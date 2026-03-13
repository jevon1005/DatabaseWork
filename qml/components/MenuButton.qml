import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Item {
    id: root
    height: 80
    width: 200

    // 按钮选择
    property int index: 0 // 按钮索引
    property bool selected // 是否选中

    // 可外部覆盖的属性
    property alias text: label.text
    property int fontSize: 18
    property int borderRadius: 8
    property double borderWidth: 0
    property color borderColor: "transparent"
    property bool fontBold: false
    property alias iconSource: icon.source

    // 按钮颜色
    property color normalColor: "#70B9FF"
    property color hoverColor: "#2379FF"
    property color pressedColor: "#1359FF"
    property color selectedColor: "#2379FF"

    // 文字颜色
    property color textColor: "#fff"
    property color pressedTextColor: "#fff"

    signal clicked

    // 阴影层
    DropShadow {
        anchors.fill: menubutton
        source: menubutton
        color: "#8B8989"
        radius: 12
        samples: 17
        horizontalOffset: 2
        verticalOffset: 2
    }

    Rectangle {
        id: menubutton
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

        RowLayout {
            anchors.fill: parent

            Item {
                Layout.preferredWidth: 50
                Layout.preferredHeight: 50
                // id: icon
                Image {
                    id: icon
                    width: parent.width
                    height: parent.height
                    fillMode: Image.PreserveAspectFit
                    source: root.iconSource
                }
            }

            Text {
                id: label
                Layout.fillWidth: true
                Layout.leftMargin: -10
                Layout.rightMargin: 10
                horizontalAlignment: Text.AlignHCenter
                text: "按钮"
                color: mouseArea.pressed ? root.pressedTextColor : root.textColor
                font.pixelSize: root.fontSize
            }
        }

        // Item {
        //     anchors.centerIn: parent
        //     width: parent.width
        //     height: parent.height

        //     Image {
        //         id: icon
        //         fillMode: Image.PreserveAspectFit
        //         source: root.iconSource
        //         anchors.verticalCenter: parent.verticalCenter
        //         x: 0
        //     }
        //     Text {
        //         id: label
        //         text: "按钮"
        //         color: root.selected ? root.selectedTextColor : root.normalTextColor
        //         font.pixelSize: 16
        //         anchors.verticalCenter: parent.verticalCenter
        //         anchors.horizontalCenter: parent.horizontalCenter
        //     }
        // }
    }
}
