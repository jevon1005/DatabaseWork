import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    // width: parent ? parent.width : 800
    // height: parent ? parent.height : 79
    width: 800
    height: 79

    property var passengerData: ({
        name: "张三张三三",
        phoneNumber: "17816936112",
        id: "412828200507112111",
        type: "学生票",
    })

    property bool available: true

    // 卡片 + 按钮
    RowLayout {
        anchors.fill: parent

        // 卡片
        Rectangle {
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height
            radius: 16
            gradient: Gradient {
                GradientStop { position: 0.0; color: available ? "#cce5ff" : "#E0E0E0"}
                GradientStop { position: 1.0; color: available ? "#8ec9ff" : "#808080"}
            }
            // anchors.left: parent.left
            // anchors.verticalCenter: parent.verticalCenter


            // 一列文本 + 一列文本
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20

                // 间隔
                Item {
                    Layout.preferredWidth: 20
                    Layout.alignment: Qt.AlignCenter
                }

                // 一行文本 + 一行文本
                ColumnLayout {

                    // 第一行文本
                    RowLayout {
                        Layout.topMargin: 12

                        Text {
                            Layout.preferredWidth: 54
                            Layout.preferredHeight: 23
                            text: "姓名："
                            font.pixelSize: 18
                            color: "#222"
                        }

                        Text {
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 23
                            text: passengerData.name
                            font.pixelSize: 18
                            color: "#222"
                        }
                    }

                    //间距
                    Item{
                        Layout.fillHeight: true
                    }

                    // 第二行文本
                    RowLayout {
                        Layout.bottomMargin: 20

                        Text {
                            Layout.preferredWidth: 90
                            Layout.preferredHeight: 23
                            text: "身份证号："
                            font.pixelSize: 18
                            color: "#222"
                        }

                        Text {
                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 23
                            text: passengerData.id
                            font.pixelSize: 18
                            color: "#222"
                        }
                    }
                }

                // 一行文本 + 一行文本
                ColumnLayout {
                    Layout.topMargin: 12

                    // 第一行文本
                    RowLayout {
                        Text {
                            Layout.preferredWidth: 90
                            Layout.preferredHeight: 23
                            text: "联系方式："
                            font.pixelSize: 18
                            color: "#222"
                        }

                        Text {
                            Layout.preferredWidth: 150
                            Layout.preferredHeight: 23
                            text: passengerData.phoneNumber
                            font.pixelSize: 18
                            color: "#222"
                        }
                    }


                    //间距
                    Item{
                        Layout.fillHeight: true
                    }

                    // 第二行文本
                    RowLayout {
                        Layout.bottomMargin: 20
                        Text {
                            Layout.preferredWidth: 90
                            Layout.preferredHeight: 23
                            text: "优惠类型："
                            font.pixelSize: 18
                            color: "#222"
                        }

                        Text {
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 23
                            text: passengerData.type
                            font.pixelSize: 18
                            color: "#222"
                        }
                    }
                }
            }
        }
    }

}
