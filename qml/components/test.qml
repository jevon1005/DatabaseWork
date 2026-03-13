import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.impl 2.15


Rectangle {
    width: 320; height: 40
    color: "#65a8ed" 
    RowLayout{
        anchors.fill: parent
        spacing: 0
        Rectangle{
            Layout.preferredWidth: 36
            Layout.preferredHeight: 40
            color: "pink"
        }

        //间隔
        Item{
            Layout.fillWidth: true
        }

        //站名
        Rectangle{
            Layout.preferredWidth: 55
            Layout.preferredHeight: 40
            color: "red"
        }

        //间隔
        Item{
            Layout.fillWidth: true
        }

        //到时
        Rectangle{
            Layout.preferredWidth: 55
            Layout.preferredHeight: 40
            color: "yellow"

            Text {
                id:arrivetime
                text: "12:30"
                color: parent.textColor
                anchors.centerIn: parent
                // verticalAlignment: Text.AlignVCenter
                // font.pixelSize: 16
                // horizontalAlignment: Text.AlignHCenter
            }

            Text{
                text: "+" + "01"
                color: "#0080FF"
                font.pixelSize: 8
                anchors.left: arrivetime.right
                anchors.top: arrivetime.top
            }
        }



        //间隔
        Item{
            Layout.fillWidth: true
        }

        //发时
        Rectangle{
            Layout.preferredWidth: 55
            Layout.preferredHeight: 40
            color: "purple"

            Text {
                text: "09:30"
                color: parent.textColor
                verticalAlignment: Text.AlignVCenter
                // font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
            }
        }

        //间隔
        Item{
            Layout.fillWidth: true
        }

        //停留
        Rectangle{
            Layout.preferredWidth: 48
            Layout.preferredHeight: 40
            color: "orange"
            Text {
                text: "30分"
                color: parent.textColor
                verticalAlignment: Text.AlignVCenter
                // font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
            }
        }

        //间隔
        Item{
            Layout.fillWidth: true
        }

        // 删除按钮
        Rectangle {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 40
            color: "black"
            Layout.rightMargin: 5
        }
    }
}
