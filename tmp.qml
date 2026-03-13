import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

Item {
    height: 128
    width: 675

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
                        text:"订单号：00000002"
                        color: "#606060"
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
                    Layout.fillWidth: true

                    Item {
                        Layout.fillWidth: true
                    }


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
                            spacing: 30
                            // 出发时间
                            ColumnLayout {
                                Layout.alignment: Qt.AlignTop

                                Text {
                                    Layout.alignment: Qt.AlignLeft
                                    text: "09:10"; font.bold: true;
                                    font.pixelSize: 21; color: "#222";
                                }
                                Text {
                                    Layout.alignment: Qt.AlignLeft
                                    text: "北京南（始）";
                                    font.pixelSize: 9; color: "#222";
                                }
                            }
                            // 车次、箭头
                            ColumnLayout {
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "G115"; font.bold: true;
                                    font.pixelSize: 18; color: "#222";
                                }
                                Image {
                                    Layout.preferredWidth: 90
                                    Layout.preferredHeight: 4
                                    Layout.topMargin: -8
                                    source: "qrc:/resources/icon/arrow.svg"
                                    fillMode: Image.Stretch
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.topMargin: -2
                                    text: "6小时7分";
                                    font.pixelSize: 8; color: "#888"; }
                            }
                            // 到达时间
                            ColumnLayout {
                                Text {
                                    Layout.alignment: Qt.AlignRight
                                    text: "15:17"; font.bold: true;
                                    font.pixelSize: 21; color: "#222"
                                }
                                Text {
                                    Layout.alignment: Qt.AlignRight
                                    text: "（过）上海虹桥";
                                    font.pixelSize: 9; color: "#222";
                                }
                            }

                            //间隔
                            Item{
                                Layout.preferredWidth: 3
                            }

                            //日期
                            Text{
                                text:"2025年6月4日"
                                font.pixelSize: 27
                                font.bold: true
                            }

                            //间隔
                            Item{
                                Layout.preferredWidth: 30
                            }
                        }


                        //车票乘车人，车票信息
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
                                Layout.leftMargin: -5
                                text:"708"
                                font.pixelSize: 30
                                color: "#EE8732"
                            }

                            //间隔
                            Item{
                                Layout.preferredWidth: 23
                            }

                            //乘车人
                            Text{
                                text: "乘车人： 王宇豪"
                                font.pixelSize: 17
                            }

                            //间隔
                            Item{
                                Layout.preferredWidth: 20
                            }

                            //票价类型
                            Rectangle{
                                Layout.preferredWidth: textItem.implicitWidth + 12   // 可加一些 padding
                                Layout.preferredHeight: textItem.implicitHeight + 8  // 可加一些 padding
                                color: "transparent"
                                border.color: "#666"
                                border.width: 2
                                radius: 6


                                Text{
                                    anchors.centerIn: parent
                                    id: textItem
                                    text:"学生票"
                                    font.pixelSize: 11
                                    color: "#666"
                                }
                            }

                            //间隔
                            Item{
                                Layout.preferredWidth: 26
                            }

                            //座位号
                            Text{
                                text: "二等座   02车  06F号"
                                font.pixelSize: 17
                            }

                            //间隔
                            Item{
                                Layout.preferredWidth: 8
                            }

                            CustomButton{
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
                        Layout.fillHeight: true
                        spacing: 0
                        Text { text: "待"; color: "#00cc00"; font.pixelSize: 21 }
                        Text { text: "乘"; color: "#00cc00"; font.pixelSize: 21 }
                        Text { text: "坐"; color: "#00cc00"; font.pixelSize: 21 }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                }

            }
        }

    }
}