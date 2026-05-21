package cjform

public enum SizeMode {
    | Fixed
    | Fill
    | Intrinsic
    
    public operator func ==(right: SizeMode): Bool {
        match (this) {
            case SizeMode.Fixed =>
                match (right) {
                    case SizeMode.Fixed => true
                    case _ => false
                }
            case SizeMode.Fill =>
                match (right) {
                    case SizeMode.Fill => true
                    case _ => false
                }
            case SizeMode.Intrinsic =>
                match (right) {
                    case SizeMode.Intrinsic => true
                    case _ => false
                }
        }
    }
}

public enum LayoutAlign {
    | Start
    | Center
    | End
    | Stretch
}

public struct LayoutParams {
    public let widthMode: SizeMode
    public let heightMode: SizeMode
    public let widthValue: Float32
    public let heightValue: Float32
    public let expandH: Bool
    public let expandV: Bool
    public let alignH: LayoutAlign
    public let alignV: LayoutAlign
    public let margin: Float32
    public let weight: Float32
    
    public init() {
        this.widthMode = SizeMode.Intrinsic
        this.heightMode = SizeMode.Intrinsic
        this.widthValue = 0.0
        this.heightValue = 0.0
        this.expandH = false
        this.expandV = false
        this.alignH = LayoutAlign.Center
        this.alignV = LayoutAlign.Center
        this.margin = 0.0
        this.weight = 1.0
    }
    
    public init(widthMode: SizeMode, heightMode: SizeMode) {
        this.widthMode = widthMode
        this.heightMode = heightMode
        this.widthValue = 0.0
        this.heightValue = 0.0
        this.expandH = isFill(widthMode)
        this.expandV = isFill(heightMode)
        this.alignH = LayoutAlign.Center
        this.alignV = LayoutAlign.Center
        this.margin = 0.0
        this.weight = 1.0
    }
    
    private static func isFill(mode: SizeMode): Bool {
        match (mode) {
            case SizeMode.Fill => true
            case _ => false
        }
    }
    
    public init(width: Float32, height: Float32) {
        this.widthMode = SizeMode.Fixed
        this.heightMode = SizeMode.Fixed
        this.widthValue = width
        this.heightValue = height
        this.expandH = false
        this.expandV = false
        this.alignH = LayoutAlign.Center
        this.alignV = LayoutAlign.Center
        this.margin = 0.0
        this.weight = 1.0
    }
    
    public init(widthMode: SizeMode, heightMode: SizeMode, widthValue: Float32, heightValue: Float32, expandH: Bool, expandV: Bool, alignH: LayoutAlign, alignV: LayoutAlign, margin: Float32, weight: Float32) {
        this.widthMode = widthMode
        this.heightMode = heightMode
        this.widthValue = widthValue
        this.heightValue = heightValue
        this.expandH = expandH
        this.expandV = expandV
        this.alignH = alignH
        this.alignV = alignV
        this.margin = margin
        this.weight = weight
    }
    
    public static func fixed(width: Float32, height: Float32): LayoutParams {
        LayoutParams(width, height)
    }
    
    public static func fill(): LayoutParams {
        LayoutParams(SizeMode.Fill, SizeMode.Fill)
    }
    
    public static func intrinsic(): LayoutParams {
        LayoutParams(SizeMode.Intrinsic, SizeMode.Intrinsic)
    }
    
    public func withMargin(margin: Float32): LayoutParams {
        LayoutParams(
            widthMode, heightMode, widthValue, heightValue,
            expandH, expandV, alignH, alignV, margin, weight
        )
    }
    
    public func withWeight(weight: Float32): LayoutParams {
        LayoutParams(
            widthMode, heightMode, widthValue, heightValue,
            expandH, expandV, alignH, alignV, margin, weight
        )
    }
    
    public func withAlign(alignH: LayoutAlign, alignV: LayoutAlign): LayoutParams {
        LayoutParams(
            widthMode, heightMode, widthValue, heightValue,
            expandH, expandV, alignH, alignV, margin, weight
        )
    }
}

public struct LayoutFrame {
    public let x: Float32
    public let y: Float32
    public let width: Float32
    public let height: Float32

    public init(x: Float32, y: Float32, width: Float32, height: Float32) {
        this.x = x
        this.y = y
        this.width = width
        this.height = height
    }
}

public interface LayoutItem {
    func measure(availableWidth: Float32, availableHeight: Float32): Unit
    func layout(x: Float32, y: Float32, width: Float32, height: Float32): Unit
    func getMeasuredWidth(): Float32
    func getMeasuredHeight(): Float32
    func getLayoutParams(): LayoutParams
}
