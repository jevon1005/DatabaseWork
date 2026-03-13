import QtQuick 2.15
import QtQuick.Controls 2.15
import MyApp 1.0
import "../components"

// 嵌入式登录页面，不再是窗口，交由外层主窗口控制显示与销毁
Item {
    id: loginPage
    width: parent ? parent.width : 960
    height: parent ? parent.height : 720
    // width: 960
    // height: 720

    property bool isAdminLogin: false
    signal loginSuccess(string role)
    
    // 错误提示信息
    property string errorMessage: ""

    Rectangle {
        anchors.fill: parent
        color: "#f8f8f8"
        Image {
            anchors.fill: parent
            source: "qrc:/images/resources/images/logbackground.png"
            fillMode: Image.PreserveAspectCrop
            opacity: 0.15
        }
        Rectangle { anchors.fill: parent; color: "#ffffff"; opacity: 0.1 }

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            spacing: 24
            Text {
                text: "欢迎登录"
                font.pixelSize: 38
                color: "#1a252f"
                font.bold: true
                font.family: "Microsoft YaHei"
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
                style: Text.Raised
                styleColor: "#ffffff"
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20
                Text {
                    id: userLoginText
                    text: "用户登录"
                    color: {
                        if (userLoginMouseArea.containsMouse && isAdminLogin) return "#2c3e50"
                        return isAdminLogin ? "#7f8c8d" : "#3498db"
                    }
                    font.pixelSize: 16
                    font.family: "Microsoft YaHei"
                    font.weight: isAdminLogin ? Font.Normal : Font.Medium
                    MouseArea { id: userLoginMouseArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true; onClicked: isAdminLogin = false }
                }
                Rectangle { width: 1; height: 18; color: "#bdc3c7"; anchors.verticalCenter: parent.verticalCenter }
                Text {
                    id: adminLoginText
                    text: "管理员登录"
                    color: {
                        if (adminLoginMouseArea.containsMouse && !isAdminLogin) return "#2c3e50"
                        return isAdminLogin ? "#3498db" : "#7f8c8d"
                    }
                    font.pixelSize: 16
                    font.family: "Microsoft YaHei"
                    font.weight: isAdminLogin ? Font.Medium : Font.Normal
                    MouseArea { id: adminLoginMouseArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true; onClicked: isAdminLogin = true }
                }
            }

            Column {
                spacing: 10
                // 用户名
                Rectangle {
                    width: 380; height: 58; radius: 10; color: "#ffffff"; border.color: "#d5d5d5"; border.width: 1
                    Rectangle { anchors.fill: parent; anchors.topMargin: 2; radius: 10; color: "#f5f5f5"; opacity: 0.3; z: -1 }
                    Row {
                        anchors.fill: parent; anchors.margins: 16; spacing: 12
                        Text { text: isAdminLogin ? "管理员" : "用户"; anchors.verticalCenter: parent.verticalCenter; color: "#5a6c7d"; font.pixelSize: 16; font.family: "Microsoft YaHei"; width: isAdminLogin ? 56 : 40; horizontalAlignment: Text.AlignRight }
                        Rectangle { width: 1; height: 24; color: "#e0e6ed"; anchors.verticalCenter: parent.verticalCenter }
                        TextField { 
                            id: username
                            anchors.verticalCenter: parent.verticalCenter
                            width: isAdminLogin ? 240 : 256
                            font.pixelSize: 16
                            font.family: "Microsoft YaHei"
                            color: "#2c3e50"
                            placeholderText: isAdminLogin ? "请输入管理员账号" : "请输入用户账号"
                            placeholderTextColor: "#95a5a6"
                            background: null
                            selectByMouse: true
                            Keys.onTabPressed: password.forceActiveFocus()
                            Keys.onReturnPressed: login()
                        }
                    }
                }
                // 密码
                Rectangle {
                    width: 380; height: 58; radius: 10; color: "#ffffff"; border.color: "#d5d5d5"; border.width: 1
                    Rectangle { anchors.fill: parent; anchors.topMargin: 2; radius: 10; color: "#f5f5f5"; opacity: 0.3; z: -1 }
                    Row {
                        anchors.fill: parent; anchors.margins: 16; spacing: 12
                        Text { text: "密码"; anchors.verticalCenter: parent.verticalCenter; color: "#5a6c7d"; font.pixelSize: 16; font.family: "Microsoft YaHei"; width: 40; horizontalAlignment: Text.AlignRight }
                        Rectangle { width: 1; height: 24; color: "#e0e6ed"; anchors.verticalCenter: parent.verticalCenter }
                        TextField { 
                            id: password
                            anchors.verticalCenter: parent.verticalCenter
                            width: 256
                            font.pixelSize: 16
                            font.family: "Microsoft YaHei"
                            color: "#2c3e50"
                            placeholderText: "请输入登录密码"
                            placeholderTextColor: "#95a5a6"
                            echoMode: TextInput.Password
                            background: null
                            selectByMouse: true
                            Keys.onTabPressed: username.forceActiveFocus()
                            Keys.onReturnPressed: login()
                        }
                    }
                }
            }

            // 登录按钮
            Rectangle {
                id: loginButton
                width: 380; height: 54; radius: 10; color: "#409CFC"
                Rectangle { anchors.fill: parent; anchors.topMargin: 3; radius: 10; color: "#1c5a85"; opacity: 0.4; z: -1 }
                Text { text: "登录"; color: "white"; font.pixelSize: 18; font.family: "Microsoft YaHei"; font.weight: Font.Medium; anchors.centerIn: parent }
                MouseArea {
                    anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onEntered: loginButton.color = "#1f5f99"
                    onExited: loginButton.color = "#409CFC"
                    onPressed: loginButton.color = "#174a73"
                    onReleased: loginButton.color = "#1f5f99"
                    onClicked: login()
                }
            }

            // 注册按钮（仅普通用户）
            Rectangle {
                id: registerButton
                width: 380; height: 54; radius: 10; color: "#ffffff"; border.color: "#c5c5c5"; border.width: 1.5; visible: !isAdminLogin
                Rectangle { anchors.fill: parent; anchors.topMargin: 2; radius: 10; color: "#e8e8e8"; opacity: 0.3; z: -1 }
                Text { text: "注册"; color: "#4a4a4a"; font.pixelSize: 18; font.family: "Microsoft YaHei"; font.weight: Font.Medium; anchors.centerIn: parent }
                MouseArea {
                    anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onEntered: { registerButton.color = "#f8f8f8"; registerButton.border.color = "#aaa" }
                    onExited: { registerButton.color = "#ffffff"; registerButton.border.color = "#c5c5c5" }
                    onPressed: { registerButton.color = "#e8e8e8"; registerButton.border.color = "#999" }
                    onReleased: { registerButton.color = "#f8f8f8"; registerButton.border.color = "#aaa" }
                    onClicked: {
                        registerDialog.source = "qrc:/qml/pages/RegisterDialog.qml"
                        registerDialog.onConfirmedFunction = function(info) {
                            register(info)
                        }

                        registerDialog.active = true
                    }
                }
            }
        }
    }
    

    Component.onCompleted: {
        username.forceActiveFocus()
    }

    //警告
    Loader {
        id: warning 
        source: ""
        active: false
        onLoaded: {
            if (item) {
                // 连接关闭信号
                item.closed.connect(function() {
                    warning.active = false
                })
                // 初始化参数
                item.contentText = errorMessage
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

    Loader {
        property var onConfirmedFunction: function() {}
        id: registerDialog
        source: ""
        active: false
        onLoaded: {
            if (item) {
                // 连接取消信号
                item.canceled.connect(function() {
                    registerDialog.active = false
                })
                // 连接确认信号
                item.confirmed.connect(onConfirmedFunction)
                // 初始化参数
                item.visible = true
            }
        }
    }

    function login() {
        errorMessage = "" // 清空之前的错误

        var result
        if (isAdminLogin) {
            result = accountManager.loginAdmin_api(username.text, password.text)
        } else {
            result = accountManager.loginUser_api(username.text, password.text)
        }

        if (result.success) {
            loginSuccess(isAdminLogin ? "admin" : "user")
            SessionState.role = isAdminLogin ? "admin" : "user"
            SessionState.username = username.text
        } else {
            errorMessage = result.message
            warning.source = "qrc:/qml/components/ConfirmDialog.qml"
            warning.active = true
        }
    }

    function register(info) {
        var username = info.username
        var password = info.password
        var passwordAgain = info.passwordAgain
        var name = info.name
        var phoneNumber = info.phoneNumber
        var id = info.id

        if (username === "") {
            notification.message = "用户名不能为空！"
            notification.source = "qrc:/qml/components/ConfirmDialog.qml"
            notification.active = true
            return
        }
        var firstChar = username.charCodeAt(0)
        if (!((firstChar >= 65 && firstChar <= 90) || (firstChar >= 97 && firstChar <= 122))) {
            notification.message = "用户名必须以字母开头！"
            notification.source = "qrc:/qml/components/ConfirmDialog.qml"
            notification.active = true
            return
        }
        if (password === "") {
            notification.message = "密码不能为空！"
            notification.source = "qrc:/qml/components/ConfirmDialog.qml"
            notification.active = true
            return
        }
        if (password !== passwordAgain) {
            notification.message = "两次输入密码不一致！"
            notification.source = "qrc:/qml/components/ConfirmDialog.qml"
            notification.active = true
            return
        }
        if (name === "") {
            notification.message = "姓名不能为空！"
            notification.source = "qrc:/qml/components/ConfirmDialog.qml"
            notification.active = true
            return
        }
        if (phoneNumber === "") {
            notification.message = "联系方式不能为空！"
            notification.source = "qrc:/qml/components/ConfirmDialog.qml"
            notification.active = true
            return
        }
        if (phoneNumber.length !== 11) {
            notification.message = "联系方式不合法！"
            notification.source = "qrc:/qml/components/ConfirmDialog.qml"
            notification.active = true
            return
        }
        if (id === "") {
            notification.message = "身份证号不能为空！"
            notification.source = "qrc:/qml/components/ConfirmDialog.qml"
            notification.active = true
            return
        }
        if (id.length !== 18 || !(id.indexOf('x') === -1 || id.indexOf('x') === id.length - 1)) {
            notification.message = "身份证号不合法！"
            notification.source = "qrc:/qml/components/ConfirmDialog.qml"
            notification.active = true
            return
        }

        var result = accountManager.registerUser_api(info)
        if (result.success) {
            notification.message = result.message
            notification.source = "qrc:/qml/components/ConfirmDialog.qml"
            notification.active = true
            registerDialog.active = false
        }
        else {
            notification.message = result.message
            notification.source = "qrc:/qml/components/ConfirmDialog.qml"
            notification.active = true
        }
    }
}
