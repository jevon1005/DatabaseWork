import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls
import "../components"

Page {
    id:ticketQueryPage
    property var mainWindow
    objectName: "qrc:/qml/pages/TicketQuery.qml"
    width: parent ? parent.width : 1040
    height: parent ? parent.height : 640
    // width: 1040
    // height: 640
    visible: true

    // 定义页面数据
    property alias page: pageData
    QtObject {
        id: pageData
        property string fromCity: "北京"
        property string toCity: "上海"
        property string currentDate: "" // 今天
        property string selectedDate: "" // 用户选中的日期
        property var cityList: []
        property var queryHistory: bookingSystem.queryHistory
    }

    //获取当前页面信息
    Component.onCompleted: {
        pageData.currentDate = Qt.formatDate(new Date(), "yyyy年MM月dd日")
        pageData.selectedDate = pageData.currentDate   // 默认选中今天
        pageData.cityList = stationManager.getCitiesName_api()
        pageData.fromCity = "北京"                            //在此处初始化fromCity和toCity避免获取cityList时覆盖
        pageData.toCity = "上海"
        console.log("fromCity:", pageData.fromCity, "toCity:", pageData.toCity)
        console.log("currentIndex", pageData.cityList.indexOf(pageData.fromCity))
    }

    RowLayout {
        anchors.fill: parent
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: false   // 保证弹出菜单不被裁剪

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: 110
                anchors.rightMargin: 130
                spacing: 32

                Item {
                    Layout.fillHeight: true
                }

                RowLayout {
                    SearchableComboBox {
                        id: fromCombo
                        model: pageData.cityList
                        currentIndex: pageData.cityList.indexOf(page.fromCity)
                        onCurrentIndexChanged: page.fromCity = pageData.cityList[currentIndex]
                        Layout.preferredWidth: 160
                        Layout.preferredHeight: 80
                        font.pixelSize: 48

                        indicator: Item {} // 隐藏右侧箭头

                        background: Rectangle {
                            color: fromCombo.hovered ? "#f5faff" : "transparent"         // 悬停时更浅的蓝白色
                            border.color: fromCombo.hovered ? "#b3dfff" : "transparent"  // 悬停时更浅的边框色
                            border.width: fromCombo.hovered ? 2 : 0
                            radius: 6
                        }

                        contentItem: MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: fromCombo.popup.open() // 点击弹出菜单

                            Text {
                                anchors.fill: parent
                                text: parent.parent.displayText
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                color: "#222"
                                font.pixelSize: 48
                            }
                        }

                    }

                    Item { Layout.fillWidth: true }

                    Image {
                        source: "qrc:/resources/icon/TrainIcon.png"
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 100

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                // 交换始发地和目的地
                                var tmp = page.fromCity
                                page.fromCity = page.toCity
                                page.toCity = tmp

                                // 同步 ComboBox 选中项
                                fromCombo.currentIndex = pageData.cityList.indexOf(page.fromCity)
                                toCombo.currentIndex = pageData.cityList.indexOf(page.toCity)
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // 目的地选择
                    SearchableComboBox {
                        id: toCombo
                        model: pageData.cityList
                        currentIndex: pageData.cityList.indexOf(page.toCity)
                        onCurrentIndexChanged: page.toCity = pageData.cityList[currentIndex]
                        Layout.preferredWidth: 160
                        Layout.preferredHeight: 80
                        font.pixelSize: 48

                        indicator: Item {} // 隐藏右侧箭头

                        background: Rectangle {
                            color: toCombo.hovered ? "#f5faff" : "transparent"         // 悬停时更浅的蓝白色
                            border.color: toCombo.hovered ? "#b3dfff" : "transparent"  // 悬停时更浅的边框色
                            border.width: toCombo.hovered ? 2 : 0
                            radius: 6
                        }

                        contentItem: MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: toCombo.popup.open() // 点击弹出菜单

                            Text {
                                anchors.fill: parent
                                text: parent.parent.displayText
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignRight
                                color: "#222"
                                font.pixelSize: 48
                            }
                        }

                    }
                }

                // 分割线
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 2
                    Layout.topMargin: -60
                    color: "#e6e6e6"
                }

                // 日期显示
                RowLayout {
                    Layout.topMargin: -60

                    // 日期文本
                    Text {
                        id: dateText
                        text: page.selectedDate
                        font.pixelSize: 25
                        color: "#222"
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: calendarDialog.open()
                        }
                    }

                    Item{
                        Layout.preferredWidth: 20
                    }

                    Text {
                        Layout.leftMargin: 50
                        text: getDateLabel(page.selectedDate)
                        font.pixelSize: 25
                        color: "#656565"
                    }

                }

                // 按钮
                CustomButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 72
                    Layout.topMargin: -20
                    text: "查询车票"
                    textColor: "white"
                    fontSize: 30
                    customColor: "#3B99FB"
                    onClicked: function(){
                        bookingSystem.addQueryHistory_api(pageData.fromCity, pageData.toCity)
                        ticketResultLoader.source = "qrc:/qml/pages/TicketQueryResult.qml"
                        ticketResultLoader.active = true
                    }
                }

                // 历史记录
                RowLayout {
                    Layout.topMargin: -10

                    Text {
                        visible: pageData.queryHistory.length >= 1
                        text: pageData.queryHistory.length >= 1
                            ? pageData.queryHistory[0].startCity + "--" + pageData.queryHistory[0].endCity
                            : ""
                        font.pixelSize: 18
                        color: "#ACACAC"
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: function() {
                                pageData.fromCity = pageData.queryHistory[0].startCity
                                pageData.toCity = pageData.queryHistory[0].endCity
                                fromCombo.currentIndex = pageData.cityList.indexOf(page.fromCity)
                                toCombo.currentIndex = pageData.cityList.indexOf(page.toCity)
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        visible: pageData.queryHistory.length >= 2
                        text: pageData.queryHistory.length >= 2
                            ? pageData.queryHistory[1].startCity + "--" + pageData.queryHistory[1].endCity
                            : ""
                        font.pixelSize: 18
                        color: "#ACACAC"
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: function() {
                                pageData.fromCity = pageData.queryHistory[1].startCity
                                pageData.toCity = pageData.queryHistory[1].endCity
                                fromCombo.currentIndex = pageData.cityList.indexOf(page.fromCity)
                                toCombo.currentIndex = pageData.cityList.indexOf(page.toCity)
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        visible: pageData.queryHistory.length >= 3
                        text: pageData.queryHistory.length >= 3
                            ? pageData.queryHistory[2].startCity + "--" + pageData.queryHistory[2].endCity
                            : ""
                        font.pixelSize: 18
                        color: "#ACACAC"
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: function() {
                                pageData.fromCity = pageData.queryHistory[2].startCity
                                pageData.toCity = pageData.queryHistory[2].endCity
                                fromCombo.currentIndex = pageData.cityList.indexOf(page.fromCity)
                                toCombo.currentIndex = pageData.cityList.indexOf(page.toCity)
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "清除历史"
                        font.pixelSize: 18
                        color: "#ACACAC"
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: bookingSystem.clearQueryHistory_api()
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
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
        x: (ticketQueryPage.width - width) / 2
        y: (ticketQueryPage.height - height) / 2

        MyCalendar {
            id: myCalendar
            anchors.fill: parent
            Connections {
                target: myCalendar
                function onSelectedDateChanged() {
                    page.selectedDate = Qt.formatDate(myCalendar.selectedDate, "yyyy年MM月dd日")
                    // console.log("选中日期：", myCalendar.selectedDate)
                    calendarDialog.close()
                }
            }
        }
    }

    Loader {
        id: ticketResultLoader
        source: ""
        active: false
        onLoaded: {
            if (item) {
                // 连接关闭信号
                item.closed.connect(function() {
                    // console.log("!!!!!!!!!!!!!!!!!!!!")
                    ticketResultLoader.active = false
                })
                // 初始化参数
                item.resultData.fromCity = pageData.fromCity
                item.resultData.toCity = pageData.toCity
                item.resultData.date = pageData.selectedDate
                item.resultData.selectedDate = pageData.selectedDate
                item.transientParent = mainWindow
                item.queryTickets()
                item.rawTicketList = item.ticketList
                item.visible = true
                console.log("fromCity:", item.resultData.fromCity, "toCity:", item.resultData.toCity, "date:", item.resultData.date)
            }
        }
    }

    //回车默认查询
    Shortcut {
        sequence: "Return"
        onActivated: {
            bookingSystem.addQueryHistory_api(pageData.fromCity, pageData.toCity)
            ticketResultLoader.source = "qrc:/qml/pages/TicketQueryResult.qml"
            ticketResultLoader.active = true
        }
    }


    function parseChineseDate(str) {
        var m = str.match(/^(\d{4})年(\d{1,2})月(\d{1,2})日$/)
        if (!m) return null
        return new Date(Number(m[1]), Number(m[2]) - 1, Number(m[3]))
    }

    function getDateLabel(selectedDateStr) {
        if (!selectedDateStr || selectedDateStr === "") return "111"
        var selected = parseChineseDate(selectedDateStr)
        if (!selected || isNaN(selected.getTime())) return ""
        var today = parseChineseDate(page.currentDate)
        var todayYMD = new Date(today.getFullYear(), today.getMonth(), today.getDate())
        var selectedYMD = new Date(selected.getFullYear(), selected.getMonth(), selected.getDate())
        var diff = Math.round((selectedYMD - todayYMD) / (24 * 3600 * 1000))
        if (diff === 0) return "今天"
        if (diff === 1) return "明天"
        if (diff === 2) return "后天"
        var weekNames = ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"]
        return weekNames[selectedYMD.getDay()]
    }

}
