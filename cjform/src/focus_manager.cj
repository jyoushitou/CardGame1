package cjform

import std.collection.*

private var focusIdCounter: Int64 = 0
public func nextFocusId(): Int64 { let id = focusIdCounter; focusIdCounter = focusIdCounter + 1; id }

public interface Focusable {
    func focus(): Unit
    func blur(): Unit
    func hasFocus(): Bool
    func getFocusId(): Int64
}

public class FocusManager {
    private static var instance: Option<FocusManager> = None<FocusManager>

    private var focusables: ArrayList<Focusable>
    private var currentFocusIndex: Int32

    private init() {
        this.focusables = ArrayList<Focusable>()
        this.currentFocusIndex = -1
    }

    public static func getInstance(): FocusManager {
        match (instance) {
            case Some(fm) => fm
            case None =>
                let fm = FocusManager()
                instance = Some<FocusManager>(fm)
                fm
        }
    }

    public func register(w: Focusable): Unit {
        focusables.add(w)
    }

    public func clearFocus(): Unit {
        if (currentFocusIndex >= 0 && currentFocusIndex < Int32(focusables.size)) {
            focusables[Int64(currentFocusIndex)].blur()
        }
        currentFocusIndex = -1
    }

    public func setFocus(w: Focusable): Unit {
        if (currentFocusIndex >= 0 && currentFocusIndex < Int32(focusables.size)) {
            let old = focusables[Int64(currentFocusIndex)]
            if (old.getFocusId() != w.getFocusId()) {
                old.blur()
            }
        }

        for (i in 0..focusables.size) {
            if (focusables[i].getFocusId() == w.getFocusId()) {
                currentFocusIndex = Int32(i)
                focusables[i].focus()
                return
            }
        }

        focusables.add(w)
        currentFocusIndex = Int32(focusables.size) - 1
        w.focus()
    }

    public func focusNext(): Unit {
        if (focusables.size == 0) { return }

        if (currentFocusIndex >= 0 && currentFocusIndex < Int32(focusables.size)) {
            focusables[Int64(currentFocusIndex)].blur()
        }

        if (currentFocusIndex < 0 || currentFocusIndex >= Int32(focusables.size) - 1) {
            currentFocusIndex = 0
        } else {
            currentFocusIndex = currentFocusIndex + 1
        }

        focusables[Int64(currentFocusIndex)].focus()
    }

    public func focusPrevious(): Unit {
        if (focusables.size == 0) { return }

        if (currentFocusIndex >= 0 && currentFocusIndex < Int32(focusables.size)) {
            focusables[Int64(currentFocusIndex)].blur()
        }

        if (currentFocusIndex <= 0) {
            currentFocusIndex = Int32(focusables.size) - 1
        } else {
            currentFocusIndex = currentFocusIndex - 1
        }

        focusables[Int64(currentFocusIndex)].focus()
    }

    public func getFocusedIndex(): Int32 { currentFocusIndex }
    public func hasFocusedWidget(): Bool { currentFocusIndex >= 0 }

    public func getFocused(): Option<Focusable> {
        if (currentFocusIndex >= 0 && currentFocusIndex < Int32(focusables.size)) {
            Some(focusables[Int64(currentFocusIndex)])
        } else {
            None<Focusable>
        }
    }
}
