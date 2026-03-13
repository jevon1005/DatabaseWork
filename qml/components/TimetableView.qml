import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: timetable
    width: 370
    height: 320

    property var passingStationList: [
        { stationName: "乌鲁木齐北", arriveHour: -1, arriveMinute: -1, arriveDay: -1, departureHour: 9, departureMinute: 30, departureDay: 0, stopInterval: -1, passInfo: "起末站" },
        { stationName: "中间站", arriveHour: 12, arriveMinute: 30, arriveDay: 0, departureHour: 13, departureMinute: 0, departureDay: 0, stopInterval: 30, passInfo: "中间站" },
        { stationName: "中间站", arriveHour: 12, arriveMinute: 30, arriveDay: 0, departureHour: 13, departureMinute: 0, departureDay: 0, stopInterval: 30, passInfo: "中间站" },
        { stationName: "中间站", arriveHour: 12, arriveMinute: 30, arriveDay: 0, departureHour: 13, departureMinute: 0, departureDay: 0, stopInterval: 30, passInfo: "中间站" },
        { stationName: "中间站", arriveHour: 12, arriveMinute: 30, arriveDay: 1, departureHour: 13, departureMinute: 0, departureDay: 1, stopInterval: 30, passInfo: "中间站" },
        { stationName: "中间站", arriveHour: 12, arriveMinute: 30, arriveDay: 1, departureHour: 13, departureMinute: 0, departureDay: 1, stopInterval: 30, passInfo: "中间站" },
        { stationName: "中间站", arriveHour: 12, arriveMinute: 30, arriveDay: 1, departureHour: 13, departureMinute: 0, departureDay: 1, stopInterval: 30, passInfo: "中间站" },
        { stationName: "中间站", arriveHour: 12, arriveMinute: 30, arriveDay: 1, departureHour: 13, departureMinute: 0, departureDay: 1, stopInterval: 30, passInfo: "中间站" },
        { stationName: "中间站", arriveHour: 12, arriveMinute: 30, arriveDay: 2, departureHour: 13, departureMinute: 0, departureDay: 2, stopInterval: 30, passInfo: "中间站" },
        { stationName: "呼和浩特北", arriveHour: 19, arriveMinute: 30, arriveDay: 2, departureHour: -1, departureMinute: -1, departureDay: -1, stopInterval: -1, passInfo: "起末站" },
        { stationName: "其他站", arriveHour: 12, arriveMinute: 30, arriveDay: 0, departureHour: 13, departureMinute: 0, departureDay: 0, stopInterval: 30, passInfo: "其他站" },
        { stationName: "其他站", arriveHour: 12, arriveMinute: 30, arriveDay: 0, departureHour: 13, departureMinute: 0, departureDay: 0, stopInterval: 30, passInfo: "其他站" },
        { stationName: "其他站", arriveHour: 12, arriveMinute: 30, arriveDay: 0, departureHour: 13, departureMinute: 0, departureDay: 0, stopInterval: 30, passInfo: "其他站" },
        { stationName: "其他站", arriveHour: 12, arriveMinute: 30, arriveDay: 0, departureHour: 13, departureMinute: 0, departureDay: 0, stopInterval: 30, passInfo: "其他站" },
    ]

    property bool showButtons: true

    // 新增：外部可控边框宽度
    property int borderWidth: 1

    // 格式化停留时间的函数
    // 一小时以内显示多少分，一天内显示几小时几分，超过一天显示几天几小时（不显示分了）
    function formatStopInterval(minutes) {
        if (minutes === -1) {
            return "---"
        }
        else if (minutes < 60) {
            // 一小时以内：显示分钟
            return minutes + "分"
        }
        else if (minutes < 1440) {
            // 一天内（24小时）：显示几小时几分
            var hours = Math.floor(minutes / 60)
            var mins = minutes % 60
            if (mins === 0) {
                return hours + "小时"
            }
            else {
                return hours + "小时" + mins + "分"
            }
        }
        else {
            // 超过一天：显示几天几小时（不显示分）
            var days = Math.floor(minutes / 1440)
            var remainingMinutes = minutes % 1440
            var hours = Math.floor(remainingMinutes / 60)
            if (hours === 0) {
                return days + "天"
            } else {
                return days + "天" + hours + "小时"
            }
        }
    }

    //背景
    Rectangle {
        anchors.fill: parent
        radius: 8
        color: "#fff"
        border.color: "#dde"
        border.width: borderWidth   // 这里引用属性
    }

    ColumnLayout{
        width: parent.width - 4
        height: parent.height

        // 表头
        Rectangle {
            Layout.topMargin: 2
            // Layout.leftMargin: 2
            // Layout.rightMargin: 2
            radius: 8
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            color: "#f4f9ff"
            RowLayout {
                width: parent.width
                height: parent.height
                // 左侧编辑图标占位
                Item { Layout.preferredWidth: 36; visible: showButtons }

                //间隔
                Item{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }

                Text {
                    text: "站名"
                    color: "#4D4D4D"
                    Layout.preferredWidth: 60
                    horizontalAlignment: Text.AlignHCenter
                }

                //间隔
                Item{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }

                Text {
                    text: "到时"
                    color: "#4D4D4D"
                    Layout.preferredWidth: 55
                    horizontalAlignment: Text.AlignHCenter
                }

                //间隔
                Item{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }

                Text {
                    text: "发时"
                    color: "#4D4D4D"
                    Layout.preferredWidth: 55
                    horizontalAlignment: Text.AlignHCenter
                }

                //间隔
                Item{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }

                Text {
                    text: "停留"
                    color: "#4D4D4D"
                    Layout.preferredWidth: 48
                    horizontalAlignment: Text.AlignHCenter
                }

                //间隔
                Item{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }

                // 右侧删除图标占位
                Item { Layout.preferredWidth: 36; visible: showButtons }
            }
        }

        //表格背景
        Rectangle{
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.leftMargin: 2
            Layout.rightMargin: 2
            Layout.bottomMargin: 2
            radius:8
            // 表格内容
            ListView {
                id: stationListView
                clip: true
                model: passingStationList
                anchors.fill: parent

                // 完全自定义滚动条样式
                ScrollBar.vertical: BasicScrollBar {
                    width: 4
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height - 8
                    policy: ScrollBar.AlwaysOn
                    handleNormalColor: "#a0a0a0"
                    handleLength: 60 
                }

                delegate: ColumnLayout {
                    width: stationListView.width
                        Rectangle {
                            Layout.topMargin: -5
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            radius: 6
                            gradient: Gradient {
                                orientation: Gradient.Horizontal   // 横向渐变
                                GradientStop { position: 0.0; color: "#fff"}
                                GradientStop { position: 0.2; color: mouseArea.containsMouse ? "#F0F8FF" : "#fff"}
                                GradientStop { position: 0.8; color: mouseArea.containsMouse ? "#F0F8FF" : "#fff"}
                                GradientStop { position: 1.0; color: "#fff"}
                            }

                            MouseArea {
                                id: mouseArea
                                enabled: showButtons
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.RightButton
                                onClicked: {
                                    menu.popup()
                                }
                            }

                            // 新增菜单
                            Menu {
                                id: menu
                                background: Rectangle {
                                    implicitWidth: 75
                                    implicitHeight: 20
                                    color: "#409CFC"
                                    radius: 3
                                }
                                MenuItem {
                                    implicitWidth: 75
                                    implicitHeight: 20
                                    background: Rectangle {
                                        anchors.fill: parent
                                        radius: 2
                                        color: "#409CFC"
                                    }
                                    contentItem: Text {
                                        text: "在下方新增"
                                        color: "#fff"
                                        font.pixelSize: 12
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    onTriggered: {
                                        // 使用局部变量捕获对象，防止 delegate 销毁后无法访问
                                        var dialog = editPassingStationDialog
                                        var currentIndex = index
                                        dialog.stationList = stationManager.getAllStationNames_api()
                                        dialog.initialInfo = {
                                            stationName: "",
                                            arriveHour: "",
                                            arriveMinute: "",
                                            arriveDay: "",
                                            departureHour: "",
                                            departureMinute: "",
                                            departureDay: "",
                                        }
                                        dialog.onConfirmedFunction = function(info) {
                                            addPassingStation(currentIndex + 1, info)
                                            dialog.active = false
                                        }
                                        dialog.active = true
                                    }
                                }
                            }

                            RowLayout {
                                id: rowinfo
                                anchors.fill: parent
                                spacing: 0

                                property color textColor: modelData.passInfo === "起末站"
                                                          ? "#0080FF"
                                                          : (modelData.passInfo === "其他站"
                                                          ? "#808080"
                                                          : "#000")

                                // 编辑按钮
                                Rectangle {
                                    visible: showButtons
                                    Layout.preferredWidth: 36
                                    Layout.preferredHeight: 40
                                    color: "transparent"
                                    Image {
                                        source: "qrc:/resources/icon/Edit.png"
                                        anchors.fill: parent
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            var dialog = editPassingStationDialog
                                            var currentIndex = index
                                            dialog.stationList = stationManager.getAllStationNames_api()
                                            dialog.initialInfo = modelData
                                            dialog.onConfirmedFunction = function(info) {
                                                editPassingStaion(currentIndex, info)
                                                dialog.active = false
                                            }
                                            dialog.active = true
                                        }
                                    }
                                }

                                //间隔
                                Item{
                                    Layout.fillWidth: true
                                }

                                //站名
                                Text {
                                    text: modelData.stationName === "" ? "---" : modelData.stationName
                                    color: rowinfo.textColor
                                    Layout.preferredWidth: 60
                                    Layout.preferredHeight: 40
                                    verticalAlignment: Text.AlignVCenter
                                    // font.pixelSize: 16
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                //间隔
                                Item{
                                    Layout.fillWidth: true
                                }

                                //到时
                                Rectangle{
                                    Layout.preferredWidth: 55
                                    Layout.preferredHeight: 38
                                    color: "transparent"

                                    Text {
                                        id: arrivetime
                                        text: (modelData.arriveHour === -1 || modelData.arriveMinute === -1)
                                              ? "---"
                                              : ("0" + modelData.arriveHour).slice(-2) + ":" + ("0" + modelData.arriveMinute).slice(-2)
                                        color: rowinfo.textColor
                                        // Layout.preferredWidth: 55
                                        // Layout.preferredHeight: 40
                                        anchors.centerIn: parent
                                        // verticalAlignment: Text.AlignVCenter
                                        // font.pixelSize: 16
                                        // horizontalAlignment: Text.AlignHCenter
                                    }

                                    Text{
                                        text: "+" + modelData.arriveDay
                                        visible: modelData.arriveDay > 0
                                        color: "#0080FF"
                                        // Layout.preferredWidth: 25
                                        // Layout.preferredHeight: 10
                                        font.pixelSize: 8
                                        anchors.left: arrivetime.right
                                        anchors.top: arrivetime.top
                                    }
                                }



                                //间隔
                                Item{
                                    Layout.fillWidth: true
                                }

                                //发时
                                Rectangle{
                                    Layout.preferredWidth: 55
                                    Layout.preferredHeight: 38
                                    color: "transparent"

                                    Text {
                                        id: departuretime
                                        text: (modelData.departureHour === -1 || modelData.departureMinute === -1)
                                              ? "---"
                                              : ("0" + modelData.departureHour).slice(-2) + ":" + ("0" + modelData.departureMinute).slice(-2)
                                        color: rowinfo.textColor
                                        anchors.centerIn: parent
                                        // verticalAlignment: Text.AlignVCenter
                                        // font.pixelSize: 16
                                        // horizontalAlignment: Text.AlignHCenter
                                    }

                                    Text{
                                        text: "+" + modelData.departureDay
                                        visible: modelData.departureDay > 0
                                        color: "#0080FF"
                                        // Layout.preferredWidth: 25
                                        // Layout.preferredHeight: 10
                                        font.pixelSize: 8
                                        anchors.left: departuretime.right
                                        anchors.top: departuretime.top
                                    }
                                }

                                //间隔
                                Item{
                                    Layout.fillWidth: true
                                }

                                //停留
                                Text {
                                    text: formatStopInterval(modelData.stopInterval)
                                    color: rowinfo.textColor
                                    Layout.preferredWidth: 48
                                    Layout.preferredHeight: 40
                                    verticalAlignment: Text.AlignVCenter
                                    // font.pixelSize: 16
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                //间隔
                                Item{
                                    Layout.fillWidth: true
                                }

                                // 删除按钮
                                Rectangle {
                                    visible: showButtons
                                    Layout.preferredWidth: 36
                                    Layout.preferredHeight: 40
                                    color: "transparent"
                                    Image {
                                        source: "qrc:/resources/icon/Delete.png"
                                        anchors.fill: parent
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            deletePassingStation(index)
                                        }
                                    }
                                }
                            }
                        }

                        // 行分割线
                        Rectangle {
                            Layout.topMargin: -12
                            Layout.leftMargin: 35
                            Layout.rightMargin: 35
                            Layout.fillWidth: true
                            Layout.preferredHeight: 2
                            // Layout.leftMargin: 36
                            // Layout.columnSpan: 6
                            color: "#b3b3b3"
                        }
                    }
            }
        }
    }

    // 修改或添加
    Loader {
        // 初始信息，即修改前的信息
        property var initialInfo: ({
           stationName: "",
           arriveHour: "",
           arriveMinute: "",
           arriveDay: "",
           departureHour: "",
           departureMinute: "",
           departureDay: "",
       })
        // 所有车站名，从后端获得
        property var stationList: []
        // 点击确认后执行的函数
        property var onConfirmedFunction: function() {}
        id: editPassingStationDialog
        source: "qrc:/qml/pages/EditPassingStationDialog.qml"
        active: false
        onLoaded: {
            if (item) {
                // 连接取消信号
                item.canceled.connect(function() {
                    editPassingStationDialog.active = false
                })
                // 连接确认信号
                item.confirmed.connect(onConfirmedFunction)
                //初始化参数
                item.stationInfo = initialInfo
                item.stationList = stationList
                item.visible = true
            }
        }
    }

    // 整体重置停靠站列表（触发前端刷新），并且记录滚动条，参数为滚动条刷新后和原来的偏移量，默认为 0，用于增加车站后自动下移滚动条
    function refreshPassingStationList(offset = 0) {
        // 记录当前滚动条位置
        var savedContentY = stationListView.contentY
        passingStationList = passingStationList
        // 回到之前记录的位置
        stationListView.contentY = savedContentY + offset
    }


    // 根据信息输入的信息生成停靠站，作用是对于任何不符合格式的内容进行规范化处理
    function generatePassingStation(info) {
        var passingStation = {}
        var stationName = info.stationName
        var arriveHour = info.arriveHour
        var arriveMinute = info.arriveMinute
        var arriveDay = info.arriveDay
        var departureHour = info.departureHour
        var departureMinute = info.departureMinute
        var departureDay = info.departureDay

        if (stationName === "") {
            passingStation.stationName = "---"
        }
        else {
            passingStation.stationName = stationName
        }
        if (arriveHour === "" || arriveHour < 0 || arriveHour > 23) {
            passingStation.arriveHour = -1
        }
        else {
            passingStation.arriveHour = arriveHour
        }
        if (arriveMinute === "" || arriveMinute < 0 || arriveMinute > 59) {
            passingStation.arriveMinute = -1
        }
        else {
            passingStation.arriveMinute = arriveMinute
        }
        if (arriveDay === "" || arriveDay < 0 || arriveDay > 99) {
            // 修复:天数不填写时只设置天数为-1,不影响时分
            passingStation.arriveDay = -1
        }
        else {
            passingStation.arriveDay = arriveDay
        }
        if (departureHour === "" || departureHour < 0 || departureHour > 23) {
            passingStation.departureHour = -1
        }
        else {
            passingStation.departureHour = departureHour
        }
        if (departureMinute === "" || departureMinute < 0 || departureMinute > 59) {
            passingStation.departureMinute = -1
        }
        else {
            passingStation.departureMinute = departureMinute
        }
        if (departureDay === "" || departureDay < 0 || departureDay > 99) {
            // 修复:天数不填写时只设置天数为-1,不影响时分
            passingStation.departureDay = -1
        }
        else {
            passingStation.departureDay = departureDay
        }

        // 计算停留时间
        if (passingStation.arriveHour !== -1 && passingStation.arriveMinute !== -1 &&
            passingStation.departureHour !== -1 && passingStation.departureMinute !== -1 &&
            passingStation.arriveDay !== -1 && passingStation.departureDay !== -1) {
            var arriveTotalMinutes = passingStation.arriveDay * 1440 + passingStation.arriveHour * 60 + passingStation.arriveMinute
            var departureTotalMinutes = passingStation.departureDay * 1440 + passingStation.departureHour * 60 + passingStation.departureMinute
            var stopInterval = departureTotalMinutes - arriveTotalMinutes
            if (stopInterval < 0) {
                stopInterval = -1
            }
            passingStation.stopInterval = stopInterval
        }
        else {
            passingStation.stopInterval = -1
        }

        return passingStation
    }

    function editPassingStaion(index, info) {
        var passingStation = generatePassingStation(info)
        // 停靠信息不变
        passingStation.passInfo = passingStationList[index].passInfo
        passingStationList[index] = passingStation
        refreshPassingStationList()
    }

    function deletePassingStation(index) {
        // 删除的是起始站且下方有站
        if (passingStationList.length >= 2 && index === 0) {
            console.log("删除起始站！")
            passingStationList[1].arriveHour = -1
            passingStationList[1].arriveMinute = -1
            passingStationList[1].arriveDay = -1
            passingStationList[1].stopInterval = -1
            passingStationList[1].passInfo = "起末站"
        }
        // 删除的是终点站且上方有站
        else if (passingStationList.length >= 2 && index === passingStationList.length - 1) {
            console.log("删除终点站！")
            passingStationList[index - 1].departureHour = -1
            passingStationList[index - 1].departureMinute = -1
            passingStationList[index - 1].departureDay = -1
            passingStationList[index - 1].stopInterval = -1
            passingStationList[index - 1].passInfo = "起末站"
        }
        // 删除该站
        passingStationList.splice(index, 1)
        refreshPassingStationList()
    }

    function addPassingStation(index, info) {
        var passingStation = generatePassingStation(info)
        // 在终点站下方插入
        if (index === passingStationList.length || index === -1) {
            passingStation.passInfo = "起末站"
        }
        else {
            passingStation.passInfo = "中间站"
        }
        // 滚动条偏移量，如果在最后插入，滚动条要自动滚动到底部
        var offset = 0
        // 如果点击图标插入，默认插入最后
        if (index === -1 || index === passingStationList.length) {
            // 原来的终点站变成中间站
            if (passingStationList.length >= 2) {
                passingStationList[passingStationList.length - 1].passInfo = "中间站"
            }
            passingStationList.splice(passingStationList.length, 0, passingStation)
            offset = 1000
        }
        else {
            passingStationList.splice(index, 0, passingStation)
        }
        refreshPassingStationList(offset)
    }

    function onClickAddIconFunction() {
        editPassingStationDialog.stationList = stationManager.getAllStationNames_api()
        editPassingStationDialog.initialInfo = {
            stationName: "",
            arriveHour: "",
            arriveMinute: "",
            arriveDay: "",
            departureHour: "",
            departureMinute: "",
            departureDay: "",
        }
        editPassingStationDialog.onConfirmedFunction = function(info) {
            addPassingStation(-1, info)
            editPassingStationDialog.active = false
        }
        editPassingStationDialog.active = true
    }
}
