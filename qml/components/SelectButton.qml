import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects

Item {
    id: root
    height: 40
    width: 120

    // 按钮选择
    property int index: 0 // 按钮索引
    property bool selected // 是否选中

    // 可外部覆盖的属性
    property alias text: label.text
    property int fontSize: 18
    property int borderRadius: 8
    property double borderWidth: 0
    property color borderColor: "transparent"
    // property int borderWidth: buttonType === "cancel" ? 1.5 : 0
    // property color borderColor: buttonType === "cancel" ? "#c5c5c5" : "transparent"
    property bool fontBold: false

    // 按钮颜色
    property color normalColor: "#70B9FF"
    property color hoverColor: "#2379FF"
    property color pressedColor: "#1359FF"
    property color selectedColor: "#2379FF"

    // 文字颜色
    property color textColor: "#fff"
    property color pressedTextColor: "#fff"

    signal clicked

    DropShadow {
        anchors.fill: selectButton
        source: selectButton
        color: "#1c5a85"
        radius: 10
        samples: 16
        horizontalOffset: 2
        verticalOffset: 2
    }

    Rectangle {
        id: selectButton
        anchors.fill: parent
        border.width: root.borderWidth
        border.color: root.borderColor
        radius: root.borderRadius
        color: root.selected ? root.selectedColor
                : mouseArea.pressed ? root.pressedColor
                : mouseArea.containsMouse ? root.hoverColor
                : root.normalColor

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if(!selected) {
                    root.clicked()
                }
            }
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
