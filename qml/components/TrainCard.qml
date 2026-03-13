import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    // width: parent ? parent.width : 600
    // height: parent ? parent.height : 90
    width: 620
    height: 70

    property var trainData: ({
        trainNumber: "G115232",
        startStationName: "乌鲁木齐北",
        startHour: 13,
        startMinute: 30,
        endStationName: "呼和浩特北",
        endHour: 19,
        endMinute: 24,
        intervalHour: 13,
        intervalMinute: 24,
        })

    Rectangle {
        anchors.fill: parent
        radius: 16
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#ffffff" }
            GradientStop { position: 1.0; color: "#cce5ff" }
        }
        border.color: "#b3d1f7"
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            spacing: 0

            Text {
                Layout.preferredWidth: 120
                text: trainData.startStationName
                font.pixelSize: 24
                font.bold: false
                color: "#222"
                horizontalAlignment: Text.AlignLeft
                elide: Text.ElideRight
                wrapMode: Text.NoWrap
                clip: true
            }

            Item { Layout.fillWidth: true }

            Text {
                Layout.preferredWidth: 80
                text: ("0" + trainData.startHour).slice(-2) + ":" + ("0" + trainData.startMinute).slice(-2);
                font.pixelSize: 26
                font.bold: true
                color: "#222"
                horizontalAlignment: Text.AlignLeft
                elide: Text.ElideRight
                wrapMode: Text.NoWrap
                clip: true
            }

            Item { Layout.fillWidth: true }

            ColumnLayout {

                Item{
                    Layout.fillHeight: true
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 90
                    text: trainData.trainNumber
                    font.bold: true
                    font.pixelSize: 20; color: "#222";
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideMiddle
                    wrapMode: Text.NoWrap
                    clip: true
                }
                Item{
                    Layout.preferredHeight: 0
                }

                Image {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 5
                    Layout.topMargin: -20
                    source: "qrc:/resources/icon/arrow.svg"
                    fillMode: Image.Stretch
                }
                Item{
                    Layout.preferredHeight: 0
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: -18
                    text: trainData.intervalHour + "小时" + trainData.intervalMinute + "分"
                    font.pixelSize: 10; color: "#888";
                }
                Item{
                    Layout.fillHeight: true
                }
            }

            Item { Layout.fillWidth: true }

            Text {
                Layout.preferredWidth: 80
                text: ("0" + trainData.endHour).slice(-2) + ":" + ("0" + trainData.endMinute).slice(-2);
                font.pixelSize: 26
                font.bold: true
                color: "#222"
                horizontalAlignment: Text.AlignRight
                elide: Text.ElideLeft
                wrapMode: Text.NoWrap
                clip: true
            }

            Item { Layout.fillWidth: true }

            Text {
                Layout.preferredWidth: 120
                text: trainData.endStationName
                font.pixelSize: 24
                font.bold: false
                color: "#222"
                horizontalAlignment: Text.AlignRight
                elide: Text.ElideLeft
                wrapMode: Text.NoWrap
                clip: true
            }
        }
    }
}
