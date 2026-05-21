package cjform

import std.collection.*

class ToolbarButton {
    public let text: String
    public let action: () -> Unit
    public init(text: String, action: () -> Unit) { this.text = text; this.action = action }
}

public class Toolbar <: Widget {
    private var items: ArrayList<ToolbarButton>
    private var fontFamily: String
    private var fontSize: Float32
    private var padding: Float32
    private var spacing: Float32
    private var btnPadding: Float32
    private var hoveredIndex: Int32
    private var layoutFrame: Option<LayoutFrame>
    public init() {
        this.items = ArrayList<ToolbarButton>()
        this.fontFamily = "Microsoft YaHei"
        this.fontSize = Float32(13.0)
        this.padding = Float32(4.0)
        this.spacing = Float32(2.0)
        this.btnPadding = Float32(10.0)
        this.hoveredIndex = -1
        this.layoutFrame = None
    }

    public func addItem(text: String, action: () -> Unit): Unit {
        items.add(ToolbarButton(text, action))
    }

    public func paint(canvas: Canvas, iw: Float32, ih: Float32, cw: Float32, ch: Float32): Unit {
        let (x, y, w, h) = getFrame()
        let c = Theme.colors()
        canvas.fillRect(x, y, w, h, c.bgSecondary)
        canvas.drawLine(x, y + h - Float32(1.0), x + w, y + h - Float32(1.0), Float32(1.0), c.border)

        var cx = x + padding
        for (i in 0..items.size) {
            let item = items[i]
            let tw = canvas.measureTextWidth(item.text, fontFamily, fontSize)
            let bw = tw + btnPadding * Float32(2.0)
            let btnH = h - padding * Float32(2.0)
            let btnY = y + (h - btnH) / Float32(2.0)

            if (hoveredIndex == Int32(i)) {
                canvas.fillRoundedRect(cx, btnY, bw, btnH, Float32(4.0), c.buttonHover)
            }

            let textX = cx + btnPadding
            let textY = btnY + (btnH - fontSize) / Float32(2.0)
            canvas.drawText(textX, textY, item.text, fontFamily, fontSize, c.textPrimary)
            cx = cx + bw + spacing
        }
    }

    private func getFrame(): (Float32, Float32, Float32, Float32) {
        match (layoutFrame) { case Some(f) => (f.x, f.y, f.width, f.height); case None => (0.0, 0.0, 800.0, 32.0) }
    }

    public func hitTest(x: Float32, y: Float32, iw: Float32, ih: Float32, cw: Float32, ch: Float32): Bool {
        match (layoutFrame) { case Some(f) => x >= f.x && x <= f.x + f.width && y >= f.y && y <= f.y + f.height; case None => false }
    }

    public func handleEvent(event: Event): Bool {
        match (event.eventType) {
            case EventType.MouseMove =>
                match (event.mouseEvent) {
                    case Some(me) =>
                        hoveredIndex = getButtonAt(me.x)
                        true
                    case None => false
                }
            case EventType.MouseLeave =>
                hoveredIndex = -1
                true
            case EventType.MouseUp =>
                match (event.mouseEvent) {
                    case Some(me) =>
                        let idx = getButtonAt(me.x)
                        if (idx >= 0 && idx < Int32(items.size)) {
                            items[Int64(idx)].action()
                        }
                        true
                    case None => false
                }
            case _ => false
        }
    }

    private func getButtonAt(mx: Float32): Int32 {
        let (x, _, _, h) = getFrame()
        var cx = x + padding
        for (i in 0..items.size) {
            let item = items[i]
            let tw = fontSize * Float32(item.text.size) * Float32(0.6)
            let bw = tw + btnPadding * Float32(2.0)
            if (mx >= cx && mx <= cx + bw) {
                return Int32(i)
            }
            cx = cx + bw + spacing
        }
        -1
    }

    public func contains(x: Float32, y: Float32): Bool { true }
    public func getLayoutMinWidth(): Float32 { 200.0 }
    public func getLayoutMinHeight(): Float32 { Float32(32.0) }
    public func setLayoutFrame(frame: LayoutFrame): Unit { this.layoutFrame = Some(frame) }
    public func clearLayoutFrame(): Unit { this.layoutFrame = None }
    public func getLayoutFrame(): Option<LayoutFrame> { layoutFrame }
    public func updateAnimation(tickCount: Int64): Bool { false }
    public func findLeafAt(x: Float32, y: Float32): Widget { this }
}
