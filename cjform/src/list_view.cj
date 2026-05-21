package cjform

import std.collection.*

class ListItemEntry {
    public let index: Int32
    public let widget: Widget
    public var yOffset: Float32

    public init(index: Int32, widget: Widget, yOffset: Float32) {
        this.index = index
        this.widget = widget
        this.yOffset = yOffset
    }
}

public struct ListViewStyle {
    public let selectionColor: Color
    public let scrollbarTrackColor: Color
    public let scrollbarThumbColor: Color
    public let scrollbarThumbHoverColor: Color
    public let isThemeBased: Bool

    public init() {
        this.selectionColor = Color.WHITE
        this.scrollbarTrackColor = Color.WHITE
        this.scrollbarThumbColor = Color.WHITE
        this.scrollbarThumbHoverColor = Color.WHITE
        this.isThemeBased = false
    }

    public init(selectionColor: Color, scrollbarTrackColor: Color, scrollbarThumbColor: Color, scrollbarThumbHoverColor: Color) {
        this.selectionColor = selectionColor
        this.scrollbarTrackColor = scrollbarTrackColor
        this.scrollbarThumbColor = scrollbarThumbColor
        this.scrollbarThumbHoverColor = scrollbarThumbHoverColor
        this.isThemeBased = false
    }

    public init(isThemeBased: Bool) {
        this.selectionColor = Color.WHITE
        this.scrollbarTrackColor = Color.WHITE
        this.scrollbarThumbColor = Color.WHITE
        this.scrollbarThumbHoverColor = Color.WHITE
        this.isThemeBased = isThemeBased
    }

    public static func fromTheme(): ListViewStyle { ListViewStyle(true) }
}

public class ListView <: Widget {
    private var items: ArrayList<String>
    private var itemCount: Int32
    private var itemHeight: Float32
    private var itemBuilder: (Int32, String) -> Widget
    private var activeItems: ArrayList<ListItemEntry>
    private var recyclePool: ArrayList<Widget>
    private var scrollOffset: Float32
    private var targetScrollOffset: Float32
    private var maxScrollOffset: Float32
    private var scrollAnim: AnimationState
    private var barThickness: Float32
    private var barMinLength: Float32
    private var showBar: Bool
    private var barOpacity: Float32
    private var barOpacityAnim: AnimationState
    private var lastWheelTime: Int64
    private var draggingBar: Bool
    private var dragStartScroll: Float32
    private var dragStartMouseY: Float32
    private var hoveredBar: Bool
    private var selectedIndex: Int32
    private var onSelectionChanged: Option<(Int32) -> Unit>
    private var layoutFrame: Option<LayoutFrame>
    private var viewportW: Float32
    private var viewportH: Float32
    private var contentX: Float32
    private var contentY: Float32
    private var wheelScrollSpeed: Float32
    private var style: ListViewStyle

    public init(itemHeight: Float32) {
        this.items = ArrayList<String>()
        this.itemCount = 0
        this.itemHeight = itemHeight
        this.itemBuilder = { i, s => Label(s, Position.abs(0.0, 0.0), "Microsoft YaHei", 14.0, SizeScale.fixed(), Anchor.CenterLeft, false) }
        this.activeItems = ArrayList<ListItemEntry>()
        this.recyclePool = ArrayList<Widget>()
        this.scrollOffset = 0.0
        this.targetScrollOffset = 0.0
        this.maxScrollOffset = 0.0
        this.scrollAnim = AnimationState()
        this.barThickness = 10.0
        this.barMinLength = 20.0
        this.showBar = false
        this.barOpacity = 0.3
        this.barOpacityAnim = AnimationState()
        this.lastWheelTime = 0
        this.draggingBar = false
        this.dragStartScroll = 0.0
        this.dragStartMouseY = 0.0
        this.hoveredBar = false
        this.selectedIndex = -1
        this.onSelectionChanged = None<(Int32) -> Unit>
        this.layoutFrame = None
        this.viewportW = 0.0
        this.viewportH = 0.0
        this.contentX = 0.0
        this.contentY = 0.0
        this.wheelScrollSpeed = 40.0
        this.style = ListViewStyle.fromTheme()
    }

    public init(itemHeight: Float32, style: ListViewStyle) {
        this.items = ArrayList<String>()
        this.itemCount = 0
        this.itemHeight = itemHeight
        this.itemBuilder = { i, s => Label(s, Position.abs(0.0, 0.0), "Microsoft YaHei", 14.0, SizeScale.fixed(), Anchor.CenterLeft, false) }
        this.activeItems = ArrayList<ListItemEntry>()
        this.recyclePool = ArrayList<Widget>()
        this.scrollOffset = 0.0
        this.targetScrollOffset = 0.0
        this.maxScrollOffset = 0.0
        this.scrollAnim = AnimationState()
        this.barThickness = 10.0
        this.barMinLength = 20.0
        this.showBar = false
        this.barOpacity = 0.3
        this.barOpacityAnim = AnimationState()
        this.lastWheelTime = 0
        this.draggingBar = false
        this.dragStartScroll = 0.0
        this.dragStartMouseY = 0.0
        this.hoveredBar = false
        this.selectedIndex = -1
        this.onSelectionChanged = None<(Int32) -> Unit>
        this.layoutFrame = None
        this.viewportW = 0.0
        this.viewportH = 0.0
        this.contentX = 0.0
        this.contentY = 0.0
        this.wheelScrollSpeed = 40.0
        this.style = style
    }

    public static func styled(styleName: String, itemHeight: Float32): ListView {
        ListView(itemHeight, ListViewStyle.fromTheme())
    }

    public func setData(items: ArrayList<String>): Unit {
        this.items = items
        this.itemCount = Int32(items.size)
        activeItems = ArrayList<ListItemEntry>()
        reconfigureVisibleItems()
    }

    public func setItemBuilder(builder: (Int32, String) -> Widget): Unit {
        this.itemBuilder = builder
        activeItems = ArrayList<ListItemEntry>()
        reconfigureVisibleItems()
    }

    public func setOnSelectionChanged(callback: (Int32) -> Unit): Unit {
        this.onSelectionChanged = Some<(Int32) -> Unit>(callback)
    }

    public func getSelectedIndex(): Int32 { selectedIndex }

    public func setSelectedIndex(index: Int32): Unit {
        if (index >= 0 && index < itemCount) {
            selectedIndex = index
            match (onSelectionChanged) {
                case Some(cb) => cb(selectedIndex)
                case None => ()
            }
        }
    }

    public func scrollToIndex(index: Int32): Unit {
        if (index < 0 || index >= itemCount) { return }
        let target = Float32(index) * itemHeight
        if (target < scrollOffset) {
            targetScrollOffset = target
            scrollAnim.start(scrollOffset, target, 250, Easing.EaseOut)
        } else if (target + itemHeight > scrollOffset + viewportH) {
            targetScrollOffset = target - viewportH + itemHeight
            scrollAnim.start(scrollOffset, targetScrollOffset, 250, Easing.EaseOut)
        }
        showBars()
    }

    public func getItemCount(): Int32 { itemCount }

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
                viewportW = f.width
                viewportH = f.height
            case None =>
                viewportW = Float32(currentWidth)
                viewportH = Float32(currentHeight)
        }

        showBar = Float32(itemCount) * itemHeight > viewportH
        let vpW = if (showBar) { viewportW - barThickness } else { viewportW }
        maxScrollOffset = if (showBar) { Float32(itemCount) * itemHeight - viewportH } else { 0.0 }
        if (maxScrollOffset < 0.0) { maxScrollOffset = 0.0 }

        scrollOffset = clampF(scrollOffset, 0.0, maxScrollOffset)
        targetScrollOffset = clampF(targetScrollOffset, 0.0, maxScrollOffset)

        reconfigureVisibleItems()

        contentX = match (layoutFrame) {
            case Some(f) => f.x
            case None => Float32(0.0)
        }
        contentY = match (layoutFrame) {
            case Some(f) => f.y
            case None => Float32(0.0)
        }

        canvas.pushClip(contentX, contentY, vpW, viewportH)

        for (entry in activeItems) {
            if (entry.index == selectedIndex) {
                let sel = getSelectionColor()
                canvas.fillRoundedRect(contentX + 2.0, entry.yOffset, vpW - 4.0, itemHeight, 4.0,
                    Color.rgba(sel.r, sel.g, sel.b, 40))
            }
            entry.widget.paint(canvas, initialWidth, initialHeight, currentWidth, currentHeight)
        }

        canvas.popClip()

        paintScrollbar(canvas, contentX, contentY)
    }

    private func reconfigureVisibleItems(): Unit {
        let vpW = if (showBar) { viewportW - barThickness } else { viewportW }

        let firstIdx = Int32(Float32(Int64(scrollOffset / itemHeight)))
        let lastIdx = Int32(Float32(Int64((scrollOffset + viewportH) / itemHeight))) + 1
        var first = if (firstIdx < 0) { Int32(0) } else { firstIdx }
        var last = if (lastIdx > itemCount) { itemCount } else { lastIdx }

        for (entry in activeItems) {
            recyclePool.add(entry.widget)
        }

        activeItems = ArrayList<ListItemEntry>()
        for (i in first..last) {
            let w = getOrCreateWidget(Int32(i))
            let yOff = contentY + Float32(i) * itemHeight - scrollOffset
            w.setLayoutFrame(LayoutFrame(contentX, yOff, vpW, itemHeight))
            activeItems.add(ListItemEntry(Int32(i), w, yOff))
        }
    }

    private func getOrCreateWidget(index: Int32): Widget {
        itemBuilder(Int32(index), items[Int64(index)])
    }

    private func getSelectionColor(): Color { if (style.isThemeBased) { Theme.colors().accent } else { style.selectionColor } }
    private func getScrollbarTrackColor(): Color { if (style.isThemeBased) { Theme.colors().scrollbarTrack } else { style.scrollbarTrackColor } }
    private func getScrollbarThumbColor(): Color { if (style.isThemeBased) { Theme.colors().scrollbarThumb } else { style.scrollbarThumbColor } }
    private func getScrollbarThumbHoverColor(): Color { if (style.isThemeBased) { Theme.colors().scrollbarThumbHover } else { style.scrollbarThumbHoverColor } }

    private func paintScrollbar(canvas: Canvas, frameX: Float32, frameY: Float32): Unit {
        if (!showBar || maxScrollOffset <= 0.0) { return }
        let alpha = UInt8(barOpacity * 255.0)
        if (alpha == 0) { return }

        let barX = frameX + viewportW - barThickness
        let barH = viewportH
        let thumbH = clampF(barH * barH / (Float32(itemCount) * itemHeight), barMinLength, barH - 4.0)
        let thumbTravel = barH - thumbH - 4.0
        let thumbY = if (maxScrollOffset > 0.0) { frameY + 2.0 + (scrollOffset / maxScrollOffset) * thumbTravel } else { frameY + 2.0 }

        let trackC = getScrollbarTrackColor()
        canvas.fillRoundedRect(barX + 2.0, frameY, barThickness - 4.0, barH, 4.0,
            Color.rgba(trackC.r, trackC.g, trackC.b, alpha))
        let thumbColor = if (draggingBar || hoveredBar) {
            let hoverC = getScrollbarThumbHoverColor()
            Color.rgba(hoverC.r, hoverC.g, hoverC.b, alpha)
        } else {
            let thumbC = getScrollbarThumbColor()
            Color.rgba(thumbC.r, thumbC.g, thumbC.b, alpha)
        }
        canvas.fillRoundedRect(barX + 2.0, thumbY, barThickness - 4.0, thumbH, 4.0, thumbColor)
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
                        let delta = -lines * wheelScrollSpeed
                        let newTarget = clampF(targetScrollOffset + delta, 0.0, maxScrollOffset)
                        if (!scrollAnim.isFinished()) {
                            scrollAnim.jumpToEnd()
                            scrollOffset = scrollAnim.getValue()
                        }
                        targetScrollOffset = newTarget
                        scrollAnim.start(scrollOffset, newTarget, 250, Easing.EaseOut)
                        showBars()
                    case None => ()
                }
                true
            case EventType.MouseDown =>
                handleMouseDown(event)
            case EventType.MouseUp =>
                draggingBar = false
                true
            case EventType.MouseMove =>
                handleMouseMove(event)
            case _ => false
        }
    }

    private func handleMouseDown(event: Event): Bool {
        match (event.mouseEvent) {
            case Some(me) =>
                let frameY = contentY
                if (showBar && maxScrollOffset > 0.0) {
                    let barX = contentX + viewportW - barThickness
                    if (me.x >= barX && me.x <= barX + barThickness && me.y >= frameY && me.y <= frameY + viewportH) {
                        let barH = viewportH
                        let thumbH = clampF(barH * barH / (Float32(itemCount) * itemHeight), barMinLength, barH - 4.0)
                        let thumbTravel = barH - thumbH - 4.0
                        let thumbY = frameY + 2.0 + (scrollOffset / maxScrollOffset) * thumbTravel
                        if (me.y >= thumbY && me.y <= thumbY + thumbH) {
                            draggingBar = true
                            dragStartScroll = scrollOffset
                            dragStartMouseY = me.y
                        } else {
                            let clickRatio = (me.y - frameY - thumbH / 2.0) / thumbTravel
                            let target = clampF(clickRatio * maxScrollOffset, 0.0, maxScrollOffset)
                            targetScrollOffset = target
                            scrollAnim.start(scrollOffset, target, 250, Easing.EaseOut)
                            showBars()
                        }
                        return true
                    }
                }

                let relY = me.y - frameY + scrollOffset
                let idx = Int32(relY / itemHeight)
                if (idx >= 0 && idx < itemCount) {
                    selectedIndex = idx
                    match (onSelectionChanged) {
                        case Some(cb) => cb(selectedIndex)
                        case None => ()
                    }
                }
                true
            case None => false
        }
    }

    private func handleMouseMove(event: Event): Bool {
        match (event.mouseEvent) {
            case Some(me) =>
                if (draggingBar) {
                    let barH = viewportH
                    let thumbH = clampF(barH * barH / (Float32(itemCount) * itemHeight), barMinLength, barH - 4.0)
                    let thumbTravel = barH - thumbH - 4.0
                    if (thumbTravel > 0.0) {
                        let delta = me.y - dragStartMouseY
                        let ratio = delta / thumbTravel
                        let newOff = clampF(dragStartScroll + ratio * maxScrollOffset, 0.0, maxScrollOffset)
                        targetScrollOffset = newOff
                        scrollOffset = newOff
                        scrollAnim.jumpToEnd()
                    }
                    return true
                }
                if (showBar && maxScrollOffset > 0.0) {
                    let frameX = contentX
                    let barX = frameX + viewportW - barThickness
                    let frameY = contentY
                    hoveredBar = me.x >= barX && me.x <= barX + barThickness && me.y >= frameY && me.y <= frameY + viewportH
                }
                false
            case None => false
        }
    }

    public func contains(x: Float32, y: Float32): Bool { true }

    public func findLeafAt(x: Float32, y: Float32): Widget { this }

    public func updateAnimation(tickCount: Int64): Bool {
        var active = false
        scrollAnim.update(tickCount)
        barOpacityAnim.update(tickCount)

        if (!scrollAnim.isFinished()) {
            scrollOffset = scrollAnim.getValue()
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

        active
    }

    public func getLayoutMinWidth(): Float32 { 200.0 }
    public func getLayoutMinHeight(): Float32 { 200.0 }
    public func setLayoutFrame(frame: LayoutFrame): Unit { this.layoutFrame = Some(frame) }
    public func clearLayoutFrame(): Unit { this.layoutFrame = None }
    public func getLayoutFrame(): Option<LayoutFrame> { layoutFrame }
}
