import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

Rectangle {
    color:"#fff"
    id: root
    width: 190
    height: 720
    property string role: "user"          // "user" / "admin" / "passenger" 等
    property string currentUrl: ""        // 由外部 StackView 设置
    signal navigate(string pageUrl)

    property var menuList: []
    property var profileItem: ({ text: "个人中心", icon: "qrc:/resources/icon/Profile.png", url: "qrc:/qml/pages/Profile.qml" })

    function updateProfileItem() {
        if (role === "admin") {
            profileItem = { text: "账户管理",icon: "qrc:/resources/icon/Profile.png",  url: "qrc:/qml/pages/AccountManagement.qml"  }
        } else {
            profileItem = { text: "个人中心", icon: "qrc:/resources/icon/Profile.png", url: "qrc:/qml/pages/Profile.qml" }
        }
    }

    onRoleChanged: {
        rebuildMenus()
        updateProfileItem()
    }
    Component.onCompleted: {
        rebuildMenus()
        updateProfileItem()
    }

    function rebuildMenus() {
        if (role === "admin") {
            menuList = [
                { text: "车次管理", icon: "qrc:/resources/icon/TrainManagement.png", url: "qrc:/qml/pages/TrainManagement.qml" },
                { text: "订单管理", icon: "qrc:/resources/icon/OrderManagement.png", url: "qrc:/qml/pages/OrderManagement.qml" },
                { text: "账户管理", icon: "qrc:/resources/icon/UserManagement.png", url: "qrc:/qml/pages/UserManagement.qml" }
            ]
        } else {
            // 普通用户或乘车人共用前三项
            menuList = [
                { text: "车票查询",   icon: "qrc:/resources/icon/TicketQuery.png",       url: "qrc:/qml/pages/TicketQuery.qml" },
                { text: "乘车人信息", icon: "qrc:/resources/icon/OrderManagement.png",   url: "qrc:/qml/pages/PassengerInfo.qml" },
                { text: "我的订单",   icon: "qrc:/resources/icon/MyOrders.png",          url: "qrc:/qml/pages/MyOrders.qml" }
            ]
        }
        // 检查 currentUrl 是否仍有效
        var all = menuList.map(m => m.url)
        if (role === "user") all.push(profileItem.url)
        if (currentUrl.length && all.indexOf(currentUrl) === -1) {
            currentUrl = menuList.length ? menuList[0].url : ""
            if (currentUrl) navigate(currentUrl)
        }
    }

    function isSelected(u) { return currentUrl === u }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 16

        Repeater {
            model: menuList
            delegate: MenuButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                text: modelData.text
                fontSize: 20
                iconSource: modelData.icon
                selected: isSelected(modelData.url)
                onClicked: {
                    if (!selected) {
                        root.currentUrl = modelData.url
                        root.navigate(modelData.url)
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 2
            color: "#CCE5FF"
        }

        MenuButton {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            Layout.leftMargin: 10
            Layout.rightMargin: 15
            Layout.bottomMargin: 15
            text: profileItem.text
            iconSource: profileItem.icon
            selected: isSelected(profileItem.url)
            onClicked: {
                if (!selected) {
                    root.currentUrl = profileItem.url
                    root.navigate(profileItem.url)
                }
            }
        }
    }

    Rectangle {
        width: 2
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.topMargin: 20
        anchors.bottomMargin: 20
        color: "#cccccc"
    }
}
