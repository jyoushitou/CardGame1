package cjform

import std.collection.*

public class Tooltip {
    public let text: String
    public let fontFamily: String
    public let fontSize: Float32
    public let bgColor: Color
    public let textColor: Color

    public init(text: String, fontFamily: String, fontSize: Float32) {
        this.text = text
        this.fontFamily = fontFamily
        this.fontSize = fontSize
        this.bgColor = Color.rgba(48, 48, 48, 230)
        this.textColor = Color.WHITE
    }

    public init(text: String, fontFamily: String, fontSize: Float32, bgColor: Color, textColor: Color) {
        this.text = text
        this.fontFamily = fontFamily
        this.fontSize = fontSize
        this.bgColor = bgColor
        this.textColor = textColor
    }
}

public class TooltipEntry {
    public let key: String
    public let tooltip: Tooltip

    public init(key: String, tooltip: Tooltip) {
        this.key = key
        this.tooltip = tooltip
    }
}
