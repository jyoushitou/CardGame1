package cjform

import std.collection.*

public struct TextBoxStyle {
    public let backgroundColor: Color
    public let focusedBackgroundColor: Color
    public let borderColor: Color
    public let focusedBorderColor: Color
    public let textColor: Color
    public let placeholderColor: Color
    public let selectionColor: Color
    public let cornerRadius: Float32
    public let borderWidth: Float32
    public let isThemeBased: Bool
    
    public init() {
        this.backgroundColor = Color.WHITE
        this.focusedBackgroundColor = Color.rgb(255, 255, 255)
        this.borderColor = Color.rgb(200, 200, 200)
        this.focusedBorderColor = Color.rgb(70, 130, 180)
        this.textColor = Color.rgb(30, 30, 30)
        this.placeholderColor = Color.rgb(150, 150, 150)
        this.selectionColor = Color.rgba(70, 130, 180, 100)
        this.cornerRadius = 4.0
        this.borderWidth = 1.0
        this.isThemeBased = false
    }
    
    public init(backgroundColor: Color, focusedBackgroundColor: Color, borderColor: Color, focusedBorderColor: Color, textColor: Color, placeholderColor: Color, selectionColor: Color, cornerRadius: Float32, borderWidth: Float32) {
        this.backgroundColor = backgroundColor
        this.focusedBackgroundColor = focusedBackgroundColor
        this.borderColor = borderColor
        this.focusedBorderColor = focusedBorderColor
        this.textColor = textColor
        this.placeholderColor = placeholderColor
        this.selectionColor = selectionColor
        this.cornerRadius = cornerRadius
        this.borderWidth = borderWidth
        this.isThemeBased = false
    }
    
    public init(isThemeBased: Bool) {
        this.backgroundColor = Color.WHITE
        this.focusedBackgroundColor = Color.WHITE
        this.borderColor = Color.WHITE
        this.focusedBorderColor = Color.WHITE
        this.textColor = Color.WHITE
        this.placeholderColor = Color.WHITE
        this.selectionColor = Color.WHITE
        this.cornerRadius = 4.0
        this.borderWidth = 1.0
        this.isThemeBased = isThemeBased
    }

    public static func default(): TextBoxStyle {
        TextBoxStyle()
    }
    
    public static func fromTheme(): TextBoxStyle {
        TextBoxStyle(true)
    }
    public func updateAnimation(tickCount: Int64): Bool { false }
}

public class TextBox <: Widget & Focusable {
    private var position: Position
    private var width: Float32
    private var height: Float32
    private var fontFamily: String
    private var fontSize: Float32
    private var sizeScale: SizeScale
    private var style: TextBoxStyle
    private var placeholder: String
    private var text: String
    private var passwordMode: Bool
    private var echoChar: Rune
    private var runes: ArrayList<Rune>
    private var cursorPos: Int64
    private var selectionStart: Int64
    private var selectionEnd: Int64
    private var isFocused: Bool
    private var isHovered: Bool
    private var isSelecting: Bool
    private var tabIndex: Int32
    private var focusId: Int64
    private var _onTextChanged: Option<(String) -> Unit>
    private var layoutFrame: Option<LayoutFrame>
    private var caretVisible: Bool
    private var awakeCaret: Bool
    private var lastBlinkTime: Int64
    private var scrollOffset: Float32
    private var parentHwnd: Option<CPointer<Byte>>

    public init(position: Position, width: Float32, height: Float32, fontFamily: String, fontSize: Float32, sizeScale: SizeScale, style: TextBoxStyle, placeholder: String) {
        this.position = position
        this.width = width
        this.height = height
        this.fontFamily = fontFamily
        this.fontSize = fontSize
        this.sizeScale = sizeScale
        this.style = style
        this.placeholder = placeholder
        this.text = ""
        this.runes = ArrayList<Rune>()
        this.cursorPos = 0
        this.selectionStart = 0
        this.selectionEnd = 0
        this.isFocused = false
        this.isHovered = false
        this.isSelecting = false
        this.tabIndex = 0
        this.focusId = nextFocusId()
        this._onTextChanged = None<(String) -> Unit>
        this.layoutFrame = None
        this.caretVisible = true
        this.awakeCaret = false
        this.lastBlinkTime = 0
        this.lastBlinkTime = 0
        this.scrollOffset = 0.0
        this.parentHwnd = None<CPointer<Byte>>
        this.passwordMode = false
        this.echoChar = r'●'
    }

    public static func styled(styleName: String, position: Position, width: Float32, height: Float32,
        style: TextBoxStyle, placeholder: String): TextBox {
        let props = StyleSheet.getDefault().resolve(styleName)
        let ff = match (props.fontFamily) { case Some(f) => f; case None => "Microsoft YaHei" }
        let fs = match (props.fontSize) { case Some(s) => s; case None => Float32(14.0) }
        let sc = match (props.sizeScale) { case Some(s) => s; case None => SizeScale.scalable() }
        TextBox(position, width, height, ff, fs, sc, style, placeholder)
    }

    public func setPasswordMode(enabled: Bool): Unit { this.passwordMode = enabled }
    public func setEchoChar(ch: Rune): Unit { this.echoChar = ch }

    public func setParentHwnd(hwnd: CPointer<Byte>): Unit {
        this.parentHwnd = Some<CPointer<Byte>>(hwnd)
    }

    public func onTextChanged(cb: (String) -> Unit): TextBox { this._onTextChanged = Some(cb); this }
    public func setOnTextChanged(callback: (String) -> Unit): Unit {
        this._onTextChanged = Some<(String) -> Unit>(callback)
    }

    public func setTabIndex(index: Int32): Unit {
        this.tabIndex = index
    }

    public func getText(): String {
        text
    }

    public func setText(text: String): Unit {
        this.text = text
        this.runes = ArrayList<Rune>()
        for (r in text.runes()) {
            this.runes.add(r)
        }
        this.cursorPos = this.runes.size
        this.scrollOffset = 0.0
        this.clearSelection()
    }

    public func isFocusable(): Bool {
        true
    }

    public func hasFocus(): Bool {
        isFocused
    }

    public func setFocus(focused: Bool): Unit {
        this.isFocused = focused
        this.showCaret()
        if (focused) {
            ensureCaretVisible()
            match (parentHwnd) {
                case Some(h) => unsafe { bridge_start_blink_timer(h, 250) }
                case None => ()
            }
        } else {
            match (parentHwnd) {
                case Some(h) => unsafe { bridge_stop_blink_timer(h) }
                case None => ()
            }
        }
    }

    public func focus(): Unit { setFocus(true) }
    public func blur(): Unit { setFocus(false) }
    public func getFocusId(): Int64 { focusId }

    public func getTabIndex(): Int32 {
        tabIndex
    }

    public func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        let now = ffi_getTickCount()
        if (awakeCaret) {
            awakeCaret = false
            lastBlinkTime = now
        } else if (now - lastBlinkTime >= 250) {
            caretVisible = !caretVisible
            lastBlinkTime = now
        }

        var left: Float32 = 0.0
        var top: Float32 = 0.0
        var actualWidth: Float32 = 0.0
        var actualHeight: Float32 = 0.0
        var actualFontSize: Float32 = 0.0

        match (layoutFrame) {
            case Some(frame) =>
                left = frame.x
                top = frame.y
                actualWidth = frame.width
                actualHeight = frame.height
                actualFontSize = fontSize
            case None =>
                let actualX = position.resolveX(initialWidth, currentWidth)
                let actualY = position.resolveY(initialHeight, currentHeight)
                actualWidth = sizeScale.resolve(initialWidth, currentWidth, width)
                actualHeight = sizeScale.resolve(initialHeight, currentHeight, height)
                actualFontSize = sizeScale.resolve(initialWidth, currentWidth, fontSize)
                left = actualX - actualWidth / 2.0
                top = actualY - actualHeight / 2.0
        }

        let (bgColor, borderColor, textColor, placeholderColor, selectionColor) = getThemeColors()

        var actualRadius: Float32 = 0.0
        match (layoutFrame) {
            case Some(_) => actualRadius = style.cornerRadius
            case None => actualRadius = sizeScale.resolve(initialWidth, currentWidth, style.cornerRadius)
        }
        canvas.fillRoundedRect(left, top, actualWidth, actualHeight, actualRadius, bgColor)

        var actualBorderWidth: Float32 = 0.0
        match (layoutFrame) {
            case Some(_) => actualBorderWidth = style.borderWidth
            case None => actualBorderWidth = sizeScale.resolve(initialWidth, currentWidth, style.borderWidth)
        }
        canvas.drawRoundedRect(left, top, actualWidth, actualHeight, actualRadius, actualBorderWidth, borderColor)

        let padding: Float32 = 8.0
        let textLeft = left + padding
        let textRight = left + actualWidth - padding
        let textClipW = actualWidth - padding * 2.0

        canvas.pushClip(textLeft, top, textClipW, actualHeight)

        let displayText = if (passwordMode && text.size > 0) {
            var runeCount: Int64 = 0
            for (_ in text.runes()) { runeCount = runeCount + 1 }
            let masked = ArrayList<Rune>()
            for (_ in 0..runeCount) { masked.add(echoChar) }
            String(masked)
        } else { text }

        if (text.size == 0 && !isFocused) {
            canvas.drawTextAligned(textLeft, top, textClipW, actualHeight, placeholder, fontFamily, actualFontSize, 0, placeholderColor)
        } else {
            if (scrollOffset < 0.0) {
                scrollOffset = 0.0
            }

            if (isFocused) {
                ensureCaretVisible()
            }

            let drawX = textLeft - scrollOffset

            if (hasSelection() && !passwordMode) {
                let selLow = getSelectionLow()
                let selHigh = getSelectionHigh()
                let selLeft = textLeft - scrollOffset + measureTextUpTo(selLow, actualFontSize)
                let selTop = top + (actualHeight - actualFontSize) / 2.0
                let selW = measureTextUpTo(selHigh, actualFontSize) - measureTextUpTo(selLow, actualFontSize)
                canvas.fillRect(selLeft, selTop, selW, actualFontSize, selectionColor)
            }

            canvas.drawTextAligned(drawX, top, 9999.0, actualHeight, displayText, fontFamily, actualFontSize, 0, textColor)
        }

        canvas.popClip()

        if (isFocused && caretVisible) {
            let caretX = textLeft - scrollOffset + measureTextUpTo(cursorPos, actualFontSize)
            let caretY = top + (actualHeight - actualFontSize) / 2.0
            canvas.drawLine(caretX, caretY, caretX, caretY + actualFontSize, 1.0, textColor)
        }
    }
    
    private func getThemeColors(): (Color, Color, Color, Color, Color) {
        if (style.isThemeBased) {
            let c = Theme.colors()
            let bgColor = c.inputBg
            let borderColor = if (isFocused) { c.borderFocused } else { c.inputBorder }
            let selectionColor = Color.rgba(c.accent.r, c.accent.g, c.accent.b, 100)
            return (bgColor, borderColor, c.textPrimary, c.inputPlaceholder, selectionColor)
        }
        
        let bgColor = if (isFocused) { style.focusedBackgroundColor } else { style.backgroundColor }
        let borderColor = if (isFocused) { style.focusedBorderColor } else { style.borderColor }
        return (bgColor, borderColor, style.textColor, style.placeholderColor, style.selectionColor)
    }

    private func showCaret(): Unit {
        caretVisible = true
        awakeCaret = true
    }

    private func measureTextWidth(text: String, fs: Float32, runeCount: Int64): Float32 {
        if (runeCount == 0) { return 0.0 }
        match (parentHwnd) {
            case Some(h) => let (w, _) = ffi_measureText(h, text, fontFamily, fs); w
            case None => fs * 0.6 * Float32(runeCount)
        }
    }

    private func measureTextUpTo(index: Int64, fs: Float32): Float32 {
        if (index <= 0) { return 0.0 }
        if (text.size == 0) { return 0.0 }
        match (parentHwnd) {
            case Some(h) => ffi_measureTextRange(h, text, Int32(index), fontFamily, fs)
            case None => fs * 0.6 * Float32(index)
        }
    }

    private func findCursorAtX(relX: Float32, fs: Float32): Int64 {
        if (relX <= 0.0) { return 0 }
        if (runes.size == 0) { return 0 }
        let fullWidth = measureTextUpTo(runes.size, fs)
        if (relX >= fullWidth) { return runes.size }
        var lo: Int64 = 0
        var hi: Int64 = runes.size
        while (lo < hi) {
            let mid = lo + (hi - lo) / 2
            let midWidth = measureTextUpTo(mid, fs)
            if (midWidth < relX) {
                lo = mid + 1
            } else {
                hi = mid
            }
        }
        if (lo > 0) {
            let loWidth = measureTextUpTo(lo, fs)
            let lo1Width = measureTextUpTo(lo - 1, fs)
            if (relX - lo1Width < loWidth - relX) {
                lo = lo - 1
            }
        }
        lo
    }

    private func ensureCaretVisible(): Unit {
        let caretX = measureTextUpTo(cursorPos, fontSize)

        var boxWidth: Float32 = width
        match (layoutFrame) {
            case Some(f) => boxWidth = f.width
            case None => ()
        }
        let padding: Float32 = 8.0
        let visibleWidth = boxWidth - padding * 2.0
        let approxCharWidth = fontSize * 0.6

        if (caretX < scrollOffset) {
            scrollOffset = caretX - approxCharWidth * 2.0
        } else if (caretX > scrollOffset + visibleWidth) {
            scrollOffset = caretX - visibleWidth + approxCharWidth * 2.0
        }

        let maxScroll = measureTextUpTo(runes.size, fontSize) - visibleWidth + approxCharWidth
        if (maxScroll < 0.0) {
            scrollOffset = 0.0
        } else if (scrollOffset > maxScroll) {
            scrollOffset = maxScroll
        }
        if (scrollOffset < 0.0) {
            scrollOffset = 0.0
        }
    }

    private func hasSelection(): Bool {
        selectionStart != selectionEnd
    }

    private func clearSelection(): Unit {
        selectionStart = cursorPos
        selectionEnd = cursorPos
    }

    private func getSelectionLow(): Int64 {
        if (selectionStart < selectionEnd) { selectionStart } else { selectionEnd }
    }

    private func getSelectionHigh(): Int64 {
        if (selectionStart > selectionEnd) { selectionStart } else { selectionEnd }
    }

    private func positionCursor(mouseX: Float32): Unit {
        var left: Float32 = 0.0
        match (layoutFrame) {
            case Some(f) => left = f.x
            case None => left = position.x - width / 2.0
        }
        let padding: Float32 = 8.0
        let textLeft = left + padding
        let relX = mouseX - textLeft + scrollOffset
        cursorPos = findCursorAtX(relX, fontSize)
        showCaret()
    }

    public func hitTest(x: Float32, y: Float32, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool {
        var left: Float32 = 0.0
        var right: Float32 = 0.0
        var top: Float32 = 0.0
        var bottom: Float32 = 0.0
        match (layoutFrame) {
            case Some(frame) =>
                left = frame.x
                right = frame.x + frame.width
                top = frame.y
                bottom = frame.y + frame.height
            case None =>
                let actualX = position.resolveX(initialWidth, currentWidth)
                let actualY = position.resolveY(initialHeight, currentHeight)
                let actualWidth = sizeScale.resolve(initialWidth, currentWidth, width)
                let actualHeight = sizeScale.resolve(initialHeight, currentHeight, height)
                left = actualX - actualWidth / 2.0
                right = actualX + actualWidth / 2.0
                top = actualY - actualHeight / 2.0
                bottom = actualY + actualHeight / 2.0
        }
        x >= left && x <= right && y >= top && y <= bottom
    }

    public func handleEvent(event: Event): Bool {
        match (event.eventType) {
            case EventType.MouseEnter =>
                isHovered = true
                true
            case EventType.MouseLeave =>
                isHovered = false
                isSelecting = false
                true
            case EventType.MouseDown =>
                handleMouseDown(event)
            case EventType.MouseUp =>
                isSelecting = false
                true
            case EventType.MouseMove =>
                handleMouseMove(event)
            case EventType.FocusGain =>
                isFocused = true
                showCaret()
                true
            case EventType.FocusLost =>
                isFocused = false
                clearSelection()
                true
            case EventType.KeyDown =>
                handleKeyDown(event)
            case EventType.KeyChar =>
                handleKeyChar(event)
            case _ => false
        }
    }

    private func handleMouseDown(event: Event): Bool {
        match (event.mouseEvent) {
            case Some(me) =>
                positionCursor(me.x)
                clearSelection()
                isSelecting = true
                true
            case None => true
        }
    }

    private func handleMouseMove(event: Event): Bool {
        if (!isSelecting) { return false }
        match (event.mouseEvent) {
            case Some(me) =>
                var left: Float32 = 0.0
                match (layoutFrame) {
                    case Some(f) => left = f.x
                    case None => left = position.x - width / 2.0
                }
                let padding: Float32 = 8.0
                let textLeft = left + padding
                let relX = me.x - textLeft + scrollOffset
                cursorPos = findCursorAtX(relX, fontSize)
                showCaret()
                ensureCaretVisible()
                true
            case None => false
        }
    }

    private func handleKeyDown(event: Event): Bool {
        if (event.hasAlt) {
            return false
        }
        match (event.keyEvent) {
            case Some(ke) =>
                let vkA: UInt32 = 65
                let vkC: UInt32 = 67
                let vkV: UInt32 = 86
                let vkX: UInt32 = 88

                if (event.hasCtrl) {
                    if (ke.keyCode == vkA) {
                        selectAll()
                        return true
                    } else if (ke.keyCode == vkC) {
                        copyToClipboard()
                        return true
                    } else if (ke.keyCode == vkV) {
                        pasteFromClipboard()
                        return true
                    } else if (ke.keyCode == vkX) {
                        cutToClipboard()
                        return true
                    }
                }

                let vkBack: UInt32 = 8
                let vkDelete: UInt32 = 46
                let vkLeft: UInt32 = 37
                let vkRight: UInt32 = 39
                let vkHome: UInt32 = 36
                let vkEnd: UInt32 = 35

                if (ke.keyCode == vkBack) {
                    handleBackspace()
                    true
                } else if (ke.keyCode == vkDelete) {
                    handleDelete()
                    true
                } else if (ke.keyCode == vkLeft) {
                    handleLeftArrow(event.hasShift)
                } else if (ke.keyCode == vkRight) {
                    handleRightArrow(event.hasShift)
                } else if (ke.keyCode == vkHome) {
                    if (event.hasShift) {
                        selectionEnd = cursorPos
                        cursorPos = 0
                        selectionStart = 0
                    } else {
                        cursorPos = 0
                        clearSelection()
                    }
                    showCaret()
                    ensureCaretVisible()
                    true
                } else if (ke.keyCode == vkEnd) {
                    if (event.hasShift) {
                        selectionStart = cursorPos
                        cursorPos = runes.size
                        selectionEnd = runes.size
                    } else {
                        cursorPos = runes.size
                        clearSelection()
                    }
                    showCaret()
                    ensureCaretVisible()
                    true
                } else {
                    false
                }
            case None => false
        }
    }

    private func handleBackspace(): Unit {
        if (hasSelection()) {
            deleteSelection()
        } else if (cursorPos > 0) {
            runes = removeRuneAt(runes, cursorPos - 1)
            cursorPos = cursorPos - 1
            updateText()
        }
        showCaret()
        ensureCaretVisible()
    }

    private func handleDelete(): Unit {
        if (hasSelection()) {
            deleteSelection()
        } else if (cursorPos < runes.size) {
            runes = removeRuneAt(runes, cursorPos)
            updateText()
        }
        showCaret()
        ensureCaretVisible()
    }

    private func removeRuneAt(list: ArrayList<Rune>, index: Int64): ArrayList<Rune> {
        let newList = ArrayList<Rune>()
        var i: Int64 = 0
        for (r in list) {
            if (i != index) {
                newList.add(r)
            }
            i = i + 1
        }
        newList
    }

    private func handleLeftArrow(hasShift: Bool): Bool {
        if (hasShift) {
            if (cursorPos == selectionEnd && cursorPos == selectionStart) {
                selectionStart = cursorPos
            }
            if (cursorPos > 0) {
                cursorPos = cursorPos - 1
            }
            selectionEnd = cursorPos
        } else {
            if (hasSelection()) {
                cursorPos = getSelectionLow()
            } else if (cursorPos > 0) {
                cursorPos = cursorPos - 1
            }
            clearSelection()
        }
        showCaret()
        ensureCaretVisible()
        true
    }

    private func handleRightArrow(hasShift: Bool): Bool {
        if (hasShift) {
            if (cursorPos == selectionEnd && cursorPos == selectionStart) {
                selectionStart = cursorPos
            }
            if (cursorPos < runes.size) {
                cursorPos = cursorPos + 1
            }
            selectionEnd = cursorPos
        } else {
            if (hasSelection()) {
                cursorPos = getSelectionHigh()
            } else if (cursorPos < runes.size) {
                cursorPos = cursorPos + 1
            }
            clearSelection()
        }
        showCaret()
        ensureCaretVisible()
        true
    }

    private func deleteSelection(): Unit {
        let selLow = getSelectionLow()
        let selHigh = getSelectionHigh()

        var newRunes = ArrayList<Rune>()
        for (i in 0..selLow) {
            newRunes.add(runes[Int64(i)])
        }
        for (i in selHigh..runes.size) {
            newRunes.add(runes[Int64(i)])
        }

        runes = newRunes
        cursorPos = selLow
        clearSelection()
        updateText()
    }

    private func copyToClipboard(): Unit {
        let selected = getSelectedText()
        if (selected.size > 0) {
            ffi_clipboardSetText(selected)
        }
    }

    private func cutToClipboard(): Unit {
        copyToClipboard()
        deleteSelection()
    }

    private func pasteFromClipboard(): Unit {
        let clipText = ffi_clipboardGetText()
        if (clipText.size > 0) {
            if (hasSelection()) {
                deleteSelection()
            }
            for (r in clipText.runes()) {
                if (r == r'\r' || r == r'\n') { break }
                runes = insertRuneAt(runes, r, cursorPos)
                cursorPos = cursorPos + 1
            }
            updateText()
            showCaret()
            ensureCaretVisible()
        }
    }

    private func handleKeyChar(event: Event): Bool {
        if (event.hasCtrl || event.hasAlt) {
            return false
        }
        match (event.keyEvent) {
            case Some(ke) =>
                let ch = ke.keyChar
                if (ch >= r' ' && ch != r'\t' && ch != r'\b') {
                    if (hasSelection()) {
                        deleteSelection()
                    }
                    runes = insertRuneAt(runes, ch, cursorPos)
                    cursorPos = cursorPos + 1
                    updateText()
                    showCaret()
                    ensureCaretVisible()
                    true
                } else {
                    false
                }
            case None => false
        }
    }

    private func insertRuneAt(list: ArrayList<Rune>, r: Rune, index: Int64): ArrayList<Rune> {
        let newList = ArrayList<Rune>()
        var i: Int64 = 0
        for (item in list) {
            if (i == index) {
                newList.add(r)
            }
            newList.add(item)
            i = i + 1
        }
        if (i == index) {
            newList.add(r)
        }
        newList
    }

    private func updateText(): Unit {
        text = String(runes)
        notifyTextChanged()
    }

    private func notifyTextChanged(): Unit {
        match (_onTextChanged) {
            case Some(callback) => callback(text)
            case None => ()
        }
    }

    public func selectAll(): Unit {
        selectionStart = 0
        selectionEnd = runes.size
        cursorPos = runes.size
        showCaret()
    }

    public func getSelectedText(): String {
        if (!hasSelection()) {
            return ""
        }
        let selLow = getSelectionLow()
        let selHigh = getSelectionHigh()
        let selectedRunes = ArrayList<Rune>()
        for (i in selLow..selHigh) {
            selectedRunes.add(runes[Int64(i)])
        }
        String(selectedRunes)
    }

    public func insertText(newText: String): Unit {
        if (hasSelection()) {
            deleteSelection()
        }
        for (r in newText.runes()) {
            runes = insertRuneAt(runes, r, cursorPos)
            cursorPos = cursorPos + 1
        }
        updateText()
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
        height
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
