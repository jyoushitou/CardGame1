package cjform

import std.collection.*

class TabInfo {
    public let title: String
    public let content: Widget

    public init(title: String, content: Widget) {
        this.title = title
        this.content = content
    }
}

public struct TabViewStyle {
    public let barBackgroundColor: Color
    public let tabActiveBgColor: Color
    public let tabInactiveBgColor: Color
    public let tabHoverBgColor: Color
    public let tabActiveTextColor: Color
    public let tabInactiveTextColor: Color
    public let indicatorColor: Color
    public let tabBarHeight: Float32
    public let tabPadding: Float32
    public let isThemeBased: Bool

    public init() {
        this.barBackgroundColor = Color.WHITE
        this.tabActiveBgColor = Color.WHITE
        this.tabInactiveBgColor = Color.WHITE
        this.tabHoverBgColor = Color.WHITE
        this.tabActiveTextColor = Color.WHITE
        this.tabInactiveTextColor = Color.WHITE
        this.indicatorColor = Color.WHITE
        this.tabBarHeight = 34.0
        this.tabPadding = 4.0
        this.isThemeBased = false
    }

    public init(barBackgroundColor: Color, tabActiveBgColor: Color, tabInactiveBgColor: Color,
        tabHoverBgColor: Color, tabActiveTextColor: Color, tabInactiveTextColor: Color,
        indicatorColor: Color, tabBarHeight: Float32, tabPadding: Float32) {
        this.barBackgroundColor = barBackgroundColor
        this.tabActiveBgColor = tabActiveBgColor
        this.tabInactiveBgColor = tabInactiveBgColor
        this.tabHoverBgColor = tabHoverBgColor
        this.tabActiveTextColor = tabActiveTextColor
        this.tabInactiveTextColor = tabInactiveTextColor
        this.indicatorColor = indicatorColor
        this.tabBarHeight = tabBarHeight
        this.tabPadding = tabPadding
        this.isThemeBased = false
    }

    public init(isThemeBased: Bool) {
        this.barBackgroundColor = Color.WHITE
        this.tabActiveBgColor = Color.WHITE
        this.tabInactiveBgColor = Color.WHITE
        this.tabHoverBgColor = Color.WHITE
        this.tabActiveTextColor = Color.WHITE
        this.tabInactiveTextColor = Color.WHITE
        this.indicatorColor = Color.WHITE
        this.tabBarHeight = 34.0
        this.tabPadding = 4.0
        this.isThemeBased = isThemeBased
    }

    public static func fromTheme(): TabViewStyle { TabViewStyle(true) }
}

public class TabView <: Widget {
    private var tabs: ArrayList<TabInfo>
    private var activeIndex: Int32
    private var style: TabViewStyle
    private var hoveredTab: Int32
    private var layoutFrame: Option<LayoutFrame>
    private var tabPositions: ArrayList<LayoutFrame>

    public init() {
        this.tabs = ArrayList<TabInfo>()
        this.activeIndex = 0
        this.style = TabViewStyle.fromTheme()
        this.hoveredTab = -1
        this.layoutFrame = None
        this.tabPositions = ArrayList<LayoutFrame>()
    }

    public init(style: TabViewStyle) {
        this.tabs = ArrayList<TabInfo>()
        this.activeIndex = 0
        this.style = style
        this.hoveredTab = -1
        this.layoutFrame = None
        this.tabPositions = ArrayList<LayoutFrame>()
    }

    public static func styled(styleName: String): TabView {
        TabView(TabViewStyle.fromTheme())
    }

    public func addTab(title: String, content: Widget): Unit {
        tabs.add(TabInfo(title, content))
    }

    public func getActiveIndex(): Int32 { activeIndex }

    public func setActiveIndex(index: Int32): Unit {
        if (index >= 0 && index < Int32(tabs.size)) {
            activeIndex = index
        }
    }

    public func getTabCount(): Int32 { Int32(tabs.size) }

    public func getActiveContent(): Option<Widget> {
        if (activeIndex >= 0 && activeIndex < Int32(tabs.size)) {
            Some(tabs[Int64(activeIndex)].content)
        } else { None }
    }

    public func getAllTabContents(): ArrayList<Widget> {
        let result = ArrayList<Widget>()
        for (tab in tabs) {
            result.add(tab.content)
        }
        result
    }

    public func findLeafAt(x: Float32, y: Float32): Widget {
        ensureContentLayout()
        if (activeIndex >= 0 && activeIndex < Int32(tabs.size)) {
            let content = tabs[Int64(activeIndex)].content
            if (content.hitTest(x, y, 0.0, 0.0, 0.0, 0.0)) {
                content.findLeafAt(x, y)
            } else { this }
        } else { this }
    }

    private func getBarBackgroundColor(): Color { if (style.isThemeBased) { Theme.colors().bgSecondary } else { style.barBackgroundColor } }
    private func getTabActiveBgColor(): Color { if (style.isThemeBased) { Theme.colors().tabActiveBg } else { style.tabActiveBgColor } }
    private func getTabInactiveBgColor(): Color { if (style.isThemeBased) { Theme.colors().bgTertiary } else { style.tabInactiveBgColor } }
    private func getTabHoverBgColor(): Color { if (style.isThemeBased) { Theme.colors().tabInactiveBg } else { style.tabHoverBgColor } }
    private func getTabActiveTextColor(): Color { if (style.isThemeBased) { Theme.colors().tabActiveText } else { style.tabActiveTextColor } }
    private func getTabInactiveTextColor(): Color { if (style.isThemeBased) { Theme.colors().tabInactiveText } else { style.tabInactiveTextColor } }
    private func getIndicatorColor(): Color { if (style.isThemeBased) { Theme.colors().accent } else { style.indicatorColor } }
    private func getTabBarHeight(): Float32 { if (style.isThemeBased) { 34.0 } else { style.tabBarHeight } }
    private func getTabPadding(): Float32 { if (style.isThemeBased) { 4.0 } else { style.tabPadding } }

    public func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        let frameX = match (layoutFrame) { case Some(f) => f.x; case None => Float32(0.0) }
        let frameY = match (layoutFrame) { case Some(f) => f.y; case None => Float32(0.0) }
        let frameW = match (layoutFrame) { case Some(f) => f.width; case None => Float32(currentWidth) }
        let frameH = match (layoutFrame) { case Some(f) => f.height; case None => Float32(currentHeight) }
        canvas.fillRoundedRect(frameX, frameY, frameW, getTabBarHeight(), 0.0, getBarBackgroundColor())

        tabPositions = ArrayList<LayoutFrame>()
        var tabX: Float32 = frameX + getTabPadding()
        let maxTabW = (frameW - getTabPadding() * 2.0) / Float32(tabs.size)
        for (i in 0..tabs.size) {
            let title = tabs[i].title
            let textW = canvas.measureTextWidth(title, "Microsoft YaHei", 14.0) + 20.0
            let tabW = if (textW < maxTabW) { textW } else { maxTabW }
            if (tabW > maxTabW) { }
            tabPositions.add(LayoutFrame(tabX, frameY + 4.0, tabW, getTabBarHeight() - 4.0))
            tabX = tabX + tabW + 2.0
        }

        for (i in 0..tabs.size) {
            let pos = tabPositions[i]
            let isActive = Int32(i) == activeIndex
            let isHovered = Int32(i) == hoveredTab
            let bgColor = if (isActive) { getTabActiveBgColor() }
                else if (isHovered) { getTabHoverBgColor() }
                else { getTabInactiveBgColor() }
            let textColor = if (isActive) { getTabActiveTextColor() } else { getTabInactiveTextColor() }

            canvas.fillRoundedRect(pos.x, pos.y, pos.width, pos.height, 6.0, bgColor)

            if (isActive) {
                canvas.drawLine(pos.x + 4.0, pos.y + pos.height - 1.0, pos.x + pos.width - 4.0, pos.y + pos.height - 1.0, 2.0, getIndicatorColor())
            }

            canvas.drawTextAligned(pos.x + 4.0, pos.y, pos.width - 8.0, pos.height, tabs[i].title, "Microsoft YaHei", 14.0, 1, textColor)
        }

        let contentY = frameY + getTabBarHeight()
        let contentH = frameH - getTabBarHeight()
        if (contentH > 0.0 && activeIndex >= 0 && activeIndex < Int32(tabs.size)) {
            let content = tabs[Int64(activeIndex)].content
            content.setLayoutFrame(LayoutFrame(frameX, contentY, frameW, contentH))
            content.paint(canvas, initialWidth, initialHeight, currentWidth, currentHeight)
        }
    }

    public func hitTest(x: Float32, y: Float32, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool {
        match (layoutFrame) {
            case Some(f) => x >= f.x && x <= f.x + f.width && y >= f.y && y <= f.y + f.height
            case None => x >= 0.0 && x <= Float32(currentWidth) && y >= 0.0 && y <= Float32(currentHeight)
        }
    }

    private func ensureContentLayout(): Unit {
        if (activeIndex >= 0 && activeIndex < Int32(tabs.size)) {
            match (layoutFrame) {
                case Some(f) =>
                    let contentY = f.y + getTabBarHeight()
                    let contentH = f.height - getTabBarHeight()
                    if (contentH > 0.0) {
                        tabs[Int64(activeIndex)].content.setLayoutFrame(LayoutFrame(f.x, contentY, f.width, contentH))
                    }
                case None => ()
            }
        }
    }

    public func handleEvent(event: Event): Bool {
        let frameY = match (layoutFrame) { case Some(f) => f.y; case None => Float32(0.0) }

        match (event.eventType) {
            case EventType.MouseDown =>
                match (event.mouseEvent) {
                    case Some(me) =>
                        if (me.y >= frameY && me.y <= frameY + getTabBarHeight()) {
                            for (i in 0..tabPositions.size) {
                                let pos = tabPositions[i]
                                if (me.x >= pos.x && me.x <= pos.x + pos.width) {
                                    activeIndex = Int32(i)
                                    return true
                                }
                            }
                        }
                        if (activeIndex >= 0 && activeIndex < Int32(tabs.size)) {
                            tabs[Int64(activeIndex)].content.handleEvent(event)
                        }
                        true
                    case None => false
                }
            case EventType.MouseMove =>
                match (event.mouseEvent) {
                    case Some(me) =>
                        var newHovered: Int32 = -1
                        for (i in 0..tabPositions.size) {
                            let pos = tabPositions[i]
                            if (me.x >= pos.x && me.x <= pos.x + pos.width && me.y >= pos.y && me.y <= pos.y + pos.height) {
                                newHovered = Int32(i)
                                break
                            }
                        }
                        hoveredTab = newHovered

                        if (activeIndex >= 0 && activeIndex < Int32(tabs.size)) {
                            tabs[Int64(activeIndex)].content.handleEvent(event)
                        }
                        true
                    case None => false
                }
            case EventType.MouseUp =>
                if (activeIndex >= 0 && activeIndex < Int32(tabs.size)) {
                    tabs[Int64(activeIndex)].content.handleEvent(event)
                }
                true
            case _ =>
                if (activeIndex >= 0 && activeIndex < Int32(tabs.size)) {
                    tabs[Int64(activeIndex)].content.handleEvent(event)
                } else {
                    false
                }
        }
    }

    public func contains(x: Float32, y: Float32): Bool { true }
    public func updateAnimation(tickCount: Int64): Bool {
        if (activeIndex >= 0 && activeIndex < Int32(tabs.size)) {
            tabs[Int64(activeIndex)].content.updateAnimation(tickCount)
        } else {
            false
        }
    }

    public func getLayoutMinWidth(): Float32 { 300.0 }
    public func getLayoutMinHeight(): Float32 { 200.0 }
    public func setLayoutFrame(frame: LayoutFrame): Unit { this.layoutFrame = Some(frame) }
    public func clearLayoutFrame(): Unit { this.layoutFrame = None }
    public func getLayoutFrame(): Option<LayoutFrame> { layoutFrame }
}
