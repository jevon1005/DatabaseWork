import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

Window {
    id: mainWindow
    width: 640; height: 400
    minimumWidth: 480; minimumHeight: 360
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

    signal confirmed(string name, string phoneNumber, string id_new, string type)
    signal canceled()

    property string initialName: ""
    property string initialPhoneNumber: ""
    property string initialId: ""
    property string initialType: ""

    Rectangle {
        width: parent.width
        height: parent.height
        radius: 16
        border.color: "#808080"
        // color: "pink"

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

        // 头部组件
        Header {
            id: header
            anchors.top: parent.top
            anchors.topMargin: 1
            width: parent.width - 5
            title: "修改乘车人信息"
            onCloseClicked: {
                canceled()
            }
        }

        // 表单内容
        ColumnLayout {
            id: column
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 90
            spacing: 22

            // 姓名
            RowLayout {
                spacing: 16
                Text {
                    Layout.preferredWidth: 80
                    text: "姓名："
                    font.pixelSize: 18
                    color: "#666"
                    horizontalAlignment: Text.AlignRight
                }
                TextField {
                    id: nameField
                    Layout.preferredWidth: 320
                    Layout.preferredHeight: 36
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    placeholderText: "请输入姓名"
                    validator: RegularExpressionValidator { regularExpression: /^\p{Script=Han}+$/u }
                    padding: 5
                    background: Rectangle {
                        color: "transparent"
                        border.color: "#999"
                        border.width: 1
                        radius: 6
                    }
                    text: initialName
                }
            }

            // 联系方式
            RowLayout {
                spacing: 16
                Text {
                    Layout.preferredWidth: 80
                    text: "联系方式："
                    font.pixelSize: 18
                    color: "#666"
                    horizontalAlignment: Text.AlignRight
                }
                TextField {
                    id: phoneNumberField
                    Layout.preferredWidth: 320
                    Layout.preferredHeight: 36
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    placeholderText: "请输入联系方式"
                    validator: RegularExpressionValidator { regularExpression:  /^[0-9]{0,11}$/ }
                    padding: 5
                    background: Rectangle {
                        color: "transparent"
                        border.color: "#999"
                        border.width: 1
                        radius: 6
                    }
                    text: initialPhoneNumber
                }
            }

            // 身份证号
            RowLayout {
                spacing: 16
                Text {
                    Layout.preferredWidth: 80
                    text: "身份证号："
                    font.pixelSize: 18
                    color: "#666"
                    horizontalAlignment: Text.AlignRight
                }
                TextField {
                    id: idField
                    Layout.preferredWidth: 320
                    Layout.preferredHeight: 36
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    placeholderText: "请输入身份证号"
                    validator: RegularExpressionValidator { regularExpression: /^[0-9x]{0,18}$/ }
                    padding: 5
                    background: Rectangle {
                        color: "transparent"
                        border.color: "#999"
                        border.width: 1
                        radius: 6
                    }
                    text: initialId
                }
            }

            RowLayout {
                Label {
                    text: "优惠类型："
                    font.pixelSize: 18
                    color: "#666"
                    Layout.preferredWidth: 80
                    horizontalAlignment: Text.AlignRight
                }
                ComboBox {
                    id: typeBox
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 30
                    Layout.leftMargin: 12

                    model: ["儿童", "成人", "学生"]
                    currentIndex: model.indexOf(initialType)
                    contentItem: Text {
                        text: parent.displayText
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                        color: "#444"
                        anchors.fill: parent
                        anchors.leftMargin: 6
                    }
                }
            }

            // 底部按钮区
            RowLayout {
                id: row
                spacing: 150
                Layout.topMargin: 10

                CustomButton {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 30
                    text: "确认"
                    activeFocusOnTab: true
                    onClicked: {
                        confirmed(nameField.text, phoneNumberField.text, idField.text, typeBox.model[typeBox.currentIndex])
                    }
                }

                CustomButton {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 30
                    text: "取消"
                    activeFocusOnTab: true
                    customColor: "#e6e6e6"
                    pressedColor: "#b3b3b3"
                    textColor: "#666"
                    pressedTextColor: "#000"
                    onClicked: {
                        canceled()
                    }
                }
            }
        }
    }
}
