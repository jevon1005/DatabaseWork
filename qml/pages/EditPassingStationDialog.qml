import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

Window {
    id: mainWindow
    width: 450; height: 270
    minimumWidth: 400; minimumHeight: 260;
    maximumWidth: 1920; maximumHeight: 1440
    visible: true
    color: "transparent"
    flags: Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    
    // 处理窗口最小化问题
    onVisibilityChanged: function(visibility) {
        if (visibility === Window.Windowed || visibility === Window.Maximized) {
            // 当窗口从最小化恢复时,确保窗口显示在最前面并获得焦点
            mainWindow.raise()
            mainWindow.requestActivate()
        }
    }

    property var stationInfo: ({
        stationName: "",
        arriveHour: "",
        arriveMinute: "",
        arriveDay: "",
        departureHour: "",
        departureMinute: "",
        departureDay: "",
    })

    property var stationList: ["北京南", "上海站", "杭州东", "嘉兴南", "温州南"]

    signal confirmed(var info)
    signal canceled()

    Rectangle {
        id: root
        width: parent.width
        height: parent.height
        radius: 16
        border.color: "#808080"

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
               mainWindow.x += mouse.x - clickX;
               mainWindow.y += mouse.y - clickY;
           }
       }

        // 顶部渐变标题栏
        Header{
            titleFontSize: 18
            id: titleBar
            width: parent.width - 4
            height: 45
            anchors.top: parent.top
            anchors.topMargin: 1
            anchors.left: parent.left
            anchors.leftMargin: 1
            title: "修改停靠站"
            onCloseClicked: canceled()
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
            anchors.bottomMargin: 20
            spacing: 0

            // 第一行：站名
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Label {
                    text: "站名："
                    font.pixelSize: 13
                    color: "#444"
                    Layout.preferredWidth: 60
                    horizontalAlignment: Text.AlignRight
                }
                SearchableComboBox {
                    id: stationNameCombo
                    Layout.preferredWidth: 150
                    Layout.preferredHeight: 25
                    popupMaxHeight: 200
                    model: stationList
                    font.pixelSize: 13
                    itemHeight: 30
                    itemFontSize: 12
                    indicator: Item {} // 隐藏右侧箭头
                    
                    property bool updating: false
                    
                    // 当 stationList 变化时，更新 currentIndex
                    onModelChanged: {
                        if (stationInfo.stationName !== "") {
                            var index = stationList.indexOf(stationInfo.stationName)
                            if (index !== -1) {
                                updating = true
                                currentIndex = index
                                updating = false
                            }
                        }
                    }
                    
                    onCurrentIndexChanged: {
                        if (!updating && currentIndex >= 0 && currentIndex < stationList.length) {
                            stationInfo.stationName = stationList[currentIndex]
                        }
                    }

                    background: Rectangle {
                        color: stationNameCombo.hovered ? "#F5F5F5" : "#fff"
                        border.color: "#C0C0C0"
                        border.width: 1
                        radius: 4
                    }

                    contentItem: MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: stationNameCombo.popup.open() // 点击弹出菜单

                        Text {
                            anchors.fill: parent
                            text: parent.parent.displayText
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            color: "#222"
                            font.pixelSize: 13
                        }
                    }
                }

                Item{
                    Layout.fillWidth: true
                }
            }

            // 第二行：到时、到天
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                // 到时：小时
                Label {
                    text: "到时："
                    font.pixelSize: 13
                    color: "#444"
                    Layout.preferredWidth: 60
                    horizontalAlignment: Text.AlignRight
                }
                TextField {
                    id: arriveHourField
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 25
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    placeholderText: "---"
                    padding: 5
                    background: Rectangle {
                        color: "transparent"
                        border.color: "#999"
                        border.width: 1
                        radius: 6
                    }
                    text: (stationInfo.arriveHour === "" || stationInfo.arriveHour === -1) ? "" : stationInfo.arriveHour
                }
                Label { text: "时"; font.pixelSize: 12; color: "#444"; }
                // 到时：分钟
                TextField {
                    id: arriveMinuteField
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 25
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    placeholderText: "---"
                    padding: 5
                    background: Rectangle {
                        color: "transparent"
                        border.color: "#999"
                        border.width: 1
                        radius: 6
                    }
                    text: (stationInfo.arriveMinute === "" || stationInfo.arriveMinute === -1) ? "" : stationInfo.arriveMinute
                }
                Label { text: "分 +"; font.pixelSize: 12; color: "#444"; }
                // 到天
                TextField {
                    id: arriveDayField
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 25
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    placeholderText: "---"
                    padding: 5
                    background: Rectangle {
                        color: "transparent"
                        border.color: "#999"
                        border.width: 1
                        radius: 6
                    }
                    text: (stationInfo.arriveDay === "" || stationInfo.arriveDay === -1) ? "" : stationInfo.arriveDay
                }
                Label { text: "天"; font.pixelSize: 12; color: "#444"; }
            }

            // 第三行：发时、发天
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                // 发时：小时
                Label {
                    text: "发时："
                    font.pixelSize: 13
                    color: "#444"
                    Layout.preferredWidth: 60
                    horizontalAlignment: Text.AlignRight
                }
                TextField {
                    id: departureHourField
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 25
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    placeholderText: "---"
                    padding: 5
                    background: Rectangle {
                        color: "transparent"
                        border.color: "#999"
                        border.width: 1
                        radius: 6
                    }
                    text: (stationInfo.departureHour === "" || stationInfo.departureHour === -1) ? "" : stationInfo.departureHour
                }
                Label { text: "时"; font.pixelSize: 12; color: "#444"; }
                // 发时：分钟
                TextField {
                    id: departureMinuteField
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 25
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    placeholderText: "---"
                    padding: 5
                    background: Rectangle {
                        color: "transparent"
                        border.color: "#999"
                        border.width: 1
                        radius: 6
                    }
                    text: (stationInfo.departureMinute === "" || stationInfo.departureMinute === -1) ? "" : stationInfo.departureMinute
                }
                Label { text: "分 +"; font.pixelSize: 12; color: "#444"; }
                // 发天
                TextField {
                    id: departureDayField
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 25
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    placeholderText: "---"
                    padding: 5
                    background: Rectangle {
                        color: "transparent"
                        border.color: "#999"
                        border.width: 1
                        radius: 6
                    }
                    text: (stationInfo.departureDay === "" || stationInfo.departureDay === -1) ? "" : stationInfo.departureDay
                }
                Label { text: "天"; font.pixelSize: 12; color: "#444"; }
            }

            // 按钮区
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.preferredWidth: 22}
                // 确认按钮
                CustomButton{
                    buttonType: "confirm"
                    text: "确认"
                    height: 24
                    width: 90
                    fontSize:14
                    onClicked: confirmed({
                        stationName: stationList[stationNameCombo.currentIndex],
                        arriveHour: arriveHourField.text === "" ? "" : parseInt(arriveHourField.text),
                        arriveMinute: arriveMinuteField.text === "" ? "" : parseInt(arriveMinuteField.text),
                        arriveDay: arriveDayField.text === "" ? "" : parseInt(arriveDayField.text),
                        departureHour: departureHourField.text === "" ? "" : parseInt(departureHourField.text),
                        departureMinute: departureMinuteField.text === "" ? "" : parseInt(departureMinuteField.text),
                        departureDay: departureDayField.text === "" ? "" : parseInt(departureDayField.text)
                    })
                }

                Item { Layout.fillWidth: true }

                // 取消按钮
                CustomButton{
                    buttonType: "cancel"
                    text: "取消"
                    height: 24
                    width:90
                    fontSize:14
                    onClicked: canceled()
                }

                Item { Layout.preferredWidth: 22}
            }
        }
    }
}
