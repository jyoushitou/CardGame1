package cjform

import std.collection.*

public class VBox <: Widget {
    private var children: ArrayList<Widget>
    private var childParams: ArrayList<LayoutParams>
    private var spacing: Float32
    private var padding: Float32
    private var layoutFrame: Option<LayoutFrame>
    private var hoveredChild: Option<Widget>

    public init() {
        this.children = ArrayList<Widget>()
        this.childParams = ArrayList<LayoutParams>()
        this.spacing = 8.0
        this.padding = 0.0
        this.layoutFrame = None
        this.hoveredChild = None
    }

    public init(spacing: Float32) {
        this.children = ArrayList<Widget>()
        this.childParams = ArrayList<LayoutParams>()
        this.spacing = spacing
        this.padding = 0.0
        this.layoutFrame = None
        this.hoveredChild = None
    }

    public init(spacing: Float32, padding: Float32) {
        this.children = ArrayList<Widget>()
        this.childParams = ArrayList<LayoutParams>()
        this.spacing = spacing
        this.padding = padding
        this.layoutFrame = None
        this.hoveredChild = None
    }

    public func add(child: Widget): VBox {
        children.add(child)
        childParams.add(LayoutParams.intrinsic())
        this
    }

    public func add(child: Widget, params: LayoutParams): VBox {
        children.add(child)
        childParams.add(params)
        this
    }

    public func setSpacing(spacing: Float32): Unit {
        this.spacing = spacing
    }

    public func setPadding(padding: Float32): Unit {
        this.padding = padding
    }

    public func getLayoutMinWidth(): Float32 {
        var maxW: Float32 = padding * 2.0
        for (i in 0..children.size) {
            let params = childParams[i]
            let child = children[i]
            let childW = match (params.widthMode) {
                case SizeMode.Fixed => params.widthValue
                case SizeMode.Intrinsic => child.getLayoutMinWidth()
                case SizeMode.Fill => Float32(0)
            }
            if (childW > maxW) {
                maxW = childW
            }
        }
        maxW
    }

    public func getLayoutMinHeight(): Float32 {
        var total: Float32 = padding * 2.0
        for (i in 0..children.size) {
            if (i > 0) {
                total = total + spacing
            }
            let params = childParams[i]
            let child = children[i]
            let childH = match (params.heightMode) {
                case SizeMode.Fixed => params.heightValue
                case SizeMode.Intrinsic => child.getLayoutMinHeight()
                case SizeMode.Fill => Float32(0)
            }
            total = total + childH
        }
        total
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

    private func performLayout(x: Float32, y: Float32, width: Float32, height: Float32): Unit {
        let contentW = width - padding * 2.0
        let contentH = height - padding * 2.0

        var fixedTotal: Float32 = 0.0
        var fillCount: Int32 = 0
        var childHeights = ArrayList<Float32>()
        var childWidths = ArrayList<Float32>()

        for (i in 0..children.size) {
            let params = childParams[i]
            let child = children[i]

            let cw = match (params.widthMode) {
                case SizeMode.Fixed => params.widthValue
                case SizeMode.Intrinsic => child.getLayoutMinWidth()
                case SizeMode.Fill => contentW
            }
            childWidths.add(cw)

            let ch = match (params.heightMode) {
                case SizeMode.Fixed =>
                    fixedTotal = fixedTotal + params.heightValue
                    params.heightValue
                case SizeMode.Intrinsic =>
                    let ih = child.getLayoutMinHeight()
                    fixedTotal = fixedTotal + ih
                    ih
                case SizeMode.Fill =>
                    fillCount = fillCount + 1
                    Float32(0)
            }
            childHeights.add(ch)
        }

        let spacingTotal = if (children.size > 0) { spacing * Float32(children.size - 1) } else { Float32(0) }
        let remaining = contentH - fixedTotal - spacingTotal
        let fillSize = if (remaining < 0.0) { Float32(0) } else if (fillCount > 0) { remaining / Float32(fillCount) } else { Float32(0) }

        var currentY: Float32 = y + padding

        for (i in 0..children.size) {
            let params = childParams[i]
            let child = children[i]

            var ch = childHeights[i]
            if (params.heightMode == SizeMode.Fill) {
                ch = fillSize
            }

            var cw = childWidths[i]

            var childX: Float32 = x + padding
            match (params.alignH) {
                case LayoutAlign.Start =>
                    childX = x + padding + params.margin
                case LayoutAlign.Center =>
                    childX = x + padding + (contentW - cw) / 2.0
                case LayoutAlign.End =>
                    childX = x + padding + contentW - cw - params.margin
                case LayoutAlign.Stretch =>
                    childX = x + padding + params.margin
                    cw = contentW - params.margin * 2.0
            }

            let finalX = childX
            let finalY = currentY + params.margin
            let finalW = match (params.alignH) {
                case LayoutAlign.Stretch => cw
                case _ => cw - params.margin * 2.0
            }
            let finalH = if (ch - params.margin * 2.0 < 0.0) { Float32(0) } else { ch - params.margin * 2.0 }

            child.setLayoutFrame(LayoutFrame(finalX, finalY, finalW, finalH))
            currentY = currentY + ch + spacing
        }
    }

    public func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        match (layoutFrame) {
            case Some(f) => performLayout(f.x, f.y, f.width, f.height)
            case None => performLayout(0.0, 0.0, Float32(currentWidth), Float32(currentHeight))
        }
        for (child in children) {
            child.paint(canvas, initialWidth, initialHeight, currentWidth, currentHeight)
        }
    }

    public func hitTest(x: Float32, y: Float32, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool {
        match (layoutFrame) {
            case Some(f) => performLayout(f.x, f.y, f.width, f.height)
            case None => performLayout(0.0, 0.0, Float32(currentWidth), Float32(currentHeight))
        }
        for (child in children) {
            if (child.hitTest(x, y, initialWidth, initialHeight, currentWidth, currentHeight)) {
                return true
            }
        }
        false
    }

    public func handleEvent(event: Event): Bool {
        match (event.eventType) {
            case EventType.MouseMove =>
                match (event.mouseEvent) {
                    case Some(me) =>
                        var newHovered: Option<Widget> = None
                        for (child in children) {
                            if (child.hitTest(me.x, me.y, 0.0, 0.0, 0.0, 0.0)) {
                                newHovered = Some(child)
                                break
                            }
                        }
                        match (hoveredChild) {
                            case Some(old) => old.handleEvent(Event.mouseLeave())
                            case None => ()
                        }
                        hoveredChild = newHovered
                        match (newHovered) {
                            case Some(new) =>
                                new.handleEvent(Event.mouseEnter())
                                new.handleEvent(event)
                            case None => ()
                        }
                        true
                    case None => false
                }
            case EventType.MouseDown | EventType.MouseUp =>
                match (event.mouseEvent) {
                    case Some(me) =>
                        for (child in children) {
                            if (child.hitTest(me.x, me.y, 0.0, 0.0, 0.0, 0.0)) {
                                return child.handleEvent(event)
                            }
                        }
                        false
                    case None => false
                }
            case _ =>
                for (child in children) {
                    if (child.handleEvent(event)) {
                        return true
                    }
                }
                false
        }
    }

    public func contains(x: Float32, y: Float32): Bool {
        match (layoutFrame) {
            case Some(f) => x >= f.x && x <= f.x + f.width && y >= f.y && y <= f.y + f.height
            case None => false
        }
    }

    public func findLeafAt(x: Float32, y: Float32): Widget {
        for (child in children) {
            if (child.hitTest(x, y, 0.0, 0.0, 0.0, 0.0)) {
                return child.findLeafAt(x, y)
            }
        }
        this
    }

    public func getChildren(): ArrayList<Widget> {
        children
    }
    public func updateAnimation(tickCount: Int64): Bool {
        var active = false
        for (child in children) {
            if (child.updateAnimation(tickCount)) { active = true }
        }
        active
    }
}
