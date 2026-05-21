package cjform

foreign func bridge_gdip_init(): CPointer<Byte>

foreign func bridge_gdip_cleanup(): Unit

foreign func bridge_window_create(title: CString, width: Int32, height: Int32, resizable: Bool, alwaysOnTop: Bool, noTitleBar: Bool): CPointer<Byte>

foreign func bridge_window_set_render_callback(hwnd: CPointer<Byte>, callback: CPointer<Byte>, context: CPointer<Byte>): Unit

foreign func bridge_window_show(hwnd: CPointer<Byte>): Unit

foreign func bridge_window_close(hwnd: CPointer<Byte>): Unit

foreign func bridge_run_loop(): Int32

foreign func bridge_process_message(): Int32

foreign func bridge_post_quit(): Unit

foreign func bridge_gdip_fill_rect(hwnd: CPointer<Byte>, x: Float32, y: Float32, w: Float32, h: Float32, r: UInt8, g: UInt8, b: UInt8, a: UInt8): Unit

foreign func bridge_gdip_draw_text(hwnd: CPointer<Byte>, x: Float32, y: Float32, text: CString, font_family: CString, font_size: Float32, r: UInt8, g: UInt8, b: UInt8, a: UInt8): Unit

foreign func bridge_gdip_measure_text(hwnd: CPointer<Byte>, text: CString, font_family: CString, font_size: Float32, out_width: CPointer<Float32>, out_height: CPointer<Float32>): Unit

foreign func bridge_gdip_measure_text_range(hwnd: CPointer<Byte>, text: CString, char_count: Int32, font_family: CString, font_size: Float32): Float32

foreign func bridge_gdip_clear(hwnd: CPointer<Byte>, r: UInt8, g: UInt8, b: UInt8, a: UInt8): Unit

foreign func bridge_gdip_fill_rounded_rect(hwnd: CPointer<Byte>, x: Float32, y: Float32, w: Float32, h: Float32, radius: Float32, r: UInt8, g: UInt8, b: UInt8, a: UInt8): Unit

foreign func bridge_gdip_draw_rounded_rect(hwnd: CPointer<Byte>, x: Float32, y: Float32, w: Float32, h: Float32, radius: Float32, border_width: Float32, r: UInt8, g: UInt8, b: UInt8, a: UInt8): Unit

foreign func bridge_gdip_draw_text_aligned(hwnd: CPointer<Byte>, x: Float32, y: Float32, w: Float32, h: Float32, text: CString, font_family: CString, font_size: Float32, alignment: Int32, r: UInt8, g: UInt8, b: UInt8, a: UInt8): Unit

foreign func bridge_gdip_draw_shadow(hwnd: CPointer<Byte>, x: Float32, y: Float32, w: Float32, h: Float32, radius: Float32, blur_radius: Float32, offset_x: Float32, offset_y: Float32, r: UInt8, g: UInt8, b: UInt8, a: UInt8): Unit

foreign func bridge_window_present(hwnd: CPointer<Byte>): Unit

foreign func bridge_window_needs_render(hwnd: CPointer<Byte>): Bool

foreign func bridge_window_clear_needs_render(hwnd: CPointer<Byte>): Unit

foreign func bridge_window_get_width(hwnd: CPointer<Byte>): Int32

foreign func bridge_window_get_height(hwnd: CPointer<Byte>): Int32

foreign func bridge_window_has_mouse_event(hwnd: CPointer<Byte>): Bool

foreign func bridge_window_get_mouse_x(hwnd: CPointer<Byte>): Int32

foreign func bridge_window_get_mouse_y(hwnd: CPointer<Byte>): Int32

foreign func bridge_window_get_mouse_button(hwnd: CPointer<Byte>): Int32

foreign func bridge_window_get_mouse_event_type(hwnd: CPointer<Byte>): Int32

foreign func bridge_window_clear_mouse_event(hwnd: CPointer<Byte>): Unit

foreign func bridge_window_has_key_event(hwnd: CPointer<Byte>): Bool

foreign func bridge_window_get_key_code(hwnd: CPointer<Byte>): UInt32

foreign func bridge_window_get_key_event_type(hwnd: CPointer<Byte>): Int32

foreign func bridge_window_get_key_char(hwnd: CPointer<Byte>): UInt16

foreign func bridge_window_get_ctrl_down(hwnd: CPointer<Byte>): Bool

foreign func bridge_window_get_shift_down(hwnd: CPointer<Byte>): Bool

foreign func bridge_window_get_alt_down(hwnd: CPointer<Byte>): Bool

foreign func bridge_window_clear_key_event(hwnd: CPointer<Byte>): Unit

foreign func bridge_gdip_draw_line(hwnd: CPointer<Byte>, x1: Float32, y1: Float32, x2: Float32, y2: Float32, line_width: Float32, r: UInt8, g: UInt8, b: UInt8, a: UInt8): Unit

foreign func bridge_edit_create(parent: CPointer<Byte>, x: Int32, y: Int32, width: Int32, height: Int32, placeholder: CString): CPointer<Byte>

foreign func bridge_edit_destroy(hEdit: CPointer<Byte>): Unit

foreign func bridge_edit_set_text(hEdit: CPointer<Byte>, text: CString): Unit

foreign func bridge_edit_get_text(hEdit: CPointer<Byte>, buffer: CPointer<Byte>, bufferSize: Int32): Int32

foreign func bridge_edit_set_focus(hEdit: CPointer<Byte>): Unit

foreign func bridge_edit_set_readonly(hEdit: CPointer<Byte>, readonly: Bool): Unit

foreign func bridge_edit_select_all(hEdit: CPointer<Byte>): Unit

foreign func bridge_edit_set_pos(hEdit: CPointer<Byte>, x: Int32, y: Int32, width: Int32, height: Int32): Unit

foreign func bridge_edit_show(hEdit: CPointer<Byte>, show: Bool): Unit

foreign func bridge_edit_set_border_color(hEdit: CPointer<Byte>, r: UInt8, g: UInt8, b: UInt8): Unit

foreign func bridge_edit_set_bg_color(hEdit: CPointer<Byte>, r: UInt8, g: UInt8, b: UInt8): Unit

foreign func bridge_clipboard_set_text(text: CString): Unit

foreign func bridge_clipboard_get_text(buffer: CPointer<Byte>, bufferSize: Int32): Int32

foreign func bridge_clipboard_has_text(): Bool

foreign func bridge_gdip_push_clip(hwnd: CPointer<Byte>, x: Float32, y: Float32, w: Float32, h: Float32): Unit

foreign func bridge_gdip_pop_clip(hwnd: CPointer<Byte>): Unit

foreign func bridge_get_tick_count(): Int64

foreign func bridge_start_blink_timer(hwnd: CPointer<Byte>, intervalMs: Int32): Unit

foreign func bridge_stop_blink_timer(hwnd: CPointer<Byte>): Unit

foreign func bridge_window_set_dark_mode(hwnd: CPointer<Byte>, dark: Bool): Unit
foreign func bridge_start_animation_timer(hwnd: CPointer<Byte>): Unit
foreign func bridge_stop_animation_timer(hwnd: CPointer<Byte>): Unit
foreign func bridge_window_set_min_size(hwnd: CPointer<Byte>, minW: Int32, minH: Int32): Unit
foreign func bridge_window_has_mouse_wheel_event(hwnd: CPointer<Byte>): Bool
foreign func bridge_window_get_mouse_wheel_delta(hwnd: CPointer<Byte>): Int32
foreign func bridge_window_get_mouse_wheel_x(hwnd: CPointer<Byte>): Int32
foreign func bridge_window_get_mouse_wheel_y(hwnd: CPointer<Byte>): Int32
foreign func bridge_window_clear_mouse_wheel_event(hwnd: CPointer<Byte>): Unit
foreign func bridge_gdip_load_image(filePath: CString): CPointer<Byte>
foreign func bridge_gdip_get_image_size(img: CPointer<Byte>, out_w: CPointer<Float32>, out_h: CPointer<Float32>): Unit
foreign func bridge_gdip_draw_image(hwnd: CPointer<Byte>, img: CPointer<Byte>, x: Float32, y: Float32, w: Float32, h: Float32): Unit
foreign func bridge_gdip_free_image(img: CPointer<Byte>): Unit
foreign func bridge_show_open_dialog(hwnd: CPointer<Byte>, title: CString, filter: CString, multiSelect: Bool): CPointer<Byte>
foreign func bridge_show_save_dialog(hwnd: CPointer<Byte>, title: CString, filter: CString, defaultName: CString): CPointer<Byte>
foreign func bridge_free_string(str: CPointer<Byte>): Unit

foreign func bridge_window_has_drop_event(hwnd: CPointer<Byte>): Bool
foreign func bridge_window_get_drop_count(hwnd: CPointer<Byte>): Int32
foreign func bridge_window_get_drop_file(hwnd: CPointer<Byte>, index: Int32, buffer: CPointer<Byte>, bufferSize: Int32): Int32
foreign func bridge_window_clear_drop_event(hwnd: CPointer<Byte>): Unit

foreign func bridge_window_get_x(hwnd: CPointer<Byte>): Int32
foreign func bridge_window_get_y(hwnd: CPointer<Byte>): Int32
foreign func bridge_window_set_pos(hwnd: CPointer<Byte>, x: Int32, y: Int32, w: Int32, h: Int32): Unit

foreign func bridge_config_write_string(section: CString, key: CString, value: CString): Unit
foreign func bridge_config_read_string(section: CString, key: CString, defaultVal: CString, buffer: CPointer<Byte>, bufferSize: Int32): Int32
foreign func bridge_config_write_int(section: CString, key: CString, value: Int32): Unit
foreign func bridge_config_read_int(section: CString, key: CString, defaultVal: Int32): Int32

foreign func bridge_is_null_ptr(ptr: CPointer<Byte>): Bool
foreign func bridge_get_dpi_scale(hwnd: CPointer<Byte>): Float32
