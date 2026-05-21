#include "bridge_common.h"

__declspec(dllexport) HWND bridge_edit_create(HWND parent, int x, int y, int w_, int h_,
    const char* placeholder) {
    wchar_t* ph = placeholder ? utf8_to_utf16(placeholder) : NULL;
    HWND hEdit = CreateWindowExW(WS_EX_CLIENTEDGE, L"EDIT", ph ? ph : L"",
        WS_CHILD | WS_VISIBLE | WS_CLIPSIBLINGS | ES_AUTOHSCROLL,
        x, y, w_, h_, parent, NULL, GetModuleHandleW(NULL), NULL);
    if (ph) free(ph);
    if (hEdit) {
        HFONT hFont = CreateFontW(14, 0, 0, 0, FW_NORMAL,
            FALSE, FALSE, FALSE, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS,
            CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH | FF_DONTCARE,
            L"Microsoft YaHei");
        SendMessageW(hEdit, WM_SETFONT, (WPARAM)hFont, TRUE);
    }
    return hEdit;
}

__declspec(dllexport) void bridge_edit_destroy(HWND hEdit) { if (hEdit) DestroyWindow(hEdit); }

__declspec(dllexport) void bridge_edit_set_text(HWND hEdit, const char* text) {
    if (hEdit && text) { wchar_t* w = utf8_to_utf16(text); if (w) { SetWindowTextW(hEdit, w); free(w); } }
}

__declspec(dllexport) int bridge_edit_get_text(HWND hEdit, char* buffer, int bs) {
    if (hEdit && buffer && bs > 0) {
        int len = GetWindowTextLengthW(hEdit);
        if (len == 0) { buffer[0] = '\0'; return 0; }
        wchar_t* wb = (wchar_t*)malloc((len + 1) * sizeof(wchar_t));
        if (wb) { GetWindowTextW(hEdit, wb, len + 1);
            int r = WideCharToMultiByte(CP_UTF8, 0, wb, -1, buffer, bs, NULL, NULL);
            free(wb); return r; }
    }
    buffer[0] = '\0'; return 0;
}

__declspec(dllexport) void bridge_edit_set_focus(HWND hEdit) { if (hEdit) SetFocus(hEdit); }

__declspec(dllexport) void bridge_edit_set_readonly(HWND hEdit, bool ro) {
    if (hEdit) SendMessageW(hEdit, EM_SETREADONLY, ro ? TRUE : FALSE, 0);
}

__declspec(dllexport) void bridge_edit_select_all(HWND hEdit) {
    if (hEdit) SendMessageW(hEdit, EM_SETSEL, 0, -1);
}

__declspec(dllexport) void bridge_edit_set_pos(HWND hEdit, int x, int y, int w_, int h_) {
    if (hEdit) SetWindowPos(hEdit, NULL, x, y, w_, h_, SWP_NOZORDER);
}

__declspec(dllexport) void bridge_edit_show(HWND hEdit, bool show) {
    if (hEdit) ShowWindow(hEdit, show ? SW_SHOW : SW_HIDE);
}

__declspec(dllexport) void bridge_edit_set_border_color(HWND hEdit,
    unsigned char r, unsigned char g, unsigned char b) {
    if (hEdit) {
        SetWindowLongW(hEdit, GWL_EXSTYLE,
            GetWindowLongW(hEdit, GWL_EXSTYLE) & ~WS_EX_CLIENTEDGE);
        SetWindowPos(hEdit, NULL, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_FRAMECHANGED);
    }
}

__declspec(dllexport) void bridge_edit_set_bg_color(HWND hEdit,
    unsigned char r, unsigned char g, unsigned char b) {
    if (hEdit) {
        HBRUSH hBrush = CreateSolidBrush(RGB(r, g, b));
        SetPropW(hEdit, L"BgBrush", hBrush);
        InvalidateRect(hEdit, NULL, TRUE);
    }
}
