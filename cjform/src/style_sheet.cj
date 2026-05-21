package cjform

import std.collection.*

public struct StyleProperties {
    public let fontFamily: Option<String>
    public let fontSize: Option<Float32>
    public let sizeScale: Option<SizeScale>
    public let anchor: Option<Anchor>
    public let cornerRadius: Option<Float32>

    public init() {
        this.fontFamily = None
        this.fontSize = None
        this.sizeScale = None
        this.anchor = None
        this.cornerRadius = None
    }

    public init(fontFamily: Option<String>, fontSize: Option<Float32>, sizeScale: Option<SizeScale>, anchor: Option<Anchor>, cornerRadius: Option<Float32>) {
        this.fontFamily = fontFamily
        this.fontSize = fontSize
        this.sizeScale = sizeScale
        this.anchor = anchor
        this.cornerRadius = cornerRadius
    }

    public func withFontFamily(f: String): StyleProperties {
        StyleProperties(Some(f), fontSize, sizeScale, anchor, cornerRadius)
    }

    public func withFontSize(s: Float32): StyleProperties {
        StyleProperties(fontFamily, Some(s), sizeScale, anchor, cornerRadius)
    }

    public func withSizeScale(s: SizeScale): StyleProperties {
        StyleProperties(fontFamily, fontSize, Some(s), anchor, cornerRadius)
    }

    public func withAnchor(a: Anchor): StyleProperties {
        StyleProperties(fontFamily, fontSize, sizeScale, Some(a), cornerRadius)
    }

    public func withCornerRadius(r: Float32): StyleProperties {
        StyleProperties(fontFamily, fontSize, sizeScale, anchor, Some(r))
    }
}

struct StyleEntry {
    public let name: String
    public let props: StyleProperties

    public init(name: String, props: StyleProperties) {
        this.name = name
        this.props = props
    }
}

public class StyleSheet {
    private static var defaultSheet: Option<StyleSheet> = None

    private var entries: ArrayList<StyleEntry>

    public init() {
        this.entries = ArrayList<StyleEntry>()
    }

    public func define(name: String, props: StyleProperties): StyleSheet {
        for (i in 0..entries.size) {
            if (entries[i].name == name) {
                entries[i] = StyleEntry(name, props)
                return this
            }
        }
        entries.add(StyleEntry(name, props))
        this
    }

    public func resolve(name: String): StyleProperties {
        for (i in 0..entries.size) {
            if (entries[i].name == name) {
                return entries[i].props
            }
        }
        StyleProperties()
    }

    public static func getDefault(): StyleSheet {
        match (defaultSheet) {
            case Some(s) => s
            case None =>
                let s = StyleSheet()
                defaultSheet = Some(s)
                s
        }
    }
}
