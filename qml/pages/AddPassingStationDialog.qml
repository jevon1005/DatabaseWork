import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

Window {
    id: mainWindow
    width: 400; height: 260
    minimumWidth: 400; minimumHeight: 260;
    maximumWidth: 1920; maximumHeight: 1440
    visible: true
    color: "transparent"
    flags: Qt.FramelessWindowHint

    Rectangle {
        id:root
        width: parent.width
        height: parent.height
        radius: 16
        color: "#ffffff"
        border.color: "#666"
        border.width: 2

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
            id:titleBar
            width: parent.width - 4
            height: 45
            anchors.top: parent.top
            anchors.topMargin: 2
            anchors.left: parent.left
            anchors.leftMargin: 2
            title: "添加停靠站"

        }

        // 内容区
        ColumnLayout {
            anchors.left: parent.left
            anchors.leftMargin: 24
            anchors.right: parent.right
            anchors.rightMargin: 40
            anchors.top: titleBar.bottom
            anchors.topMargin: 20
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 28

            // 第一排：站名 到时
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Label {
                    text: "站名："
                    font.pixelSize: 12
                    color: "#444"
                    Layout.preferredWidth: 60
                    horizontalAlignment: Text.AlignRight
                }
                ComboBox {
                    id: stationName
                    Layout.preferredWidth: 100

                    model: ["--"].concat(Array.from({length: 24}, (_, i) => i.toString().padStart(2, "0")))
                    currentIndex: 0
                    contentItem: Text {
                        text: parent.displayText

                        // horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                        color: "#444"
                        anchors.fill: parent
                        anchors.leftMargin: 6
                    }
                }

                Item{
                    Layout.fillWidth: true
                }
            }

            // 第二排：是否起始站 开时
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Label {
                    text: "到时："
                    font.pixelSize: 12
                    color: "#444"
                    Layout.preferredWidth: 60
                    horizontalAlignment: Text.AlignRight
                }

                // 到时：小时
                ComboBox {
                    id: arriveHour
                    Layout.preferredWidth: 42

                    model: ["--"].concat(Array.from({length: 24}, (_, i) => i.toString().padStart(2, "0")))
                    currentIndex: 0
                    contentItem: Text {
                        text: parent.displayText

                        // horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                        color: "#444"
                        anchors.fill: parent
                        anchors.leftMargin: 6
                    }

                }
                Label { text: "时"; font.pixelSize: 12; color: "#444"; }

                // 到时：分钟
                ComboBox {
                    id: arriveMinute
                    Layout.preferredWidth: 42
                    model: ["--"].concat(Array.from({length: 60}, (_, i) => i.toString().padStart(2, "0")))
                    currentIndex: 0
                    contentItem: Text {
                        text: parent.displayText
                        // horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                        color: "#444"
                        anchors.fill: parent
                        anchors.leftMargin: 6
                    }
                }
                Label { text: "分"; font.pixelSize: 12; color: "#444"; }
            }

            // 第二排：是否起始站 开时
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Label {
                    text: "开时："
                    font.pixelSize: 12
                    color: "#444"
                    Layout.preferredWidth: 60
                    horizontalAlignment: Text.AlignRight
                }

                // 开时：小时
                ComboBox {
                    id: departHour
                    Layout.preferredWidth: 42
                    model: ["--"].concat(Array.from({length: 24}, (_, i) => i.toString().padStart(2, "0")))
                    currentIndex: 0
                    contentItem: Text {
                        text: parent.displayText
                        // horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                        color: "#444"
                        anchors.fill: parent
                        anchors.leftMargin: 6
                    }
                }
                Label { text: "时"; font.pixelSize: 12; color: "#444"; }

                // 开时：分钟
                ComboBox {
                    id: departMinute
                    Layout.preferredWidth: 42
                    model: ["--"].concat(Array.from({length: 60}, (_, i) => i.toString().padStart(2, "0")))
                    currentIndex: 0
                    contentItem: Text {
                        text: parent.displayText
                        // horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                        color: "#444"
                        anchors.fill: parent
                        anchors.leftMargin: 6
                    }
                }
                Label { text: "分"; font.pixelSize: 12; color: "#444"; }
            }


            // 按钮区
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.preferredWidth: 22}
                // 确认按钮
                CustomButton{
                    buttonType: "confirm"
                    text: "确认"
                    height: 20
                    width:90
                    fontSize:12
                }

                Item { Layout.fillWidth: true }

                // 取消按钮
                CustomButton{
                    buttonType: "cancel"
                    text: "取消"
                    height: 20
                    width:90
                    fontSize:12
                }

                Item { Layout.preferredWidth: 22}
            }
        }
    }
}
