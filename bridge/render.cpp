#include "bridge_common.h"

static float scale_font_size(HWND hwnd, float font_size) {
    HDC hdc = GetDC(hwnd);
    int dpi = GetDeviceCaps(hdc, LOGPIXELSX);
    ReleaseDC(hwnd, hdc);
    if (dpi <= 0) dpi = 96;
    return font_size * dpi / 96.0f;
}

__declspec(dllexport) void bridge_gdip_push_clip(HWND hwnd, float x, float y, float w, float h) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx) { ctx->hasClipRect = true; ctx->clipX = x; ctx->clipY = y; ctx->clipW = w; ctx->clipH = h; }
}

__declspec(dllexport) void bridge_gdip_pop_clip(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx) ctx->hasClipRect = false;
}

__declspec(dllexport) void bridge_gdip_fill_rect(HWND hwnd, float x, float y, float w, float h,
    unsigned char r, unsigned char g, unsigned char b, unsigned char a) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx && ctx->memDC) {
        Graphics graphics(ctx->memDC); applyClipIfNeeded(&graphics, ctx);
        setupHighQualityGraphics(&graphics);
        SolidBrush br(Color(a, r, g, b));
        graphics.FillRectangle(&br, x, y, w, h);
    }
}

__declspec(dllexport) void bridge_gdip_draw_text(HWND hwnd, float x, float y, const char* text,
    const char* font_family, float font_size,
    unsigned char r, unsigned char g, unsigned char b, unsigned char a) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx && ctx->memDC && text) {
        Graphics graphics(ctx->memDC); applyClipIfNeeded(&graphics, ctx);
        setupHighQualityGraphics(&graphics);
        wchar_t* tw = utf8_to_utf16(text);
        wchar_t* fw = font_family ? utf8_to_utf16(font_family) : NULL;
        if (tw) {
            FontFamily ff(fw ? fw : L"Microsoft YaHei");
            Font f(&ff, scale_font_size(hwnd, font_size), FontStyleRegular, UnitPixel);
            SolidBrush br(Color(a, r, g, b));
            StringFormat fmt(StringFormat::GenericTypographic());
            fmt.SetAlignment(StringAlignmentNear);
            fmt.SetLineAlignment(StringAlignmentNear);
            graphics.DrawString(tw, -1, &f, PointF(x, y), &fmt, &br);
            free(tw); if (fw) free(fw);
        }
    }
}

__declspec(dllexport) void bridge_gdip_draw_shadow(HWND hwnd, float x, float y, float w, float h,
    float radius, float blur_radius, float offset_x, float offset_y,
    unsigned char r, unsigned char g, unsigned char b, unsigned char a) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx && ctx->memDC) {
        Graphics graphics(ctx->memDC); applyClipIfNeeded(&graphics, ctx);
        graphics.SetSmoothingMode(SmoothingModeAntiAlias);
        graphics.SetCompositingQuality(CompositingQualityHighQuality);
        int layers = 5;
        float as = (float)a / (float)(layers * layers);
        for (int i = layers; i > 0; i--) {
            float expand = blur_radius * (float)i / (float)layers;
            float alpha  = as * i;
            SolidBrush br(Color((unsigned char)alpha, r, g, b));
            if (radius > 0.0f) {
                GraphicsPath path;
                float d = radius * 2.0f; if (d > w) d = w; if (d > h) d = h;
                float sx = x + offset_x - expand, sy = y + offset_y - expand;
                float sw = w + expand * 2.0f, sh = h + expand * 2.0f;
                path.AddArc(sx, sy, d, d, 180.0f, 90.0f);
                path.AddArc(sx + sw - d, sy, d, d, 270.0f, 90.0f);
                path.AddArc(sx + sw - d, sy + sh - d, d, d, 0.0f, 90.0f);
                path.AddArc(sx, sy + sh - d, d, d, 90.0f, 90.0f);
                path.CloseFigure();
                graphics.FillPath(&br, &path);
            } else {
                graphics.FillRectangle(&br, x + offset_x - expand, y + offset_y - expand,
                    w + expand * 2.0f, h + expand * 2.0f);
            }
        }
    }
}

__declspec(dllexport) void bridge_gdip_measure_text(HWND hwnd, const char* text,
    const char* font_family, float font_size,
    float* out_width, float* out_height) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx && ctx->memDC && text) {
        Graphics graphics(ctx->memDC);
        graphics.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
        wchar_t* tw = utf8_to_utf16(text);
        if (tw) {
            wchar_t* fw = font_family ? utf8_to_utf16(font_family) : NULL;
            FontFamily ff(fw ? fw : L"Microsoft YaHei");
            Font f(&ff, scale_font_size(hwnd, font_size), FontStyleRegular, UnitPixel);
            StringFormat fmt(StringFormat::GenericTypographic());
            RectF br; graphics.MeasureString(tw, -1, &f, PointF(0, 0), &fmt, &br);
            *out_width = br.Width; *out_height = br.Height;
            if (fw) free(fw); free(tw);
        }
    } else { *out_width = 0; *out_height = 0; }
}

__declspec(dllexport) void bridge_gdip_clear(HWND hwnd,
    unsigned char r, unsigned char g, unsigned char b, unsigned char a) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx && ctx->memDC) { Graphics graphics(ctx->memDC); graphics.Clear(Color(a, r, g, b)); }
}

__declspec(dllexport) void bridge_gdip_fill_rounded_rect(HWND hwnd, float x, float y, float w, float h,
    float radius, unsigned char r, unsigned char g, unsigned char b, unsigned char a) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx && ctx->memDC) {
        Graphics graphics(ctx->memDC); applyClipIfNeeded(&graphics, ctx);
        setupHighQualityGraphics(&graphics);
        if (radius > 0.0f) {
            GraphicsPath path; float d = radius * 2.0f;
            path.AddArc(x, y, d, d, 180.0f, 90.0f);
            path.AddArc(x + w - d, y, d, d, 270.0f, 90.0f);
            path.AddArc(x + w - d, y + h - d, d, d, 0.0f, 90.0f);
            path.AddArc(x, y + h - d, d, d, 90.0f, 90.0f);
            path.CloseFigure();
            SolidBrush br(Color(a, r, g, b)); graphics.FillPath(&br, &path);
        } else {
            SolidBrush br(Color(a, r, g, b)); graphics.FillRectangle(&br, x, y, w, h);
        }
    }
}

__declspec(dllexport) void bridge_gdip_draw_rounded_rect(HWND hwnd, float x, float y, float w, float h,
    float radius, float border_width, unsigned char r, unsigned char g, unsigned char b, unsigned char a) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx && ctx->memDC) {
        Graphics graphics(ctx->memDC); applyClipIfNeeded(&graphics, ctx);
        setupHighQualityGraphics(&graphics);
        Pen pen(Color(a, r, g, b), border_width); pen.SetAlignment(PenAlignmentInset);
        if (radius > 0.0f) {
            GraphicsPath path; float d = radius * 2.0f;
            if (d > w) d = w; if (d > h) d = h;
            path.AddArc(x, y, d, d, 180.0f, 90.0f);
            path.AddArc(x + w - d, y, d, d, 270.0f, 90.0f);
            path.AddArc(x + w - d, y + h - d, d, d, 0.0f, 90.0f);
            path.AddArc(x, y + h - d, d, d, 90.0f, 90.0f);
            path.CloseFigure();
            graphics.DrawPath(&pen, &path);
        } else {
            graphics.DrawRectangle(&pen, x, y, w, h);
        }
    }
}

__declspec(dllexport) void bridge_gdip_draw_text_aligned(HWND hwnd, float x, float y, float w, float h,
    const char* text, const char* font_family, float font_size, int alignment,
    unsigned char r, unsigned char g, unsigned char b, unsigned char a) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx && ctx->memDC && text) {
        Graphics graphics(ctx->memDC); applyClipIfNeeded(&graphics, ctx);
        setupHighQualityGraphics(&graphics);
        wchar_t* tw = utf8_to_utf16(text);
        wchar_t* fw = font_family ? utf8_to_utf16(font_family) : NULL;
        if (tw) {
            FontFamily ff(fw ? fw : L"Microsoft YaHei");
            Font f(&ff, scale_font_size(hwnd, font_size), FontStyleRegular, UnitPixel);
            SolidBrush br(Color(a, r, g, b));
            StringFormat fmt(StringFormat::GenericTypographic());
            if (alignment == 0) fmt.SetAlignment(StringAlignmentNear);
            else if (alignment == 1) fmt.SetAlignment(StringAlignmentCenter);
            else fmt.SetAlignment(StringAlignmentFar);
            fmt.SetLineAlignment(StringAlignmentCenter);
            RectF lr(x, y, w, h);
            graphics.DrawString(tw, -1, &f, lr, &fmt, &br);
            free(tw); if (fw) free(fw);
        }
    }
}

__declspec(dllexport) bool bridge_window_needs_render(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    return ctx ? ctx->needsRender : false;
}

__declspec(dllexport) void bridge_window_clear_needs_render(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx) ctx->needsRender = false;
}

__declspec(dllexport) void bridge_window_present(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx) { BitBlt(ctx->hdc, 0, 0, ctx->width, ctx->height, ctx->memDC, 0, 0, SRCCOPY);
               InvalidateRect(hwnd, NULL, FALSE); }
}

__declspec(dllexport) int bridge_window_get_width(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); return ctx ? ctx->width : 0;
}

__declspec(dllexport) int bridge_window_get_height(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); return ctx ? ctx->height : 0;
}

__declspec(dllexport) void bridge_gdip_draw_line(HWND hwnd, float x1, float y1, float x2, float y2,
    float line_width, unsigned char r, unsigned char g, unsigned char b, unsigned char a) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx && ctx->memDC) {
        Graphics graphics(ctx->memDC); applyClipIfNeeded(&graphics, ctx);
        setupHighQualityGraphics(&graphics);
        Pen pen(Color(a, r, g, b), line_width); graphics.DrawLine(&pen, x1, y1, x2, y2);
    }
}

__declspec(dllexport) float bridge_gdip_measure_text_range(HWND hwnd, const char* text,
    int char_count, const char* font_family, float font_size) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (!ctx || !ctx->memDC || !text || char_count <= 0) return 0.0f;
    wchar_t* tw = utf8_to_utf16(text);
    if (!tw) return 0.0f;
    int len = (int)wcslen(tw);
    if (char_count > len) char_count = len;

    Graphics graphics(ctx->memDC);
    graphics.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
    wchar_t* fw = font_family ? utf8_to_utf16(font_family) : NULL;
    FontFamily ff(fw ? fw : L"Microsoft YaHei");
    Font f(&ff, scale_font_size(hwnd, font_size), FontStyleRegular, UnitPixel);
    if (fw) free(fw);

    StringFormat fmt(StringFormat::GenericTypographic());
    fmt.SetAlignment(StringAlignmentNear);
    fmt.SetLineAlignment(StringAlignmentNear);
    fmt.SetFormatFlags(fmt.GetFormatFlags() | StringFormatFlagsMeasureTrailingSpaces);
    CharacterRange range(0, char_count);
    fmt.SetMeasurableCharacterRanges(1, &range);

    Region region;
    RectF layoutRect(0.0f, 0.0f, 10000.0f, 10000.0f);
    graphics.MeasureCharacterRanges(tw, len, &f, layoutRect, &fmt, 1, &region);

    RectF bounds;
    region.GetBounds(&bounds, &graphics);
    free(tw);
    return bounds.Width;
}
