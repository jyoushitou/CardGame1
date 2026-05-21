package cjform

import std.collection.*

public class MenuItem {
    public let text: String
    public let shortcut: String
    public let isEnabled: Bool
    public var onClick: () -> Unit
    public let children: ArrayList<MenuItem>

    public init(text: String, onClick: () -> Unit, shortcut: String, isEnabled: Bool) {
        this.text = text
        this.onClick = onClick
        this.shortcut = shortcut
        this.isEnabled = isEnabled
        this.children = ArrayList<MenuItem>()
    }

    public init(text: String, onClick: () -> Unit) {
        this.text = text
        this.onClick = onClick
        this.shortcut = ""
        this.isEnabled = true
        this.children = ArrayList<MenuItem>()
    }

    public func addChild(item: MenuItem): MenuItem {
        children.add(item)
        this
    }

    public func setOnClick(cb: () -> Unit): MenuItem { this.onClick = cb; this }

    public static func separator(): MenuItem {
        MenuItem("", { => () }, "", false)
    }
}

public struct MenuBarStyle {
    public let backgroundColor: Color
    public let itemHoverColor: Color
    public let itemTextColor: Color
    public let itemDisabledTextColor: Color
    public let barHeight: Float32
    public let itemHeight: Float32
    public let itemPadding: Float32
    public let isThemeBased: Bool

    public init() {
        this.backgroundColor = Color.WHITE
        this.itemHoverColor = Color.WHITE
        this.itemTextColor = Color.WHITE
        this.itemDisabledTextColor = Color.WHITE
        this.barHeight = 28.0
        this.itemHeight = 24.0
        this.itemPadding = 12.0
        this.isThemeBased = false
    }

    public init(backgroundColor: Color, itemHoverColor: Color, itemTextColor: Color, itemDisabledTextColor: Color,
        barHeight: Float32, itemHeight: Float32, itemPadding: Float32) {
        this.backgroundColor = backgroundColor
        this.itemHoverColor = itemHoverColor
        this.itemTextColor = itemTextColor
        this.itemDisabledTextColor = itemDisabledTextColor
        this.barHeight = barHeight
        this.itemHeight = itemHeight
        this.itemPadding = itemPadding
        this.isThemeBased = false
    }

    public init(isThemeBased: Bool) {
        this.backgroundColor = Color.WHITE
        this.itemHoverColor = Color.WHITE
        this.itemTextColor = Color.WHITE
        this.itemDisabledTextColor = Color.WHITE
        this.barHeight = 28.0
        this.itemHeight = 24.0
        this.itemPadding = 12.0
        this.isThemeBased = isThemeBased
    }

    public static func fromTheme(): MenuBarStyle { MenuBarStyle(true) }
}

public class MenuBar <: Widget {
    private var items: ArrayList<MenuItem>
    private var hoveredIndex: Int32
    private var openIndex: Int32
    private var style: MenuBarStyle
    private var layoutFrame: Option<LayoutFrame>
    private var parentWindow: Option<Window>
    private var itemPositions: ArrayList<LayoutFrame>
    private var needsReposition: Bool

    public init() {
        this.items = ArrayList<MenuItem>()
        this.hoveredIndex = -1
        this.openIndex = -1
        this.style = MenuBarStyle.fromTheme()
        this.layoutFrame = None
        this.parentWindow = None<Window>
        this.itemPositions = ArrayList<LayoutFrame>()
        this.needsReposition = true
    }

    public init(style: MenuBarStyle) {
        this.items = ArrayList<MenuItem>()
        this.hoveredIndex = -1
        this.openIndex = -1
        this.style = style
        this.layoutFrame = None
        this.parentWindow = None<Window>
        this.itemPositions = ArrayList<LayoutFrame>()
        this.needsReposition = true
    }

    public static func styled(styleName: String): MenuBar {
        MenuBar(MenuBarStyle.fromTheme())
    }

    public func setParentWindow(win: Window): Unit { this.parentWindow = Some(win) }

    public func addMenu(label: String, onClick: () -> Unit): MenuItem {
        let item = MenuItem(label, onClick)
        items.add(item)
        item
    }

    public func addItem(item: MenuItem): Unit {
        items.add(item)
    }

    private func getBackgroundColor(): Color { if (style.isThemeBased) { Theme.colors().bgSecondary } else { style.backgroundColor } }
    private func getItemHoverColor(): Color { if (style.isThemeBased) { Theme.colors().buttonHover } else { style.itemHoverColor } }
    private func getItemTextColor(): Color { if (style.isThemeBased) { Theme.colors().textPrimary } else { style.itemTextColor } }
    private func getItemDisabledTextColor(): Color { if (style.isThemeBased) { Theme.colors().textTertiary } else { style.itemDisabledTextColor } }
    private func getBarHeight(): Float32 { if (style.isThemeBased) { 28.0 } else { style.barHeight } }
    private func getItemHeight(): Float32 { if (style.isThemeBased) { 24.0 } else { style.itemHeight } }
    private func getItemPadding(): Float32 { if (style.isThemeBased) { 12.0 } else { style.itemPadding } }

    public func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        let frameX = match (layoutFrame) { case Some(f) => f.x; case None => Float32(0.0) }
        let frameY = match (layoutFrame) { case Some(f) => f.y; case None => Float32(0.0) }
        let frameW = match (layoutFrame) { case Some(f) => f.width; case None => Float32(currentWidth) }
        canvas.fillRoundedRect(frameX, frameY, frameW, getBarHeight(), 0.0, getBackgroundColor())
        if (needsReposition || itemPositions.size != items.size) {
            itemPositions = ArrayList<LayoutFrame>()
            var x: Float32 = frameX + 4.0
            for (item in items) {
                let textW = canvas.measureTextWidth(item.text, "Microsoft YaHei", 13.0) + getItemPadding() * 2.0
                itemPositions.add(LayoutFrame(x, frameY + 2.0, textW, getBarHeight() - 4.0))
                x = x + textW + 2.0
            }
            needsReposition = false
        }

        for (i in 0..items.size) {
            let pos = itemPositions[i]
            let item = items[i]
            let idx = Int32(i)
            let isHovered = idx == hoveredIndex
            let isOpen = idx == openIndex

            if (isHovered || isOpen) {
                canvas.fillRoundedRect(pos.x, pos.y, pos.width, pos.height, 4.0, getItemHoverColor())
            }
            let textColor = if (item.isEnabled) { getItemTextColor() } else { getItemDisabledTextColor() }
            canvas.drawTextAligned(pos.x + getItemPadding(), pos.y, pos.width - getItemPadding() * 2.0, pos.height, item.text, "Microsoft YaHei", 13.0, 1, textColor)
        }
    }

    public func hitTest(x: Float32, y: Float32, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool {
        match (layoutFrame) {
            case Some(f) => x >= f.x && x <= f.x + f.width && y >= f.y && y <= f.y + getBarHeight()
            case None => false
        }
    }

    public func handleEvent(event: Event): Bool {
        match (event.eventType) {
            case EventType.MouseMove =>
                match (event.mouseEvent) {
                    case Some(me) =>
                        var newHovered: Int32 = -1
                        for (i in 0..itemPositions.size) {
                            let pos = itemPositions[i]
                            if (me.x >= pos.x && me.x <= pos.x + pos.width && me.y >= pos.y && me.y <= pos.y + pos.height) {
                                newHovered = Int32(i)
                                break
                            }
                        }
                        if (openIndex >= 0 && newHovered != openIndex && newHovered >= 0) {
                            closeMenu()
                            openMenu(newHovered)
                        }
                        hoveredIndex = newHovered
                        true
                    case None => false
                }
            case EventType.MouseDown =>
                match (event.mouseEvent) {
                    case Some(me) =>
                        for (i in 0..itemPositions.size) {
                            let pos = itemPositions[i]
                            if (me.x >= pos.x && me.x <= pos.x + pos.width && me.y >= pos.y && me.y <= pos.y + pos.height) {
                                let idx = Int32(i)
                                if (openIndex == idx) {
                                    closeMenu()
                                } else {
                                    if (openIndex >= 0) { closeMenu() }
                                    openMenu(idx)
                                }
                                return true
                            }
                        }
                        if (openIndex >= 0) { closeMenu() }
                        true
                    case None => false
                }
            case _ => false
        }
    }

    private func openMenu(index: Int32): Unit {
        if (index < 0 || index >= Int32(items.size)) { return }
        openIndex = index
        let menu = items[Int64(index)]
        if (menu.children.size == 0) {
            if (menu.isEnabled) { menu.onClick() }
            openIndex = -1
            return
        }
        match (parentWindow) {
            case Some(win) =>
                let pos = itemPositions[Int64(index)]
                let (fx, fy) = getMenuFrame()
                let drop = createDropDown(menu)
                drop.setPosition(pos.x, fy + getBarHeight())
                win.showOverlay(drop)
            case None => ()
        }
    }

    private func closeMenu(): Unit {
        openIndex = -1
        match (parentWindow) {
            case Some(win) => win.dismissOverlay()
            case None => ()
        }
    }

    private func getMenuFrame(): (Float32, Float32) {
        match (layoutFrame) {
            case Some(f) => (f.x, f.y)
            case None => (0.0, 0.0)
        }
    }

    private func createDropDown(menu: MenuItem): ContextMenu {
        let cm = ContextMenu()
        for (child in menu.children) {
            cm.addItem(child)
        }
        cm
    }

    public func contains(x: Float32, y: Float32): Bool { true }
    public func updateAnimation(tickCount: Int64): Bool { false }
    public func findLeafAt(x: Float32, y: Float32): Widget { this }
    public func getLayoutMinWidth(): Float32 { 300.0 }
    public func getLayoutMinHeight(): Float32 { getBarHeight() }
    public func setLayoutFrame(frame: LayoutFrame): Unit { this.layoutFrame = Some(frame) }
    public func clearLayoutFrame(): Unit { this.layoutFrame = None }
    public func getLayoutFrame(): Option<LayoutFrame> { layoutFrame }
}
