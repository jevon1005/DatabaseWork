import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Item {
    id: root
    property int buttonWidth: 28
    property int buttonHeight: 28
    property int buttonRadius: buttonWidth / 2

    width: buttonWidth + 6
    height: buttonHeight + 6

    property bool checked: false
    signal toggled(bool checked)

    DropShadow {
        anchors.fill: circle
        source: circle
        horizontalOffset: 2
        verticalOffset: 2
        radius: 8
        color: "#B0B0B0"
        samples: 16
    }

    Rectangle {
        id: circle
        anchors.centerIn: parent
        width: root.buttonWidth
        height: root.buttonHeight
        radius: root.buttonRadius
        color: "#F3F5F7"
        border.color: "#DDD"
        border.width: 1

        Rectangle {
            anchors.centerIn: parent
            width: root.buttonWidth * 0.57
            height: root.buttonHeight * 0.57
            radius: root.buttonRadius * 0.57
            color: root.checked ? "#67B7FF" : "transparent"
            visible: root.checked
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.checked = !root.checked
                root.toggled(root.checked)
            }
        }
    }
}
