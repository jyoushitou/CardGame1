package cjform

import std.collection.*

public enum EventType {
    | MouseMove
    | MouseDown
    | MouseUp
    | Click
    | MouseEnter
    | MouseLeave
    | KeyDown
    | KeyChar
    | FocusGain
    | FocusLost
    | MouseWheel
    | FileDrop
}

public struct MouseEvent {
    public let x: Float32
    public let y: Float32
    public let button: Int32

    public init(x: Float32, y: Float32, button: Int32) {
        this.x = x
        this.y = y
        this.button = button
    }
}

public struct MouseWheelEvent {
    public let x: Float32
    public let y: Float32
    public let delta: Int32

    public init(x: Float32, y: Float32, delta: Int32) {
        this.x = x
        this.y = y
        this.delta = delta
    }
}

public struct KeyEvent {
    public let keyCode: UInt32
    public let keyChar: Rune

    public init(keyCode: UInt32, keyChar: Rune) {
        this.keyCode = keyCode
        this.keyChar = keyChar
    }
}

public class Event {
    public let eventType: EventType
    public let mouseEvent: Option<MouseEvent>
    public let mouseWheelEvent: Option<MouseWheelEvent>
    public let keyEvent: Option<KeyEvent>
    public let fileDropEvent: Option<ArrayList<String>>
    public let hasCtrl: Bool
    public let hasShift: Bool
    public let hasAlt: Bool

    public init(eventType: EventType, mouseEvent: Option<MouseEvent>, mouseWheelEvent: Option<MouseWheelEvent>, keyEvent: Option<KeyEvent>, fileDropEvent: Option<ArrayList<String>>, hasCtrl: Bool, hasShift: Bool, hasAlt: Bool) {
        this.eventType = eventType
        this.mouseEvent = mouseEvent
        this.mouseWheelEvent = mouseWheelEvent
        this.keyEvent = keyEvent
        this.fileDropEvent = fileDropEvent
        this.hasCtrl = hasCtrl
        this.hasShift = hasShift
        this.hasAlt = hasAlt
    }

    public static func mouseMove(x: Float32, y: Float32): Event {
        Event(EventType.MouseMove, Some<MouseEvent>(MouseEvent(x, y, 0)), None<MouseWheelEvent>, None<KeyEvent>, None<ArrayList<String>>, false, false, false)
    }

    public static func mouseDown(x: Float32, y: Float32, button: Int32): Event {
        Event(EventType.MouseDown, Some<MouseEvent>(MouseEvent(x, y, button)), None<MouseWheelEvent>, None<KeyEvent>, None<ArrayList<String>>, false, false, false)
    }

    public static func mouseUp(x: Float32, y: Float32, button: Int32): Event {
        Event(EventType.MouseUp, Some<MouseEvent>(MouseEvent(x, y, button)), None<MouseWheelEvent>, None<KeyEvent>, None<ArrayList<String>>, false, false, false)
    }

    public static func click(x: Float32, y: Float32): Event {
        Event(EventType.Click, Some<MouseEvent>(MouseEvent(x, y, 0)), None<MouseWheelEvent>, None<KeyEvent>, None<ArrayList<String>>, false, false, false)
    }

    public static func mouseEnter(): Event {
        Event(EventType.MouseEnter, None<MouseEvent>, None<MouseWheelEvent>, None<KeyEvent>, None<ArrayList<String>>, false, false, false)
    }

    public static func mouseLeave(): Event {
        Event(EventType.MouseLeave, None<MouseEvent>, None<MouseWheelEvent>, None<KeyEvent>, None<ArrayList<String>>, false, false, false)
    }

    public static func keyDown(keyCode: UInt32, hasCtrl: Bool, hasShift: Bool, hasAlt: Bool): Event {
        Event(EventType.KeyDown, None<MouseEvent>, None<MouseWheelEvent>, Some<KeyEvent>(KeyEvent(keyCode, r'\0')), None<ArrayList<String>>, hasCtrl, hasShift, hasAlt)
    }

    public static func keyChar(keyChar: Rune, hasCtrl: Bool, hasShift: Bool, hasAlt: Bool): Event {
        Event(EventType.KeyChar, None<MouseEvent>, None<MouseWheelEvent>, Some<KeyEvent>(KeyEvent(0, keyChar)), None<ArrayList<String>>, hasCtrl, hasShift, hasAlt)
    }

    public static func focusGain(): Event {
        Event(EventType.FocusGain, None<MouseEvent>, None<MouseWheelEvent>, None<KeyEvent>, None<ArrayList<String>>, false, false, false)
    }

    public static func mouseWheel(x: Float32, y: Float32, delta: Int32): Event {
        Event(EventType.MouseWheel, None<MouseEvent>, Some<MouseWheelEvent>(MouseWheelEvent(x, y, delta)), None<KeyEvent>, None<ArrayList<String>>, false, false, false)
    }

    public static func focusLost(): Event {
        Event(EventType.FocusLost, None<MouseEvent>, None<MouseWheelEvent>, None<KeyEvent>, None<ArrayList<String>>, false, false, false)
    }

    public static func fileDrop(files: ArrayList<String>): Event {
        Event(EventType.FileDrop, None<MouseEvent>, None<MouseWheelEvent>, None<KeyEvent>, Some<ArrayList<String>>(files), false, false, false)
    }
}
