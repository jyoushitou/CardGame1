package cjform

// ============================================================
// Safe FFI wrappers — all CString allocation/free lives here.
// Widget code calls these instead of unsafe bridge_* directly.
// ============================================================

// --- Config (INI) ---

public func ffi_configWrite(section: String, key: String, value: String): Unit {
    let sc = unsafe { LibC.mallocCString(section) }
    let kc = unsafe { LibC.mallocCString(key) }
    let vc = unsafe { LibC.mallocCString(value) }
    unsafe { bridge_config_write_string(sc, kc, vc) }
    unsafe { LibC.free(sc); LibC.free(kc); LibC.free(vc) }
}

public func ffi_configWriteInt(section: String, key: String, value: Int32): Unit {
    let sc = unsafe { LibC.mallocCString(section) }
    let kc = unsafe { LibC.mallocCString(key) }
    unsafe { bridge_config_write_int(sc, kc, value) }
    unsafe { LibC.free(sc); LibC.free(kc) }
}

public func ffi_configReadInt(section: String, key: String, defaultVal: Int32): Int32 {
    let sc = unsafe { LibC.mallocCString(section) }
    let kc = unsafe { LibC.mallocCString(key) }
    let r = unsafe { bridge_config_read_int(sc, kc, defaultVal) }
    unsafe { LibC.free(sc); LibC.free(kc) }
    r
}

// --- Clipboard ---

public func ffi_clipboardSetText(text: String): Unit {
    let cstr = unsafe { LibC.mallocCString(text) }
    unsafe { bridge_clipboard_set_text(cstr) }
    unsafe { LibC.free(cstr) }
}

public func ffi_clipboardGetText(): String {
    let buffer = unsafe { LibC.malloc<Byte>(count: 4096) }
    let len = unsafe { bridge_clipboard_get_text(buffer, 4096) }
    let result = if (len > 0) { unsafe { CString(buffer) }.toString() } else { "" }
    unsafe { LibC.free(buffer) }
    result
}

// --- Native Edit ---

public func ffi_editCreate(parent: CPointer<Byte>, x: Int32, y: Int32, w: Int32, h: Int32, placeholder: String): CPointer<Byte> {
    let cstr = unsafe { LibC.mallocCString(placeholder) }
    let hwnd = unsafe { bridge_edit_create(parent, x, y, w, h, cstr) }
    unsafe { LibC.free(cstr) }
    if (ffi_isNullPtr(hwnd)) {
        println("[CJForm] Warning: failed to create edit control")
    }
    hwnd
}

public func ffi_editSetText(hEdit: CPointer<Byte>, text: String): Unit {
    let cstr = unsafe { LibC.mallocCString(text) }
    unsafe { bridge_edit_set_text(hEdit, cstr) }
    unsafe { LibC.free(cstr) }
}

public func ffi_editGetText(hEdit: CPointer<Byte>): String {
    let buffer = unsafe { LibC.malloc<Byte>(count: 256) }
    let len = unsafe { bridge_edit_get_text(hEdit, buffer, 256) }
    let result = if (len > 0) { unsafe { CString(buffer) }.toString() } else { "" }
    unsafe { LibC.free(buffer) }
    result
}

// --- Image ---

public func ffi_loadImage(filePath: String): CPointer<Byte> {
    let cstr = unsafe { LibC.mallocCString(filePath) }
    let bmp = unsafe { bridge_gdip_load_image(cstr) }
    unsafe { LibC.free(cstr) }
    if (ffi_isNullPtr(bmp)) {
        println("[CJForm] Warning: failed to load image '${filePath}'")
    }
    bmp
}

public func ffi_getImageSize(img: CPointer<Byte>): (Float32, Float32) {
    let wPtr = unsafe { LibC.malloc<Float32>(count: 1) }
    let hPtr = unsafe { LibC.malloc<Float32>(count: 1) }
    unsafe { bridge_gdip_get_image_size(img, wPtr, hPtr) }
    let w = unsafe { wPtr.read() }
    let h = unsafe { hPtr.read() }
    unsafe { LibC.free(wPtr); LibC.free(hPtr) }
    (w, h)
}

public func ffi_drawImage(hwnd: CPointer<Byte>, img: CPointer<Byte>, x: Float32, y: Float32, w: Float32, h: Float32): Unit {
    unsafe { bridge_gdip_draw_image(hwnd, img, x, y, w, h) }
}

// --- File Dialogs ---

public func ffi_showOpenDialog(hwnd: CPointer<Byte>, title: String, filter: String, multiSelect: Bool): Option<String> {
    let tc = unsafe { LibC.mallocCString(title) }
    let fc = unsafe { LibC.mallocCString(filter) }
    let resultPtr = unsafe { bridge_show_open_dialog(hwnd, tc, fc, multiSelect) }
    unsafe { LibC.free(tc); LibC.free(fc) }
    let path = unsafe { CString(resultPtr) }.toString()
    unsafe { bridge_free_string(resultPtr) }
    if (path.size == 0) { None<String> } else { Some(path) }
}

public func ffi_showSaveDialog(hwnd: CPointer<Byte>, title: String, filter: String, defaultName: String): Option<String> {
    let tc = unsafe { LibC.mallocCString(title) }
    let fc = unsafe { LibC.mallocCString(filter) }
    let nc = unsafe { LibC.mallocCString(defaultName) }
    let resultPtr = unsafe { bridge_show_save_dialog(hwnd, tc, fc, nc) }
    unsafe { LibC.free(tc); LibC.free(fc); LibC.free(nc) }
    let path = unsafe { CString(resultPtr) }.toString()
    unsafe { bridge_free_string(resultPtr) }
    if (path.size == 0) { None<String> } else { Some(path) }
}

// --- Window ---

public func ffi_windowCreate(title: String, width: Int32, height: Int32, resizable: Bool, alwaysOnTop: Bool, noTitleBar: Bool): CPointer<Byte> {
    let tc = unsafe { LibC.mallocCString(title) }
    let hwnd = unsafe { bridge_window_create(tc, width, height, resizable, alwaysOnTop, noTitleBar) }
    unsafe { LibC.free(tc) }
    if (ffi_isNullPtr(hwnd)) {
        println("[CJForm] Error: failed to create window '${title}'")
    }
    hwnd
}

// --- Misc ---

public func ffi_getTickCount(): Int64 {
    unsafe { bridge_get_tick_count() }
}

public func ffi_postQuit(): Unit {
    unsafe { bridge_post_quit() }
}

public func ffi_measureText(hwnd: CPointer<Byte>, text: String, fontFamily: String, fontSize: Float32): (Float32, Float32) {
    let tc = unsafe { LibC.mallocCString(text) }
    let fc = unsafe { LibC.mallocCString(fontFamily) }
    let wPtr = unsafe { LibC.malloc<Float32>(count: 1) }
    let hPtr = unsafe { LibC.malloc<Float32>(count: 1) }
    unsafe { bridge_gdip_measure_text(hwnd, tc, fc, fontSize, wPtr, hPtr) }
    let w = unsafe { wPtr.read() }
    let h = unsafe { hPtr.read() }
    unsafe { LibC.free(tc); LibC.free(fc); LibC.free(wPtr); LibC.free(hPtr) }
    (w, h)
}

public func ffi_measureTextRange(hwnd: CPointer<Byte>, text: String, charCount: Int32, fontFamily: String, fontSize: Float32): Float32 {
    let tc = unsafe { LibC.mallocCString(text) }
    let fc = unsafe { LibC.mallocCString(fontFamily) }
    let w = unsafe { bridge_gdip_measure_text_range(hwnd, tc, charCount, fc, fontSize) }
    unsafe { LibC.free(tc); LibC.free(fc) }
    w
}

// --- Pointer utilities ---

public func ffi_isNullPtr(ptr: CPointer<Byte>): Bool {
    unsafe { bridge_is_null_ptr(ptr) }
}

// --- GDI+ ---

public func ffi_getDpiScale(hwnd: CPointer<Byte>): Float32 {
    let scale = unsafe { bridge_get_dpi_scale(hwnd) }
    if (scale <= 0.0) { 1.0 } else { scale }
}

public func ffi_gdipInit(): Bool {
    let token = unsafe { bridge_gdip_init() }
    let ok = !ffi_isNullPtr(token)
    if (!ok) {
        println("[CJForm] Error: GDI+ initialization failed")
    }
    ok
}
