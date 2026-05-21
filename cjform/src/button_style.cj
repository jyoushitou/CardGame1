package cjform

public enum TextAlignment {
    | Left
    | Center
    | Right
}

public struct ButtonStyle {
    public let cornerRadius: Float32
    public let hasBorder: Bool
    public let borderWidth: Float32
    public let backgroundColor: Color
    public let hoverBackgroundColor: Color
    public let pressBackgroundColor: Color
    public let borderColor: Color
    public let hoverBorderColor: Color
    public let pressBorderColor: Color
    public let textColor: Color
    public let hoverTextColor: Color
    public let pressTextColor: Color
    public let textAlignment: TextAlignment
    public let shadow: Shadow
    public let isThemeBased: Bool
    public let isOutlined: Bool
    
    public init(cornerRadius: Float32, hasBorder: Bool, borderWidth: Float32, 
                backgroundColor: Color, hoverBackgroundColor: Color, pressBackgroundColor: Color,
                borderColor: Color, hoverBorderColor: Color, pressBorderColor: Color,
                textColor: Color, hoverTextColor: Color, pressTextColor: Color,
                textAlignment: TextAlignment, shadow: Shadow) {
        this.cornerRadius = cornerRadius
        this.hasBorder = hasBorder
        this.borderWidth = borderWidth
        this.backgroundColor = backgroundColor
        this.hoverBackgroundColor = hoverBackgroundColor
        this.pressBackgroundColor = pressBackgroundColor
        this.borderColor = borderColor
        this.hoverBorderColor = hoverBorderColor
        this.pressBorderColor = pressBorderColor
        this.textColor = textColor
        this.hoverTextColor = hoverTextColor
        this.pressTextColor = pressTextColor
        this.textAlignment = textAlignment
        this.shadow = shadow
        this.isThemeBased = false
        this.isOutlined = false
    }
    
    public init(cornerRadius: Float32, hasBorder: Bool, borderWidth: Float32, 
                backgroundColor: Color, hoverBackgroundColor: Color, pressBackgroundColor: Color,
                borderColor: Color, hoverBorderColor: Color, pressBorderColor: Color,
                textColor: Color, hoverTextColor: Color, pressTextColor: Color,
                textAlignment: TextAlignment, shadow: Shadow,
                isThemeBased: Bool, isOutlined: Bool) {
        this.cornerRadius = cornerRadius
        this.hasBorder = hasBorder
        this.borderWidth = borderWidth
        this.backgroundColor = backgroundColor
        this.hoverBackgroundColor = hoverBackgroundColor
        this.pressBackgroundColor = pressBackgroundColor
        this.borderColor = borderColor
        this.hoverBorderColor = hoverBorderColor
        this.pressBorderColor = pressBorderColor
        this.textColor = textColor
        this.hoverTextColor = hoverTextColor
        this.pressTextColor = pressTextColor
        this.textAlignment = textAlignment
        this.shadow = shadow
        this.isThemeBased = isThemeBased
        this.isOutlined = isOutlined
    }
    
    public static func default(): ButtonStyle {
        ButtonStyle(
            0.0,
            false,
            1.0,
            Color.rgb(200, 200, 200),
            Color.rgb(220, 220, 220),
            Color.rgb(180, 180, 180),
            Color.BLACK,
            Color.BLACK,
            Color.BLACK,
            Color.BLACK,
            Color.BLACK,
            Color.BLACK,
            TextAlignment.Center,
            Shadow.none()
        )
    }
    
    public static func rounded(radius: Float32): ButtonStyle {
        ButtonStyle(
            radius,
            false,
            1.0,
            Color.rgb(200, 200, 200),
            Color.rgb(220, 220, 220),
            Color.rgb(180, 180, 180),
            Color.BLACK,
            Color.BLACK,
            Color.BLACK,
            Color.BLACK,
            Color.BLACK,
            Color.BLACK,
            TextAlignment.Center,
            Shadow.none()
        )
    }
    
    public static func bordered(borderWidth: Float32, borderColor: Color): ButtonStyle {
        ButtonStyle(
            0.0,
            true,
            borderWidth,
            Color.rgb(255, 255, 255),
            Color.rgb(255, 255, 255),
            Color.rgb(240, 240, 240),
            borderColor,
            borderColor,
            borderColor,
            Color.BLACK,
            Color.BLACK,
            Color.BLACK,
            TextAlignment.Center,
            Shadow.none()
        )
    }
    
    public static func roundedBordered(radius: Float32, borderWidth: Float32, borderColor: Color): ButtonStyle {
        ButtonStyle(
            radius,
            true,
            borderWidth,
            Color.rgb(255, 255, 255),
            Color.rgb(255, 255, 255),
            Color.rgb(240, 240, 240),
            borderColor,
            borderColor,
            borderColor,
            Color.BLACK,
            Color.BLACK,
            Color.BLACK,
            TextAlignment.Center,
            Shadow.none()
        )
    }
    
    public static func withShadow(style: ButtonStyle, shadow: Shadow): ButtonStyle {
        ButtonStyle(
            style.cornerRadius,
            style.hasBorder,
            style.borderWidth,
            style.backgroundColor,
            style.hoverBackgroundColor,
            style.pressBackgroundColor,
            style.borderColor,
            style.hoverBorderColor,
            style.pressBorderColor,
            style.textColor,
            style.hoverTextColor,
            style.pressTextColor,
            style.textAlignment,
            shadow
        )
    }
    
    public static func fromTheme(): ButtonStyle {
        ButtonStyle(
            6.0,
            false,
            1.0,
            Color.WHITE,
            Color.WHITE,
            Color.WHITE,
            Color.WHITE,
            Color.WHITE,
            Color.WHITE,
            Color.WHITE,
            Color.WHITE,
            Color.WHITE,
            TextAlignment.Center,
            Shadow.none(),
            true,
            false
        )
    }
    
    public static func outlined(): ButtonStyle {
        ButtonStyle(
            6.0,
            true,
            1.0,
            Color.WHITE,
            Color.WHITE,
            Color.WHITE,
            Color.WHITE,
            Color.WHITE,
            Color.WHITE,
            Color.WHITE,
            Color.WHITE,
            Color.WHITE,
            TextAlignment.Center,
            Shadow.none(),
            true,
            true
        )
    }
}
