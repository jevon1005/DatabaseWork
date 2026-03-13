import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    property alias text: searchField.text
    property string placeholderText: "查找"
    property int fontSize: 18         // 可外部设置文字大小
    property int inputHeight: 40      // 可外部设置输入框高度
    property int radius: 6            // 新增：可外部设置圆角
    width: 400
    height: inputHeight

    Rectangle {
        id: background
        anchors.fill: parent
        radius: root.radius           // 使用外部属性
        border.color: "#AAAAAA"
        border.width: 1
        color: "white"
        height: root.inputHeight

        RowLayout {
            anchors.fill: parent

            Image {
                id: searchIcon
                source: "qrc:/resources/icon/Find.png"
                Layout.preferredHeight: root.inputHeight
                Layout.preferredWidth: root.inputHeight
                fillMode: Image.PreserveAspectFit
                smooth: true
                Layout.alignment: Qt.AlignVCenter
            }

            TextField {
                id: searchField
                Layout.fillWidth: true
                Layout.leftMargin: -20
                font.pixelSize: root.fontSize
                height: root.inputHeight
                placeholderText: root.placeholderText
                background: null
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
