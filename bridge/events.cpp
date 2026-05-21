#include "bridge_common.h"

__declspec(dllexport) bool bridge_window_has_mouse_event(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); return ctx ? ctx->hasMouseEvent : false;
}

__declspec(dllexport) int bridge_window_get_mouse_x(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); return ctx ? ctx->mouseX : 0;
}

__declspec(dllexport) int bridge_window_get_mouse_y(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); return ctx ? ctx->mouseY : 0;
}

__declspec(dllexport) int bridge_window_get_mouse_button(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); return ctx ? ctx->mouseButton : 0;
}

__declspec(dllexport) int bridge_window_get_mouse_event_type(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); return ctx ? ctx->mouseEventType : 0;
}

__declspec(dllexport) void bridge_window_clear_mouse_event(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); if (ctx) ctx->hasMouseEvent = false;
}

__declspec(dllexport) bool bridge_window_has_key_event(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); return ctx ? ctx->hasKeyEvent : false;
}

__declspec(dllexport) unsigned int bridge_window_get_key_code(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); return ctx ? ctx->keyCode : 0;
}

__declspec(dllexport) int bridge_window_get_key_event_type(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); return ctx ? ctx->keyEventType : 0;
}

__declspec(dllexport) wchar_t bridge_window_get_key_char(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); return ctx ? ctx->keyChar : 0;
}

__declspec(dllexport) bool bridge_window_get_ctrl_down(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); return ctx ? ctx->ctrlDown : false;
}

__declspec(dllexport) bool bridge_window_get_shift_down(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); return ctx ? ctx->shiftDown : false;
}

__declspec(dllexport) bool bridge_window_get_alt_down(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); return ctx ? ctx->altDown : false;
}

__declspec(dllexport) void bridge_window_clear_key_event(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx) { ctx->hasKeyEvent = false; ctx->keyChar = 0; }
}

__declspec(dllexport) bool bridge_window_has_mouse_wheel_event(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    return ctx ? ctx->hasMouseWheelEvent : false;
}

__declspec(dllexport) int bridge_window_get_mouse_wheel_delta(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    return ctx ? ctx->mouseWheelDelta : 0;
}

__declspec(dllexport) int bridge_window_get_mouse_wheel_x(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    return ctx ? ctx->mouseWheelX : 0;
}

__declspec(dllexport) int bridge_window_get_mouse_wheel_y(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    return ctx ? ctx->mouseWheelY : 0;
}

__declspec(dllexport) void bridge_window_clear_mouse_wheel_event(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx) ctx->hasMouseWheelEvent = false;
}

__declspec(dllexport) bool bridge_window_has_drop_event(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    return ctx ? ctx->hasDropEvent : false;
}

__declspec(dllexport) int bridge_window_get_drop_count(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    return ctx ? ctx->dropFileCount : 0;
}

__declspec(dllexport) int bridge_window_get_drop_file(HWND hwnd, int index, char* buffer, int bufferSize) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (!ctx || !ctx->dropFileList || index < 0 || index >= ctx->dropFileCount || !buffer || bufferSize <= 0) {
        buffer[0] = '\0'; return 0;
    }
    wchar_t* ptr = ctx->dropFileList;
    for (int i = 0; i < index; i++) { ptr += wcslen(ptr) + 1; }
    char* utf8 = utf16_to_utf8(ptr);
    if (utf8) {
        int len = (int)strlen(utf8);
        int copyLen = len < bufferSize - 1 ? len : bufferSize - 1;
        memcpy(buffer, utf8, copyLen); buffer[copyLen] = '\0';
        free(utf8);
        return copyLen;
    }
    buffer[0] = '\0'; return 0;
}

__declspec(dllexport) void bridge_window_clear_drop_event(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx) {
        ctx->hasDropEvent = false;
        if (ctx->dropFileList) { free(ctx->dropFileList); ctx->dropFileList = NULL; }
        ctx->dropFileCount = 0;
    }
}

__declspec(dllexport) int bridge_window_get_x(HWND hwnd) {
    RECT r; if (GetWindowRect(hwnd, &r)) return r.left; return 0;
}

__declspec(dllexport) int bridge_window_get_y(HWND hwnd) {
    RECT r; if (GetWindowRect(hwnd, &r)) return r.top; return 0;
}

__declspec(dllexport) void bridge_window_set_pos(HWND hwnd, int x, int y, int w, int h) {
    if (hwnd) SetWindowPos(hwnd, NULL, x, y, w, h, SWP_NOZORDER);
}
