package cjform

public enum PositionMode {
    | Absolute
    | Relative
}

public enum Anchor {
    | Center
    | TopLeft
    | TopCenter
    | TopRight
    | CenterLeft
    | CenterRight
    | BottomLeft
    | BottomCenter
    | BottomRight
}

public struct Position {
    public let x: Float32
    public let y: Float32
    public let mode: PositionMode
    
    public init(x: Float32, y: Float32, mode: PositionMode) {
        this.x = x
        this.y = y
        this.mode = mode
    }
    
    public static func abs(x: Float32, y: Float32): Position {
        Position(x, y, PositionMode.Absolute)
    }
    
    public static func rel(x: Float32, y: Float32): Position {
        Position(x, y, PositionMode.Relative)
    }
    
    public func resolveX(initialWidth: Float32, currentWidth: Float32): Float32 {
        match (mode) {
            case PositionMode.Absolute => x
            case PositionMode.Relative => x * currentWidth / initialWidth
        }
    }
    
    public func resolveY(initialHeight: Float32, currentHeight: Float32): Float32 {
        match (mode) {
            case PositionMode.Absolute => y
            case PositionMode.Relative => y * currentHeight / initialHeight
        }
    }
}

public struct SizeScale {
    public let scale: Bool
    
    public init(scale: Bool) {
        this.scale = scale
    }
    
    public static func fixed(): SizeScale {
        SizeScale(false)
    }
    
    public static func scalable(): SizeScale {
        SizeScale(true)
    }
    
    public func resolve(initialSize: Float32, currentSize: Float32, baseSize: Float32): Float32 {
        if (scale) {
            return baseSize * currentSize / initialSize
        } else {
            return baseSize
        }
    }
}
