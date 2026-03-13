import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects

Item {
    id: root
    height: 40
    width: 120

    property bool mouseAreaEnabled: true

    // 新增：开放鼠标形状属性，默认手型
    property int cursorType: Qt.PointingHandCursor

    // 按钮类型：confirm（确认/登录），cancel（取消/注册）
    property string buttonType: "confirm" // "confirm" 或 "cancel"

    // 可外部覆盖的属性
    property alias text: label.text
    property int fontSize: 18
    property int borderRadius: 8
    property double borderWidth: buttonType === "cancel" ? 1.5 : 0
    property color borderColor: buttonType === "cancel" ? "#c5c5c5" : "transparent"
    property bool fontBold: false

    // 按钮颜色
    property color customColor: buttonType === "confirm" ? "#409CFC" : "#ffffff"
    property color pressedColor: buttonType === "confirm" ? "#174a73" : "#e8e8e8"
    property color hoverColor: buttonType === "confirm" ? "#1f5f99" : "#f8f8f8"

    // 文字颜色
    property color textColor: buttonType === "confirm" ? "#fff" : "#4a4a4a"
    property color pressedTextColor: buttonType === "confirm" ? "#fff" : "#4a4a4a"

    signal clicked

    DropShadow {
        anchors.fill: menubutton
        source: menubutton
        color: buttonType === "confirm" ? "#1c5a85" : "#e8e8e8"
        radius: 10
        samples: 16
        horizontalOffset: 2
        verticalOffset: 2
    }

    Rectangle {
        id: menubutton
        anchors.fill: parent
        border.width: root.borderWidth
        border.color: root.borderColor
        radius: root.borderRadius
        color: mouseArea.pressed ? root.pressedColor
              : mouseArea.containsMouse ? root.hoverColor
              : root.customColor

        MouseArea {
            id: mouseArea
            enabled: mouseAreaEnabled
            anchors.fill: parent
            hoverEnabled: true
            // 绑定到外部可控的 cursorType
            cursorShape: root.cursorType
            onClicked: root.clicked()
        }

        Text {
            id: label
            text: "按钮"
            color: mouseArea.pressed ? root.pressedTextColor : root.textColor
            font.pixelSize: root.fontSize
            font.bold: root.fontBold
            anchors.centerIn: parent
        }
    }
}
