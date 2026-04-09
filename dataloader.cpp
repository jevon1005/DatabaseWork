#include "dataloader.h"
#include "railway_pg_connection.h"
#include <QSqlDatabase>
#include <QSqlError>
#include <QDebug>
#include <QtGlobal>
#include <QSettings>
#include <QFileInfo>
#include <QCoreApplication>
#include <QDir>

DataLoader::DataLoader(StationManager* sm, TrainManager* tm, AccountManager* am, PassengerManager* pm, OrderManager* om)
    : m_stationManager(sm), m_trainManager(tm), m_accountManager(am), m_passengerManager(pm), m_orderManager(om)
{
}

DataLoader::~DataLoader()
{
}

// 在子线程中读取配置文件
static QString readThreadConfigValue(const QString &key, const QString &defaultValue = QString())
{
    QStringList searchPaths;
    searchPaths << "railway_debug_pg.ini";
    searchPaths << QCoreApplication::applicationDirPath() + "/railway_debug_pg.ini";
    searchPaths << QCoreApplication::applicationDirPath() + "/../railway_debug_pg.ini";
    
    QString configPath;
    for (const QString &path : searchPaths) {
        QFileInfo fi(path);
        if (fi.exists()) {
            configPath = fi.absoluteFilePath();
            break;
        }
    }
    
    if (configPath.isEmpty()) {
        return defaultValue;
    }

    QSettings settings(configPath, QSettings::IniFormat);
    settings.beginGroup(QStringLiteral("postgres"));
    QString value = settings.value(key).toString();
    settings.endGroup();
    return value.isEmpty() ? defaultValue : value;
}

void DataLoader::run()
{
    auto loadLocalSnapshot = [this]() {
        emit progressUpdated(10, "云端不可用，加载本地快照...");
        if (m_stationManager) m_stationManager->loadFromLocalCache();
        if (m_trainManager) m_trainManager->loadFromLocalCache();
        if (m_accountManager) m_accountManager->loadFromLocalCache();
        if (m_passengerManager) m_passengerManager->loadFromLocalCache();
        if (m_orderManager) m_orderManager->loadFromLocalCache();
        emit progressUpdated(100, "已加载本地快照");
    };
    // 在子线程中创建独立的数据库连接
    QString threadConnName = QStringLiteral("railway_thread_%1")
                             .arg(reinterpret_cast<quintptr>(QThread::currentThreadId()));
    
    // 读取配置
    QString host = qEnvironmentVariable("PGHOST");
    QString port = qEnvironmentVariable("PGPORT", QStringLiteral("5432"));
    QString dbname = qEnvironmentVariable("PGDATABASE", QStringLiteral("postgres"));
    QString user = qEnvironmentVariable("PGUSER");
    QString pass = qEnvironmentVariable("PGPASSWORD");
    QString sslmode = qEnvironmentVariable("PGSSLMODE", QStringLiteral("require"));
    
    // 如果环境变量为空,从配置文件读取
    if (host.isEmpty() || user.isEmpty()) {
        host = readThreadConfigValue(QStringLiteral("host"));
        port = readThreadConfigValue(QStringLiteral("port"), QStringLiteral("6543"));
        dbname = readThreadConfigValue(QStringLiteral("database"), QStringLiteral("postgres"));
        user = readThreadConfigValue(QStringLiteral("user"));
        pass = readThreadConfigValue(QStringLiteral("password"));
        sslmode = readThreadConfigValue(QStringLiteral("sslmode"), QStringLiteral("require"));
    }
    
    if (host.isEmpty() || user.isEmpty()) {
        qWarning() << "子线程:数据库配置未设置,无法加载数据";
        loadLocalSnapshot();
        emit loadFinished();
        return;
    }
    
    // 使用作用域确保数据库对象在删除前完全销毁
    {
        QSqlDatabase db = QSqlDatabase::addDatabase(QStringLiteral("QPSQL"), threadConnName);
        db.setHostName(host);
        db.setPort(port.toInt());
        db.setDatabaseName(dbname);
        db.setUserName(user);
        db.setPassword(pass);
        
        QString connectOpts = QStringLiteral("sslmode=%1;keepalives=1;keepalives_idle=30;keepalives_interval=10;keepalives_count=3")
                              .arg(sslmode);
        db.setConnectOptions(connectOpts);
        
        if (!db.open()) {
            qWarning() << "子线程:数据库连接失败:" << db.lastError().text();
            QSqlDatabase::removeDatabase(threadConnName);
            loadLocalSnapshot();
            emit loadFinished();
            return;
        }

    // 加载车站信息
    emit progressUpdated(10, "正在加载车站信息...");
    if (m_stationManager) {
        m_stationManager->loadFromPostgres(db);
    }

    // 加载列车信息
    emit progressUpdated(30, "正在加载列车时刻表...");
    if (m_trainManager) {
        m_trainManager->loadFromPostgres(db);
    }

    // 加载账户信息
    emit progressUpdated(60, "正在加载账户信息...");
    if (m_accountManager) {
        m_accountManager->loadFromPostgres(db);
    }

    // 加载乘车人信息
    emit progressUpdated(70, "正在加载乘车人信息...");
    if (m_passengerManager) {
        m_passengerManager->loadFromPostgres(db);
    }

    // 加载订单信息
    emit progressUpdated(80, "正在同步云端订单...");
    if (m_orderManager) {
        m_orderManager->loadFromPostgres(db);
    }

    // 启动时把云端快照持久化到本地，后续使用本地内存数据提升体验
    if (m_stationManager) m_stationManager->saveToLocalCache();
    if (m_trainManager) m_trainManager->saveToLocalCache();
    if (m_accountManager) m_accountManager->saveToLocalCache();
    if (m_passengerManager) m_passengerManager->saveToLocalCache();
    if (m_orderManager) m_orderManager->saveToLocalCache();

        // 完成加载
        emit progressUpdated(100, "加载完成");
        
        db.close();
    } // db 对象在此销毁
    
    // 所有数据库对象销毁后才删除连接
    QSqlDatabase::removeDatabase(threadConnName);
    
    emit loadFinished();
}
