#include "railway_pg_connection.h"

#include <QSqlDatabase>
#include <QSqlError>
#include <QtGlobal>
#include <QSettings>
#include <QFileInfo>

static const char kConnName[] = "railway";
static QString s_lastError;

static QString readConfigValue(const QString &key, const QString &defaultValue = QString())
{
    QString configPath = QStringLiteral("railway_debug_pg.ini");
    QFileInfo fi(configPath);
    if (!fi.exists())
        return defaultValue;

    QSettings settings(configPath, QSettings::IniFormat);
    settings.beginGroup(QStringLiteral("postgres"));
    QString value = settings.value(key).toString();
    settings.endGroup();
    return value.isEmpty() ? defaultValue : value;
}

bool railwayPgTryOpenFromEnvironment()
{
    if (QSqlDatabase::contains(QLatin1String(kConnName))) {
        QSqlDatabase existing = QSqlDatabase::database(QLatin1String(kConnName), false);
        if (existing.isOpen())
            return true;
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
        s_lastError = QStringLiteral("未设置 PGHOST / PGUSER（或数据库已关闭）");
        return false;
    }

    db.setHostName(host);
    db.setPort(port.toInt());
    db.setDatabaseName(dbname);
    db.setUserName(user);
    db.setPassword(pass);
    db.setConnectOptions(QStringLiteral("sslmode=%1").arg(sslmode));

    if (!db.open()) {
        s_lastError = db.lastError().text();
        QSqlDatabase::removeDatabase(QLatin1String(kConnName));
        return false;
    }
    s_lastError.clear();
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
