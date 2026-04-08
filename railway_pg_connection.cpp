#include "railway_pg_connection.h"

#include <QSqlDatabase>
#include <QSqlError>
#include <QtGlobal>
#include <QSettings>
#include <QFileInfo>
#include <QCoreApplication>
#include <QDir>
#include <QDebug>

static const char kConnName[] = "railway";
static QString s_lastError;

static QString readConfigValue(const QString &key, const QString &defaultValue = QString())
{
    QStringList searchPaths;
    searchPaths << "railway_debug_pg.ini";
    searchPaths << QCoreApplication::applicationDirPath() + "/railway_debug_pg.ini";
    searchPaths << QCoreApplication::applicationDirPath() + "/../railway_debug_pg.ini";

    QString configPath;
    for (const QString &path : searchPaths) {
        QFileInfo fi(path);
        qDebug() << "[配置] 正在查找文件:" << fi.absoluteFilePath() << " 是否存在:" << fi.exists();

        if (fi.exists()) {
            configPath = fi.absoluteFilePath();
            qDebug() << "[配置] 成功找到配置文件:" << configPath;
            break;
        }
    }

    if (configPath.isEmpty()) {
        qDebug() << "[配置] 警告: 未找到任何配置文件!";
        return defaultValue;
    }

    QSettings settings(configPath, QSettings::IniFormat);
    settings.beginGroup(QStringLiteral("postgres"));
    QString value = settings.value(key).toString();
    settings.endGroup();
    return value.isEmpty() ? defaultValue : value;
}

bool railwayPgTryOpenFromEnvironment()
{
    // 检查连接是否已存在且打开
    if (QSqlDatabase::contains(QLatin1String(kConnName))) {
        QSqlDatabase existing = QSqlDatabase::database(QLatin1String(kConnName), false);
        if (existing.isOpen()) {
            // 连接已存在且打开,直接返回成功
            s_lastError.clear();
            return true;
        }
        // 连接存在但未打开,需要删除重建
        // 关键:先让对象超出作用域,再删除数据库
        {
            QSqlDatabase temp = QSqlDatabase::database(QLatin1String(kConnName));
            temp.close();
        } // temp 对象销毁
        QSqlDatabase::removeDatabase(QLatin1String(kConnName));
    }

    QSqlDatabase db = QSqlDatabase::addDatabase(QStringLiteral("QPSQL"), QLatin1String(kConnName));

    QString host = qEnvironmentVariable("PGHOST");
    QString port = qEnvironmentVariable("PGPORT", QStringLiteral("5432"));
    QString dbname = qEnvironmentVariable("PGDATABASE", QStringLiteral("postgres"));
    QString user = qEnvironmentVariable("PGUSER");
    QString pass = qEnvironmentVariable("PGPASSWORD");
    QString sslmode = qEnvironmentVariable("PGSSLMODE", QStringLiteral("require"));

    if (host.isEmpty() || user.isEmpty()) {
        host = readConfigValue(QStringLiteral("host"));
        port = readConfigValue(QStringLiteral("port"), QStringLiteral("5432"));
        dbname = readConfigValue(QStringLiteral("database"), QStringLiteral("postgres"));
        user = readConfigValue(QStringLiteral("user"));
        pass = readConfigValue(QStringLiteral("password"));
        sslmode = readConfigValue(QStringLiteral("sslmode"), QStringLiteral("require"));
    }

    if (host.isEmpty() || user.isEmpty()) {
        s_lastError = QStringLiteral("未设置 PGHOST / PGUSER(或数据库已关闭)");
        return false;
    }

    qDebug() << "[数据库] 尝试连接:" << host << ":" << port;
    qDebug() << "[数据库] 数据库:" << dbname << "用户:" << user;
    qDebug() << "[数据库] SSL模式:" << sslmode;

    db.setHostName(host);
    db.setPort(port.toInt());
    db.setDatabaseName(dbname);
    db.setUserName(user);
    db.setPassword(pass);
    
    // 完整的连接选项:SSL + 心跳保活机制
    QString connectOpts = QStringLiteral("sslmode=%1;keepalives=1;keepalives_idle=30;keepalives_interval=10;keepalives_count=3")
                          .arg(sslmode);
    db.setConnectOptions(connectOpts);

    if (!db.open()) {
        s_lastError = db.lastError().text();
        qDebug() << "[数据库] ❌ 连接失败:" << s_lastError;
        qDebug() << "[数据库] 详细错误:" << db.lastError().databaseText();
        qDebug() << "[数据库] 驱动错误:" << db.lastError().driverText();
        qDebug() << "[数据库] 详细错误:" << db.lastError().databaseText();
        qDebug() << "[数据库] 驱动错误:" << db.lastError().driverText();
        QSqlDatabase::removeDatabase(QLatin1String(kConnName));
        return false;
    }
    s_lastError.clear();
    qDebug() << "[数据库] ✅ 连接成功!";
    return true;
}

bool railwayPgIsOpen()
{
    return QSqlDatabase::contains(QLatin1String(kConnName))
        && QSqlDatabase::database(QLatin1String(kConnName), false).isOpen();
}

QString railwayPgLastError()
{
    return s_lastError;
}
