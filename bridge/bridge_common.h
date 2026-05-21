#ifndef BRIDGE_COMMON_H
#define BRIDGE_COMMON_H

#include <windows.h>
#include <gdiplus.h>
#include <dwmapi.h>
#include <shobjidl.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>

#pragma comment(lib, "gdiplus.lib")
#pragma comment(lib, "dwmapi.lib")

using namespace Gdiplus;

extern "C" {

typedef struct {
    HWND hwnd;
    HDC  hdc;
    HDC  memDC;
    HBITMAP memBitmap;
    HBITMAP oldBitmap;
    int  width, height;
    void* renderCallback;
    void* renderContext;
    bool needsRender;
    int  mouseX, mouseY, mouseButton, mouseEventType;
    bool hasMouseEvent;
    unsigned int keyCode;
    int  keyEventType;
    bool hasKeyEvent;
    bool ctrlDown, shiftDown, altDown;
    wchar_t keyChar;
    bool hasClipRect;
    float clipX, clipY, clipW, clipH;
    int  mouseWheelDelta;
    bool hasMouseWheelEvent;
    int  mouseWheelX, mouseWheelY;
    int  minWidth, minHeight;
    bool isResizable;
    bool isAlwaysOnTop;
    bool isNoTitleBar;
    bool hasDropEvent;
    wchar_t* dropFileList;
    int  dropFileCount;
} WindowContext;

// --- utility functions (internal linkage) ---
wchar_t* utf8_to_utf16(const char* utf8_str);
char* utf16_to_utf8(const wchar_t* wstr);
void applyClipIfNeeded(Graphics* g, WindowContext* ctx);
void setupHighQualityGraphics(Graphics* graphics);
wchar_t* build_filter(const char* filter);

// --- exported bridge functions ---
__declspec(dllexport) void* bridge_gdip_init();
__declspec(dllexport) void bridge_gdip_cleanup();

__declspec(dllexport) HWND bridge_window_create(const char* title, int width, int height,
    bool resizable, bool alwaysOnTop, bool noTitleBar);
__declspec(dllexport) void bridge_window_set_render_callback(HWND hwnd, void* cb, void* c);
__declspec(dllexport) void bridge_window_show(HWND hwnd);
__declspec(dllexport) void bridge_window_close(HWND hwnd);
__declspec(dllexport) int bridge_run_loop();
__declspec(dllexport) int bridge_process_message();
__declspec(dllexport) void bridge_post_quit();
__declspec(dllexport) long long bridge_get_tick_count();
__declspec(dllexport) void bridge_start_blink_timer(HWND hwnd, int ms);
__declspec(dllexport) void bridge_stop_blink_timer(HWND hwnd);
__declspec(dllexport) void bridge_window_set_dark_mode(HWND hwnd, bool dark);
__declspec(dllexport) void bridge_start_animation_timer(HWND hwnd);
__declspec(dllexport) void bridge_stop_animation_timer(HWND hwnd);
__declspec(dllexport) void bridge_window_set_min_size(HWND hwnd, int minW, int minH);

__declspec(dllexport) void bridge_gdip_push_clip(HWND hwnd, float x, float y, float w, float h);
__declspec(dllexport) void bridge_gdip_pop_clip(HWND hwnd);
__declspec(dllexport) void bridge_gdip_fill_rect(HWND hwnd, float x, float y, float w, float h,
    unsigned char r, unsigned char g, unsigned char b, unsigned char a);
__declspec(dllexport) void bridge_gdip_draw_text(HWND hwnd, float x, float y, const char* text,
    const char* font_family, float font_size,
    unsigned char r, unsigned char g, unsigned char b, unsigned char a);
__declspec(dllexport) void bridge_gdip_draw_shadow(HWND hwnd, float x, float y, float w, float h,
    float radius, float blur_radius, float offset_x, float offset_y,
    unsigned char r, unsigned char g, unsigned char b, unsigned char a);
__declspec(dllexport) void bridge_gdip_measure_text(HWND hwnd, const char* text,
    const char* font_family, float font_size, float* out_width, float* out_height);
__declspec(dllexport) void bridge_gdip_clear(HWND hwnd,
    unsigned char r, unsigned char g, unsigned char b, unsigned char a);
__declspec(dllexport) void bridge_gdip_fill_rounded_rect(HWND hwnd, float x, float y, float w, float h,
    float radius, unsigned char r, unsigned char g, unsigned char b, unsigned char a);
__declspec(dllexport) void bridge_gdip_draw_rounded_rect(HWND hwnd, float x, float y, float w, float h,
    float radius, float border_width, unsigned char r, unsigned char g, unsigned char b, unsigned char a);
__declspec(dllexport) void bridge_gdip_draw_text_aligned(HWND hwnd, float x, float y, float w, float h,
    const char* text, const char* font_family, float font_size, int alignment,
    unsigned char r, unsigned char g, unsigned char b, unsigned char a);
__declspec(dllexport) bool bridge_window_needs_render(HWND hwnd);
__declspec(dllexport) void bridge_window_clear_needs_render(HWND hwnd);
__declspec(dllexport) void bridge_window_present(HWND hwnd);
__declspec(dllexport) int bridge_window_get_width(HWND hwnd);
__declspec(dllexport) int bridge_window_get_height(HWND hwnd);
__declspec(dllexport) void bridge_gdip_draw_line(HWND hwnd, float x1, float y1, float x2, float y2,
    float line_width, unsigned char r, unsigned char g, unsigned char b, unsigned char a);
__declspec(dllexport) float bridge_gdip_measure_text_range(HWND hwnd, const char* text,
    int char_count, const char* font_family, float font_size);

__declspec(dllexport) bool bridge_window_has_mouse_event(HWND hwnd);
__declspec(dllexport) int bridge_window_get_mouse_x(HWND hwnd);
__declspec(dllexport) int bridge_window_get_mouse_y(HWND hwnd);
__declspec(dllexport) int bridge_window_get_mouse_button(HWND hwnd);
__declspec(dllexport) int bridge_window_get_mouse_event_type(HWND hwnd);
__declspec(dllexport) void bridge_window_clear_mouse_event(HWND hwnd);
__declspec(dllexport) bool bridge_window_has_key_event(HWND hwnd);
__declspec(dllexport) unsigned int bridge_window_get_key_code(HWND hwnd);
__declspec(dllexport) int bridge_window_get_key_event_type(HWND hwnd);
__declspec(dllexport) wchar_t bridge_window_get_key_char(HWND hwnd);
__declspec(dllexport) bool bridge_window_get_ctrl_down(HWND hwnd);
__declspec(dllexport) bool bridge_window_get_shift_down(HWND hwnd);
__declspec(dllexport) bool bridge_window_get_alt_down(HWND hwnd);
__declspec(dllexport) void bridge_window_clear_key_event(HWND hwnd);
__declspec(dllexport) bool bridge_window_has_mouse_wheel_event(HWND hwnd);
__declspec(dllexport) int bridge_window_get_mouse_wheel_delta(HWND hwnd);
__declspec(dllexport) int bridge_window_get_mouse_wheel_x(HWND hwnd);
__declspec(dllexport) int bridge_window_get_mouse_wheel_y(HWND hwnd);
__declspec(dllexport) void bridge_window_clear_mouse_wheel_event(HWND hwnd);
__declspec(dllexport) bool bridge_window_has_drop_event(HWND hwnd);
__declspec(dllexport) int bridge_window_get_drop_count(HWND hwnd);
__declspec(dllexport) int bridge_window_get_drop_file(HWND hwnd, int index, char* buffer, int bufferSize);
__declspec(dllexport) void bridge_window_clear_drop_event(HWND hwnd);
__declspec(dllexport) int bridge_window_get_x(HWND hwnd);
__declspec(dllexport) int bridge_window_get_y(HWND hwnd);
__declspec(dllexport) void bridge_window_set_pos(HWND hwnd, int x, int y, int w, int h);

__declspec(dllexport) HWND bridge_edit_create(HWND parent, int x, int y, int w_, int h_,
    const char* placeholder);
__declspec(dllexport) void bridge_edit_destroy(HWND hEdit);
__declspec(dllexport) void bridge_edit_set_text(HWND hEdit, const char* text);
__declspec(dllexport) int bridge_edit_get_text(HWND hEdit, char* buffer, int bs);
__declspec(dllexport) void bridge_edit_set_focus(HWND hEdit);
__declspec(dllexport) void bridge_edit_set_readonly(HWND hEdit, bool ro);
__declspec(dllexport) void bridge_edit_select_all(HWND hEdit);
__declspec(dllexport) void bridge_edit_set_pos(HWND hEdit, int x, int y, int w_, int h_);
__declspec(dllexport) void bridge_edit_show(HWND hEdit, bool show);
__declspec(dllexport) void bridge_edit_set_border_color(HWND hEdit,
    unsigned char r, unsigned char g, unsigned char b);
__declspec(dllexport) void bridge_edit_set_bg_color(HWND hEdit,
    unsigned char r, unsigned char g, unsigned char b);

__declspec(dllexport) void bridge_clipboard_set_text(const char* text);
__declspec(dllexport) int bridge_clipboard_get_text(char* buffer, int bs);
__declspec(dllexport) bool bridge_clipboard_has_text();

__declspec(dllexport) void* bridge_gdip_load_image(const char* filePath);
__declspec(dllexport) void bridge_gdip_get_image_size(void* img, float* out_w, float* out_h);
__declspec(dllexport) void bridge_gdip_draw_image(HWND hwnd, void* img,
    float x, float y, float w, float h);
__declspec(dllexport) void bridge_gdip_free_image(void* img);

__declspec(dllexport) char* bridge_show_open_dialog(HWND hwnd, const char* title,
    const char* filter, bool multiSelect);
__declspec(dllexport) char* bridge_show_save_dialog(HWND hwnd, const char* title,
    const char* filter, const char* defaultName);
__declspec(dllexport) void bridge_free_string(void* str);

__declspec(dllexport) void bridge_config_write_string(const char* section, const char* key, const char* value);
__declspec(dllexport) int bridge_config_read_string(const char* section, const char* key,
    const char* defaultVal, char* buffer, int bufferSize);
__declspec(dllexport) void bridge_config_write_int(const char* section, const char* key, int value);
__declspec(dllexport) int bridge_config_read_int(const char* section, const char* key, int defaultVal);

__declspec(dllexport) bool bridge_is_null_ptr(void* ptr);
__declspec(dllexport) float bridge_get_dpi_scale(HWND hwnd);

}

#endif
