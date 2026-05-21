package cjform

public struct SliderStyle {
    public let trackColor: Color
    public let fillColor: Color
    public let thumbColor: Color
    public let hoverThumbColor: Color
    public let dragThumbColor: Color
    public let isThemeBased: Bool

    public init() {
        this.trackColor = Color.rgb(220, 220, 220)
        this.fillColor = Color.rgb(70, 130, 180)
        this.thumbColor = Color.WHITE
        this.hoverThumbColor = Color.rgb(240, 248, 255)
        this.dragThumbColor = Color.rgb(70, 130, 180)
        this.isThemeBased = false
    }
    
    public init(trackColor: Color, fillColor: Color, thumbColor: Color, hoverThumbColor: Color, dragThumbColor: Color) {
        this.trackColor = trackColor
        this.fillColor = fillColor
        this.thumbColor = thumbColor
        this.hoverThumbColor = hoverThumbColor
        this.dragThumbColor = dragThumbColor
        this.isThemeBased = false
    }
    
    public init(isThemeBased: Bool) {
        this.trackColor = Color.WHITE
        this.fillColor = Color.WHITE
        this.thumbColor = Color.WHITE
        this.hoverThumbColor = Color.WHITE
        this.dragThumbColor = Color.WHITE
        this.isThemeBased = isThemeBased
    }

    public static func default(): SliderStyle {
        SliderStyle()
    }
    
    public static func fromTheme(): SliderStyle {
        SliderStyle(true)
    }
    public func updateAnimation(tickCount: Int64): Bool { false }
}

public class Slider <: Widget {
    private var position: Position
    private var width: Float32
    private var sizeScale: SizeScale
    private var style: SliderStyle
    private var minValue: Float32
    private var maxValue: Float32
    private var currentValue: Float32
    private var isHovered: Bool
    private var isDragging: Bool
    private var _onValueChanged: Option<(Float32) -> Unit>
    private var layoutFrame: Option<LayoutFrame>

    public init(position: Position, width: Float32, sizeScale: SizeScale, style: SliderStyle, min: Float32, max: Float32, value: Float32) {
        this.position = position
        this.width = width
        this.sizeScale = sizeScale
        this.style = style
        this.minValue = min
        this.maxValue = max
        this.currentValue = value
        this.isHovered = false
        this.isDragging = false
        this._onValueChanged = None<(Float32) -> Unit>
        this.layoutFrame = None
    }

    public static func styled(styleName: String, position: Position, width: Float32,
        style: SliderStyle, min: Float32, max: Float32, value: Float32): Slider {
        let props = StyleSheet.getDefault().resolve(styleName)
        let sc = match (props.sizeScale) { case Some(s) => s; case None => SizeScale.scalable() }
        Slider(position, width, sc, style, min, max, value)
    }

    public func onValueChanged(cb: (Float32) -> Unit): Slider { this._onValueChanged = Some(cb); this }
    public func setOnValueChanged(callback: (Float32) -> Unit): Unit {
        this._onValueChanged = Some<(Float32) -> Unit>(callback)
    }

    public func getValue(): Float32 {
        currentValue
    }

    public func setValue(value: Float32): Unit {
        this.currentValue = value
        if (currentValue < minValue) {
            currentValue = minValue
        }
        if (currentValue > maxValue) {
            currentValue = maxValue
        }
    }

    public func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        var actualX: Float32 = 0.0
        var actualY: Float32 = 0.0
        var actualWidth: Float32 = 0.0

        match (layoutFrame) {
            case Some(frame) =>
                actualX = frame.x + frame.width / 2.0
                actualY = frame.y + frame.height / 2.0
                actualWidth = frame.width
            case None =>
                actualX = position.resolveX(initialWidth, currentWidth)
                actualY = position.resolveY(initialHeight, currentHeight)
                actualWidth = sizeScale.resolve(initialWidth, currentWidth, width)
        }

        let trackHeight: Float32 = 4.0
        let thumbRadius: Float32 = 8.0

        let trackLeft = actualX - actualWidth / 2.0
        let trackTop = actualY - trackHeight / 2.0

        let (trackColor, fillColor, thumbColor) = getThemeColors()

        canvas.fillRoundedRect(trackLeft, trackTop, actualWidth, trackHeight, trackHeight / 2.0, trackColor)

        let ratio = (currentValue - minValue) / (maxValue - minValue)
        let fillWidth = actualWidth * ratio
        canvas.fillRoundedRect(trackLeft, trackTop, fillWidth, trackHeight, trackHeight / 2.0, fillColor)

        let thumbX = trackLeft + fillWidth
        let thumbY = actualY

        canvas.fillRoundedRect(thumbX - thumbRadius, thumbY - thumbRadius, thumbRadius * 2.0, thumbRadius * 2.0, thumbRadius, thumbColor)
        canvas.drawRoundedRect(thumbX - thumbRadius, thumbY - thumbRadius, thumbRadius * 2.0, thumbRadius * 2.0, thumbRadius, 1.0, fillColor)
    }
    
    private func getThemeColors(): (Color, Color, Color) {
        if (style.isThemeBased) {
            let c = Theme.colors()
            let thumbColor = if (isDragging) {
                c.accent
            } else if (isHovered) {
                c.bgSecondary
            } else {
                c.sliderThumb
            }
            return (c.sliderTrack, c.sliderFill, thumbColor)
        }
        
        let thumbColor = if (isDragging) {
            style.dragThumbColor
        } else if (isHovered) {
            style.hoverThumbColor
        } else {
            style.thumbColor
        }
        return (style.trackColor, style.fillColor, thumbColor)
    }

    public func hitTest(x: Float32, y: Float32, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool {
        match (layoutFrame) {
            case Some(frame) =>
                x >= frame.x && x <= frame.x + frame.width && y >= frame.y && y <= frame.y + frame.height
            case None =>
                let actualX = position.resolveX(initialWidth, currentWidth)
                let actualY = position.resolveY(initialHeight, currentHeight)
                let actualWidth = sizeScale.resolve(initialWidth, currentWidth, width)
                let trackLeft = actualX - actualWidth / 2.0
                let trackRight = actualX + actualWidth / 2.0
                let trackTop = actualY - 12.0
                let trackBottom = actualY + 12.0
                x >= trackLeft && x <= trackRight && y >= trackTop && y <= trackBottom
        }
    }

    public func handleEvent(event: Event): Bool {
        match (event.eventType) {
            case EventType.MouseEnter =>
                isHovered = true
                true
            case EventType.MouseLeave =>
                isHovered = false
                isDragging = false
                true
            case EventType.MouseDown =>
                isDragging = true
                true
            case EventType.MouseUp =>
                isDragging = false
                true
            case EventType.MouseMove =>
                if (isDragging) {
                    true
                } else {
                    false
                }
            case _ => false
        }
    }

    public func handleDrag(mouseX: Float32, initialWidth: Float32, currentWidth: Float32): Unit {
        var trackLeft: Float32 = 0.0
        var dragWidth: Float32 = 0.0

        match (layoutFrame) {
            case Some(frame) =>
                trackLeft = frame.x
                dragWidth = frame.width
            case None =>
                let actualX = position.resolveX(initialWidth, currentWidth)
                dragWidth = sizeScale.resolve(initialWidth, currentWidth, width)
                trackLeft = actualX - dragWidth / 2.0
        }

        let ratio = (mouseX - trackLeft) / dragWidth

        if (ratio < 0.0) {
            currentValue = minValue
        } else if (ratio > 1.0) {
            currentValue = maxValue
        } else {
            currentValue = minValue + ratio * (maxValue - minValue)
        }

        notifyValueChanged()
    }

    private func notifyValueChanged(): Unit {
        match (_onValueChanged) {
            case Some(callback) => callback(currentValue)
            case None => ()
        }
    }

    public func contains(x: Float32, y: Float32): Bool {
        true
    }

    public func getPosition(): Position {
        position
    }

    public func setPosition(position: Position): Unit {
        this.position = position
    }

    public func getLayoutMinWidth(): Float32 {
        width
    }

    public func getLayoutMinHeight(): Float32 {
        24.0
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
    public func updateAnimation(tickCount: Int64): Bool { false }

    public func findLeafAt(x: Float32, y: Float32): Widget { this }
}
