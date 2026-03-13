import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

Window {
    width: 400; height: 600
    minimumWidth: 400; minimumHeight: 260;
    maximumWidth: 1920; maximumHeight: 1440
    visible: true
    color: "#ffffff"

    Rectangle {
        id: dialog
        anchors.fill: parent
        radius: 16
        color: "#ffffff"
        border.color: "#222"
        border.width: 1

        ColumnLayout{
            anchors.fill: parent
            spacing:0

            // 标题栏
            Rectangle {
                Layout.fillWidth: true
                height: 40
                radius: 16
                Layout.leftMargin: 1
                Layout.rightMargin: 1
                Layout.topMargin: 1
                Text {
                    text: "车站管理"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 28
                    font.bold: true
                }
            }

            //间隔符
            Rectangle{
                Layout.fillWidth: true
                height: 2
                color: "#222"
            }

            //时刻表
            StationListView{
                Layout.fillWidth: true
                height: 450
                borderWidth:0
                Layout.leftMargin: 2
                Layout.rightMargin: 2
                Layout.topMargin: 4
            }


            // 新增按钮
            Rectangle {
                width: 38
                height: 38
                Layout.alignment: Qt.AlignRight
                Layout.rightMargin: 30
                Layout.topMargin: 4

                Image {
                    source: "qrc:/resources/icon/Add.png"
                    anchors.centerIn: parent
                    width: 50
                    height: 50
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        stationList.push({ name: "", arrive: "", depart: "", stop: "", checked: true })
                    }
                }
            }


            // 按钮区
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 10
                Item {
                    Layout.fillWidth: true
                }

                // 确认按钮
                CustomButton{
                    buttonType: "confirm"
                    text: "确认"
                    borderRadius: 4
                    height: 26
                    width:130
                    fontSize:14
                }

                Item {
                    Layout.preferredWidth: 40
                }

                // 取消按钮
                CustomButton{
                    buttonType: "cancel"
                    text: "取消"
                    borderRadius: 4
                    height: 26
                    width:130
                    fontSize:14
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            Item{
                Layout.fillHeight: true
            }

        }

    }

}
