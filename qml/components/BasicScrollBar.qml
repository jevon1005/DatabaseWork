import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Templates 2.15 as T

T.ScrollBar {
    id: control

    property color handleNormalColor: "#a0a0a0"
    property color handleHoverColor: "#666"
    property color handlePressColor: "#666"
    property int handleLength: 40

    contentItem: Rectangle {
        width: parent.width
        height: handleLength
        x: 0
        y: control.position * control.availableHeight
        radius: 6
        color: control.pressed
               ? control.handlePressColor
               : control.hovered
                 ? control.handleHoverColor
                 : control.handleNormalColor
    }

    background: Rectangle {
        anchors.fill: parent
        color: "transparent"
        radius: 6
    }
}
