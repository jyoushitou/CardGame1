#ifndef NET_FFI_H
#define NET_FFI_H

#include <cstdint>
#include <winsock2.h>
#include <ws2tcpip.h>

extern "C" {

__declspec(dllexport) int bridge_net_init();
__declspec(dllexport) void bridge_net_cleanup();

// TCP Server
__declspec(dllexport) int64_t bridge_net_server_create(int port);
__declspec(dllexport) int64_t bridge_net_server_accept(int64_t serverHandle);
__declspec(dllexport) void bridge_net_server_close(int64_t serverHandle);

// TCP Client
__declspec(dllexport) int64_t bridge_net_client_connect(const char* host, int port);
__declspec(dllexport) bool bridge_net_is_connected(int64_t handle);

// Data transfer (shared by server client sockets and client sockets)
__declspec(dllexport) int bridge_net_send(int64_t handle, const char* data, int len);
__declspec(dllexport) int bridge_net_recv(int64_t handle, char* buffer, int bufferSize);

// UDP (for LAN discovery)
__declspec(dllexport) int64_t bridge_net_udp_create(int port);
__declspec(dllexport) int bridge_net_udp_send(int64_t handle, const char* host, int port, const char* data, int len);
__declspec(dllexport) int bridge_net_udp_recv(int64_t handle, char* buffer, int bufferSize, char* fromHost, int* fromPort);
__declspec(dllexport) void bridge_net_udp_close(int64_t handle);

// Utility
__declspec(dllexport) void bridge_net_close(int64_t handle);
__declspec(dllexport) bool bridge_net_is_alive(int64_t handle);
__declspec(dllexport) int bridge_net_last_error();

}

#endif
