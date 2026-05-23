package myapp

import std.collection.*

public class NetServer {
    private var serverHandle: Int64
    private var clientHandle: Int64
    private var reader: StreamReader
    private var active: Bool
    private var udpHandle: Int64

    public init() {
        this.serverHandle = Int64(-1)
        this.clientHandle = Int64(-1)
        this.reader = StreamReader()
        this.active = false
        this.udpHandle = Int64(-1)
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
        if (!netIsAlive(clientHandle)) {
            clientHandle = Int64(-1)
            return msgs
        }
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

    public func startDiscovery(port: Int32): Unit {
        udpHandle = netUdpCreate(port)
    }

    public func pollDiscovery(): Unit {
        if (udpHandle < Int64(0)) { return }
        while (true) {
            let (host, data, srcPort) = netUdpRecv(udpHandle)
            if (host.size == 0 || data.size == 0) { break }
            let parsed = deserialize(data)
            if (parsed.msgType == DISCOVER) {
                let resp = MsgBuilder(ANNOUNCE).add("name", "Host").build()
                netUdpSend(udpHandle, host, srcPort, resp)
            }
        }
    }

    public func stopDiscovery(): Unit {
        if (udpHandle >= Int64(0)) { netUdpClose(udpHandle) }
        udpHandle = Int64(-1)
    }
}
