import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects

Rectangle {
    id: infoHeader
    property string title: "标题" // 外部传入
    property int titleFontSize: 28 // 标题字体大小，默认28
    signal closeClicked         // 关闭按钮点击信号

    width: parent ? parent.width : 570
    height: 60
    radius: 14
    // 渐变背景（蓝色调优化，从深蓝到浅蓝）
    gradient: Gradient {
        orientation: Gradient.Horizontal   // 横向渐变
        GradientStop { position: 0.0; color: "#1976D2" }  // 深蓝
        GradientStop { position: 0.5; color: "#42A5F5" }  // 中蓝
        GradientStop { position: 0.85; color: "#ffffff" } 
    }

    // 左侧标题，外部可传入
    Text {
        id: titleText
        text: infoHeader.title
        color: "#FFFFFF"
        font.bold: true
        font.pixelSize: infoHeader.titleFontSize  // 使用开放的字体大小属性
        leftPadding: 10
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 20
    }

    Image {
        id: closeBtn
        source: "qrc:/resources/icon/Cancel.png"
        width: 60
        height: 60
        fillMode: Image.PreserveAspectFit
        anchors.right: parent.right
        anchors.rightMargin: 2
        anchors.verticalCenter: parent.verticalCenter

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: infoHeader.closeClicked()
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
        }

        HueSaturation {
            anchors.fill: parent
            source: closeBtn
            saturation: 2
            lightness: 0.01
            visible: mouseArea.containsMouse  // 只在鼠标悬浮时显示效果
        }
    }

}
