import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: splashWindow
    width: 600
    height: 400
    title: "高铁订票系统"
    visible: true
    flags: Qt.FramelessWindowHint
    color: "#f0f0f0"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        Image {
            id: logo
            source: "qrc:/images/logbackground.png"
            width: 200
            height: 200
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "高铁订票系统"
            font.pixelSize: 24
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
            color: "#333"
        }

        Text {
            id: statusText
            text: "正在初始化..."
            font.pixelSize: 16
            Layout.alignment: Qt.AlignHCenter
            color: "#666"
        }

        ProgressBar {
            id: progressBar
            value: 0
            from: 0
            to: 1
            width: parent.width * 0.8
            Layout.alignment: Qt.AlignHCenter
            background: Rectangle {
                color: "#e0e0e0"
                radius: 4
            }
            contentItem: Rectangle {
                color: "#4CAF50"
                radius: 4
                width: progressBar.width * progressBar.value
                height: progressBar.height
            }
        }

        Text {
            id: progressText
            text: "0%"
            font.pixelSize: 14
            Layout.alignment: Qt.AlignHCenter
            color: "#666"
        }
    }

    Component.onCompleted: {
        appLoader.progressUpdated.connect(function(percent, msg) {
            progressBar.value = percent / 100.0;
            progressText.text = percent + "%";
            statusText.text = msg;
        });

        appLoader.loadFinished.connect(function() {
            // 加载完成后，初始化数据
            stationManager.initializeData();
            trainManager.initializeData();
            accountManager.initializeData();
            passengerManager.initializeData();
            orderManager.initializeData();
            
            // 关闭Splash页面，跳转到main.qml
            var component = Qt.createComponent("main.qml");
            if (component.status === Component.Ready) {
                var mainWindow = component.createObject(null);
                mainWindow.visible = true;
                splashWindow.close();
            } else {
                console.error("Failed to load main.qml:", component.errorString());
            }
        });

        // 启动加载线程
        appLoader.start();
    }
}
