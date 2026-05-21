package cjform

public struct SplitPaneStyle {
    public let dividerColor: Color
    public let dividerHoverColor: Color
    public let dividerDragColor: Color
    public let dividerSize: Float32
    public let minPanelSize: Float32
    public let isThemeBased: Bool

    public init() {
        this.dividerColor = Color.WHITE; this.dividerHoverColor = Color.WHITE
        this.dividerDragColor = Color.WHITE
        this.dividerSize = 6.0; this.minPanelSize = 80.0
        this.isThemeBased = false
    }

    public init(dividerColor: Color, dividerHoverColor: Color, dividerDragColor: Color,
        dividerSize: Float32, minPanelSize: Float32) {
        this.dividerColor = dividerColor; this.dividerHoverColor = dividerHoverColor
        this.dividerDragColor = dividerDragColor
        this.dividerSize = dividerSize; this.minPanelSize = minPanelSize
        this.isThemeBased = false
    }

    public init(isThemeBased: Bool) {
        this.dividerColor = Color.WHITE; this.dividerHoverColor = Color.WHITE
        this.dividerDragColor = Color.WHITE
        this.dividerSize = 6.0; this.minPanelSize = 80.0
        this.isThemeBased = isThemeBased
    }

    public static func fromTheme(): SplitPaneStyle { SplitPaneStyle(true) }
}

public class SplitPane <: Widget {
    private var left: Option<Widget>
    private var right: Option<Widget>
    private var isVertical: Bool
    private var splitRatio: Float32
    private var minPanelSize: Float32
    private var dividerSize: Float32
    private var isDragging: Bool
    private var hoverDivider: Bool
    private var layoutFrame: Option<LayoutFrame>
    private var style: SplitPaneStyle

    public init(isVertical: Bool) {
        this.style = SplitPaneStyle.fromTheme()
        this.left = None<Widget>
        this.right = None<Widget>
        this.isVertical = isVertical
        this.splitRatio = 0.5
        this.minPanelSize = style.minPanelSize
        this.dividerSize = style.dividerSize
        this.isDragging = false
        this.hoverDivider = false
        this.layoutFrame = None
    }

    public init(isVertical: Bool, style: SplitPaneStyle) {
        this.style = style
        this.left = None<Widget>
        this.right = None<Widget>
        this.isVertical = isVertical
        this.splitRatio = 0.5
        this.minPanelSize = style.minPanelSize
        this.dividerSize = style.dividerSize
        this.isDragging = false
        this.hoverDivider = false
        this.layoutFrame = None
    }

    public static func styled(styleName: String, isVertical: Bool): SplitPane {
        SplitPane(isVertical, SplitPaneStyle.fromTheme())
    }

    public func setLeft(widget: Widget): Unit { this.left = Some(widget) }
    public func setRight(widget: Widget): Unit { this.right = Some(widget) }
    public func setSplitRatio(ratio: Float32): Unit { this.splitRatio = ratio }

    public func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        let (x, y, w, h) = getFrame()
        if (w <= 0.0 || h <= 0.0) { return }

        let splitPos = getSplitPosition(w, h)
        let halfD = dividerSize / 2.0

        var leftX: Float32 = x
        var leftY: Float32 = y
        var leftW: Float32 = 0.0
        var leftH: Float32 = h
        var rightX: Float32 = 0.0
        var rightY: Float32 = y
        var rightW: Float32 = 0.0
        var rightH: Float32 = h
        var divX: Float32 = 0.0
        var divY: Float32 = 0.0
        var divW: Float32 = 0.0
        var divH: Float32 = 0.0

        if (isVertical) {
            leftW = splitPos - halfD - x
            rightX = splitPos + halfD
            rightW = x + w - rightX
            divX = splitPos - halfD
            divY = y
            divW = dividerSize
            divH = h
        } else {
            leftH = splitPos - halfD - y
            rightY = splitPos + halfD
            rightH = y + h - rightY
            divX = x
            divY = splitPos - halfD
            divW = w
            divH = dividerSize
        }

        let divColor = if (style.isThemeBased) {
            if (isDragging) { Theme.colors().accent } else if (hoverDivider) { Theme.colors().accentHover } else { Theme.colors().border }
        } else {
            if (isDragging) { style.dividerDragColor } else if (hoverDivider) { style.dividerHoverColor } else { style.dividerColor }
        }
        canvas.fillRoundedRect(divX, divY, divW, divH, 2.0, divColor)

        match (left) {
            case Some(lw) =>
                if (leftW > 0.0 && leftH > 0.0) {
                    lw.setLayoutFrame(LayoutFrame(leftX, leftY, leftW, leftH))
                    lw.paint(canvas, initialWidth, initialHeight, currentWidth, currentHeight)
                }
            case None => ()
        }

        match (right) {
            case Some(rw) =>
                if (rightW > 0.0 && rightH > 0.0) {
                    rw.setLayoutFrame(LayoutFrame(rightX, rightY, rightW, rightH))
                    rw.paint(canvas, initialWidth, initialHeight, currentWidth, currentHeight)
                }
            case None => ()
        }
    }

    public func hitTest(x: Float32, y: Float32, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool {
        match (layoutFrame) { case Some(f) => x >= f.x && x <= f.x + f.width && y >= f.y && y <= f.y + f.height; case None => false }
    }

    public func handleEvent(event: Event): Bool {
        match (event.eventType) {
            case EventType.MouseMove =>
                match (event.mouseEvent) {
                    case Some(me) =>
                        if (isDragging) {
                            let (x, y, w, h) = getFrame()
                            if (isVertical) {
                                let relX = me.x - x
                                splitRatio = clampF(relX / w, minPanelSize / w, 1.0 - minPanelSize / w)
                            } else {
                                let relY = me.y - y
                                splitRatio = clampF(relY / h, minPanelSize / h, 1.0 - minPanelSize / h)
                            }
                            return true
                        }
                        let (x, y, w, h) = getFrame()
                        let sp = getSplitPosition(w, h)
                        let halfD = dividerSize / 2.0
                        if (isVertical) {
                            hoverDivider = me.x >= sp - halfD && me.x <= sp + halfD && me.y >= y && me.y <= y + h
                        } else {
                            hoverDivider = me.y >= sp - halfD && me.y <= sp + halfD && me.x >= x && me.x <= x + w
                        }
                        routeToChildAt(event, me.x, me.y)
                        true
                    case None => false
                }
            case EventType.MouseDown =>
                match (event.mouseEvent) {
                    case Some(me) =>
                        let (x, y, w, h) = getFrame()
                        let sp = getSplitPosition(w, h)
                        let halfD = dividerSize / 2.0
                        if (isVertical) {
                            if (me.x >= sp - halfD - 4.0 && me.x <= sp + halfD + 4.0 && me.y >= y && me.y <= y + h) {
                                isDragging = true
                                return true
                            }
                        } else {
                            if (me.y >= sp - halfD - 4.0 && me.y <= sp + halfD + 4.0 && me.x >= x && me.x <= x + w) {
                                isDragging = true
                                return true
                            }
                        }
                        routeToChildAt(event, me.x, me.y)
                        true
                    case None => false
                }
            case EventType.MouseUp =>
                isDragging = false
                routeToChild(event)
                true
            case EventType.MouseWheel =>
                match (event.mouseWheelEvent) {
                    case Some(we) => routeToChildAt(event, we.x, we.y)
                    case None => false
                }
            case _ => routeToChild(event)
        }
    }

    private func routeToChildAt(event: Event, mx: Float32, my: Float32): Bool {
        match (left) {
            case Some(lw) =>
                if (lw.hitTest(mx, my, 0.0, 0.0, 0.0, 0.0)) {
                    return lw.handleEvent(event)
                }
            case None => ()
        }
        match (right) {
            case Some(rw) => rw.handleEvent(event)
            case None => false
        }
    }

    private func routeToChild(event: Event): Bool {
        var handled = false
        match (left) { case Some(lw) => handled = lw.handleEvent(event); case None => () }
        match (right) { case Some(rw) => if (!handled) { handled = rw.handleEvent(event) }; case None => () }
        handled
    }

    private func getSplitPosition(w: Float32, h: Float32): Float32 {
        let total = if (isVertical) { w } else { h }
        total * splitRatio
    }

    private func getFrame(): (Float32, Float32, Float32, Float32) {
        match (layoutFrame) { case Some(f) => (f.x, f.y, f.width, f.height); case None => (0.0, 0.0, 400.0, 300.0) }
    }

    private func clampF(v: Float32, lo: Float32, hi: Float32): Float32 {
        if (v < lo) { lo } else if (v > hi) { hi } else { v }
    }

    public func contains(x: Float32, y: Float32): Bool { true }
    public func updateAnimation(tickCount: Int64): Bool {
        var active = false
        match (left) { case Some(lw) => if (lw.updateAnimation(tickCount)) { active = true }; case None => () }
        match (right) { case Some(rw) => if (rw.updateAnimation(tickCount)) { active = true }; case None => () }
        active
    }

    public func findLeafAt(x: Float32, y: Float32): Widget {
        match (left) {
            case Some(lw) =>
                if (lw.hitTest(x, y, Float32(0.0), Float32(0.0), Float32(0.0), Float32(0.0))) {
                    return lw.findLeafAt(x, y)
                }
            case None => ()
        }
        match (right) {
            case Some(rw) =>
                if (rw.hitTest(x, y, Float32(0.0), Float32(0.0), Float32(0.0), Float32(0.0))) {
                    return rw.findLeafAt(x, y)
                }
            case None => ()
        }
        this
    }

    public func getLayoutMinWidth(): Float32 { 200.0 }
    public func getLayoutMinHeight(): Float32 { 100.0 }
    public func setLayoutFrame(frame: LayoutFrame): Unit { this.layoutFrame = Some(frame) }
    public func clearLayoutFrame(): Unit { this.layoutFrame = None }
    public func getLayoutFrame(): Option<LayoutFrame> { layoutFrame }
}
