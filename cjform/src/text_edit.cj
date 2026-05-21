package cjform

import std.collection.*

public struct TextEditStyle {
    public let backgroundColor: Color
    public let textColor: Color
    public let selectionColor: Color
    public let cursorColor: Color
    public let borderColor: Color
    public let focusedBorderColor: Color
    public let cornerRadius: Float32
    public let borderWidth: Float32
    public let isThemeBased: Bool

    public init() {
        this.backgroundColor = Color.WHITE
        this.textColor = Color.rgb(30, 30, 30)
        this.selectionColor = Color.rgba(70, 130, 180, 100)
        this.cursorColor = Color.rgb(30, 30, 30)
        this.borderColor = Color.rgb(200, 200, 200)
        this.focusedBorderColor = Color.rgb(70, 130, 180)
        this.cornerRadius = 4.0
        this.borderWidth = 1.0
        this.isThemeBased = false
    }

    public init(isThemeBased: Bool) {
        this.backgroundColor = Color.WHITE
        this.textColor = Color.WHITE
        this.selectionColor = Color.WHITE
        this.cursorColor = Color.WHITE
        this.borderColor = Color.WHITE
        this.focusedBorderColor = Color.WHITE
        this.cornerRadius = 4.0
        this.borderWidth = 1.0
        this.isThemeBased = isThemeBased
    }

    public static func fromTheme(): TextEditStyle { TextEditStyle(true) }
    public func updateAnimation(tickCount: Int64): Bool { false }
}

enum UndoOpType {
    | Insert
    | Delete
}

class UndoEntry {
    public let row: Int64
    public let col: Int64
    public let text: String
    public let opType: UndoOpType

    public init(opType: UndoOpType, row: Int64, col: Int64, text: String) {
        this.opType = opType
        this.row = row
        this.col = col
        this.text = text
    }
}

class VisualLine {
    public let sourceRow: Int64
    public let sourceStartCol: Int64
    public let text: String
    public init(sourceRow: Int64, sourceStartCol: Int64, text: String) {
        this.sourceRow = sourceRow; this.sourceStartCol = sourceStartCol; this.text = text
    }
}

public class TextEdit <: Widget & Focusable {
    private var lines: ArrayList<String>
    private var cursorRow: Int64
    private var cursorCol: Int64
    private var selStartRow: Int64
    private var selStartCol: Int64
    private var selEndRow: Int64
    private var selEndCol: Int64
    private var fontFamily: String
    private var fontSize: Float32
    private var style: TextEditStyle
    private var lineHeight: Float32
    private var avgCharW: Float32
    private var padding: Float32
    private var wordWrap: Bool
    private var isFocused: Bool
    private var isHovered: Bool
    private var isSelecting: Bool
    private var caretVisible: Bool
    private var lastBlinkTime: Int64
    private var scrollY: Float32
    private var targetScrollY: Float32
    private var maxScrollY: Float32
    private var scrollAnimY: AnimationState
    private var barThickness: Float32
    private var barMinLength: Float32
    private var barOpacity: Float32
    private var lastWheelTime: Int64
    private var layoutFrame: Option<LayoutFrame>
    private var parentHwnd: Option<CPointer<Byte>>
    private var focusId: Int64
    private var viewportH: Float32
    private var undoStack: ArrayList<UndoEntry>
    private var redoStack: ArrayList<UndoEntry>
    private var groupingDelete: Bool
    private var _onTextChanged: Option<(String) -> Unit>
    private var wrapCache: ArrayList<Int64>

    public init(fontFamily: String, fontSize: Float32, style: TextEditStyle) {
        this.lines = ArrayList<String>()
        this.lines.add("")
        this.cursorRow = 0
        this.cursorCol = 0
        this.selStartRow = 0
        this.selStartCol = 0
        this.selEndRow = 0
        this.selEndCol = 0
        this.fontFamily = fontFamily
        this.fontSize = fontSize
        this.style = style
        this.lineHeight = fontSize * 1.5
        this.avgCharW = fontSize * 0.6
        this.padding = 8.0
        this.wordWrap = false
        this.isFocused = false
        this.isHovered = false
        this.isSelecting = false
        this.caretVisible = true
        this.lastBlinkTime = 0
        this.scrollY = 0.0
        this.targetScrollY = 0.0
        this.maxScrollY = 0.0
        this.scrollAnimY = AnimationState()
        this.barThickness = 10.0
        this.barMinLength = 20.0
        this.barOpacity = 0.3
        this.lastWheelTime = 0
        this.layoutFrame = None
        this.parentHwnd = None<CPointer<Byte>>
        this.focusId = nextFocusId()
        this.viewportH = 0.0
        this.undoStack = ArrayList<UndoEntry>()
        this.redoStack = ArrayList<UndoEntry>()
        this.groupingDelete = false
        this._onTextChanged = None<(String) -> Unit>
        this.wrapCache = ArrayList<Int64>()
    }

    public static func styled(styleName: String, fontFamily: String, fontSize: Float32,
        style: TextEditStyle): TextEdit {
        let props = StyleSheet.getDefault().resolve(styleName)
        let ff = match (props.fontFamily) { case Some(f) => f; case None => fontFamily }
        let fs = match (props.fontSize) { case Some(s) => s; case None => fontSize }
        TextEdit(ff, fs, style)
    }

    public func setParentHwnd(hwnd: CPointer<Byte>): Unit { this.parentHwnd = Some(hwnd) }

    public func focus(): Unit { isFocused = true; caretVisible = true; lastBlinkTime = 0 }
    public func blur(): Unit { isFocused = false }
    public func hasFocus(): Bool { isFocused }
    public func getFocusId(): Int64 { focusId }
    public func onTextChanged(cb: (String) -> Unit): TextEdit { this._onTextChanged = Some(cb); this }
    public func setOnTextChanged(callback: (String) -> Unit): Unit { this._onTextChanged = Some(callback) }
    public func setWordWrap(wrap: Bool): Unit { this.wordWrap = wrap }

    public func getText(): String {
        var result = ""
        for (i in 0..lines.size) {
            if (i > 0) { result = result + "\n" }
            result = result + lines[i]
        }
        result
    }

    public func setText(text: String): Unit {
        lines = ArrayList<String>()
        if (text.size == 0) {
            lines.add("")
        } else {
            var current = ArrayList<Rune>()
            for (r in text.runes()) {
                if (r == r'\n') {
                    lines.add(String(current))
                    current = ArrayList<Rune>()
                } else if (r != r'\r') {
                    current.add(r)
                }
            }
            lines.add(String(current))
        }
        cursorRow = 0
        cursorCol = 0
        clearSelection()
        scrollY = 0.0
        targetScrollY = 0.0
        undoStack = ArrayList<UndoEntry>()
        redoStack = ArrayList<UndoEntry>()
        notifyChanged()
    }

    public func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        let now = ffi_getTickCount()
        if (lastBlinkTime == 0) {
            lastBlinkTime = now
        } else if (now - lastBlinkTime >= 250) {
            caretVisible = !caretVisible
            lastBlinkTime = now
        }

        let (left, top, vw, vh) = getViewport()
        if (vw <= 0.0 || vh <= 0.0) { return }
        viewportH = vh
        let c = Theme.colors()
        let (bg, textC, selC, cursorC, borderC) = getThemeColors()
        canvas.fillRoundedRect(left, top, vw, vh, style.cornerRadius, bg)
        let bw = style.borderWidth
        canvas.drawRoundedRect(left, top, vw, vh, style.cornerRadius, bw, borderC)
        let textLeft = left + padding
        let textTop = top + padding
        let textW = vw - padding * 2.0
        let textH = vh - padding * 2.0
        if (textW <= 0.0 || textH <= 0.0) { return }

        canvas.pushClip(textLeft, textTop, textW, textH)

        let visualLines = getVisualLines(textW)
        let contentH = Float32(visualLines.size) * lineHeight
        maxScrollY = if (contentH > textH) { contentH - textH } else { 0.0 }
        scrollAnimY.update(now)
        if (!scrollAnimY.isFinished()) { scrollY = scrollAnimY.getValue() }
        if (scrollY < 0.0) { scrollY = 0.0 }
        if (scrollY > maxScrollY) { scrollY = maxScrollY }
        let firstVis = if (lineHeight > 0.0) { Int64(scrollY / lineHeight) } else { Int64(0) }
        let lastVis = if (lineHeight > 0.0) { Int64((scrollY + textH) / lineHeight) + 1 } else { Int64(0) }
        let totalVL = Int64(visualLines.size)
        let fv = if (firstVis < 0) { Int64(0) } else if (firstVis >= totalVL) { totalVL } else { firstVis }
        let lv = if (lastVis < 0) { Int64(0) } else if (lastVis > totalVL) { totalVL } else { lastVis }

        if (hasSelection()) {
            paintSelection(canvas, textLeft, textTop, textW, visualLines, fv, lv, selC)
        }

        for (vi in fv..lv) {
            let vl = visualLines[vi]
            let lineY = textTop + Float32(vi) * lineHeight - scrollY
            canvas.drawText(textLeft, lineY, vl.text, fontFamily, fontSize, textC)
        }

        if (isFocused && caretVisible) {
            let (curVLine, curColInVLine) = mapToVisual(visualLines, cursorRow, cursorCol)
            if (curVLine >= 0 && curVLine < Int64(visualLines.size)) {
                let cursorVL = visualLines[curVLine]
                let cx = textLeft + measureLineUpTo(cursorVL.text, curColInVLine)
                let cy = textTop + Float32(curVLine) * lineHeight - scrollY
                canvas.drawLine(cx, cy, cx, cy + lineHeight, 1.0, cursorC)
            }
        }

        canvas.popClip()

        paintScrollbar(canvas, left, top, vw, vh, textH, contentH)
    }

    public func hitTest(x: Float32, y: Float32, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool {
        match (layoutFrame) {
            case Some(f) => x >= f.x && x <= f.x + f.width && y >= f.y && y <= f.y + f.height
            case None => false
        }
    }

    public func handleEvent(event: Event): Bool {
        match (event.eventType) {
            case EventType.MouseEnter => isHovered = true; true
            case EventType.MouseLeave => isHovered = false; isSelecting = false; true
            case EventType.MouseDown => handleMouseDown(event)
            case EventType.MouseUp => isSelecting = false; true
            case EventType.MouseMove => handleMouseMove(event)
            case EventType.MouseWheel => handleMouseWheel(event)
            case EventType.FocusGain => isFocused = true; caretVisible = true; lastBlinkTime = 0; true
            case EventType.FocusLost => isFocused = false; true
            case EventType.KeyDown => handleKeyDown(event)
            case EventType.KeyChar => handleKeyChar(event)
            case _ => false
        }
    }

    public func contains(x: Float32, y: Float32): Bool { true }
    public func updateAnimation(tickCount: Int64): Bool {
        scrollAnimY.update(tickCount)
        if (!scrollAnimY.isFinished()) { scrollY = scrollAnimY.getValue(); return true }
        if (lastWheelTime > 0) {
            let now = tickCount
            if (now - lastWheelTime > 1500 && barOpacity > 0.31) { barOpacity = 0.3 }
        }
        false
    }
    public func findLeafAt(x: Float32, y: Float32): Widget { this }
    public func getLayoutMinWidth(): Float32 { 200.0 }
    public func getLayoutMinHeight(): Float32 { 100.0 }
    public func setLayoutFrame(frame: LayoutFrame): Unit { this.layoutFrame = Some(frame) }
    public func clearLayoutFrame(): Unit { this.layoutFrame = None }
    public func getLayoutFrame(): Option<LayoutFrame> { layoutFrame }

    private func handleMouseDown(event: Event): Bool {
        match (event.mouseEvent) {
            case Some(me) =>
                let (left, top, vw, vh) = getViewport()
                let textLeft = left + padding
                let textTop = top + padding
                let textW = vw - padding * 2.0
                let visLines = getVisualLines(textW)
                let clickY = me.y - textTop + scrollY
                var visIdx = Int64(clickY / lineHeight)
                if (visIdx < 0) { visIdx = 0 }
                if (visIdx >= Int64(visLines.size)) { visIdx = Int64(visLines.size) - 1 }
                if (visIdx < 0) { return true }

                let vl = visLines[visIdx]
                let clickX = me.x - textLeft
                let col = columnAtX(vl, clickX)

                cursorRow = vl.sourceRow
                cursorCol = vl.sourceStartCol + col
                clearSelection()
                isSelecting = true
                selStartRow = cursorRow
                selStartCol = cursorCol
                selEndRow = cursorRow
                selEndCol = cursorCol
                caretVisible = true
                lastBlinkTime = 0
                ensureCursorVisible()
                true
            case None => false
        }
    }

    private func handleMouseMove(event: Event): Bool {
        if (!isSelecting) { return false }
        match (event.mouseEvent) {
            case Some(me) =>
                let (left, top, vw, _) = getViewport()
                let textLeft = left + padding
                let textTop = top + padding
                let textW = vw - padding * 2.0
                let visLines = getVisualLines(textW)
                let clickY = me.y - textTop + scrollY
                var visIdx = Int64(clickY / lineHeight)
                if (visIdx < 0) { visIdx = 0 }
                if (visIdx >= Int64(visLines.size)) { visIdx = Int64(visLines.size) - 1 }
                if (visIdx < 0) { return true }

                let vl = visLines[visIdx]
                let clickX = me.x - textLeft
                let col = columnAtX(vl, clickX)

                cursorRow = vl.sourceRow
                cursorCol = vl.sourceStartCol + col
                selEndRow = cursorRow
                selEndCol = cursorCol
                caretVisible = true
                lastBlinkTime = 0
                ensureCursorVisible()
                true
            case None => false
        }
    }

    private func handleMouseWheel(event: Event): Bool {
        match (event.mouseWheelEvent) {
            case Some(we) =>
                let lines = Float32(we.delta) / 120.0
                let speed = lineHeight * 3.0
                let newTarget = targetScrollY - lines * speed
                if (newTarget < 0.0) { targetScrollY = 0.0 } else if (newTarget > maxScrollY) { targetScrollY = maxScrollY } else { targetScrollY = newTarget }
                scrollAnimY.jumpToEnd()
                scrollY = scrollAnimY.getValue()
                scrollAnimY.start(scrollY, targetScrollY, 150, Easing.EaseOut)
                barOpacity = 1.0
                lastWheelTime = ffi_getTickCount()
                true
            case None => false
        }
    }

    private func handleKeyDown(event: Event): Bool {
        if (event.hasAlt) { return false }
        match (event.keyEvent) {
            case Some(ke) =>
                let vkA: UInt32 = 65; let vkC: UInt32 = 67; let vkV: UInt32 = 86
                let vkX: UInt32 = 88; let vkZ: UInt32 = 90; let vkY: UInt32 = 89

                if (event.hasCtrl) {
                    if (ke.keyCode == vkA) { selectAll(); return true }
                    if (ke.keyCode == vkC) { copy(); return true }
                    if (ke.keyCode == vkV) { paste(); return true }
                    if (ke.keyCode == vkX) { cut(); return true }
                    if (ke.keyCode == vkZ) { undo(); return true }
                    if (ke.keyCode == vkY) { redo(); return true }
                }

                let vkBack: UInt32 = 8; let vkDelete: UInt32 = 46
                let vkLeft: UInt32 = 37; let vkRight: UInt32 = 39
                let vkUp: UInt32 = 38; let vkDown: UInt32 = 40
                let vkHome: UInt32 = 36; let vkEnd: UInt32 = 35
                let vkEnter: UInt32 = 13

                if (ke.keyCode == vkBack) { backspace(); return true }
                if (ke.keyCode == vkDelete) { deleteForward(); return true }
                if (ke.keyCode == vkEnter) { insertNewline(); return true }
                if (ke.keyCode == vkLeft) { moveLeft(event.hasShift); return true }
                if (ke.keyCode == vkRight) { moveRight(event.hasShift); return true }
                if (ke.keyCode == vkUp) { moveUp(event.hasShift); return true }
                if (ke.keyCode == vkDown) { moveDown(event.hasShift); return true }
                if (ke.keyCode == vkHome) { moveHome(event.hasShift); return true }
                if (ke.keyCode == vkEnd) { moveEnd(event.hasShift); return true }
                false
            case None => false
        }
    }

    private func handleKeyChar(event: Event): Bool {
        if (event.hasCtrl || event.hasAlt) { return false }
        match (event.keyEvent) {
            case Some(ke) =>
                let ch = ke.keyChar
                if (ch >= r' ' && ch != r'\t') {
                    insertChar(ch)
                    true
                } else if (ch == r'\t') {
                    insertChar(r' ')
                    insertChar(r' ')
                    true
                } else { false }
            case None => false
        }
    }

    private func insertChar(ch: Rune): Unit {
        redoStack = ArrayList<UndoEntry>()
        if (hasSelection()) { deleteSelectionRaw(false) }
        let line = lines[Int64(cursorRow)]
        let runes = toRunes(line)
        let newRunes = insertRuneAt(runes, ch, cursorCol)
        lines[Int64(cursorRow)] = String(newRunes)
        undoStack.add(UndoEntry(UndoOpType.Insert, cursorRow, cursorCol, String(ch)))
        groupingDelete = false
        cursorCol = cursorCol + 1
        clearSelection()
        notifyChanged()
        ensureCursorVisible()
    }

    private func backspace(): Unit {
        redoStack = ArrayList<UndoEntry>()
        if (hasSelection()) { deleteSelectionRaw(true); return }
        if (cursorCol > 0) {
            let line = lines[Int64(cursorRow)]
            let runes = toRunes(line)
            let deleted = String(runes[Int64(cursorCol - 1)])
            let newRunes = removeRuneAt(runes, cursorCol - 1)
            lines[Int64(cursorRow)] = String(newRunes)
            pushDeleteUndo(cursorRow, cursorCol - 1, deleted)
            cursorCol = cursorCol - 1
        } else if (cursorRow > 0) {
            let prevLine = lines[Int64(cursorRow - 1)]
            let curLine = lines[Int64(cursorRow)]
            let newCol = Int64(runeCount(prevLine))
            lines[Int64(cursorRow - 1)] = prevLine + curLine
            lines = removeAt(lines, Int64(cursorRow))
            redoStack = ArrayList<UndoEntry>()
            undoStack.add(UndoEntry(UndoOpType.Delete, cursorRow - 1, newCol, "\n"))
            groupingDelete = false
            cursorRow = cursorRow - 1
            cursorCol = newCol
        }
        clearSelection()
        notifyChanged()
        ensureCursorVisible()
    }

    private func deleteForward(): Unit {
        redoStack = ArrayList<UndoEntry>()
        if (hasSelection()) { deleteSelectionRaw(true); return }
        let line = lines[Int64(cursorRow)]
        let runes = toRunes(line)
        if (cursorCol < Int64(runes.size)) {
            let deleted = String(runes[Int64(cursorCol)])
            let newRunes = removeRuneAt(runes, cursorCol)
            lines[Int64(cursorRow)] = String(newRunes)
            pushDeleteUndo(cursorRow, cursorCol, deleted)
        } else if (cursorRow < Int64(lines.size) - 1) {
            let curLine = lines[Int64(cursorRow)]
            let nextLine = lines[Int64(cursorRow + 1)]
            lines[Int64(cursorRow)] = curLine + nextLine
            lines = removeAt(lines, Int64(cursorRow + 1))
            redoStack = ArrayList<UndoEntry>()
            undoStack.add(UndoEntry(UndoOpType.Delete, cursorRow, cursorCol, "\n"))
            groupingDelete = false
        }
        clearSelection()
        notifyChanged()
        ensureCursorVisible()
    }

    private func insertNewline(): Unit {
        redoStack = ArrayList<UndoEntry>()
        if (hasSelection()) { deleteSelectionRaw(false) }
        let line = lines[Int64(cursorRow)]
        let runes = toRunes(line)
        let leftRunes = ArrayList<Rune>()
        for (i in 0..cursorCol) { leftRunes.add(runes[Int64(i)]) }
        let rightRunes = ArrayList<Rune>()
        for (i in cursorCol..Int64(runes.size)) { rightRunes.add(runes[i]) }
        lines[Int64(cursorRow)] = String(leftRunes)
        lines = insertAt(lines, Int64(cursorRow + 1), String(rightRunes))
        undoStack.add(UndoEntry(UndoOpType.Insert, cursorRow, cursorCol, "\n"))
        groupingDelete = false
        cursorRow = cursorRow + 1
        cursorCol = 0
        clearSelection()
        notifyChanged()
        ensureCursorVisible()
    }

    private func deleteSelectionRaw(recordUndo: Bool): Unit {
        if (!hasSelection()) { return }
        let (sr, sc, er, ec) = getOrderedSelection()
        if (recordUndo) {
            redoStack = ArrayList<UndoEntry>()
            let deleted = getTextRange(sr, sc, er, ec)
            undoStack.add(UndoEntry(UndoOpType.Delete, sr, sc, deleted))
            groupingDelete = false
        }
        let firstLine = lines[Int64(sr)]
        let lastLine = lines[Int64(er)]
        let firstRunes = toRunes(firstLine)
        let lastRunes = toRunes(lastLine)
        let prefixRunes = ArrayList<Rune>()
        for (i in 0..sc) { prefixRunes.add(firstRunes[Int64(i)]) }
        let suffixRunes = ArrayList<Rune>()
        for (i in ec..Int64(lastRunes.size)) { suffixRunes.add(lastRunes[i]) }
        let newLine = String(prefixRunes) + String(suffixRunes)
        var newLines = ArrayList<String>()
        for (i in 0..sr) { newLines.add(lines[Int64(i)]) }
        newLines.add(newLine)
        for (i in (er + 1)..Int64(lines.size)) { newLines.add(lines[i]) }
        lines = newLines
        cursorRow = sr
        cursorCol = sc
        clearSelection()
        notifyChanged()
        ensureCursorVisible()
    }

    private func pushDeleteUndo(row: Int64, col: Int64, text: String): Unit {
        groupingDelete = true
        undoStack.add(UndoEntry(UndoOpType.Delete, row, col, text))
    }

    private func undo(): Unit {
        if (undoStack.size == 0) { return }
        let entry = undoStack[Int64(undoStack.size - 1)]
        undoStack = popLast(undoStack)
        groupingDelete = false
        clearSelection()

        match (entry.opType) {
            case UndoOpType.Insert =>
                if (entry.text == "\n") {
                    if (entry.row + 1 < Int64(lines.size)) {
                        let cur = lines[Int64(entry.row)]
                        let next = lines[Int64(entry.row + 1)]
                        lines[Int64(entry.row)] = cur + next
                        lines = removeAt(lines, Int64(entry.row + 1))
                    }
                } else {
                    let line = lines[Int64(entry.row)]
                    let runes = toRunes(line)
                    let newRunes = ArrayList<Rune>()
                    for (i in 0..entry.col) { newRunes.add(runes[Int64(i)]) }
                    let skipEnd = entry.col + runeCount(entry.text)
                    for (i in skipEnd..Int64(runes.size)) { newRunes.add(runes[i]) }
                    lines[Int64(entry.row)] = String(newRunes)
                }
                cursorRow = entry.row
                cursorCol = entry.col
            case UndoOpType.Delete =>
                if (entry.text == "\n") {
                    let cur = lines[Int64(entry.row)]
                    let newLeft = ArrayList<Rune>()
                    let curRunes = toRunes(cur)
                    for (i in 0..entry.col) { newLeft.add(curRunes[Int64(i)]) }
                    let newRight = ArrayList<Rune>()
                    for (i in entry.col..Int64(curRunes.size)) { newRight.add(curRunes[i]) }
                    lines[Int64(entry.row)] = String(newLeft)
                    lines = insertAt(lines, Int64(entry.row + 1), String(newRight))
                } else {
                    let line = lines[Int64(entry.row)]
                    let runes = toRunes(line)
                    let newRunes = ArrayList<Rune>()
                    for (i in 0..entry.col) { newRunes.add(runes[Int64(i)]) }
                    for (r in entry.text.runes()) { newRunes.add(r) }
                    for (i in entry.col..Int64(runes.size)) { newRunes.add(runes[i]) }
                    lines[Int64(entry.row)] = String(newRunes)
                }
                cursorRow = entry.row
                cursorCol = entry.col + runeCount(entry.text)
        }
        redoStack.add(entry)
        notifyChanged()
        ensureCursorVisible()
    }

    private func redo(): Unit {
        if (redoStack.size == 0) { return }
        let entry = redoStack[Int64(redoStack.size - 1)]
        redoStack = popLast(redoStack)
        groupingDelete = false
        clearSelection()

        match (entry.opType) {
            case UndoOpType.Insert =>
                if (entry.text == "\n") {
                    let cur = lines[Int64(entry.row)]
                    let left = ArrayList<Rune>()
                    let curRunes = toRunes(cur)
                    for (i in 0..entry.col) { left.add(curRunes[Int64(i)]) }
                    let right = ArrayList<Rune>()
                    for (i in entry.col..Int64(curRunes.size)) { right.add(curRunes[i]) }
                    lines[Int64(entry.row)] = String(left)
                    lines = insertAt(lines, Int64(entry.row + 1), String(right))
                } else {
                    let line = lines[Int64(entry.row)]
                    let runes = toRunes(line)
                    let newRunes = insertRuneAtMulti(runes, entry.text, entry.col)
                    lines[Int64(entry.row)] = String(newRunes)
                }
                cursorRow = entry.row
                cursorCol = entry.col + runeCount(entry.text)
            case UndoOpType.Delete =>
                if (entry.text == "\n") {
                    if (entry.row + 1 < Int64(lines.size)) {
                        let cur = lines[Int64(entry.row)]
                        let next = lines[Int64(entry.row + 1)]
                        lines[Int64(entry.row)] = cur + next
                        lines = removeAt(lines, Int64(entry.row + 1))
                    }
                } else {
                    let line = lines[Int64(entry.row)]
                    let runes = toRunes(line)
                    let newRunes = ArrayList<Rune>()
                    for (i in 0..entry.col) { newRunes.add(runes[Int64(i)]) }
                    let skipEnd = entry.col + runeCount(entry.text)
                    for (i in skipEnd..Int64(runes.size)) { newRunes.add(runes[i]) }
                    lines[Int64(entry.row)] = String(newRunes)
                }
                cursorRow = entry.row
                cursorCol = entry.col
        }
        undoStack.add(entry)
        notifyChanged()
        ensureCursorVisible()
    }

    private func moveLeft(hasShift: Bool): Unit {
        if (hasShift) {
            if (!hasSelection()) { selStartRow = cursorRow; selStartCol = cursorCol }
            if (cursorCol > 0) { cursorCol = cursorCol - 1 }
            else if (cursorRow > 0) { cursorRow = cursorRow - 1; cursorCol = Int64(lines[Int64(cursorRow)].size) }
            selEndRow = cursorRow; selEndCol = cursorCol
        } else {
            if (hasSelection()) {
                let (sr, sc, _, _) = getOrderedSelection()
                cursorRow = sr; cursorCol = sc
            } else if (cursorCol > 0) { cursorCol = cursorCol - 1 }
            else if (cursorRow > 0) { cursorRow = cursorRow - 1; cursorCol = Int64(lines[Int64(cursorRow)].size) }
            clearSelection()
        }
        caretVisible = true; lastBlinkTime = 0; ensureCursorVisible()
    }

    private func moveRight(hasShift: Bool): Unit {
        let lineLen = Int64(lines[Int64(cursorRow)].size)
        if (hasShift) {
            if (!hasSelection()) { selStartRow = cursorRow; selStartCol = cursorCol }
            if (cursorCol < lineLen) { cursorCol = cursorCol + 1 }
            else if (cursorRow < Int64(lines.size) - 1) { cursorRow = cursorRow + 1; cursorCol = 0 }
            selEndRow = cursorRow; selEndCol = cursorCol
        } else {
            if (hasSelection()) {
                let (_, _, er, ec) = getOrderedSelection()
                cursorRow = er; cursorCol = ec
            } else if (cursorCol < lineLen) { cursorCol = cursorCol + 1 }
            else if (cursorRow < Int64(lines.size) - 1) { cursorRow = cursorRow + 1; cursorCol = 0 }
            clearSelection()
        }
        caretVisible = true; lastBlinkTime = 0; ensureCursorVisible()
    }

    private func moveUp(hasShift: Bool): Unit {
        if (cursorRow > 0) { cursorRow = cursorRow - 1 } else { return }
        let lineLen = Int64(lines[Int64(cursorRow)].size)
        if (cursorCol > lineLen) { cursorCol = lineLen }
        if (hasShift) { selEndRow = cursorRow; selEndCol = cursorCol } else { clearSelection() }
        caretVisible = true; lastBlinkTime = 0; ensureCursorVisible()
    }

    private func moveDown(hasShift: Bool): Unit {
        if (cursorRow < Int64(lines.size) - 1) { cursorRow = cursorRow + 1 } else { return }
        let lineLen = Int64(lines[Int64(cursorRow)].size)
        if (cursorCol > lineLen) { cursorCol = lineLen }
        if (hasShift) { selEndRow = cursorRow; selEndCol = cursorCol } else { clearSelection() }
        caretVisible = true; lastBlinkTime = 0; ensureCursorVisible()
    }

    private func moveHome(hasShift: Bool): Unit {
        if (hasShift) {
            if (!hasSelection()) { selStartRow = cursorRow; selStartCol = cursorCol }
        } else { clearSelection() }
        cursorCol = 0
        if (hasShift) { selEndRow = cursorRow; selEndCol = cursorCol }
        caretVisible = true; lastBlinkTime = 0; ensureCursorVisible()
    }

    private func moveEnd(hasShift: Bool): Unit {
        if (hasShift) {
            if (!hasSelection()) { selStartRow = cursorRow; selStartCol = cursorCol }
        } else { clearSelection() }
        cursorCol = Int64(lines[Int64(cursorRow)].size)
        if (hasShift) { selEndRow = cursorRow; selEndCol = cursorCol }
        caretVisible = true; lastBlinkTime = 0; ensureCursorVisible()
    }

    private func copy(): Unit {
        if (!hasSelection()) { return }
        let selected = getSelectedText()
        if (selected.size > 0) {
            ffi_clipboardSetText(selected)
        }
    }

    private func cut(): Unit {
        copy()
        deleteSelectionRaw(true)
    }

    private func paste(): Unit {
        let clipText = ffi_clipboardGetText()
        if (clipText.size > 0) {
            redoStack = ArrayList<UndoEntry>()
            if (hasSelection()) { deleteSelectionRaw(false) }
            for (r in clipText.runes()) {
                if (r == r'\r') { continue }
                if (r == r'\n') { insertNewlineRaw() }
                else { insertCharRaw(r) }
            }
            undoStack.add(UndoEntry(UndoOpType.Insert, cursorRow, cursorCol, clipText))
            groupingDelete = false
            notifyChanged()
            ensureCursorVisible()
        }
    }

    private func insertCharRaw(ch: Rune): Unit {
        let line = lines[Int64(cursorRow)]
        let runes = toRunes(line)
        let newRunes = insertRuneAt(runes, ch, cursorCol)
        lines[Int64(cursorRow)] = String(newRunes)
        cursorCol = cursorCol + 1
    }

    private func insertNewlineRaw(): Unit {
        let line = lines[Int64(cursorRow)]
        let runes = toRunes(line)
        let leftRunes = ArrayList<Rune>()
        for (i in 0..cursorCol) { leftRunes.add(runes[Int64(i)]) }
        let rightRunes = ArrayList<Rune>()
        for (i in cursorCol..Int64(runes.size)) { rightRunes.add(runes[i]) }
        lines[Int64(cursorRow)] = String(leftRunes)
        lines = insertAt(lines, Int64(cursorRow + 1), String(rightRunes))
        cursorRow = cursorRow + 1
        cursorCol = 0
    }

    private func selectAll(): Unit {
        selStartRow = 0; selStartCol = 0
        selEndRow = Int64(lines.size) - 1
        selEndCol = Int64(lines[selEndRow].size)
        cursorRow = selEndRow; cursorCol = selEndCol
        caretVisible = true; lastBlinkTime = 0
    }

    private func hasSelection(): Bool {
        selStartRow != selEndRow || selStartCol != selEndCol
    }

    private func clearSelection(): Unit {
        selStartRow = cursorRow; selStartCol = cursorCol
        selEndRow = cursorRow; selEndCol = cursorCol
    }

    private func getOrderedSelection(): (Int64, Int64, Int64, Int64) {
        if (selStartRow < selEndRow || (selStartRow == selEndRow && selStartCol <= selEndCol)) {
            (selStartRow, selStartCol, selEndRow, selEndCol)
        } else {
            (selEndRow, selEndCol, selStartRow, selStartCol)
        }
    }

    private func getSelectedText(): String {
        if (!hasSelection()) { return "" }
        let (sr, sc, er, ec) = getOrderedSelection()
        getTextRange(sr, sc, er, ec)
    }

    private func getTextRange(sr: Int64, sc: Int64, er: Int64, ec: Int64): String {
        if (sr == er) {
            let line = lines[Int64(sr)]
            let runes = toRunes(line)
            let selected = ArrayList<Rune>()
            for (i in sc..ec) { selected.add(runes[Int64(i)]) }
            return String(selected)
        }
        var result = ""
        let firstLine = lines[Int64(sr)]
        let firstRunes = toRunes(firstLine)
        for (i in sc..Int64(firstRunes.size)) { result = result + String(firstRunes[Int64(i)]) }
        for (row in (sr + 1)..er) { result = result + "\n"; result = result + lines[Int64(row)] }
        let lastLine = lines[Int64(er)]
        let lastRunes = toRunes(lastLine)
        result = result + "\n"
        for (i in 0..ec) { result = result + String(lastRunes[Int64(i)]) }
        result
    }

    private func getVisualLines(textW: Float32): ArrayList<VisualLine> {
        let result = ArrayList<VisualLine>()
        if (wordWrap && textW > 0.0 && avgCharW > 0.0) {
            let charsPerLine = Int64(textW / avgCharW)
            if (charsPerLine < 1) { return result }
            for (row in 0..lines.size) {
                let line = lines[row]
                let runes = toRunes(line)
                var col: Int64 = 0
                let total = Int64(runes.size)
                while (col < total) {
                    let end = if (col + charsPerLine < total) { col + charsPerLine } else { total }
                    let segRunes = ArrayList<Rune>()
                    for (i in col..end) { segRunes.add(runes[Int64(i)]) }
                    result.add(VisualLine(Int64(row), col, String(segRunes)))
                    col = end
                }
            }
        } else {
            for (row in 0..lines.size) {
                result.add(VisualLine(Int64(row), 0, lines[row]))
            }
        }
        result
    }

    private func mapToVisual(visLines: ArrayList<VisualLine>, srcRow: Int64, srcCol: Int64): (Int64, Int64) {
        var visIdx: Int64 = 0
        for (vl in visLines) {
            if (vl.sourceRow == srcRow && srcCol >= vl.sourceStartCol && srcCol <= vl.sourceStartCol + Int64(vl.text.size)) {
                return (visIdx, srcCol - vl.sourceStartCol)
            }
            visIdx = visIdx + 1
        }
        (Int64(0), Int64(0))
    }

    private func getViewport(): (Float32, Float32, Float32, Float32) {
        match (layoutFrame) {
            case Some(f) => (f.x, f.y, f.width, f.height)
            case None => (0.0, 0.0, 400.0, 300.0)
        }
    }

    private func getThemeColors(): (Color, Color, Color, Color, Color) {
        if (style.isThemeBased) {
            let c = Theme.colors()
            let bg = c.inputBg
            let border = if (isFocused) { c.borderFocused } else { c.inputBorder }
            return (bg, c.textPrimary, Color.rgba(c.accent.r, c.accent.g, c.accent.b, 100), c.accent, border)
        }
        let bg = style.backgroundColor
        let border = if (isFocused) { style.focusedBorderColor } else { style.borderColor }
        (bg, style.textColor, style.selectionColor, style.cursorColor, border)
    }

    private func paintSelection(canvas: Canvas, x: Float32, y: Float32, textW: Float32, visLines: ArrayList<VisualLine>, fv: Int64, lv: Int64, selC: Color): Unit {
        let (sr, sc, er, ec) = getOrderedSelection()
        for (vi in fv..lv) {
            let vl = visLines[vi]
            let vlStart = vl.sourceStartCol
            let vlEnd = vlStart + Int64(vl.text.size)
            var selStartInLine = Int64(-1)
            var selEndInLine = Int64(-1)
            if (vl.sourceRow > sr && vl.sourceRow < er) {
                selStartInLine = 0
                selEndInLine = Int64(vl.text.size)
            } else if (vl.sourceRow == sr && vl.sourceRow == er) {
                if (sc < vlEnd && ec > vlStart) {
                    selStartInLine = if (sc > vlStart) { sc - vlStart } else { 0 }
                    selEndInLine = if (ec < vlEnd) { ec - vlStart } else { Int64(vl.text.size) }
                }
            } else if (vl.sourceRow == sr) {
                if (sc < vlEnd) {
                    selStartInLine = if (sc > vlStart) { sc - vlStart } else { 0 }
                    selEndInLine = Int64(vl.text.size)
                }
            } else if (vl.sourceRow == er) {
                if (ec > vlStart) {
                    selStartInLine = 0
                    selEndInLine = if (ec < vlEnd) { ec - vlStart } else { Int64(vl.text.size) }
                }
            }
            if (selStartInLine >= 0 && selEndInLine > selStartInLine) {
                let prefixW = if (selStartInLine > 0) { measureLineUpTo(vl.text, selStartInLine) } else { Float32(0.0) }
                let totalW = measureLineUpTo(vl.text, selEndInLine)
                let sx = x + prefixW
                let sw = totalW - prefixW
                let sy = y + Float32(vi) * lineHeight - scrollY
                canvas.fillRect(sx, sy, sw, lineHeight, selC)
            }
        }
    }

    private func columnAtX(vl: VisualLine, clickX: Float32): Int64 {
        let total = Int64(vl.text.size)
        var col: Int64 = 0
        while (col < total && measureLineUpTo(vl.text, col) < clickX) {
            col = col + 1
        }
        if (col > 0) {
            let prevW = measureLineUpTo(vl.text, col - 1)
            let curW = measureLineUpTo(vl.text, col)
            if (clickX - prevW > curW - clickX) { col = col }
            else { col = col - 1 }
        }
        if (col < 0) { col = 0 }
        if (col > total) { col = total }
        col
    }

    private func measureLineUpTo(line: String, charCount: Int64): Float32 {
        match (parentHwnd) {
            case Some(h) => ffi_measureTextRange(h, line, Int32(charCount), fontFamily, fontSize)
            case None => Float32(charCount) * avgCharW
        }
    }

    private func paintScrollbar(canvas: Canvas, left: Float32, top: Float32, vw: Float32, vh: Float32, textH: Float32, contentH: Float32): Unit {
        if (maxScrollY <= 0.0 || barOpacity <= 0.01) { return }
        let c = Theme.colors()
        let alpha = UInt8(barOpacity * 255.0)
        let barX = left + vw - barThickness
        let barH = vh
        let thumbH = if (contentH > 0.0) { barH * textH / contentH } else { barH }
        let clampedH = if (thumbH < barMinLength) { barMinLength } else if (thumbH > barH - 4.0) { barH - 4.0 } else { thumbH }
        let thumbTravel = barH - clampedH - 4.0
        let thumbY = if (maxScrollY > 0.0) { top + 2.0 + (scrollY / maxScrollY) * thumbTravel } else { top + 2.0 }
        canvas.fillRoundedRect(barX + 2.0, top, barThickness - 4.0, barH, 4.0, Color.rgba(c.scrollbarTrack.r, c.scrollbarTrack.g, c.scrollbarTrack.b, alpha))
        canvas.fillRoundedRect(barX + 2.0, thumbY, barThickness - 4.0, clampedH, 4.0, Color.rgba(c.scrollbarThumb.r, c.scrollbarThumb.g, c.scrollbarThumb.b, alpha))
    }

    private func ensureCursorVisible(): Unit {
        let (_, _, vw, _) = getViewport()
        let textW = vw - padding * 2.0
        let visLines = getVisualLines(textW)
        let (curVLine, _) = mapToVisual(visLines, cursorRow, cursorCol)
        let curY = Float32(curVLine) * lineHeight
        let textH = viewportH - padding * 2.0
        if (curY < scrollY) { targetScrollY = curY - lineHeight }
        else if (curY + lineHeight > scrollY + textH) { targetScrollY = curY - textH + lineHeight * 2.0 }
        if (targetScrollY < 0.0) { targetScrollY = 0.0 }
        if (targetScrollY > maxScrollY) { targetScrollY = maxScrollY }
        scrollAnimY.jumpToEnd()
        scrollY = scrollAnimY.getValue()
        scrollAnimY.start(scrollY, targetScrollY, 100, Easing.EaseOut)
        barOpacity = 1.0
        lastWheelTime = ffi_getTickCount()
    }

    private func notifyChanged(): Unit {
        match (_onTextChanged) {
            case Some(cb) => cb(getText())
            case None => ()
        }
    }

    private func runeCount(s: String): Int64 {
        var count: Int64 = 0
        for (_ in s.runes()) { count = count + 1 }
        count
    }

    private func toRunes(s: String): ArrayList<Rune> {
        let result = ArrayList<Rune>()
        for (r in s.runes()) { result.add(r) }
        result
    }

    private func insertRuneAt(list: ArrayList<Rune>, r: Rune, index: Int64): ArrayList<Rune> {
        let result = ArrayList<Rune>()
        var i: Int64 = 0
        for (item in list) {
            if (i == index) { result.add(r) }
            result.add(item)
            i = i + 1
        }
        if (i == index) { result.add(r) }
        result
    }

    private func insertRuneAtMulti(list: ArrayList<Rune>, text: String, index: Int64): ArrayList<Rune> {
        let result = ArrayList<Rune>()
        var i: Int64 = 0
        for (item in list) {
            if (i == index) {
                for (r in text.runes()) { result.add(r) }
            }
            result.add(item)
            i = i + 1
        }
        if (i == index) {
            for (r in text.runes()) { result.add(r) }
        }
        result
    }

    private func removeRuneAt(list: ArrayList<Rune>, index: Int64): ArrayList<Rune> {
        let result = ArrayList<Rune>()
        var i: Int64 = 0
        for (item in list) {
            if (i != index) { result.add(item) }
            i = i + 1
        }
        result
    }

    private func insertAt(list: ArrayList<String>, index: Int64, value: String): ArrayList<String> {
        let result = ArrayList<String>()
        var i: Int64 = 0
        for (item in list) {
            if (i == index) { result.add(value) }
            result.add(item)
            i = i + 1
        }
        if (i == index) { result.add(value) }
        result
    }

    private func removeAt(list: ArrayList<String>, index: Int64): ArrayList<String> {
        let result = ArrayList<String>()
        var i: Int64 = 0
        for (item in list) {
            if (i != index) { result.add(item) }
            i = i + 1
        }
        result
    }

    private func popLast(list: ArrayList<UndoEntry>): ArrayList<UndoEntry> {
        let result = ArrayList<UndoEntry>()
        for (i in 0..(list.size - 1)) { result.add(list[Int64(i)]) }
        result
    }

    private func popLastString(list: ArrayList<String>): ArrayList<String> {
        let result = ArrayList<String>()
        for (i in 0..(list.size - 1)) { result.add(list[Int64(i)]) }
        result
    }
}
