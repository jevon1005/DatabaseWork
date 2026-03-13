import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    width: 690
    // Layout.fillWidth: True
    height: 105

    property var ticketData: ({
        trainNumber: "G15621",
        startStationName: "呼和浩特北",
        startYear: 2024,
        startMonth: 7,
        startDay: 15,
        startHour: 8,
        startMinute: 30,
        startStationStopInfo: "过",
        endStationName: "齐齐哈尔南",
        endYear: 2024,
        endMonth: 7,
        endDay: 15,
        endHour: 13,
        endMinute: 30,
        endStationStopInfo: "过",
        intervalHour: 5,
        intervalMinute: 0,
        firstClassPrice: 755.22,
        secondClassPrice: 1551.35,
        businessClassPrice: 2985.75,
        firstClassCount: 120,
        secondClassCount: 120,
        businessClassCount: 0,
    })

    signal showTimetable(string trainNumber, string startStation, string endStation)
    signal bookTicket(int seatType) // seatType: 0=二等座, 1=一等座, 2=商务座

    Rectangle {
        anchors.fill: parent
        // width: parent.width - 40
        // height: 140
        radius: 15
        // 使用渐变背景
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#ffffff" }
            GradientStop { position: 1.0; color: "#cce5ff" }
        }
        border.color: "#999"
        border.width: 2
        // anchors.horizontalCenter: parent.horizontalCenter
        // anchors.top: parent.top
        // anchors.topMargin: 15

        // 左侧时间、车次、票价 + 座次 + 座次票价
        RowLayout {
            anchors.fill: parent
            anchors.topMargin: 5
            anchors.bottomMargin: 5
            anchors.leftMargin: 15
            anchors.rightMargin: 15
            height: parent.height - 20

            // 发车时间、车次号、时刻表、到达时间 + 票价
            ColumnLayout {

                // 发车时间 + 车次号 + 时刻表 + 到达时间
                RowLayout {
                    Layout.fillHeight: true
                    spacing: 10
                    // 出发时间
                    ColumnLayout {
                        // anchors.top: parent.top
                        Layout.alignment: Qt.AlignTop

                        // 间隔
                        Item {
                            Layout.preferredHeight: 4
                        }

                        Text {
                            Layout.alignment: Qt.AlignLeft
                            horizontalAlignment: Text.AlignLeft
                            Layout.preferredWidth: 70
                            text: ("0" + ticketData.startHour).slice(-2) + ":" + ("0" + ticketData.startMinute).slice(-2);
                            font.bold: true;
                            font.pixelSize: 21;
                            color: "#222"
                            elide: Text.ElideRight
                            wrapMode: Text.NoWrap
                            clip: true
                        }
                        Text {
                            Layout.alignment: Qt.AlignLeft
                            horizontalAlignment: Text.AlignLeft
                            Layout.preferredWidth: 90
                            text: ticketData.startStationName +
                                  "（" + ticketData.startStationStopInfo + "）"
                            font.pixelSize: 11;
                            color: "#222";
                            elide: Text.ElideRight
                            wrapMode: Text.NoWrap
                            clip: true
                        }
                    }
                    // 车次、箭头、时刻表
                    ColumnLayout {
                        Text {
                            Layout.preferredWidth: 90
                            Layout.alignment: Qt.AlignHCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: ticketData.trainNumber
                            font.bold: true;
                            font.pixelSize: 23; color: "#222";
                            elide: Text.ElideRight
                            wrapMode: Text.NoWrap
                            clip: true
                        }
                        Image {
                            Layout.topMargin: -4
                            source: "qrc:/resources/icon/arrow.svg"
                            Layout.preferredWidth: 140
                            height: 15
                            fillMode: Image.Stretch
                        }
                        Text {
                            Layout.preferredWidth: 50
                            Layout.alignment: Qt.AlignHCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: ticketData.intervalHour + "时" + ticketData.intervalMinute + "分"
                            font.pixelSize: 10;
                            color: "#888";
                            elide: Text.ElideRight
                            wrapMode: Text.NoWrap
                            clip: true
                        }
                        CustomButton {
                            text: "时刻表"
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 45
                            Layout.preferredHeight: 21
                            fontSize: 11
                            customColor: "#e0e8f8"
                            pressedColor: "#b3d1ff"
                            textColor: "#888"
                            pressedTextColor: "#222"
                            onClicked: showTimetable(ticketData.trainNumber, ticketData.startStationName, ticketData.endStationName)
                        }
                    }
                    // 到达时间
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop

                        // 间隔
                        Item {
                            Layout.preferredHeight: 4
                        }

                        Text {
                            Layout.alignment: Qt.AlignRight
                            horizontalAlignment: Text.AlignRight
                            Layout.preferredWidth: 70
                            text: ("0" + ticketData.endHour).slice(-2) + ":" + ("0" + ticketData.endMinute).slice(-2);
                            font.bold: true;
                            font.pixelSize: 21;
                            color: "#222"
                            elide: Text.ElideLeft
                            wrapMode: Text.NoWrap
                            clip: true
                        }
                        Text {
                            Layout.alignment: Qt.AlignRight
                            horizontalAlignment: Text.AlignRight
                            Layout.preferredWidth: 90
                            text: "（" + ticketData.endStationStopInfo + "）" +
                                  ticketData.endStationName
                            font.pixelSize: 11;
                            color: "#222";
                            elide: Text.ElideLeft
                            wrapMode: Text.NoWrap
                            clip: true
                        }
                    }

                }
                // 票价

                RowLayout{
                    Item{
                        Layout.fillWidth: true
                    }

                    Text {
                        Layout.preferredWidth: 150
                        horizontalAlignment: Text.AlignRight
                        text: "￥" + ticketData.secondClassPrice + "起"
                        font.pixelSize: 21
                        color: "#e88a3d"
                        font.bold: true
                        Layout.topMargin: -20
                        elide: Text.ElideLeft
                        wrapMode: Text.NoWrap
                        clip: true
                    }
                }

            }

            // 间隔
            Item {
                Layout.fillWidth: true
            }

            // 中间分隔线
            Rectangle {
                width: 2
                Layout.topMargin: 6
                Layout.preferredHeight: 83
                // Layout.fillHeight: true
                color: "#ccc"
                radius: 1
            }

            // 间隔
            Item {
                Layout.fillWidth: true
            }

            // 二等 + 一等 + 商务
            RowLayout {
                Layout.topMargin: 4
                Layout.fillHeight: true

                // 座位等级
                ColumnLayout {
                    spacing: 11
                    Text {
                        text: "二等";
                        font.pixelSize: 14; color: "#222";
                    }
                    Text {
                        text: "一等";
                        font.pixelSize: 14; color: "#222";
                    }
                    Text {
                        text: "商务";
                        font.pixelSize: 14; color: "#222";
                    }
                }

                // 间隔
                Item {
                    Layout.preferredWidth: 25
                }

                // 票价
                ColumnLayout {
                    spacing: 11
                    Text {
                        Layout.preferredWidth: 70
                        text: "￥" + ticketData.secondClassPrice;
                        font.pixelSize: 14; color: "#e88a3d";
                        elide: Text.ElideRight
                        wrapMode: Text.NoWrap
                        clip: true
                    }
                    Text {
                        Layout.preferredWidth: 70
                        text: "￥" + ticketData.firstClassPrice;
                        font.pixelSize: 14; color: "#e88a3d";
                        elide: Text.ElideRight
                        wrapMode: Text.NoWrap
                        clip: true
                    }
                    Text {
                        Layout.preferredWidth: 80
                        text: "￥" + ticketData.businessClassPrice;
                        font.pixelSize: 14; color: "#e88a3d";
                        elide: Text.ElideRight
                        wrapMode: Text.NoWrap
                        clip: true
                    }
                }

                // 间隔
                Item {
                    Layout.preferredWidth: 20
                }

                // 余票
                ColumnLayout {
                    spacing: 11
                    Text {
                        text: ticketData.secondClassCount > 0
                              ? "有票"
                              : "无票"
                        font.pixelSize: 14;
                        color: ticketData.secondClassCount > 0
                               ? "#4ec67e"
                               : "#bbb"
                    }
                    Text {
                        text: ticketData.firstClassCount > 0
                              ? "有票"
                              : "无票"
                        font.pixelSize: 14;
                        color: ticketData.firstClassCount > 0
                               ? "#4ec67e"
                               : "#bbb"
                    }
                    Text {
                        text: ticketData.businessClassCount > 0
                              ? "有票"
                              : "无票"
                        font.pixelSize: 14;
                        color: ticketData.businessClassCount > 0
                               ? "#4ec67e"
                               : "#bbb"
                    }
                }

                // 间隔
                Item {
                    Layout.preferredWidth: 25
                }

                ColumnLayout {
                    spacing: 8
                    CustomButton {
                        text: "预定"
                        customColor: ticketData.secondClassCount > 0
                                     ? "#5d7fa9"
                                     : "#808080"
                        pressedColor: ticketData.secondClassCount > 0
                                      ? "#3B99FB"
                                      : "#808080"
                        mouseAreaEnabled: ticketData.secondClassCount > 0
                        textColor: "#fff"
                        fontSize: 12
                        fontBold: false
                        width: 42
                        height: 21
                        enabled: true
                        cursorType: ticketData.secondClassCount > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                        Layout.row: 0; Layout.column: 3
                        onClicked: {
                            if (ticketData.secondClassCount > 0) {
                                bookTicket(0) // 0 = 二等座
                            }
                        }
                    }
                    CustomButton {
                        text: "预定"
                        customColor: ticketData.firstClassCount > 0
                                     ? "#5d7fa9"
                                     : "#808080"
                        pressedColor: ticketData.firstClassCount > 0
                                      ? "#3B99FB"
                                      : "#808080"
                        mouseAreaEnabled: ticketData.firstClassCount > 0
                        textColor: "#fff"
                        fontSize: 12
                        fontBold: false
                        width: 42
                        height: 21
                        enabled: true
                        cursorType: ticketData.firstClassCount > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                        Layout.row: 0; Layout.column: 3
                        onClicked: {
                            if (ticketData.firstClassCount > 0) {
                                bookTicket(1) // 1 = 一等座
                            }
                        }
                    }
                    CustomButton {
                        text: "预定"
                        customColor: ticketData.businessClassCount > 0
                                     ? "#5d7fa9"
                                     : "#808080"
                        pressedColor: ticketData.businessClassCount > 0
                                      ? "#3B99FB"
                                      : "#808080"
                        mouseAreaEnabled: ticketData.businessClassCount > 0
                        textColor: "#fff"
                        fontSize: 12
                        fontBold: false
                        width: 42
                        height: 21
                        enabled: true
                        cursorType: ticketData.businessClassCount > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                        Layout.row: 0; Layout.column: 3
                        onClicked: {
                            if (ticketData.businessClassCount > 0) {
                                bookTicket(2) // 2 = 商务座
                            }
                        }
                    }
                }
            }
        }
    }
}
