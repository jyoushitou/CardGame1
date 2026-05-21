package cjform

public struct ToggleSwitchStyle {
    public let trackColor: Color
    public let trackOnColor: Color
    public let thumbColor: Color
    public let isThemeBased: Bool

    public init() {
        this.trackColor = Color.rgb(200, 200, 200)
        this.trackOnColor = Color.rgb(70, 130, 180)
        this.thumbColor = Color.WHITE
        this.isThemeBased = false
    }

    public init(trackColor: Color, trackOnColor: Color, thumbColor: Color) {
        this.trackColor = trackColor
        this.trackOnColor = trackOnColor
        this.thumbColor = thumbColor
        this.isThemeBased = false
    }

    public init(isThemeBased: Bool) {
        this.trackColor = Color.WHITE
        this.trackOnColor = Color.WHITE
        this.thumbColor = Color.WHITE
        this.isThemeBased = isThemeBased
    }

    public static func default(): ToggleSwitchStyle { ToggleSwitchStyle() }
    public static func fromTheme(): ToggleSwitchStyle { ToggleSwitchStyle(true) }
}

public class ToggleSwitch <: Widget {
    private var isChecked: Bool
    private var isHovered: Bool
    private var style: ToggleSwitchStyle
    private var thumbAnim: AnimationState
    private var onCheckedChanged: Option<(Bool) -> Unit>
    private var onClickCallback: Option<() -> Unit>
    private var layoutFrame: Option<LayoutFrame>

    public init(checked: Bool, style: ToggleSwitchStyle) {
        this.isChecked = checked
        this.isHovered = false
        this.style = style
        this.thumbAnim = AnimationState()
        this.onCheckedChanged = None<(Bool) -> Unit>
        this.onClickCallback = None<() -> Unit>
        this.layoutFrame = None
    }

    public func onClick(cb: () -> Unit): ToggleSwitch {
        this.onClickCallback = Some(cb)
        this
    }
    public func onToggle(cb: (Bool) -> Unit): ToggleSwitch {
        this.onCheckedChanged = Some(cb)
        this
    }
    public func setOnCheckedChanged(callback: (Bool) -> Unit): Unit {
        this.onCheckedChanged = Some<(Bool) -> Unit>(callback)
    }

    public func isChecked_(): Bool { isChecked }

    public func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        var x: Float32 = 0.0
        var y: Float32 = 0.0

        match (layoutFrame) {
            case Some(frame) =>
                x = frame.x; y = frame.y
            case None =>
                x = 0.0; y = 0.0
        }

        let tw: Float32 = 44.0
        let th: Float32 = 22.0
        let tr = th / 2.0
        let thumbSize: Float32 = 18.0
        let thumbPad: Float32 = 2.0
        let thumbOffX = x + thumbPad
        let thumbOnX = x + tw - thumbSize - thumbPad

        let (trackColor, trackOnColor, thumbColor) = getThemeColors()
        let bg = if (isChecked) { trackOnColor } else { trackColor }
        canvas.fillRoundedRect(x, y, tw, th, tr, bg)

        let t = if (thumbAnim.isFinished()) {
            if (isChecked) { Float32(1.0) } else { Float32(0.0) }
        } else {
            thumbAnim.getValue()
        }
        let thumbX = thumbOffX + (thumbOnX - thumbOffX) * t
        canvas.fillRoundedRect(thumbX, y + thumbPad, thumbSize, thumbSize, thumbSize / 2.0, thumbColor)
        canvas.drawRoundedRect(thumbX, y + thumbPad, thumbSize, thumbSize, thumbSize / 2.0, 1.0, bg)
    }

    private func getThemeColors(): (Color, Color, Color) {
        if (style.isThemeBased) {
            let c = Theme.colors()
            (c.toggleTrack, c.toggleTrackOn, c.toggleThumb)
        } else {
            (style.trackColor, style.trackOnColor, style.thumbColor)
        }
    }

    public func hitTest(x: Float32, y: Float32, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool {
        match (layoutFrame) {
            case Some(frame) =>
                x >= frame.x && x <= frame.x + frame.width && y >= frame.y && y <= frame.y + frame.height
            case None => false
        }
    }

    public func handleEvent(event: Event): Bool {
        match (event.eventType) {
            case EventType.MouseEnter =>
                isHovered = true; true
            case EventType.MouseLeave =>
                isHovered = false; true
            case EventType.MouseUp =>
                isChecked = !isChecked
                if (isChecked) {
                    thumbAnim.start(0.0, 1.0, 180, Easing.EaseOut)
                } else {
                    thumbAnim.start(1.0, 0.0, 180, Easing.EaseOut)
                }
                notifyChanged()
                match (onClickCallback) {
                    case Some(cb) => cb()
                    case None => ()
                }
                true
            case _ => false
        }
    }

    private func notifyChanged(): Unit {
        match (onCheckedChanged) {
            case Some(cb) => cb(isChecked)
            case None => ()
        }
    }

    public func contains(x: Float32, y: Float32): Bool { true }

    public func findLeafAt(x: Float32, y: Float32): Widget { this }

    public func updateAnimation(tickCount: Int64): Bool {
        thumbAnim.update(tickCount)
        !thumbAnim.isFinished()
    }

    public func getLayoutMinWidth(): Float32 { 44.0 }
    public func getLayoutMinHeight(): Float32 { 22.0 }
    public func setLayoutFrame(frame: LayoutFrame): Unit { this.layoutFrame = Some(frame) }
    public func clearLayoutFrame(): Unit { this.layoutFrame = None }
    public func getLayoutFrame(): Option<LayoutFrame> { layoutFrame }
}
