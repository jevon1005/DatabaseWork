import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

Window {
    id: timetableManagementWin
    width: 400; height: 520
    visible: true
    color: "transparent"
    flags: Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    
    // 处理窗口最小化问题
    onVisibilityChanged: function(visibility) {
        if (visibility === Window.Windowed || visibility === Window.Maximized) {
            // 当窗口从最小化恢复时,确保窗口显示在最前面并获得焦点
            timetableManagementWin.raise()
            timetableManagementWin.requestActivate()
        } else if (!visible) {
            closed()
        }
    }

    property var timetable: []
    property string oldTrainNumber: ""

    signal closed()
    signal confirmed(var info)

    onClosing: {
        closed()
    }

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: "#ffffff"
        border.color: "#222"
        border.width: 1


        //拖动逻辑
        MouseArea {
           anchors.fill: parent
           // 定义拖动
           property real clickX: 0
           property real clickY: 0

           onPressed: function(mouse) {
               clickX = mouse.x;
               clickY = mouse.y;
           }
           onPositionChanged: function(mouse) {
               // 拖动窗口
               timetableManagementWin.x += mouse.x - clickX;
               timetableManagementWin.y += mouse.y - clickY;
           }
           onClicked: {
               // 点击任意位置退出编辑模式
               if (titleBar.isEditing) {
                   titleBar.isEditing = false
               }
           }
       }

        ColumnLayout{
            anchors.fill: parent
            spacing:0

            // 标题栏
            Rectangle {
                id: titleBar
                Layout.fillWidth: true
                height: 40
                radius: 16
                Layout.leftMargin: 1
                Layout.rightMargin: 1
                Layout.topMargin: 1
                
                property bool isEditing: false
                
                // 显示模式：文本
                Text {
                    id: trainNumberText
                    text: trainNumberInput.text
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 28
                    font.bold: true
                    visible: !titleBar.isEditing
                }
                
                // 编辑模式：输入框
                Rectangle {
                    id: trainNumberEditBox
                    width: 150
                    height: 35
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    visible: titleBar.isEditing
                    border.color: "transparent"
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            // 阻止事件冒泡，避免点击输入框时退出编辑
                            mouse.accepted = true
                        }
                    }
                    
                    TextInput {
                        id: trainNumberInput
                        text: oldTrainNumber
                        anchors.fill: parent
                        anchors.margins: 5
                        font.pixelSize: 24
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        
                        onAccepted: {
                            titleBar.isEditing = false
                        }
                    }
                }
                
                // 编辑按钮
                Image {
                    source: "qrc:/resources/icon/Edit.png" 
                    width: 40
                    height: 40
                    anchors.left: parent.horizontalCenter
                    anchors.leftMargin: 40
                    anchors.verticalCenter: parent.verticalCenter
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            mouse.accepted = true  // 阻止事件冒泡
                            titleBar.isEditing = !titleBar.isEditing
                            if (titleBar.isEditing) {
                                trainNumberInput.forceActiveFocus()
                                trainNumberInput.selectAll()
                            }
                        }
                    }
                }
            }

            //间隔符
            Rectangle{
                Layout.fillWidth: true
                height: 2
                color: "#222"
            }

            //时刻表
            TimetableView{
                id: timetableView
                Layout.fillWidth: true
                Layout.preferredHeight: 350
                borderWidth: 0
                Layout.leftMargin: 2
                Layout.rightMargin: 2
                Layout.topMargin: 4
                passingStationList: timetable
            }

            Item {
                Layout.fillHeight: true
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
                        timetableView.onClickAddIconFunction()
                    }
                }
            }

            Item {
                Layout.preferredHeight: 10
            }

            // 按钮区
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 10
                Layout.bottomMargin: 25

                Item {
                    Layout.preferredWidth: 30
                }
                // 确认按钮
                CustomButton{
                    buttonType: "confirm"
                    text: "确认"
                    borderRadius: 4
                    height: 26
                    width:130
                    fontSize:14
                    onClicked: confirmed({
                        oldTrainNumber: oldTrainNumber,
                        passingStationList: timetableView.passingStationList,
                        newTrainNumber: trainNumberInput.text
                    })
                }

                Item { Layout.fillWidth: true }

                // 取消按钮
                CustomButton{
                    buttonType: "cancel"
                    text: "取消"
                    borderRadius: 4
                    height: 26
                    width:130
                    fontSize:14
                    onClicked: {
                        timetableManagementWin.visible = false
                    }
                }

                Item { Layout.preferredWidth: 30}
            }
        }
    }
}
