package cjform

public struct ProgressBarStyle {
    public let trackColor: Color
    public let fillColor: Color
    public let cornerRadius: Float32
    public let height: Float32
    public let isThemeBased: Bool

    public init() {
        this.trackColor = Color.rgb(230, 230, 230)
        this.fillColor = Color.rgb(70, 130, 180)
        this.cornerRadius = 4.0
        this.height = 16.0
        this.isThemeBased = false
    }

    public init(trackColor: Color, fillColor: Color, cornerRadius: Float32, height: Float32) {
        this.trackColor = trackColor
        this.fillColor = fillColor
        this.cornerRadius = cornerRadius
        this.height = height
        this.isThemeBased = false
    }

    public init(isThemeBased: Bool) {
        this.trackColor = Color.WHITE
        this.fillColor = Color.WHITE
        this.cornerRadius = 4.0
        this.height = 16.0
        this.isThemeBased = isThemeBased
    }

    public static func default(): ProgressBarStyle { ProgressBarStyle() }
    public static func fromTheme(): ProgressBarStyle { ProgressBarStyle(true) }
}

public class ProgressBar <: Widget {
    private var minValue: Float32
    private var maxValue: Float32
    private var currentValue: Float32
    private var style: ProgressBarStyle
    private var isIndeterminate: Bool
    private var animOffset: AnimationState
    private var layoutFrame: Option<LayoutFrame>

    public init(minValue: Float32, maxValue: Float32, value: Float32, style: ProgressBarStyle) {
        this.minValue = minValue
        this.maxValue = maxValue
        this.currentValue = if (value < minValue) { minValue } else if (value > maxValue) { maxValue } else { value }
        this.style = style
        this.isIndeterminate = false
        this.animOffset = AnimationState()
        this.layoutFrame = None
    }

    public func setValue(value: Float32): Unit {
        currentValue = if (value < minValue) { minValue } else if (value > maxValue) { maxValue } else { value }
    }

    public func setIndeterminate(indeterminate: Bool): Unit {
        isIndeterminate = indeterminate
        if (indeterminate) {
            animOffset.start(0.0, 1.0, 1500, Easing.EaseInOut)
        }
    }

    public func getValue(): Float32 { currentValue }

    public func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        var x: Float32 = 0.0
        var y: Float32 = 0.0
        var w: Float32 = 0.0
        var h: Float32 = 0.0

        match (layoutFrame) {
            case Some(frame) =>
                x = frame.x; y = frame.y; w = frame.width; h = frame.height
            case None =>
                x = 0.0; y = 0.0; w = currentWidth; h = style.height
        }

        let trackColor = if (style.isThemeBased) { Theme.colors().progressTrack } else { style.trackColor }
        let fillColor = if (style.isThemeBased) { Theme.colors().progressFill } else { style.fillColor }
        let r = style.cornerRadius
        let rr = if (r > h / 2.0) { h / 2.0 } else { r }

        canvas.fillRoundedRect(x, y, w, h, rr, trackColor)

        if (isIndeterminate) {
            let stripeW = w * 0.35
            let maxX = w - stripeW
            let progress = animOffset.getValue()
            let stripeX = x + progress * maxX
            canvas.fillRoundedRect(stripeX, y, stripeW, h, rr, fillColor)
        } else {
            let ratio = (currentValue - minValue) / (maxValue - minValue)
            if (ratio > 0.0) {
                let fillW = w * ratio
                canvas.fillRoundedRect(x, y, fillW, h, rr, fillColor)
            }
        }
    }

    public func hitTest(x: Float32, y: Float32, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool { false }
    public func handleEvent(event: Event): Bool { false }
    public func contains(x: Float32, y: Float32): Bool { true }

    public func findLeafAt(x: Float32, y: Float32): Widget { this }

    public func updateAnimation(tickCount: Int64): Bool {
        if (!isIndeterminate) { return false }
        animOffset.update(tickCount)
        if (animOffset.isFinished()) {
            animOffset.start(0.0, 1.0, 1500, Easing.EaseInOut)
        }
        true
    }

    public func getLayoutMinWidth(): Float32 { 200.0 }
    public func getLayoutMinHeight(): Float32 { style.height }
    public func setLayoutFrame(frame: LayoutFrame): Unit { this.layoutFrame = Some(frame) }
    public func clearLayoutFrame(): Unit { this.layoutFrame = None }
    public func getLayoutFrame(): Option<LayoutFrame> { layoutFrame }
}
