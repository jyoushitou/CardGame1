package cjform

public struct GroupBoxStyle {
    public let borderColor: Color
    public let titleColor: Color
    public let titleHeight: Float32
    public let borderWidth: Float32
    public let fontFamily: String
    public let fontSize: Float32
    public let isThemeBased: Bool

    public init() {
        this.borderColor = Color.WHITE; this.titleColor = Color.WHITE
        this.titleHeight = 22.0; this.borderWidth = 1.0
        this.fontFamily = "Microsoft YaHei"; this.fontSize = 13.0
        this.isThemeBased = false
    }

    public init(borderColor: Color, titleColor: Color, titleHeight: Float32,
        borderWidth: Float32, fontFamily: String, fontSize: Float32) {
        this.borderColor = borderColor; this.titleColor = titleColor
        this.titleHeight = titleHeight; this.borderWidth = borderWidth
        this.fontFamily = fontFamily; this.fontSize = fontSize
        this.isThemeBased = false
    }

    public init(isThemeBased: Bool) {
        this.borderColor = Color.WHITE; this.titleColor = Color.WHITE
        this.titleHeight = 22.0; this.borderWidth = 1.0
        this.fontFamily = "Microsoft YaHei"; this.fontSize = 13.0
        this.isThemeBased = isThemeBased
    }

    public static func fromTheme(): GroupBoxStyle { GroupBoxStyle(true) }
}

public class GroupBox <: Widget {
    private var style: GroupBoxStyle
    private var title: String
    private var content: Option<Widget>
    private var layoutFrame: Option<LayoutFrame>

    public init(title: String) {
        this.style = GroupBoxStyle.fromTheme()
        this.title = title
        this.content = None<Widget>
        this.layoutFrame = None
    }

    public init(title: String, style: GroupBoxStyle) {
        this.style = style
        this.title = title
        this.content = None<Widget>
        this.layoutFrame = None
    }

    public static func styled(styleName: String, title: String): GroupBox {
        GroupBox(title, GroupBoxStyle.fromTheme())
    }

    public func setContent(widget: Widget): Unit { this.content = Some(widget) }
    public func getContent(): Option<Widget> { content }

    private func getBorderColor(): Color { if (style.isThemeBased) { Theme.colors().border } else { style.borderColor } }
    private func getTitleColor(): Color { if (style.isThemeBased) { Theme.colors().textPrimary } else { style.titleColor } }

    public func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        let (x, y, w, h) = getFrame()
        let titleH = style.titleHeight
        let borderC = getBorderColor()
        let halfTitle: Float32 = titleH / Float32(2.0)
        let titleW = canvas.measureTextWidth(title, style.fontFamily, style.fontSize)
        let lineY = y + halfTitle
        canvas.drawLine(x + Float32(8.0), lineY, x + Float32(12.0), lineY, style.borderWidth, borderC)
        let gapEnd = x + Float32(16.0) + titleW
        canvas.drawLine(gapEnd, lineY, x + w - Float32(8.0), lineY, style.borderWidth, borderC)
        canvas.drawText(x + Float32(14.0), y, title, style.fontFamily, style.fontSize, getTitleColor())
        canvas.drawLine(x + Float32(8.0), lineY, x + Float32(8.0), y + h - Float32(8.0), style.borderWidth, borderC)
        canvas.drawLine(x + w - Float32(8.0), lineY, x + w - Float32(8.0), y + h - Float32(8.0), style.borderWidth, borderC)
        canvas.drawLine(x + Float32(8.0), y + h - Float32(8.0), x + w - Float32(8.0), y + h - Float32(8.0), style.borderWidth, borderC)
        let contentX = x + Float32(12.0)
        let contentY = y + titleH + Float32(4.0)
        let contentW = w - Float32(24.0)
        let contentH = h - titleH - Float32(12.0)
        match (content) {
            case Some(child) =>
                if (contentW > Float32(0.0) && contentH > Float32(0.0)) {
                    child.setLayoutFrame(LayoutFrame(contentX, contentY, contentW, contentH))
                    child.paint(canvas, initialWidth, initialHeight, currentWidth, currentHeight)
                }
            case None => ()
        }
    }

    public func hitTest(x: Float32, y: Float32, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool {
        match (layoutFrame) { case Some(f) => x >= f.x && x <= f.x + f.width && y >= f.y && y <= f.y + f.height; case None => false }
    }

    public func handleEvent(event: Event): Bool {
        match (content) {
            case Some(child) =>
                match (event.eventType) {
                    case EventType.MouseMove | EventType.MouseDown | EventType.MouseUp =>
                        match (event.mouseEvent) {
                            case Some(me) =>
                                if (isInContentArea(me.x, me.y)) {
                                    child.handleEvent(event)
                                } else { false }
                            case None => false
                        }
                    case EventType.MouseWheel =>
                        match (event.mouseWheelEvent) {
                            case Some(we) =>
                                if (isInContentArea(we.x, we.y)) {
                                    child.handleEvent(event)
                                } else { false }
                            case None => false
                        }
                    case _ => child.handleEvent(event)
                }
            case None => false
        }
    }

    private func isInContentArea(x: Float32, y: Float32): Bool {
        match (layoutFrame) {
            case Some(f) =>
                let f4 = Float32(4.0)
                let headerH = Float32(22.0)
                x >= f.x + f4 && x <= f.x + f.width - f4 && y >= f.y + headerH && y <= f.y + f.height - f4
            case None => true
        }
    }

    private func getFrame(): (Float32, Float32, Float32, Float32) {
        match (layoutFrame) { case Some(f) => (f.x, f.y, f.width, f.height); case None => (Float32(0.0), Float32(0.0), Float32(200.0), Float32(100.0)) }
    }

    public func contains(x: Float32, y: Float32): Bool { true }
    public func updateAnimation(tickCount: Int64): Bool {
        match (content) { case Some(c) => c.updateAnimation(tickCount); case None => false }
    }
    public func getLayoutMinWidth(): Float32 { Float32(100.0) }
    public func getLayoutMinHeight(): Float32 { Float32(60.0) }
    public func setLayoutFrame(frame: LayoutFrame): Unit { this.layoutFrame = Some(frame) }
    public func clearLayoutFrame(): Unit { this.layoutFrame = None }
    public func getLayoutFrame(): Option<LayoutFrame> { layoutFrame }

    public func findLeafAt(x: Float32, y: Float32): Widget {
        match (content) {
            case Some(child) =>
                if (child.hitTest(x, y, 0.0, 0.0, 0.0, 0.0)) {
                    child.findLeafAt(x, y)
                } else { this }
            case None => this
        }
    }
}
