#include "net_ffi.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <timeapi.h>

#pragma comment(lib, "ws2_32.lib")

static bool g_netInitialized = false;

__declspec(dllexport) int bridge_net_init() {
    if (g_netInitialized) return 1;
    timeBeginPeriod(1);
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

static void set_nonblocking(SOCKET s) {
    u_long mode = 1;
    ioctlsocket(s, FIONBIO, &mode);
}

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
        if (err == WSAEWOULDBLOCK) return 0;
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

__declspec(dllexport) int64_t bridge_net_client_connect(const char* host, int port) {
    SOCKET s = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (s == INVALID_SOCKET) return -1;

    set_nonblocking(s);

    sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons((u_short)port);

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

__declspec(dllexport) int bridge_net_send(int64_t handle, const char* data, int len) {
    SOCKET s = (SOCKET)handle;
    if (s == INVALID_SOCKET) return -1;
    int sent = send(s, data, len, 0);
    return sent;
}

__declspec(dllexport) int bridge_net_recv(int64_t handle, char* buffer, int bufferSize) {
    SOCKET s = (SOCKET)handle;
    if (s == INVALID_SOCKET) return -1;
    int received = recv(s, buffer, bufferSize - 1, 0);
    if (received == SOCKET_ERROR) {
        int err = WSAGetLastError();
        if (err == WSAEWOULDBLOCK) return 0;
        return -1;
    }
    if (received > 0) {
        buffer[received] = '\0';
    }
    return received;
}

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

__declspec(dllexport) bool bridge_net_is_alive(int64_t handle) {
    SOCKET s = (SOCKET)handle;
    if (s == INVALID_SOCKET) return false;
    char buf;
    int r = recv(s, &buf, 1, MSG_PEEK);
    if (r == 0) return false;
    if (r == SOCKET_ERROR) {
        int err = WSAGetLastError();
        if (err == WSAEWOULDBLOCK) return true;
        return false;
    }
    return true;
}

__declspec(dllexport) void bridge_net_close(int64_t handle) {
    SOCKET s = (SOCKET)handle;
    if (s != INVALID_SOCKET) {
        closesocket(s);
    }
}

__declspec(dllexport) int bridge_net_last_error() {
    return WSAGetLastError();
}

__declspec(dllexport) int bridge_net_get_local_ip(char* buffer, int bufferSize) {
    if (!buffer || bufferSize <= 0) return -1;
    buffer[0] = '\0';

    char hostname[256];
    if (gethostname(hostname, sizeof(hostname)) != 0) return -1;

    struct addrinfo hints, *result = NULL;
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_protocol = IPPROTO_TCP;

    if (getaddrinfo(hostname, NULL, &hints, &result) != 0) return -1;

    int found = 0;
    for (struct addrinfo* ptr = result; ptr != NULL; ptr = ptr->ai_next) {
        struct sockaddr_in* addr = (struct sockaddr_in*)ptr->ai_addr;
        char* ip = inet_ntoa(addr->sin_addr);
        if (ip && strcmp(ip, "127.0.0.1") != 0) {
            strncpy(buffer, ip, bufferSize - 1);
            buffer[bufferSize - 1] = '\0';
            found = 1;
            break;
        }
    }

    if (!found && result) {
        struct sockaddr_in* addr = (struct sockaddr_in*)result->ai_addr;
        char* ip = inet_ntoa(addr->sin_addr);
        if (ip) {
            strncpy(buffer, ip, bufferSize - 1);
            buffer[bufferSize - 1] = '\0';
            found = 1;
        }
    }

    freeaddrinfo(result);
    return found ? (int)strlen(buffer) : -1;
}

__declspec(dllexport) int bridge_net_get_public_ip(char* buffer, int bufferSize) {
    if (!buffer || bufferSize <= 0) return -1;
    buffer[0] = '\0';

    const char* stunServer = "stun.l.google.com";
    int stunPort = 19302;

    struct addrinfo hints, *result = NULL;
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_DGRAM;
    hints.ai_protocol = IPPROTO_UDP;

    char portStr[16];
    snprintf(portStr, sizeof(portStr), "%d", stunPort);

    if (getaddrinfo(stunServer, portStr, &hints, &result) != 0 || !result) return -1;

    SOCKET s = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (s == INVALID_SOCKET) {
        freeaddrinfo(result);
        return -1;
    }

    DWORD timeout = 3000;
    setsockopt(s, SOL_SOCKET, SO_RCVTIMEO, (const char*)&timeout, sizeof(timeout));

    unsigned char request[20];
    memset(request, 0, 20);
    request[0] = 0x00; request[1] = 0x01;
    request[2] = 0x00; request[3] = 0x00;
    request[4] = 0x21; request[5] = 0x12; request[6] = 0xA4; request[7] = 0x42;
    unsigned int tick = GetTickCount();
    for (int i = 0; i < 12; i++) {
        request[8 + i] = (unsigned char)((tick >> (i * 2)) & 0xFF);
    }

    sendto(s, (const char*)request, 20, 0, result->ai_addr, (int)result->ai_addrlen);
    freeaddrinfo(result);

    unsigned char response[256];
    sockaddr_in fromAddr;
    int fromLen = sizeof(fromAddr);
    int received = recvfrom(s, (char*)response, sizeof(response), 0, (sockaddr*)&fromAddr, &fromLen);
    closesocket(s);

    if (received < 20) return -1;

    unsigned short msgType = (response[0] << 8) | response[1];
    if (msgType != 0x0101) return -1;

    unsigned int magic = (response[4] << 24) | (response[5] << 16) | (response[6] << 8) | response[7];
    if (magic != 0x2112A442) return -1;

    unsigned short msgLength = (response[2] << 8) | response[3];
    int pos = 20;

    while (pos + 4 <= received && pos < 20 + msgLength) {
        unsigned short attrType = (response[pos] << 8) | response[pos + 1];
        unsigned short attrLen = (response[pos + 2] << 8) | response[pos + 3];
        pos += 4;

        if (pos + attrLen > received) break;

        if (attrType == 0x0020 && attrLen >= 8 && pos + attrLen <= received) {
            unsigned char family = response[pos + 1];
            if (family == 0x01) {
                unsigned short xport = (response[pos + 2] << 8) | response[pos + 3];
                unsigned short port = xport ^ (magic >> 16);

                unsigned int xaddr = (response[pos + 4] << 24) | (response[pos + 5] << 16) |
                                    (response[pos + 6] << 8) | response[pos + 7];
                unsigned int addr = xaddr ^ magic;

                snprintf(buffer, bufferSize, "%d.%d.%d.%d",
                    (addr >> 24) & 0xFF, (addr >> 16) & 0xFF,
                    (addr >> 8) & 0xFF, addr & 0xFF);
                return (int)strlen(buffer);
            }
        }
        if (attrType == 0x0001 && attrLen >= 8 && pos + attrLen <= received) {
            unsigned char family = response[pos + 1];
            if (family == 0x01) {
                unsigned int addr = (response[pos + 4] << 24) | (response[pos + 5] << 16) |
                                   (response[pos + 6] << 8) | response[pos + 7];
                snprintf(buffer, bufferSize, "%d.%d.%d.%d",
                    (addr >> 24) & 0xFF, (addr >> 16) & 0xFF,
                    (addr >> 8) & 0xFF, addr & 0xFF);
                return (int)strlen(buffer);
            }
        }

        pos += attrLen;
        if (attrLen % 4 != 0) pos += 4 - (attrLen % 4);
    }

    return -1;
}

static bool http_get(const char* host, int port, const char* path, char* response, int responseSize) {
    SOCKET s = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (s == INVALID_SOCKET) return false;

    struct addrinfo hints, *result = NULL;
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;

    char portStr[16];
    snprintf(portStr, sizeof(portStr), "%d", port);
    if (getaddrinfo(host, portStr, &hints, &result) != 0 || !result) {
        closesocket(s);
        return false;
    }

    DWORD timeout = 5000;
    setsockopt(s, SOL_SOCKET, SO_RCVTIMEO, (const char*)&timeout, sizeof(timeout));

    if (connect(s, result->ai_addr, (int)result->ai_addrlen) == SOCKET_ERROR) {
        int err = WSAGetLastError();
        closesocket(s);
        freeaddrinfo(result);
        return false;
    }
    freeaddrinfo(result);

    char req[2048];
    snprintf(req, sizeof(req),
        "GET %s HTTP/1.1\r\n"
        "Host: %s:%d\r\n"
        "Connection: close\r\n"
        "\r\n",
        path, host, port);

    send(s, req, (int)strlen(req), 0);

    int total = 0;
    while (total < responseSize - 1) {
        int r = recv(s, response + total, responseSize - 1 - total, 0);
        if (r <= 0) break;
        total += r;
    }
    if (total > 0 && total < responseSize) {
        response[total] = '\0';
    }
    closesocket(s);
    return total > 0;
}

static bool http_post_soap(const char* host, int port, const char* path,
                           const char* soapAction, const char* body,
                           char* response, int responseSize) {
    SOCKET s = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (s == INVALID_SOCKET) return false;

    struct addrinfo hints, *result = NULL;
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;

    char portStr[16];
    snprintf(portStr, sizeof(portStr), "%d", port);
    if (getaddrinfo(host, portStr, &hints, &result) != 0 || !result) {
        closesocket(s);
        return false;
    }

    DWORD timeout = 5000;
    setsockopt(s, SOL_SOCKET, SO_RCVTIMEO, (const char*)&timeout, sizeof(timeout));

    if (connect(s, result->ai_addr, (int)result->ai_addrlen) == SOCKET_ERROR) {
        closesocket(s);
        freeaddrinfo(result);
        return false;
    }
    freeaddrinfo(result);

    int bodyLen = (int)strlen(body);
    char req[4096];
    snprintf(req, sizeof(req),
        "POST %s HTTP/1.1\r\n"
        "Host: %s:%d\r\n"
        "Content-Type: text/xml; charset=\"utf-8\"\r\n"
        "SOAPAction: \"%s\"\r\n"
        "Content-Length: %d\r\n"
        "Connection: close\r\n"
        "\r\n"
        "%s",
        path, host, port, soapAction, bodyLen, body);

    send(s, req, (int)strlen(req), 0);

    int total = 0;
    while (total < responseSize - 1) {
        int r = recv(s, response + total, responseSize - 1 - total, 0);
        if (r <= 0) break;
        total += r;
    }
    if (total > 0 && total < responseSize) {
        response[total] = '\0';
    }
    closesocket(s);
    return total > 0;
}

static const char* xml_extract(const char* body, const char* tag) {
    static char buf[512];
    char openTag[128], closeTag[128];
    snprintf(openTag, sizeof(openTag), "<%s>", tag);
    snprintf(closeTag, sizeof(closeTag), "</%s>", tag);

    const char* start = strstr(body, openTag);
    if (!start) return NULL;
    start += strlen(openTag);
    const char* end = strstr(start, closeTag);
    if (!end) return NULL;

    size_t len = end - start;
    if (len >= sizeof(buf)) len = sizeof(buf) - 1;
    memcpy(buf, start, len);
    buf[len] = '\0';
    return buf;
}

static void parse_url(const char* url, char* host, int hostSize, int* port, char* path, int pathSize) {
    *port = 80;
    host[0] = '\0';
    path[0] = '/';
    path[1] = '\0';

    const char* p = url;
    if (strncmp(p, "http://", 7) == 0) p += 7;

    const char* hostEnd = strchr(p, ':');
    const char* pathStart = strchr(p, '/');

    if (hostEnd && (!pathStart || hostEnd < pathStart)) {
        size_t hLen = hostEnd - p;
        if (hLen >= (size_t)hostSize) hLen = hostSize - 1;
        memcpy(host, p, hLen);
        host[hLen] = '\0';
        *port = atoi(hostEnd + 1);
        const char* slash = strchr(hostEnd, '/');
        if (slash) {
            strncpy(path, slash, pathSize - 1);
            path[pathSize - 1] = '\0';
        }
    } else if (pathStart) {
        size_t hLen = pathStart - p;
        if (hLen >= (size_t)hostSize) hLen = hostSize - 1;
        memcpy(host, p, hLen);
        host[hLen] = '\0';
        strncpy(path, pathStart, pathSize - 1);
        path[pathSize - 1] = '\0';
    } else {
        strncpy(host, p, hostSize - 1);
        host[hostSize - 1] = '\0';
    }
}

__declspec(dllexport) int bridge_upnp_add_mapping(int port, const char* protocol, const char* description) {
    const char* ssdpAddr = "239.255.255.250";
    int ssdpPort = 1900;

    SOCKET udp = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (udp == INVALID_SOCKET) return 0;

    DWORD timeout = 3000;
    setsockopt(udp, SOL_SOCKET, SO_RCVTIMEO, (const char*)&timeout, sizeof(timeout));

    sockaddr_in bindAddr;
    memset(&bindAddr, 0, sizeof(bindAddr));
    bindAddr.sin_family = AF_INET;
    bindAddr.sin_addr.s_addr = INADDR_ANY;
    bindAddr.sin_port = 0;
    bind(udp, (sockaddr*)&bindAddr, sizeof(bindAddr));

    char msearch[512];
    snprintf(msearch, sizeof(msearch),
        "M-SEARCH * HTTP/1.1\r\n"
        "HOST: 239.255.255.250:1900\r\n"
        "MAN: \"ssdp:discover\"\r\n"
        "MX: 2\r\n"
        "ST: urn:schemas-upnp-org:device:InternetGatewayDevice:1\r\n"
        "\r\n");

    sockaddr_in ssdpAddrIn;
    memset(&ssdpAddrIn, 0, sizeof(ssdpAddrIn));
    ssdpAddrIn.sin_family = AF_INET;
    ssdpAddrIn.sin_port = htons((u_short)ssdpPort);
    ssdpAddrIn.sin_addr.s_addr = inet_addr(ssdpAddr);

    sendto(udp, msearch, (int)strlen(msearch), 0, (sockaddr*)&ssdpAddrIn, sizeof(ssdpAddrIn));

    snprintf(msearch, sizeof(msearch),
        "M-SEARCH * HTTP/1.1\r\n"
        "HOST: 239.255.255.250:1900\r\n"
        "MAN: \"ssdp:discover\"\r\n"
        "MX: 2\r\n"
        "ST: urn:schemas-upnp-org:service:WANIPConnection:1\r\n"
        "\r\n");
    sendto(udp, msearch, (int)strlen(msearch), 0, (sockaddr*)&ssdpAddrIn, sizeof(ssdpAddrIn));

    char recvBuf[2048];
    char locationUrl[512] = "";
    int tries = 0;

    while (tries < 10) {
        int r = recvfrom(udp, recvBuf, sizeof(recvBuf) - 1, 0, NULL, NULL);
        if (r <= 0) break;

        recvBuf[r] = '\0';

        const char* loc = strstr(recvBuf, "LOCATION:");
        if (!loc) loc = strstr(recvBuf, "Location:");
        if (loc) {
            loc = strchr(loc, ':') + 1;
            while (*loc == ' ') loc++;
            const char* end = strstr(loc, "\r\n");
            if (end) {
                size_t len = end - loc;
                if (len < sizeof(locationUrl)) {
                    memcpy(locationUrl, loc, len);
                    locationUrl[len] = '\0';
                    break;
                }
            }
        }
        tries++;
    }
    closesocket(udp);

    if (locationUrl[0] == '\0') return 0;

    char descHost[256], descPath[512];
    int descPort;
    parse_url(locationUrl, descHost, sizeof(descHost), &descPort, descPath, sizeof(descPath));

    char descXml[8192] = "";
    if (!http_get(descHost, descPort, descPath, descXml, sizeof(descXml))) return 0;

    const char* servicePos = NULL;
    const char* checkServices[] = {
        "urn:schemas-upnp-org:service:WANIPConnection:1",
        "urn:schemas-upnp-org:service:WANPPPConnection:1"
    };

    for (int si = 0; si < 2; si++) {
        servicePos = strstr(descXml, checkServices[si]);
        if (servicePos) break;
    }
    if (!servicePos) return 0;

    const char* ctrl = strstr(servicePos, "<controlURL>");
    if (!ctrl) ctrl = strstr(descXml, "<controlURL>");
    if (!ctrl) return 0;

    ctrl += strlen("<controlURL>");
    const char* ctrlEnd = strstr(ctrl, "</controlURL>");
    if (!ctrlEnd) return 0;

    char controlPath[512];
    size_t cpLen = ctrlEnd - ctrl;
    if (cpLen >= sizeof(controlPath)) cpLen = sizeof(controlPath) - 1;
    memcpy(controlPath, ctrl, cpLen);
    controlPath[cpLen] = '\0';

    char localIp[64] = "127.0.0.1";
    bridge_net_get_local_ip(localIp, sizeof(localIp));

    char soapBody[2048];
    snprintf(soapBody, sizeof(soapBody),
        "<?xml version=\"1.0\"?>"
        "<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" "
        "s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
        "<s:Body>"
        "<u:AddPortMapping xmlns:u=\"urn:schemas-upnp-org:service:WANIPConnection:1\">"
        "<NewRemoteHost></NewRemoteHost>"
        "<NewExternalPort>%d</NewExternalPort>"
        "<NewProtocol>%s</NewProtocol>"
        "<NewInternalPort>%d</NewInternalPort>"
        "<NewInternalClient>%s</NewInternalClient>"
        "<NewEnabled>1</NewEnabled>"
        "<NewPortMappingDescription>%s</NewPortMappingDescription>"
        "<NewLeaseDuration>0</NewLeaseDuration>"
        "</u:AddPortMapping>"
        "</s:Body>"
        "</s:Envelope>",
        port, protocol, port, localIp, description);

    char soapAction[256];
    snprintf(soapAction, sizeof(soapAction),
        "urn:schemas-upnp-org:service:WANIPConnection:1#AddPortMapping");

    char soapResp[4096] = "";
    if (http_post_soap(descHost, descPort, controlPath, soapAction, soapBody, soapResp, sizeof(soapResp))) {
        if (strstr(soapResp, "200 OK") || !strstr(soapResp, "<errorCode>")) {
            return 1;
        }
    }

    return 0;
}
