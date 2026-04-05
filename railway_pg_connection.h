#ifndef RAILWAY_PG_CONNECTION_H
#define RAILWAY_PG_CONNECTION_H

class QString;

// 使用 Qt QPSQL 连接；连接名 "railway"。
//
// 1) 环境变量（最高优先级）：PGHOST, PGPORT, PGDATABASE, PGUSER, PGPASSWORD, PGSSLMODE
// 2) railway_debug_pg.ini（次优先，见 railway_debug_pg.ini.example）
// 3) railway_pg_connection.cpp 内 kRailwayPgEmbeddedDebug + embeddedPg* 常量（临时调试用，默认开启但值为空）
bool railwayPgTryOpenFromEnvironment();
bool railwayPgIsOpen();
QString railwayPgLastError();

// QSqlDatabase 连接名，与 railwayPgTryOpenFromEnvironment 创建的连接一致
#define RAILWAY_PG_CONN "railway"

#endif
