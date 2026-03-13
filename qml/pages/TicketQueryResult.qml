import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

Window {
    id: resultWin
    signal closed()
    onVisibleChanged: if (!visible) closed()

    width: 740; height: 640
    minimumWidth: 480; minimumHeight: 360;
    maximumWidth: 1920; maximumHeight: 1440
    // modality: Qt.ApplicationModal
    modality: Qt.WindowModal
    
    // 处理窗口最小化问题
    onVisibilityChanged: function(visibility) {
        if (visibility === Window.Windowed || visibility === Window.Maximized) {
            // 当窗口从最小化恢复时,确保窗口显示在最前面并获得焦点
            resultWin.raise()
            resultWin.requestActivate()
        }
    }

    property alias resultData: resultData
    QtObject {
        id: resultData
        property string fromCity: ""
        property string toCity: ""
        property string date: ""
        property string selectedDate: date
    }

    // 三组互斥：座位、时间、高铁
    property int seatSelected: -1        // 0: 商务座, 1: 一等座, 2: 二等座, -1:未选
    property int timeSelected: -1        // 0: 上午, 1: 下午, -1:未选
    property int typeSelected: -1        // 0: 高铁, -1:未选

    property var ticketList: []
    property var timetable: []
    property var rawTicketList: []
    
    // 用于传递给确认订单页面的数据
    property var pendingOrderInfo: null
    property int pendingSeatType: -1
    
    // 防抖标志,避免快速重复触发筛选
    property bool isFiltering: false
    
    // 改签模式标识
    property bool rescheduleMode: false  // 是否为改签模式
    property string originalOrderNumber: ""  // 原订单号(改签时使用)
    property string rescheduleSource: ""  // 改签来源: "myOrders" 或 "management"

    // 提交流程结束信号
    signal submitOrderDone()

    //先初始化再onCompleted加载数据再onloaded
    Component.onCompleted: {
        // 预初始化,避免首次筛选时卡顿
        filterTimer.triggered.connect(performFilter)
    }

    color: "#ffffff"

    ColumnLayout{
    anchors.fill: parent
        //上部
        Rectangle{
            Layout.fillWidth: true
            height: 170
            color: "#6399f4"

            //主内容
            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: 20   // 顶部留20像素空隙
                spacing: 15

                //标题
                RowLayout {
                    Layout.preferredHeight: 35
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 40
                    Text { color: "#ffffff"; text: resultData.fromCity; font.bold: false; font.pointSize: 20 }
                    Text { 
                        color: "#ffffff"; 
                        text: "<>"; 
                        horizontalAlignment: Text.AlignLeft;
                        font.bold: true;
                        font.pointSize: 20
                        opacity: rescheduleMode ? 0.5 : 1.0  // 改签模式下半透明
                        MouseArea {
                            anchors.fill: parent
                            enabled: !rescheduleMode  // 改签模式下禁用
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                            onClicked: {
                                // 交换始发地和目的地
                                var tmp = resultData.fromCity
                                resultData.fromCity = resultData.toCity
                                resultData.toCity = tmp
                                queryTickets()
                            }
                        }
                    }
                    Text { color: "#ffffff"; text: resultData.toCity; font.bold: false; font.pointSize: 20 }
                }

                //下部
                RowLayout {

                    // 左侧日期和日历
                    RowLayout {
                        spacing: 8
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                        Layout.leftMargin: 30

                        Text {
                            text: "日期："
                            color: "#fff"
                            font.pixelSize: 18

                        }
                        Text {
                            text: resultData.selectedDate
                            color: "#fff"
                            font.pixelSize: 18

                        }
                        Image {
                            source: "qrc:/resources/icon/Calendar.png"
                            Layout.preferredWidth: 60
                            Layout.preferredHeight: 60
                            fillMode: Image.PreserveAspectFit
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: calendarDialog.open()
                            }
                        }
                    }

                    Item{
                        Layout.fillWidth: true
                    }

                    // 右侧筛选项
                    GridLayout {
                        Layout.rightMargin: 40
                        Layout.fillWidth: true
                        columns: 3
                        rowSpacing: 4
                        columnSpacing: 4

                        // 第一列
                        MyCheckBox {
                            text: "只看商务座"
                            checked: seatSelected === 0
                            onClicked: {
                                seatSelected = seatSelected === 0 ? -1 : 0
                                console.log("商务座选择状态:", seatSelected === 0)
                                filterTickets()
                            }
                            Layout.row: 0
                            Layout.column: 0
                        }
                        MyCheckBox {
                            text: "上午出发"
                            checked: timeSelected === 0
                            onClicked: {
                                timeSelected = timeSelected === 0 ? -1 : 0
                                console.log("上午出发选择状态:", timeSelected === 0)
                                filterTickets()
                            }
                            Layout.row: 1
                            Layout.column: 0
                        }
                        // 第二列
                        MyCheckBox {
                            text: "只看一等座"
                            checked: seatSelected === 1
                            onClicked: {
                                seatSelected = seatSelected === 1 ? -1 : 1
                                console.log("一等座选择状态:", seatSelected === 1)
                                filterTickets()
                            }
                            Layout.row: 0
                            Layout.column: 1
                        }
                        MyCheckBox {
                            text: "下午出发"
                            checked: timeSelected === 1
                            onClicked: {
                                timeSelected = timeSelected === 1 ? -1 : 1
                                console.log("下午出发选择状态:", timeSelected === 1)
                                filterTickets()
                            }
                            Layout.row: 1
                            Layout.column: 1
                        }
                        // 第三列
                        MyCheckBox {
                            text: "只看二等座"
                            checked: seatSelected === 2
                            onClicked: {
                                seatSelected = seatSelected === 2 ? -1 : 2
                                console.log("二等座选择状态:", seatSelected === 2)
                                filterTickets()
                            }
                            Layout.row: 0
                            Layout.column: 2
                        }
                        MyCheckBox {
                            text: "只看高铁"
                            checked: typeSelected === 0
                            onClicked: {
                                typeSelected = typeSelected === 0 ? -1 : 0
                                console.log("高铁选择状态:", typeSelected === 0)
                                filterTickets()
                            }
                            Layout.row: 1
                            Layout.column: 2
                        }
                    }
                }

                Item{
                    Layout.fillHeight: true
                }
            }
        }

        //票务查询结果卡片区和底部按钮区的白色背景
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: -20
            radius: 20
            color: "#f8fbff"
            border.color: "#999"
            border.width: 2

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: 8
                anchors.leftMargin: 5
                // anchors.rightMargin: 8
                // 滚动卡片区
                ListView {
                    id: ticketListView
                    model: ticketList
                    clip: true
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.leftMargin: 15
                    // Layout.rightMargin: 10
                    // contentWidth: parent.width

                    // 完全自定义滚动条样式
                    ScrollBar.vertical: BasicScrollBar {
                        width: 8
                        anchors.right: parent.right
                        height: parent.height - 8
                        policy: ScrollBar.AlwaysOn
                        handleNormalColor: "#a0a0a0"
                        handleLength: 60 
                    }

                    delegate: ColumnLayout {
                        width: ticketListView.width - 20

                        // 票务查询结果卡片区
                        TicketCard {
                            Layout.fillWidth: true
                            Layout.topMargin: 15
                            visible: true
                            ticketData: modelData
                            onShowTimetable: function() {
                                // 打开时刻表窗口
                                timetable = trainManager.getTimetableInfo_api(modelData.trainNumber, modelData.startStationName, modelData.endStationName)
                                timetableLoader.source = "Timetable.qml"
                                timetableLoader.active = true
                            }
                            onBookTicket: function(seatType) {
                                pendingOrderInfo = modelData
                                pendingSeatType = seatType
                                submitLoader.onSubmitOrderDoneFunction = function() {
                                    submitOrderDone()
                                    resultWin.close()
                                }
                                // 加载确认订单页面
                               submitLoader.source = "OrderConfirm.qml"
                               submitLoader.active = true
                            }
                        }
                    }
                }


                //底部分割线
                Rectangle {
                    Layout.topMargin: 10
                    Layout.leftMargin: 25
                    Layout.rightMargin: 25
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
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    Layout.bottomMargin: 30
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 50

                    property int selectedIndex: 0

                    SelectButton {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 30
                        text: "耗时最短"
                        index: 0
                        selected: parent.selectedIndex == index
                        onClicked: {
                            parent.selectedIndex = index
                            sortTickets(0)
                        }
                        fontSize: 16
                    }
                    SelectButton {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 30
                        text: "发时最早"
                        index: 1
                        selected: parent.selectedIndex == index
                        onClicked: {
                            parent.selectedIndex = index
                            sortTickets(1)
                        }
                        fontSize: 16
                    }
                    SelectButton {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 30
                        text: "到时最早"
                        index: 2
                        selected: parent.selectedIndex == index
                        onClicked: {
                            parent.selectedIndex = index
                            sortTickets(2)
                        }
                        fontSize: 16
                    }
                    SelectButton {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 30
                        text: "价格最低"
                        index: 3
                        selected: parent.selectedIndex == index
                        onClicked: {
                            parent.selectedIndex = index
                            sortTickets(3)
                        }
                        fontSize: 16
                    }
                }
            }
        }
    }

    // 日历弹窗（放在Window顶层）
    Dialog {
        id: calendarDialog
        modal: true
        width: 340
        height: 370

        // 居中显示
    x: (resultWin.width - width) / 2
    y: (resultWin.height - height) / 2

        MyCalendar {
            id: myCalendar
            anchors.fill: parent
            Connections {
                target: myCalendar
                function onSelectedDateChanged() {
                    resultData.selectedDate = Qt.formatDate(myCalendar.selectedDate, "yyyy年MM月dd日")
                    // console.log("选中日期：", myCalendar.selectedDate)
                    queryTickets()
                    calendarDialog.close()
                }
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
                item.transientParent = resultWin
                item.timetable = timetable
                item.visible = true
            }
        }
    }
    
    // 防抖定时器,避免频繁触发筛选
    Timer {
        id: filterTimer
        interval: 50  // 延迟50ms执行,让UI先响应
        repeat: false
    }
    
    Loader {
        property var onSubmitOrderDoneFunction: null
        id: submitLoader
        source: ""
        active: false
        onLoaded: {
            if (item) {
                // 连接关闭信号
                item.closed.connect(function() {
                    console.log("关闭确认订单页面")
                    submitLoader.active = false
                    pendingOrderInfo = null
                    pendingSeatType = -1
                })

                // 连接提交流程结束信号
                item.submitOrderDone.connect(onSubmitOrderDoneFunction)
                
                // 设置来源类型 - 必须在最前面设置,确保无论什么情况都能正确设置
                if (rescheduleMode) {
                    item.sourceType = rescheduleSource  // 使用传递的改签来源
                    item.originalOrderNumber = originalOrderNumber
                    console.log("设置改签模式 sourceType:", rescheduleSource, "originalOrderNumber:", originalOrderNumber)
                } else {
                    item.sourceType = "query"  // 普通查询模式
                    console.log("设置普通查询模式 sourceType: query")
                }
                
                // 如果有待处理的订单信息,则设置数据
                if (pendingOrderInfo && pendingSeatType !== -1) {
                    var seatTypeName = ["二等座", "一等座", "商务座"][pendingSeatType];
                    var price = [pendingOrderInfo.secondClassPrice, pendingOrderInfo.firstClassPrice, pendingOrderInfo.businessClassPrice][pendingSeatType];
                    var remainingTickets = [pendingOrderInfo.secondClassCount, pendingOrderInfo.firstClassCount, pendingOrderInfo.businessClassCount][pendingSeatType];
                    
                    // 设置订单信息到 ticketData
                    if (item.ticketData) {
                        item.ticketData = Object.assign({}, pendingOrderInfo, {
                            seatType: seatTypeName,
                            price: price,
                            remainingTickets: remainingTickets
                        })

                        // item.ticketData.trainNumber = pendingOrderInfo.trainNumber
                        // item.ticketData.startStationName = pendingOrderInfo.startStationName
                        // item.ticketData.startStationStopInfo = pendingOrderInfo.startStationStopInfo
                        // item.ticketData.startYear = pendingOrderInfo.startYear
                        // item.ticketData.startMonth = pendingOrderInfo.startMonth
                        // item.ticketData.startDay = pendingOrderInfo.startDay
                        // item.ticketData.startHour = pendingOrderInfo.startHour
                        // item.ticketData.startMinute = pendingOrderInfo.startMinute
                        // item.ticketData.endStationName = pendingOrderInfo.endStationName
                        // item.ticketData.endStationStopInfo = pendingOrderInfo.endStationStopInfo
                        // item.ticketData.endYear = pendingOrderInfo.endYear
                        // item.ticketData.endMonth = pendingOrderInfo.endMonth
                        // item.ticketData.endDay = pendingOrderInfo.endDay
                        // item.ticketData.endHour = pendingOrderInfo.endHour
                        // item.ticketData.endMinute = pendingOrderInfo.endMinute
                        // item.ticketData.intervalHour = pendingOrderInfo.intervalHour
                        // item.ticketData.intervalMinute = pendingOrderInfo.intervalMinute
                        // item.ticketData.seatType = seatTypeName
                        // item.ticketData.price = price
                        // item.ticketData.remainingTickets = remainingTickets
                    }
                }
                
                // 在设置完所有属性后,手动调用 refreshPassengers
                item.refreshPassengers()
                item.visible = true
            }
        }
    }

    //查询车票
    function queryTickets() {
        var dateInt = resultData.selectedDate.match(/(\d+)年(\d+)月(\d+)日/);
        if (!dateInt) {
            console.log("selectedDate 格式不正确:", resultData.selectedDate);
            return;
        }
        var year = parseInt(dateInt[1]);
        var month = parseInt(dateInt[2]);
        var day = parseInt(dateInt[3]);
        console.log("year:", year, "month:", month, "day:", day);
        rawTicketList = bookingSystem.queryTickets_api(resultData.fromCity, resultData.toCity, year, month, day);
        ticketList = rawTicketList;
    }


    //筛选车票 - 使用防抖机制优化性能
    function filterTickets() {
        // 如果正在筛选,先停止之前的定时器
        if (filterTimer.running) {
            filterTimer.stop()
        }
        // 启动延迟筛选,让UI先响应
        filterTimer.start()
    }
    
    //实际执行筛选的函数
    function performFilter() {
        if (isFiltering) {
            return  // 防止重复执行
        }
        
        isFiltering = true
        
        ticketList = rawTicketList.filter(function(ticket, idx) {

                // if (!rawTicketList || rawTicketList.length === 0) {
                //     console.log("原始筛选数据 rawTicketList 为空！");
                // } else {
                //     console.log("原始筛选数据数量：", rawTicketList.length, rawTicketList);
                // }
            // 座位类型筛选
            if (seatSelected !== -1) {
                // console.log('座位选择');
                if (seatSelected === 0 && ticket.businessClassCount <= 0) {
                    // console.log(`[${idx}] filtered by businessClassCount:`, ticket);
                    return false;
                }
                if (seatSelected === 1 && ticket.firstClassCount <= 0) {
                    // console.log(`[${idx}] filtered by firstClassCount:`, ticket);
                    return false;
                }
                if (seatSelected === 2 && ticket.secondClassCount <= 0) {
                    // console.log(`[${idx}] filtered by secondClassCount:`, ticket);
                    return false;
                }
            }
            // 出发时间筛选
            if (timeSelected !== -1) {
                // console.log('时间选择');
                if (timeSelected === 0 && ticket.startHour >= 12) {
                    // console.log(`[${idx}] filtered by startHour >= 12:`, ticket);
                    return false;
                }
                if (timeSelected === 1 && ticket.startHour < 12) {
                    // console.log(`[${idx}] filtered by startHour < 12:`, ticket);
                    return false;
                }
            }
            // 列车类型筛选
            if (typeSelected !== -1) {
                // console.log('类型选择');
                if (typeSelected === 0 && !ticket.trainNumber.startsWith("G")) {
                    // console.log(`[${idx}] filtered by trainNumber not G:`, ticket);
                    return false;
                }
            }
            // 通过所有条件
            return true;
        });

        isFiltering = false
        // console.log("filter result:", ticketList);
    }

    //排序车票
    function sortTickets(sortType) {
        var tempList = ticketList.slice(); // 复制数组
        
        switch(sortType) {
            case 0: // 耗时最短
                tempList.sort(function(a, b) {
                    // 将时间转换为分钟进行比较
                    var durationA = a.intervalHour * 60 + a.intervalMinute;
                    var durationB = b.intervalHour * 60 + b.intervalMinute;
                    return durationA - durationB;
                });
                break;
            case 1: // 发时最早
                tempList.sort(function(a, b) {
                    // 先比较小时，再比较分钟
                    if (a.startHour !== b.startHour) {
                        return a.startHour - b.startHour;
                    }
                    return a.startMinute - b.startMinute;
                });
                break;
            case 2: // 到时最早
                tempList.sort(function(a, b) {
                    // 先比较小时，再比较分钟
                    if (a.endHour !== b.endHour) {
                        return a.endHour - b.endHour;
                    }
                    return a.endMinute - b.endMinute;
                });
                break;
            case 3: // 价格最低
                tempList.sort(function(a, b) {
                    // 获取最低价格（二等座 < 一等座 < 商务座）
                    var priceA = a.secondClassPrice || a.firstClassPrice || a.businessClassPrice || 0;
                    var priceB = b.secondClassPrice || b.firstClassPrice || b.businessClassPrice || 0;
                    return priceA - priceB;
                });
                break;
        }
        
        ticketList = tempList;
        console.log("排序完成，类型:", sortType);
    }
}
