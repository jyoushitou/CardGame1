package cjform

import std.collection.*

public struct ThemeColors {
    public let bgPrimary: Color
    public let bgSecondary: Color
    public let bgTertiary: Color
    public let textPrimary: Color
    public let textSecondary: Color
    public let textTertiary: Color
    public let accent: Color
    public let accentHover: Color
    public let accentPressed: Color
    public let border: Color
    public let borderFocused: Color
    public let danger: Color
    public let success: Color
    public let warning: Color
    public let shadow: Color
    public let inputBg: Color
    public let inputBorder: Color
    public let inputPlaceholder: Color
    public let buttonBg: Color
    public let buttonHover: Color
    public let buttonPressed: Color
    public let buttonText: Color
    public let sliderTrack: Color
    public let sliderFill: Color
    public let sliderThumb: Color
    public let progressTrack: Color
    public let progressFill: Color
    public let toggleTrack: Color
    public let toggleTrackOn: Color
    public let toggleThumb: Color
    public let separator: Color
    public let scrollbarTrack: Color
    public let scrollbarThumb: Color
    public let scrollbarThumbHover: Color
    public let tabActiveBg: Color
    public let tabInactiveBg: Color
    public let tabActiveText: Color
    public let tabInactiveText: Color
    public let tableHeaderBg: Color
    public let tableHeaderText: Color
    public let tableGridLine: Color
    public let tableSelectedBg: Color
    public let tableRowEven: Color
    public let tableRowOdd: Color
    public let popupBg: Color
    public let popupBorder: Color
    public let popupItemHover: Color
    public let popupItemText: Color
    public let popupItemTextSecondary: Color

    public init(
        bgPrimary: Color, bgSecondary: Color, bgTertiary: Color,
        textPrimary: Color, textSecondary: Color, textTertiary: Color,
        accent: Color, accentHover: Color, accentPressed: Color,
        border: Color, borderFocused: Color,
        danger: Color, success: Color, warning: Color, shadow: Color,
        inputBg: Color, inputBorder: Color, inputPlaceholder: Color,
        buttonBg: Color, buttonHover: Color, buttonPressed: Color, buttonText: Color,
        sliderTrack: Color, sliderFill: Color, sliderThumb: Color,
        progressTrack: Color, progressFill: Color,
        toggleTrack: Color, toggleTrackOn: Color, toggleThumb: Color,
        separator: Color,
        scrollbarTrack: Color, scrollbarThumb: Color, scrollbarThumbHover: Color,
        tabActiveBg: Color, tabInactiveBg: Color, tabActiveText: Color, tabInactiveText: Color,
        tableHeaderBg: Color, tableHeaderText: Color, tableGridLine: Color,
        tableSelectedBg: Color, tableRowEven: Color, tableRowOdd: Color,
        popupBg: Color, popupBorder: Color, popupItemHover: Color,
        popupItemText: Color, popupItemTextSecondary: Color
    ) {
        this.bgPrimary = bgPrimary
        this.bgSecondary = bgSecondary
        this.bgTertiary = bgTertiary
        this.textPrimary = textPrimary
        this.textSecondary = textSecondary
        this.textTertiary = textTertiary
        this.accent = accent
        this.accentHover = accentHover
        this.accentPressed = accentPressed
        this.border = border
        this.borderFocused = borderFocused
        this.danger = danger
        this.success = success
        this.warning = warning
        this.shadow = shadow
        this.inputBg = inputBg
        this.inputBorder = inputBorder
        this.inputPlaceholder = inputPlaceholder
        this.buttonBg = buttonBg
        this.buttonHover = buttonHover
        this.buttonPressed = buttonPressed
        this.buttonText = buttonText
        this.sliderTrack = sliderTrack
        this.sliderFill = sliderFill
        this.sliderThumb = sliderThumb
        this.progressTrack = progressTrack
        this.progressFill = progressFill
        this.toggleTrack = toggleTrack
        this.toggleTrackOn = toggleTrackOn
        this.toggleThumb = toggleThumb
        this.separator = separator
        this.scrollbarTrack = scrollbarTrack
        this.scrollbarThumb = scrollbarThumb
        this.scrollbarThumbHover = scrollbarThumbHover
        this.tabActiveBg = tabActiveBg
        this.tabInactiveBg = tabInactiveBg
        this.tabActiveText = tabActiveText
        this.tabInactiveText = tabInactiveText
        this.tableHeaderBg = tableHeaderBg
        this.tableHeaderText = tableHeaderText
        this.tableGridLine = tableGridLine
        this.tableSelectedBg = tableSelectedBg
        this.tableRowEven = tableRowEven
        this.tableRowOdd = tableRowOdd
        this.popupBg = popupBg
        this.popupBorder = popupBorder
        this.popupItemHover = popupItemHover
        this.popupItemText = popupItemText
        this.popupItemTextSecondary = popupItemTextSecondary
    }
}

public class Theme {
    private static var currentTheme: Option<Theme> = None<Theme>
    
    public let name: String
    public let themeColors: ThemeColors
    public let isDark: Bool
    private var onThemeChanged: ArrayList<() -> Unit>
    
    private init(name: String, themeColors: ThemeColors, isDark: Bool) {
        this.name = name
        this.themeColors = themeColors
        this.isDark = isDark
        this.onThemeChanged = ArrayList<() -> Unit>()
    }
    
    public static func light(): Theme {
        Theme("Light", ThemeColors(
            Color.rgb(255, 255, 255),
            Color.rgb(248, 249, 250),
            Color.rgb(240, 242, 245),
            Color.rgb(33, 37, 41),
            Color.rgb(73, 80, 87),
            Color.rgb(134, 142, 150),
            Color.rgb(0, 123, 255),
            Color.rgb(0, 111, 230),
            Color.rgb(0, 99, 204),
            Color.rgb(222, 226, 230),
            Color.rgb(0, 123, 255),
            Color.rgb(220, 53, 69),
            Color.rgb(40, 167, 69),
            Color.rgb(255, 193, 7),
            Color.rgba(0, 0, 0, 25),
            Color.rgb(255, 255, 255),
            Color.rgb(206, 212, 218),
            Color.rgb(173, 181, 189),
            Color.rgb(0, 123, 255),
            Color.rgb(0, 111, 230),
            Color.rgb(0, 99, 204),
            Color.rgb(255, 255, 255),
            Color.rgb(222, 226, 230),
            Color.rgb(0, 123, 255),
            Color.rgb(255, 255, 255),
            Color.rgb(233, 236, 239),
            Color.rgb(0, 123, 255),
            Color.rgb(206, 212, 218),
            Color.rgb(0, 123, 255),
            Color.WHITE,
            Color.rgb(222, 226, 230),
            Color.rgba(0, 0, 0, 6), Color.rgba(0, 0, 0, 60), Color.rgba(0, 0, 0, 90),
            Color.rgb(255, 255, 255), Color.rgb(240, 242, 245), Color.rgb(33, 37, 41), Color.rgb(134, 142, 150),
            Color.rgb(248, 249, 250), Color.rgb(33, 37, 41), Color.rgba(0, 0, 0, 20),
            Color.rgba(0, 123, 255, 30), Color.rgb(255, 255, 255), Color.rgb(248, 249, 250),
            Color.rgb(255, 255, 255), Color.rgb(222, 226, 230), Color.rgba(0, 123, 255, 30),
            Color.rgb(33, 37, 41), Color.rgb(134, 142, 150)
        ), false)
    }
    
    public static func dark(): Theme {
        Theme("Dark", ThemeColors(
            Color.rgb(30, 30, 30),
            Color.rgb(45, 45, 45),
            Color.rgb(60, 60, 60),
            Color.rgb(255, 255, 255),
            Color.rgb(200, 200, 200),
            Color.rgb(150, 150, 150),
            Color.rgb(100, 149, 237),
            Color.rgb(120, 169, 255),
            Color.rgb(80, 129, 217),
            Color.rgb(80, 80, 80),
            Color.rgb(100, 149, 237),
            Color.rgb(239, 83, 80),
            Color.rgb(102, 187, 106),
            Color.rgb(255, 183, 77),
            Color.rgba(0, 0, 0, 100),
            Color.rgb(45, 45, 45),
            Color.rgb(80, 80, 80),
            Color.rgb(120, 120, 120),
            Color.rgb(100, 149, 237),
            Color.rgb(120, 169, 255),
            Color.rgb(80, 129, 217),
            Color.rgb(255, 255, 255),
            Color.rgb(80, 80, 80),
            Color.rgb(100, 149, 237),
            Color.rgb(200, 200, 200),
            Color.rgb(60, 60, 60),
            Color.rgb(100, 149, 237),
            Color.rgb(70, 70, 70),
            Color.rgb(100, 149, 237),
            Color.rgb(200, 200, 200),
            Color.rgb(60, 60, 60),
            Color.rgba(255, 255, 255, 8), Color.rgba(255, 255, 255, 60), Color.rgba(255, 255, 255, 90),
            Color.rgb(45, 45, 45), Color.rgb(60, 60, 60), Color.rgb(255, 255, 255), Color.rgb(150, 150, 150),
            Color.rgb(60, 60, 60), Color.rgb(255, 255, 255), Color.rgba(255, 255, 255, 15),
            Color.rgba(100, 149, 237, 30), Color.rgb(45, 45, 45), Color.rgb(52, 52, 52),
            Color.rgb(45, 45, 45), Color.rgb(80, 80, 80), Color.rgba(100, 149, 237, 25),
            Color.rgb(255, 255, 255), Color.rgb(150, 150, 150)
        ), true)
    }
    
    public static func getCurrent(): Theme {
        match (currentTheme) {
            case Some(t) => t
            case None =>
                let t = dark()
                currentTheme = Some<Theme>(t)
                t
        }
    }
    
    public static func setCurrent(theme: Theme): Unit {
        currentTheme = Some<Theme>(theme)
        match (currentTheme) {
            case Some(t) =>
                for (callback in t.onThemeChanged) {
                    callback()
                }
            case None => ()
        }
    }
    
    public static func toggle(): Unit {
        let current = getCurrent()
        if (current.isDark) {
            setCurrent(light())
        } else {
            setCurrent(dark())
        }
    }
    
    public func onThemeChange(callback: () -> Unit): Unit {
        onThemeChanged.add(callback)
    }
    
    public static func colors(): ThemeColors {
        getCurrent().themeColors
    }
}
