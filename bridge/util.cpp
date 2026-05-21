#include "bridge_common.h"

wchar_t* utf8_to_utf16(const char* utf8_str) {
    if (!utf8_str) return NULL;
    int len = MultiByteToWideChar(CP_UTF8, 0, utf8_str, -1, NULL, 0);
    if (len == 0) return NULL;
    wchar_t* w = (wchar_t*)malloc(len * sizeof(wchar_t));
    if (!w) return NULL;
    if (MultiByteToWideChar(CP_UTF8, 0, utf8_str, -1, w, len) == 0) {
        free(w); return NULL;
    }
    return w;
}

char* utf16_to_utf8(const wchar_t* wstr) {
    if (!wstr) return NULL;
    int len = WideCharToMultiByte(CP_UTF8, 0, wstr, -1, NULL, 0, NULL, NULL);
    if (len == 0) return NULL;
    char* s = (char*)malloc(len);
    if (!s) return NULL;
    WideCharToMultiByte(CP_UTF8, 0, wstr, -1, s, len, NULL, NULL);
    return s;
}

void applyClipIfNeeded(Graphics* g, WindowContext* ctx) {
    if (ctx && ctx->hasClipRect)
        g->SetClip(RectF(ctx->clipX, ctx->clipY, ctx->clipW, ctx->clipH));
}

void setupHighQualityGraphics(Graphics* graphics) {
    graphics->SetSmoothingMode(SmoothingModeNone);
    graphics->SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
    graphics->SetCompositingQuality(CompositingQualityDefault);
    graphics->SetInterpolationMode(InterpolationModeNearestNeighbor);
}

wchar_t* build_filter(const char* filter) {
    if (!filter) return NULL;
    int len = (int)strlen(filter);
    wchar_t* wf = (wchar_t*)malloc((len + 2) * sizeof(wchar_t));
    if (!wf) return NULL;
    for (int i = 0; i < len; i++) {
        wf[i] = (filter[i] == '|') ? L'\0' : (wchar_t)filter[i];
    }
    wf[len] = L'\0'; wf[len + 1] = L'\0';
    return wf;
}

__declspec(dllexport) bool bridge_is_null_ptr(void* ptr) {
    return ptr == NULL;
}
