package cjform

public class LinkLabel <: Widget {
    private var text: String
    private var position: Position
    private var fontFamily: String
    private var fontSize: Float32
    private var sizeScale: SizeScale
    private var anchor: Anchor
    private var isHovered: Bool
    private var layoutFrame: Option<LayoutFrame>
    private var _onClick: () -> Unit

    public init(text: String, position: Position, fontFamily: String, fontSize: Float32,
        sizeScale: SizeScale, anchor: Anchor, onClick: () -> Unit) {
        this.text = text
        this.position = position
        this.fontFamily = fontFamily
        this.fontSize = fontSize
        this.sizeScale = sizeScale
        this.anchor = anchor
        this.isHovered = false
        this.layoutFrame = None
        this._onClick = onClick
    }

    public static func styled(styleName: String, text: String, position: Position,
        onClick: () -> Unit): LinkLabel {
        let props = StyleSheet.getDefault().resolve(styleName)
        let ff = match (props.fontFamily) { case Some(f) => f; case None => "Microsoft YaHei" }
        let fs = match (props.fontSize) { case Some(s) => s; case None => Float32(14.0) }
        let sc = match (props.sizeScale) { case Some(s) => s; case None => SizeScale.fixed() }
        let an = match (props.anchor) { case Some(a) => a; case None => Anchor.CenterLeft }
        LinkLabel(text, position, ff, fs, sc, an, onClick)
    }

    public func paint(canvas: Canvas, iw: Float32, ih: Float32, cw: Float32, ch: Float32): Unit {
        let c = Theme.colors()
        let color = if (isHovered) { c.accentHover } else { c.accent }
        var textW: Float32 = 0.0

        match (layoutFrame) {
            case Some(frame) =>
                textW = canvas.measureTextWidth(text, fontFamily, fontSize)
                canvas.drawText(frame.x, frame.y, text, fontFamily, fontSize, color)
                let underlineY = frame.y + fontSize + Float32(1.0)
                canvas.drawLine(frame.x, underlineY, frame.x + textW, underlineY, Float32(1.0), color)
            case None =>
                let actualX = position.resolveX(iw, cw)
                let actualY = position.resolveY(ih, ch)
                let actualFontSize = sizeScale.resolve(iw, cw, fontSize)
                textW = canvas.measureTextWidth(text, fontFamily, actualFontSize)
                let drawX = actualX - textW / Float32(2.0)
                let drawY = actualY - actualFontSize / Float32(2.0)
                canvas.drawText(drawX, drawY, text, fontFamily, actualFontSize, color)
                let underlineY = drawY + actualFontSize + Float32(1.0)
                canvas.drawLine(drawX, underlineY, drawX + textW, underlineY, Float32(1.0), color)
        }
    }

    public func hitTest(x: Float32, y: Float32, iw: Float32, ih: Float32, cw: Float32, ch: Float32): Bool {
        match (layoutFrame) {
            case Some(f) => x >= f.x && x <= f.x + f.width && y >= f.y && y <= f.y + f.height
            case None =>
                let actualX = position.resolveX(iw, cw)
                let actualY = position.resolveY(ih, ch)
                let actualFontSize = sizeScale.resolve(iw, cw, fontSize)
                let textW = actualFontSize * Float32(text.size) * Float32(0.6)
                let left = actualX - textW / Float32(2.0)
                let right = actualX + textW / Float32(2.0)
                let top = actualY - actualFontSize / Float32(2.0)
                let bottom = actualY + actualFontSize / Float32(2.0)
                x >= left && x <= right && y >= top && y <= bottom
        }
    }

    public func handleEvent(event: Event): Bool {
        match (event.eventType) {
            case EventType.MouseEnter => isHovered = true; true
            case EventType.MouseLeave => isHovered = false; true
            case EventType.MouseDown => _onClick(); true
            case _ => false
        }
    }

    public func contains(x: Float32, y: Float32): Bool { true }
    public func getLayoutMinWidth(): Float32 { Float32(text.size) * fontSize * Float32(0.6) }
    public func getLayoutMinHeight(): Float32 { fontSize * Float32(1.4) }
    public func setLayoutFrame(frame: LayoutFrame): Unit { this.layoutFrame = Some(frame) }
    public func clearLayoutFrame(): Unit { this.layoutFrame = None }
    public func getLayoutFrame(): Option<LayoutFrame> { layoutFrame }
    public func updateAnimation(tickCount: Int64): Bool { false }
    public func findLeafAt(x: Float32, y: Float32): Widget { this }

    public func onClick(cb: () -> Unit): LinkLabel { this._onClick = cb; this }
    public func setText(t: String): Unit { this.text = t }
    public func getText(): String { text }
}
