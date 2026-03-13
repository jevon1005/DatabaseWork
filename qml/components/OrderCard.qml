import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

Item {
    height: 128
    width: 675

    // 定义数据
    property var orderData: ({
        orderNumber: "0000000003",
        trainNumber: "G1234",
        year: 2025,
        month: 11,
        day: 25,
        seatLevel: "二等座",
        carriageNumber: 5,
        seatRow: 12,
        seatCol: 3,
        price: 533.50,
        status: "待乘坐",
        passengerName: "张三",
        type: "成人",
        startStationName: "呼和浩特北",
        startStationStopInfo: "始",
        startHour: 8,
        startMinute: 5,
        endStationName: "呼和浩特北",
        endStationStopInfo: "过",
        endHour: 13,
        endMinute: 30,
        intervalHour: 5,
        intervalMinute: 25,
    })

    signal showTimetable()

    RowLayout {
        anchors.fill: parent

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 15
            // 使用渐变背景
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#ffffff" }
                GradientStop { position: 1.0; color: "#cce5ff" }
            }
            border.color: "#999"
            border.width: 2

            //列排序
            ColumnLayout{
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                spacing: 6

                //头部
                RowLayout{
                    Layout.topMargin: 6
                    Layout.leftMargin: 11
                    Layout.rightMargin: 11

                    Text{
                        Layout.preferredWidth: 150
                        text:"订单号：" + orderData.orderNumber
                        color: "#606060"
                        elide: Text.ElideRight
                        wrapMode: Text.NoWrap
                        clip: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text{
                        text: "车票当日当次有效"
                        color: "#606060"
                    }
                }

                //分隔线
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 2
                    Layout.rightMargin: 2
                    Layout.topMargin: -4
                    width: 2
                    height: 2
                    color: "#ccc"
                    radius: 1
                }

                //下部主内容
                RowLayout{
                    Layout.topMargin: -8
                    Layout.leftMargin: 15
                    Layout.fillWidth: true

                    //左侧
                    ColumnLayout{
                        Layout.alignment: Qt.AlignTop
                        spacing:3
                        //车票信息，时间
                        // Item {
                        //     Layout.preferredHeight: 0
                        // }

                        RowLayout {
                            Layout.alignment: Qt.AlignLeft
                            // Layout.leftMargin: 36
                            Layout.topMargin: -2

                            // 出发时间
                            ColumnLayout {
                                Text {
                                    Layout.alignment: Qt.AlignLeft
                                    horizontalAlignment: Text.AlignLeft
                                    Layout.preferredWidth: 70
                                    text: ("0" + orderData.startHour).slice(-2) + ":" + ("0" + orderData.startMinute).slice(-2)
                                    font.bold: true;
                                    font.pixelSize: 21; color: "#222"
                                    elide: Text.ElideRight
                                    wrapMode: Text.NoWrap
                                    clip: true
                                }
                                Text {
                                    Layout.alignment: Qt.AlignLeft
                                    horizontalAlignment: Text.AlignLeft
                                    Layout.preferredWidth: 75
                                    text: orderData.startStationName + "（" + orderData.startStationStopInfo + "）";
                                    font.pixelSize: 11; color: "#222";
                                    elide: Text.ElideRight
                                    wrapMode: Text.NoWrap
                                    clip: true
                                }
                            }
                            // 车次、箭头
                            ColumnLayout {
                                Text {
                                    Layout.preferredWidth: 130
                                    Layout.alignment: Qt.AlignHCenter
                                    horizontalAlignment: Text.AlignHCenter
                                    text: orderData.trainNumber;
                                    font.bold: true;
                                    font.pixelSize: 18; color: "#222";
                                    elide: Text.ElideMiddle
                                    wrapMode: Text.NoWrap
                                    clip: true
                                }
                                Image {
                                    Layout.preferredWidth: 150
                                    Layout.preferredHeight: 6
                                    Layout.topMargin: -8
                                    source: "qrc:/resources/icon/arrow.svg"
                                    fillMode: Image.Stretch
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.topMargin: -2
                                    text: orderData.intervalHour + "时" + orderData.intervalMinute + "分"
                                    font.pixelSize: 11; color: "#888";
                                    elide: Text.ElideRight
                                    wrapMode: Text.NoWrap
                                    clip: true
                                }
                            }
                            // 到达时间
                            ColumnLayout {
                                Text {
                                    Layout.alignment: Qt.AlignRight
                                    horizontalAlignment: Text.AlignRight
                                    Layout.preferredWidth: 70
                                    text: ("0" + orderData.endHour).slice(-2) + ":" + ("0" + orderData.endMinute).slice(-2);
                                    font.bold: true;
                                    font.pixelSize: 21; color: "#222"
                                    elide: Text.ElideLeft
                                    wrapMode: Text.NoWrap
                                    clip: true
                                }
                                Text {
                                    Layout.alignment: Qt.AlignRight
                                    horizontalAlignment: Text.AlignRight
                                    Layout.preferredWidth: 75
                                    text: "（" + orderData.endStationStopInfo + "）" +
                                          orderData.endStationName
                                    font.pixelSize: 11; color: "#222";
                                    elide: Text.ElideLeft
                                    wrapMode: Text.NoWrap
                                    clip: true
                                }
                            }

                            //日期
                            Text{
                                Layout.leftMargin: 30
                                Layout.preferredWidth: 230
                                text: orderData.year + "年" + orderData.month + "月" + orderData.day + "日"
                                font.pixelSize: 27
                                font.bold: true
                                elide: Text.ElideRight
                                wrapMode: Text.NoWrap
                                clip: true
                            }
                        }


                        // 车票乘车人，车票信息
                        RowLayout{
                            // Layout.leftMargin: 42

                            //票价
                            Text{
                                Layout.topMargin: 6
                                text:"¥ "
                                font.pixelSize: 18
                                font.bold: true
                                color: "#EE8732"
                            }

                            //票价
                            Text{
                                Layout.preferredWidth: 115
                                Layout.leftMargin: -5
                                text: orderData.price
                                font.pixelSize: 30
                                color: "#EE8732"
                                elide: Text.ElideRight
                                wrapMode: Text.NoWrap
                                clip: true
                            }


                            //乘车人
                            Text{
                                Layout.preferredWidth: 135
                                text: "乘车人：" + orderData.passengerName
                                font.pixelSize: 17
                                elide: Text.ElideRight
                                wrapMode: Text.NoWrap
                                clip: true
                            }


                            //票价类型
                            Rectangle{
                                Layout.leftMargin: 20
                                Layout.preferredWidth: textItem.implicitWidth + 12   // 可加一些 padding
                                Layout.preferredHeight: textItem.implicitHeight + 8  // 可加一些 padding
                                color: "transparent"
                                border.color: "#666"
                                border.width: 2
                                radius: 6


                                Text{
                                    anchors.centerIn: parent
                                    id: textItem
                                    text: orderData.passengerType + "票"
                                    font.pixelSize: 11
                                    color: "#666"
                                }
                            }

                            //座位号
                            Text{
                                Layout.preferredWidth: 145
                                Layout.leftMargin: 15
                                text: {
                                    if (orderData.carriageNumber === 0 || orderData.seatRow === 0 || orderData.seatCol === 0) {
                                        return orderData.seatLevel + " --车--座"
                                    } else {
                                        return orderData.seatLevel + " " +
                                               ("0" + orderData.carriageNumber).slice(-2) + "车" +
                                               ("0" + orderData.seatRow).slice(-2) +
                                               String.fromCharCode(65 + orderData.seatCol - 1) + "座"
                                    }
                                }
                                font.pixelSize: 17
                                elide: Text.ElideRight
                                wrapMode: Text.NoWrap
                                clip: true
                            }

                            // 时刻表
                            CustomButton{
                                Layout.leftMargin: 10
                                Layout.preferredHeight: 18
                                Layout.preferredWidth: 53
                                fontSize: 12
                                text: "时刻表"
                                customColor: "#fff"
                                textColor: "#666"
                                pressedColor: "#666"
                                pressedTextColor: "#fff"
                                borderRadius: 5
                                borderColor: "#666"
                                borderWidth: 2
                                onClicked: {
                                    showTimetable()
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    //分割线
                    Rectangle {
                        Layout.preferredWidth: 2
                        Layout.preferredHeight: 83
                        color: "#ccc"
                        radius: 1
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    //右侧状态

                    ColumnLayout {
                        property color textColor: orderData.status === "待乘坐" ? "#00cc00" : "#808080"
                        Layout.fillHeight: true
                        spacing: 0
                        Text { text: orderData.status[0]; color: parent.textColor; font.pixelSize: 21 }
                        Text { text: orderData.status[1]; color: parent.textColor; font.pixelSize: 21 }
                        Text { text: orderData.status[2]; color: parent.textColor; font.pixelSize: 21 }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                }

            }
        }

    }
}
