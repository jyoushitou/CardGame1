package cjform

public struct SeparatorStyle {
    public let color: Color
    public let thickness: Float32
    public let margin: Float32
    public let isThemeBased: Bool

    public init() {
        this.color = Color.rgb(200, 200, 200)
        this.thickness = 1.0
        this.margin = 4.0
        this.isThemeBased = false
    }

    public init(color: Color, thickness: Float32, margin: Float32) {
        this.color = color
        this.thickness = thickness
        this.margin = margin
        this.isThemeBased = false
    }

    public init(isThemeBased: Bool) {
        this.color = Color.WHITE
        this.thickness = 1.0
        this.margin = 4.0
        this.isThemeBased = isThemeBased
    }

    public static func default(): SeparatorStyle { SeparatorStyle() }
    public static func fromTheme(): SeparatorStyle { SeparatorStyle(true) }
}

public class Separator <: Widget {
    private var isHorizontal: Bool
    private var style: SeparatorStyle
    private var layoutFrame: Option<LayoutFrame>

    public init(isHorizontal: Bool, style: SeparatorStyle) {
        this.isHorizontal = isHorizontal
        this.style = style
        this.layoutFrame = None
    }

    public func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        let color = if (style.isThemeBased) { Theme.colors().separator } else { style.color }
        match (layoutFrame) {
            case Some(frame) =>
                if (isHorizontal) {
                    canvas.drawLine(frame.x + style.margin, frame.y + frame.height / 2.0,
                        frame.x + frame.width - style.margin, frame.y + frame.height / 2.0,
                        style.thickness, color)
                } else {
                    canvas.drawLine(frame.x + frame.width / 2.0, frame.y + style.margin,
                        frame.x + frame.width / 2.0, frame.y + frame.height - style.margin,
                        style.thickness, color)
                }
            case None => ()
        }
    }

    public func hitTest(x: Float32, y: Float32, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool { false }
    public func handleEvent(event: Event): Bool { false }
    public func contains(x: Float32, y: Float32): Bool { false }
    public func updateAnimation(tickCount: Int64): Bool { false }
    public func findLeafAt(x: Float32, y: Float32): Widget { this }

    public func getLayoutMinWidth(): Float32 { style.thickness + style.margin * 2.0 }
    public func getLayoutMinHeight(): Float32 { style.thickness + style.margin * 2.0 }
    public func setLayoutFrame(frame: LayoutFrame): Unit { this.layoutFrame = Some(frame) }
    public func clearLayoutFrame(): Unit { this.layoutFrame = None }
    public func getLayoutFrame(): Option<LayoutFrame> { layoutFrame }
}
