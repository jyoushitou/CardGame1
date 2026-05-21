package cjform

public struct Shadow {
    public let hasShadow: Bool
    public let blurRadius: Float32
    public let offsetX: Float32
    public let offsetY: Float32
    public let color: Color
    
    public init(hasShadow: Bool, blurRadius: Float32, offsetX: Float32, offsetY: Float32, color: Color) {
        this.hasShadow = hasShadow
        this.blurRadius = blurRadius
        this.offsetX = offsetX
        this.offsetY = offsetY
        this.color = color
    }
    
    public static func none(): Shadow {
        Shadow(false, 0.0, 0.0, 0.0, Color.TRANSPARENT)
    }
    
    public static func simple(blurRadius: Float32, offsetX: Float32, offsetY: Float32, color: Color): Shadow {
        Shadow(true, blurRadius, offsetX, offsetY, color)
    }
    
    public static func defaultShadow(): Shadow {
        Shadow(true, 5.0, 2.0, 2.0, Color.rgba(0, 0, 0, 100))
    }
}
