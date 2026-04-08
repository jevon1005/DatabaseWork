import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import MyApp 1.0

ApplicationWindow {
    id: splashWindow
    width: 600
    height: 400
    title: "高铁订票系统"
    visible: true
    flags: Qt.FramelessWindowHint
    color: "#f0f0f0"

    // 背景图片层
    Rectangle {
        anchors.fill: parent
        color: "#f8f8f8"
        
        Image {
            anchors.fill: parent
            source: "qrc:/images/resources/images/logbackground.png"
            fillMode: Image.PreserveAspectCrop
            opacity: 0.15
        }
    }

    // 前景内容层
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40
        spacing: 20

        // 顶部弹簧,将内容向下推
        Item {
            Layout.fillHeight: true
            Layout.preferredHeight: 20
        }

        // Logo 图标区域(如果有单独的 logo,可以替换)
        Rectangle {
            Layout.preferredWidth: 120
            Layout.preferredHeight: 120
            Layout.alignment: Qt.AlignHCenter
            radius: 60
            color: "#409CFC"
            
            Text {
                anchors.centerIn: parent
                text: "🚄"
                font.pixelSize: 60
                color: "white"
            }
        }

        Text {
            text: "高铁订票系统"
            font.pixelSize: 28
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
            color: "#2c3e50"
            font.family: "Microsoft YaHei"
        }

        Text {
            id: statusText
            text: "正在初始化..."
            font.pixelSize: 16
            Layout.alignment: Qt.AlignHCenter
            color: "#7f8c8d"
            font.family: "Microsoft YaHei"
        }

        ProgressBar {
            id: progressBar
            value: 0
            from: 0
            to: 1
            Layout.preferredWidth: 400
            Layout.preferredHeight: 8
            Layout.alignment: Qt.AlignHCenter
            background: Rectangle {
                color: "#ecf0f1"
                radius: 4
            }
            contentItem: Rectangle {
                color: "#409CFC"
                radius: 4
                width: progressBar.visualPosition * progressBar.width
            }
        }

        Text {
            id: progressText
            text: "0%"
            font.pixelSize: 14
            Layout.alignment: Qt.AlignHCenter
            color: "#95a5a6"
            font.family: "Microsoft YaHei"
        }

        // 底部弹簧,保持布局居中
        Item {
            Layout.fillHeight: true
            Layout.preferredHeight: 40
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
