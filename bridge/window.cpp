#include "bridge_common.h"

static ULONG_PTR g_gdiplusToken;
static GdiplusStartupInput g_gdiplusInput;

static LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    switch (uMsg) {
        case WM_DESTROY:
            if (ctx) {
                KillTimer(hwnd, 1);
                if (ctx->dropFileList) free(ctx->dropFileList);
                if (ctx->memBitmap) {
                    SelectObject(ctx->memDC, ctx->oldBitmap);
                    DeleteObject(ctx->memBitmap);
                }
                if (ctx->memDC) DeleteDC(ctx->memDC);
                if (ctx->hdc)   ReleaseDC(hwnd, ctx->hdc);
                free(ctx);
            }
            RemovePropW(hwnd, L"CjFormCtx");
            PostQuitMessage(0);
            return 0;
        case WM_CLOSE:
            DestroyWindow(hwnd); return 0;
        case WM_SIZE:
            if (ctx) {
                ctx->width  = LOWORD(lParam);
                ctx->height = HIWORD(lParam);
                if (ctx->memBitmap) {
                    SelectObject(ctx->memDC, ctx->oldBitmap);
                    DeleteObject(ctx->memBitmap);
                }
                ctx->memBitmap = CreateCompatibleBitmap(ctx->hdc, ctx->width, ctx->height);
                ctx->oldBitmap  = (HBITMAP)SelectObject(ctx->memDC, ctx->memBitmap);
                ctx->needsRender = true;
            }
            InvalidateRect(hwnd, NULL, FALSE);
            return 0;
        case WM_PAINT: {
            PAINTSTRUCT ps;
            BeginPaint(hwnd, &ps);
            if (ctx)
                BitBlt(ctx->hdc, 0, 0, ctx->width, ctx->height, ctx->memDC, 0, 0, SRCCOPY);
            EndPaint(hwnd, &ps);
            return 0;
        }
        case WM_ERASEBKGND: return 1;
        case WM_TIMER:
            if (ctx) ctx->needsRender = true; return 0;
        case WM_MOUSEMOVE:
            if (ctx) { ctx->mouseX = LOWORD(lParam); ctx->mouseY = HIWORD(lParam);
                ctx->mouseButton = 0; ctx->mouseEventType = 1; ctx->hasMouseEvent = true; } return 0;
        case WM_LBUTTONDOWN:
            if (ctx) { ctx->mouseX = LOWORD(lParam); ctx->mouseY = HIWORD(lParam);
                ctx->mouseButton = 1; ctx->mouseEventType = 2; ctx->hasMouseEvent = true; } return 0;
        case WM_LBUTTONUP:
            if (ctx) { ctx->mouseX = LOWORD(lParam); ctx->mouseY = HIWORD(lParam);
                ctx->mouseButton = 1; ctx->mouseEventType = 3; ctx->hasMouseEvent = true; } return 0;
        case WM_RBUTTONDOWN:
            if (ctx) { ctx->mouseX = LOWORD(lParam); ctx->mouseY = HIWORD(lParam);
                ctx->mouseButton = 2; ctx->mouseEventType = 2; ctx->hasMouseEvent = true; } return 0;
        case WM_RBUTTONUP:
            if (ctx) { ctx->mouseX = LOWORD(lParam); ctx->mouseY = HIWORD(lParam);
                ctx->mouseButton = 2; ctx->mouseEventType = 3; ctx->hasMouseEvent = true; } return 0;
        case WM_KEYDOWN:
            if (ctx) { ctx->keyCode = (unsigned int)wParam; ctx->keyEventType = 1;
                ctx->ctrlDown = (GetKeyState(VK_CONTROL)&0x8000)!=0;
                ctx->shiftDown = (GetKeyState(VK_SHIFT)&0x8000)!=0;
                ctx->altDown = (GetKeyState(VK_MENU)&0x8000)!=0; ctx->hasKeyEvent = true; } return 0;
        case WM_CHAR:
            if (ctx) { ctx->keyChar = (wchar_t)wParam; ctx->keyEventType = 2;
                ctx->ctrlDown = (GetKeyState(VK_CONTROL)&0x8000)!=0;
                ctx->shiftDown = (GetKeyState(VK_SHIFT)&0x8000)!=0;
                ctx->altDown = (GetKeyState(VK_MENU)&0x8000)!=0; ctx->hasKeyEvent = true; } return 0;
        case WM_MOUSEWHEEL:
            if (ctx) {
                POINT pt = { LOWORD(lParam), HIWORD(lParam) };
                ScreenToClient(hwnd, &pt);
                ctx->mouseWheelX = pt.x;
                ctx->mouseWheelY = pt.y;
                ctx->mouseWheelDelta = GET_WHEEL_DELTA_WPARAM(wParam);
                ctx->hasMouseWheelEvent = true;
            }
            return 0;
        case WM_GETMINMAXINFO:
            if (ctx && (ctx->minWidth > 0 || ctx->minHeight > 0)) {
                MINMAXINFO* mmi = (MINMAXINFO*)lParam;
                if (ctx->minWidth > 0)  mmi->ptMinTrackSize.x = ctx->minWidth;
                if (ctx->minHeight > 0) mmi->ptMinTrackSize.y = ctx->minHeight;
            }
            return 0;
        case WM_DROPFILES:
            if (ctx) {
                HDROP hDrop = (HDROP)wParam;
                ctx->dropFileCount = DragQueryFileW(hDrop, 0xFFFFFFFF, NULL, 0);
                if (ctx->dropFileCount > 0) {
                    size_t totalLen = 0;
                    for (int i = 0; i < ctx->dropFileCount; i++) {
                        totalLen += DragQueryFileW(hDrop, i, NULL, 0) + 1;
                    }
                    ctx->dropFileList = (wchar_t*)malloc((totalLen + 1) * sizeof(wchar_t));
                    if (ctx->dropFileList) {
                        wchar_t* ptr = ctx->dropFileList;
                        for (int i = 0; i < ctx->dropFileCount; i++) {
                            int len = DragQueryFileW(hDrop, i, ptr, totalLen - (ptr - ctx->dropFileList));
                            ptr += len + 1;
                        }
                        *ptr = L'\0';
                    }
                }
                DragFinish(hDrop);
                ctx->hasDropEvent = true;
            }
            return 0;
    }
    return DefWindowProcW(hwnd, uMsg, wParam, lParam);
}

__declspec(dllexport) void* bridge_gdip_init() {
    SetProcessDPIAware();
    GdiplusStartup(&g_gdiplusToken, &g_gdiplusInput, NULL);
    return (void*)g_gdiplusToken;
}

__declspec(dllexport) float bridge_get_dpi_scale(HWND hwnd) {
    HDC hdc = GetDC(hwnd);
    int dpi = GetDeviceCaps(hdc, LOGPIXELSX);
    ReleaseDC(hwnd, hdc);
    return dpi / 96.0f;
}

__declspec(dllexport) void bridge_gdip_cleanup() {
    GdiplusShutdown(g_gdiplusToken);
}

__declspec(dllexport) HWND bridge_window_create(const char* title, int width, int height,
    bool resizable, bool alwaysOnTop, bool noTitleBar) {
    static bool registered = false;
    if (!registered) {
        WNDCLASSEXW wc = {0};
        wc.cbSize = sizeof(WNDCLASSEXW);
        wc.style = CS_HREDRAW | CS_VREDRAW;
        wc.lpfnWndProc = WindowProc;
        wc.hInstance = GetModuleHandleW(NULL);
        wc.hCursor = LoadCursor(NULL, IDC_ARROW);
        wc.hbrBackground = NULL;
        wc.lpszClassName = L"CjFormWindow";
        if (!RegisterClassExW(&wc)) return NULL;
        registered = true;
    }
    wchar_t* tw = utf8_to_utf16(title);
    if (!tw) tw = (wchar_t*)L"CjForm Window";

    DWORD dwStyle = noTitleBar ? (WS_POPUP | WS_BORDER) : WS_OVERLAPPEDWINDOW;
    if (!resizable && !noTitleBar) {
        dwStyle &= ~(WS_THICKFRAME | WS_MAXIMIZEBOX);
    }
    DWORD dwExStyle = WS_EX_ACCEPTFILES;
    if (alwaysOnTop) dwExStyle |= WS_EX_TOPMOST;

    HWND hwnd = CreateWindowExW(dwExStyle, L"CjFormWindow", tw,
        dwStyle, CW_USEDEFAULT, CW_USEDEFAULT,
        width, height, NULL, NULL, GetModuleHandleW(NULL), NULL);
    if (tw != L"CjForm Window") free(tw);
    if (!hwnd) return NULL;
    DragAcceptFiles(hwnd, TRUE);

    WindowContext* ctx = (WindowContext*)calloc(1, sizeof(WindowContext));
    ctx->hwnd = hwnd;
    ctx->hdc  = GetDC(hwnd);
    ctx->memDC = CreateCompatibleDC(ctx->hdc);
    RECT r; GetClientRect(hwnd, &r);
    ctx->width  = r.right - r.left; if (ctx->width <=0) ctx->width=width;
    ctx->height = r.bottom - r.top; if (ctx->height<=0) ctx->height=height;
    ctx->memBitmap = CreateCompatibleBitmap(ctx->hdc, ctx->width, ctx->height);
    ctx->oldBitmap = (HBITMAP)SelectObject(ctx->memDC, ctx->memBitmap);
    ctx->isResizable = resizable;
    ctx->isAlwaysOnTop = alwaysOnTop;
    ctx->isNoTitleBar = noTitleBar;
    SetPropW(hwnd, L"CjFormCtx", (HANDLE)ctx);
    return hwnd;
}

__declspec(dllexport) void bridge_window_set_render_callback(HWND hwnd, void* cb, void* c) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx) { ctx->renderCallback = cb; ctx->renderContext = c; }
}

__declspec(dllexport) void bridge_window_show(HWND hwnd) {
    if (hwnd) { ShowWindow(hwnd, SW_SHOW); UpdateWindow(hwnd); }
}

__declspec(dllexport) void bridge_window_close(HWND hwnd) { if (hwnd) CloseWindow(hwnd); }

__declspec(dllexport) int bridge_run_loop() {
    MSG msg; while (GetMessageW(&msg, NULL, 0, 0)) {
        TranslateMessage(&msg); DispatchMessageW(&msg); }
    return (int)msg.wParam;
}

__declspec(dllexport) int bridge_process_message() {
    MSG msg;
    if (GetMessageW(&msg, NULL, 0, 0)) { TranslateMessage(&msg); DispatchMessageW(&msg); return 1; }
    return 0;
}

__declspec(dllexport) void bridge_post_quit() { PostQuitMessage(0); }

__declspec(dllexport) long long bridge_get_tick_count() { return (long long)GetTickCount64(); }

__declspec(dllexport) void bridge_start_blink_timer(HWND hwnd, int ms) { if (hwnd) SetTimer(hwnd, 1, ms, NULL); }

__declspec(dllexport) void bridge_stop_blink_timer(HWND hwnd) { if (hwnd) KillTimer(hwnd, 1); }

__declspec(dllexport) void bridge_window_set_dark_mode(HWND hwnd, bool dark) {
    BOOL value = dark ? TRUE : FALSE;
    DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &value, sizeof(value));
}

__declspec(dllexport) void bridge_start_animation_timer(HWND hwnd) {
    if (hwnd) SetTimer(hwnd, 2, 16, NULL);
}

__declspec(dllexport) void bridge_stop_animation_timer(HWND hwnd) {
    if (hwnd) KillTimer(hwnd, 2);
}

__declspec(dllexport) void bridge_window_set_min_size(HWND hwnd, int minW, int minH) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx) { ctx->minWidth = minW; ctx->minHeight = minH; }
}
