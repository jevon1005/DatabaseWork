import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

Window {
    id: modifySeatTemplateWin
    // property var mainWindow
    
    // 处理窗口最小化和关闭问题
    onVisibleChanged: {
        if (!visible) closed()
    }
    
    onVisibilityChanged: function(visibility) {
        if (visibility === Window.Windowed || visibility === Window.Maximized) {
            // 当窗口从最小化恢复时,确保窗口显示在最前面并获得焦点
            modifySeatTemplateWin.raise()
            modifySeatTemplateWin.requestActivate()
        }
    }

    width: 600; height: 410
    minimumWidth: 600; minimumHeight: 410

    visible: true
    color: "transparent"
    flags: Qt.FramelessWindowHint
    modality: Qt.ApplicationModal

    // 车次号
    property string trainNumber: ""
    // 当前车厢配置 [{seatLevel: "一等座", rows: 10, cols: 2}, ...]
    property var currentCarriages: []

    // signal seatTemplateUpdated()
    signal closed()
    signal confirmed(var info)

    // 当 currentCarriages 变化时自动加载模板
    onCurrentCarriagesChanged: {
        loadCurrentTemplate()
    }

    Rectangle {
        id: root
        width: parent.width
        height: parent.height
        color: "#ffffff"
        border.color: "#666"
        border.width: 2
        radius: 16

        //拖动逻辑
        MouseArea {
           anchors.fill: parent
           // 定义拖动
           property real clickX: 0
           property real clickY: 0

           onPressed: function(mouse) {
               clickX = mouse.x;
               clickY = mouse.y;
           }
           onPositionChanged: function(mouse) {
               // 拖动窗口
               modifySeatTemplateWin.x += mouse.x - clickX;
               modifySeatTemplateWin.y += mouse.y - clickY;
           }
       }

        // 顶部渐变标题栏
        Header{
            titleFontSize: 18
            id: titleBar
            width: parent.width - 4
            height: 45
            anchors.top: parent.top
            anchors.topMargin: 2
            anchors.left: parent.left
            anchors.leftMargin: 2
            title: "修改座位模板 - " + trainNumber
            onCloseClicked: {
                modifySeatTemplateWin.visible = false
            }
        }

        // 内容区
        ColumnLayout {
            anchors.left: parent.left
            anchors.leftMargin: 36
            anchors.right: parent.right
            anchors.rightMargin: 36
            anchors.top: titleBar.bottom
            anchors.topMargin: 16
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 42
            spacing: 8

            // 车厢总数（只读，根据下面配置自动计算）
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Label {
                    text: "车厢总数："
                    font.pixelSize: 14
                    color: "#444"
                    Layout.preferredWidth: 70
                }
                TextField {
                    id: totalCarriage
                    Layout.preferredWidth: 60
                    height: 26
                    font.pixelSize: 13
                    text: "0"
                    validator: IntValidator { bottom: 1 }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    background: Rectangle {
                        radius: 5
                        border.color: "#888"
                        border.width: 1
                        color: "#fff"
                    }
                }
                Label {
                    text: "（车厢数应等于下方配置的车厢范围总和）"
                    font.pixelSize: 12
                    color: "#666"
                }
                Item { Layout.fillWidth: true }
            }



            // 一等座
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                //标题
                Label {
                    text: "一等座"
                    font.pixelSize: 14
                    color: "#4282e6"
                    Layout.bottomMargin: 2
                }

                Item{
                    Layout.fillHeight:true
                }

                // 分割线
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#e0e6ef"
                    opacity: 0.9
                }

                Item{
                    Layout.fillHeight: true
                }

                //输入一等座信息
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    Label {
                        text: "车厢："
                        font.pixelSize: 13
                        color: "#444"
                        Layout.preferredWidth: 45
                        horizontalAlignment: Text.AlignRight
                    }
                    TextField {
                        id: firstStart
                        Layout.preferredWidth: 40
                        height: 24
                        font.pixelSize: 12
                        text: "1"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        background: Rectangle {
                            radius: 5
                            border.color: "#888"
                            border.width: 1
                            color: "#fff"
                        }
                        onTextChanged: updateTotalCarriageCount()
                    }
                    Label { text: "到"; font.pixelSize: 13; color: "#444" }
                    TextField {
                        id: firstEnd
                        Layout.preferredWidth: 40
                        height: 24
                        font.pixelSize: 12
                        text: "2"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        background: Rectangle {
                            radius: 5
                            border.color: "#888"
                            border.width: 1
                            color: "#fff"
                        }
                        onTextChanged: updateTotalCarriageCount()
                    }
                    Label { text: "车厢"; font.pixelSize: 13; color: "#444" }

                    Item{
                        Layout.fillWidth: true
                    }

                    Label { text: "行数："; font.pixelSize: 13; color: "#444" }
                    TextField {
                        id: firstRows
                        Layout.preferredWidth: 40
                        height: 24
                        font.pixelSize: 12
                        text: "10"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        background: Rectangle {
                            radius: 5
                            border.color: "#888"
                            border.width: 1
                            color: "#fff"
                        }
                    }

                    Item{
                        Layout.fillWidth: true
                    }

                    Label { text: "列数："; font.pixelSize: 13; color: "#444" }
                    TextField {
                        id: firstCols
                        Layout.preferredWidth: 40
                        height: 24
                        font.pixelSize: 12
                        text: "2"
                        validator: IntValidator { bottom: 1; top: 26 }
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        background: Rectangle {
                            radius: 5
                            border.color: "#888"
                            border.width: 1
                            color: "#fff"
                        }
                    }
                    Item { Layout.fillWidth: true }
                }

                Item{
                    Layout.fillHeight: true
                }

            }



            // 二等座
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                //标题
                Label {
                    text: "二等座"
                    font.pixelSize: 14
                    color: "#4282e6"
                    Layout.bottomMargin: 2
                }

                Item{
                    Layout.fillHeight:true
                }

                // 分割线
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#e0e6ef"
                    opacity: 0.9
                }

                Item{
                    Layout.fillHeight: true
                }

                //输入二等座信息
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    Label {
                        text: "车厢："
                        font.pixelSize: 13
                        color: "#444"
                        Layout.preferredWidth: 45
                        horizontalAlignment: Text.AlignRight
                    }
                    TextField {
                        id: secondStart
                        Layout.preferredWidth: 40
                        height: 24
                        font.pixelSize: 12
                        text: "3"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        background: Rectangle {
                            radius: 5
                            border.color: "#888"
                            border.width: 1
                            color: "#fff"
                        }
                        onTextChanged: updateTotalCarriageCount()
                    }
                    Label { text: "到"; font.pixelSize: 13; color: "#444" }
                    TextField {
                        id: secondEnd
                        Layout.preferredWidth: 40
                        height: 24
                        font.pixelSize: 12
                        text: "14"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        background: Rectangle {
                            radius: 5
                            border.color: "#888"
                            border.width: 1
                            color: "#fff"
                        }
                        onTextChanged: updateTotalCarriageCount()
                    }
                    Label { text: "车厢"; font.pixelSize: 13; color: "#444" }

                    Item{
                        Layout.fillWidth: true
                    }

                    Label { text: "行数："; font.pixelSize: 13; color: "#444" }
                    TextField {
                        id: secondRows
                        Layout.preferredWidth: 40
                        height: 24
                        font.pixelSize: 12
                        text: "21"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        background: Rectangle {
                            radius: 5
                            border.color: "#888"
                            border.width: 1
                            color: "#fff"
                        }
                    }

                    Item{
                        Layout.fillWidth: true
                    }

                    Label { text: "列数："; font.pixelSize: 13; color: "#444" }
                    TextField {
                        id: secondCols
                        Layout.preferredWidth: 40
                        height: 24
                        font.pixelSize: 12
                        text: "5"
                        validator: IntValidator { bottom: 1; top: 26 }
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        background: Rectangle {
                            radius: 5
                            border.color: "#888"
                            border.width: 1
                            color: "#fff"
                        }
                    }
                    Item { Layout.fillWidth: true }
                }

                Item{
                    Layout.fillHeight: true
                }

            }


            // 商务座
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                //标题
                Label {
                    text: "商务座"
                    font.pixelSize: 14
                    color: "#4282e6"
                    Layout.bottomMargin: 2
                }

                Item{
                    Layout.fillHeight:true
                }

                // 分割线
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#e0e6ef"
                    opacity: 0.9
                }

                Item{
                    Layout.fillHeight: true
                }

                //输入商务座信息
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    Label {
                        text: "车厢："
                        font.pixelSize: 13
                        color: "#444"
                        Layout.preferredWidth: 45
                        horizontalAlignment: Text.AlignRight
                    }
                    TextField {
                        id: businessStart
                        Layout.preferredWidth: 40
                        height: 24
                        font.pixelSize: 12
                        text: "15"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        background: Rectangle {
                            radius: 5
                            border.color: "#888"
                            border.width: 1
                            color: "#fff"
                        }
                        onTextChanged: updateTotalCarriageCount()
                    }
                    Label { text: "到"; font.pixelSize: 13; color: "#444" }
                    TextField {
                        id: businessEnd
                        Layout.preferredWidth: 40
                        height: 24
                        font.pixelSize: 12
                        text: "16"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        background: Rectangle {
                            radius: 5
                            border.color: "#888"
                            border.width: 1
                            color: "#fff"
                        }
                        onTextChanged: updateTotalCarriageCount()
                    }
                    Label { text: "车厢"; font.pixelSize: 13; color: "#444" }

                    Item{
                        Layout.fillWidth: true
                    }

                    Label { text: "行数："; font.pixelSize: 13; color: "#444" }
                    TextField {
                        id: businessRows
                        Layout.preferredWidth: 40
                        height: 24
                        font.pixelSize: 12
                        text: "10"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        background: Rectangle {
                            radius: 5
                            border.color: "#888"
                            border.width: 1
                            color: "#fff"
                        }
                    }

                    Item{
                        Layout.fillWidth: true
                    }

                    Label { text: "列数："; font.pixelSize: 13; color: "#444" }
                    TextField {
                        id: businessCols
                        Layout.preferredWidth: 40
                        height: 24
                        font.pixelSize: 12
                        text: "2"
                        validator: IntValidator { bottom: 1; top: 26 }
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        background: Rectangle {
                            radius: 5
                            border.color: "#888"
                            border.width: 1
                            color: "#fff"
                        }
                    }
                    Item { Layout.fillWidth: true }
                }

                Item{
                    Layout.fillHeight: true
                }

            }

            // 底部按钮区
            RowLayout {
                Layout.topMargin: 20
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                // anchors.horizontalCenter: parent.horizontalCenter
                // anchors.bottom: parent.bottom
                // anchors.bottomMargin: 30
                spacing: 120
                // Layout.bottomMargin: 30

                CustomButton {
                    text: "确认"
                    width: 120
                    height: 30
                    onClicked: {
                        submitSeatTemplate()
                    }
                }
                CustomButton {
                    text: "取消"
                    customColor: "#e6e6e6"
                    textColor: "#666"
                    pressedColor: "#666"
                    pressedTextColor: "#fff"
                    width: 120
                    height: 30
                    onClicked: {
                        modifySeatTemplateWin.visible = false
                    }
                }
            }
        }
    }

    // 通知弹窗
    Loader {
        property string message: ""
        property var onClosedFunction: null
        id: notification
        source: ""
        active: false
        onLoaded: {
            if (item) {
                // 设置父窗口关系 - 使用主窗口避免模态窗口焦点竞争
                item.transientParent = ApplicationWindow.window
                // 连接关闭信号
                item.closed.connect(onClosedFunction)
                // 初始化参数
                item.contentText = message
                item.visible = true
            }
        }
    }

    // 加载当前车厢模板配置
    function loadCurrentTemplate() {
        console.log("加载车厢模板:", trainNumber, "车厢数:", currentCarriages.length)
        
        // 清空所有字段
        firstStart.text = ""
        firstEnd.text = ""
        firstRows.text = ""
        firstCols.text = ""
        secondStart.text = ""
        secondEnd.text = ""
        secondRows.text = ""
        secondCols.text = ""
        businessStart.text = ""
        businessEnd.text = ""
        businessRows.text = ""
        businessCols.text = ""
        
        if (currentCarriages.length === 0) {
            totalCarriage.text = "0"
            return
        }
        
        // 按车厢类型分组统计
        var firstClass = {start: -1, end: -1, rows: 0, cols: 0}
        var secondClass = {start: -1, end: -1, rows: 0, cols: 0}
        var businessClass = {start: -1, end: -1, rows: 0, cols: 0}
        
        for (var i = 0; i < currentCarriages.length; i++) {
            var carriage = currentCarriages[i]
            var carriageNum = i + 1
            
            console.log("车厢", carriageNum, ":", carriage.seatLevel, carriage.rows + "行", carriage.cols + "列")
            
            if (carriage.seatLevel === "一等座") {
                if (firstClass.start === -1) {
                    firstClass.start = carriageNum
                    firstClass.rows = carriage.rows
                    firstClass.cols = carriage.cols
                }
                firstClass.end = carriageNum
            } else if (carriage.seatLevel === "二等座") {
                if (secondClass.start === -1) {
                    secondClass.start = carriageNum
                    secondClass.rows = carriage.rows
                    secondClass.cols = carriage.cols
                }
                secondClass.end = carriageNum
            } else if (carriage.seatLevel === "商务座") {
                if (businessClass.start === -1) {
                    businessClass.start = carriageNum
                    businessClass.rows = carriage.rows
                    businessClass.cols = carriage.cols
                }
                businessClass.end = carriageNum
            }
        }
        
        // 设置界面值
        if (firstClass.start !== -1) {
            firstStart.text = firstClass.start.toString()
            firstEnd.text = firstClass.end.toString()
            firstRows.text = firstClass.rows.toString()
            firstCols.text = firstClass.cols.toString()
        }
        
        if (secondClass.start !== -1) {
            secondStart.text = secondClass.start.toString()
            secondEnd.text = secondClass.end.toString()
            secondRows.text = secondClass.rows.toString()
            secondCols.text = secondClass.cols.toString()
        }
        
        if (businessClass.start !== -1) {
            businessStart.text = businessClass.start.toString()
            businessEnd.text = businessClass.end.toString()
            businessRows.text = businessClass.rows.toString()
            businessCols.text = businessClass.cols.toString()
        }
        
        // 设置车厢总数
        totalCarriage.text = currentCarriages.length.toString()
        console.log("加载完成,车厢总数:", currentCarriages.length)
    }

    // 更新车厢总数显示
    function updateTotalCarriageCount() {
        var total = 0
        
        var fStart = parseInt(firstStart.text)
        var fEnd = parseInt(firstEnd.text)
        if (!isNaN(fStart) && !isNaN(fEnd) && fEnd >= fStart) {
            total += (fEnd - fStart + 1)
        }
        
        var sStart = parseInt(secondStart.text)
        var sEnd = parseInt(secondEnd.text)
        if (!isNaN(sStart) && !isNaN(sEnd) && sEnd >= sStart) {
            total += (sEnd - sStart + 1)
        }
        
        var bStart = parseInt(businessStart.text)
        var bEnd = parseInt(businessEnd.text)
        if (!isNaN(bStart) && !isNaN(bEnd) && bEnd >= bStart) {
            total += (bEnd - bStart + 1)
        }
        
        totalCarriage.text = total.toString()
    }

    // 提交座位模板
    function submitSeatTemplate() {
        // 获取输入值
        var totalCarriageNum = parseInt(totalCarriage.text)
        var fStart = parseInt(firstStart.text)
        var fEnd = parseInt(firstEnd.text)
        var fRows = parseInt(firstRows.text)
        var fCols = parseInt(firstCols.text)
        
        var sStart = parseInt(secondStart.text)
        var sEnd = parseInt(secondEnd.text)
        var sRows = parseInt(secondRows.text)
        var sCols = parseInt(secondCols.text)
        
        var bStart = parseInt(businessStart.text)
        var bEnd = parseInt(businessEnd.text)
        var bRows = parseInt(businessRows.text)
        var bCols = parseInt(businessCols.text)
        
        // 基础验证
        if (isNaN(totalCarriageNum) || totalCarriageNum <= 0) {
            showError("请输入有效的车厢总数")
            return
        }
        
        // 收集所有有效的车厢范围
        var ranges = []
        
        // 一等座
        if (!isNaN(fStart) && !isNaN(fEnd)) {
            if (fEnd < fStart) {
                showError("一等座结束车厢号不能小于起始车厢号")
                return
            }
            if (isNaN(fRows) || fRows <= 0 || isNaN(fCols) || fCols <= 0) {
                showError("一等座行数和列数必须为正整数")
                return
            }
            if (fCols > 26) {
                showError("一等座列数不能超过26")
                return
            }
            ranges.push({
                start: fStart,
                end: fEnd,
                type: "一等座",
                rows: fRows,
                cols: fCols
            })
        }
        
        // 二等座
        if (!isNaN(sStart) && !isNaN(sEnd)) {
            if (sEnd < sStart) {
                showError("二等座结束车厢号不能小于起始车厢号")
                return
            }
            if (isNaN(sRows) || sRows <= 0 || isNaN(sCols) || sCols <= 0) {
                showError("二等座行数和列数必须为正整数")
                return
            }
            if (sCols > 26) {
                showError("二等座列数不能超过26")
                return
            }
            ranges.push({
                start: sStart,
                end: sEnd,
                type: "二等座",
                rows: sRows,
                cols: sCols
            })
        }
        
        // 商务座
        if (!isNaN(bStart) && !isNaN(bEnd)) {
            if (bEnd < bStart) {
                showError("商务座结束车厢号不能小于起始车厢号")
                return
            }
            if (isNaN(bRows) || bRows <= 0 || isNaN(bCols) || bCols <= 0) {
                showError("商务座行数和列数必须为正整数")
                return
            }
            if (bCols > 26) {
                showError("商务座列数不能超过26")
                return
            }
            ranges.push({
                start: bStart,
                end: bEnd,
                type: "商务座",
                rows: bRows,
                cols: bCols
            })
        }
        
        // 至少要有一种座位类型
        if (ranges.length === 0) {
            showError("至少需要配置一种座位类型")
            return
        }
        
        // 按起始车厢号排序
        ranges.sort(function(a, b) { return a.start - b.start })
        
        // 验证车厢范围不交叉且连续
        for (var i = 0; i < ranges.length; i++) {
            // 检查是否从1开始
            if (i === 0 && ranges[i].start !== 1) {
                showError("车厢必须从1号开始,当前从" + ranges[i].start + "号开始")
                return
            }
            
            // 检查是否有交叉或遗漏
            if (i > 0) {
                var prevEnd = ranges[i - 1].end
                var currStart = ranges[i].start
                
                if (currStart <= prevEnd) {
                    showError(ranges[i - 1].type + "(" + ranges[i - 1].start + "-" + prevEnd + ")与" + 
                             ranges[i].type + "(" + currStart + "-" + ranges[i].end + ")车厢范围交叉")
                    return
                }
                
                if (currStart !== prevEnd + 1) {
                    showError("车厢范围不连续:第" + prevEnd + "号车厢后应为第" + (prevEnd + 1) + "号,但配置为第" + currStart + "号")
                    return
                }
            }
        }
        
        // 验证最后一个车厢号等于总车厢数
        var lastEnd = ranges[ranges.length - 1].end
        if (lastEnd !== totalCarriageNum) {
            showError("车厢配置总数(" + lastEnd + ")与车厢总数(" + totalCarriageNum + ")不符")
            return
        }
        
        // 不要构造新的车厢数组，直接使用前端传回的数据，否则传递过多无用信息
        // // 构建新的车厢配置数组
        // var carriages = []
        // for (var i = 0; i < ranges.length; i++) {
        //     var range = ranges[i]
        //     for (var j = range.start; j <= range.end; j++) {
        //         carriages.push({
        //             seatLevel: range.type,
        //             rows: range.rows,
        //             cols: range.cols
        //         })
        //     }
        // }
        confirmed({
            carriageNum: totalCarriageNum,
            firstStart: fStart,
            firstEnd: fEnd,
            firstRows: fRows,
            firstCols: fCols,
            secondStart: sStart,
            secondEnd: sEnd,
            secondRows: sRows,
            secondCols: sCols,
            businessStart: bStart,
            businessEnd: bEnd,
            businessRows: bRows,
            businessCols: bCols,
            carriageRanges: ranges
        })

        // // 调用后端API更新座位模板
        // var result = trainManager.updateSeatTemplate_api({
        //     trainNumber: trainNumber,
        //     carriages: carriages
        // })

        // if (result.success) {
        //     notification.message = "座位模板修改成功！"
        //     notification.onClosedFunction = function() {
        //         notification.active = false
        //         seatTemplateUpdated()
        //         modifySeatTemplateWin.visible = false
        //     }
        // } else {
        //     notification.message = result.message || "座位模板修改失败！"
        //     notification.onClosedFunction = function() { notification.active = false }
        // }
        
        // notification.source = "qrc:/qml/components/ConfirmDialog.qml"
        // notification.active = true
    }
    
    // 显示错误提示
    function showError(message) {
        console.log("验证错误:", message)
        notification.message = message
        notification.onClosedFunction = function() { notification.active = false }
        notification.source = "qrc:/qml/components/ConfirmDialog.qml"
        notification.active = true
    }
}
