#include "trainmanager.h"
#include "railway_pg_connection.h"
#include "railway_pg_codec.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <QDebug>
#include <QCoreApplication>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QStringList>

TrainManager::TrainManager(QObject *parent) : QObject{parent} {
    // 数据将通过DataLoader多线程加载
}

void TrainManager::initializeData() {
    // 💡 自动迁移逻辑
    if (trains.empty()) {
        qDebug() << "[列车] 云端为空或解析失败，开始从本地txt加载并重置云端...";
        readFromFile("../../data/train.txt");
        if (railwayPgCanWriteImmediately()) saveToPostgres();
    }
}

TrainManager::~TrainManager() {
    saveToLocalCache();
}

QVariantList TrainManager::getTrains_api() {
    QVariantList list;
    for (auto &train : trains) {
        QVariantMap map;
        map["trainNumber"] = train.getNumber();
        std::tuple<Station, Time> startStationInfo = train.getTimetable().getStartStationInfo();
        std::tuple<Station, Time> endStationInfo = train.getTimetable().getEndStationInfo();
        Station startStation = std::get<0>(startStationInfo);
        Time startTime = std::get<1>(startStationInfo);
        Station endStation = std::get<0>(endStationInfo);
        Time endTime = std::get<1>(endStationInfo);
        map["startStationName"] = startStation.getStationName();
        map["startHour"] = startTime.getHour(); map["startMinute"] = startTime.getMinute();
        map["endStationName"] = endStation.getStationName();
        map["endHour"] = endTime.getHour(); map["endMinute"] = endTime.getMinute();
        int intervalSeconds = train.getTimetable().getInterval(startStation, endStation);
        map["intervalHour"] = intervalSeconds / 3600; map["intervalMinute"] = (intervalSeconds % 3600) / 60;
        list << map;
    }
    return list;
}

QVariantMap TrainManager::deleteTrain_api(const QString &trainNumber) {
    QVariantMap result;
    
    // 先检查云端是否有"待乘坐"状态的关联订单
    if (railwayPgIsOpen()) {
        QSqlDatabase db = QSqlDatabase::database("railway", false);
        if (db.isOpen()) {
            QSqlQuery checkQuery(db);
            checkQuery.prepare("SELECT COUNT(*) FROM orders o "
                             "JOIN trains t ON o.train_id = t.train_id "
                             "WHERE t.train_number = ? AND o.status = '待乘坐'");
            checkQuery.addBindValue(trainNumber);
            
            if (checkQuery.exec() && checkQuery.next()) {
                int orderCount = checkQuery.value(0).toInt();
                if (orderCount > 0) {
                    result["success"] = false;
                    result["message"] = QString("该列车有 %1 个待乘坐的订单,请先取消或完成这些订单后再删除列车!").arg(orderCount);
                    qWarning() << "[列车管理] ⚠️  删除失败: 列车" << trainNumber << "有" << orderCount << "个待乘坐订单";
                    return result;
                }
            }
        }
    }
    
    // 没有关联订单,可以安全删除
    for (auto it = trains.begin(); it != trains.end(); it++) {
        if (it->getNumber() == trainNumber) {
            trains.erase(it);
            m_dirty = true;
            
            // 立即同步删除到云端
            if (deleteSingleTrainFromPostgres(trainNumber)) {
                m_dirty = false; // 删除成功后标记为已同步
            }
            
            result["success"] = true; 
            result["message"] = "删除成功！"; 
            return result;
        }
    }
    result["success"] = false;
    result["message"] = "列车不存在";
    return result;
}

QVariantList TrainManager::getTimetableInfo_api(const QString &trainNumber) {
    QVariantList list; auto findResult = getTrainByTrainNumber(trainNumber); if (!findResult) return list;
    Train &train = findResult.value(); std::vector<std::tuple<Station, Time, Time, int, int, int, QString>> info = train.getTimetable().getInfo();
    for (auto &t : info) {
        QVariantMap map; map["stationName"] = std::get<0>(t).getStationName(); map["arriveHour"] = std::get<1>(t).getHour(); map["arriveMinute"] = std::get<1>(t).getMinute(); map["arriveDay"] = std::get<3>(t); map["departureHour"] = std::get<2>(t).getHour(); map["departureMinute"] = std::get<2>(t).getMinute(); map["departureDay"] = std::get<4>(t); map["stopInterval"] = std::get<5>(t); map["passInfo"] = std::get<6>(t); list << map;
    }
    return list;
}

QVariantList TrainManager::getTimetableInfo_api(const QString &trainNumber, const QString &startStationName, const QString &endStationName) {
    QVariantList list; auto findResult = getTrainByTrainNumber(trainNumber); if (!findResult) return list;
    Train &train = findResult.value(); std::vector<std::tuple<Station, Time, Time, int, int, int, QString>> info = train.getTimetable().getInfo(startStationName, endStationName);
    for (auto &t : info) {
        QVariantMap map; map["stationName"] = std::get<0>(t).getStationName(); map["arriveHour"] = std::get<1>(t).getHour(); map["arriveMinute"] = std::get<1>(t).getMinute(); map["arriveDay"] = std::get<3>(t); map["departureHour"] = std::get<2>(t).getHour(); map["departureMinute"] = std::get<2>(t).getMinute(); map["departureDay"] = std::get<4>(t); map["stopInterval"] = std::get<5>(t); map["passInfo"] = std::get<6>(t); list << map;
    }
    return list;
}

QVariantList TrainManager::getCarriages_api(const QString &trainNumber) {
    QVariantList list; auto findResult = getTrainByTrainNumber(trainNumber); if (!findResult) return list;
    Train &train = findResult.value(); std::vector<std::tuple<QString, int, int>> carriages = train.getCarriages();
    for (const auto &carriage : carriages) { QVariantMap map; map["seatLevel"] = std::get<0>(carriage); map["rows"] = std::get<1>(carriage); map["cols"] = std::get<2>(carriage); list << map; }
    return list;
}

QVariantMap TrainManager::updateTimetableAndTrainNumberByTrainNumber(const QString &oldTrainNumber, Timetable &timetable, const QString &newTrainNumber) {
    QVariantMap result;
    if (oldTrainNumber == "") {
        // 添加新列车
        if (getTrainByTrainNumber(newTrainNumber)) { 
            result["success"] = false; 
            return result; 
        }
        Train newTrain; 
        newTrain.setNumber(newTrainNumber); 
        newTrain.setTimetable(timetable); 
        trains.push_back(newTrain);
        m_dirty = true;
        
        // 立即同步到云端
        syncSingleTrainToPostgres(newTrain);
        
        result["success"] = true; 
        return result;
    }
    
    // 更新现有列车
    if (oldTrainNumber != newTrainNumber && getTrainByTrainNumber(newTrainNumber)) { 
        result["success"] = false; 
        return result; 
    }
    
    for (auto &train : trains) {
        if (train.getNumber() == oldTrainNumber) {
            // 如果修改车次号,先检查是否有"待乘坐"的订单
            if (oldTrainNumber != newTrainNumber && railwayPgIsOpen()) {
                QSqlDatabase db = QSqlDatabase::database("railway", false);
                if (db.isOpen()) {
                    QSqlQuery checkQuery(db);
                    checkQuery.prepare("SELECT COUNT(*) FROM orders o "
                                     "JOIN trains t ON o.train_id = t.train_id "
                                     "WHERE t.train_number = ? AND o.status = '待乘坐'");
                    checkQuery.addBindValue(oldTrainNumber);
                    
                    if (checkQuery.exec() && checkQuery.next()) {
                        int orderCount = checkQuery.value(0).toInt();
                        if (orderCount > 0) {
                            result["success"] = false;
                            result["message"] = QString("该列车有 %1 个待乘坐的订单,无法修改车次号!").arg(orderCount);
                            qWarning() << "[列车管理] ⚠️  修改失败: 列车" << oldTrainNumber << "有" << orderCount << "个待乘坐订单";
                            return result;
                        }
                    }
                }
            }
            
            train.setTimetable(timetable); 
            train.setNumber(newTrainNumber);
            m_dirty = true;
            
            // 如果车次号变了,需要更新数据库(不能用删除+插入,要用UPDATE)
            if (oldTrainNumber != newTrainNumber) {
                // 使用特殊的更新方法处理车次号变更
                updateTrainNumberInPostgres(oldTrainNumber, train);
            } else {
                // 车次号没变,正常同步
                syncSingleTrainToPostgres(train);
            }
            
            result["success"] = true; 
            return result;
        }
    }
    result["success"] = false; 
    return result;
}

QVariantMap TrainManager::updateSeatTemplateByTrainNumber(const QString &trainNumber, std::vector<std::tuple<QString, int, int> > carriages) {
    QVariantMap result;
    for (auto it = trains.begin(); it != trains.end(); it++) {
        if (it->getNumber() == trainNumber) {
            it->setCarriages(carriages);
            m_dirty = true;
            
            // 立即同步到云端
            syncSingleTrainToPostgres(*it);
            
            result["success"] = true; 
            return result;
        }
    }
    result["success"] = false; 
    return result;
}

std::vector<std::tuple<Train, Station, Station>> TrainManager::getRoutesByCities(const QString &startCityName, const QString &endCityName) {
    std::vector<std::tuple<Train, Station, Station>> result;
    for (auto &train : trains) {
        std::vector<std::tuple<Station, Station>> stationPairs = train.getTimetable().getStationPairsBetweenCities(startCityName, endCityName);
        for (auto &pair : stationPairs) result.push_back(std::make_tuple(train, std::get<0>(pair), std::get<1>(pair)));
    }
    return result;
}

std::optional<Train> TrainManager::getTrainByTrainNumber(const QString &trainNumber) {
    for (auto &train : trains) if (train.getNumber() == trainNumber) return train; return std::nullopt;
}

bool TrainManager::readFromFile(const char filename[]) {
    std::fstream fis(filename, std::ios::in); if (!fis) return false;
    Train train; while (fis >> train) trains.push_back(train); return true;
}

bool TrainManager::writeToFile(const char filename[]) {
    std::fstream fos(filename, std::ios::out); if (!fos) return false;
    for (auto &train : trains) fos << train << std::endl; return true;
}

void TrainManager::loadFromPostgres() {
    QSqlDatabase db = QSqlDatabase::database("railway", false);
    loadFromPostgres(db);
}

void TrainManager::loadFromPostgres(QSqlDatabase &db) {
    trains.clear();
    if (!db.isOpen()) return;

    QSqlQuery q(db);
    if (!q.exec("SELECT train_number, seat_config FROM trains ORDER BY train_id")) return;

    while (q.next()) {
        Train tr;
        if (RailwayPgCodec::trainFromSeatConfigJson(q.value(1).toString(), q.value(0).toString(), tr)) {
            trains.push_back(tr);
        }
    }
    m_dirty = false;
}

void TrainManager::saveToPostgres() {
    QSqlDatabase db = QSqlDatabase::database("railway", false);
    if (!db.isOpen()) return;

    QSqlQuery ping(db); if (!ping.exec("SELECT 1")) { db.close(); db.open(); }
    if (!db.transaction()) return;

    QStringList localTrainNumbers;
    localTrainNumbers.reserve(static_cast<qsizetype>(trains.size()));

    for (Train &train : trains) {
        std::tuple<Station, Time> sInfo = train.getTimetable().getStartStationInfo();
        std::tuple<Station, Time> eInfo = train.getTimetable().getEndStationInfo();

        QSqlQuery qs0(db); qs0.prepare("SELECT station_id FROM stations WHERE station_name = ? LIMIT 1"); qs0.addBindValue(std::get<0>(sInfo).getStationName());
        if (!qs0.exec() || !qs0.next()) continue; // 跳过不完整的车站
        const int sid0 = qs0.value(0).toInt();

        QSqlQuery qs1(db); qs1.prepare("SELECT station_id FROM stations WHERE station_name = ? LIMIT 1"); qs1.addBindValue(std::get<0>(eInfo).getStationName());
        if (!qs1.exec() || !qs1.next()) continue;
        const int sid1 = qs1.value(0).toInt();

        QString cfg = RailwayPgCodec::trainToSeatConfigJson(train);

        QSqlQuery q(db);
        q.prepare("INSERT INTO trains (train_number, start_station_id, end_station_id, seat_config) VALUES (?,?,?,?) ON CONFLICT (train_number) DO UPDATE SET start_station_id = EXCLUDED.start_station_id, end_station_id = EXCLUDED.end_station_id, seat_config = EXCLUDED.seat_config");
        q.addBindValue(train.getNumber()); q.addBindValue(sid0); q.addBindValue(sid1); q.addBindValue(cfg);
        if (!q.exec()) { db.rollback(); return; }
        QString escaped = train.getNumber();
        escaped.replace("'", "''");
        localTrainNumbers << escaped;
    }

    if (localTrainNumbers.isEmpty()) {
        QSqlQuery qDelete(db);
        if (!qDelete.exec("DELETE FROM trains")) { db.rollback(); return; }
    } else {
        QSqlQuery qDelete(db);
        const QString sql = QString("DELETE FROM trains WHERE train_number NOT IN ('%1')").arg(localTrainNumbers.join("','"));
        if (!qDelete.exec(sql)) { db.rollback(); return; }
    }
    db.commit();
    m_dirty = false;
}

// 立即同步单条列车到云端(用于增/改操作)
void TrainManager::syncSingleTrainToPostgres(Train &train) {
    if (!railwayPgIsOpen()) {
        qWarning() << "[列车管理] 云端连接不可用,跳过同步";
        return;
    }
    
    QSqlDatabase db = QSqlDatabase::database("railway", false);
    if (!db.isOpen()) {
        railwayPgTryOpenFromEnvironment();
        db = QSqlDatabase::database("railway", false);
    }
    
    if (!db.isOpen()) {
        qWarning() << "[列车管理] 数据库打开失败,跳过同步";
        return;
    }
    
    std::tuple<Station, Time> sInfo = train.getTimetable().getStartStationInfo();
    std::tuple<Station, Time> eInfo = train.getTimetable().getEndStationInfo();
    
    QSqlQuery qs0(db); 
    qs0.prepare("SELECT station_id FROM stations WHERE station_name = ? LIMIT 1"); 
    qs0.addBindValue(std::get<0>(sInfo).getStationName());
    if (!qs0.exec() || !qs0.next()) {
        qWarning() << "[列车管理] 起始站不存在:" << std::get<0>(sInfo).getStationName();
        return;
    }
    const int sid0 = qs0.value(0).toInt();
    
    QSqlQuery qs1(db); 
    qs1.prepare("SELECT station_id FROM stations WHERE station_name = ? LIMIT 1"); 
    qs1.addBindValue(std::get<0>(eInfo).getStationName());
    if (!qs1.exec() || !qs1.next()) {
        qWarning() << "[列车管理] 终点站不存在:" << std::get<0>(eInfo).getStationName();
        return;
    }
    const int sid1 = qs1.value(0).toInt();
    
    QString cfg = RailwayPgCodec::trainToSeatConfigJson(train);
    
    QSqlQuery q(db);
    q.prepare("INSERT INTO trains (train_number, start_station_id, end_station_id, seat_config) "
              "VALUES (?,?,?,?) "
              "ON CONFLICT (train_number) DO UPDATE SET "
              "start_station_id = EXCLUDED.start_station_id, "
              "end_station_id = EXCLUDED.end_station_id, "
              "seat_config = EXCLUDED.seat_config");
    q.addBindValue(train.getNumber()); 
    q.addBindValue(sid0); 
    q.addBindValue(sid1); 
    q.addBindValue(cfg);
    
    if (!q.exec()) {
        qWarning() << "[列车管理] 云端同步失败:" << q.lastError().text();
    } else {
        qDebug() << "[列车管理] ✅ 已同步到云端:" << train.getNumber();
    }
}

// 立即从云端删除单条列车(用于删操作)
// 注意: 调用此方法前应该已经检查过没有"待乘坐"状态的订单
bool TrainManager::deleteSingleTrainFromPostgres(const QString &trainNumber) {
    if (!railwayPgIsOpen()) {
        qWarning() << "[列车管理] 云端连接不可用,跳过同步删除";
        return false;
    }
    
    QSqlDatabase db = QSqlDatabase::database("railway", false);
    if (!db.isOpen()) {
        railwayPgTryOpenFromEnvironment();
        db = QSqlDatabase::database("railway", false);
    }
    
    if (!db.isOpen()) {
        qWarning() << "[列车管理] 数据库打开失败,跳过同步删除";
        return false;
    }
    
    // 先删除所有关联的历史订单(已取消、已完成、已改签等)
    // 只删除非"待乘坐"状态的订单(待乘坐的订单在前面已经检查过了)
    QSqlQuery deleteHistoryOrders(db);
    deleteHistoryOrders.prepare("DELETE FROM orders WHERE train_id IN "
                               "(SELECT train_id FROM trains WHERE train_number = ?) "
                               "AND status != '待乘坐'");
    deleteHistoryOrders.addBindValue(trainNumber);
    
    if (deleteHistoryOrders.exec()) {
        int deletedCount = deleteHistoryOrders.numRowsAffected();
        if (deletedCount > 0) {
            qDebug() << "[列车管理] 已删除" << deletedCount << "条历史订单记录";
        }
    } else {
        qWarning() << "[列车管理] 删除历史订单失败:" << deleteHistoryOrders.lastError().text();
        // 即使删除历史订单失败,仍尝试删除列车
    }
    
    // 删除列车
    QSqlQuery q(db);
    q.prepare("DELETE FROM trains WHERE train_number = ?");
    q.addBindValue(trainNumber);
    
    if (!q.exec()) {
        qWarning() << "[列车管理] 云端删除失败:" << q.lastError().text();
        return false;
    } else {
        qDebug() << "[列车管理] ✅ 已从云端删除:" << trainNumber;
        return true;
    }
}

// 更新车次号(处理外键约束问题)
// 直接UPDATE而不是DELETE+INSERT,这样订单的外键关系会自动保持
void TrainManager::updateTrainNumberInPostgres(const QString &oldTrainNumber, Train &train) {
    if (!railwayPgIsOpen()) {
        qWarning() << "[列车管理] 云端连接不可用,跳过同步";
        return;
    }
    
    QSqlDatabase db = QSqlDatabase::database("railway", false);
    if (!db.isOpen()) {
        railwayPgTryOpenFromEnvironment();
        db = QSqlDatabase::database("railway", false);
    }
    
    if (!db.isOpen()) {
        qWarning() << "[列车管理] 数据库打开失败,跳过同步";
        return;
    }
    
    std::tuple<Station, Time> sInfo = train.getTimetable().getStartStationInfo();
    std::tuple<Station, Time> eInfo = train.getTimetable().getEndStationInfo();
    
    QSqlQuery qs0(db); 
    qs0.prepare("SELECT station_id FROM stations WHERE station_name = ? LIMIT 1"); 
    qs0.addBindValue(std::get<0>(sInfo).getStationName());
    if (!qs0.exec() || !qs0.next()) {
        qWarning() << "[列车管理] 起始站不存在:" << std::get<0>(sInfo).getStationName();
        return;
    }
    const int sid0 = qs0.value(0).toInt();
    
    QSqlQuery qs1(db); 
    qs1.prepare("SELECT station_id FROM stations WHERE station_name = ? LIMIT 1"); 
    qs1.addBindValue(std::get<0>(eInfo).getStationName());
    if (!qs1.exec() || !qs1.next()) {
        qWarning() << "[列车管理] 终点站不存在:" << std::get<0>(eInfo).getStationName();
        return;
    }
    const int sid1 = qs1.value(0).toInt();
    
    QString cfg = RailwayPgCodec::trainToSeatConfigJson(train);
    
    // 使用UPDATE直接更新,保持train_id不变,这样订单的外键关系自动保持
    QSqlQuery q(db);
    q.prepare("UPDATE trains SET "
              "train_number = ?, "
              "start_station_id = ?, "
              "end_station_id = ?, "
              "seat_config = ? "
              "WHERE train_number = ?");
    q.addBindValue(train.getNumber()); 
    q.addBindValue(sid0); 
    q.addBindValue(sid1); 
    q.addBindValue(cfg);
    q.addBindValue(oldTrainNumber); // WHERE条件使用旧车次号
    
    if (!q.exec()) {
        qWarning() << "[列车管理] 云端更新失败:" << q.lastError().text();
    } else {
        qDebug() << "[列车管理] ✅ 已更新车次号:" << oldTrainNumber << "->" << train.getNumber();
    }
}

bool TrainManager::loadFromLocalCache() {
    trains.clear();
    const bool ok = readFromFile("../../data/train.txt");
    m_dirty = false;
    return ok;
}

bool TrainManager::saveToLocalCache() const {
    auto *self = const_cast<TrainManager *>(this);
    return self->writeToFile("../../data/train.txt");
}

bool TrainManager::hasDirtyChanges() const {
    return m_dirty;
}

void TrainManager::markClean() {
    m_dirty = false;
}