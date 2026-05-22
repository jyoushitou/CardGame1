#include "net_ffi.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#pragma comment(lib, "ws2_32.lib")

static bool g_netInitialized = false;

// --- Init / Cleanup ---

__declspec(dllexport) int bridge_net_init() {
    if (g_netInitialized) return 1;
    WSADATA wsaData;
    int result = WSAStartup(MAKEWORD(2, 2), &wsaData);
    if (result == 0) {
        g_netInitialized = true;
        return 1;
    }
    return 0;
}

__declspec(dllexport) void bridge_net_cleanup() {
    if (g_netInitialized) {
        WSACleanup();
        g_netInitialized = false;
    }
}

// --- Helper: set non-blocking mode ---

static void set_nonblocking(SOCKET s) {
    u_long mode = 1;
    ioctlsocket(s, FIONBIO, &mode);
}

// --- TCP Server ---

__declspec(dllexport) int64_t bridge_net_server_create(int port) {
    SOCKET s = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (s == INVALID_SOCKET) return -1;

    int opt = 1;
    setsockopt(s, SOL_SOCKET, SO_REUSEADDR, (const char*)&opt, sizeof(opt));

    sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = INADDR_ANY;
    addr.sin_port = htons((u_short)port);

    if (bind(s, (sockaddr*)&addr, sizeof(addr)) == SOCKET_ERROR) {
        closesocket(s);
        return -1;
    }

    if (listen(s, 1) == SOCKET_ERROR) {
        closesocket(s);
        return -1;
    }

    set_nonblocking(s);
    return (int64_t)s;
}

__declspec(dllexport) int64_t bridge_net_server_accept(int64_t serverHandle) {
    SOCKET server = (SOCKET)serverHandle;
    if (server == INVALID_SOCKET) return -1;

    sockaddr_in clientAddr;
    int addrLen = sizeof(clientAddr);
    SOCKET client = accept(server, (sockaddr*)&clientAddr, &addrLen);

    if (client == INVALID_SOCKET) {
        int err = WSAGetLastError();
        if (err == WSAEWOULDBLOCK) return 0;  // no pending connection
        return -1;
    }

    set_nonblocking(client);
    return (int64_t)client;
}

__declspec(dllexport) void bridge_net_server_close(int64_t serverHandle) {
    SOCKET s = (SOCKET)serverHandle;
    if (s != INVALID_SOCKET) {
        closesocket(s);
    }
}

// --- TCP Client ---

__declspec(dllexport) int64_t bridge_net_client_connect(const char* host, int port) {
    SOCKET s = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (s == INVALID_SOCKET) return -1;

    set_nonblocking(s);

    sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons((u_short)port);

    // Try to resolve host
    addrinfo hints, *result = NULL;
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;

    char portStr[16];
    snprintf(portStr, sizeof(portStr), "%d", port);

    if (getaddrinfo(host, portStr, &hints, &result) == 0 && result) {
        memcpy(&addr, result->ai_addr, sizeof(addr));
        freeaddrinfo(result);
    } else {
        addr.sin_addr.s_addr = inet_addr(host);
        if (addr.sin_addr.s_addr == INADDR_NONE) {
            closesocket(s);
            return -1;
        }
    }

    connect(s, (sockaddr*)&addr, sizeof(addr));
    // Non-blocking connect will return immediately; check with send/recv later
    return (int64_t)s;
}

__declspec(dllexport) bool bridge_net_is_connected(int64_t handle) {
    SOCKET s = (SOCKET)handle;
    if (s == INVALID_SOCKET) return false;

    fd_set writeSet;
    FD_ZERO(&writeSet);
    FD_SET(s, &writeSet);

    timeval timeout;
    timeout.tv_sec = 0;
    timeout.tv_usec = 0;

    int result = select(0, NULL, &writeSet, NULL, &timeout);
    if (result > 0) {
        // Check for socket error
        int error = 0;
        int len = sizeof(error);
        getsockopt(s, SOL_SOCKET, SO_ERROR, (char*)&error, &len);
        return error == 0;
    }
    return false;
}

// --- Data transfer ---

__declspec(dllexport) int bridge_net_send(int64_t handle, const char* data, int len) {
    SOCKET s = (SOCKET)handle;
    if (s == INVALID_SOCKET) return -1;
    int sent = send(s, data, len, 0);
    return sent;
}

__declspec(dllexport) int bridge_net_recv(int64_t handle, char* buffer, int bufferSize) {
    SOCKET s = (SOCKET)handle;
    if (s == INVALID_SOCKET) return -1;
    int received = recv(s, buffer, bufferSize - 1, 0);  // Leave room for null
    if (received == SOCKET_ERROR) {
        int err = WSAGetLastError();
        if (err == WSAEWOULDBLOCK) return 0;
        return -1;
    }
    if (received > 0) {
        buffer[received] = '\0';  // Null-terminate
    }
    return received;
}

// --- UDP ---

__declspec(dllexport) int64_t bridge_net_udp_create(int port) {
    SOCKET s = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (s == INVALID_SOCKET) return -1;

    int opt = 1;
    setsockopt(s, SOL_SOCKET, SO_BROADCAST, (const char*)&opt, sizeof(opt));
    setsockopt(s, SOL_SOCKET, SO_REUSEADDR, (const char*)&opt, sizeof(opt));

    sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = INADDR_ANY;
    addr.sin_port = htons((u_short)port);

    if (bind(s, (sockaddr*)&addr, sizeof(addr)) == SOCKET_ERROR) {
        // Don't fail on bind failure — allow send-only use
    }

    set_nonblocking(s);
    return (int64_t)s;
}

__declspec(dllexport) int bridge_net_udp_send(int64_t handle, const char* host, int port, const char* data, int len) {
    SOCKET s = (SOCKET)handle;
    if (s == INVALID_SOCKET) return -1;

    sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons((u_short)port);
    addr.sin_addr.s_addr = inet_addr(host);
    if (addr.sin_addr.s_addr == INADDR_NONE) {
        // Try broadcast
        addr.sin_addr.s_addr = INADDR_BROADCAST;
    }

    int sent = sendto(s, data, len, 0, (sockaddr*)&addr, sizeof(addr));
    return sent;
}

__declspec(dllexport) int bridge_net_udp_recv(int64_t handle, char* buffer, int bufferSize, char* fromHost, int* fromPort) {
    SOCKET s = (SOCKET)handle;
    if (s == INVALID_SOCKET) return -1;

    sockaddr_in from;
    int fromLen = sizeof(from);
    memset(&from, 0, sizeof(from));

    int received = recvfrom(s, buffer, bufferSize - 1, 0, (sockaddr*)&from, &fromLen);
    if (received == SOCKET_ERROR) {
        int err = WSAGetLastError();
        if (err == WSAEWOULDBLOCK) return 0;
        return -1;
    }
    if (received > 0) {
        buffer[received] = '\0';
    }

    if (fromHost && fromPort) {
        // Convert IP to string
        char* ipStr = inet_ntoa(from.sin_addr);
        if (ipStr) {
            strncpy(fromHost, ipStr, 64);
            fromHost[63] = '\0';
        }
        *fromPort = ntohs(from.sin_port);
    }

    return received;
}

__declspec(dllexport) void bridge_net_udp_close(int64_t handle) {
    SOCKET s = (SOCKET)handle;
    if (s != INVALID_SOCKET) {
        closesocket(s);
    }
}

// --- Generic close ---

__declspec(dllexport) void bridge_net_close(int64_t handle) {
    SOCKET s = (SOCKET)handle;
    if (s != INVALID_SOCKET) {
        closesocket(s);
    }
}

__declspec(dllexport) int bridge_net_last_error() {
    return WSAGetLastError();
}
