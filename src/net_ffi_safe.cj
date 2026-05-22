package myapp

import cjform.*

foreign func bridge_net_init(): Int32
foreign func bridge_net_cleanup(): Unit
foreign func bridge_net_server_create(port: Int32): Int64
foreign func bridge_net_server_accept(serverHandle: Int64): Int64
foreign func bridge_net_server_close(serverHandle: Int64): Unit
foreign func bridge_net_client_connect(host: CString, port: Int32): Int64
foreign func bridge_net_is_connected(handle: Int64): Bool
foreign func bridge_net_send(handle: Int64, data: CString, len: Int32): Int32
foreign func bridge_net_recv(handle: Int64, buffer: CPointer<Byte>, bufferSize: Int32): Int32
foreign func bridge_net_udp_create(port: Int32): Int64
foreign func bridge_net_udp_send(handle: Int64, host: CString, port: Int32, data: CString, len: Int32): Int32
foreign func bridge_net_udp_recv(handle: Int64, buffer: CPointer<Byte>, bufferSize: Int32, fromHost: CPointer<Byte>, fromPort: CPointer<Int32>): Int32
foreign func bridge_net_udp_close(handle: Int64): Unit
foreign func bridge_net_close(handle: Int64): Unit

public func netInit(): Bool {
    let result = unsafe { bridge_net_init() }
    result != 0
}

public func netCleanup(): Unit {
    unsafe { bridge_net_cleanup() }
}

public func netServerCreate(port: Int32): Int64 {
    unsafe { bridge_net_server_create(port) }
}

public func netServerAccept(serverHandle: Int64): Int64 {
    unsafe { bridge_net_server_accept(serverHandle) }
}

public func netServerClose(handle: Int64): Unit {
    unsafe { bridge_net_server_close(handle) }
}

public func netClientConnect(host: String, port: Int32): Int64 {
    let cstr = unsafe { LibC.mallocCString(host) }
    let handle = unsafe { bridge_net_client_connect(cstr, port) }
    unsafe { LibC.free(cstr) }
    handle
}

public func netIsConnected(handle: Int64): Bool {
    unsafe { bridge_net_is_connected(handle) }
}

public func netSend(handle: Int64, data: String): Int32 {
    let cstr = unsafe { LibC.mallocCString(data) }
    let sent = unsafe { bridge_net_send(handle, cstr, Int32(data.size)) }
    unsafe { LibC.free(cstr) }
    sent
}

public func netRecv(handle: Int64): String {
    let buffer = unsafe { LibC.malloc<Byte>(count: 4096) }
    let received = unsafe { bridge_net_recv(handle, buffer, 4096) }
    if (received > 0) {
        let result = unsafe { CString(buffer) }.toString()
        unsafe { LibC.free(buffer) }
        result
    } else {
        unsafe { LibC.free(buffer) }
        ""
    }
}

public func netUdpCreate(port: Int32): Int64 {
    unsafe { bridge_net_udp_create(port) }
}

public func netUdpSend(handle: Int64, host: String, port: Int32, data: String): Int32 {
    let hc = unsafe { LibC.mallocCString(host) }
    let dc = unsafe { LibC.mallocCString(data) }
    let sent = unsafe { bridge_net_udp_send(handle, hc, port, dc, Int32(data.size)) }
    unsafe { LibC.free(hc); LibC.free(dc) }
    sent
}

public func netUdpRecv(handle: Int64): (String, String, Int32) {
    let buffer = unsafe { LibC.malloc<Byte>(count: 1024) }
    let hostBuf = unsafe { LibC.malloc<Byte>(count: 64) }
    let portPtr = unsafe { LibC.malloc<Int32>(count: 1) }
    let received = unsafe { bridge_net_udp_recv(handle, buffer, 1024, hostBuf, portPtr) }
    if (received > 0) {
        let host = unsafe { CString(hostBuf) }.toString()
        let port = unsafe { portPtr.read() }
        let data = unsafe { CString(buffer) }.toString()
        unsafe { LibC.free(buffer); LibC.free(hostBuf); LibC.free(portPtr) }
        (host, data, port)
    } else {
        unsafe { LibC.free(buffer); LibC.free(hostBuf); LibC.free(portPtr) }
        ("", "", 0)
    }
}

public func netUdpClose(handle: Int64): Unit {
    unsafe { bridge_net_udp_close(handle) }
}

public func netClose(handle: Int64): Unit {
    unsafe { bridge_net_close(handle) }
}
