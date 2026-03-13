import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts
import "../qml/components"
import MyApp 1.0

ApplicationWindow {
    id: appWin
    width: 1040
    height: 640
    visible: true
    title: "高铁订票系统"

    property string startPage: (SessionState.role === "admin") ?
                                   "qrc:/qml/pages/TrainManagement.qml" :
                                   "qrc:/qml/pages/TicketQuery.qml"
    property bool loggedIn: SessionState.isLoggedIn

    // 定义属性
    property var stackView

    // 主内容区：始终占满，内部根据登录状态显示侧边栏与内容
    RowLayout {
        id: contentRow
        anchors.fill: parent
        spacing: 0
        visible: loggedIn

        SideBar {
            id: sideBar
            role: SessionState.role
            Layout.fillHeight: true
            onNavigate: function(pageUrl) {
                if (stackView.currentItem && stackView.currentItem.objectName === pageUrl)
                    return
                stackView.clear()
                stackView.push(Qt.resolvedUrl(pageUrl), { mainWindow: appWin })
            }
            // 固定宽度由组件内部 width 决定，不再伸展
        }

        StackView {
            id: mainStackView
            Layout.fillWidth: true
            Layout.fillHeight: true
            onCurrentItemChanged: {
                if (currentItem && currentItem.objectName)
                    sideBar.currentUrl = currentItem.objectName
            }
        }
    }

    // 登录层：覆盖显示，登录成功后隐藏
    Loader {
        id: loginLoader
        anchors.fill: parent
        active: !loggedIn
        source: "qrc:/qml/pages/Login.qml"
        z: 10
        onLoaded: {
            if (item) {
                item.loginSuccess.connect(function() {
                    SessionState.isLoggedIn = true
                    // appWin.loggedIn = true
                    stackViewLoadTimer.restart()
                })
            }
        }
    }

    // 如果根组件加载完成后已经是登录状态，则直接渲染主界面（仅方便以后做自动登录，目前没用处）
    Component.onCompleted: {
        if (loggedIn) loadStartPage()
        SessionState.isLoggedInChanged.connect(function() {
        appWin.loggedIn = SessionState.isLoggedIn
        console.log("appWin loggedIn changed:", appWin.loggedIn)
        })
        appWin.stackView = mainStackView
    }

    // 若以后支持切换账号（改变 userRole），可调用此函数
    function loadStartPage() {
        if (!loggedIn) return
        try {
            stackView.clear()
            stackView.push(Qt.resolvedUrl(startPage), { mainWindow: appWin })
            sideBar.currentUrl = startPage
            console.log("Successfully loaded start page:", startPage)
        } catch (error) {
            console.error("Exception during start page loading:", error)
        }
    }

    Timer {
        id: stackViewLoadTimer
        interval: 50; repeat: false
        onTriggered: loadStartPage()
    }
}
