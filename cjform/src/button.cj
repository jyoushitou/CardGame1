package cjform

public class Button <: Widget {
    private var text: String
    private var position: Position
    private var width: Float32
    private var height: Float32
    private var fontFamily: String
    private var fontSize: Float32
    private var sizeScale: SizeScale
    private var anchor: Anchor
    private var style: ButtonStyle
    private var isHovered: Bool
    private var isPressed: Bool
    private var _onClick: () -> Unit
    private var layoutFrame: Option<LayoutFrame>
    private var hoverAnim: AnimationState
    private var pressAnim: AnimationState

    public init(text: String, position: Position, width: Float32, height: Float32, fontFamily: String, fontSize: Float32, sizeScale: SizeScale, anchor: Anchor, style: ButtonStyle, onClick: () -> Unit) {
        this.text = text
        this.position = position
        this.width = width
        this.height = height
        this.fontFamily = fontFamily
        this.fontSize = fontSize
        this.sizeScale = sizeScale
        this.anchor = anchor
        this.style = style
        this.isHovered = false
        this.isPressed = false
        this._onClick = onClick
        this.layoutFrame = None
        this.hoverAnim = AnimationState()
        this.pressAnim = AnimationState()
    }

    public static func styled(styleName: String, text: String, position: Position,
        width: Float32, height: Float32, style: ButtonStyle, onClick: () -> Unit): Button {
        let props = StyleSheet.getDefault().resolve(styleName)
        let ff = match (props.fontFamily) { case Some(f) => f; case None => "Microsoft YaHei" }
        let fs = match (props.fontSize) { case Some(s) => s; case None => Float32(14.0) }
        let sc = match (props.sizeScale) { case Some(s) => s; case None => SizeScale.scalable() }
        let an = match (props.anchor) { case Some(a) => a; case None => Anchor.Center }
        Button(text, position, width, height, ff, fs, sc, an, style, onClick)
    }

    public func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        var left: Float32 = 0.0
        var top: Float32 = 0.0
        var actualWidth: Float32 = 0.0
        var actualHeight: Float32 = 0.0
        var actualFontSize: Float32 = 0.0

        match (layoutFrame) {
            case Some(frame) =>
                left = frame.x
                top = frame.y
                actualWidth = frame.width
                actualHeight = frame.height
                actualFontSize = fontSize
            case None =>
                let actualX = position.resolveX(initialWidth, currentWidth)
                let actualY = position.resolveY(initialHeight, currentHeight)
                actualWidth = sizeScale.resolve(initialWidth, currentWidth, width)
                actualHeight = sizeScale.resolve(initialHeight, currentHeight, height)
                actualFontSize = sizeScale.resolve(initialWidth, currentWidth, fontSize)
                left = actualX - actualWidth / 2.0
                top = actualY - actualHeight / 2.0
        }

        var actualRadius: Float32 = 0.0
        match (layoutFrame) {
            case Some(_) => actualRadius = style.cornerRadius
            case None => actualRadius = sizeScale.resolve(initialWidth, currentWidth, style.cornerRadius)
        }

        if (style.shadow.hasShadow) {
            var actualBlurRadius: Float32 = 0.0
            var actualOffsetX: Float32 = 0.0
            var actualOffsetY: Float32 = 0.0
            match (layoutFrame) {
                case Some(_) =>
                    actualBlurRadius = style.shadow.blurRadius
                    actualOffsetX = style.shadow.offsetX
                    actualOffsetY = style.shadow.offsetY
                case None =>
                    actualBlurRadius = sizeScale.resolve(initialWidth, currentWidth, style.shadow.blurRadius)
                    actualOffsetX = sizeScale.resolve(initialWidth, currentWidth, style.shadow.offsetX)
                    actualOffsetY = sizeScale.resolve(initialHeight, currentHeight, style.shadow.offsetY)
            }
            canvas.drawShadow(left, top, actualWidth, actualHeight, actualRadius, actualBlurRadius, actualOffsetX, actualOffsetY, style.shadow.color)
        }

        let backgroundColor = getBackgroundColor()
        canvas.fillRoundedRect(left, top, actualWidth, actualHeight, actualRadius, backgroundColor)

        if (style.hasBorder) {
            let borderColor = getBorderColor()
            var actualBorderWidth: Float32 = 0.0
            match (layoutFrame) {
                case Some(_) => actualBorderWidth = style.borderWidth
                case None => actualBorderWidth = sizeScale.resolve(initialWidth, currentWidth, style.borderWidth)
            }
            canvas.drawRoundedRect(left, top, actualWidth, actualHeight, actualRadius, actualBorderWidth, borderColor)
        }

        let textColor = getTextColor()
        let alignment = getTextAlignment()
        canvas.drawTextAligned(left, top, actualWidth, actualHeight, text, fontFamily, actualFontSize, alignment, textColor)
    }

    private func getBackgroundColor(): Color {
        let ht = hoverAnim.getValue()
        let pt = pressAnim.getValue()

        if (style.isThemeBased) {
            let c = Theme.colors()
            if (style.isOutlined) {
                return lerpColor(
                    lerpColor(c.inputBg, c.bgSecondary, ht),
                    c.bgTertiary, pt)
            } else {
                return lerpColor(
                    lerpColor(c.buttonBg, c.buttonHover, ht),
                    c.buttonPressed, pt)
            }
        }

        return lerpColor(
            lerpColor(style.backgroundColor, style.hoverBackgroundColor, ht),
            style.pressBackgroundColor, pt)
    }

    private func getBorderColor(): Color {
        if (style.isThemeBased) {
            let c = Theme.colors()
            if (style.isOutlined) {
                if (isPressed) {
                    return c.accentPressed
                } else if (isHovered) {
                    return c.accentHover
                } else {
                    return c.accent
                }
            } else {
                return c.border
            }
        }
        
        if (isPressed) {
            return style.pressBorderColor
        } else if (isHovered) {
            return style.hoverBorderColor
        } else {
            return style.borderColor
        }
    }

    private func getTextColor(): Color {
        if (style.isThemeBased) {
            let c = Theme.colors()
            if (style.isOutlined) {
                if (isPressed) {
                    return c.accentPressed
                } else if (isHovered) {
                    return c.accentHover
                } else {
                    return c.accent
                }
            } else {
                return c.buttonText
            }
        }
        
        if (isPressed) {
            return style.pressTextColor
        } else if (isHovered) {
            return style.hoverTextColor
        } else {
            return style.textColor
        }
    }

    private func getTextAlignment(): Int32 {
        match (style.textAlignment) {
            case TextAlignment.Left => 0
            case TextAlignment.Center => 1
            case TextAlignment.Right => 2
        }
    }

    public func hitTest(x: Float32, y: Float32, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool {
        var left: Float32 = 0.0
        var right: Float32 = 0.0
        var top: Float32 = 0.0
        var bottom: Float32 = 0.0
        match (layoutFrame) {
            case Some(frame) =>
                left = frame.x
                right = frame.x + frame.width
                top = frame.y
                bottom = frame.y + frame.height
            case None =>
                let actualX = position.resolveX(initialWidth, currentWidth)
                let actualY = position.resolveY(initialHeight, currentHeight)
                let actualWidth = sizeScale.resolve(initialWidth, currentWidth, width)
                let actualHeight = sizeScale.resolve(initialHeight, currentHeight, height)
                left = actualX - actualWidth / 2.0
                right = actualX + actualWidth / 2.0
                top = actualY - actualHeight / 2.0
                bottom = actualY + actualHeight / 2.0
        }
        x >= left && x <= right && y >= top && y <= bottom
    }

    public func handleEvent(event: Event): Bool {
        match (event.eventType) {
            case EventType.MouseEnter =>
                isHovered = true
                hoverAnim.start(0.0, 1.0, 150, Easing.EaseOut)
                true
            case EventType.MouseLeave =>
                isHovered = false
                isPressed = false
                hoverAnim.start(1.0, 0.0, 120, Easing.EaseOut)
                pressAnim.start(1.0, 0.0, 80, Easing.EaseOut)
                true
            case EventType.MouseDown =>
                isPressed = true
                pressAnim.start(0.0, 1.0, 60, Easing.EaseOut)
                true
            case EventType.MouseUp =>
                if (isPressed) {
                    isPressed = false
                    pressAnim.start(1.0, 0.0, 80, Easing.EaseOut)
                    _onClick()
                }
                true
            case _ => false
        }
    }

    public func contains(x: Float32, y: Float32): Bool {
        true
    }

    public func getText(): String {
        text
    }

    public func onClick(cb: () -> Unit): Button { this._onClick = cb; this }
    public func setText(text: String): Unit {
        this.text = text
    }

    public func getPosition(): Position {
        position
    }

    public func setPosition(position: Position): Unit {
        this.position = position
    }

    public func getStyle(): ButtonStyle {
        style
    }

    public func setStyle(style: ButtonStyle): Unit {
        this.style = style
    }

    public func getLayoutMinWidth(): Float32 {
        Float32(text.size) * fontSize * 0.6 + 24.0
    }

    public func getLayoutMinHeight(): Float32 {
        fontSize + 16.0
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
    public func updateAnimation(tickCount: Int64): Bool {
        hoverAnim.update(tickCount)
        pressAnim.update(tickCount)
        !hoverAnim.isFinished() || !pressAnim.isFinished()
    }

    public func findLeafAt(x: Float32, y: Float32): Widget { this }
}
