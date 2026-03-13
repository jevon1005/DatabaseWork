import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"
import MyApp 1.0

Page {
    id: passengerInfoPage
    property var mainWindow
    objectName:"qrc:/qml/pages/PassengerInfo.qml"
    width: parent ? parent.width :640
    height: parent ? parent.height : 400

    property var rawPassengerList: []
    property var passengerList: []

    Component.onCompleted: {
        refreshPassengers()
    }

    // 主内容区
    Rectangle {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 20

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: passengerInfoPage.height - 70
                Layout.alignment: Qt.AlignTop

                // 滚动卡片区
                ListView {
                    id: passengerListView
                    model: passengerList
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
                        width: passengerListView.width - 15

                        // 卡片列表
                        RowLayout{
                            Layout.fillWidth: true
                            // 删除按钮
                            Rectangle {
                                Layout.rightMargin: 15
                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 30
                                radius: 18
                                border.color: "transparent"
                                MouseArea {
                                    id: mouseAreaDelete
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        // 先判断能否删除（即有没有待乘坐订单）
                                        var result = bookingSystem.isPassengerEditable_api({
                                            username: modelData.username,
                                            passengerId: modelData.id
                                        })
                                        if (!result.success) {
                                            warning.onConfirmed = function() {
                                                warning.active = false
                                            }
                                            warning.message = result.message
                                            warning.source = "qrc:/qml/components/ConfirmCancelDialog.qml"
                                            warning.active = true;
                                        }
                                        else {
                                            warning.onConfirmed = function() {
                                                warning.active = false
                                                deletePassenger(SessionState.username, modelData.id)
                                            }
                                            warning.message = "确认删除该乘车人？"
                                            warning.source = "qrc:/qml/components/ConfirmCancelDialog.qml"
                                            warning.active = true
                                        }
                                    }
                                }
                                Image {
                                    source: "qrc:/resources/icon/Delete.png"
                                    anchors.centerIn: parent
                                    width: 70
                                    height: 70
                                }
                            }

                            PassengerCard {
                                Layout.fillWidth: true
                                passengerData: modelData
                            }
                            // 编辑按钮
                            Rectangle {
                                Layout.preferredWidth: 60
                                Layout.preferredHeight: 60
                                radius: 16
                                color: "#fff"
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        // 先判断能否修改（即有没有待乘坐订单）
                                        var result = bookingSystem.isPassengerEditable_api({
                                            username: modelData.username,
                                            passengerId: modelData.id
                                        })
                                        if (!result.success) {
                                            warning.onConfirmed = function() {
                                                warning.active = false
                                            }
                                            warning.message = result.message
                                            warning.source = "qrc:/qml/components/ConfirmCancelDialog.qml"
                                            warning.active = true;
                                        }
                                        else {
                                            editPassengerInfoDialog.initialName = modelData.name
                                            editPassengerInfoDialog.initialPhoneNumber = modelData.phoneNumber
                                            editPassengerInfoDialog.initialId = modelData.id
                                            editPassengerInfoDialog.initialType = modelData.type
                                            editPassengerInfoDialog.onConfirmed = function(name, phoneNumber, id, type) {
                                                editPassengerInfo(modelData.id, name, phoneNumber, id, type)
                                            }

                                            editPassengerInfoDialog.source = "qrc:/qml/pages/EditPassengerInfoDialog.qml"
                                            editPassengerInfoDialog.active = true
                                        }
                                    }
                                }
                                Image {
                                    anchors.centerIn: parent
                                    source: "qrc:/resources/icon/Edit.png"
                                    width: 60
                                    height: 60
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
                Layout.topMargin: -20
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
                    id: searchName
                    inputHeight: 30
                    width: 185
                    fontSize: 14
                    placeholderText: "查找姓名"
                    onTextChanged: filterPassengerList()
                }
                SearchBar{
                    id: searchPhoneNumber
                    inputHeight: 30
                    width: 185
                    fontSize: 14
                    placeholderText: "查找联系方式"
                    onTextChanged: filterPassengerList()
                }
                SearchBar{
                    id: searchId
                    inputHeight: 30
                    width: 185
                    fontSize: 14
                    placeholderText: "查找身份证号"
                    onTextChanged: filterPassengerList()
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
                            editPassengerInfoDialog.onConfirmed = function(name, phoneNumber, id, type) {
                                addPassengerInfo(name, phoneNumber, id, type)
                            }
                            editPassengerInfoDialog.source = "qrc:/qml/pages/EditPassengerInfoDialog.qml"
                            editPassengerInfoDialog.active = true
                        }
                    }
                }
            }
       }
    }

    Loader {
        property string message: ""
        property var onConfirmed: function() {}
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


    // 修改
    Loader {
        property string initialName: ""
        property string initialPhoneNumber: ""
        property string initialId: ""
        property string initialType: ""
        property var onConfirmed: null
        id: editPassengerInfoDialog
        source: ""
        active: false
        onLoaded: {
            if (item) {
                // 连接取消信号
                item.canceled.connect(function() {
                    editPassengerInfoDialog.active = false
                })
                // 连接确认信号
                item.confirmed.connect(onConfirmed)
                //初始化参数
                item.initialName = initialName
                item.initialPhoneNumber = initialPhoneNumber
                item.initialId = initialId
                item.initialType = initialType
                item.visible = true
            }
        }
    }


    function refreshPassengers() {
        var savedContentY = passengerListView.contentY
        rawPassengerList = passengerManager.getPassengersByUsername_api(SessionState.username)
        filterPassengerList()
        passengerListView.contentY = savedContentY
    }

    function deletePassenger(username, id) {
        passengerManager.deletePassengerByUsernameAndId_api(username, id)
        refreshPassengers(username)
        notification.message = "乘车人删除成功！"
        notification.source = "qrc:/qml/components/ConfirmDialog.qml"
        notification.active = true
    }

    function filterPassengerList() {
        passengerList = rawPassengerList.filter(function(passenger) {
            return (searchName.text === "" || (passenger.name && passenger.name.indexOf(searchName.text) !== -1))
                && (searchPhoneNumber.text === "" || (passenger.phoneNumber && passenger.phoneNumber.indexOf(searchPhoneNumber.text) !== -1))
                && (searchId.text === "" || (passenger.id && passenger.id.indexOf(searchId.text) !== -1))
        });
    }

    function isPassengerInfoLegal(name, phoneNumber, id, type) {
        if (name === "") {
            notification.message = "姓名不能为空！"
            notification.source = "qrc:/qml/components/ConfirmDialog.qml"
            notification.active = true
            return false
        }
        if (phoneNumber === "") {
            notification.message = "联系方式不能为空！"
            notification.source = "qrc:/qml/components/ConfirmDialog.qml"
            notification.active = true
            return false
        }
        if (phoneNumber.length !== 11) {
            notification.message = "联系方式不合法！"
            notification.source = "qrc:/qml/components/ConfirmDialog.qml"
            notification.active = true
            return false
        }
        if (id === "") {
            notification.message = "身份证号不能为空！"
            notification.source = "qrc:/qml/components/ConfirmDialog.qml"
            notification.active = true
            return false
        }
        if (id.length !== 18 || !(id.indexOf('x') === -1 || id.indexOf('x') === id.length - 1)) {
            notification.message = "身份证号不合法！"
            notification.source = "qrc:/qml/components/ConfirmDialog.qml"
            notification.active = true
            return false
        }
        if (type === "") {
            notification.message = "优惠类型不能为空！"
            notification.source = "qrc:/qml/components/ConfirmDialog.qml"
            notification.active = true
            return false
        }
        return true
    }

    function editPassengerInfo(id_old, name, phoneNumber, id_new, type) {
        if (!isPassengerInfoLegal(name, phoneNumber, id_new, type))
            return

        var result = passengerManager.editPassenger_api(SessionState.username, id_old, name, phoneNumber, id_new, type)
        if (result.success) {
            notification.message = result.message
            notification.source = "qrc:/qml/components/ConfirmDialog.qml"
            notification.active = true
            editPassengerInfoDialog.active = false
            refreshPassengers()
        }
        else {
            notification.message = result.message
            notification.source = "qrc:/qml/components/ConfirmDialog.qml"
            notification.active = true
        }
    }

    function addPassengerInfo(name, phoneNumber, id, type) {
        if (!isPassengerInfoLegal(name, phoneNumber, id, type))
            return

        var result = passengerManager.addPassenger_api({
            username: SessionState.username,
            name: name,
            phoneNumber: phoneNumber,
            id: id,
            type: type
        })
        if (result.success) {
            notification.message = result.message
            notification.source = "qrc:/qml/components/ConfirmDialog.qml"
            notification.active = true
            editPassengerInfoDialog.active = false
            refreshPassengers()
        }
        else {
            notification.message = result.message
            notification.source = "qrc:/qml/components/ConfirmDialog.qml"
            notification.active = true
        }
    }
}
