#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>
// 仅注册需要的类型
#include "accountmanager.h"
#include "stationmanager.h"
#include "ordermanager.h"
#include "bookingsystem.h"
#include "trainmanager.h"
#include "passengermanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // 设置 Qt Quick Controls 2 的样式为 Basic（或 Fusion、Material）
    qputenv("QT_QUICK_CONTROLS_STYLE", QByteArray("Basic"));

    QQmlApplicationEngine engine;    // 创建 QML 应用程序引擎对象

    StationManager* stationManager = new StationManager;
    OrderManager* orderManager = new OrderManager;
    TrainManager* trainManager = new TrainManager;
    AccountManager* accountManager = new AccountManager;
    PassengerManager* passengerManager = new PassengerManager;
    BookingSystem* bookingSystem = new BookingSystem(stationManager,
                                                     orderManager,
                                                     trainManager,
                                                     accountManager,
                                                     passengerManager);
    engine.rootContext()->setContextProperty("stationManager", stationManager);
    engine.rootContext()->setContextProperty("orderManager", orderManager);
    engine.rootContext()->setContextProperty("trainManager", trainManager);
    engine.rootContext()->setContextProperty("bookingSystem", bookingSystem);
    engine.rootContext()->setContextProperty("accountManager", accountManager);
    engine.rootContext()->setContextProperty("passengerManager", passengerManager);
    qmlRegisterSingletonType(QUrl("qrc:/qml/SessionState.qml"), "MyApp", 1, 0, "SessionState");

    // 直接加载主窗口（包含嵌入式登录页面）
    const QUrl mainUrl("qrc:/qml/main.qml");
    engine.load(mainUrl);
    if (engine.rootObjects().isEmpty()) {
        qWarning() << "main.qml 加载失败";
        return -1;
    }

    return app.exec();
}

