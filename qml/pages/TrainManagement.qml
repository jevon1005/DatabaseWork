import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

Page {
    width: parent ? parent.width : 960
    height: parent ? parent.height : 720
    id:trainManagementPage
    objectName: "qrc:/qml/pages/TrainManagement.qml"
    visible: true

    property var mainWindow
    property var rawTrainList: []
    property var trainList: []

    Component.onCompleted: {
        refreshTrains()
    }

    RowLayout {
        anchors.fill: parent

        // 主内容区
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.topMargin: 20
                spacing: 0

                // 车次卡片区（ListView放在Rectangle里）
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: trainManagementPage.height - 120

                    ListView {
                        id: trainListView
                        anchors.fill: parent
                        model: trainList
                        spacing: 15
                        clip: true

                        // 完全自定义滚动条样式
                        ScrollBar.vertical: BasicScrollBar {
                            width: 8
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            height: parent.height - 8
                            policy: ScrollBar.AlwaysOn
                            handleNormalColor: "#a0a0a0"
                            handleLength: 60 // 这里设置想要的长度
                        }

                        delegate: RowLayout {
                            width: trainListView.width

                            // 左侧按钮区
                            ColumnLayout {
                                width: 100
                                spacing: 10
                                Layout.leftMargin: 2
                                // verticalCenter: parent.verticalCenter

                                CustomButton {
                                    text: "时刻表"
                                    width: 90
                                    height: 26
                                    fontSize: 15
                                    borderRadius: 7
                                    buttonType: "confirm"
                                    onClicked: {
                                        timetableLoader.timetable = trainManager.getTimetableInfo_api(modelData.trainNumber)
                                        timetableLoader.oldTrainNumber = modelData.trainNumber
                                        timetableLoader.isAddMode = false  // 编辑模式
                                        timetableLoader.onConfirmedFunction = function(info) {
                                            updateTimetableAndTrainNumber(info)
                                        }

                                        timetableLoader.source = "TimetableManagement.qml"
                                        timetableLoader.active = true
                                    }
                                }
                                CustomButton {
                                    text: "座位模板"
                                    width: 90
                                    height: 26
                                    fontSize: 15
                                    borderRadius: 7
                                    buttonType: "confirm"
                                    onClicked: {
                                        seatTemplateLoader.trainNumber = modelData.trainNumber
                                        seatTemplateLoader.currentCarriages = trainManager.getCarriages_api(modelData.trainNumber)
                                        seatTemplateLoader.onConfirmedFunction = function(info) {
                                            updateSeatTemplate(modelData.trainNumber, info)
                                        }

                                        seatTemplateLoader.source = "EditSeatTemplateDialog.qml"
                                        seatTemplateLoader.active = true
                                    }
                                }
                            }

                            Item{
                                Layout.preferredWidth: 2
                            }

                            // 车次卡片内容
                            TrainCard {
                                Layout.fillWidth: true
                                trainData: modelData
                            }

                            Item{
                                Layout.preferredWidth: 10
                            }

                            // 右侧删除按钮
                            Rectangle {
                                Layout.rightMargin: 30
                                width: 30
                                height: 30
                                radius: 18
                                color: "transparent"
                                border.color: "transparent"
                                Image {
                                    source: "qrc:/resources/icon/Delete.png"
                                    anchors.centerIn: parent
                                    width: 60
                                    height: 60
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (!isTrainEditable({
                                            trainNumber: modelData.trainNumber
                                        }))
                                            return

                                        warning.onConfirmed = function() {
                                            warning.active = false
                                            deleteTrain(modelData.trainNumber);
                                        }
                                        warning.message = "确认删除该车次？"
                                        warning.source = "qrc:/qml/components/ConfirmCancelDialog.qml"
                                        warning.active = true
                                    }
                                }
                            }
                        }
                    }
                }

                // 分割线
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    Layout.rightMargin: 30
                    Layout.topMargin: 0
                    color: "#cce5ff"
                }

                // 搜索框和添加按钮区
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    Layout.bottomMargin: 20
                    spacing: 15

                    // 搜索框
                    SearchBar{
                        id: searchTrainNumber
                        inputHeight: 30
                        width: 185
                        fontSize: 14
                        placeholderText: "查找车次号"
                        onTextChanged: filterTrainList()
                    }
                    SearchBar{
                        id: searchStartStationName
                        inputHeight: 30
                        width: 185
                        fontSize: 14
                        placeholderText: "查找起始站"
                        onTextChanged: filterTrainList()
                    }
                    SearchBar{
                        id: searchEndStationName
                        inputHeight: 30
                        width: 185
                        fontSize: 14
                        placeholderText: "查找终点站"
                        onTextChanged: filterTrainList()
                    }

                    Item { Layout.fillWidth: true }

                    // 添加按钮
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
                                // 新增车次：先打开时刻表页面（新增模式）
                                timetableLoader.timetable = []
                                timetableLoader.oldTrainNumber = ""
                                timetableLoader.isAddMode = true
                                timetableLoader.onConfirmedFunction = function(info) {
                                    addNewTrain(info)
                                }
                                timetableLoader.source = "TimetableManagement.qml"
                                timetableLoader.active = true
                            }
                        }
                    }
                }
            }
        }
    }

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

    Loader {
        property string message: ""
        id: notification
        source: "qrc:/qml/components/ConfirmDialog.qml"
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
        property string oldTrainNumber: ""
        property bool isAddMode: false  // 是否为新增模式
        property var onConfirmedFunction: function() {}
        id: timetableLoader
        source: ""
        active: false
        onLoaded: {
            if (item) {
                // 连接关闭信号
                item.closed.connect(function() {
                    timetableLoader.active = false
                })
                // 连接确认信号
                item.confirmed.connect(onConfirmedFunction)
                // 初始化参数
                item.transientParent = mainWindow
                item.timetable = timetable
                item.oldTrainNumber = oldTrainNumber
                item.visible = true
            }
        }
    }

    //座位模板页面
    Loader {
        property string trainNumber: ""
        property bool isAddMode: false  // 是否为新增模式
        property var pendingTrainInfo: null  // 新增模式下，保存时刻表信息
        property var onConfirmedFunction: function() {}
        property var currentCarriages: []
        id: seatTemplateLoader
        source: ""
        active: false
        onLoaded: {
            if (item) {
                // 连接关闭信号
                item.closed.connect(function() {
                    seatTemplateLoader.active = false
                })
                // 连接更新成功信号
                item.confirmed.connect(onConfirmedFunction)
                // 初始化参数
                item.transientParent = mainWindow
                item.trainNumber = seatTemplateLoader.trainNumber
                item.currentCarriages = seatTemplateLoader.currentCarriages
                item.visible = true
            }
        }
    }

    function refreshTrains() {
        var savedContentY = trainListView.contentY
        rawTrainList = trainManager.getTrains_api()
        filterTrainList()
        trainListView.contentY = savedContentY
    }

    function deleteTrain(trainNumber) {
        var result = trainManager.deleteTrain_api(trainNumber)
        refreshTrains()
        notification.message = result["success"] === true ? "车次删除成功!" : "车次删除失败！"
        notification.source = "qrc:/qml/components/ConfirmDialog.qml"
        notification.active = true
    }

    function filterTrainList() {
        trainList = rawTrainList.filter(function(train) {
            return (searchTrainNumber.text === "" || (train.trainNumber && train.trainNumber.indexOf(searchTrainNumber.text) !== -1))
                && (searchStartStationName.text === "" || (train.startStationName && train.startStationName.indexOf(searchStartStationName.text) !== -1))
                && (searchEndStationName.text === "" || (train.endStationName && train.endStationName.indexOf(searchEndStationName.text) !== -1))
        });
    }

    function isPassingStationLegal(list) {
        // 长度为 <=1 不合法
        if (list.length <= 1) {
            notification.message = "起末站不完整！"
            notification.active = true;
            return false
        }
        var stationFlag = {}
        // 每一站依次判断
        for (var i = 0; i < list.length; i++) {
            var stationName = list[i].stationName
            var arriveHour = list[i].arriveHour
            var arriveMinute = list[i].arriveMinute
            var arriveDay = list[i].arriveDay
            var departureHour = list[i].departureHour
            var departureMinute = list[i].departureMinute
            var departureDay = list[i].departureDay
            // 判断站名是否缺失
            if (stationName === "") {
                notification.message = "第" + (i + 1) + "站站名缺失！"
                notification.active = true
                return false
            }
            // 判断是否重复经过某一站
            if (stationFlag[stationName]) {
                notification.message = "重复经过" + stationName + "站！"
                notification.active = true
                return false
            }
            // 记录经过了此站
            stationFlag[stationName] = true
            // 判断起始站各时间字段是否合法
            if (i == 0 && (arriveHour !== -1 || arriveMinute !== -1 || arriveDay !== -1 ||
                           departureHour === -1 || departureMinute === -1 || departureDay !== 0)) {
                notification.message = "第" + (i + 1) + "站时刻项错误！"
                notification.active = true
                return false
            }
            // 判断终点站各时间字段是否合法
            if (i == list.length - 1 && (arriveHour === -1 || arriveMinute === -1 || arriveDay === -1 ||
                           departureHour !== -1 || departureMinute !== -1 || departureDay !== -1)) {
                notification.message = "第" + (i + 1) + "站时刻项错误！"
                notification.active = true
                return false
            }
            // 判断中间站各时间字段是否合法
            if (i != 0 && i != list.length - 1 && (arriveHour === -1 || arriveMinute === -1 || arriveDay === -1 ||
                           departureHour === -1 || departureMinute === -1 || departureDay === -1)) {
                notification.message = "第" + (i + 1) + "站时刻项错误！"
                notification.active = true
                return false
            }

            // 判断中间站的到时是不是在发时的前面
            if (i != 0 && i != list.length - 1 && (arriveDay > departureDay ||
                (arriveDay === departureDay && arriveHour > departureHour) ||
                (arriveDay === departureDay && arriveHour === departureHour && arriveMinute >= departureMinute))) {
                notification.message = "第" + (i + 1) + "站到时应在发时之前！"
                notification.active = true
                return false
            }

            // 判断该站的到时是不是在上一站发时的后面
            if (i > 0 && (arriveDay < list[i - 1].departureDay ||
                (arriveDay === list[i - 1].departureDay && arriveHour < list[i - 1].departureHour) ||
                (arriveDay === list[i - 1].departureDay && arriveHour === list[i - 1].departureHour && arriveMinute <= list[i - 1].departureMinute))) {
                notification.message = "第" + (i + 1) + "站到时应在上一站发时之后！"
                notification.active = true
                return false
            }
        }
        return true
    }


    function updateTimetableAndTrainNumber(info) {
        if (!isTrainEditable({
            trainNumber: info.oldTrainNumber
        })) {
            timetableLoader.active = false
            return
        }

        if (!isPassingStationLegal(info.passingStationList)) {
            return
        }
        var result = bookingSystem.updateTimetableAndTrainNumber_api(info)
        if (!result.success) {
            notification.message = result.message
            notification.active = true
            return
        }
        notification.message = "修改成功！"
        notification.active = true
        timetableLoader.active = false
        refreshTrains()
    }

    function addNewTrain(info) {
        // 新增车次流程：先验证时刻表合法性
        if (!isPassingStationLegal(info.passingStationList)) {
            return
        }
        
        // 调用后端验证车次号和时刻表（复用修改时刻表的验证逻辑）
        var result = bookingSystem.updateTimetableAndTrainNumber_api(info)
        if (!result.success) {
            notification.message = result.message
            notification.active = true
            return
        }
        
        // 验证通过，不关闭时刻表页面，直接打开座位模板页面
        seatTemplateLoader.trainNumber = info.newTrainNumber
        seatTemplateLoader.currentCarriages = []  // 新增车次，座位模板为空
        seatTemplateLoader.isAddMode = true
        seatTemplateLoader.pendingTrainInfo = info  // 保存时刻表信息
        seatTemplateLoader.onConfirmedFunction = function(seatInfo) {
            completeAddNewTrain(info, seatInfo)
        }
        seatTemplateLoader.source = "EditSeatTemplateDialog.qml"
        seatTemplateLoader.active = true
    }

    function completeAddNewTrain(trainInfo, seatInfo) {
        // 构建座位模板数据(扁平结构,直接传递所有字段)
        var completeInfo = {
            trainNumber: trainInfo.newTrainNumber,
            carriageNum: seatInfo.carriageNum,
            firstStart: seatInfo.firstStart,
            firstEnd: seatInfo.firstEnd,
            firstRows: seatInfo.firstRows,
            firstCols: seatInfo.firstCols,
            secondStart: seatInfo.secondStart,
            secondEnd: seatInfo.secondEnd,
            secondRows: seatInfo.secondRows,
            secondCols: seatInfo.secondCols,
            businessStart: seatInfo.businessStart,
            businessEnd: seatInfo.businessEnd,
            businessRows: seatInfo.businessRows,
            businessCols: seatInfo.businessCols
        }
        
        // 调用后端更新座位模板（此时车次已经存在）
        var result = bookingSystem.updateSeatTemplate_api(completeInfo)
        if (!result.success) {
            notification.message = result.message
            notification.active = true
            return
        }
        
        notification.message = "车次添加成功！"
        notification.active = true
        seatTemplateLoader.active = false
        timetableLoader.active = false  // 关闭时刻表管理页面
        refreshTrains()
    }

    function updateSeatTemplate(trainNumber, info) {
        if (!isTrainEditable({
            trainNumber: trainNumber
        })) {
            seatTemplateLoader.active = false
            return
        }

        info.trainNumber = trainNumber
        var result = bookingSystem.updateSeatTemplate_api(info)
        // var result = bookingSystem.updateSeatTemplate_api(Object.assign({}, info, {
        //                                                     trainNumber: trainNumber
        //                                                  }))
        if (!result.success) {
            notification.message = result.message
            notification.active = true
            return
        }
        notification.message = "修改成功！"
        notification.active = true
        seatTemplateLoader.active = false
        refreshTrains()
    }

    function isTrainEditable(info) {
        var result = bookingSystem.isTrainEditable_api(info)
        if (!result.success) {
            notification.message = result.message
            notification.active = true
            return false
        }
        return true
    }
}
