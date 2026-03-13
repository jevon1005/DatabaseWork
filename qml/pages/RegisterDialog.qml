import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

Window {
    id: mainWindow
    width: 600; height: 450
    minimumWidth: 600; minimumHeight: 410
    visible: true
    color: "transparent"
    flags:Qt.FramelessWindowHint
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
            title: "用户注册"
            onCloseClicked: canceled()
        }

        // 内容区
        ColumnLayout{
            anchors.left: parent.left
            anchors.leftMargin: 36
            anchors.right: parent.right
            anchors.rightMargin: 36
            anchors.top: titleBar.bottom
            anchors.topMargin: 16
            anchors.bottom: parent.bottom
            spacing: 0

            Label {
                text: "注册"
                font.pixelSize: 14
                color: "#4282e6"
                Layout.topMargin: 10
            }

            // 分割线
            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: 5
                height: 1
                color: "#e0e6ef"
                opacity: 0.9
            }

            RowLayout {
                Layout.topMargin: 15
                spacing: 10
                Label {
                    text: "用户名："
                    font.pixelSize: 13
                    color: "#444"
                    Layout.preferredWidth: 70
                    horizontalAlignment: Text.AlignRight
                }
                TextField {
                    id: usernameField
                    placeholderText: "请输入用户名（字母、数字或下划线，须以字母开头）"
                    validator: RegularExpressionValidator { regularExpression: /^[A-Za-z0-9_]{0,18}$/ }
                    Layout.preferredWidth: 350
                    height: 24
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    background: Rectangle {
                        radius: 5
                        border.color: "#888"
                        border.width: 1
                        color: "#fff"
                    }
                }
            }

            RowLayout {
                Layout.topMargin: 15
                spacing: 10
                Label {
                    text: "密码："
                    font.pixelSize: 13
                    color: "#444"
                    Layout.preferredWidth: 70
                    horizontalAlignment: Text.AlignRight
                }
                TextField {
                    id: passwordField
                    placeholderText: "请输入密码"
                    Layout.preferredWidth: 350
                    height: 24
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    background: Rectangle {
                        radius: 5
                        border.color: "#888"
                        border.width: 1
                        color: "#fff"
                    }
                }
            }

            RowLayout {
                Layout.topMargin: 15
                spacing: 10
                Label {
                    text: "确认密码："
                    font.pixelSize: 13
                    color: "#444"
                    Layout.preferredWidth: 70
                    horizontalAlignment: Text.AlignRight
                }
                TextField {
                    id: passwordAgainField
                    placeholderText: "请再次输入密码"
                    Layout.preferredWidth: 350
                    height: 24
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    background: Rectangle {
                        radius: 5
                        border.color: "#888"
                        border.width: 1
                        color: "#fff"
                    }
                }
            }

            Label {
                Layout.topMargin: 20
                text: "个人信息"
                font.pixelSize: 14
                color: "#4282e6"
            }

            // 分割线
            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: 5
                height: 1
                color: "#e0e6ef"
                opacity: 0.9
            }

            RowLayout {
                Layout.topMargin: 15
                spacing: 10
                Label {
                    text: "姓名："
                    font.pixelSize: 13
                    color: "#444"
                    Layout.preferredWidth: 70
                    horizontalAlignment: Text.AlignRight
                }
                TextField {
                    id: nameField
                    placeholderText: "请输入姓名"
                    validator: RegularExpressionValidator { regularExpression: /^\p{Script=Han}+$/u }
                    Layout.preferredWidth: 100
                    height: 24
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    background: Rectangle {
                        radius: 5
                        border.color: "#888"
                        border.width: 1
                        color: "#fff"
                    }
                }
                Label {
                    Layout.preferredWidth: 70
                    Layout.leftMargin: 40
                    text: "联系方式："
                    font.pixelSize: 13
                    color: "#444"
                    horizontalAlignment: Text.AlignRight
                }
                TextField {
                    id: phoneNumberField
                    placeholderText: "请输入联系方式"
                    validator: RegularExpressionValidator { regularExpression:  /^[0-9]{0,11}$/ }
                    Layout.preferredWidth: 150
                    height: 24
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    background: Rectangle {
                        radius: 5
                        border.color: "#888"
                        border.width: 1
                        color: "#fff"
                    }
                }
            }

            RowLayout {
                Layout.topMargin: 15
                spacing: 10
                Label {
                    text: "身份证号："
                    font.pixelSize: 13
                    color: "#444"
                    Layout.preferredWidth: 70
                    horizontalAlignment: Text.AlignRight
                }
                TextField {
                    id: idField
                    placeholderText: "请输入身份证号"
                    validator: RegularExpressionValidator { regularExpression: /^[0-9x]{0,18}$/ }
                    Layout.preferredWidth: 200
                    height: 24
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    background: Rectangle {
                        radius: 5
                        border.color: "#888"
                        border.width: 1
                        color: "#fff"
                    }
                }
            }

            Item{
                Layout.fillHeight: true
            }

            // 按钮区
            RowLayout {
                Layout.fillWidth: true
                Layout.bottomMargin: 30
                Item { Layout.preferredWidth: 80 }
                // 确认按钮
                CustomButton{
                    buttonType: "confirm"
                    text: "确认"
                    height: 26
                    width: 100
                    fontSize: 14
                    onClicked: confirmed({
                        username: usernameField.text,
                        password: passwordField.text,
                        passwordAgain: passwordAgainField.text,
                        name: nameField.text,
                        phoneNumber: phoneNumberField.text,
                        id: idField.text,
                    })
                }
                Item { Layout.fillWidth: true }
                // 取消按钮
                CustomButton{
                    buttonType: "cancel"
                    text: "取消"
                    height: 26
                    width: 100
                    fontSize: 14
                    onClicked: canceled()
                }
                Item { Layout.preferredWidth: 80 }
            }

        }
    }
}
