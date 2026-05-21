package cjform

public struct Color {
    public let r: UInt8
    public let g: UInt8
    public let b: UInt8
    public let a: UInt8
    
    public init(r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
        this.r = r
        this.g = g
        this.b = b
        this.a = a
    }
    
    public static func rgb(r: UInt8, g: UInt8, b: UInt8): Color {
        Color(r, g, b, 255)
    }
    
    public static func rgba(r: UInt8, g: UInt8, b: UInt8, a: UInt8): Color {
        Color(r, g, b, a)
    }
    
    public static let WHITE = Color.rgb(255, 255, 255)
    public static let BLACK = Color.rgb(0, 0, 0)
    public static let RED = Color.rgb(255, 0, 0)
    public static let GREEN = Color.rgb(0, 255, 0)
    public static let BLUE = Color.rgb(0, 0, 255)
    public static let GRAY = Color.rgb(128, 128, 128)
    public static let LIGHT_GRAY = Color.rgb(240, 240, 240)
    public static let TRANSPARENT = Color.rgba(0, 0, 0, 0)
}
