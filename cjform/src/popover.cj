package cjform

import std.collection.*

public struct PopoverStyle {
    public let backgroundColor: Color
    public let borderColor: Color
    public let shadowColor: Color
    public let cornerRadius: Float32
    public let shadowBlur: Float32
    public let borderWidth: Float32
    public let isThemeBased: Bool

    public init() {
        this.backgroundColor = Color.WHITE
        this.borderColor = Color.WHITE
        this.shadowColor = Color.WHITE
        this.cornerRadius = 6.0
        this.shadowBlur = 8.0
        this.borderWidth = 1.0
        this.isThemeBased = false
    }

    public init(backgroundColor: Color, borderColor: Color, shadowColor: Color,
        cornerRadius: Float32, shadowBlur: Float32, borderWidth: Float32) {
        this.backgroundColor = backgroundColor
        this.borderColor = borderColor
        this.shadowColor = shadowColor
        this.cornerRadius = cornerRadius
        this.shadowBlur = shadowBlur
        this.borderWidth = borderWidth
        this.isThemeBased = false
    }

    public init(isThemeBased: Bool) {
        this.backgroundColor = Color.WHITE
        this.borderColor = Color.WHITE
        this.shadowColor = Color.WHITE
        this.cornerRadius = 6.0
        this.shadowBlur = 8.0
        this.borderWidth = 1.0
        this.isThemeBased = isThemeBased
    }

    public static func fromTheme(): PopoverStyle { PopoverStyle(true) }
}

public class Popover <: Widget {
    private var content: Widget
    private var anchorX: Float32
    private var anchorY: Float32
    private var prefWidth: Float32
    private var prefHeight: Float32
    private var style: PopoverStyle
    private var layoutFrame: Option<LayoutFrame>

    public init(content: Widget, anchorX: Float32, anchorY: Float32, width: Float32, height: Float32) {
        this.content = content
        this.anchorX = anchorX
        this.anchorY = anchorY
        this.prefWidth = width
        this.prefHeight = height
        this.style = PopoverStyle.fromTheme()
        this.layoutFrame = None
    }

    public init(content: Widget, anchorX: Float32, anchorY: Float32, width: Float32, height: Float32, style: PopoverStyle) {
        this.content = content
        this.anchorX = anchorX
        this.anchorY = anchorY
        this.prefWidth = width
        this.prefHeight = height
        this.style = style
        this.layoutFrame = None
    }

    public static func styled(styleName: String, content: Widget, anchorX: Float32, anchorY: Float32, width: Float32, height: Float32): Popover {
        Popover(content, anchorX, anchorY, width, height, PopoverStyle.fromTheme())
    }

    private func getBgColor(): Color { if (style.isThemeBased) { Theme.colors().popupBg } else { style.backgroundColor } }
    private func getBorderColor(): Color { if (style.isThemeBased) { Theme.colors().popupBorder } else { style.borderColor } }
    private func getShadowColor(): Color { if (style.isThemeBased) { Theme.colors().shadow } else { style.shadowColor } }
    private func getCornerRadius(): Float32 { if (style.isThemeBased) { 6.0 } else { style.cornerRadius } }
    private func getShadowBlur(): Float32 { if (style.isThemeBased) { 8.0 } else { style.shadowBlur } }
    private func getBorderWidth(): Float32 { if (style.isThemeBased) { 1.0 } else { style.borderWidth } }

    public func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        var popX = anchorX + 4.0
        var popY = anchorY + 4.0
        if (popX + prefWidth > Float32(currentWidth)) { popX = anchorX - prefWidth - 4.0 }
        if (popY + prefHeight > Float32(currentHeight)) { popY = anchorY - prefHeight - 4.0 }
        if (popX < 0.0) { popX = 4.0 }
        if (popY < 0.0) { popY = 4.0 }

        canvas.drawShadow(popX, popY, prefWidth, prefHeight, getCornerRadius(), getShadowBlur(), 0.0, 4.0, getShadowColor())
        canvas.fillRoundedRect(popX, popY, prefWidth, prefHeight, getCornerRadius(), getBgColor())
        canvas.drawRoundedRect(popX, popY, prefWidth, prefHeight, getCornerRadius(), getBorderWidth(), getBorderColor())
        content.setLayoutFrame(LayoutFrame(popX + 4.0, popY + 4.0, prefWidth - 8.0, prefHeight - 8.0))
        content.paint(canvas, initialWidth, initialHeight, currentWidth, currentHeight)
        content.clearLayoutFrame()
    }

    public func hitTest(x: Float32, y: Float32, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool {
        content.hitTest(x, y, initialWidth, initialHeight, currentWidth, currentHeight)
    }

    public func handleEvent(event: Event): Bool {
        match (event.eventType) {
            case EventType.MouseUp | EventType.MouseDown =>
                content.handleEvent(event)
            case _ => false
        }
    }

    public func contains(x: Float32, y: Float32): Bool { true }
    public func updateAnimation(tickCount: Int64): Bool { false }

    public func findLeafAt(x: Float32, y: Float32): Widget {
        if (content.hitTest(x, y, Float32(0.0), Float32(0.0), Float32(0.0), Float32(0.0))) {
            return content.findLeafAt(x, y)
        }
        this
    }

    public func getLayoutMinWidth(): Float32 { prefWidth }
    public func getLayoutMinHeight(): Float32 { prefHeight }
    public func setLayoutFrame(frame: LayoutFrame): Unit { this.layoutFrame = Some(frame) }
    public func clearLayoutFrame(): Unit { this.layoutFrame = None }
    public func getLayoutFrame(): Option<LayoutFrame> { layoutFrame }
}
