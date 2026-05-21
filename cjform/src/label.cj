package cjform

public class Label <: Widget {
    private var text: String
    private var position: Position
    private var color: Color
    private var fontFamily: String
    private var baseFontSize: Float32
    private var sizeScale: SizeScale
    private var anchor: Anchor
    private var layoutFrame: Option<LayoutFrame>
    private var isThemeBased: Bool
    private var isSecondary: Bool

    public init(text: String, position: Position, color: Color, fontFamily: String, fontSize: Float32, sizeScale: SizeScale, anchor: Anchor) {
        this.text = text
        this.position = position
        this.color = color
        this.fontFamily = fontFamily
        this.baseFontSize = fontSize
        this.sizeScale = sizeScale
        this.anchor = anchor
        this.layoutFrame = None
        this.isThemeBased = false
        this.isSecondary = false
    }
    
    public init(text: String, position: Position, fontFamily: String, fontSize: Float32, sizeScale: SizeScale, anchor: Anchor, isSecondary: Bool) {
        this.text = text
        this.position = position
        this.color = Color.WHITE
        this.fontFamily = fontFamily
        this.baseFontSize = fontSize
        this.sizeScale = sizeScale
        this.anchor = anchor
        this.layoutFrame = None
        this.isThemeBased = true
        this.isSecondary = isSecondary
    }

    public static func styled(styleName: String, text: String, position: Position,
        color: Color): Label {
        let props = StyleSheet.getDefault().resolve(styleName)
        let ff = match (props.fontFamily) { case Some(f) => f; case None => "Microsoft YaHei" }
        let fs = match (props.fontSize) { case Some(s) => s; case None => Float32(14.0) }
        let sc = match (props.sizeScale) { case Some(s) => s; case None => SizeScale.fixed() }
        let an = match (props.anchor) { case Some(a) => a; case None => Anchor.CenterLeft }
        Label(text, position, color, ff, fs, sc, an)
    }

    public static func styled(styleName: String, text: String, position: Position,
        isSecondary: Bool): Label {
        let props = StyleSheet.getDefault().resolve(styleName)
        let ff = match (props.fontFamily) { case Some(f) => f; case None => "Microsoft YaHei" }
        let fs = match (props.fontSize) { case Some(s) => s; case None => Float32(14.0) }
        let sc = match (props.sizeScale) { case Some(s) => s; case None => SizeScale.fixed() }
        let an = match (props.anchor) { case Some(a) => a; case None => Anchor.CenterLeft }
        Label(text, position, ff, fs, sc, an, isSecondary)
    }

    public func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        let actualColor = if (isThemeBased) {
            let c = Theme.colors()
            if (isSecondary) { c.textSecondary } else { c.textPrimary }
        } else {
            color
        }
        
        match (layoutFrame) {
            case Some(frame) =>
                let drawX = frame.x
                let drawY = frame.y
                canvas.drawText(drawX, drawY, text, fontFamily, baseFontSize, actualColor)
            case None =>
                let actualX = position.resolveX(initialWidth, currentWidth)
                let actualY = position.resolveY(initialHeight, currentHeight)
                let actualFontSize = sizeScale.resolve(initialWidth, currentWidth, baseFontSize)
                let textWidth = canvas.measureTextWidth(text, fontFamily, actualFontSize)
                let drawX = actualX - textWidth / 2.0
                let drawY = actualY - actualFontSize / 2.0
                canvas.drawText(drawX, drawY, text, fontFamily, actualFontSize, actualColor)
        }
    }
    
    private func adjustX(x: Float32, fontSize: Float32): Float32 {
        match (anchor) {
            case Anchor.Center | Anchor.TopCenter | Anchor.BottomCenter => x
            case Anchor.TopLeft | Anchor.CenterLeft | Anchor.BottomLeft => x
            case Anchor.TopRight | Anchor.CenterRight | Anchor.BottomRight => x
        }
    }

    private func adjustY(y: Float32, fontSize: Float32): Float32 {
        match (anchor) {
            case Anchor.Center | Anchor.CenterLeft | Anchor.CenterRight => y
            case Anchor.TopLeft | Anchor.TopCenter | Anchor.TopRight => y
            case Anchor.BottomLeft | Anchor.BottomCenter | Anchor.BottomRight => y
        }
    }
    
    public func getText(): String {
        text
    }
    
    public func setText(text: String): Unit {
        this.text = text
    }
    
    public func getPosition(): Position {
        position
    }
    
    public func setPosition(position: Position): Unit {
        this.position = position
    }
    
    public func getColor(): Color {
        color
    }
    
    public func setColor(color: Color): Unit {
        this.color = color
    }
    
    public func getFontFamily(): String {
        fontFamily
    }
    
    public func setFontFamily(fontFamily: String): Unit {
        this.fontFamily = fontFamily
    }
    
    public func getFontSize(): Float32 {
        baseFontSize
    }
    
    public func setFontSize(fontSize: Float32): Unit {
        this.baseFontSize = fontSize
    }
    
    public func getSizeScale(): SizeScale {
        sizeScale
    }
    
    public func setSizeScale(sizeScale: SizeScale): Unit {
        this.sizeScale = sizeScale
    }
    
    public func getAnchor(): Anchor {
        anchor
    }
    
    public func setAnchor(anchor: Anchor): Unit {
        this.anchor = anchor
    }
    
    public func hitTest(x: Float32, y: Float32, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool {
        false
    }

    public func handleEvent(event: Event): Bool {
        false
    }

    public func contains(x: Float32, y: Float32): Bool {
        false
    }

    public func getLayoutMinWidth(): Float32 {
        Float32(text.size) * baseFontSize * 0.6
    }

    public func getLayoutMinHeight(): Float32 {
        baseFontSize * 1.2
    }

    public func setLayoutFrame(frame: LayoutFrame): Unit {
        this.layoutFrame = Some(frame)
    }

    public func clearLayoutFrame(): Unit {
        this.layoutFrame = None
    }

    public func getLayoutFrame(): Option<LayoutFrame> {
        layoutFrame
    }
    public func updateAnimation(tickCount: Int64): Bool { false }

    public func findLeafAt(x: Float32, y: Float32): Widget { this }
}
