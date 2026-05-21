package cjform

import std.collection.*

public class StatusBar <: Widget {
    private var sections: ArrayList<String>
    private var fontFamily: String
    private var fontSize: Float32
    private var padding: Float32
    private var layoutFrame: Option<LayoutFrame>

    public init() {
        this.sections = ArrayList<String>()
        this.sections.add("")
        this.fontFamily = "Microsoft YaHei"
        this.fontSize = Float32(12.0)
        this.padding = Float32(8.0)
        this.layoutFrame = None
    }

    public func setText(text: String): Unit {
        if (sections.size == 0) { sections.add(text) } else { sections[0] = text }
    }

    public func setSections(s: ArrayList<String>): Unit { this.sections = s }

    public func paint(canvas: Canvas, iw: Float32, ih: Float32, cw: Float32, ch: Float32): Unit {
        let (x, y, w, h) = getFrame()
        let c = Theme.colors()
        canvas.fillRect(x, y, w, h, c.bgTertiary)
        canvas.drawLine(x, y, x + w, y, Float32(1.0), c.border)

        let sectionW = w / Float32(sections.size)
        for (i in 0..sections.size) {
            let sx = x + Float32(i) * sectionW + padding
            let sy = y + (h - fontSize) / Float32(2.0)
            if (i > 0) {
                canvas.drawLine(x + Float32(i) * sectionW, y + Float32(4.0),
                    x + Float32(i) * sectionW, y + h - Float32(4.0), Float32(1.0), c.border)
            }
            canvas.drawText(sx, sy, sections[i], fontFamily, fontSize, c.textSecondary)
        }
    }

    private func getFrame(): (Float32, Float32, Float32, Float32) {
        match (layoutFrame) { case Some(f) => (f.x, f.y, f.width, f.height); case None => (0.0, 0.0, 800.0, 24.0) }
    }

    public func hitTest(x: Float32, y: Float32, iw: Float32, ih: Float32, cw: Float32, ch: Float32): Bool {
        match (layoutFrame) { case Some(f) => x >= f.x && x <= f.x + f.width && y >= f.y && y <= f.y + f.height; case None => false }
    }
    public func handleEvent(event: Event): Bool { false }
    public func contains(x: Float32, y: Float32): Bool { true }
    public func getLayoutMinWidth(): Float32 { 200.0 }
    public func getLayoutMinHeight(): Float32 { Float32(24.0) }
    public func setLayoutFrame(frame: LayoutFrame): Unit { this.layoutFrame = Some(frame) }
    public func clearLayoutFrame(): Unit { this.layoutFrame = None }
    public func getLayoutFrame(): Option<LayoutFrame> { layoutFrame }
    public func updateAnimation(tickCount: Int64): Bool { false }
    public func findLeafAt(x: Float32, y: Float32): Widget { this }
}
