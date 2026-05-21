package cjform

import std.collection.*

public class TableColumn {
    public let title: String
    public var width: Float32
    public let sortable: Bool
    public let resizable: Bool
    public let alignment: Int32

    public init(title: String, width: Float32, sortable: Bool, resizable: Bool, alignment: Int32) {
        this.title = title
        this.width = width
        this.sortable = sortable
        this.resizable = resizable
        this.alignment = alignment
    }
}

public struct TableViewStyle {
    public let headerBgColor: Color
    public let headerTextColor: Color
    public let sortArrowColor: Color
    public let gridLineColor: Color
    public let selectedBgColor: Color
    public let rowEvenColor: Color
    public let rowOddColor: Color
    public let cellTextColor: Color
    public let scrollbarTrackColor: Color
    public let scrollbarThumbColor: Color
    public let scrollbarThumbHoverColor: Color
    public let isThemeBased: Bool

    public init() {
        this.headerBgColor = Color.WHITE
        this.headerTextColor = Color.WHITE
        this.sortArrowColor = Color.WHITE
        this.gridLineColor = Color.WHITE
        this.selectedBgColor = Color.WHITE
        this.rowEvenColor = Color.WHITE
        this.rowOddColor = Color.WHITE
        this.cellTextColor = Color.WHITE
        this.scrollbarTrackColor = Color.WHITE
        this.scrollbarThumbColor = Color.WHITE
        this.scrollbarThumbHoverColor = Color.WHITE
        this.isThemeBased = false
    }

    public init(headerBgColor: Color, headerTextColor: Color, sortArrowColor: Color,
        gridLineColor: Color, selectedBgColor: Color, rowEvenColor: Color, rowOddColor: Color,
        cellTextColor: Color, scrollbarTrackColor: Color, scrollbarThumbColor: Color,
        scrollbarThumbHoverColor: Color) {
        this.headerBgColor = headerBgColor
        this.headerTextColor = headerTextColor
        this.sortArrowColor = sortArrowColor
        this.gridLineColor = gridLineColor
        this.selectedBgColor = selectedBgColor
        this.rowEvenColor = rowEvenColor
        this.rowOddColor = rowOddColor
        this.cellTextColor = cellTextColor
        this.scrollbarTrackColor = scrollbarTrackColor
        this.scrollbarThumbColor = scrollbarThumbColor
        this.scrollbarThumbHoverColor = scrollbarThumbHoverColor
        this.isThemeBased = false
    }

    public init(isThemeBased: Bool) {
        this.headerBgColor = Color.WHITE
        this.headerTextColor = Color.WHITE
        this.sortArrowColor = Color.WHITE
        this.gridLineColor = Color.WHITE
        this.selectedBgColor = Color.WHITE
        this.rowEvenColor = Color.WHITE
        this.rowOddColor = Color.WHITE
        this.cellTextColor = Color.WHITE
        this.scrollbarTrackColor = Color.WHITE
        this.scrollbarThumbColor = Color.WHITE
        this.scrollbarThumbHoverColor = Color.WHITE
        this.isThemeBased = isThemeBased
    }

    public static func fromTheme(): TableViewStyle { TableViewStyle(true) }
}

public class TableView <: Widget {
    private var columns: ArrayList<TableColumn>
    private var dataRows: ArrayList<ArrayList<String>>
    private var headerHeight: Float32
    private var rowHeight: Float32
    private var minColumnWidth: Float32
    private var sortColumn: Int32
    private var sortAscending: Bool
    private var resizingColumn: Int32
    private var resizeStartX: Float32
    private var resizeStartWidth: Float32
    private var hoveredDivider: Int32
    private var resizeHandleWidth: Float32
    private var scrollX: Float32
    private var scrollY: Float32
    private var targetScrollX: Float32
    private var targetScrollY: Float32
    private var maxScrollX: Float32
    private var maxScrollY: Float32
    private var scrollAnimX: AnimationState
    private var scrollAnimY: AnimationState
    private var barThickness: Float32
    private var barMinLength: Float32
    private var showBarX: Bool
    private var showBarY: Bool
    private var barOpacity: Float32
    private var barOpacityAnim: AnimationState
    private var lastWheelTime: Int64
    private var draggingBarX: Bool
    private var draggingBarY: Bool
    private var dragStartScrollX: Float32
    private var dragStartScrollY: Float32
    private var dragStartMX: Float32
    private var dragStartMY: Float32
    private var hoveredBarX: Bool
    private var hoveredBarY: Bool
    private var selectedRow: Int32
    private var onSelectionChanged: Option<(Int32) -> Unit>
    private var layoutFrame: Option<LayoutFrame>
    private var viewportW: Float32
    private var viewportH: Float32
    private var wheelScrollSpeed: Float32
    private var style: TableViewStyle

    public init() {
        this.columns = ArrayList<TableColumn>()
        this.dataRows = ArrayList<ArrayList<String>>()
        this.headerHeight = 30.0
        this.rowHeight = 24.0
        this.minColumnWidth = 40.0
        this.sortColumn = -1
        this.sortAscending = true
        this.resizingColumn = -1
        this.resizeStartX = 0.0
        this.resizeStartWidth = 0.0
        this.hoveredDivider = -1
        this.resizeHandleWidth = 4.0
        this.scrollX = 0.0
        this.scrollY = 0.0
        this.targetScrollX = 0.0
        this.targetScrollY = 0.0
        this.maxScrollX = 0.0
        this.maxScrollY = 0.0
        this.scrollAnimX = AnimationState()
        this.scrollAnimY = AnimationState()
        this.barThickness = 10.0
        this.barMinLength = 20.0
        this.showBarX = false
        this.showBarY = false
        this.barOpacity = 0.3
        this.barOpacityAnim = AnimationState()
        this.lastWheelTime = 0
        this.draggingBarX = false
        this.draggingBarY = false
        this.dragStartScrollX = 0.0
        this.dragStartScrollY = 0.0
        this.dragStartMX = 0.0
        this.dragStartMY = 0.0
        this.hoveredBarX = false
        this.hoveredBarY = false
        this.selectedRow = -1
        this.onSelectionChanged = None<(Int32) -> Unit>
        this.layoutFrame = None
        this.viewportW = 0.0
        this.viewportH = 0.0
        this.wheelScrollSpeed = 40.0
        this.style = TableViewStyle.fromTheme()
    }

    public init(style: TableViewStyle) {
        this.columns = ArrayList<TableColumn>()
        this.dataRows = ArrayList<ArrayList<String>>()
        this.headerHeight = 30.0
        this.rowHeight = 24.0
        this.minColumnWidth = 40.0
        this.sortColumn = -1
        this.sortAscending = true
        this.resizingColumn = -1
        this.resizeStartX = 0.0
        this.resizeStartWidth = 0.0
        this.hoveredDivider = -1
        this.resizeHandleWidth = 4.0
        this.scrollX = 0.0
        this.scrollY = 0.0
        this.targetScrollX = 0.0
        this.targetScrollY = 0.0
        this.maxScrollX = 0.0
        this.maxScrollY = 0.0
        this.scrollAnimX = AnimationState()
        this.scrollAnimY = AnimationState()
        this.barThickness = 10.0
        this.barMinLength = 20.0
        this.showBarX = false
        this.showBarY = false
        this.barOpacity = 0.3
        this.barOpacityAnim = AnimationState()
        this.lastWheelTime = 0
        this.draggingBarX = false
        this.draggingBarY = false
        this.dragStartScrollX = 0.0
        this.dragStartScrollY = 0.0
        this.dragStartMX = 0.0
        this.dragStartMY = 0.0
        this.hoveredBarX = false
        this.hoveredBarY = false
        this.selectedRow = -1
        this.onSelectionChanged = None<(Int32) -> Unit>
        this.layoutFrame = None
        this.viewportW = 0.0
        this.viewportH = 0.0
        this.wheelScrollSpeed = 40.0
        this.style = style
    }

    public static func styled(styleName: String): TableView {
        TableView(TableViewStyle.fromTheme())
    }

    public func addColumn(column: TableColumn): Unit {
        columns.add(column)
    }

    public func addRow(row: ArrayList<String>): Unit {
        dataRows.add(row)
    }

    public func setData(rows: ArrayList<ArrayList<String>>): Unit {
        this.dataRows = rows
        this.scrollX = 0.0
        this.scrollY = 0.0
    }

    public func setOnSelectionChanged(callback: (Int32) -> Unit): Unit {
        this.onSelectionChanged = Some<(Int32) -> Unit>(callback)
    }

    public func getSelectedRow(): Int32 { selectedRow }

    public func clear(): Unit {
        dataRows = ArrayList<ArrayList<String>>()
        selectedRow = -1
        scrollX = 0.0
        scrollY = 0.0
    }

    private func clampF(v: Float32, lo: Float32, hi: Float32): Float32 {
        if (v < lo) { lo } else if (v > hi) { hi } else { v }
    }

    private func showBars(): Unit {
        barOpacityAnim.start(barOpacity, 1.0, 150, Easing.EaseOut)
        lastWheelTime = unsafe { bridge_get_tick_count() }
    }

    private func getTotalColWidth(): Float32 {
        var total: Float32 = 0.0
        for (col in columns) { total = total + col.width }
        total
    }

    private func getHeaderBgColor(): Color { if (style.isThemeBased) { Theme.colors().tableHeaderBg } else { style.headerBgColor } }
    private func getHeaderTextColor(): Color { if (style.isThemeBased) { Theme.colors().tableHeaderText } else { style.headerTextColor } }
    private func getSortArrowColor(): Color { if (style.isThemeBased) { Theme.colors().accent } else { style.sortArrowColor } }
    private func getGridLineColor(): Color { if (style.isThemeBased) { Theme.colors().tableGridLine } else { style.gridLineColor } }
    private func getSelectedBgColor(): Color { if (style.isThemeBased) { Theme.colors().tableSelectedBg } else { style.selectedBgColor } }
    private func getRowEvenColor(): Color { if (style.isThemeBased) { Theme.colors().tableRowEven } else { style.rowEvenColor } }
    private func getRowOddColor(): Color { if (style.isThemeBased) { Theme.colors().tableRowOdd } else { style.rowOddColor } }
    private func getCellTextColor(): Color { if (style.isThemeBased) { Theme.colors().textPrimary } else { style.cellTextColor } }
    private func getScrollbarTrackColor(): Color { if (style.isThemeBased) { Theme.colors().scrollbarTrack } else { style.scrollbarTrackColor } }
    private func getScrollbarThumbColor(): Color { if (style.isThemeBased) { Theme.colors().scrollbarThumb } else { style.scrollbarThumbColor } }
    private func getScrollbarThumbHoverColor(): Color { if (style.isThemeBased) { Theme.colors().scrollbarThumbHover } else { style.scrollbarThumbHoverColor } }

    public func paint(canvas: Canvas, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Unit {
        let frameX = match (layoutFrame) { case Some(f) => f.x; case None => Float32(0.0) }
        let frameY = match (layoutFrame) { case Some(f) => f.y; case None => Float32(0.0) }
        viewportW = match (layoutFrame) { case Some(f) => f.width; case None => Float32(currentWidth) }
        viewportH = match (layoutFrame) { case Some(f) => f.height; case None => Float32(currentHeight) }
        let totalColW = getTotalColWidth()
        let contentH = Float32(dataRows.size) * rowHeight
        let vpW = viewportW
        let vpH = viewportH - headerHeight
        showBarY = contentH > vpH
        showBarX = totalColW > vpW
        if (showBarX && !showBarY && contentH > vpH - barThickness) { showBarY = true }
        if (showBarY && !showBarX && totalColW > vpW - barThickness) { showBarX = true }
        let vpW2 = if (showBarY) { vpW - barThickness } else { vpW }
        let vpH2 = if (showBarX) { vpH - barThickness } else { vpH }
        maxScrollX = if (totalColW > vpW2) { totalColW - vpW2 } else { Float32(0.0) }
        maxScrollY = if (contentH > vpH2) { contentH - vpH2 } else { Float32(0.0) }
        if (maxScrollX < 0.0) { maxScrollX = 0.0 }
        if (maxScrollY < 0.0) { maxScrollY = 0.0 }
        scrollX = clampF(scrollX, 0.0, maxScrollX)
        scrollY = clampF(scrollY, 0.0, maxScrollY)

        var colX: Float32 = frameX - scrollX
        for (i in 0..columns.size) {
            let col = columns[i]
            let colIdx = Int32(i)
            let colRight = colX + col.width

            if (colRight > frameX && colX < frameX + vpW2) {
                canvas.fillRoundedRect(colX, frameY, col.width, headerHeight, 0.0, getHeaderBgColor())
                canvas.drawTextAligned(colX + 4.0, frameY + 2.0, col.width - 8.0, headerHeight - 4.0, col.title, "Microsoft YaHei", 13.0, col.alignment, getHeaderTextColor())

                if (sortColumn == colIdx) {
                    let arrow = if (sortAscending) { " ^" } else { " v" }
                    canvas.drawText(colX + 4.0, frameY + 4.0, arrow, "Microsoft YaHei", 10.0, getSortArrowColor())
                }

                canvas.drawLine(colRight - 1.0, frameY + 4.0, colRight - 1.0, frameY + headerHeight - 4.0, 1.0, getGridLineColor())
            }
            colX = colRight
        }

        let rowAreaY = frameY + headerHeight
        canvas.pushClip(frameX, rowAreaY, vpW2, vpH2)

        let firstRow = Int32(Float32(Int64(scrollY / rowHeight)))
        let lastRow = Int32(Float32(Int64((scrollY + vpH2) / rowHeight))) + 1
        var first = if (firstRow < 0) { Int32(0) } else { firstRow }
        var last = if (lastRow > Int32(dataRows.size)) { Int32(dataRows.size) } else { lastRow }

        for (ri in first..last) {
            let row = dataRows[Int64(ri)]
            let y = rowAreaY + Float32(ri) * rowHeight - scrollY

            if (Int32(ri) == selectedRow) {
                canvas.fillRoundedRect(frameX, y, vpW2, rowHeight, 0.0, getSelectedBgColor())
            } else if (Int32(ri) % 2 == 0) {
                canvas.fillRoundedRect(frameX, y, vpW2, rowHeight, 0.0, getRowEvenColor())
            } else {
                canvas.fillRoundedRect(frameX, y, vpW2, rowHeight, 0.0, getRowOddColor())
            }

            var cellX: Float32 = frameX - scrollX
            for (ci in 0..columns.size) {
                let col = columns[ci]
                let cellRight = cellX + col.width
                if (cellRight > frameX && cellX < frameX + vpW2) {
                    let cellText = if (Int64(ci) < row.size) { row[Int64(ci)] } else { "" }
                    canvas.drawTextAligned(cellX + 4.0, y + 2.0, col.width - 8.0, rowHeight - 4.0, cellText, "Microsoft YaHei", 13.0, col.alignment, getCellTextColor())
                    canvas.drawLine(cellRight - 1.0, y, cellRight - 1.0, y + rowHeight, 1.0, getGridLineColor())
                }
                cellX = cellRight
            }
        }

        canvas.popClip()

        paintScrollbars(canvas, frameX, frameY, vpW2, vpH2)
    }

    private func paintScrollbars(canvas: Canvas, frameX: Float32, frameY: Float32, vpW: Float32, vpH: Float32): Unit {
        let alpha = UInt8(barOpacity * 255.0)
        if (alpha == 0) { return }

        if (showBarY && maxScrollY > 0.0) {
            let barX = frameX + vpW
            let barH = vpH
            let contentH = Float32(dataRows.size) * rowHeight
            let thumbH = clampF(barH * vpH / contentH, barMinLength, barH - 4.0)
            let thumbTravel = barH - thumbH - 4.0
            let thumbY = frameY + headerHeight + 2.0 + (scrollY / maxScrollY) * thumbTravel

            let trackC = getScrollbarTrackColor()
            canvas.fillRoundedRect(barX + 2.0, frameY + headerHeight, barThickness - 4.0, barH, 4.0,
                Color.rgba(trackC.r, trackC.g, trackC.b, alpha))
            let thumbColor = if (draggingBarY || hoveredBarY) {
                let hoverC = getScrollbarThumbHoverColor()
                Color.rgba(hoverC.r, hoverC.g, hoverC.b, alpha)
            } else {
                let thumbC = getScrollbarThumbColor()
                Color.rgba(thumbC.r, thumbC.g, thumbC.b, alpha)
            }
            canvas.fillRoundedRect(barX + 2.0, thumbY, barThickness - 4.0, thumbH, 4.0, thumbColor)
        }

        if (showBarX && maxScrollX > 0.0) {
            let barY = frameY + headerHeight + vpH
            let barW = vpW
            let totalColW = getTotalColWidth()
            let thumbW = clampF(barW * vpW / totalColW, barMinLength, barW - 4.0)
            let thumbTravel = barW - thumbW - 4.0
            let thumbX = frameX + 2.0 + (scrollX / maxScrollX) * thumbTravel

            let trackC = getScrollbarTrackColor()
            canvas.fillRoundedRect(frameX, barY + 2.0, barW, barThickness - 4.0, 4.0,
                Color.rgba(trackC.r, trackC.g, trackC.b, alpha))
            let thumbColor = if (draggingBarX || hoveredBarX) {
                let hoverC = getScrollbarThumbHoverColor()
                Color.rgba(hoverC.r, hoverC.g, hoverC.b, alpha)
            } else {
                let thumbC = getScrollbarThumbColor()
                Color.rgba(thumbC.r, thumbC.g, thumbC.b, alpha)
            }
            canvas.fillRoundedRect(thumbX, barY + 2.0, thumbW, barThickness - 4.0, 4.0, thumbColor)
        }
    }

    public func hitTest(x: Float32, y: Float32, initialWidth: Float32, initialHeight: Float32, currentWidth: Float32, currentHeight: Float32): Bool {
        match (layoutFrame) {
            case Some(f) => x >= f.x && x <= f.x + f.width && y >= f.y && y <= f.y + f.height
            case None => x >= 0.0 && x <= Float32(currentWidth) && y >= 0.0 && y <= Float32(currentHeight)
        }
    }

    public func handleEvent(event: Event): Bool {
        let frameX = match (layoutFrame) { case Some(f) => f.x; case None => Float32(0.0) }
        let frameY = match (layoutFrame) { case Some(f) => f.y; case None => Float32(0.0) }

        match (event.eventType) {
            case EventType.MouseWheel =>
                match (event.mouseWheelEvent) {
                    case Some(we) =>
                        let lines = Float32(we.delta) / 120.0
                        let delta = -lines * wheelScrollSpeed
                        let newTarget = clampF(targetScrollY + delta, 0.0, maxScrollY)
                        if (!scrollAnimY.isFinished()) {
                            scrollAnimY.jumpToEnd()
                            scrollY = scrollAnimY.getValue()
                        }
                        targetScrollY = newTarget
                        scrollAnimY.start(scrollY, newTarget, 250, Easing.EaseOut)
                        showBars()
                    case None => ()
                }
                true
            case EventType.MouseDown =>
                handleMouseDown(event, frameX, frameY)
            case EventType.MouseUp =>
                handleMouseUp(event)
            case EventType.MouseMove =>
                handleMouseMove(event, frameX, frameY)
            case _ => false
        }
    }

    private func handleMouseDown(event: Event, frameX: Float32, frameY: Float32): Bool {
        match (event.mouseEvent) {
            case Some(me) =>
                let vpW = if (showBarY) { viewportW - barThickness } else { viewportW }
                let vpH = viewportH - headerHeight

                if (hoveredDivider >= 0 && me.y >= frameY && me.y <= frameY + headerHeight) {
                    resizingColumn = hoveredDivider
                    resizeStartX = me.x
                    resizeStartWidth = columns[Int64(hoveredDivider)].width
                    return true
                }

                if (showBarY && maxScrollY > 0.0) {
                    let barX = frameX + vpW
                    let rowAreaY = frameY + headerHeight
                    if (me.x >= barX && me.x <= barX + barThickness && me.y >= rowAreaY && me.y <= rowAreaY + vpH) {
                        let contentH = Float32(dataRows.size) * rowHeight
                        let thumbH = clampF(vpH * vpH / contentH, barMinLength, vpH - 4.0)
                        let thumbTravel = vpH - thumbH - 4.0
                        let thumbY = rowAreaY + 2.0 + (scrollY / maxScrollY) * thumbTravel
                        if (me.y >= thumbY && me.y <= thumbY + thumbH) {
                            draggingBarY = true
                            dragStartScrollY = scrollY
                            dragStartMY = me.y
                        } else {
                            let clickRatio = (me.y - rowAreaY - thumbH / 2.0) / thumbTravel
                            let target = clampF(clickRatio * maxScrollY, 0.0, maxScrollY)
                            targetScrollY = target
                            scrollAnimY.start(scrollY, target, 250, Easing.EaseOut)
                            showBars()
                        }
                        return true
                    }
                }

                if (showBarX && maxScrollX > 0.0) {
                    let barY = frameY + headerHeight + vpH
                    if (me.x >= frameX && me.x <= frameX + viewportW && me.y >= barY && me.y <= barY + barThickness) {
                        let totalColW = getTotalColWidth()
                        let thumbW = clampF(vpW * vpW / totalColW, barMinLength, vpW - 4.0)
                        let thumbTravel = vpW - thumbW - 4.0
                        let thumbX = frameX + 2.0 + (scrollX / maxScrollX) * thumbTravel
                        if (me.x >= thumbX && me.x <= thumbX + thumbW) {
                            draggingBarX = true
                            dragStartScrollX = scrollX
                            dragStartMX = me.x
                        } else {
                            let clickRatio = (me.x - frameX - thumbW / 2.0) / thumbTravel
                            let target = clampF(clickRatio * maxScrollX, 0.0, maxScrollX)
                            targetScrollX = target
                            scrollAnimX.start(scrollX, target, 250, Easing.EaseOut)
                            showBars()
                        }
                        return true
                    }
                }

                if (me.y >= frameY && me.y <= frameY + headerHeight) {
                    var colX: Float32 = frameX - scrollX
                    for (i in 0..columns.size) {
                        let col = columns[i]
                        let colIdx = Int32(i)
                        if (me.x >= colX && me.x <= colX + col.width) {
                            if (col.sortable) {
                                if (sortColumn == colIdx) {
                                    sortAscending = !sortAscending
                                } else {
                                    sortColumn = colIdx
                                    sortAscending = true
                                }
                                sortData()
                            }
                            return true
                        }
                        colX = colX + col.width
                    }
                }

                let rowAreaY = frameY + headerHeight
                if (me.y >= rowAreaY && me.y <= rowAreaY + vpH) {
                    let relY = me.y - rowAreaY + scrollY
                    let rowIdx = Int32(relY / rowHeight)
                    if (rowIdx >= 0 && rowIdx < Int32(dataRows.size)) {
                        selectedRow = rowIdx
                        match (onSelectionChanged) {
                            case Some(cb) => cb(selectedRow)
                            case None => ()
                        }
                    }
                }
                true
            case None => false
        }
    }

    private func handleMouseUp(event: Event): Bool {
        resizingColumn = -1
        draggingBarX = false
        draggingBarY = false
        true
    }

    private func handleMouseMove(event: Event, frameX: Float32, frameY: Float32): Bool {
        match (event.mouseEvent) {
            case Some(me) =>
                if (resizingColumn >= 0) {
                    let delta = me.x - resizeStartX
                    let newW = clampF(resizeStartWidth + delta, minColumnWidth, 500.0)
                    columns[Int64(resizingColumn)].width = newW
                    return true
                }

                if (draggingBarY) {
                    let vpH = viewportH - headerHeight
                    let contentH = Float32(dataRows.size) * rowHeight
                    let thumbH = clampF(vpH * vpH / contentH, barMinLength, vpH - 4.0)
                    let thumbTravel = vpH - thumbH - 4.0
                    if (thumbTravel > 0.0) {
                        let delta = me.y - dragStartMY
                        let ratio = delta / thumbTravel
                        let newOff = clampF(dragStartScrollY + ratio * maxScrollY, 0.0, maxScrollY)
                        targetScrollY = newOff
                        scrollY = newOff
                        scrollAnimY.jumpToEnd()
                    }
                    return true
                }
                if (draggingBarX) {
                    let vpW = if (showBarY) { viewportW - barThickness } else { viewportW }
                    let totalColW = getTotalColWidth()
                    let thumbW = clampF(vpW * vpW / totalColW, barMinLength, vpW - 4.0)
                    let thumbTravel = vpW - thumbW - 4.0
                    if (thumbTravel > 0.0) {
                        let delta = me.x - dragStartMX
                        let ratio = delta / thumbTravel
                        let newOff = clampF(dragStartScrollX + ratio * maxScrollX, 0.0, maxScrollX)
                        targetScrollX = newOff
                        scrollX = newOff
                        scrollAnimX.jumpToEnd()
                    }
                    return true
                }

                let vpW = if (showBarY) { viewportW - barThickness } else { viewportW }
                let vpH = viewportH - headerHeight
                var suspended: Bool = false
                if (showBarY && maxScrollY > 0.0) {
                    let barX = frameX + vpW
                    let rowAreaY = frameY + headerHeight
                    hoveredBarY = me.x >= barX && me.x <= barX + barThickness && me.y >= rowAreaY && me.y <= rowAreaY + vpH
                    if (hoveredBarY) { suspended = true }
                }
                if (showBarX && maxScrollX > 0.0) {
                    let barY = frameY + headerHeight + vpH
                    hoveredBarX = me.x >= frameX && me.x <= frameX + viewportW && me.y >= barY && me.y <= barY + barThickness
                    if (hoveredBarX) { suspended = true }
                }

                if (!suspended && me.y >= frameY && me.y <= frameY + headerHeight && resizingColumn < 0) {
                    var colX: Float32 = frameX - scrollX
                    hoveredDivider = -1
                    for (i in 0..columns.size) {
                        let col = columns[i]
                        let colIdx = Int32(i)
                        if (me.x >= colX + col.width - resizeHandleWidth / 2.0 && me.x <= colX + col.width + resizeHandleWidth / 2.0 && columns[Int64(colIdx)].resizable) {
                            hoveredDivider = colIdx
                            break
                        }
                        colX = colX + col.width
                    }
                } else if (!suspended) {
                    hoveredDivider = -1
                }

                true
            case None => false
        }
    }

    private func sortData(): Unit {
        if (sortColumn < 0 || sortColumn >= Int32(columns.size)) { return }

        let n = dataRows.size
        var sorted = ArrayList<ArrayList<String>>()
        for (row in dataRows) { sorted.add(row) }

        for (i in 0..n) {
            for (j in 0..(n - i - 1)) {
                let a = sorted[Int64(j)]
                let b = sorted[Int64(j + 1)]
                let colIdx = Int64(sortColumn)
                var shouldSwap = false

                if (colIdx < a.size && colIdx < b.size) {
                    if (sortAscending) {
                        shouldSwap = stringCompareGT(a[colIdx], b[colIdx])
                    } else {
                        shouldSwap = stringCompareGT(b[colIdx], a[colIdx])
                    }
                }
                if (shouldSwap) {
                    let tmp = sorted[Int64(j)]
                    sorted[Int64(j)] = sorted[Int64(j + 1)]
                    sorted[Int64(j + 1)] = tmp
                }
            }
        }
        dataRows = sorted
    }

    private func stringCompareGT(a: String, b: String): Bool {
        let listA = ArrayList<Rune>()
        let listB = ArrayList<Rune>()
        for (r in a.runes()) { listA.add(r) }
        for (r in b.runes()) { listB.add(r) }
        let sizeA = listA.size
        let sizeB = listB.size
        let minLen = if (sizeA < sizeB) { sizeA } else { sizeB }
        for (i in 0..minLen) {
            let ra = listA[Int64(i)]
            let rb = listB[Int64(i)]
            if (ra > rb) { return true }
            if (ra < rb) { return false }
        }
        sizeA > sizeB
    }

    public func contains(x: Float32, y: Float32): Bool { true }

    public func findLeafAt(x: Float32, y: Float32): Widget { this }

    public func updateAnimation(tickCount: Int64): Bool {
        var active = false
        scrollAnimX.update(tickCount)
        scrollAnimY.update(tickCount)
        barOpacityAnim.update(tickCount)

        if (!scrollAnimX.isFinished()) { scrollX = scrollAnimX.getValue(); active = true }
        if (!scrollAnimY.isFinished()) { scrollY = scrollAnimY.getValue(); active = true }

        if (barOpacityAnim.isFinished() && lastWheelTime > 0) {
            let now = unsafe { bridge_get_tick_count() }
            if (now - lastWheelTime > 1500 && barOpacity > 0.31) {
                barOpacityAnim.start(barOpacity, 0.3, 500, Easing.EaseOut)
            }
        }
        if (!barOpacityAnim.isFinished()) { barOpacity = barOpacityAnim.getValue(); active = true }

        active
    }

    public func getLayoutMinWidth(): Float32 { 300.0 }
    public func getLayoutMinHeight(): Float32 { 200.0 }
    public func setLayoutFrame(frame: LayoutFrame): Unit { this.layoutFrame = Some(frame) }
    public func clearLayoutFrame(): Unit { this.layoutFrame = None }
    public func getLayoutFrame(): Option<LayoutFrame> { layoutFrame }
}
