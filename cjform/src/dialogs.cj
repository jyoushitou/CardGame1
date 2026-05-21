package cjform

import std.collection.*

class ShortcutEntry {
    public let keyCode: UInt32
    public let ctrl: Bool
    public let shift: Bool
    public let alt: Bool
    public let action: () -> Unit
    public init(keyCode: UInt32, ctrl: Bool, shift: Bool, alt: Bool, action: () -> Unit) {
        this.keyCode = keyCode; this.ctrl = ctrl; this.shift = shift; this.alt = alt; this.action = action
    }
}

public class ShortcutManager {
    private static var instance: Option<ShortcutManager> = None<ShortcutManager>
    private var shortcuts: ArrayList<ShortcutEntry>

    private init() { this.shortcuts = ArrayList<ShortcutEntry>() }

    public static func getInstance(): ShortcutManager {
        match (instance) {
            case Some(sm) => sm
            case None =>
                let sm = ShortcutManager()
                instance = Some(sm)
                sm
        }
    }

    public func register(keyCode: UInt32, ctrl: Bool, shift: Bool, alt: Bool, action: () -> Unit): Unit {
        shortcuts.add(ShortcutEntry(keyCode, ctrl, shift, alt, action))
    }

    public func registerChar(keyChar: UInt16, ctrl: Bool, shift: Bool, action: () -> Unit): Unit {
        shortcuts.add(ShortcutEntry(UInt32(keyChar), ctrl, shift, false, action))
    }

    public func handleKey(keyCode: UInt32, keyChar: UInt16, ctrl: Bool, shift: Bool, alt: Bool): Bool {
        for (entry in shortcuts) {
            if (entry.ctrl == ctrl && entry.shift == shift && entry.alt == alt) {
                if (entry.keyCode == keyCode) {
                    entry.action()
                    return true
                }
            }
        }
        if (keyChar != 0) {
            for (entry in shortcuts) {
                if (entry.ctrl == ctrl && entry.shift == shift && entry.alt == alt) {
                    if (entry.keyCode == UInt32(keyChar)) {
                        entry.action()
                        return true
                    }
                }
            }
        }
        false
    }

    public func clear(): Unit { shortcuts = ArrayList<ShortcutEntry>() }

    public func unregister(keyCode: UInt32, ctrl: Bool, shift: Bool, alt: Bool): Bool {
        for (i in 0..shortcuts.size) {
            let e = shortcuts[i]
            if (e.keyCode == keyCode && e.ctrl == ctrl && e.shift == shift && e.alt == alt) {
                let newList = ArrayList<ShortcutEntry>()
                for (j in 0..shortcuts.size) {
                    if (j != i) { newList.add(shortcuts[j]) }
                }
                shortcuts = newList
                return true
            }
        }
        false
    }

    public func saveConfig(): Unit {
        for (i in 0..shortcuts.size) {
            let e = shortcuts[i]
            let sn = "shortcut_${i}"
            ffi_configWriteInt(sn, "keyCode", Int32(e.keyCode))
            ffi_configWriteInt(sn, "ctrl", if (e.ctrl) { 1 } else { 0 })
            ffi_configWriteInt(sn, "shift", if (e.shift) { 1 } else { 0 })
            ffi_configWriteInt(sn, "alt", if (e.alt) { 1 } else { 0 })
        }
    }

    public func loadConfig(actionMap: (String) -> Option<() -> Unit>): Unit {
        var i: Int32 = 0
        while (true) {
            let sn = "shortcut_${i}"
            let keyCode = ffi_configReadInt(sn, "keyCode", -1)
            if (keyCode < 0) { break }
            let ctrl = ffi_configReadInt(sn, "ctrl", 0) != 0
            let shift = ffi_configReadInt(sn, "shift", 0) != 0
            let alt = ffi_configReadInt(sn, "alt", 0) != 0
            let actionName = "shortcut_${i}"
            match (actionMap(actionName)) {
                case Some(action) => register(UInt32(keyCode), ctrl, shift, alt, action)
                case None => ()
            }
            i = i + 1
        }
    }
}

public enum MessageBoxIcon {
    | Info
    | Warning
    | Error
    | Question
}

public enum MessageBoxButtons {
    | Ok
    | OkCancel
    | YesNo
    | YesNoCancel
}

public enum MessageBoxResult {
    | Ok_
    | Cancel
    | Yes
    | No
}

public func showMessageBox(title: String, message: String, icon: MessageBoxIcon, buttons: MessageBoxButtons): MessageBoxResult {
    let dlgW: Int32 = 400
    let dlgH: Int32 = 180
    let dlg = MessageBoxDialog(title, message, icon, buttons)
    let win = Window(title, dlgW, dlgH)
    win.setMinSize(dlgW, dlgH)
    win.setResizable(false)
    win.setBackgroundColor(Theme.colors().bgSecondary)
    win.addWidget(dlg)
    win.show()
    win.run()

    dlg.getResult()
}

class MessageBoxDialog <: Widget {
    private let title: String
    private let message: String
    private let icon: MessageBoxIcon
    private let buttons: MessageBoxButtons
    private var result: MessageBoxResult
    private var btnHover: Int32
    private var layoutFrame: Option<LayoutFrame>

    public init(title: String, message: String, icon: MessageBoxIcon, buttons: MessageBoxButtons) {
        this.title = title
        this.message = message
        this.icon = icon
        this.buttons = buttons
        this.result = MessageBoxResult.Ok_
        this.btnHover = -1
        this.layoutFrame = None
    }

    public func getResult(): MessageBoxResult { result }

    public func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        let (_, _, w, h) = getFrame()
        let c = Theme.colors()
        let pad: Float32 = 20.0
        let btnH: Float32 = 30.0
        let btnW: Float32 = 80.0
        let f4 = Float32(4.0)
        let f8 = Float32(8.0)
        let f16 = Float32(16.0)
        canvas.drawText(pad, pad + f4, message, "Microsoft YaHei", Float32(14.0), c.textPrimary)
        let btnY = h - btnH - f16
        let btnCount = match (buttons) {
            case MessageBoxButtons.Ok => 1
            case MessageBoxButtons.OkCancel => 2
            case MessageBoxButtons.YesNo => 2
            case MessageBoxButtons.YesNoCancel => 3
        }

        var btnIdx: Int32 = 0
        let totalBtnW = Float32(btnCount) * btnW + Float32(btnCount - 1) * f8
        var btnX = (w - totalBtnW) / Float32(2.0)

        match (buttons) {
            case MessageBoxButtons.Ok =>
                paintButton(canvas, btnX, btnY, btnW, btnH, "OK", btnIdx == btnHover, c)
            case MessageBoxButtons.OkCancel =>
                paintButton(canvas, btnX, btnY, btnW, btnH, "OK", btnIdx == btnHover, c)
                btnIdx = btnIdx + 1; btnX = btnX + btnW + f8
                paintButton(canvas, btnX, btnY, btnW, btnH, "Cancel", btnIdx == btnHover, c)
            case MessageBoxButtons.YesNo =>
                paintButton(canvas, btnX, btnY, btnW, btnH, "Yes", btnIdx == btnHover, c)
                btnIdx = btnIdx + 1; btnX = btnX + btnW + f8
                paintButton(canvas, btnX, btnY, btnW, btnH, "No", btnIdx == btnHover, c)
            case MessageBoxButtons.YesNoCancel =>
                paintButton(canvas, btnX, btnY, btnW, btnH, "Yes", btnIdx == btnHover, c)
                btnIdx = btnIdx + 1; btnX = btnX + btnW + f8
                paintButton(canvas, btnX, btnY, btnW, btnH, "No", btnIdx == btnHover, c)
                btnIdx = btnIdx + 1; btnX = btnX + btnW + f8
                paintButton(canvas, btnX, btnY, btnW, btnH, "Cancel", btnIdx == btnHover, c)
        }
    }

    private func paintButton(canvas: Canvas, x: Float32, y: Float32, w: Float32, h: Float32, label: String, hovered: Bool, c: ThemeColors): Unit {
        let bg = if (hovered) { c.buttonHover } else { c.buttonBg }
        canvas.fillRoundedRect(x, y, w, h, Float32(4.0), bg)
        canvas.drawRoundedRect(x, y, w, h, Float32(4.0), Float32(1.0), c.border)
        canvas.drawTextAligned(x, y, w, h, label, "Microsoft YaHei", Float32(13.0), 1, c.textPrimary)
    }

    public func hitTest(x: Float32, y: Float32, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool { true }

    public func handleEvent(event: Event): Bool {
        match (event.eventType) {
            case EventType.MouseMove =>
                match (event.mouseEvent) {
                    case Some(me) =>
                        btnHover = getButtonAt(me.x, me.y)
                        true
                    case None => false
                }
            case EventType.MouseUp =>
                match (event.mouseEvent) {
                    case Some(me) =>
                        let idx = getButtonAt(me.x, me.y)
                        match (buttons) {
                            case MessageBoxButtons.Ok => if (idx == 0) { result = MessageBoxResult.Ok_ }
                            case MessageBoxButtons.OkCancel =>
                                if (idx == 0) { result = MessageBoxResult.Ok_ }
                                else if (idx == 1) { result = MessageBoxResult.Cancel }
                            case MessageBoxButtons.YesNo =>
                                if (idx == 0) { result = MessageBoxResult.Yes }
                                else if (idx == 1) { result = MessageBoxResult.No }
                            case MessageBoxButtons.YesNoCancel =>
                                if (idx == 0) { result = MessageBoxResult.Yes }
                                else if (idx == 1) { result = MessageBoxResult.No }
                                else if (idx == 2) { result = MessageBoxResult.Cancel }
                        }
                        unsafe { bridge_post_quit() }
                        true
                    case None => false
                }
            case _ => false
        }
    }

    private func getButtonAt(mx: Float32, my: Float32): Int32 {
        let (_, _, w, h) = getFrame()
        let btnH: Float32 = 30.0
        let btnW: Float32 = 80.0
        let btnY = h - btnH - 16.0
        let btnCount = match (buttons) {
            case MessageBoxButtons.Ok => 1
            case MessageBoxButtons.OkCancel => 2
            case MessageBoxButtons.YesNo => 2
            case MessageBoxButtons.YesNoCancel => 3
        }
        let totalBtnW = Float32(btnCount) * btnW + Float32(btnCount - 1) * 8.0
        var btnX = (w - totalBtnW) / 2.0
        for (i in 0..btnCount) {
            if (mx >= btnX && mx <= btnX + btnW && my >= btnY && my <= btnY + btnH) {
                return Int32(i)
            }
            btnX = btnX + btnW + Float32(8.0)
        }
        Int32(-1)
    }

    private func getFrame(): (Float32, Float32, Float32, Float32) {
        (0.0, 0.0, 400.0, 180.0)
    }

    public func contains(x: Float32, y: Float32): Bool { true }
    public func updateAnimation(tickCount: Int64): Bool { false }
    public func findLeafAt(x: Float32, y: Float32): Widget { this }
    public func getLayoutMinWidth(): Float32 { 400.0 }
    public func getLayoutMinHeight(): Float32 { 180.0 }
    public func setLayoutFrame(frame: LayoutFrame): Unit { this.layoutFrame = Some(frame) }
    public func clearLayoutFrame(): Unit { this.layoutFrame = None }
    public func getLayoutFrame(): Option<LayoutFrame> { layoutFrame }
}

public func showOpenDialog(win: Window, title: String, filter: String): Option<String> {
    ffi_showOpenDialog(win.getHandle(), title, filter, false)
}

public func showSaveDialog(win: Window, title: String, filter: String, defaultName: String): Option<String> {
    ffi_showSaveDialog(win.getHandle(), title, filter, defaultName)
}
