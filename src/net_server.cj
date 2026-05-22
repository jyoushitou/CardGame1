package myapp

import std.collection.*

public class NetServer {
    private var serverHandle: Int64
    private var clientHandle: Int64
    private var reader: StreamReader
    private var active: Bool

    public init() {
        this.serverHandle = Int64(-1)
        this.clientHandle = Int64(-1)
        this.reader = StreamReader()
        this.active = false
    }

    public func start(port: Int32): Bool {
        serverHandle = netServerCreate(port)
        if (serverHandle < Int64(0)) { return false }
        active = true
        true
    }

    public func acceptClient(): Bool {
        if (clientHandle >= Int64(0)) { return true }
        let client = netServerAccept(serverHandle)
        if (client > Int64(0)) {
            clientHandle = client
            return true
        }
        false
    }

    public func poll(): ArrayList<NetMsg> {
        let msgs = ArrayList<NetMsg>()
        if (clientHandle < Int64(0)) { return msgs }
        let data = netRecv(clientHandle)
        if (data.size > 0) {
            let lines = reader.feed(data)
            for (line in lines) {
                msgs.add(deserialize(line))
            }
        }
        msgs
    }

    public func send(msg: NetMsg): Unit {
        if (clientHandle < Int64(0)) { return }
        let wire = msg.toWire() + "\n"
        netSend(clientHandle, wire)
    }

    public func sendString(wire: String): Unit {
        if (clientHandle < Int64(0)) { return }
        netSend(clientHandle, wire + "\n")
    }

    public func stop(): Unit {
        if (clientHandle >= Int64(0)) { netClose(clientHandle) }
        if (serverHandle >= Int64(0)) { netServerClose(serverHandle) }
        clientHandle = Int64(-1)
        serverHandle = Int64(-1)
        active = false
    }

    public func isActive(): Bool { active }
    public func hasClient(): Bool { clientHandle >= Int64(0) }
}
