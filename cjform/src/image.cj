package cjform

public enum ImageScaleMode {
    | Original
    | Fill
    | Fit
    | Stretch
}

public class Image <: Widget {
    private var filePath: String
    private var scaleMode: ImageScaleMode
    private var layoutFrame: Option<LayoutFrame>
    private var bitmap: Option<CPointer<Byte>>
    private var imgW: Float32
    private var imgH: Float32
    private var loaded: Bool

    public init(filePath: String) {
        this.filePath = filePath
        this.scaleMode = ImageScaleMode.Fit
        this.layoutFrame = None
        this.bitmap = None<CPointer<Byte>>
        this.imgW = 0.0
        this.imgH = 0.0
        this.loaded = false
    }

    public func setScaleMode(mode: ImageScaleMode): Unit { this.scaleMode = mode }

    private func ensureLoaded(): Unit {
        if (loaded) { return }
        loaded = true
        let bmp = ffi_loadImage(filePath)
        bitmap = Some(bmp)
        let (w, h) = ffi_getImageSize(bmp)
        imgW = w
        imgH = h
    }

    public func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        let (x, y, w, h) = getFrame()
        ensureLoaded()
        if (imgW > 0.0 && imgH > 0.0) {
            match (bitmap) {
                case Some(bmp) =>
                    let (dx, dy, dw, dh) = calcDestRect(x, y, w, h)
                    ffi_drawImage(canvas.getHwnd(), bmp, dx, dy, dw, dh)
                case None => ()
            }
        } else {
            let c = Theme.colors()
            canvas.fillRoundedRect(x, y, w, h, Float32(4.0), c.bgTertiary)
            canvas.drawRoundedRect(x, y, w, h, Float32(4.0), Float32(1.0), c.border)
            canvas.drawTextAligned(x, y, w, h, "[No Image]", "Microsoft YaHei", Float32(13.0), 1, c.textSecondary)
        }
    }

    private func calcDestRect(x: Float32, y: Float32, w: Float32, h: Float32): (Float32, Float32, Float32, Float32) {
        if (imgW <= 0.0 || imgH <= 0.0) { return (x, y, w, h) }
        match (scaleMode) {
            case ImageScaleMode.Original => (x, y, imgW, imgH)
            case ImageScaleMode.Fill => (x, y, w, h)
            case ImageScaleMode.Fit =>
                let scale = if (w / imgW < h / imgH) { w / imgW } else { h / imgH }
                let dw = imgW * scale; let dh = imgH * scale
                (x + (w - dw) / Float32(2.0), y + (h - dh) / Float32(2.0), dw, dh)
            case ImageScaleMode.Stretch => (x, y, w, h)
        }
    }

    public func hitTest(x: Float32, y: Float32, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool {
        match (layoutFrame) { case Some(f) => x >= f.x && x <= f.x + f.width && y >= f.y && y <= f.y + f.height; case None => false }
    }

    public func handleEvent(event: Event): Bool { false }
    public func contains(x: Float32, y: Float32): Bool { true }
    public func updateAnimation(tickCount: Int64): Bool { false }
    public func findLeafAt(x: Float32, y: Float32): Widget { this }

    private func getFrame(): (Float32, Float32, Float32, Float32) {
        match (layoutFrame) { case Some(f) => (f.x, f.y, f.width, f.height); case None => (0.0, 0.0, 200.0, 150.0) }
    }

    public func getLayoutMinWidth(): Float32 { 100.0 }
    public func getLayoutMinHeight(): Float32 { 100.0 }
    public func setLayoutFrame(frame: LayoutFrame): Unit { this.layoutFrame = Some(frame) }
    public func clearLayoutFrame(): Unit { this.layoutFrame = None }
    public func getLayoutFrame(): Option<LayoutFrame> { layoutFrame }
}
