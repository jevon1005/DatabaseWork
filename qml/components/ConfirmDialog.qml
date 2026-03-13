import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15

Window {
    id: confirmWin
    title: "确认"
    property string contentText: "主内容iahfahfahfafhoiashfdoaosigfasu;dg;oihf;HF;AOSIHF;Oaifh;ohi"
    signal closed()
    onVisibleChanged: {
        if (!visible) closed()
        else {
            confirmWin.requestActivate()
            focusTimer.restart()
        }
    }
    
    // 处理窗口最小化问题
    onVisibilityChanged: function(visibility) {
        if (visibility === Window.Windowed || visibility === Window.Maximized) {
            // 当窗口从最小化恢复时,确保窗口显示在最前面并获得焦点
            confirmWin.raise()
            confirmWin.requestActivate()
        }
    }

    width: 320
    height: 180
    flags: Qt.Dialog
    modality: Qt.ApplicationModal
    color: "transparent"

    onActiveChanged: {
        if (active) {
            focusTimer.restart()
        }
    }

    // 延迟获取焦点
    Timer {
        id: focusTimer
        interval: 100
        repeat: false
        onTriggered: {
            mainRect.forceActiveFocus()
        }
    }

    // 使用 Shortcut 捕获回车键
    Shortcut {
        sequence: "Return"
        enabled: confirmWin.visible
        onActivated: {
            confirmWin.closed()
        }
    }
    
    Shortcut {
        sequence: "Enter"
        enabled: confirmWin.visible
        onActivated: {
            confirmWin.closed()
        }
    }

    Rectangle {
        id: mainRect
        anchors.fill: parent
        focus: true
        activeFocusOnTab: true
        color: "#ffffff"
        
        Keys.onReturnPressed: {
            event.accepted = true
            confirmWin.closed()
        }
        Keys.onEnterPressed: {
            event.accepted = true
            confirmWin.closed()
        }
        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                event.accepted = true
                confirmWin.closed()
            }
        }

        ColumnLayout {
            anchors.fill: parent

            Text {
                id:content

                Layout.topMargin: 30
                Layout.rightMargin: 60
                Layout.leftMargin: 60
                text: contentText
                wrapMode: Text.Wrap                      // 开启自动换行
                // elide: Text.ElideMiddle
                Layout.preferredWidth: 200
                Layout.preferredHeight: 60
                font.pixelSize: 18
                font.family: "Microsoft YaHei"
                color: "#1a252f"
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            CustomButton {
                Layout.topMargin: 10
                Layout.bottomMargin: 20
                Layout.alignment: Qt.AlignCenter
                buttonType: "confirm"
                width: 120
                text: "确认"
                onClicked: {
                    console.log("Button clicked")
                    closed()
                }
            }
        }
    }
}
