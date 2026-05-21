package cjform

public struct ScrollAreaStyle {
    public let scrollbarTrackColor: Color
    public let scrollbarThumbColor: Color
    public let scrollbarThumbHoverColor: Color
    public let barThickness: Float32
    public let barMinLength: Float32
    public let isThemeBased: Bool

    public init() {
        this.scrollbarTrackColor = Color.WHITE
        this.scrollbarThumbColor = Color.WHITE
        this.scrollbarThumbHoverColor = Color.WHITE
        this.barThickness = 10.0
        this.barMinLength = 20.0
        this.isThemeBased = false
    }

    public init(scrollbarTrackColor: Color, scrollbarThumbColor: Color, scrollbarThumbHoverColor: Color,
        barThickness: Float32, barMinLength: Float32) {
        this.scrollbarTrackColor = scrollbarTrackColor
        this.scrollbarThumbColor = scrollbarThumbColor
        this.scrollbarThumbHoverColor = scrollbarThumbHoverColor
        this.barThickness = barThickness
        this.barMinLength = barMinLength
        this.isThemeBased = false
    }

    public init(isThemeBased: Bool) {
        this.scrollbarTrackColor = Color.WHITE
        this.scrollbarThumbColor = Color.WHITE
        this.scrollbarThumbHoverColor = Color.WHITE
        this.barThickness = 10.0
        this.barMinLength = 20.0
        this.isThemeBased = isThemeBased
    }

    public static func fromTheme(): ScrollAreaStyle { ScrollAreaStyle(true) }
}

public class ScrollArea <: Widget {
    private var content: Option<Widget>
    private var contentViewW: Float32
    private var contentViewH: Float32
    private var viewportX: Float32
    private var viewportY: Float32
    private var viewportW: Float32
    private var viewportH: Float32
    private var scrollX: Float32
    private var scrollY: Float32
    private var targetScrollX: Float32
    private var targetScrollY: Float32
    private var maxScrollX: Float32
    private var maxScrollY: Float32
    private var scrollAnimX: AnimationState
    private var scrollAnimY: AnimationState
    private var style: ScrollAreaStyle
    private var showBarY: Bool
    private var showBarX: Bool
    private var barOpacity: Float32
    private var barOpacityAnim: AnimationState
    private var lastWheelTime: Int64
    private var draggingBarX: Bool
    private var draggingBarY: Bool
    private var dragStartScrollX: Float32
    private var dragStartScrollY: Float32
    private var dragStartMouseX: Float32
    private var dragStartMouseY: Float32
    private var hoveredBarX: Bool
    private var hoveredBarY: Bool
    private var layoutFrame: Option<LayoutFrame>
    private var wheelScrollSpeed: Float32

    public init() {
        this.content = None<Widget>
        this.contentViewW = 0.0
        this.contentViewH = 0.0
        this.viewportX = 0.0
        this.viewportY = 0.0
        this.viewportW = 0.0
        this.viewportH = 0.0
        this.scrollX = 0.0
        this.scrollY = 0.0
        this.targetScrollX = 0.0
        this.targetScrollY = 0.0
        this.maxScrollX = 0.0
        this.maxScrollY = 0.0
        this.scrollAnimX = AnimationState()
        this.scrollAnimY = AnimationState()
        this.style = ScrollAreaStyle.fromTheme()
        this.showBarY = false
        this.showBarX = false
        this.barOpacity = 0.3
        this.barOpacityAnim = AnimationState()
        this.lastWheelTime = 0
        this.draggingBarX = false
        this.draggingBarY = false
        this.dragStartScrollX = 0.0
        this.dragStartScrollY = 0.0
        this.dragStartMouseX = 0.0
        this.dragStartMouseY = 0.0
        this.hoveredBarX = false
        this.hoveredBarY = false
        this.layoutFrame = None
        this.wheelScrollSpeed = 40.0
    }

    public init(style: ScrollAreaStyle) {
        this.content = None<Widget>
        this.contentViewW = 0.0
        this.contentViewH = 0.0
        this.viewportX = 0.0
        this.viewportY = 0.0
        this.viewportW = 0.0
        this.viewportH = 0.0
        this.scrollX = 0.0
        this.scrollY = 0.0
        this.targetScrollX = 0.0
        this.targetScrollY = 0.0
        this.maxScrollX = 0.0
        this.maxScrollY = 0.0
        this.scrollAnimX = AnimationState()
        this.scrollAnimY = AnimationState()
        this.style = style
        this.showBarY = false
        this.showBarX = false
        this.barOpacity = 0.3
        this.barOpacityAnim = AnimationState()
        this.lastWheelTime = 0
        this.draggingBarX = false
        this.draggingBarY = false
        this.dragStartScrollX = 0.0
        this.dragStartScrollY = 0.0
        this.dragStartMouseX = 0.0
        this.dragStartMouseY = 0.0
        this.hoveredBarX = false
        this.hoveredBarY = false
        this.layoutFrame = None
        this.wheelScrollSpeed = 40.0
    }

    public static func styled(styleName: String): ScrollArea {
        ScrollArea(ScrollAreaStyle.fromTheme())
    }

    public func setContent(widget: Widget): Unit {
        this.content = Some(widget)
        this.scrollX = 0.0
        this.scrollY = 0.0
        this.targetScrollX = 0.0
        this.targetScrollY = 0.0
    }

    public func setWheelScrollSpeed(speed: Float32): Unit {
        this.wheelScrollSpeed = speed
    }

    public func getContent(): Option<Widget> {
        content
    }

    public func findLeafAt(x: Float32, y: Float32): Widget {
        match (content) {
            case Some(child) =>
                let cw = child.getLayoutMinWidth()
                let ch = child.getLayoutMinHeight()
                match (layoutFrame) {
                    case Some(f) => child.setLayoutFrame(LayoutFrame(f.x, f.y, cw, ch))
                    case None => child.setLayoutFrame(LayoutFrame(0.0, 0.0, cw, ch))
                }
                if (child.hitTest(x, y, 0.0, 0.0, 0.0, 0.0)) {
                    child.findLeafAt(x, y)
                } else { this }
            case None => this
        }
    }

    public func scrollTo(x: Float32, y: Float32): Unit {
        targetScrollX = clampF(x, 0.0, maxScrollX)
        targetScrollY = clampF(y, 0.0, maxScrollY)
        scrollAnimX.start(scrollX, targetScrollX, 250, Easing.EaseOut)
        scrollAnimY.start(scrollY, targetScrollY, 250, Easing.EaseOut)
        showBars()
    }

    public func scrollBy(dx: Float32, dy: Float32): Unit {
        let newTx = clampF(targetScrollX + dx, 0.0, maxScrollX)
        let newTy = clampF(targetScrollY + dy, 0.0, maxScrollY)
        if (!scrollAnimX.isFinished()) {
            scrollAnimX.jumpToEnd()
            scrollX = scrollAnimX.getValue()
        }
        if (!scrollAnimY.isFinished()) {
            scrollAnimY.jumpToEnd()
            scrollY = scrollAnimY.getValue()
        }
        targetScrollX = newTx
        targetScrollY = newTy
        if (newTx != scrollX) {
            scrollAnimX.start(scrollX, newTx, 250, Easing.EaseOut)
        }
        if (newTy != scrollY) {
            scrollAnimY.start(scrollY, newTy, 250, Easing.EaseOut)
        }
        showBars()
    }

    public func getScrollX(): Float32 { scrollX }
    public func getScrollY(): Float32 { scrollY }

    private func clampF(v: Float32, lo: Float32, hi: Float32): Float32 {
        if (v < lo) { lo } else if (v > hi) { hi } else { v }
    }

    private func showBars(): Unit {
        barOpacityAnim.start(barOpacity, 1.0, 150, Easing.EaseOut)
        lastWheelTime = unsafe { bridge_get_tick_count() }
    }

    public func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        match (layoutFrame) {
            case Some(f) =>
                viewportX = f.x
                viewportY = f.y
                viewportW = f.width
                viewportH = f.height
            case None =>
                viewportX = 0.0
                viewportY = 0.0
                viewportW = Float32(currentWidth)
                viewportH = Float32(currentHeight)
        }

        match (content) {
            case Some(child) =>
                contentViewW = child.getLayoutMinWidth()
                contentViewH = child.getLayoutMinHeight()
            case None =>
                contentViewW = viewportW
                contentViewH = viewportH
        }

        let prefBarThick = getBarThickness()
        let needBarY = contentViewH > viewportH
        let needBarX = contentViewW > viewportW
        if (needBarX && !needBarY && contentViewH > viewportH - prefBarThick) {
            showBarY = true
        } else {
            showBarY = needBarY
        }
        if (needBarY && !needBarX && contentViewW > viewportW - prefBarThick) {
            showBarX = true
        } else {
            showBarX = needBarX
        }
        if (!needBarY) { showBarY = false }
        if (!needBarX) { showBarX = false }
        let vpW = if (showBarY) { viewportW - prefBarThick } else { viewportW }
        let vpH = if (showBarX) { viewportH - prefBarThick } else { viewportH }
        maxScrollX = if (contentViewW > vpW) { contentViewW - vpW } else { 0.0 }
        maxScrollY = if (contentViewH > vpH) { contentViewH - vpH } else { 0.0 }
        if (maxScrollX < 0.0) { maxScrollX = 0.0 }
        if (maxScrollY < 0.0) { maxScrollY = 0.0 }

        scrollX = clampF(scrollX, 0.0, maxScrollX)
        scrollY = clampF(scrollY, 0.0, maxScrollY)

        canvas.pushClip(viewportX, viewportY, vpW, vpH)

        match (content) {
            case Some(child) =>
                child.setLayoutFrame(LayoutFrame(viewportX - scrollX, viewportY - scrollY, contentViewW, contentViewH))
                child.paint(canvas, initialWidth, initialHeight, currentWidth, currentHeight)
            case None => ()
        }

        canvas.popClip()

        paintScrollbars(canvas)
    }

    private func getScrollbarTrackColor(): Color { if (style.isThemeBased) { Theme.colors().scrollbarTrack } else { style.scrollbarTrackColor } }
    private func getScrollbarThumbColor(): Color { if (style.isThemeBased) { Theme.colors().scrollbarThumb } else { style.scrollbarThumbColor } }
    private func getScrollbarThumbHoverColor(): Color { if (style.isThemeBased) { Theme.colors().scrollbarThumbHover } else { style.scrollbarThumbHoverColor } }
    private func getBarThickness(): Float32 { if (style.isThemeBased) { 10.0 } else { style.barThickness } }
    private func getBarMinLength(): Float32 { if (style.isThemeBased) { 20.0 } else { style.barMinLength } }

    private func paintScrollbars(canvas: Canvas): Unit {
        let vpW = if (showBarY) { viewportW - getBarThickness() } else { viewportW }
        let vpH = if (showBarX) { viewportH - getBarThickness() } else { viewportH }

        let trackAlpha = UInt8(barOpacity * 255.0)
        if (trackAlpha == 0) { return }

        if (showBarY && maxScrollY > 0.0) {
            let barX = viewportX + vpW
            let barH = viewportH
            let thumbH = clampF(barH * vpH / contentViewH, getBarMinLength(), barH - 4.0)
            let thumbTravel = barH - thumbH - 4.0
            let thumbY = if (maxScrollY > 0.0) { viewportY + 2.0 + (scrollY / maxScrollY) * thumbTravel } else { viewportY + 2.0 }
            let trackC = getScrollbarTrackColor()
            canvas.fillRoundedRect(barX + 2.0, viewportY, getBarThickness() - 4.0, barH, 4.0,
                Color.rgba(trackC.r, trackC.g, trackC.b, trackAlpha))
            let thumbColor = if (draggingBarY || hoveredBarY) {
                let hoverC = getScrollbarThumbHoverColor()
                Color.rgba(hoverC.r, hoverC.g, hoverC.b, trackAlpha)
            } else {
                let thumbC = getScrollbarThumbColor()
                Color.rgba(thumbC.r, thumbC.g, thumbC.b, trackAlpha)
            }
            canvas.fillRoundedRect(barX + 2.0, thumbY, getBarThickness() - 4.0, thumbH, 4.0, thumbColor)
        }

        if (showBarX && maxScrollX > 0.0) {
            let barY = viewportY + vpH
            let barW = viewportW
            let thumbW = clampF(barW * vpW / contentViewW, getBarMinLength(), barW - 4.0)
            let thumbTravel = barW - thumbW - 4.0
            let thumbX = if (maxScrollX > 0.0) { viewportX + 2.0 + (scrollX / maxScrollX) * thumbTravel } else { viewportX + 2.0 }

            let trackC = getScrollbarTrackColor()
            canvas.fillRoundedRect(viewportX, barY + 2.0, barW, getBarThickness() - 4.0, 4.0,
                Color.rgba(trackC.r, trackC.g, trackC.b, trackAlpha))
            let thumbColor = if (draggingBarX || hoveredBarX) {
                let hoverC = getScrollbarThumbHoverColor()
                Color.rgba(hoverC.r, hoverC.g, hoverC.b, trackAlpha)
            } else {
                let thumbC = getScrollbarThumbColor()
                Color.rgba(thumbC.r, thumbC.g, thumbC.b, trackAlpha)
            }
            canvas.fillRoundedRect(thumbX, barY + 2.0, thumbW, getBarThickness() - 4.0, 4.0, thumbColor)
        }
    }

    public func hitTest(x: Float32, y: Float32, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool {
        match (layoutFrame) {
            case Some(f) => x >= f.x && x <= f.x + f.width && y >= f.y && y <= f.y + f.height
            case None => x >= 0.0 && x <= Float32(currentWidth) && y >= 0.0 && y <= Float32(currentHeight)
        }
    }

    public func handleEvent(event: Event): Bool {
        match (event.eventType) {
            case EventType.MouseWheel =>
                match (event.mouseWheelEvent) {
                    case Some(we) =>
                        let lines = Float32(we.delta) / 120.0
                        scrollBy(0.0, -lines * wheelScrollSpeed)
                    case None => ()
                }
                true
            case EventType.MouseDown =>
                handleMouseDownEvent(event)
            case EventType.MouseUp =>
                if (draggingBarX || draggingBarY) {
                    draggingBarX = false
                    draggingBarY = false
                    true
                } else {
                    routeToContent(event)
                }
            case EventType.MouseMove =>
                handleMouseMoveEvent(event)
            case _ => routeToContent(event)
        }
    }

    private func handleMouseDownEvent(event: Event): Bool {
        match (event.mouseEvent) {
            case Some(me) =>
                let vpW = if (showBarY) { viewportW - getBarThickness() } else { viewportW }
                let vpH = if (showBarX) { viewportH - getBarThickness() } else { viewportH }

                if (showBarY && maxScrollY > 0.0) {
                    let barX = viewportX + vpW
                    if (me.x >= barX && me.x <= barX + getBarThickness() && me.y >= viewportY && me.y <= viewportY + viewportH) {
                        let barH = viewportH
                        let thumbH = clampF(barH * vpH / contentViewH, getBarMinLength(), barH - 4.0)
                        let thumbTravel = barH - thumbH - 4.0
                        let thumbY = viewportY + 2.0 + (scrollY / maxScrollY) * thumbTravel
                        if (me.y >= thumbY && me.y <= thumbY + thumbH) {
                            draggingBarY = true
                            dragStartScrollY = scrollY
                            dragStartMouseY = me.y
                        } else {
                            let clickRatio = (me.y - viewportY - thumbH / 2.0) / thumbTravel
                            scrollTo(scrollX, clampF(clickRatio * maxScrollY, 0.0, maxScrollY))
                        }
                        return true
                    }
                }

                if (showBarX && maxScrollX > 0.0) {
                    let barY = viewportY + vpH
                    if (me.x >= viewportX && me.x <= viewportX + viewportW && me.y >= barY && me.y <= barY + getBarThickness()) {
                        let barW = viewportW
                        let thumbW = clampF(barW * vpW / contentViewW, getBarMinLength(), barW - 4.0)
                        let thumbTravel = barW - thumbW - 4.0
                        let thumbX = viewportX + 2.0 + (scrollX / maxScrollX) * thumbTravel
                        if (me.x >= thumbX && me.x <= thumbX + thumbW) {
                            draggingBarX = true
                            dragStartScrollX = scrollX
                            dragStartMouseX = me.x
                        } else {
                            let clickRatio = (me.x - viewportX - thumbW / 2.0) / thumbTravel
                            scrollTo(clampF(clickRatio * maxScrollX, 0.0, maxScrollX), scrollY)
                        }
                        return true
                    }
                }

                routeToContent(event)
                true
            case None => false
        }
    }

    private func handleMouseMoveEvent(event: Event): Bool {
        match (event.mouseEvent) {
            case Some(me) =>
                let vpW = if (showBarY) { viewportW - getBarThickness() } else { viewportW }
                let vpH = if (showBarX) { viewportH - getBarThickness() } else { viewportH }

                if (draggingBarY) {
                    let barH = viewportH
                    let thumbH = clampF(barH * vpH / contentViewH, getBarMinLength(), barH - 4.0)
                    let thumbTravel = barH - thumbH - 4.0
                    if (thumbTravel > 0.0) {
                        let delta = me.y - dragStartMouseY
                        let ratio = delta / thumbTravel
                        let newY = clampF(dragStartScrollY + ratio * maxScrollY, 0.0, maxScrollY)
                        targetScrollY = newY
                        scrollY = newY
                        scrollAnimY.jumpToEnd()
                    }
                    return true
                }

                if (draggingBarX) {
                    let barW = viewportW
                    let thumbW = clampF(barW * vpW / contentViewW, getBarMinLength(), barW - 4.0)
                    let thumbTravel = barW - thumbW - 4.0
                    if (thumbTravel > 0.0) {
                        let delta = me.x - dragStartMouseX
                        let ratio = delta / thumbTravel
                        let newX = clampF(dragStartScrollX + ratio * maxScrollX, 0.0, maxScrollX)
                        targetScrollX = newX
                        scrollX = newX
                        scrollAnimX.jumpToEnd()
                    }
                    return true
                }

                if (showBarY && maxScrollY > 0.0) {
                    let barX = viewportX + vpW
                    hoveredBarY = me.x >= barX && me.x <= barX + getBarThickness() && me.y >= viewportY && me.y <= viewportY + viewportH
                }
                if (showBarX && maxScrollX > 0.0) {
                    let barY = viewportY + vpH
                    hoveredBarX = me.x >= viewportX && me.x <= viewportX + viewportW && me.y >= barY && me.y <= barY + getBarThickness()
                }

                routeToContent(event)
                true
            case None => false
        }
    }

    private func routeToContent(event: Event): Bool {
        match (content) {
            case Some(child) => child.handleEvent(event)
            case None => false
        }
    }

    public func contains(x: Float32, y: Float32): Bool { true }

    public func updateAnimation(tickCount: Int64): Bool {
        var active = false
        scrollAnimX.update(tickCount)
        scrollAnimY.update(tickCount)
        barOpacityAnim.update(tickCount)

        if (!scrollAnimX.isFinished()) {
            scrollX = scrollAnimX.getValue()
            active = true
        }
        if (!scrollAnimY.isFinished()) {
            scrollY = scrollAnimY.getValue()
            active = true
        }

        if (barOpacityAnim.isFinished() && lastWheelTime > 0) {
            let now = unsafe { bridge_get_tick_count() }
            if (now - lastWheelTime > 1500 && barOpacity > 0.31) {
                barOpacityAnim.start(barOpacity, 0.3, 500, Easing.EaseOut)
            }
        }
        if (!barOpacityAnim.isFinished()) {
            barOpacity = barOpacityAnim.getValue()
            active = true
        }

        match (content) {
            case Some(child) =>
                if (child.updateAnimation(tickCount)) { active = true }
            case None => ()
        }

        active
    }

    public func getLayoutMinWidth(): Float32 { 100.0 }
    public func getLayoutMinHeight(): Float32 { 100.0 }
    public func setLayoutFrame(frame: LayoutFrame): Unit { this.layoutFrame = Some(frame) }
    public func clearLayoutFrame(): Unit { this.layoutFrame = None }
    public func getLayoutFrame(): Option<LayoutFrame> { layoutFrame }
}
