package cjform

public interface Widget {
    func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit
    func hitTest(x: Float32, y: Float32, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool
    func handleEvent(event: Event): Bool
    func contains(x: Float32, y: Float32): Bool
    func getLayoutMinWidth(): Float32
    func getLayoutMinHeight(): Float32
    func setLayoutFrame(frame: LayoutFrame): Unit
    func clearLayoutFrame(): Unit
    func getLayoutFrame(): Option<LayoutFrame>
    func updateAnimation(tickCount: Int64): Bool
    func findLeafAt(x: Float32, y: Float32): Widget
}
