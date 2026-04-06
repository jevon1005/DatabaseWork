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

bool connectToCloudDB() {
    if (!QSqlDatabase::drivers().contains("QPSQL")) {
        qDebug() << "缺少 QPSQL 驱动！";
        return false;
    }
    QSqlDatabase db = QSqlDatabase::addDatabase("QPSQL", "railway");

    db.setHostName("aws-1-ap-southeast-2.pooler.supabase.com");
    db.setPort(6543);
    db.setDatabaseName("postgres");
    db.setUserName("postgres.rtjrnuejqearaubgzxnv");
    db.setPassword("Aa1819822437");
    // 加入心跳保活机制，防止 Supabase 切断连接
    db.setConnectOptions("sslmode=require;keepalives=1;keepalives_idle=30;keepalives_interval=10;keepalives_count=3");

    if (!db.open()) {
        qDebug() << "❌ 数据库连接失败:" << db.lastError().text();
        return false;
    }
    qDebug() << "✅ 成功连接到 Supabase 云数据库！";
    return true;
}

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    connectToCloudDB();

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