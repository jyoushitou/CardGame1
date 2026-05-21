package myapp

import cjform.*

main(): Int64 {
    Theme.setCurrent(Theme.dark())

    StyleSheet.getDefault()
        .define("btn", StyleProperties()
            .withFontFamily("Microsoft YaHei")
            .withFontSize(14.0)
            .withSizeScale(SizeScale.fixed())
            .withAnchor(Anchor.Center))

    if (!ffi_gdipInit()) {
        println("Failed to initialize GDI+")
        return 1
    }

    let game = CardGameUI()
    let result = game.run()
    Int64(result)
}
