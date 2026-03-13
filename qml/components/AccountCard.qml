import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    width: parent ? parent.width : 690
    height: parent ? parent.height : 70
    // width: 800
    // height: 70

    property var accountData: ({
        type: "admin",
        username: "2507154692929292",
        password: "thisisapassword123456",
        isLocked: true,
    })

    // 用户卡片
    Rectangle {
        id: card
        width: parent.width
        height: 79
        radius: 16
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#cce5ff" }
            GradientStop { position: 1.0; color: "#8ec9ff" }
        }

        //卡片区
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 40
            spacing: 15

            // 左侧信息
            ColumnLayout {
                spacing: 0

                // 第一行
                RowLayout {
                    Layout.topMargin: 12
                    Text {
                        text: "用户名：" + accountData.username
                        font.pixelSize: 18
                        color: "#222"
                    }
                }

                // 间隔
                Item { Layout.fillHeight: true }

                // 第二行
                RowLayout {
                    Layout.bottomMargin: 12
                    Text {
                        text: "密码：" + accountData.password
                        font.pixelSize: 18
                        color: "#222"
                    }
                }
            }

            Item{
                Layout.fillWidth: true
            }

            Rectangle{
                width: 70
                height: 30
                radius: 4
                border.color: "#CC6600"
                color: "transparent"
                visible: accountData.isLocked
                Text {
                    text: "已锁定"
                    font.pixelSize: 16
                    color: "#CC6600"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle{
                width: 70
                height: 30
                radius: 4
                border.color: "green"
                color: "transparent"
                visible: accountData.type === "admin"   // 只在 isAdmin 为 true 时显示
                Text {
                    text: "管理员"
                    font.pixelSize: 16
                    color: "green"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
