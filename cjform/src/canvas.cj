package cjform

public class Canvas {
    private let hwnd: CPointer<Byte>
    private let dpiScale: Float32

    public init(hwnd: CPointer<Byte>) {
        this.hwnd = hwnd
        this.dpiScale = ffi_getDpiScale(hwnd)
    }

    public func getHwnd(): CPointer<Byte> { hwnd }
    public func getDpiScale(): Float32 { dpiScale }
    
    public func clear(color: Color): Unit {
        unsafe {
            bridge_gdip_clear(hwnd, color.r, color.g, color.b, color.a)
        }
    }
    
    public func fillRect(x: Float32, y: Float32, width: Float32, height: Float32, color: Color): Unit {
        unsafe {
            bridge_gdip_fill_rect(hwnd, x, y, width, height, color.r, color.g, color.b, color.a)
        }
    }
    
    public func fillRoundedRect(x: Float32, y: Float32, width: Float32, height: Float32, radius: Float32, color: Color): Unit {
        unsafe {
            bridge_gdip_fill_rounded_rect(hwnd, x, y, width, height, radius, color.r, color.g, color.b, color.a)
        }
    }
    
    public func drawRoundedRect(x: Float32, y: Float32, width: Float32, height: Float32, radius: Float32, borderWidth: Float32, color: Color): Unit {
        unsafe {
            bridge_gdip_draw_rounded_rect(hwnd, x, y, width, height, radius, borderWidth, color.r, color.g, color.b, color.a)
        }
    }
    
    public func drawText(x: Float32, y: Float32, text: String, fontFamily: String, fontSize: Float32, color: Color): Unit {
        unsafe {
            let textCStr = LibC.mallocCString(text)
            let fontCStr = LibC.mallocCString(fontFamily)
            bridge_gdip_draw_text(hwnd, x, y, textCStr, fontCStr, fontSize, color.r, color.g, color.b, color.a)
            LibC.free(textCStr)
            LibC.free(fontCStr)
        }
    }
    
    public func drawTextAligned(x: Float32, y: Float32, width: Float32, height: Float32, text: String, fontFamily: String, fontSize: Float32, alignment: Int32, color: Color): Unit {
        unsafe {
            let textCStr = LibC.mallocCString(text)
            let fontCStr = LibC.mallocCString(fontFamily)
            bridge_gdip_draw_text_aligned(hwnd, x, y, width, height, textCStr, fontCStr, fontSize, alignment, color.r, color.g, color.b, color.a)
            LibC.free(textCStr)
            LibC.free(fontCStr)
        }
    }
    
    public func drawShadow(x: Float32, y: Float32, width: Float32, height: Float32, radius: Float32, blurRadius: Float32, offsetX: Float32, offsetY: Float32, color: Color): Unit {
        unsafe {
            bridge_gdip_draw_shadow(hwnd, x, y, width, height, radius, blurRadius, offsetX, offsetY, color.r, color.g, color.b, color.a)
        }
    }
    
    public func drawLine(x1: Float32, y1: Float32, x2: Float32, y2: Float32, lineWidth: Float32, color: Color): Unit {
        unsafe {
            bridge_gdip_draw_line(hwnd, x1, y1, x2, y2, lineWidth, color.r, color.g, color.b, color.a)
        }
    }

    public func pushClip(x: Float32, y: Float32, width: Float32, height: Float32): Unit {
        unsafe {
            bridge_gdip_push_clip(hwnd, x, y, width, height)
        }
    }

    public func popClip(): Unit {
        unsafe {
            bridge_gdip_pop_clip(hwnd)
        }
    }

    public func measureTextWidth(text: String, fontFamily: String, fontSize: Float32): Float32 {
        if (text.size == 0) { return 0.0 }
        let (w, _) = ffi_measureText(hwnd, text, fontFamily, fontSize)
        w
    }
}
