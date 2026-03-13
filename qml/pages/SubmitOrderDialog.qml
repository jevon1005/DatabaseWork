import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"
import MyApp 1.0

Window{
    id: submitWin
    signal closed()
    
    // 处理窗口最小化和关闭问题
    onVisibleChanged: {
        if (!visible) closed()
    }
    
    onVisibilityChanged: function(visibility) {
        if (visibility === Window.Windowed || visibility === Window.Maximized) {
            // 当窗口从最小化恢复时,确保窗口显示在最前面并获得焦点
            submitWin.raise()
            submitWin.requestActivate()
        }
    }
    
    width: 740; height: 580
    minimumWidth: 480; minimumHeight: 360
    maximumWidth: 1920; maximumHeight: 1440
    
    visible: true
    color: "transparent"
    flags: Qt.FramelessWindowHint
    modality: Qt.ApplicationModal

    property var submitList: []
    property var timetable: []
    property string mode: "query"
    property string originalOrderNumber: ""

    signal submitOrderDone();

    Rectangle {
        id:root
        anchors.fill: parent
        color: "#ffffff"
        radius: 16
        border.color: "#808080"

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
               submitWin.x += mouse.x - clickX;
               submitWin.y += mouse.y - clickY;
           }
       }

        //标题
        Header {
            id: header
            anchors.top: parent.top
            anchors.topMargin: 1
            width: parent.width - 5
            title: "提交订单"
            onCloseClicked: {
                submitWin.visible = false
            }
        }

        //下部
        Rectangle {
            width: parent.width
            height: parent.height - header.height - 20 // 可根据内容调整高度
            anchors.top: parent.top
            anchors.topMargin: header.height + 20
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5

            ColumnLayout {
                anchors.fill: parent
                // anchors.topMargin: 8
                // anchors.leftMargin: 5
                // anchors.rightMargin: 8
                // 滚动卡片区
                ListView {
                    id: submitListView
                    model: submitList
                    clip: true
                    spacing: 15
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.leftMargin: 20
                    // Layout.leftMargin: 10
                    // Layout.rightMargin: 10
                    // contentWidth: parent.width

                    // 完全自定义滚动条样式
                    ScrollBar.vertical: BasicScrollBar {
                        width: 8
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        height: parent.height - 8
                        policy: ScrollBar.AlwaysOn
                        handleNormalColor: "#a0a0a0"
                        handleLength: 60 
                    }

                    delegate: ColumnLayout {
                    width: submitListView.width - 30

                        RowLayout {
                            Layout.fillWidth: true

                            OrderCard {
                                Layout.preferredWidth: 675
                                orderData: modelData
                                onShowTimetable: function() {
                                    // 根据车次号、起始站和终点站查询时刻表
                                    timetable = trainManager.getTimetableInfo_api(modelData.trainNumber, modelData.startStationName, modelData.endStationName)
                                    timetableLoader.source = "Timetable.qml"
                                    timetableLoader.active = true
                                }
                            }
                        }
                    }
                }

                //底部分割线
                Rectangle {
                    Layout.topMargin: 10
                    Layout.leftMargin: 40
                    Layout.rightMargin: 40
                    Layout.preferredHeight: 2
                    Layout.fillWidth: true
                    // anchors.horizontalCenter: parent.horizontalCenter
                    // anchors.bottom: parent.bottom
                    // anchors.bottomMargin: 70
                    // anchors.leftMargin: 20
                    // width: parent.width - 40
                    // height: 2
                    // color: 'pink'
                    color: "#ccc"
                    radius: 1
                }

                // 底部按钮区
                RowLayout {
                    Layout.topMargin: 10
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    // anchors.horizontalCenter: parent.horizontalCenter
                    // anchors.bottom: parent.bottom
                    // anchors.bottomMargin: 30
                    spacing: 80
                    Layout.bottomMargin: 30

                    CustomButton {
                        text: "提交订单"
                        width: 250
                        height: 30
                        onClicked: {
                            console.log("提交订单,共", submitList.length, "张")
                            // TODO: 调用后端API提交订单
                            // 这里假设提交成功
                            var success = true
                            for (var i = 0; i < submitList.length; i++) {
                                var order = submitList[i]
                                var result = bookingSystem.createOrder_api({
                                    // 管理员不传用户名，因为管理员改签的用户名来自待改签订单
                                    username: SessionState.role === "user" ? SessionState.username : "",
                                    trainNumber: order.trainNumber,
                                    passengerId: order.passengerId,
                                    startStationName: order.startStationName,
                                    endStationName: order.endStationName,
                                    year: order.year,
                                    month: order.month,
                                    day: order.day,
                                    seatLevel: order.seatLevel,
                                    pendingRescheduleOrderNumber: order.pendingRescheduleOrderNumber
                                })
                                if (!result.success) {
                                    success = false
                                    console.log(result.message)
                                }
                            }
                            notification.message = success ? "全部提交成功，可到我的订单界面查看！" : "有部分订单提交失败!"
                            notification.onClosedFunction = function() {
                                submitOrderDone()
                                submitWin.closed()
                            }
                            notification.source = "qrc:/qml/components/ConfirmDialog.qml"
                            notification.active = true
                        }
                    }
                    CustomButton {
                        text: "返回"
                        customColor: "#e6e6e6"
                        textColor: "#666"
                        pressedColor: "#666"
                        pressedTextColor: "#fff"
                        width: 250
                        height: 30
                        onClicked: {
                            submitWin.visible = false
                        }
                    }
                }
            }
        }
    }

    // 通知弹窗
    Loader {
        property string message: ""
        property var onClosedFunction: null
        id: notification
        source: ""
        active: false
        onLoaded: {
            if (item) {
                // 设置父窗口关系 - 使用主窗口避免模态窗口焦点竞争
                item.transientParent = ApplicationWindow.window
                // 连接关闭信号
                item.closed.connect(onClosedFunction)
                // 初始化参数
                item.contentText = message
                item.visible = true
            }
        }
    }

    //时刻表页面
    Loader {
        id: timetableLoader
        source: ""
        active: false
        onLoaded: {
            if (item) {
                // 连接关闭信号
                item.closed.connect(function() {
                    timetableLoader.active = false
                })
                // 初始化参数
                item.transientParent = submitWin
                item.timetable = timetable
                item.visible = true
            }
        }
    }
}
