import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15

Window {
    id: confirmCancelWin
    title: "确认取消"
    property string contentText: "主内容iahfahfahfafhoiashfdoaosigfasu;dg;oihf;HF;AOSIHF;Oaifh;ohi"
    signal confirmed()
    signal canceled()
    onVisibleChanged: if (!visible) canceled()
    
    // 处理窗口最小化问题
    onVisibilityChanged: function(visibility) {
        if (visibility === Window.Windowed || visibility === Window.Maximized) {
            // 当窗口从最小化恢复时,确保窗口显示在最前面并获得焦点
            confirmCancelWin.raise()
            confirmCancelWin.requestActivate()
        }
    }

    width: 320
    height: 180
    flags: Qt.Dialog
    modality: Qt.ApplicationModal
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: "#ffffff"

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

            RowLayout{

                Layout.bottomMargin: 20
                Layout.topMargin: 10
                Layout.rightMargin: 40
                Layout.leftMargin: 40
                CustomButton{
                    buttonType: "confirm"
                    width: 100
                    text: "确认"
                    focus: true

                    Keys.onReturnPressed: {
                        confirmed()
                    }

                    onClicked: {
                        confirmed()
                    }
                }

                Item{
                    Layout.fillWidth:true
                }

                CustomButton{
                    buttonType: "cancel"
                    width: 100
                    text: "取消"

                    onClicked:{
                        canceled()
                    }
                }
            }
               
        
        }
    }
}
