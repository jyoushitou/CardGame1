package cjform

import std.collection.*

public class Window {
    private let hwnd: CPointer<Byte>
    private let title: String
    private let width: Int32
    private let height: Int32
    private var bgColor: Color
    private var widgets: ArrayList<Widget>
    private var hoveredWidget: Option<Widget>
    private var pressedWidget: Option<Widget>
    private var focusedWidget: Option<Widget>
    private var focusManager: FocusManager
    private var nativeControls: ArrayList<NativeTextBox>
    private var draggingSlider: Option<Slider>
    private var animationsActive: Bool
    private var tooltips: ArrayList<TooltipEntry>
    private var hoverStartTime: Int64
    private var tooltipVisible: Bool
    private var lastMouseX: Float32
    private var lastMouseY: Float32
    private var isResizable: Bool
    private var isAlwaysOnTop: Bool
    private var isNoTitleBar: Bool
    private var minWinWidth: Int32
    private var minWinHeight: Int32
    private var contextMenu: Option<ContextMenu>
    private var overlayWidget: Option<Widget>
    private var mainWidget: Option<Widget>
    private var onFileDrop: Option<(ArrayList<String>) -> Unit>

    public init(title: String, width: Int32, height: Int32) {
        this.title = title
        this.width = width
        this.height = height
        this.bgColor = Color.LIGHT_GRAY
        this.widgets = ArrayList<Widget>()
        this.hoveredWidget = None<Widget>
        this.pressedWidget = None<Widget>
        this.focusedWidget = None<Widget>
        this.focusManager = FocusManager.getInstance()
        this.nativeControls = ArrayList<NativeTextBox>()
        this.draggingSlider = None<Slider>
        this.animationsActive = false
        this.tooltips = ArrayList<TooltipEntry>()
        this.hoverStartTime = 0
        this.tooltipVisible = false
        this.lastMouseX = 0.0
        this.lastMouseY = 0.0
        this.isResizable = true
        this.isAlwaysOnTop = false
        this.isNoTitleBar = false
        this.minWinWidth = 0
        this.minWinHeight = 0
        this.overlayWidget = None<Widget>
        this.contextMenu = None<ContextMenu>
        this.mainWidget = None<Widget>
        this.onFileDrop = None<(ArrayList<String>) -> Unit>

        ffi_gdipInit()

        this.hwnd = ffi_windowCreate(title, width, height, true, false, false)

        if (ffi_isNullPtr(hwnd)) { return }

        unsafe { bridge_window_set_dark_mode(hwnd, Theme.getCurrent().isDark) }

        loadWindowState()
    }

    public func setOnFileDrop(callback: (ArrayList<String>) -> Unit): Unit {
        this.onFileDrop = Some<(ArrayList<String>) -> Unit>(callback)
    }

    private func loadWindowState(): Unit {
        let x = ffi_configReadInt("window", "x", -1)
        if (x >= 0) {
            let y = ffi_configReadInt("window", "y", -1)
            if (y >= 0) {
                let w = ffi_configReadInt("window", "w", -1)
                if (w > 0) {
                    let h = ffi_configReadInt("window", "h", -1)
                    if (h > 0) {
                        unsafe { bridge_window_set_pos(hwnd, x, y, w, h) }
                    }
                }
            }
        }
    }

    private func saveWindowState(): Unit {
        let x = unsafe { bridge_window_get_x(hwnd) }
        let y = unsafe { bridge_window_get_y(hwnd) }
        let w = unsafe { bridge_window_get_width(hwnd) }
        let h = unsafe { bridge_window_get_height(hwnd) }
        ffi_configWriteInt("window", "x", x)
        ffi_configWriteInt("window", "y", y)
        ffi_configWriteInt("window", "w", w)
        ffi_configWriteInt("window", "h", h)
    }

    public func setResizable(resizable: Bool): Unit { this.isResizable = resizable }
    public func setAlwaysOnTop(onTop: Bool): Unit { this.isAlwaysOnTop = onTop }
    public func setNoTitleBar(noTitleBar: Bool): Unit { this.isNoTitleBar = noTitleBar }

    public func setMinSize(minW: Int32, minH: Int32): Unit {
        this.minWinWidth = minW
        this.minWinHeight = minH
        unsafe { bridge_window_set_min_size(hwnd, minW, minH) }
    }

    public func setContextMenu(menu: ContextMenu): Unit { this.contextMenu = Some(menu) }
    public func setMainWidget(widget: Widget): Unit { this.mainWidget = Some(widget) }

    public func showOverlay(widget: Widget): Unit { this.overlayWidget = Some(widget) }

    public func dismissOverlay(): Unit { this.overlayWidget = None }

    public func hasOverlay(): Bool {
        match (overlayWidget) {
            case Some(_) => true
            case None => false
        }
    }

    public func setTooltip(widget: Widget, tooltip: Tooltip): Unit {
        let key = getWidgetKey(widget)
        tooltips.add(TooltipEntry(key, tooltip))
    }

    private func getWidgetKey(widget: Widget): String {
        match (widget) {
            case b: Button => b.getText()
            case _ => "widget"
        }
    }

    public func getHandle(): CPointer<Byte> {
        hwnd
    }

    public func setBackgroundColor(color: Color): Unit {
        this.bgColor = color
    }

    public func addWidget(widget: Widget): Unit {
        widgets.add(widget)
        registerChildren(widget)
    }

    public func addNativeTextBox(textBox: NativeTextBox): Unit {
        nativeControls.add(textBox)
    }

    private func registerChildren(widget: Widget): Unit {
        match (widget) {
            case tb: TextBox =>
                focusManager.register(tb)
                tb.setParentHwnd(hwnd)
            case te: TextEdit =>
                focusManager.register(te)
                te.setParentHwnd(hwnd)
            case sb: SpinBox =>
                focusManager.register(sb)
            case cb: ComboBox =>
                focusManager.register(cb)
            case vbox: VBox =>
                for (child in vbox.getChildren()) { registerChildren(child) }
            case hbox: HBox =>
                for (child in hbox.getChildren()) { registerChildren(child) }
            case scrollArea: ScrollArea =>
                match (scrollArea.getContent()) {
                    case Some(c) => registerChildren(c)
                    case None => ()
                }
            case tabView: TabView =>
                for (content in tabView.getAllTabContents()) { registerChildren(content) }
            case groupBox: GroupBox =>
                match (groupBox.getContent()) {
                    case Some(c) => registerChildren(c)
                    case None => ()
                }
            case splitPane: SplitPane => ()
            case _ => ()
        }
    }

    public func show(): Unit {
        unsafe { bridge_window_show(hwnd) }
    }

    public func close(): Unit {
        unsafe { bridge_window_close(hwnd) }
    }

    public func run(): Int32 {
        if (ffi_isNullPtr(hwnd)) {
            println("[CJForm] Error: cannot run — window handle is null")
            return 1
        }

        render()

        while (true) {
            let needsRender = unsafe { bridge_window_needs_render(hwnd) }
            if (needsRender) {
                render()
                unsafe { bridge_window_clear_needs_render(hwnd) }
            }

            processEvents()

            let continueLoop = unsafe { bridge_process_message() }
            if (continueLoop == 0) {
                break
            }
        }

        saveWindowState()
        0
    }

    private func processEvents(): Unit {
        let hasMouseEvent = unsafe { bridge_window_has_mouse_event(hwnd) }
        if (hasMouseEvent) {
            let mouseX = unsafe { bridge_window_get_mouse_x(hwnd) }
            let mouseY = unsafe { bridge_window_get_mouse_y(hwnd) }
            let mouseButton = unsafe { bridge_window_get_mouse_button(hwnd) }
            let mouseEventType = unsafe { bridge_window_get_mouse_event_type(hwnd) }

            unsafe { bridge_window_clear_mouse_event(hwnd) }

            let currentWidth = unsafe { bridge_window_get_width(hwnd) }
            let currentHeight = unsafe { bridge_window_get_height(hwnd) }

            let event = createEvent(mouseEventType, Float32(mouseX), Float32(mouseY), mouseButton)
            dispatchEvent(event, Float32(mouseX), Float32(mouseY), Float32(currentWidth), Float32(currentHeight))

            render()
        }

        let hasKeyEvent = unsafe { bridge_window_has_key_event(hwnd) }
        if (hasKeyEvent) {
            let keyCode = unsafe { bridge_window_get_key_code(hwnd) }
            let keyEventType = unsafe { bridge_window_get_key_event_type(hwnd) }
            let keyChar = unsafe { bridge_window_get_key_char(hwnd) }
            let ctrlDown = unsafe { bridge_window_get_ctrl_down(hwnd) }
            let shiftDown = unsafe { bridge_window_get_shift_down(hwnd) }
            let altDown = unsafe { bridge_window_get_alt_down(hwnd) }

            unsafe { bridge_window_clear_key_event(hwnd) }

            match (focusedWidget) {
                case Some(_) => ()
                case None => ()
            }
            processKeyEvent(keyCode, keyEventType, keyChar, ctrlDown, shiftDown, altDown)

            render()
        }

        let hasWheelEvent = unsafe { bridge_window_has_mouse_wheel_event(hwnd) }
        if (hasWheelEvent) {
            let wheelX = unsafe { bridge_window_get_mouse_wheel_x(hwnd) }
            let wheelY = unsafe { bridge_window_get_mouse_wheel_y(hwnd) }
            let wheelDelta = unsafe { bridge_window_get_mouse_wheel_delta(hwnd) }
            unsafe { bridge_window_clear_mouse_wheel_event(hwnd) }

            let curW = unsafe { bridge_window_get_width(hwnd) }
            let curH = unsafe { bridge_window_get_height(hwnd) }
            let wheelEvent = Event.mouseWheel(Float32(wheelX), Float32(wheelY), wheelDelta)

            var handled = false
            match (overlayWidget) {
                case Some(overlay) =>
                    handled = overlay.handleEvent(wheelEvent)
                case None => ()
            }
            if (!handled) {
                for (widget in widgets) {
                    if (widget.hitTest(Float32(wheelX), Float32(wheelY), Float32(width), Float32(height), Float32(curW), Float32(curH))) {
                        
                        if (widget.handleEvent(wheelEvent)) { break }
                    }
                }
            }
            render()
        }

        let hasDropEvent = unsafe { bridge_window_has_drop_event(hwnd) }
        if (hasDropEvent) {
            let count = unsafe { bridge_window_get_drop_count(hwnd) }
            if (count > 0) {
                let files = ArrayList<String>()
                let buf = unsafe { LibC.malloc<Byte>(count: 512) }
                let bufSize: Int32 = 512
                for (i in 0..count) {
                    let len = unsafe { bridge_window_get_drop_file(hwnd, i, buf, bufSize) }
                    if (len > 0) {
                        let cStr = unsafe { CString(buf) }
                        files.add(cStr.toString())
                    }
                }
                unsafe { LibC.free(buf) }
                unsafe { bridge_window_clear_drop_event(hwnd) }
                match (onFileDrop) {
                    case Some(cb) => cb(files)
                    case None => ()
                }
            } else {
                unsafe { bridge_window_clear_drop_event(hwnd) }
            }
        }
    }

    private func processKeyEvent(keyCode: UInt32, keyEventType: Int32, keyChar: UInt16, hasCtrl: Bool, hasShift: Bool, hasAlt: Bool): Unit {
        if (keyEventType == 1) {
            if (ShortcutManager.getInstance().handleKey(keyCode, keyChar, hasCtrl, hasShift, hasAlt)) {
                return
            }
            if (keyCode == 9) {
                if (hasShift) {
                    focusManager.focusPrevious()
                } else {
                    focusManager.focusNext()
                }
                syncFocusedWidget()
            } else {
                match (focusedWidget) {
                    case Some(w) =>
                        match (w) {
                            case tb: TextBox =>
                                tb.handleEvent(Event.keyDown(keyCode, hasCtrl, hasShift, hasAlt))
                            case te: TextEdit =>
                                te.handleEvent(Event.keyDown(keyCode, hasCtrl, hasShift, hasAlt))
                            case sb: SpinBox =>
                                sb.handleEvent(Event.keyDown(keyCode, hasCtrl, hasShift, hasAlt))
                            case _ => ()
                        }
                    case None => ()
                }
            }
        } else if (keyEventType == 2) {
            if (keyChar != 0) {
                match (focusedWidget) {
                    case Some(w) =>
                        match (w) {
                            case tb: TextBox =>
                                tb.handleEvent(Event.keyChar(Rune(keyChar), hasCtrl, hasShift, hasAlt))
                            case te: TextEdit =>
                                te.handleEvent(Event.keyChar(Rune(keyChar), hasCtrl, hasShift, hasAlt))
                            case sb: SpinBox =>
                                sb.handleEvent(Event.keyChar(Rune(keyChar), hasCtrl, hasShift, hasAlt))
                            case _ => ()
                        }
                    case None => ()
                }
            }
        }
    }

    private func syncFocusedWidget(): Unit {
        match (focusManager.getFocused()) {
            case Some(f) =>
                match (f) {
                    case tb: TextBox => focusedWidget = Some<Widget>(tb)
                    case te: TextEdit => focusedWidget = Some<Widget>(te)
                    case sb: SpinBox => focusedWidget = Some<Widget>(sb)
                    case cb: ComboBox => focusedWidget = Some<Widget>(cb)
                    case _ => ()
                }
            case None => focusedWidget = None<Widget>
        }
    }

    private func createEvent(eventType: Int32, x: Float32, y: Float32, button: Int32): Event {
        if (eventType == 1) {
            Event.mouseMove(x, y)
        } else if (eventType == 2) {
            Event.mouseDown(x, y, button)
        } else if (eventType == 3) {
            Event.mouseUp(x, y, button)
        } else {
            Event.mouseMove(x, y)
        }
    }

    private func dispatchEvent(event: Event, mouseX: Float32, mouseY: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        match (event.eventType) {
            case EventType.MouseMove =>
                handleMouseMove(mouseX, mouseY, currentWidth, currentHeight)
            case EventType.MouseDown =>
                let btn = match (event.mouseEvent) {
                    case Some(me) => me.button
                    case None => Int32(1)
                }
                handleMouseDown(mouseX, mouseY, btn, currentWidth, currentHeight)
            case EventType.MouseUp =>
                handleMouseUp(mouseX, mouseY, currentWidth, currentHeight)
            case EventType.MouseWheel =>
                handleMouseWheelEvent(event, mouseX, mouseY, currentWidth, currentHeight)
            case _ => ()
        }
    }

    private func handleMouseMove(x: Float32, y: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        match (draggingSlider) {
            case Some(slider) =>
                slider.handleDrag(x, Float32(width), currentWidth)
                return
            case None => ()
        }

        match (pressedWidget) {
            case Some(w) =>
                w.handleEvent(Event.mouseMove(x, y))
                return
            case None => ()
        }

        match (overlayWidget) {
            case Some(overlay) =>
                overlay.handleEvent(Event.mouseMove(x, y))
                return
            case None => ()
        }

        var foundWidget: Option<Widget> = None<Widget>

        for (widget in widgets) {
            if (widget.hitTest(x, y, Float32(width), Float32(height), currentWidth, currentHeight)) {
                foundWidget = Some<Widget>(widget)
                break
            }
        }

        lastMouseX = x
        lastMouseY = y

        match (foundWidget) {
            case Some(w) =>
                match (hoveredWidget) {
                    case Some(old) =>
                        old.handleEvent(Event.mouseLeave())
                        
                        w.handleEvent(Event.mouseEnter())
                        w.handleEvent(Event.mouseMove(x, y))
                        
                        hoveredWidget = Some<Widget>(w)
                        hoverStartTime = ffi_getTickCount()
                        tooltipVisible = false
                    case None =>
                        w.handleEvent(Event.mouseEnter())
                        w.handleEvent(Event.mouseMove(x, y))
                        
                        hoveredWidget = Some<Widget>(w)
                        hoverStartTime = ffi_getTickCount()
                        tooltipVisible = false
                }
            case None =>
                match (hoveredWidget) {
                    case Some(old) =>
                        old.handleEvent(Event.mouseLeave())
                        
                        hoveredWidget = None<Widget>
                        tooltipVisible = false
                    case None => ()
                }
        }

        match (hoveredWidget) {
            case Some(w) =>
                if (!tooltipVisible) {
                    let now = ffi_getTickCount()
                    if (now - hoverStartTime >= 500) {
                        tooltipVisible = true
                    }
                }
            case None => ()
        }
    }

    private func handleMouseWheelEvent(event: Event, x: Float32, y: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        match (overlayWidget) {
            case Some(overlay) =>
                if (overlay.hitTest(x, y, Float32(width), Float32(height), currentWidth, currentHeight)) {
                    overlay.handleEvent(event)
                    return
                }
            case None => ()
        }
        for (widget in widgets) {
            if (widget.hitTest(x, y, Float32(width), Float32(height), currentWidth, currentHeight)) {
                if (widget.handleEvent(event)) { break }
            }
        }
    }

    private func getLeafWidget(widget: Widget, x: Float32, y: Float32): Widget {
        widget.findLeafAt(x, y)
    }

    private func handleMouseDown(x: Float32, y: Float32, button: Int32, currentWidth: Float32, currentHeight: Float32): Unit {
        match (overlayWidget) {
            case Some(overlay) =>
                if (overlay.hitTest(x, y, Float32(width), Float32(height), currentWidth, currentHeight)) {
                    overlay.handleEvent(Event.mouseDown(x, y, button))
                } else {
                    overlayWidget = None
                }
                return
            case None => ()
        }

        if (button == 3) {
            match (contextMenu) {
                case Some(menu) =>
                    menu.setPosition(x, y)
                    overlayWidget = Some<Widget>(menu)
                case None => ()
            }
            return
        }
        var hitWidget: Bool = false
        for (widget in widgets) {
            if (widget.hitTest(x, y, Float32(width), Float32(height), currentWidth, currentHeight)) {
                hitWidget = true
                let leaf = getLeafWidget(widget, x, y)

                match (leaf) {
                    case f: Focusable =>
                        focusManager.setFocus(f)
                        focusedWidget = Some<Widget>(leaf)
                    case slider: Slider =>
                        focusManager.clearFocus()
                        match (focusedWidget) {
                            case Some(fw) =>
                                fw.handleEvent(Event.focusLost())
                                focusedWidget = None<Widget>
                            case None => ()
                        }
                        slider.handleDrag(x, Float32(width), currentWidth)
                        draggingSlider = Some<Slider>(slider)
                    case _ =>
                        match (focusedWidget) {
                            case Some(fw) =>
                                fw.handleEvent(Event.focusLost())
                                focusedWidget = None<Widget>
                            case None => ()
                        }
                        focusManager.clearFocus()
                }

                leaf.handleEvent(Event.mouseDown(x, y, button))
                
                pressedWidget = Some<Widget>(leaf)
                break
            }
        }
        if (!hitWidget) {
            match (focusedWidget) {
                case Some(fw) =>
                    fw.handleEvent(Event.focusLost())
                    focusedWidget = None<Widget>
                case None => ()
            }
            focusManager.clearFocus()
        }
    }

    private func handleMouseUp(x: Float32, y: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        draggingSlider = None<Slider>

        match (overlayWidget) {
            case Some(overlay) =>
                overlay.handleEvent(Event.mouseUp(x, y, 1))
                match (overlay) {
                    case menu: ContextMenu => overlayWidget = None
                    case _ => ()
                }
                return
            case None => ()
        }

        match (pressedWidget) {
            case Some(w) =>
                w.handleEvent(Event.mouseUp(x, y, 1))
                
                pressedWidget = None<Widget>
                return
            case None => ()
        }

        match (hoveredWidget) {
            case Some(w) =>
                let leaf = getLeafWidget(w, x, y)
                leaf.handleEvent(Event.mouseUp(x, y, 1))
                
                match (leaf) {
                    case slider: Slider =>
                        slider.handleEvent(Event.mouseUp(x, y, 1))
                    case _ => ()
                }
            case None =>
                for (widget in widgets) {
                    if (widget.hitTest(x, y, Float32(width), Float32(height), currentWidth, currentHeight)) {
                        let leaf = getLeafWidget(widget, x, y)
                        leaf.handleEvent(Event.mouseUp(x, y, 1))
                        
                        break
                    }
                }
        }
    }

    private func render(): Unit {
        let now = ffi_getTickCount()
        var stillAnimating = false
        for (widget in widgets) {
            if (widget.updateAnimation(now)) {
                stillAnimating = true
            }
        }

        if (stillAnimating && !animationsActive) {
            animationsActive = true
            unsafe { bridge_start_animation_timer(hwnd) }
        } else if (!stillAnimating && animationsActive) {
            animationsActive = false
            unsafe { bridge_stop_animation_timer(hwnd) }
        }

        let canvas = Canvas(hwnd)
        canvas.clear(bgColor)

        let currentWidth = unsafe { bridge_window_get_width(hwnd) }
        let currentHeight = unsafe { bridge_window_get_height(hwnd) }

        match (mainWidget) {
            case Some(mw) =>
                match (mw.getLayoutFrame()) {
                    case Some(f) =>
                        mw.setLayoutFrame(LayoutFrame(f.x, f.y,
                            Float32(currentWidth) - f.x, Float32(currentHeight) - f.y))
                    case None => ()
                }
            case None => ()
        }

        for (widget in widgets) {
            widget.paint(canvas, Float32(width), Float32(height), Float32(currentWidth), Float32(currentHeight))
        }

        if (tooltipVisible) {
            drawTooltip(canvas, currentWidth, currentHeight)
        }

        match (overlayWidget) {
            case Some(overlay) =>
                overlay.paint(canvas, Float32(width), Float32(height), Float32(currentWidth), Float32(currentHeight))
            case None => ()
        }

        unsafe { bridge_window_present(hwnd) }
    }

    private func drawTooltip(canvas: Canvas, winW: Int32, winH: Int32): Unit {
        match (hoveredWidget) {
            case Some(w) =>
                let key = getWidgetKey(w)
                for (entry in tooltips) {
                    if (entry.key == key) {
                        let tt = entry.tooltip
                        let pad: Float32 = 6.0
                        let textW = canvas.measureTextWidth(tt.text, tt.fontFamily, tt.fontSize) + pad * 2.0
                        let textH = tt.fontSize + pad * 2.0
                        var tipX = lastMouseX + 14.0
                        var tipY = lastMouseY + 18.0
                        if (tipX + textW > Float32(winW)) { tipX = Float32(winW) - textW - 4.0 }
                        if (tipY + textH > Float32(winH)) { tipY = Float32(winH) - textH - 4.0 }
                        canvas.fillRoundedRect(tipX, tipY, textW, textH, 4.0, tt.bgColor)
                        canvas.drawText(tipX + pad, tipY + pad, tt.text, tt.fontFamily, tt.fontSize, tt.textColor)
                        break
                    }
                }
            case None => ()
        }
    }

    public func getTitle(): String {
        title
    }

    public func getWidth(): Int32 {
        width
    }

    public func getHeight(): Int32 {
        height
    }
}
