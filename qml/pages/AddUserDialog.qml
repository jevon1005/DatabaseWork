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
        color: "#ffffff"
        border.color: "#666"
        border.width: 2
        radius: 16

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
            title: "添加用户"

        }

        // 内容区
        ColumnLayout {
            anchors.left: parent.left
            anchors.leftMargin: 30
            anchors.right: parent.right
            anchors.rightMargin: 50
            anchors.top: titleBar.bottom
            anchors.topMargin: 28
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 28

            // 用户名
            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                Label {
                    text: "用户名："
                    font.pixelSize: 14
                    Layout.preferredWidth: 70
                    color: "#666"
                    horizontalAlignment: Text.AlignRight
                }

                TextField {
                    id: usernameField
                    Layout.fillWidth: true
                    height: 32
                    font.pixelSize: 14
                    background: Rectangle {
                        radius: 5
                        border.color: "#999"
                        border.width: 1
                        color: "#fff"
                    }
                }
            }

            // 密码
            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                Label {
                    text: "密 码："
                    font.pixelSize: 14
                    color: "#444"
                    Layout.preferredWidth: 70
                    horizontalAlignment: Text.AlignRight
                }
                TextField {
                    id: passwordField
                    Layout.fillWidth: true
                    height: 32
                    echoMode: TextInput.Password
                    font.pixelSize: 14
                    background: Rectangle {
                        radius: 5
                        border.color: "#999"
                        border.width: 1
                        color: "#fff"
                    }
                }
            }

            // 管理员
            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                Label {
                    text: "管理员："
                    font.pixelSize: 14
                    color: "#444"
                    Layout.preferredWidth: 70
                    horizontalAlignment: Text.AlignRight
                }
                CheckButton {
                    id: adminCheck
                    checked: false
                    buttonWidth: 24
                    buttonHeight: 18
                    buttonRadius: 4
                }
                Item { Layout.fillWidth: true } // 占位
            }


            // 按钮区
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.preferredWidth: 22}
                // 确认按钮
                CustomButton{
                    buttonType: "confirm"
                    text: "确认"
                    height: 26
                    width:100
                    fontSize:14
                }

                Item { Layout.fillWidth: true }

                // 取消按钮
                CustomButton{
                    buttonType: "cancel"
                    text: "取消"
                    height: 26
                    width:100
                    fontSize:14
                }

                Item { Layout.preferredWidth: 22}
            }
        }
    }
}
