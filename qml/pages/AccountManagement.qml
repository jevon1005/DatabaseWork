import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"
import MyApp 1.0

Page{
    width: parent ? parent.width : 1080
    height: parent ? parent.height : 720
    id: accountPage
    objectName: "qrc:/qml/pages/AccountManager.qml"
    visible: true
    property var mainWindow

    Rectangle{
        anchors.fill: parent

        Item {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 150
            anchors.topMargin: 30
            anchors.bottomMargin: 86

            ColumnLayout {
                width: parent.width
                spacing: 20

                // 账号管理标题
                Text {
                    text: "账号管理"
                    font.pixelSize: 35
                    font.bold: true
                    color: "#007FFF"
                }

                // 按钮区
                Column {
                    CustomButton{
                        width: 100
                        height: 35
                        fontSize: 16
                        text: "退出登录"
                        onClicked: {
                            warning.onConfirmedFunction = function() {               // 退出登录逻辑
                                warning.active = false
                                //清空参数
                                SessionState.clear()
                                // 清空主内容区
                                console.log("mainWindow:", mainWindow)
                                console.log("mainWindow.stackView:", mainWindow.stackView)
                                if (mainWindow && mainWindow.stackView) {
                                    mainWindow.stackView.clear()
                                    console.log("mainWindow.stackView cleared")

                                }
                                console.log("已退出登录")
                                console.log("appWin.loggedIn:", appWin.loggedIn)
                                console.log("SessionState.isLoggedIn:", SessionState.isLoggedIn)
                            }
                            warning.message = "确认退出登录？"
                            warning.source = "qrc:/qml/components/ConfirmCancelDialog.qml"
                            warning.active = true
                        }
                    }
                }
            }
        }
    }

    // 警告
    Loader {
        property string message: ""
        property var onConfirmedFunction: function() {}
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
                item.confirmed.connect(warning.onConfirmedFunction)
                // 初始化参数
                item.contentText = warning.message
                item.visible = true
            }
        }
    }
}
