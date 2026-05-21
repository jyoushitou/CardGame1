package cjform

import std.collection.*

public struct SpinBoxStyle {
    public let backgroundColor: Color
    public let focusedBorderColor: Color
    public let borderColor: Color
    public let textColor: Color
    public let caretColor: Color
    public let buttonColor: Color
    public let buttonHoverColor: Color
    public let buttonPressedColor: Color
    public let arrowColor: Color
    public let cornerRadius: Float32
    public let borderWidth: Float32
    public let isThemeBased: Bool

    public init() {
        this.backgroundColor = Color.WHITE
        this.focusedBorderColor = Color.WHITE
        this.borderColor = Color.WHITE
        this.textColor = Color.WHITE
        this.caretColor = Color.WHITE
        this.buttonColor = Color.WHITE
        this.buttonHoverColor = Color.WHITE
        this.buttonPressedColor = Color.WHITE
        this.arrowColor = Color.WHITE
        this.cornerRadius = 4.0
        this.borderWidth = 1.0
        this.isThemeBased = false
    }

    public init(backgroundColor: Color, focusedBorderColor: Color, borderColor: Color,
        textColor: Color, caretColor: Color, buttonColor: Color, buttonHoverColor: Color,
        buttonPressedColor: Color, arrowColor: Color, cornerRadius: Float32, borderWidth: Float32) {
        this.backgroundColor = backgroundColor
        this.focusedBorderColor = focusedBorderColor
        this.borderColor = borderColor
        this.textColor = textColor
        this.caretColor = caretColor
        this.buttonColor = buttonColor
        this.buttonHoverColor = buttonHoverColor
        this.buttonPressedColor = buttonPressedColor
        this.arrowColor = arrowColor
        this.cornerRadius = cornerRadius
        this.borderWidth = borderWidth
        this.isThemeBased = false
    }

    public init(isThemeBased: Bool) {
        this.backgroundColor = Color.WHITE
        this.focusedBorderColor = Color.WHITE
        this.borderColor = Color.WHITE
        this.textColor = Color.WHITE
        this.caretColor = Color.WHITE
        this.buttonColor = Color.WHITE
        this.buttonHoverColor = Color.WHITE
        this.buttonPressedColor = Color.WHITE
        this.arrowColor = Color.WHITE
        this.cornerRadius = 4.0
        this.borderWidth = 1.0
        this.isThemeBased = isThemeBased
    }

    public static func fromTheme(): SpinBoxStyle { SpinBoxStyle(true) }
}

public class SpinBox <: Widget & Focusable {
    private var style: SpinBoxStyle
    private var value: Float32
    private var minValue: Float32
    private var maxValue: Float32
    private var step: Float32
    private var isIntMode: Bool
    private var isHovered: Bool
    private var isFocused: Bool
    private var focusId: Int64
    private var hoverZone: Int32
    private var pressedZone: Int32
    private var repeatTimer: Int64
    private var repeatInterval: Int64
    private var layoutFrame: Option<LayoutFrame>
    private var _onValueChanged: Option<(Float32) -> Unit>
    private var isEditing: Bool
    private var editBuffer: String
    private var caretVisible: Bool
    private var lastBlinkTime: Int64

    public init(minV: Float32, maxV: Float32, initialV: Float32, step: Float32, isInt: Bool) {
        this.style = SpinBoxStyle.fromTheme()
        this.minValue = minV
        this.maxValue = maxV
        this.value = initialV
        this.step = step
        this.isIntMode = isInt
        this.isHovered = false
        this.isFocused = false
        this.focusId = nextFocusId()
        this.hoverZone = 0
        this.pressedZone = 0
        this.repeatTimer = 0
        this.repeatInterval = 80
        this.layoutFrame = None
        this._onValueChanged = None<(Float32) -> Unit>
        this.isEditing = false
        this.editBuffer = ""
        this.caretVisible = true
        this.lastBlinkTime = 0
    }

    public init(minV: Float32, maxV: Float32, initialV: Float32, step: Float32, isInt: Bool, style: SpinBoxStyle) {
        this.style = style
        this.minValue = minV
        this.maxValue = maxV
        this.value = initialV
        this.step = step
        this.isIntMode = isInt
        this.isHovered = false
        this.isFocused = false
        this.focusId = nextFocusId()
        this.hoverZone = 0
        this.pressedZone = 0
        this.repeatTimer = 0
        this.repeatInterval = 80
        this.layoutFrame = None
        this._onValueChanged = None<(Float32) -> Unit>
        this.isEditing = false
        this.editBuffer = ""
        this.caretVisible = true
        this.lastBlinkTime = 0
    }

    public static func styled(styleName: String, minV: Float32, maxV: Float32,
        initialV: Float32, step: Float32, isInt: Bool): SpinBox {
        SpinBox(minV, maxV, initialV, step, isInt, SpinBoxStyle.fromTheme())
    }

    public func onValueChanged(cb: (Float32) -> Unit): SpinBox { this._onValueChanged = Some(cb); this }
    public func setOnValueChanged(cb: (Float32) -> Unit): Unit { this._onValueChanged = Some(cb) }

    public func focus(): Unit { isFocused = true }
    public func blur(): Unit { isFocused = false; if (isEditing) { commitEditing() } }
    public func hasFocus(): Bool { isFocused }
    public func getFocusId(): Int64 { focusId }
    public func getValue(): Float32 { value }

    private func formatValue(): String {
        if (isEditing) { return editBuffer }
        if (isIntMode) { Int64(value).toString() } else { value.toString() }
    }

    private func getBgColor(): Color { if (style.isThemeBased) { Theme.colors().inputBg } else { style.backgroundColor } }
    private func getBorderColor(): Color {
        if (style.isThemeBased) {
            if (isFocused || isEditing) { Theme.colors().borderFocused } else { Theme.colors().inputBorder }
        } else {
            if (isFocused || isEditing) { style.focusedBorderColor } else { style.borderColor }
        }
    }
    private func getTextColor(): Color { if (style.isThemeBased) { Theme.colors().textPrimary } else { style.textColor } }
    private func getCaretColor(): Color { if (style.isThemeBased) { Theme.colors().accent } else { style.caretColor } }
    private func getButtonBg(z: Int32): Color {
        if (style.isThemeBased) {
            if (pressedZone == z) { Theme.colors().buttonPressed }
            else if (hoverZone == z) { Theme.colors().buttonHover }
            else { Theme.colors().bgTertiary }
        } else {
            if (pressedZone == z) { style.buttonPressedColor }
            else if (hoverZone == z) { style.buttonHoverColor }
            else { style.buttonColor }
        }
    }
    private func getArrowColor(): Color { if (style.isThemeBased) { Theme.colors().textSecondary } else { style.arrowColor } }
    private func getSeparatorColor(): Color { if (style.isThemeBased) { Theme.colors().inputBorder } else { style.borderColor } }

    public func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        let (x, y, w, h) = getFrame()
        let btnW = h

        let now = unsafe { bridge_get_tick_count() }
        if (now - lastBlinkTime >= 250) {
            caretVisible = !caretVisible
            lastBlinkTime = now
        }

        canvas.fillRoundedRect(x, y, w, h, style.cornerRadius, getBgColor())
        canvas.drawRoundedRect(x, y, w, h, style.cornerRadius, style.borderWidth, getBorderColor())

        let textX = x + Float32(8.0)
        let textW = w - btnW - Float32(16.0)
        canvas.drawTextAligned(textX, y, textW, h, formatValue(), "Microsoft YaHei", Float32(13.0), 0, getTextColor())
        if (isEditing && caretVisible) {
            let caretX = textX + canvas.measureTextWidth(editBuffer, "Microsoft YaHei", Float32(13.0))
            canvas.drawLine(caretX, y + Float32(4.0), caretX, y + h - Float32(4.0), Float32(1.0), getCaretColor())
        }
        let upBg = getButtonBg(1)
        canvas.fillRoundedRect(x + w - btnW, y, btnW, h / Float32(2.0), Float32(0.0), upBg)
        let cx = x + w - btnW / Float32(2.0)
        let cy = y + h / Float32(4.0)
        let arrowC = getArrowColor()
        canvas.drawLine(cx - Float32(4.0), cy + Float32(2.0), cx, cy - Float32(2.0), Float32(1.5), arrowC)
        canvas.drawLine(cx, cy - Float32(2.0), cx + Float32(4.0), cy + Float32(2.0), Float32(1.5), arrowC)
        let dnBg = getButtonBg(2)
        canvas.fillRoundedRect(x + w - btnW, y + h / Float32(2.0), btnW, h / Float32(2.0), Float32(0.0), dnBg)
        let cy2 = y + h * Float32(3.0) / Float32(4.0)
        canvas.drawLine(cx - Float32(4.0), cy2 - Float32(2.0), cx, cy2 + Float32(2.0), Float32(1.5), arrowC)
        canvas.drawLine(cx, cy2 + Float32(2.0), cx + Float32(4.0), cy2 - Float32(2.0), Float32(1.5), arrowC)
        canvas.drawLine(x + w - btnW, y + Float32(2.0), x + w - btnW, y + h - Float32(2.0), Float32(1.0), getSeparatorColor())
    }

    public func hitTest(x: Float32, y: Float32, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool {
        match (layoutFrame) { case Some(f) => x >= f.x && x <= f.x + f.width && y >= f.y && y <= f.y + f.height; case None => false }
    }

    public func handleEvent(event: Event): Bool {
        if (isEditing) {
            return handleEditingEvent(event)
        }
        match (event.eventType) {
            case EventType.MouseEnter => isHovered = true; true
            case EventType.MouseLeave => isHovered = false; hoverZone = 0; pressedZone = 0; true
            case EventType.MouseDown =>
                match (event.mouseEvent) {
                    case Some(me) =>
                        let (x, y, w, h) = getFrame()
                        let btnW = h
                        if (me.x >= x + w - btnW) {
                            if (me.y <= y + h / Float32(2.0)) { pressedZone = 1; stepUp(); repeatTimer = unsafe { bridge_get_tick_count() } }
                            else { pressedZone = 2; stepDown(); repeatTimer = unsafe { bridge_get_tick_count() } }
                        } else {
                            startEditing()
                        }
                        true
                    case None => false
                }
            case EventType.MouseUp => pressedZone = 0; true
            case EventType.MouseMove =>
                match (event.mouseEvent) {
                    case Some(me) =>
                        let (fx, fy, vw, vh) = getFrame()
                        let btnW = vh
                        if (me.x >= fx + vw - btnW) {
                            hoverZone = if (me.y <= fy + vh / Float32(2.0)) { 1 } else { 2 }
                        } else {
                            hoverZone = 3
                        }
                        if (pressedZone != 0) {
                            let now = unsafe { bridge_get_tick_count() }
                            if (now - repeatTimer >= repeatInterval) {
                                if (pressedZone == 1) { stepUp() } else { stepDown() }
                                repeatTimer = now
                            }
                        }
                        true
                    case None => false
                }
            case EventType.FocusGain => isFocused = true; true
            case EventType.FocusLost => isFocused = false; true
            case EventType.MouseWheel =>
                match (event.mouseWheelEvent) {
                    case Some(we) =>
                        if (we.delta > 0) { stepUp() } else { stepDown() }
                        true
                    case None => false
                }
            case EventType.KeyDown =>
                match (event.keyEvent) {
                    case Some(ke) =>
                        let vkUp: UInt32 = 38; let vkDown: UInt32 = 40
                        if (ke.keyCode == vkUp) { stepUp(); true }
                        else if (ke.keyCode == vkDown) { stepDown(); true }
                        else { false }
                    case None => false
                }
            case _ => false
        }
    }

    private func startEditing(): Unit {
        isEditing = true
        editBuffer = formatValue()
        caretVisible = true
        lastBlinkTime = unsafe { bridge_get_tick_count() }
    }

    private func commitEditing(): Unit {
        isEditing = false
        if (editBuffer.size > 0) {
            let newVal = parseFloat(editBuffer)
            if (newVal >= minValue && newVal <= maxValue) {
                value = if (isIntMode) { Float32(Int64(newVal)) } else { newVal }
                notifyChanged()
            }
        }
        editBuffer = ""
    }

    private func cancelEditing(): Unit {
        isEditing = false
        editBuffer = ""
    }

    private func parseFloat(s: String): Float32 {
        var result: Float32 = 0.0
        var isNeg = false
        var decimalDiv: Float32 = 0.0
        var idx: Int64 = 0
        let runes = toRunes(s)
        if (runes.size > 0 && runes[0] == r'-') {
            isNeg = true
            idx = 1
        }
        while (idx < Int64(runes.size)) {
            let r = runes[Int64(idx)]
            if (r == r'.' && decimalDiv == 0.0) {
                decimalDiv = 1.0
            } else if (r == r'0') {
                if (decimalDiv > 0.0) { decimalDiv = decimalDiv * 10.0; result = result }
                else { result = result * 10.0 }
            } else if (r == r'1') {
                if (decimalDiv > 0.0) { decimalDiv = decimalDiv * 10.0; result = result + Float32(1.0) / decimalDiv }
                else { result = result * 10.0 + Float32(1.0) }
            } else if (r == r'2') {
                if (decimalDiv > 0.0) { decimalDiv = decimalDiv * 10.0; result = result + Float32(2.0) / decimalDiv }
                else { result = result * 10.0 + Float32(2.0) }
            } else if (r == r'3') {
                if (decimalDiv > 0.0) { decimalDiv = decimalDiv * 10.0; result = result + Float32(3.0) / decimalDiv }
                else { result = result * 10.0 + Float32(3.0) }
            } else if (r == r'4') {
                if (decimalDiv > 0.0) { decimalDiv = decimalDiv * 10.0; result = result + Float32(4.0) / decimalDiv }
                else { result = result * 10.0 + Float32(4.0) }
            } else if (r == r'5') {
                if (decimalDiv > 0.0) { decimalDiv = decimalDiv * 10.0; result = result + Float32(5.0) / decimalDiv }
                else { result = result * 10.0 + Float32(5.0) }
            } else if (r == r'6') {
                if (decimalDiv > 0.0) { decimalDiv = decimalDiv * 10.0; result = result + Float32(6.0) / decimalDiv }
                else { result = result * 10.0 + Float32(6.0) }
            } else if (r == r'7') {
                if (decimalDiv > 0.0) { decimalDiv = decimalDiv * 10.0; result = result + Float32(7.0) / decimalDiv }
                else { result = result * 10.0 + Float32(7.0) }
            } else if (r == r'8') {
                if (decimalDiv > 0.0) { decimalDiv = decimalDiv * 10.0; result = result + Float32(8.0) / decimalDiv }
                else { result = result * 10.0 + Float32(8.0) }
            } else if (r == r'9') {
                if (decimalDiv > 0.0) { decimalDiv = decimalDiv * 10.0; result = result + Float32(9.0) / decimalDiv }
                else { result = result * 10.0 + Float32(9.0) }
            }
            idx = idx + 1
        }
        if (isNeg) { Float32(0.0) - result } else { result }
    }

    private func toRunes(s: String): ArrayList<Rune> {
        let result = ArrayList<Rune>()
        for (r in s.runes()) { result.add(r) }
        result
    }

    private func handleEditingEvent(event: Event): Bool {
        match (event.eventType) {
            case EventType.MouseDown =>
                match (event.mouseEvent) {
                    case Some(me) =>
                        let (x, y, w, h) = getFrame()
                        let btnW = h
                        if (me.x >= x + w - btnW) {
                            commitEditing()
                            if (me.y <= y + h / Float32(2.0)) { stepUp() }
                            else { stepDown() }
                        }
                        true
                    case None => false
                }
            case EventType.KeyDown =>
                match (event.keyEvent) {
                    case Some(ke) =>
                        let vkEnter: UInt32 = 13; let vkEsc: UInt32 = 27
                        let vkBack: UInt32 = 8; let vkDelete: UInt32 = 46
                        let vkUp: UInt32 = 38; let vkDown: UInt32 = 40
                        if (ke.keyCode == vkEnter) { commitEditing(); true }
                        else if (ke.keyCode == vkEsc) { cancelEditing(); true }
                        else if (ke.keyCode == vkBack) {
                            if (editBuffer.size > 0) {
                                let runes = toRunes(editBuffer)
                                let newRunes = ArrayList<Rune>()
                                for (i in 0..(runes.size - 1)) { newRunes.add(runes[Int64(i)]) }
                                editBuffer = String(newRunes)
                            }
                            caretVisible = true; lastBlinkTime = unsafe { bridge_get_tick_count() }; true
                        } else if (ke.keyCode == vkUp) { commitEditing(); stepUp(); true }
                        else if (ke.keyCode == vkDown) { commitEditing(); stepDown(); true }
                        else { false }
                    case None => false
                }
            case EventType.KeyChar =>
                if (event.hasCtrl || event.hasAlt) { return false }
                match (event.keyEvent) {
                    case Some(ke) =>
                        let ch = ke.keyChar
                        let valid = (ch >= r'0' && ch <= r'9') || ch == r'-' || ch == r'.'
                        if (valid) {
                            if (ch == r'-') {
                                if (editBuffer.size > 0) { return true }
                                if (minValue >= Float32(0.0)) { return true }
                            }
                            if (ch == r'.') {
                                if (isIntMode) { return true }
                                for (r in editBuffer.runes()) { if (r == r'.') { return true } }
                            }
                            let runes = toRunes(editBuffer)
                            runes.add(ch)
                            editBuffer = String(runes)
                            caretVisible = true; lastBlinkTime = unsafe { bridge_get_tick_count() }
                            true
                        } else { false }
                    case None => false
                }
            case EventType.FocusLost => commitEditing(); true
            case _ => false
        }
    }

    private func stepUp(): Unit {
        let newVal = value + step
        if (newVal <= maxValue) { value = newVal } else { value = maxValue }
        editBuffer = ""
        notifyChanged()
    }

    private func stepDown(): Unit {
        let newVal = value - step
        if (newVal >= minValue) { value = newVal } else { value = minValue }
        editBuffer = ""
        notifyChanged()
    }

    private func notifyChanged(): Unit {
        match (_onValueChanged) { case Some(cb) => cb(value); case None => () }
    }

    private func getFrame(): (Float32, Float32, Float32, Float32) {
        match (layoutFrame) { case Some(f) => (f.x, f.y, f.width, f.height); case None => (Float32(0.0), Float32(0.0), Float32(100.0), Float32(28.0)) }
    }

    public func contains(x: Float32, y: Float32): Bool { true }
    public func updateAnimation(tickCount: Int64): Bool { false }
    public func findLeafAt(x: Float32, y: Float32): Widget { this }
    public func getLayoutMinWidth(): Float32 { Float32(100.0) }
    public func getLayoutMinHeight(): Float32 { Float32(28.0) }
    public func setLayoutFrame(frame: LayoutFrame): Unit { this.layoutFrame = Some(frame) }
    public func clearLayoutFrame(): Unit { this.layoutFrame = None }
    public func getLayoutFrame(): Option<LayoutFrame> { layoutFrame }
}
