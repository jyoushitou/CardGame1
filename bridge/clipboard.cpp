#include "bridge_common.h"

__declspec(dllexport) void bridge_clipboard_set_text(const char* text) {
    if (!text || !OpenClipboard(NULL)) return;
    EmptyClipboard();
    int len = MultiByteToWideChar(CP_UTF8, 0, text, -1, NULL, 0);
    if (len > 0) {
        HGLOBAL hMem = GlobalAlloc(GMEM_MOVEABLE, len * sizeof(wchar_t));
        if (hMem) { wchar_t* ws = (wchar_t*)GlobalLock(hMem);
            if (ws) { MultiByteToWideChar(CP_UTF8, 0, text, -1, ws, len);
                GlobalUnlock(hMem); SetClipboardData(CF_UNICODETEXT, hMem); } }
    }
    CloseClipboard();
}

__declspec(dllexport) int bridge_clipboard_get_text(char* buffer, int bs) {
    if (!buffer || bs <= 0) return 0; buffer[0] = '\0';
    if (!OpenClipboard(NULL)) return 0; int r = 0;
    HGLOBAL hMem = GetClipboardData(CF_UNICODETEXT);
    if (hMem) { wchar_t* ws = (wchar_t*)GlobalLock(hMem);
        if (ws) { r = WideCharToMultiByte(CP_UTF8, 0, ws, -1, buffer, bs, NULL, NULL);
            GlobalUnlock(hMem); } }
    CloseClipboard(); return r;
}

__declspec(dllexport) bool bridge_clipboard_has_text() {
    if (!OpenClipboard(NULL)) return false;
    bool has = IsClipboardFormatAvailable(CF_UNICODETEXT);
    CloseClipboard(); return has;
}
