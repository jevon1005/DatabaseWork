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
    for (auto it = trains.begin(); it != trains.end(); it++) {
        if (it->getNumber() == trainNumber) {
            trains.erase(it);
            m_dirty = true;
            if (railwayPgCanWriteImmediately()) {
                QSqlDatabase db = QSqlDatabase::database("railway", false);
                QSqlQuery q(db);
                q.prepare("DELETE FROM trains WHERE train_number = ?");
                q.addBindValue(trainNumber);
                q.exec();
            }
            result["success"] = true; result["message"] = "删除成功！"; return result;
        }
    }
    result["success"] = false; return result;
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
        if (getTrainByTrainNumber(newTrainNumber)) { result["success"] = false; return result; }
        Train newTrain; newTrain.setNumber(newTrainNumber); newTrain.setTimetable(timetable); trains.push_back(newTrain);
        m_dirty = true;
        if (railwayPgCanWriteImmediately()) {
            QSqlDatabase db = QSqlDatabase::database("railway", false);
            std::tuple<Station, Time> sInfo = newTrain.getTimetable().getStartStationInfo();
            std::tuple<Station, Time> eInfo = newTrain.getTimetable().getEndStationInfo();
            QSqlQuery qs0(db); qs0.prepare("SELECT station_id FROM stations WHERE station_name = ? LIMIT 1"); qs0.addBindValue(std::get<0>(sInfo).getStationName());
            if (!qs0.exec() || !qs0.next()) { result["success"] = false; return result; }
            const int sid0 = qs0.value(0).toInt();
            QSqlQuery qs1(db); qs1.prepare("SELECT station_id FROM stations WHERE station_name = ? LIMIT 1"); qs1.addBindValue(std::get<0>(eInfo).getStationName());
            if (!qs1.exec() || !qs1.next()) { result["success"] = false; return result; }
            const int sid1 = qs1.value(0).toInt();
            QString cfg = RailwayPgCodec::trainToSeatConfigJson(newTrain);
            QSqlQuery q(db);
            q.prepare("INSERT INTO trains (train_number, start_station_id, end_station_id, seat_config) VALUES (?,?,?,?)");
            q.addBindValue(newTrain.getNumber()); q.addBindValue(sid0); q.addBindValue(sid1); q.addBindValue(cfg);
            q.exec();
        }
        result["success"] = true; return result;
    }
    if (oldTrainNumber != newTrainNumber && getTrainByTrainNumber(newTrainNumber)) { result["success"] = false; return result; }
    for (auto &train : trains) {
        if (train.getNumber() == oldTrainNumber) {
            train.setTimetable(timetable); train.setNumber(newTrainNumber);
            m_dirty = true;
            if (railwayPgCanWriteImmediately()) {
                QSqlDatabase db = QSqlDatabase::database("railway", false);
                std::tuple<Station, Time> sInfo = train.getTimetable().getStartStationInfo();
                std::tuple<Station, Time> eInfo = train.getTimetable().getEndStationInfo();
                QSqlQuery qs0(db); qs0.prepare("SELECT station_id FROM stations WHERE station_name = ? LIMIT 1"); qs0.addBindValue(std::get<0>(sInfo).getStationName());
                if (!qs0.exec() || !qs0.next()) { result["success"] = false; return result; }
                const int sid0 = qs0.value(0).toInt();
                QSqlQuery qs1(db); qs1.prepare("SELECT station_id FROM stations WHERE station_name = ? LIMIT 1"); qs1.addBindValue(std::get<0>(eInfo).getStationName());
                if (!qs1.exec() || !qs1.next()) { result["success"] = false; return result; }
                const int sid1 = qs1.value(0).toInt();
                QString cfg = RailwayPgCodec::trainToSeatConfigJson(train);
                QSqlQuery q(db);
                q.prepare("UPDATE trains SET train_number = ?, start_station_id = ?, end_station_id = ?, seat_config = ? WHERE train_number = ?");
                q.addBindValue(newTrainNumber); q.addBindValue(sid0); q.addBindValue(sid1); q.addBindValue(cfg); q.addBindValue(oldTrainNumber);
                q.exec();
            }
            result["success"] = true; return result;
        }
    }
    result["success"] = false; return result;
}

QVariantMap TrainManager::updateSeatTemplateByTrainNumber(const QString &trainNumber, std::vector<std::tuple<QString, int, int> > carriages) {
    QVariantMap result;
    for (auto it = trains.begin(); it != trains.end(); it++) {
        if (it->getNumber() == trainNumber) {
            it->setCarriages(carriages);
            m_dirty = true;
            if (railwayPgCanWriteImmediately()) {
                QSqlDatabase db = QSqlDatabase::database("railway", false);
                std::tuple<Station, Time> sInfo = it->getTimetable().getStartStationInfo();
                std::tuple<Station, Time> eInfo = it->getTimetable().getEndStationInfo();
                QSqlQuery qs0(db); qs0.prepare("SELECT station_id FROM stations WHERE station_name = ? LIMIT 1"); qs0.addBindValue(std::get<0>(sInfo).getStationName());
                if (!qs0.exec() || !qs0.next()) { result["success"] = false; return result; }
                const int sid0 = qs0.value(0).toInt();
                QSqlQuery qs1(db); qs1.prepare("SELECT station_id FROM stations WHERE station_name = ? LIMIT 1"); qs1.addBindValue(std::get<0>(eInfo).getStationName());
                if (!qs1.exec() || !qs1.next()) { result["success"] = false; return result; }
                const int sid1 = qs1.value(0).toInt();
                QString cfg = RailwayPgCodec::trainToSeatConfigJson(*it);
                QSqlQuery q(db);
                q.prepare("UPDATE trains SET start_station_id = ?, end_station_id = ?, seat_config = ? WHERE train_number = ?");
                q.addBindValue(sid0); q.addBindValue(sid1); q.addBindValue(cfg); q.addBindValue(trainNumber);
                q.exec();
            }
            result["success"] = true; return result;
        }
    }
    result["success"] = false; return result;
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