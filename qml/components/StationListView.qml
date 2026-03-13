import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: stationList
    width: 250
    height: 320

    property var stations: [
        { name: "北京南", city: "北京"},
        { name: "上海虹桥", city: "上海"},
        { name: "遵义北", city: "遵义"},
        { name: "嘉兴南", city: "嘉兴"},
        { name: "贺州西", city: "贺州"},
        { name: "温州南", city: "温州"},
        { name: "贵州", city: "贵州"},
    ]

    property bool showButtons: true

    // 新增：外部可控边框宽度
    property int borderWidth: 1

    //背景
    Rectangle {
        anchors.fill: parent
        radius: 8
        color: "#fff"
        border.color: "#dde"
        border.width: borderWidth   // 这里引用属性
    }

    ColumnLayout{
        width: parent.width - 4
        height: parent.height

        // 表头
        Rectangle {
            Layout.topMargin: 2
            Layout.leftMargin: 2
            Layout.rightMargin: 2
            radius: 8
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            color: "#f4f9ff"
            RowLayout {
                width: parent.width
                height: parent.height
                // 左侧编辑图标占位
                Item { Layout.preferredWidth: 36; visible: showButtons }

                //间隔
                Item{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }

                Text {
                    text: "站名"
                    font.bold: true
                    Layout.preferredWidth: 48
                    horizontalAlignment: Text.AlignHCenter
                }

                //间隔
                Item{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }

                Text {
                    text: "城市"
                    font.bold: true
                    Layout.preferredWidth: 48
                    horizontalAlignment: Text.AlignHCenter
                }

                //间隔
                Item{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }

                // 右侧删除图标占位
                Item { Layout.preferredWidth: 36; visible: showButtons }
            }
        }

        // 表头下的分割线
        Rectangle {
            width: parent.width
            height: 1
            color: "#cce5ff"
        }


        //表格背景
        Rectangle{
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.leftMargin: 2
            Layout.rightMargin: 2
            Layout.bottomMargin: 2
            radius:8
            // 表格内容
            ScrollView {
                id:scrollview
                anchors.fill:parent

                // 完全自定义滚动条样式
                ScrollBar.vertical: BasicScrollBar {
                    width: 4
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height - 8
                    policy: ScrollBar.AlwaysOn
                    handleNormalColor: "#a0a0a0"
                    handleLength: 60 
                }

                ColumnLayout {
                    width: scrollview.width
                    height: scrollview.height
                    Repeater {
                        model: stationList.stations
                        ColumnLayout{
                            Layout.fillWidth: true
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40

                                // 编辑按钮
                                Item {
                                    Layout.preferredWidth: 36
                                    Layout.preferredHeight: 40
                                    visible: showButtons
                                    Button {
                                        anchors.centerIn: parent
                                        width: 24; height: 24
                                        icon.source: "qrc:/resources/icon/Edit.png"
                                        background: Rectangle { color: "transparent" }
                                        onClicked: {
                                            // 编辑逻辑
                                        }
                                    }
                                }

                                //间隔
                                Item{
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: modelData.name
                                    Layout.preferredWidth: 48
                                    Layout.preferredHeight: 40
                                    verticalAlignment: Text.AlignVCenter
                                    // font.pixelSize: 16
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                //间隔
                                Item{
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: modelData.city
                                    Layout.preferredWidth: 48
                                    Layout.preferredHeight: 40
                                    verticalAlignment: Text.AlignVCenter
                                    // font.pixelSize: 16
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                //间隔
                                Item{
                                    Layout.fillWidth: true
                                }

                                // 删除按钮
                                Item {
                                    Layout.preferredWidth: 36
                                    Layout.preferredHeight: 40
                                    visible: showButtons
                                    Button {
                                        anchors.centerIn: parent
                                        width: 36; height: 36
                                        icon.source: "qrc:/resources/icon/Delete.png"
                                        background: Rectangle { color: "transparent" }
                                        onClicked: {
                                            timetable.stations.splice(index, 1)
                                        }
                                    }
                                }


                            }

                            // 行分割线
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                                // Layout.leftMargin: 36
                                Layout.columnSpan: 6
                                color: "#e0e0e0"
                            }
                        }
                    }
                }
            }
        }
    }
}
