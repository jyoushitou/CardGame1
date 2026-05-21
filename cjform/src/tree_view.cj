package cjform

import std.collection.*

public class TreeNode {
    public let label: String
    public var expanded: Bool
    public var children: ArrayList<TreeNode>
    public var depth: Int32

    public init(label: String) {
        this.label = label
        this.expanded = false
        this.children = ArrayList<TreeNode>()
        this.depth = 0
    }

    public func addChild(child: TreeNode): TreeNode {
        child.depth = this.depth + 1
        children.add(child)
        child
    }

    public func hasChildren(): Bool { children.size > 0 }
}

public struct TreeViewStyle {
    public let selectionColor: Color
    public let hoverColor: Color
    public let arrowColor: Color
    public let selectedTextColor: Color
    public let normalTextColor: Color
    public let scrollbarTrackColor: Color
    public let scrollbarThumbColor: Color
    public let scrollbarThumbHoverColor: Color
    public let isThemeBased: Bool

    public init() {
        this.selectionColor = Color.WHITE
        this.hoverColor = Color.WHITE
        this.arrowColor = Color.WHITE
        this.selectedTextColor = Color.WHITE
        this.normalTextColor = Color.WHITE
        this.scrollbarTrackColor = Color.WHITE
        this.scrollbarThumbColor = Color.WHITE
        this.scrollbarThumbHoverColor = Color.WHITE
        this.isThemeBased = false
    }

    public init(selectionColor: Color, hoverColor: Color, arrowColor: Color,
        selectedTextColor: Color, normalTextColor: Color, scrollbarTrackColor: Color,
        scrollbarThumbColor: Color, scrollbarThumbHoverColor: Color) {
        this.selectionColor = selectionColor
        this.hoverColor = hoverColor
        this.arrowColor = arrowColor
        this.selectedTextColor = selectedTextColor
        this.normalTextColor = normalTextColor
        this.scrollbarTrackColor = scrollbarTrackColor
        this.scrollbarThumbColor = scrollbarThumbColor
        this.scrollbarThumbHoverColor = scrollbarThumbHoverColor
        this.isThemeBased = false
    }

    public init(isThemeBased: Bool) {
        this.selectionColor = Color.WHITE
        this.hoverColor = Color.WHITE
        this.arrowColor = Color.WHITE
        this.selectedTextColor = Color.WHITE
        this.normalTextColor = Color.WHITE
        this.scrollbarTrackColor = Color.WHITE
        this.scrollbarThumbColor = Color.WHITE
        this.scrollbarThumbHoverColor = Color.WHITE
        this.isThemeBased = isThemeBased
    }

    public static func fromTheme(): TreeViewStyle { TreeViewStyle(true) }
}

public class TreeView <: Widget {
    private var rootNodes: ArrayList<TreeNode>
    private var visibleNodes: ArrayList<TreeNode>
    private var nodeHeight: Float32
    private var indentWidth: Float32
    private var toggleSize: Float32
    private var needsFlatten: Bool
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
    private var selectedNodeIndex: Int32
    private var onSelectionChanged: Option<(Int32) -> Unit>
    private var hoveredNodeIndex: Int32
    private var layoutFrame: Option<LayoutFrame>
    private var viewportW: Float32
    private var viewportH: Float32
    private var wheelScrollSpeed: Float32
    private var style: TreeViewStyle

    public init() {
        this.rootNodes = ArrayList<TreeNode>()
        this.visibleNodes = ArrayList<TreeNode>()
        this.nodeHeight = 24.0
        this.indentWidth = 20.0
        this.toggleSize = 10.0
        this.needsFlatten = true
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
        this.selectedNodeIndex = -1
        this.onSelectionChanged = None<(Int32) -> Unit>
        this.hoveredNodeIndex = -1
        this.layoutFrame = None
        this.viewportW = 0.0
        this.viewportH = 0.0
        this.wheelScrollSpeed = 40.0
        this.style = TreeViewStyle.fromTheme()
    }

    public init(style: TreeViewStyle) {
        this.rootNodes = ArrayList<TreeNode>()
        this.visibleNodes = ArrayList<TreeNode>()
        this.nodeHeight = 24.0
        this.indentWidth = 20.0
        this.toggleSize = 10.0
        this.needsFlatten = true
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
        this.selectedNodeIndex = -1
        this.onSelectionChanged = None<(Int32) -> Unit>
        this.hoveredNodeIndex = -1
        this.layoutFrame = None
        this.viewportW = 0.0
        this.viewportH = 0.0
        this.wheelScrollSpeed = 40.0
        this.style = style
    }

    public static func styled(styleName: String): TreeView {
        TreeView(TreeViewStyle.fromTheme())
    }

    public func addNode(node: TreeNode): Unit {
        rootNodes.add(node)
        needsFlatten = true
    }

    public func getRootNodes(): ArrayList<TreeNode> { rootNodes }

    public func setOnSelectionChanged(callback: (Int32) -> Unit): Unit {
        this.onSelectionChanged = Some<(Int32) -> Unit>(callback)
    }

    public func getSelectedNodeIndex(): Int32 { selectedNodeIndex }

    public func expandAll(): Unit {
        expandRecursive(rootNodes)
        needsFlatten = true
    }

    private func expandRecursive(nodes: ArrayList<TreeNode>): Unit {
        for (node in nodes) {
            if (node.hasChildren()) {
                node.expanded = true
                expandRecursive(node.children)
            }
        }
    }

    public func collapseAll(): Unit {
        collapseRecursive(rootNodes)
        needsFlatten = true
    }

    private func collapseRecursive(nodes: ArrayList<TreeNode>): Unit {
        for (node in nodes) {
            node.expanded = false
            collapseRecursive(node.children)
        }
    }

    private func clampF(v: Float32, lo: Float32, hi: Float32): Float32 {
        if (v < lo) { lo } else if (v > hi) { hi } else { v }
    }

    private func showBars(): Unit {
        barOpacityAnim.start(barOpacity, 1.0, 150, Easing.EaseOut)
        lastWheelTime = unsafe { bridge_get_tick_count() }
    }

    private func getSelectionColor(): Color { if (style.isThemeBased) { Theme.colors().accent } else { style.selectionColor } }
    private func getHoverColor(): Color { if (style.isThemeBased) { Theme.colors().border } else { style.hoverColor } }
    private func getArrowColor(): Color { if (style.isThemeBased) { Theme.colors().textSecondary } else { style.arrowColor } }
    private func getSelectedTextColor(): Color { if (style.isThemeBased) { Theme.colors().accent } else { style.selectedTextColor } }
    private func getNormalTextColor(): Color { if (style.isThemeBased) { Theme.colors().textPrimary } else { style.normalTextColor } }
    private func getScrollbarTrackColor(): Color { if (style.isThemeBased) { Theme.colors().scrollbarTrack } else { style.scrollbarTrackColor } }
    private func getScrollbarThumbColor(): Color { if (style.isThemeBased) { Theme.colors().scrollbarThumb } else { style.scrollbarThumbColor } }
    private func getScrollbarThumbHoverColor(): Color { if (style.isThemeBased) { Theme.colors().scrollbarThumbHover } else { style.scrollbarThumbHoverColor } }

    public func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        let frameX = match (layoutFrame) { case Some(f) => f.x; case None => Float32(0.0) }
        let frameY = match (layoutFrame) { case Some(f) => f.y; case None => Float32(0.0) }
        viewportW = match (layoutFrame) { case Some(f) => f.width; case None => Float32(currentWidth) }
        viewportH = match (layoutFrame) { case Some(f) => f.height; case None => Float32(currentHeight) }

        if (needsFlatten) {
            visibleNodes = flattenNodes(rootNodes)
            needsFlatten = false
        }

        showBar = Float32(visibleNodes.size) * nodeHeight > viewportH
        let vpW = if (showBar) { viewportW - barThickness } else { viewportW }
        maxScrollOffset = if (showBar) { Float32(visibleNodes.size) * nodeHeight - viewportH } else { Float32(0.0) }
        if (maxScrollOffset < 0.0) { maxScrollOffset = 0.0 }
        scrollOffset = clampF(scrollOffset, 0.0, maxScrollOffset)
        canvas.pushClip(frameX, frameY, vpW, viewportH)

        let firstIdx = Int32(Float32(Int64(scrollOffset / nodeHeight)))
        let lastIdx = Int32(Float32(Int64((scrollOffset + viewportH) / nodeHeight))) + 1
        var first = if (firstIdx < 0) { Int32(0) } else { firstIdx }
        var last = if (lastIdx > Int32(visibleNodes.size)) { Int32(visibleNodes.size) } else { lastIdx }

        for (i in first..last) {
            let node = visibleNodes[Int64(i)]
            let y = Float32(i) * nodeHeight - scrollOffset + frameY
            let x = frameX + Float32(node.depth) * indentWidth + 8.0

            if (Int32(i) == selectedNodeIndex) {
                let sel = getSelectionColor()
                canvas.fillRoundedRect(frameX + 2.0, y, vpW - 4.0, nodeHeight, 4.0, Color.rgba(sel.r, sel.g, sel.b, 40))
            } else if (Int32(i) == hoveredNodeIndex) {
                let hov = getHoverColor()
                canvas.fillRoundedRect(frameX + 2.0, y, vpW - 4.0, nodeHeight, 4.0, Color.rgba(hov.r, hov.g, hov.b, 30))
            }

            if (node.hasChildren()) {
                let tx = x - toggleSize - 4.0
                let ty = y + (nodeHeight - toggleSize) / 2.0
                let half = toggleSize / 2.0
                if (node.expanded) {
                    canvas.drawLine(tx, ty, tx + half, ty + toggleSize, 1.5, getArrowColor())
                    canvas.drawLine(tx + half, ty + toggleSize, tx + toggleSize, ty, 1.5, getArrowColor())
                } else {
                    canvas.drawLine(tx, ty, tx + toggleSize, ty + half, 1.5, getArrowColor())
                    canvas.drawLine(tx + toggleSize, ty + half, tx, ty + toggleSize, 1.5, getArrowColor())
                }
            }

            let textColor = if (Int32(i) == selectedNodeIndex) { getSelectedTextColor() } else { getNormalTextColor() }
            canvas.drawText(x, y + (nodeHeight - 14.0) / 2.0, node.label, "Microsoft YaHei", 14.0, textColor)
        }

        canvas.popClip()

        paintScrollbar(canvas, frameX, frameY)
    }

    private func flattenNodes(nodes: ArrayList<TreeNode>): ArrayList<TreeNode> {
        let result = ArrayList<TreeNode>()
        flattenRecursive(nodes, result)
        result
    }

    private func flattenRecursive(nodes: ArrayList<TreeNode>, result: ArrayList<TreeNode>): Unit {
        for (node in nodes) {
            result.add(node)
            if (node.expanded) {
                flattenRecursive(node.children, result)
            }
        }
    }

    private func paintScrollbar(canvas: Canvas, frameX: Float32, frameY: Float32): Unit {
        if (!showBar || maxScrollOffset <= 0.0) { return }
        let alpha = UInt8(barOpacity * 255.0)
        if (alpha == 0) { return }

        let barX = frameX + viewportW - barThickness
        let barH = viewportH
        let totalH = Float32(visibleNodes.size) * nodeHeight
        let thumbH = clampF(barH * barH / totalH, barMinLength, barH - 4.0)
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
        let frameY = match (layoutFrame) { case Some(f) => f.y; case None => Float32(0.0) }
        let frameX = match (layoutFrame) { case Some(f) => f.x; case None => Float32(0.0) }

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
                match (event.mouseEvent) {
                    case Some(me) =>
                        if (showBar && maxScrollOffset > 0.0) {
                            let barX = frameX + viewportW - barThickness
                            if (me.x >= barX && me.x <= barX + barThickness && me.y >= frameY && me.y <= frameY + viewportH) {
                                let barH = viewportH
                                let totalH = Float32(visibleNodes.size) * nodeHeight
                                let thumbH = clampF(barH * barH / totalH, barMinLength, barH - 4.0)
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
                        let nodeIdx = Int32(relY / nodeHeight)
                        if (nodeIdx >= 0 && nodeIdx < Int32(visibleNodes.size)) {
                            let node = visibleNodes[Int64(nodeIdx)]
                            let toggleX = frameX + Float32(node.depth) * indentWidth + 8.0 - toggleSize - 8.0

                            if (node.hasChildren() && me.x >= toggleX && me.x <= toggleX + toggleSize + 2.0) {
                                node.expanded = !node.expanded
                                needsFlatten = true
                            } else {
                                selectedNodeIndex = nodeIdx
                                match (onSelectionChanged) {
                                    case Some(cb) => cb(selectedNodeIndex)
                                    case None => ()
                                }
                            }
                        }
                        true
                    case None => false
                }
            case EventType.MouseMove =>
                match (event.mouseEvent) {
                    case Some(me) =>
                        if (draggingBar) {
                            let barH = viewportH
                            let totalH = Float32(visibleNodes.size) * nodeHeight
                            let thumbH = clampF(barH * barH / totalH, barMinLength, barH - 4.0)
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
                            let barX = frameX + viewportW - barThickness
                            hoveredBar = me.x >= barX && me.x <= barX + barThickness && me.y >= frameY && me.y <= frameY + viewportH
                        }

                        let relY = me.y - frameY + scrollOffset
                        let nodeIdx = Int32(relY / nodeHeight)
                        if (nodeIdx >= 0 && nodeIdx < Int32(visibleNodes.size)) {
                            hoveredNodeIndex = nodeIdx
                        } else {
                            hoveredNodeIndex = -1
                        }
                        true
                    case None => false
                }
            case EventType.MouseUp =>
                draggingBar = false
                true
            case _ => false
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
