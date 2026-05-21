#include "bridge_common.h"

__declspec(dllexport) void bridge_config_write_string(const char* section, const char* key, const char* value) {
    wchar_t* ws = utf8_to_utf16(section);
    wchar_t* wk = utf8_to_utf16(key);
    wchar_t* wv = utf8_to_utf16(value);
    if (ws && wk && wv) {
        WritePrivateProfileStringW(ws, wk, wv, L".\\cjform.ini");
    }
    if (ws) free(ws); if (wk) free(wk); if (wv) free(wv);
}

__declspec(dllexport) int bridge_config_read_string(const char* section, const char* key,
    const char* defaultVal, char* buffer, int bufferSize) {
    wchar_t* ws = utf8_to_utf16(section);
    wchar_t* wk = utf8_to_utf16(key);
    wchar_t* wd = utf8_to_utf16(defaultVal);
    if (!ws || !wk || !buffer || bufferSize <= 0) {
        if (ws) free(ws); if (wk) free(wk); if (wd) free(wd);
        buffer[0] = '\0'; return 0;
    }
    wchar_t wbuf[4096];
    GetPrivateProfileStringW(ws, wk, wd ? wd : L"", wbuf, 4096, L".\\cjform.ini");
    char* utf8 = utf16_to_utf8(wbuf);
    if (utf8) {
        int len = (int)strlen(utf8);
        int copyLen = len < bufferSize - 1 ? len : bufferSize - 1;
        memcpy(buffer, utf8, copyLen); buffer[copyLen] = '\0';
        free(utf8);
        if (ws) free(ws); if (wk) free(wk); if (wd) free(wd);
        return copyLen;
    }
    buffer[0] = '\0';
    if (ws) free(ws); if (wk) free(wk); if (wd) free(wd);
    return 0;
}

__declspec(dllexport) void bridge_config_write_int(const char* section, const char* key, int value) {
    char buf[32];
    snprintf(buf, sizeof(buf), "%d", value);
    bridge_config_write_string(section, key, buf);
}

__declspec(dllexport) int bridge_config_read_int(const char* section, const char* key, int defaultVal) {
    char buf[32];
    char def[32];
    snprintf(def, sizeof(def), "%d", defaultVal);
    bridge_config_read_string(section, key, def, buf, sizeof(buf));
    return atoi(buf);
}
