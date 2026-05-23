"""
CjForm CardGame — Relay Server
Pairs two clients with the same room code and forwards TCP data between them.
"""

import asyncio
import logging
import sys

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
log = logging.getLogger("relay")

RELAY_PORT = 9528
HANDSHAKE_TIMEOUT = 10
PAIR_TIMEOUT = 120

class RelayServer:
    def __init__(self, host: str = "0.0.0.0", port: int = RELAY_PORT):
        self.host = host
        self.port = port
        self.pending: dict[str, tuple[asyncio.StreamReader, asyncio.StreamWriter, str, asyncio.Event]] = {}
        self.pairs: dict[str, tuple[asyncio.Task, asyncio.Task]] = {}

    async def handle(self, reader: asyncio.StreamReader, writer: asyncio.StreamWriter):
        addr = writer.get_extra_info("peername")
        log.info(f"[connect] {addr}")

        try:
            line = await asyncio.wait_for(reader.readline(), HANDSHAKE_TIMEOUT)
        except asyncio.TimeoutError:
            log.warning(f"[timeout] {addr} — no handshake")
            writer.close()
            return

        if not line:
            log.info(f"[disconnect] {addr} — closed before handshake")
            writer.close()
            return

        raw = line.decode("utf-8", errors="replace").strip()
        if ":" not in raw:
            log.warning(f"[bad-msg] {addr}: {raw}")
            writer.close()
            return

        role, room = raw.split(":", 1)
        role = role.upper()
        room = room.strip().upper()
        if not room or role not in ("HOST", "GUEST"):
            log.warning(f"[bad-msg] {addr}: role={role} room={room}")
            writer.close()
            return

        log.info(f"[handshake] {addr} role={role} room={room}")

        if room in self.pending:
            other_reader, other_writer, other_role, _ = self.pending[room]

            if other_role == role:
                log.warning(f"[reject] {addr} — room={room} already has {other_role}")
                try:
                    writer.write(b"REJECT:room already has that role\n")
                    await writer.drain()
                except Exception:
                    pass
                writer.close()
                return

            other_reader, other_writer, other_role, other_event = self.pending.pop(room)
            other_event.set()

            log.info(f"[paired] room={room}  {other_role} <-> {role}")
            try:
                other_writer.write(b"PAIRED\n")
                await other_writer.drain()
            except Exception:
                pass
            try:
                writer.write(b"PAIRED\n")
                await writer.drain()
            except Exception:
                pass

            if role == "HOST":
                h_reader, h_writer = reader, writer
                g_reader, g_writer = other_reader, other_writer
            else:
                h_reader, h_writer = other_reader, other_writer
                g_reader, g_writer = reader, writer

            task_a = asyncio.create_task(self.forward(room, "H->G", h_reader, g_writer))
            task_b = asyncio.create_task(self.forward(room, "G->H", g_reader, h_writer))
            self.pairs[room] = (task_a, task_b)

        else:
            event = asyncio.Event()
            self.pending[room] = (reader, writer, role, event)
            log.info(f"[waiting] room={room} role={role} — waiting for peer")
            try:
                await asyncio.wait_for(event.wait(), PAIR_TIMEOUT)
            except asyncio.TimeoutError:
                pass
            if room in self.pending:
                r, w, _, _ = self.pending.pop(room)
                log.info(f"[expired] room={room} — peer never arrived")
                try:
                    w.write(b"TIMEOUT:peer never arrived\n")
                    await w.drain()
                except Exception:
                    pass
                w.close()

    async def forward(self, room: str, tag: str, reader: asyncio.StreamReader, writer: asyncio.StreamWriter):
        try:
            while True:
                data = await reader.read(4096)
                if not data:
                    break
                writer.write(data)
                await writer.drain()
        except Exception as e:
            log.debug(f"[{tag}] error: {e}")
        finally:
            log.info(f"[{tag}] room={room} closed")
            try:
                writer.close()
            except Exception:
                pass
            if room in self.pairs:
                t_a, t_b = self.pairs.pop(room)
                for t in (t_a, t_b):
                    if not t.done():
                        t.cancel()

    async def start(self):
        server = await asyncio.start_server(self.handle, self.host, self.port)
        addrs = ", ".join(str(s.getsockname()) for s in server.sockets)
        log.info(f"Relay server listening on {addrs}")
        async with server:
            await server.serve_forever()


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else RELAY_PORT
    host = sys.argv[2] if len(sys.argv) > 2 else "0.0.0.0"
    asyncio.run(RelayServer(host, port).start())
