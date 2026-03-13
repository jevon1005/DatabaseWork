import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

Window {
    id: mainWindow
    width: 420; height: 260
    minimumWidth: 400; minimumHeight: 260;
    maximumWidth: 1920; maximumHeight: 1440;
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

    signal confirmed(var info)
    signal canceled()

    Rectangle {
        id:root
        width: parent.width
        height: parent.height
        color: "#ffffff"
        border.color: "#808080"
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
            id: titleBar
            width: parent.width - 5
            height: 45
            anchors.top: parent.top
            anchors.topMargin: 1
            anchors.left: parent.left
            anchors.leftMargin: 1
            title: "重置密码"
            onCloseClicked: canceled()
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
                    text: "输入新密码："
                    font.pixelSize: 14
                    Layout.preferredWidth: 70
                    color: "#666"
                    horizontalAlignment: Text.AlignRight
                }

                TextField {
                    id: passwordField
                    placeholderText: "请输入密码"
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
                    text: "确认密码："
                    font.pixelSize: 14
                    color: "#444"
                    Layout.preferredWidth: 70
                    horizontalAlignment: Text.AlignRight
                }
                TextField {
                    id: passwordAgainField
                    placeholderText: "请再次输入密码"
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
                    onClicked: confirmed({
                        password: passwordField.text,
                        passwordAgain: passwordAgainField.text
                    })
                }

                Item { Layout.fillWidth: true }

                // 取消按钮
                CustomButton{
                    buttonType: "cancel"
                    text: "取消"
                    height: 26
                    width:100
                    fontSize:14
                    onClicked: canceled()
                }

                Item { Layout.preferredWidth: 22}
            }
        }
    }
}
