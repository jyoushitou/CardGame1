#include "bridge_common.h"

__declspec(dllexport) void* bridge_gdip_load_image(const char* filePath) {
    int len = MultiByteToWideChar(CP_UTF8, 0, filePath, -1, NULL, 0);
    if (len == 0) return NULL;
    wchar_t* wpath = (wchar_t*)malloc(len * sizeof(wchar_t));
    MultiByteToWideChar(CP_UTF8, 0, filePath, -1, wpath, len);
    Bitmap* bmp = Bitmap::FromFile(wpath, FALSE);
    free(wpath);
    if (bmp && bmp->GetLastStatus() == Ok) return bmp;
    if (bmp) delete bmp;
    return NULL;
}

__declspec(dllexport) void bridge_gdip_get_image_size(void* img, float* out_w, float* out_h) {
    Bitmap* bmp = (Bitmap*)img;
    if (bmp) { *out_w = (float)bmp->GetWidth(); *out_h = (float)bmp->GetHeight(); }
    else { *out_w = 0; *out_h = 0; }
}

__declspec(dllexport) void bridge_gdip_draw_image(HWND hwnd, void* img,
    float x, float y, float w, float h) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (!ctx || !ctx->memDC || !img) return;
    Bitmap* bmp = (Bitmap*)img;
    Graphics graphics(ctx->memDC);
    applyClipIfNeeded(&graphics, ctx);
    graphics.SetInterpolationMode(InterpolationModeHighQualityBicubic);
    graphics.DrawImage(bmp, RectF(x, y, w, h), 0, 0, (REAL)bmp->GetWidth(), (REAL)bmp->GetHeight(), UnitPixel);
}

__declspec(dllexport) void bridge_gdip_free_image(void* img) {
    if (img) delete (Bitmap*)img;
}
