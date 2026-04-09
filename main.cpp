#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>

#include "accountmanager.h"
#include "stationmanager.h"
#include "ordermanager.h"
#include "bookingsystem.h"
#include "trainmanager.h"
#include "passengermanager.h"
#include "railway_pg_connection.h"
#include "dataloader.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    railwayPgSetDeferredSyncEnabled(true);
    
    // 使用配置系统连接数据库
    if (!QSqlDatabase::drivers().contains("QPSQL")) {
        qDebug() << "❌ 缺少 QPSQL 驱动！";
    } else if (!railwayPgTryOpenFromEnvironment()) {
        qDebug() << "❌ 数据库连接失败:" << railwayPgLastError();
    } else {
        qDebug() << "✅ 成功连接到 Supabase 云数据库！";
    }

    qputenv("QT_QUICK_CONTROLS_STYLE", QByteArray("Basic"));
    QQmlApplicationEngine engine;

    // ❗注意：初始化顺序必须如下，OrderManager 需要传入 TrainManager
    StationManager* stationManager = new StationManager;
    TrainManager* trainManager = new TrainManager;
    OrderManager* orderManager = new OrderManager(trainManager);
    AccountManager* accountManager = new AccountManager;
    PassengerManager* passengerManager = new PassengerManager;

    BookingSystem* bookingSystem = new BookingSystem(stationManager,
                                                     orderManager,
                                                     trainManager,
                                                     accountManager,
                                                     passengerManager);

    // 创建DataLoader
    DataLoader* loader = new DataLoader(stationManager, trainManager, accountManager, passengerManager, orderManager);

    QObject::connect(&app, &QCoreApplication::aboutToQuit, [&]() {
        stationManager->saveToLocalCache();
        trainManager->saveToLocalCache();
        accountManager->saveToLocalCache();
        passengerManager->saveToLocalCache();
        orderManager->saveToLocalCache();

        if (!railwayPgIsOpen()) {
            railwayPgTryOpenFromEnvironment();
        }
        if (!railwayPgIsOpen()) {
            qWarning() << "退出同步跳过：云端连接不可用，仅保留本地快照。";
            return;
        }
        if (stationManager->hasDirtyChanges()) stationManager->saveToPostgres();
        if (accountManager->hasDirtyChanges()) accountManager->saveToPostgres();
        if (trainManager->hasDirtyChanges()) trainManager->saveToPostgres();
        if (passengerManager->hasDirtyChanges()) passengerManager->saveToPostgres();
        if (orderManager->hasDirtyChanges()) orderManager->saveToPostgres();
    });

    // 注册到QML
    engine.rootContext()->setContextProperty("stationManager", stationManager);
    engine.rootContext()->setContextProperty("orderManager", orderManager);
    engine.rootContext()->setContextProperty("trainManager", trainManager);
    engine.rootContext()->setContextProperty("bookingSystem", bookingSystem);
    engine.rootContext()->setContextProperty("accountManager", accountManager);
    engine.rootContext()->setContextProperty("passengerManager", passengerManager);
    engine.rootContext()->setContextProperty("appLoader", loader);
    qmlRegisterSingletonType(QUrl("qrc:/qml/SessionState.qml"), "MyApp", 1, 0, "SessionState");

    // 先加载启动页
    const QUrl splashUrl("qrc:/qml/Splash.qml");
    engine.load(splashUrl);
    if (engine.rootObjects().isEmpty()) {
        qWarning() << "Splash.qml 加载失败";
        // 加载失败时，直接加载main.qml
        const QUrl mainUrl("qrc:/qml/main.qml");
        engine.load(mainUrl);
        if (engine.rootObjects().isEmpty()) {
            qWarning() << "main.qml 加载失败";
            return -1;
        }
    }
    return app.exec();
}