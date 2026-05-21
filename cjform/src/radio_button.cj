package cjform

import std.collection.*

public class RadioGroup {
    private var buttons: ArrayList<RadioButton>
    private var selectedIndex: Int32
    private var _onSelectionChanged: Option<(Int32) -> Unit>

    public init() {
        this.buttons = ArrayList<RadioButton>()
        this.selectedIndex = -1
        this._onSelectionChanged = None<(Int32) -> Unit>
    }

    public func add(button: RadioButton): Unit {
        button.setGroup(this)
        button.setIndex(Int32(buttons.size))
        buttons.add(button)
        if (selectedIndex < 0) {
            selectedIndex = 0
            button.setSelected(true)
        }
    }

    public func select(index: Int32): Unit {
        if (index >= 0 && index < Int32(buttons.size)) {
            for (i in 0..buttons.size) {
                buttons[i].setSelected(Int32(i) == index)
            }
            selectedIndex = index
            notifySelectionChanged()
        }
    }

    public func getSelectedIndex(): Int32 {
        selectedIndex
    }

    public func onSelectionChanged(cb: (Int32) -> Unit): RadioGroup { this._onSelectionChanged = Some(cb); this }
    public func setOnSelectionChanged(callback: (Int32) -> Unit): Unit {
        this._onSelectionChanged = Some<(Int32) -> Unit>(callback)
    }

    private func notifySelectionChanged(): Unit {
        match (_onSelectionChanged) {
            case Some(callback) => callback(selectedIndex)
            case None => ()
        }
    }
    public func updateAnimation(tickCount: Int64): Bool { false }
}

public struct RadioButtonStyle {
    public let circleColor: Color
    public let selectedCircleColor: Color
    public let borderColor: Color
    public let dotColor: Color
    public let textColor: Color
    public let hoverCircleColor: Color
    public let isThemeBased: Bool

    public init() {
        this.circleColor = Color.WHITE
        this.selectedCircleColor = Color.rgb(70, 130, 180)
        this.borderColor = Color.rgb(180, 180, 180)
        this.dotColor = Color.WHITE
        this.textColor = Color.rgb(30, 30, 30)
        this.hoverCircleColor = Color.rgb(240, 248, 255)
        this.isThemeBased = false
    }
    
    public init(circleColor: Color, selectedCircleColor: Color, borderColor: Color, dotColor: Color, textColor: Color, hoverCircleColor: Color) {
        this.circleColor = circleColor
        this.selectedCircleColor = selectedCircleColor
        this.borderColor = borderColor
        this.dotColor = dotColor
        this.textColor = textColor
        this.hoverCircleColor = hoverCircleColor
        this.isThemeBased = false
    }
    
    public init(isThemeBased: Bool) {
        this.circleColor = Color.WHITE
        this.selectedCircleColor = Color.WHITE
        this.borderColor = Color.WHITE
        this.dotColor = Color.WHITE
        this.textColor = Color.WHITE
        this.hoverCircleColor = Color.WHITE
        this.isThemeBased = isThemeBased
    }

    public static func default(): RadioButtonStyle {
        RadioButtonStyle()
    }
    
    public static func fromTheme(): RadioButtonStyle {
        RadioButtonStyle(true)
    }
    public func updateAnimation(tickCount: Int64): Bool { false }
}

public class RadioButton <: Widget {
    private var text: String
    private var position: Position
    private var fontFamily: String
    private var fontSize: Float32
    private var sizeScale: SizeScale
    private var style: RadioButtonStyle
    private var isSelected: Bool
    private var isHovered: Bool
    private var group: Option<RadioGroup>
    private var index: Int32
    private var layoutFrame: Option<LayoutFrame>
    private var measuredTextWidth: Float32
    private var onClickCallback: Option<() -> Unit>

    public init(text: String, position: Position, fontFamily: String, fontSize: Float32, sizeScale: SizeScale, style: RadioButtonStyle) {
        this.text = text
        this.position = position
        this.fontFamily = fontFamily
        this.fontSize = fontSize
        this.sizeScale = sizeScale
        this.style = style
        this.isSelected = false
        this.isHovered = false
        this.group = None<RadioGroup>
        this.index = -1
        this.layoutFrame = None
        this.measuredTextWidth = 0.0
        this.onClickCallback = None<() -> Unit>
    }

    public func onClick(cb: () -> Unit): RadioButton {
        this.onClickCallback = Some(cb)
        this
    }

    public static func styled(styleName: String, text: String, position: Position,
        style: RadioButtonStyle): RadioButton {
        let props = StyleSheet.getDefault().resolve(styleName)
        let ff = match (props.fontFamily) { case Some(f) => f; case None => "Microsoft YaHei" }
        let fs = match (props.fontSize) { case Some(s) => s; case None => Float32(14.0) }
        let sc = match (props.sizeScale) { case Some(s) => s; case None => SizeScale.scalable() }
        RadioButton(text, position, ff, fs, sc, style)
    }

    public func setGroup(group: RadioGroup): Unit {
        this.group = Some<RadioGroup>(group)
    }

    public func setIndex(index: Int32): Unit {
        this.index = index
    }

    public func setSelected(selected: Bool): Unit {
        this.isSelected = selected
    }

    public func isSelected_(): Bool {
        isSelected
    }

    public func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        var circleLeft: Float32 = 0.0
        var circleTop: Float32 = 0.0
        var circleRadius: Float32 = 0.0
        var actualFontSize: Float32 = 0.0
        var textX: Float32 = 0.0
        var textY: Float32 = 0.0

        match (layoutFrame) {
            case Some(frame) =>
                circleRadius = fontSize * 0.6
                circleLeft = frame.x
                circleTop = frame.y + (frame.height - circleRadius * 2.0) / 2.0
                textX = circleLeft + circleRadius * 2.0 + 8.0
                textY = frame.y
                actualFontSize = fontSize
            case None =>
                let actualX = position.resolveX(initialWidth, currentWidth)
                let actualY = position.resolveY(initialHeight, currentHeight)
                actualFontSize = sizeScale.resolve(initialWidth, currentWidth, fontSize)
                circleRadius = actualFontSize * 0.6
                circleLeft = actualX
                circleTop = actualY + (actualFontSize - circleRadius * 2.0) / 2.0
                textX = actualX + circleRadius * 2.0 + 8.0
                textY = actualY
        }

        let (bgColor, borderColor, dotColor, textColor) = getThemeColors()

        measuredTextWidth = canvas.measureTextWidth(text, fontFamily, actualFontSize)

        canvas.fillRoundedRect(circleLeft, circleTop, circleRadius * 2.0, circleRadius * 2.0, circleRadius, bgColor)
        canvas.drawRoundedRect(circleLeft, circleTop, circleRadius * 2.0, circleRadius * 2.0, circleRadius, 1.0, borderColor)

        if (isSelected) {
            let innerDotRadius = circleRadius * 0.4
            let cx = circleLeft + circleRadius
            let cy = circleTop + circleRadius
            let dotLeft = cx - innerDotRadius
            let dotTop = cy - innerDotRadius
            canvas.fillRoundedRect(dotLeft, dotTop, innerDotRadius * 2.0, innerDotRadius * 2.0, innerDotRadius, dotColor)
        }

        canvas.drawText(textX, textY, text, fontFamily, actualFontSize, textColor)
    }
    
    private func getThemeColors(): (Color, Color, Color, Color) {
        if (style.isThemeBased) {
            let c = Theme.colors()
            let bgColor = if (isSelected) {
                c.accent
            } else if (isHovered) {
                c.bgSecondary
            } else {
                c.inputBg
            }
            return (bgColor, c.inputBorder, c.buttonText, c.textPrimary)
        }
        
        let bgColor = if (isSelected) {
            style.selectedCircleColor
        } else if (isHovered) {
            style.hoverCircleColor
        } else {
            style.circleColor
        }
        return (bgColor, style.borderColor, style.dotColor, style.textColor)
    }

    public func hitTest(x: Float32, y: Float32, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool {
        match (layoutFrame) {
            case Some(frame) =>
                x >= frame.x && x <= frame.x + frame.width && y >= frame.y && y <= frame.y + frame.height
            case None =>
                let actualX = position.resolveX(initialWidth, currentWidth)
                let actualY = position.resolveY(initialHeight, currentHeight)
                let actualFontSize = sizeScale.resolve(initialWidth, currentWidth, fontSize)
                let circleRadius = actualFontSize * 0.6
                let textWidth = if (measuredTextWidth > 0.0) { measuredTextWidth } else { Float32(text.size) * actualFontSize * 0.6 }
                let totalWidth = circleRadius * 2.0 + 8.0 + textWidth
                let hitLeft = actualX
                let hitRight = actualX + totalWidth
                let hitTop = actualY + (actualFontSize - circleRadius * 2.0) / 2.0
                let hitBottom = hitTop + circleRadius * 2.0
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
                if (!isSelected) {
                    match (group) {
                        case Some(g) => g.select(index)
                        case None => isSelected = true
                    }
                }
                match (onClickCallback) {
                    case Some(cb) => cb()
                    case None => ()
                }
                true
            case _ => false
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
        let circleDiameter = fontSize * 1.2
        let textWidth = if (measuredTextWidth > 0.0) { measuredTextWidth } else { Float32(text.size) * fontSize * 0.6 }
        circleDiameter + 8.0 + textWidth
    }

    public func getLayoutMinHeight(): Float32 {
        let circleDiameter = fontSize * 1.2
        if (circleDiameter > fontSize) { circleDiameter } else { fontSize }
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
