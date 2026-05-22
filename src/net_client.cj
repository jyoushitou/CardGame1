package myapp

import std.collection.*

public class NetClient {
    private var handle: Int64
    private var reader: StreamReader
    private var connected: Bool

    public init() {
        this.handle = Int64(-1)
        this.reader = StreamReader()
        this.connected = false
    }

    public func connect(host: String, port: Int32): Bool {
        handle = netClientConnect(host, port)
        if (handle < Int64(0)) { return false }
        connected = true
        true
    }

    public func poll(): ArrayList<NetMsg> {
        let msgs = ArrayList<NetMsg>()
        if (handle < Int64(0)) { return msgs }
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

    public func disconnect(): Unit {
        if (handle >= Int64(0)) { netClose(handle) }
        handle = Int64(-1)
        connected = false
    }

    public func isConnected(): Bool { connected }

    public static func discover(port: Int32): ArrayList<String> {
        let hosts = ArrayList<String>()
        let udpHandle = netUdpCreate(0)
        if (udpHandle < Int64(0)) { return hosts }
        let msg = MsgBuilder(DISCOVER).build()
        netUdpSend(udpHandle, "255.255.255.255", port, msg)

        for (_ in 0..5) {
            let (host, data, _) = netUdpRecv(udpHandle)
            if (host.size > 0 && data.size > 0) {
                let parsed = deserialize(data)
                if (parsed.msgType == ANNOUNCE) {
                    var dup = false
                    for (h in hosts) {
                        if (h == host) { dup = true }
                    }
                    if (!dup) { hosts.add(host) }
                }
            }
        }
        netUdpClose(udpHandle)
        hosts
    }

    public static func announce(port: Int32, playerName: String): Unit {
        let udpHandle = netUdpCreate(port)
        if (udpHandle < Int64(0)) { return }

        let (host, data, _) = netUdpRecv(udpHandle)
        if (host.size > 0 && data.size > 0) {
            let parsed = deserialize(data)
            if (parsed.msgType == DISCOVER) {
                let resp = MsgBuilder(ANNOUNCE).add("name", playerName).build()
                netUdpSend(udpHandle, host, port, resp)
            }
        }
        netUdpClose(udpHandle)
    }
}
