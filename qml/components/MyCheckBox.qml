import QtQuick 2.15
import QtQuick.Templates 2.15 as T
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15
import Qt5Compat.GraphicalEffects

T.CheckBox {
    id: control

    property color themeColor: "#5786ff"
    property color textColor: "white"
    property color indicatorBackgroundColor: "white"
    property color indicatorBorderColor: control.checked ? themeColor : "#ccc"
    property color indicatorButtonColor: themeColor
    property int indicatorBorderWidth: 1
    property int indicatorRadius: 4

    implicitWidth: 120
    implicitHeight: 32
    leftPadding: 28
    rightPadding: 8
    spacing: 6

    indicator: Rectangle {
        x: 4
        y: (control.height - height) / 2
        width: 14
        height: 18
        radius: control.indicatorRadius
        color: control.indicatorBackgroundColor
        border.color: control.indicatorBorderColor
        border.width: control.indicatorBorderWidth

        Text {
            text: control.checked ? "✔" : ""
            anchors.centerIn: parent
            font.pixelSize: 10
            color: control.indicatorButtonColor
        }
    }

    contentItem: Text {
        text: control.text
        font.pixelSize: 14
        color: control.textColor
        horizontalAlignment: Text.AlignLeft      // 水平左对齐
        verticalAlignment: Text.AlignVCenter     // 垂直居中
        anchors.verticalCenter: parent.verticalCenter // 让文字和指示器竖直居中
        leftPadding: 0
    }

    background: Rectangle {
        color: "#a1c8fb"
        radius: 4
        border.color: "#b3b3b3"
        border.width: 1
    }
}
