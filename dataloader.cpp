#include "dataloader.h"
#include <QSqlDatabase>
#include <QSqlError>
#include <QDebug>

DataLoader::DataLoader(StationManager* sm, TrainManager* tm, AccountManager* am, PassengerManager* pm, OrderManager* om)
    : m_stationManager(sm), m_trainManager(tm), m_accountManager(am), m_passengerManager(pm), m_orderManager(om)
{
}

DataLoader::~DataLoader()
{
}

void DataLoader::run()
{
    // 在子线程中创建新的数据库连接
    QSqlDatabase db = QSqlDatabase::addDatabase("QPSQL", "railway_thread");
    db.setHostName("aws-1-ap-southeast-2.pooler.supabase.com");
    db.setPort(6543);
    db.setDatabaseName("postgres");
    db.setUserName("postgres.rtjrnuejqearaubgzxnv");
    db.setPassword("Aa1819822437");
    db.setConnectOptions("sslmode=require;keepalives=1;keepalives_idle=30;keepalives_interval=10;keepalives_count=3");
    
    if (!db.open()) {
        qWarning() << "数据库连接失败:" << db.lastError().text();
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

    // 完成加载
    emit progressUpdated(100, "加载完成");
    QSqlDatabase::removeDatabase("railway_thread");
    emit loadFinished();
}
