package myapp

import std.collection.*
import cjform.*

public class NetClient {
    private var handle: Int64
    private var reader: StreamReader
    private var connected: Bool
    private var connecting: Bool
    private var connectStartTick: Int64

    private var discoveryHandle: Int64
    private var discovering: Bool
    private var discoveryStartTick: Int64
    private var discoveryNextSendTick: Int64
    private var discoveryPort: Int32
    private var foundHosts: ArrayList<String>

    public init() {
        this.handle = Int64(-1)
        this.reader = StreamReader()
        this.connected = false
        this.connecting = false
        this.connectStartTick = Int64(0)
        this.discoveryHandle = Int64(-1)
        this.discovering = false
        this.discoveryStartTick = Int64(0)
        this.discoveryNextSendTick = Int64(0)
        this.discoveryPort = 0
        this.foundHosts = ArrayList<String>()
    }

    public func startDiscovery(port: Int32): Unit {
        discoveryHandle = netUdpCreate(0)
        if (discoveryHandle < Int64(0)) {
            discovering = false
            return
        }
        discoveryPort = port
        foundHosts = ArrayList<String>()
        discovering = true
        discoveryStartTick = ffi_getTickCount()
        discoveryNextSendTick = discoveryStartTick
    }

    public func pollDiscovery(): ArrayList<String> {
        let newHosts = ArrayList<String>()
        if (!discovering || discoveryHandle < Int64(0)) { return newHosts }

        let now = ffi_getTickCount()
        if (now >= discoveryNextSendTick) {
            let msg = MsgBuilder(DISCOVER).build()
            netUdpSend(discoveryHandle, "255.255.255.255", discoveryPort, msg)
            netUdpSend(discoveryHandle, "255.255.255.255", discoveryPort, msg)
            netUdpSend(discoveryHandle, "255.255.255.255", discoveryPort, msg)
            discoveryNextSendTick = now + Int64(200)
        }

        while (true) {
            let (host, data, _) = netUdpRecv(discoveryHandle)
            if (host.size == 0 || data.size == 0) { break }
            let parsed = deserialize(data)
            if (parsed.msgType == ANNOUNCE) {
                var dup = false
                for (h in foundHosts) {
                    if (h == host) { dup = true }
                }
                if (!dup) {
                    foundHosts.add(host)
                    newHosts.add(host)
                }
            }
        }

        if (now - discoveryStartTick > Int64(5000)) {
            stopDiscovery()
        }
        newHosts
    }

    public func stopDiscovery(): Unit {
        if (discoveryHandle >= Int64(0)) { netUdpClose(discoveryHandle) }
        discoveryHandle = Int64(-1)
        discovering = false
    }

    public func isDiscovering(): Bool { discovering }

    public func startConnect(host: String, port: Int32): Unit {
        handle = netClientConnect(host, port)
        if (handle < Int64(0)) {
            connecting = false
            return
        }
        connecting = true
        connectStartTick = ffi_getTickCount()
    }

    public func pollConnect(): Bool {
        if (!connecting || handle < Int64(0)) { return false }
        if (netIsConnected(handle)) {
            connecting = false
            connected = true
            return true
        }
        if (ffi_getTickCount() - connectStartTick > Int64(5000)) {
            netClose(handle)
            handle = Int64(-1)
            connecting = false
            return false
        }
        false
    }

    public func isConnecting(): Bool { connecting }

    public func pollRaw(): ArrayList<String> {
        let lines = ArrayList<String>()
        if (handle < Int64(0)) { return lines }
        if (!netIsAlive(handle)) {
            connected = false
            handle = Int64(-1)
            return lines
        }
        let data = netRecv(handle)
        if (data.size > 0) {
            let rawLines = reader.feed(data)
            for (line in rawLines) {
                lines.add(line)
            }
        }
        lines
    }

    public func poll(): ArrayList<NetMsg> {
        let msgs = ArrayList<NetMsg>()
        if (handle < Int64(0)) { return msgs }
        if (!netIsAlive(handle)) {
            connected = false
            handle = Int64(-1)
            return msgs
        }
        let data = netRecv(handle)
        if (data.size > 0) {
            let lines = reader.feed(data)
            for (line in lines) {
                msgs.add(deserialize(line))
            }
        }
        msgs
    }

    public func send(msg: NetMsg): Unit {
        if (handle < Int64(0)) { return }
        let wire = msg.toWire() + "\n"
        netSend(handle, wire)
    }

    public func sendString(wire: String): Unit {
        if (handle < Int64(0)) { return }
        netSend(handle, wire + "\n")
    }

    public func sendRaw(data: String): Unit {
        if (handle < Int64(0)) { return }
        netSend(handle, data)
    }

    public func getHandle(): Int64 { handle }

    public func disconnect(): Unit {
        if (handle >= Int64(0)) { netClose(handle) }
        handle = Int64(-1)
        connected = false
        connecting = false
    }

    public func isConnected(): Bool { connected }
}
