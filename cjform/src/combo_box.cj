package cjform

import std.collection.*

public struct ComboBoxStyle {
    public let backgroundColor: Color
    public let hoverBackgroundColor: Color
    public let borderColor: Color
    public let textColor: Color
    public let arrowColor: Color
    public let shadowColor: Color
    public let popupBgColor: Color
    public let popupBorderColor: Color
    public let popupItemHoverColor: Color
    public let popupSelectedTextColor: Color
    public let popupItemTextColor: Color
    public let cornerRadius: Float32
    public let borderWidth: Float32
    public let isThemeBased: Bool

    public init() {
        this.backgroundColor = Color.WHITE
        this.hoverBackgroundColor = Color.WHITE
        this.borderColor = Color.WHITE
        this.textColor = Color.WHITE
        this.arrowColor = Color.WHITE
        this.shadowColor = Color.WHITE
        this.popupBgColor = Color.WHITE
        this.popupBorderColor = Color.WHITE
        this.popupItemHoverColor = Color.WHITE
        this.popupSelectedTextColor = Color.WHITE
        this.popupItemTextColor = Color.WHITE
        this.cornerRadius = 4.0
        this.borderWidth = 1.0
        this.isThemeBased = false
    }

    public init(backgroundColor: Color, hoverBackgroundColor: Color, borderColor: Color,
        textColor: Color, arrowColor: Color, shadowColor: Color, popupBgColor: Color,
        popupBorderColor: Color, popupItemHoverColor: Color, popupSelectedTextColor: Color,
        popupItemTextColor: Color, cornerRadius: Float32, borderWidth: Float32) {
        this.backgroundColor = backgroundColor
        this.hoverBackgroundColor = hoverBackgroundColor
        this.borderColor = borderColor
        this.textColor = textColor
        this.arrowColor = arrowColor
        this.shadowColor = shadowColor
        this.popupBgColor = popupBgColor
        this.popupBorderColor = popupBorderColor
        this.popupItemHoverColor = popupItemHoverColor
        this.popupSelectedTextColor = popupSelectedTextColor
        this.popupItemTextColor = popupItemTextColor
        this.cornerRadius = cornerRadius
        this.borderWidth = borderWidth
        this.isThemeBased = false
    }

    public init(isThemeBased: Bool) {
        this.backgroundColor = Color.WHITE
        this.hoverBackgroundColor = Color.WHITE
        this.borderColor = Color.WHITE
        this.textColor = Color.WHITE
        this.arrowColor = Color.WHITE
        this.shadowColor = Color.WHITE
        this.popupBgColor = Color.WHITE
        this.popupBorderColor = Color.WHITE
        this.popupItemHoverColor = Color.WHITE
        this.popupSelectedTextColor = Color.WHITE
        this.popupItemTextColor = Color.WHITE
        this.cornerRadius = 4.0
        this.borderWidth = 1.0
        this.isThemeBased = isThemeBased
    }

    public static func fromTheme(): ComboBoxStyle { ComboBoxStyle(true) }
}

public class ComboBox <: Widget & Focusable {
    private var items: ArrayList<String>
    private var selectedIndex: Int32
    private var isOpen: Bool
    private var isHovered: Bool
    private var isFocused: Bool
    private var focusId: Int64
    private var hoveredItemIndex: Int32
    private var buttonHeight: Float32
    private var dropDownMaxHeight: Float32
    private var itemHeight: Float32
    private var _onSelectionChanged: Option<(Int32, String) -> Unit>
    private var layoutFrame: Option<LayoutFrame>
    private var parentWindow: Option<Window>
    private var style: ComboBoxStyle

    public init() {
        this.items = ArrayList<String>()
        this.selectedIndex = -1
        this.isOpen = false
        this.isHovered = false
        this.isFocused = false
        this.focusId = nextFocusId()
        this.hoveredItemIndex = -1
        this.buttonHeight = 30.0
        this.dropDownMaxHeight = 200.0
        this.itemHeight = 26.0
        this._onSelectionChanged = None<(Int32, String) -> Unit>
        this.layoutFrame = None
        this.parentWindow = None<Window>
        this.style = ComboBoxStyle.fromTheme()
    }

    public init(style: ComboBoxStyle) {
        this.items = ArrayList<String>()
        this.selectedIndex = -1
        this.isOpen = false
        this.isHovered = false
        this.isFocused = false
        this.focusId = nextFocusId()
        this.hoveredItemIndex = -1
        this.buttonHeight = 30.0
        this.dropDownMaxHeight = 200.0
        this.itemHeight = 26.0
        this._onSelectionChanged = None<(Int32, String) -> Unit>
        this.layoutFrame = None
        this.parentWindow = None<Window>
        this.style = style
    }

    public static func styled(styleName: String): ComboBox {
        ComboBox(ComboBoxStyle.fromTheme())
    }

    public func setItems(items: ArrayList<String>): Unit {
        this.items = items
        this.selectedIndex = -1
    }

    public func onSelectionChanged(cb: (Int32, String) -> Unit): ComboBox { this._onSelectionChanged = Some(cb); this }
    public func setOnSelectionChanged(callback: (Int32, String) -> Unit): Unit {
        this._onSelectionChanged = Some<(Int32, String) -> Unit>(callback)
    }

    public func getSelectedIndex(): Int32 { selectedIndex }

    public func setParentWindow(win: Window): Unit { this.parentWindow = Some(win) }

    public func focus(): Unit { isFocused = true }
    public func blur(): Unit { isFocused = false; if (isOpen) { closeDropdown() } }
    public func hasFocus(): Bool { isFocused }
    public func getFocusId(): Int64 { focusId }

    private func getSelectedLabel(): String {
        if (selectedIndex >= 0 && selectedIndex < Int32(items.size)) {
            items[Int64(selectedIndex)]
        } else {
            ""
        }
    }

    private func getBackgroundColor(): Color { if (style.isThemeBased) { Theme.colors().inputBg } else { style.backgroundColor } }
    private func getHoverBackgroundColor(): Color { if (style.isThemeBased) { Theme.colors().buttonHover } else { style.hoverBackgroundColor } }
    private func getBorderColor(): Color { if (style.isThemeBased) { Theme.colors().inputBorder } else { style.borderColor } }
    private func getTextColor(): Color { if (style.isThemeBased) { Theme.colors().textPrimary } else { style.textColor } }
    private func getArrowColor(): Color { if (style.isThemeBased) { Theme.colors().textSecondary } else { style.arrowColor } }
    private func getShadowColor(): Color { if (style.isThemeBased) { Theme.colors().shadow } else { style.shadowColor } }
    private func getPopupBgColor(): Color { if (style.isThemeBased) { Theme.colors().popupBg } else { style.popupBgColor } }
    private func getPopupBorderColor(): Color { if (style.isThemeBased) { Theme.colors().popupBorder } else { style.popupBorderColor } }
    private func getPopupItemHoverColor(): Color { if (style.isThemeBased) { Theme.colors().popupItemHover } else { style.popupItemHoverColor } }
    private func getPopupSelectedTextColor(): Color { if (style.isThemeBased) { Theme.colors().accent } else { style.popupSelectedTextColor } }
    private func getPopupItemTextColor(): Color { if (style.isThemeBased) { Theme.colors().popupItemText } else { style.popupItemTextColor } }
    private func getCornerRadius(): Float32 { if (style.isThemeBased) { 4.0 } else { style.cornerRadius } }
    private func getBorderWidth(): Float32 { if (style.isThemeBased) { 1.0 } else { style.borderWidth } }

    public func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        if (isOpen) {
            match (parentWindow) {
                case Some(win) =>
                    if (!win.hasOverlay()) { isOpen = false; hoveredItemIndex = -1 }
                case None => ()
            }
        }

        let frameX = match (layoutFrame) { case Some(f) => f.x; case None => Float32(0.0) }
        let frameY = match (layoutFrame) { case Some(f) => f.y; case None => Float32(0.0) }
        let frameW = match (layoutFrame) { case Some(f) => f.width; case None => Float32(200.0) }
        let bgColor = if (isHovered) { getHoverBackgroundColor() } else { getBackgroundColor() }
        canvas.fillRoundedRect(frameX, frameY, frameW, buttonHeight, getCornerRadius(), bgColor)
        canvas.drawRoundedRect(frameX, frameY, frameW, buttonHeight, getCornerRadius(), getBorderWidth(), getBorderColor())
        let label = getSelectedLabel()
        if (label.size > 0) {
            canvas.drawTextAligned(frameX + 8.0, frameY, frameW - 28.0, buttonHeight, label, "Microsoft YaHei", 13.0, 0, getTextColor())
        }
        let arrowX = frameX + frameW - 18.0
        let arrowY = frameY + buttonHeight / 2.0 - 3.0
        canvas.drawLine(arrowX, arrowY, arrowX + 8.0, arrowY, 1.5, getArrowColor())
        canvas.drawLine(arrowX + 2.0, arrowY + 3.0, arrowX + 6.0, arrowY + 3.0, 1.5, getArrowColor())
        canvas.drawLine(arrowX + 4.0, arrowY + 6.0, arrowX + 4.0, arrowY + 6.0, 1.5, getArrowColor())
        if (isOpen) {
            let (dropX, dropY) = getDropDownPosition(frameY)
            paintDropdown(canvas, initialWidth, initialHeight, currentWidth, currentHeight, dropX, dropY)
        }
    }

    public func paintDropdown(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32, dropX: Float32, dropY: Float32): Unit {
        let count = items.size
        let dropH = if (Float32(count) * itemHeight > dropDownMaxHeight) { dropDownMaxHeight } else { Float32(count) * itemHeight }

        canvas.drawShadow(dropX, dropY, Float32(200.0), dropH, 4.0, 6.0, 0.0, 4.0, getShadowColor())
        canvas.fillRoundedRect(dropX, dropY, Float32(200.0), dropH, 4.0, getPopupBgColor())
        canvas.drawRoundedRect(dropX, dropY, Float32(200.0), dropH, 4.0, 1.0, getPopupBorderColor())

        for (i in 0..count) {
            let itemY = dropY + Float32(i) * itemHeight
            let itemIdx = Int32(i)
            if (itemIdx == hoveredItemIndex || itemIdx == selectedIndex) {
                canvas.fillRoundedRect(dropX + 2.0, itemY + 1.0, Float32(196.0), itemHeight - 2.0, 3.0, getPopupItemHoverColor())
            }
            let textColor = if (itemIdx == selectedIndex) { getPopupSelectedTextColor() } else { getPopupItemTextColor() }
            canvas.drawTextAligned(dropX + 8.0, itemY, Float32(184.0), itemHeight, items[i], "Microsoft YaHei", 13.0, 0, textColor)
        }
    }

    public func hitTestDropdown(x: Float32, y: Float32, dropX: Float32, dropY: Float32): Bool {
        let count = items.size
        let dropH = if (Float32(count) * itemHeight > dropDownMaxHeight) { dropDownMaxHeight } else { Float32(count) * itemHeight }
        x >= dropX && x <= dropX + Float32(200.0) && y >= dropY && y <= dropY + dropH
    }

    public func handleDropdownClick(x: Float32, y: Float32, dropX: Float32, dropY: Float32): Bool {
        let relY = y - dropY
        let idx = Int32(relY / itemHeight)
        if (idx >= 0 && idx < Int32(items.size)) {
            selectedIndex = idx
            match (_onSelectionChanged) {
                case Some(cb) => cb(selectedIndex, items[Int64(selectedIndex)])
                case None => ()
            }
            return true
        }
        false
    }

    public func getDropDownPosition(frameY: Float32): (Float32, Float32) {
        let frameX = match (layoutFrame) { case Some(f) => f.x; case None => Float32(0.0) }
        (frameX, frameY + buttonHeight + 2.0)
    }

    public func hitTest(x: Float32, y: Float32, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool {
        match (layoutFrame) {
            case Some(f) =>
                let inButton = x >= f.x && x <= f.x + f.width && y >= f.y && y <= f.y + buttonHeight
                if (inButton) { return true }
                if (isOpen) {
                    let (dropX, dropY) = getDropDownPosition(f.y)
                    return hitTestDropdown(x, y, dropX, dropY)
                }
                false
            case None => false
        }
    }

    public func handleEvent(event: Event): Bool {
        if (isOpen) {
            return handleOpenEvent(event)
        }
        match (event.eventType) {
            case EventType.MouseEnter =>
                isHovered = true
                true
            case EventType.MouseLeave =>
                isHovered = false
                true
            case EventType.MouseUp =>
                openDropdown()
                true
            case _ => false
        }
    }

    private func openDropdown(): Unit {
        isOpen = true
        hoveredItemIndex = selectedIndex
        match (parentWindow) {
            case Some(win) => win.showOverlay(this)
            case None => ()
        }
    }

    private func closeDropdown(): Unit {
        isOpen = false
        hoveredItemIndex = -1
        match (parentWindow) {
            case Some(win) => win.dismissOverlay()
            case None => ()
        }
    }

    private func handleOpenEvent(event: Event): Bool {
        let frameX = match (layoutFrame) { case Some(f) => f.x; case None => Float32(0.0) }
        let frameY = match (layoutFrame) { case Some(f) => f.y; case None => Float32(0.0) }
        let (dropX, dropY) = getDropDownPosition(frameY)

        match (event.eventType) {
            case EventType.MouseMove =>
                match (event.mouseEvent) {
                    case Some(me) =>
                        if (hitTestDropdown(me.x, me.y, dropX, dropY)) {
                            let relY = me.y - dropY
                            hoveredItemIndex = Int32(relY / itemHeight)
                        } else {
                            hoveredItemIndex = -1
                        }
                    case None => ()
                }
                true
            case EventType.MouseUp =>
                match (event.mouseEvent) {
                    case Some(me) =>
                        if (hitTestDropdown(me.x, me.y, dropX, dropY)) {
                            handleDropdownClick(me.x, me.y, dropX, dropY)
                        }
                        closeDropdown()
                    case None => closeDropdown()
                }
                true
            case _ => false
        }
    }

    public func contains(x: Float32, y: Float32): Bool { true }
    public func updateAnimation(tickCount: Int64): Bool { false }
    public func findLeafAt(x: Float32, y: Float32): Widget { this }
    public func getLayoutMinWidth(): Float32 { 160.0 }
    public func getLayoutMinHeight(): Float32 { buttonHeight }
    public func setLayoutFrame(frame: LayoutFrame): Unit { this.layoutFrame = Some(frame) }
    public func clearLayoutFrame(): Unit { this.layoutFrame = None }
    public func getLayoutFrame(): Option<LayoutFrame> { layoutFrame }
}
