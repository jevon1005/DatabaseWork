import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import MyApp 1.0
import "../components"

Page {
    width: parent ? parent.width : 960
    height: parent ? parent.height : 720
    // width: 960
    // height: 720
    id: orderManagementPage
    objectName: "qrc:/qml/pages/OrderManagement.qml"
    visible: true

    property var mainWindow
    property var rawOrderList: []
    property var orderList: []

    Component.onCompleted: {
        refreshOrders()
    }

    Rectangle {
        anchors.fill: parent

        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 20
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: orderManagementPage.height - 110
                Layout.alignment: Qt.AlignTop

                // 滚动卡片区
                ListView {
                    id: orderListView
                    model: orderList
                    clip: true
                    spacing: 15
                    anchors.fill: parent
                    anchors.topMargin: 20
                    anchors.bottomMargin: 20

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
                        width: orderListView.width - 30

                        RowLayout {
                            Layout.fillWidth: true

                            OrderCard {
                                Layout.preferredWidth: 675
                                orderData: modelData
                                onShowTimetable: function() {
                                    timetableLoader.timetable = orderManager.getTimetableInfo_api(modelData.orderNumber)
                                    timetableLoader.source = "Timetable.qml"
                                    timetableLoader.active = true
                                    console.log(timetableLoader.timetable[0]["stationName"])
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            ColumnLayout {
                                CustomButton {
                                    Layout.preferredWidth: 110
                                    Layout.preferredHeight: 35
                                    text: "改签"
                                    activeFocusOnTab: true
                                    mouseAreaEnabled: modelData.status === "待乘坐"
                                    customColor: modelData.status === "待乘坐" ? "#409CFC" : "#808080"
                                    pressedColor: modelData.status === "待乘坐" ? "#174a73" : "#808080"
                                    hoverColor: modelData.status === "待乘坐" ? "#1f5f99" : "#808080"
                                    onClicked: {
                                        // 改签逻辑:跳转到车票查询结果页面
                                        openRescheduleTicketQuery(modelData)
                                    }
                                }
                                Item{
                                    Layout.preferredHeight: 20
                                }
                                CustomButton {
                                    Layout.preferredWidth: 110
                                    Layout.preferredHeight: 35
                                    text: "退票"
                                    activeFocusOnTab: true
                                    mouseAreaEnabled: modelData.status === "待乘坐"
                                    customColor: modelData.status === "待乘坐" ? "#409CFC" : "#808080"
                                    pressedColor: modelData.status === "待乘坐" ? "#174a73" : "#808080"
                                    hoverColor: modelData.status === "待乘坐" ? "#1f5f99" : "#808080"
                                    onClicked: {
                                        warning.onConfirmed = function() {
                                            warning.active = false
                                            cancelOrder(modelData.orderNumber)
                                        }
                                        warning.message = "确认取消该订单？"
                                        warning.source = "qrc:/qml/components/ConfirmCancelDialog.qml"
                                        warning.active = true
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 分割线
            Rectangle {
                id: rectangle
                Layout.fillWidth: true
                Layout.preferredHeight: 2
                Layout.rightMargin: 30
                color: "#cce5ff"
            }

            // 搜索框
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                Layout.topMargin: 10
                spacing: 15

                // 搜索框
                SearchBar{
                    id: searchOrderNumber
                    inputHeight: 30
                    width: 185
                    fontSize: 14
                    placeholderText: "查找订单号"
                    onTextChanged: filterOrderList()
                }
                SearchBar{
                    id: searchTrainNumber
                    inputHeight: 30
                    width: 185
                    fontSize: 14
                    placeholderText: "查找车次"
                    onTextChanged: filterOrderList()
                }
                SearchBar{
                    id: searchDate
                    inputHeight: 30
                    width: 185
                    fontSize: 14
                    placeholderText: "查找日期（yyyymmdd)"
                    onTextChanged: filterOrderList()
                }
                SearchBar{
                    id: searchPassengerName
                    inputHeight: 30
                    width: 185
                    fontSize: 14
                    placeholderText: "查找乘车人"
                    onTextChanged: filterOrderList()
                }

                Item { Layout.fillWidth: true }
            }

            // 搜索框
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                spacing: 15

                // 搜索框
                SearchBar{
                    id: searchStartStationName
                    inputHeight: 30
                    width: 185
                    fontSize: 14
                    placeholderText: "查找出发站"
                    onTextChanged: filterOrderList()
                }
                SearchBar{
                    id: searchEndStationName
                    inputHeight: 30
                    width: 185
                    fontSize: 14
                    placeholderText: "查找终点站"
                    onTextChanged: filterOrderList()
                }
                Item { Layout.fillWidth: true }
            }
        }
    }

    //警告
    Loader {
        property string message: ""
        property var onConfirmed: null
        id: warning
        source: ""
        active: false
        onLoaded: {
            if (item) {
                // 连接关闭信号
                item.canceled.connect(function() {
                    warning.active = false
                })
                // 连接确认信号
                item.confirmed.connect(onConfirmed)
                // 初始化参数
                item.contentText = message
                item.visible = true
            }
        }
    }

    //通知
    Loader {
        property string message: ""
        id: notification
        source: ""
        active: false
        onLoaded: {
            if (item) {
                // 连接关闭信号
                item.closed.connect(function() {
                    notification.active = false
                })
                // 初始化参数
                item.contentText = message
                item.visible = true
            }
        }
    }

    //时刻表页面
    Loader {
        property var timetable: []
        id: timetableLoader
        source: ""
        active: false
        onLoaded: {
            if (item) {
                // 连接关闭信号
                item.closed.connect(function() {
                    console.log("!!!!!!!!!!!!!!!!!!!!")
                    timetableLoader.active = false
                })
                // 初始化参数
                item.transientParent = mainWindow
                item.timetable = timetable
                item.visible = true
            }
        }
    }

    //车票查询结果页面(改签用)
    Loader {
        property var orderInfo: null
        id: ticketResultLoader
        source: ""
        active: false
        onLoaded: {
            if (item) {
                // 连接关闭信号
                item.closed.connect(function() {
                    ticketResultLoader.active = false
                    orderInfo = null
                    refreshOrders()  // 关闭时刷新订单列表
                })
                // 初始化参数
                if (orderInfo) {
                    // 通过车站名获取城市名
                    var cityMap = stationManager.getCitiesByStationNames_api(orderInfo.startStationName, orderInfo.endStationName)
                    item.resultData.fromCity = cityMap.startCity
                    item.resultData.toCity = cityMap.endCity
                    var dateStr = orderInfo.year + "年" + 
                                  (orderInfo.month < 10 ? "0" : "") + orderInfo.month + "月" + 
                                  (orderInfo.day < 10 ? "0" : "") + orderInfo.day + "日"
                    item.resultData.date = dateStr
                    item.resultData.selectedDate = dateStr
                    item.rescheduleMode = true  // 标记为改签模式
                    item.originalOrderNumber = orderInfo.orderNumber  // 传递原订单号
                    item.rescheduleSource = "myOrders"  // 改签时只显示该订单的乘客
                    item.transientParent = mainWindow
                    item.queryTickets()
                    item.rawTicketList = item.ticketList
                }
                item.visible = true
            }
        }
    }

    function refreshOrders() {
        // 记录当前滚动条位置
        var savedContentY = orderListView.contentY
        rawOrderList = orderManager.getOrders_api()
        filterOrderList()
        // 回到之前记录的位置
        orderListView.contentY = savedContentY
    }

    function cancelOrder(orderNumber) {
        orderManager.cancelOrder_api(orderNumber)
        refreshOrders()
        notification.message = "订单取消成功！"
        notification.source = "qrc:/qml/components/ConfirmDialog.qml"
        notification.active = true
    }

    function filterOrderList() {
        orderList = rawOrderList.filter(function(order) {
            // 日期判断，yyyyMMdd格式
            var dateOk = true;
            if (searchDate.text !== "") {
                var mm = order.month < 10 ? "0" + order.month : "" + order.month;
                var dd = order.day < 10 ? "0" + order.day : "" + order.day;
                var orderDateStr = "" + order.year + mm + dd;
                dateOk = (orderDateStr === searchDate.text);
            }
            return (searchOrderNumber.text === "" || (order.orderNumber && order.orderNumber.indexOf(searchOrderNumber.text) !== -1))
                && (searchTrainNumber.text === "" || (order.trainNumber && order.trainNumber.indexOf(searchTrainNumber.text) !== -1))
                && (searchPassengerName.text === "" || (order.passengerName && order.passengerName.indexOf(searchPassengerName.text) !== -1))
                && (searchStartStationName.text === "" || (order.startStationName && order.startStationName.indexOf(searchStartStationName.text) !== -1))
                && (searchEndStationName.text === "" || (order.endStationName && order.endStationName.indexOf(searchEndStationName.text) !== -1))
                && dateOk;
        });
    }

    // 打开改签车票查询页面
    function openRescheduleTicketQuery(orderData) {
        console.log("打开改签页面,订单号:", orderData.orderNumber)
        ticketResultLoader.orderInfo = orderData
        ticketResultLoader.source = "qrc:/qml/pages/TicketQueryResult.qml"
        ticketResultLoader.active = true
    }
}
