package cjform

public struct CheckBoxStyle {
    public let boxColor: Color
    public let checkedBoxColor: Color
    public let borderColor: Color
    public let checkMarkColor: Color
    public let textColor: Color
    public let hoverBoxColor: Color
    public let cornerRadius: Float32
    public let isThemeBased: Bool

    public init() {
        this.boxColor = Color.WHITE
        this.checkedBoxColor = Color.rgb(70, 130, 180)
        this.borderColor = Color.rgb(180, 180, 180)
        this.checkMarkColor = Color.WHITE
        this.textColor = Color.rgb(30, 30, 30)
        this.hoverBoxColor = Color.rgb(240, 248, 255)
        this.cornerRadius = 3.0
        this.isThemeBased = false
    }
    
    public init(boxColor: Color, checkedBoxColor: Color, borderColor: Color, checkMarkColor: Color, textColor: Color, hoverBoxColor: Color, cornerRadius: Float32) {
        this.boxColor = boxColor
        this.checkedBoxColor = checkedBoxColor
        this.borderColor = borderColor
        this.checkMarkColor = checkMarkColor
        this.textColor = textColor
        this.hoverBoxColor = hoverBoxColor
        this.cornerRadius = cornerRadius
        this.isThemeBased = false
    }
    
    public init(isThemeBased: Bool) {
        this.boxColor = Color.WHITE
        this.checkedBoxColor = Color.WHITE
        this.borderColor = Color.WHITE
        this.checkMarkColor = Color.WHITE
        this.textColor = Color.WHITE
        this.hoverBoxColor = Color.WHITE
        this.cornerRadius = 3.0
        this.isThemeBased = isThemeBased
    }

    public static func default(): CheckBoxStyle {
        CheckBoxStyle()
    }
    
    public static func fromTheme(): CheckBoxStyle {
        CheckBoxStyle(true)
    }
    public func updateAnimation(tickCount: Int64): Bool { false }
}

public class CheckBox <: Widget {
    private var text: String
    private var position: Position
    private var fontFamily: String
    private var fontSize: Float32
    private var sizeScale: SizeScale
    private var style: CheckBoxStyle
    private var isChecked: Bool
    private var isHovered: Bool
    private var onCheckedChanged: Option<(Bool) -> Unit>
    private var onClickCallback: Option<() -> Unit>
    private var layoutFrame: Option<LayoutFrame>
    private var measuredTextWidth: Float32

    public init(text: String, position: Position, fontFamily: String, fontSize: Float32, sizeScale: SizeScale, style: CheckBoxStyle, checked: Bool) {
        this.text = text
        this.position = position
        this.fontFamily = fontFamily
        this.fontSize = fontSize
        this.sizeScale = sizeScale
        this.style = style
        this.isChecked = checked
        this.isHovered = false
        this.onCheckedChanged = None<(Bool) -> Unit>
        this.onClickCallback = None<() -> Unit>
        this.layoutFrame = None
        this.measuredTextWidth = 0.0
    }

    public static func styled(styleName: String, text: String, position: Position,
        style: CheckBoxStyle, checked: Bool): CheckBox {
        let props = StyleSheet.getDefault().resolve(styleName)
        let ff = match (props.fontFamily) { case Some(f) => f; case None => "Microsoft YaHei" }
        let fs = match (props.fontSize) { case Some(s) => s; case None => Float32(14.0) }
        let sc = match (props.sizeScale) { case Some(s) => s; case None => SizeScale.scalable() }
        CheckBox(text, position, ff, fs, sc, style, checked)
    }

    public func onClick(cb: () -> Unit): CheckBox {
        this.onClickCallback = Some(cb)
        this
    }
    public func onToggle(cb: (Bool) -> Unit): CheckBox {
        this.onCheckedChanged = Some(cb)
        this
    }
    public func setOnCheckedChanged(callback: (Bool) -> Unit): Unit {
        this.onCheckedChanged = Some<(Bool) -> Unit>(callback)
    }

    public func isChecked_(): Bool {
        isChecked
    }

    public func setChecked(checked: Bool): Unit {
        this.isChecked = checked
    }

    public func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        var boxLeft: Float32 = 0.0
        var boxTop: Float32 = 0.0
        var boxSize: Float32 = 0.0
        var actualFontSize: Float32 = 0.0
        var textX: Float32 = 0.0
        var textY: Float32 = 0.0

        match (layoutFrame) {
            case Some(frame) =>
                boxSize = fontSize * 1.2
                boxLeft = frame.x
                boxTop = frame.y + (frame.height - boxSize) / 2.0
                textX = boxLeft + boxSize + 8.0
                textY = frame.y
                actualFontSize = fontSize
            case None =>
                let actualX = position.resolveX(initialWidth, currentWidth)
                let actualY = position.resolveY(initialHeight, currentHeight)
                actualFontSize = sizeScale.resolve(initialWidth, currentWidth, fontSize)
                boxSize = actualFontSize * 1.2
                boxLeft = actualX
                boxTop = actualY + (actualFontSize - boxSize) / 2.0
                textX = actualX + boxSize + 8.0
                textY = actualY
        }

        var actualRadius: Float32 = 0.0
        match (layoutFrame) {
            case Some(_) => actualRadius = style.cornerRadius
            case None => actualRadius = sizeScale.resolve(initialWidth, currentWidth, style.cornerRadius)
        }

        let (bgColor, borderColor, checkMarkColor, textColor) = getThemeColors()

        measuredTextWidth = canvas.measureTextWidth(text, fontFamily, actualFontSize)

        canvas.fillRoundedRect(boxLeft, boxTop, boxSize, boxSize, actualRadius, bgColor)
        canvas.drawRoundedRect(boxLeft, boxTop, boxSize, boxSize, actualRadius, 1.0, borderColor)

        if (isChecked) {
            drawCheckMark(canvas, boxLeft, boxTop, boxSize, actualFontSize, checkMarkColor)
        }

        canvas.drawText(textX, textY, text, fontFamily, actualFontSize, textColor)
    }
    
    private func getThemeColors(): (Color, Color, Color, Color) {
        if (style.isThemeBased) {
            let c = Theme.colors()
            let bgColor = if (isChecked) {
                c.accent
            } else if (isHovered) {
                c.bgSecondary
            } else {
                c.inputBg
            }
            return (bgColor, c.inputBorder, c.buttonText, c.textPrimary)
        }
        
        let bgColor = if (isChecked) {
            style.checkedBoxColor
        } else if (isHovered) {
            style.hoverBoxColor
        } else {
            style.boxColor
        }
        return (bgColor, style.borderColor, style.checkMarkColor, style.textColor)
    }

    private func drawCheckMark(canvas: Canvas, boxLeft: Float32, boxTop: Float32, boxSize: Float32, fontSize: Float32, checkMarkColor: Color): Unit {
        let cx = boxLeft + boxSize / 2.0
        let cy = boxTop + boxSize / 2.0
        let size = boxSize * 0.4

        let x1 = cx - size * 0.6
        let y1 = cy
        let x2 = cx - size * 0.1
        let y2 = cy + size * 0.5
        let x3 = cx + size * 0.6
        let y3 = cy - size * 0.4

        canvas.drawLine(x1, y1, x2, y2, 2.0, checkMarkColor)
        canvas.drawLine(x2, y2, x3, y3, 2.0, checkMarkColor)
    }

    public func hitTest(x: Float32, y: Float32, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool {
        match (layoutFrame) {
            case Some(frame) =>
                x >= frame.x && x <= frame.x + frame.width && y >= frame.y && y <= frame.y + frame.height
            case None =>
                let actualX = position.resolveX(initialWidth, currentWidth)
                let actualY = position.resolveY(initialHeight, currentHeight)
                let actualFontSize = sizeScale.resolve(initialWidth, currentWidth, fontSize)
                let boxSize = actualFontSize * 1.2
                let textWidth = if (measuredTextWidth > 0.0) { measuredTextWidth } else { Float32(text.size) * actualFontSize * 0.6 }
                let totalWidth = boxSize + 8.0 + textWidth
                let hitLeft = actualX
                let hitRight = actualX + totalWidth
                let hitTop = actualY + (actualFontSize - boxSize) / 2.0
                let hitBottom = hitTop + boxSize
                x >= hitLeft && x <= hitRight && y >= hitTop && y <= hitBottom
        }
    }

    public func handleEvent(event: Event): Bool {
        match (event.eventType) {
            case EventType.MouseEnter =>
                isHovered = true
                true
            case EventType.MouseLeave =>
                isHovered = false
                true
            case EventType.MouseUp =>
                isChecked = !isChecked
                notifyCheckedChanged()
                match (onClickCallback) {
                    case Some(cb) => cb()
                    case None => ()
                }
                true
            case _ => false
        }
    }

    private func notifyCheckedChanged(): Unit {
        match (onCheckedChanged) {
            case Some(callback) => callback(isChecked)
            case None => ()
        }
    }

    public func contains(x: Float32, y: Float32): Bool {
        true
    }

    public func getPosition(): Position {
        position
    }

    public func setPosition(position: Position): Unit {
        this.position = position
    }

    public func getText(): String {
        text
    }

    public func setText(text: String): Unit {
        this.text = text
    }

    public func getLayoutMinWidth(): Float32 {
        let boxSize = fontSize * 1.2
        let textWidth = if (measuredTextWidth > 0.0) { measuredTextWidth } else { Float32(text.size) * fontSize * 0.6 }
        boxSize + 8.0 + textWidth
    }

    public func getLayoutMinHeight(): Float32 {
        let boxSize = fontSize * 1.2
        if (boxSize > fontSize) { boxSize } else { fontSize }
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
