#include "stationmanager.h"
#include "railway_pg_connection.h"
#include <math.h>
#include <fstream>
#include <sstream>
#include <iostream>
#include <QDebug>
#include <QVariantMap>
#include <QCoreApplication>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>

StationManager::StationManager(QObject *parent) : QObject{parent} {
    // 数据将通过DataLoader多线程加载
}

void StationManager::initializeData() {
    // 💡 自动迁移逻辑：如果云端没数据，读本地并自动上传
    if (cities.empty() || stations.empty()) {
        qDebug() << "[车站] 云端为空，从本地 txt 加载并自动迁移至云端...";
        readFromFile("../../data/station.txt", "../../data/city.txt");
        if (railwayPgIsOpen()) saveToPostgres();
    }
}

StationManager::~StationManager() {
    if (!railwayPgIsOpen()) writeToFile("../../data/station.txt", "../../data/city.txt");
}

QStringList StationManager::getCitiesName_api() {
    QStringList list;
    for (auto &city : cities) {
        list << city.getName();
    }
    return list;
}

QVariantMap StationManager::getCitiesByStationNames_api(const QString &startStationName, const QString &endStationName) {
    QVariantMap result;
    auto startStation = getStationByStationName(startStationName);
    result["startCity"] = startStation.has_value() ? startStation->getCityName() : startStationName;
    auto endStation = getStationByStationName(endStationName);
    result["endCity"] = endStation.has_value() ? endStation->getCityName() : endStationName;
    return result;
}

QVariantList StationManager::getAllStationNames_api() {
    QVariantList list;
    for (auto station : stations) {
        list << station.getStationName();
    }
    return list;
}

double StationManager::computeDistance(City &c1, City &c2) {
    const double PI = 3.14159265358979323846;
    double lon1 = c1.getLongitude() * PI / 180.0, lon2 = c2.getLongitude() * PI / 180.0;
    double lat1 = c1.getLatitude() * PI / 180.0, lat2 = c2.getLatitude() * PI / 180.0;
    double a = sin((lat1-lat2)/2)*sin((lat1-lat2)/2) + cos(lat1)*cos(lat2)*sin((lon1-lon2)/2)*sin((lon1-lon2)/2);
    double c = 2 * atan2(sqrt(a), sqrt(1-a));
    return std::round(c * 6371.0 * 100.0) / 100.0;
}

std::optional<Station> StationManager::getStationByStationName(const QString &stationName) {
    for (auto &station : stations) {
        if (station.getStationName() == stationName) return station;
    }
    return std::nullopt;
}

std::optional<City> StationManager::getCityByCityName(const QString &cityName) {
    for (auto &city : cities) {
        if (city.getName() == cityName) return city;
    }
    return std::nullopt;
}

void StationManager::readFromFileStations(const char filename[]) {
    std::fstream fis(filename, std::ios::in);
    if (!fis) { qWarning() << "车站文件不存在！"; return; }
    Station station;
    while (fis >> station) stations.push_back(station);
}

void StationManager::readFromFileCities(const char filename[]) {
    std::fstream fis(filename, std::ios::in);
    if (!fis) { qWarning() << "城市信息文件不存在！"; return; }
    City city;
    while (fis >> city) cities.push_back(city);
}

void StationManager::readFromFile(const char filenameStations[], const char filenameCities[]) {
    readFromFileStations(filenameStations);
    readFromFileCities(filenameCities);
}

void StationManager::writeToFileStations(const char filename[]) {
    std::fstream fos(filename, std::ios::out);
    if (!fos) return;
    for (auto &station : stations) fos << station << std::endl;
}

void StationManager::writeToFileCities(const char filename[]) {
    std::fstream fos(filename, std::ios::out);
    if (!fos) return;
    for (auto &city : cities) fos << city << std::endl;
}

void StationManager::writeToFile(const char filenameStations[], const char filenameCities[]) {
    writeToFileStations(filenameStations);
    writeToFileCities(filenameCities);
}

void StationManager::loadFromPostgres() {
    QSqlDatabase db = QSqlDatabase::database("railway", false);
    loadFromPostgres(db);
}

void StationManager::loadFromPostgres(QSqlDatabase &db) {
    cities.clear();
    stations.clear();
    if (!db.isOpen()) return;

    QSqlQuery qc(db);
    if (qc.exec("SELECT city_name, province, longitude, latitude FROM cities ORDER BY city_id")) {
        while (qc.next()) {
            std::ostringstream line;
            line << qc.value(0).toString().toStdString() << ' '
                 << qc.value(2).toDouble() << ' '
                 << qc.value(3).toDouble() << ' '
                 << qc.value(1).toString().toStdString();
            std::istringstream iss(line.str());
            City c;
            iss >> c;
            cities.push_back(c);
        }
    }

    QSqlQuery qs(db);
    if (qs.exec("SELECT s.station_name, c.city_name FROM stations s JOIN cities c ON c.city_id = s.city_id ORDER BY s.station_id")) {
        while (qs.next()) {
            stations.push_back(Station(qs.value(0).toString(), qs.value(1).toString()));
        }
    }
}

void StationManager::saveToPostgres() {
    QSqlDatabase db = QSqlDatabase::database("railway", false);
    if (!db.isOpen()) return;

    if (!db.transaction()) return;

    // 保存城市数据（批量操作）
    QSqlQuery qCity(db);
    qCity.prepare("INSERT INTO cities (city_name, province, longitude, latitude) VALUES (?,?,?,?) "
                  "ON CONFLICT (city_name) DO UPDATE SET province = EXCLUDED.province, "
                  "longitude = EXCLUDED.longitude, latitude = EXCLUDED.latitude");

    QVariantList cityNames, provinces, longitudes, latitudes;
    for (City &city : cities) {
        cityNames << city.getName();
        provinces << city.getProvince();
        longitudes << city.getLongitude();
        latitudes << city.getLatitude();
    }

    qCity.addBindValue(cityNames);
    qCity.addBindValue(provinces);
    qCity.addBindValue(longitudes);
    qCity.addBindValue(latitudes);

    if (!qCity.execBatch()) {
        qWarning() << "批量插入城市失败:" << qCity.lastError();
        db.rollback();
        return;
    }

    // 保存车站数据（批量操作）
    QSqlQuery qStation(db);
    qStation.prepare("INSERT INTO stations (station_name, city_id, province) VALUES (?,?,?) "
                     "ON CONFLICT (station_name) DO UPDATE SET city_id = EXCLUDED.city_id, province = EXCLUDED.province");

    QVariantList stationNames, cityIds, stationProvinces;
    for (Station &st : stations) {
        // 查找城市ID
        QSqlQuery qLookup(db);
        qLookup.prepare("SELECT city_id FROM cities WHERE city_name = ? LIMIT 1");
        qLookup.addBindValue(st.getCityName());
        if (!qLookup.exec() || !qLookup.next()) {
            qWarning() << "车站对应的城市未找到：" << st.getStationName();
            db.rollback();
            return;
        }
        const int cityId = qLookup.value(0).toInt();

        stationNames << st.getStationName();
        cityIds << cityId;
        stationProvinces << QString(); // 数据库中的 province 这里传空或默认值
    }

    qStation.addBindValue(stationNames);
    qStation.addBindValue(cityIds);
    qStation.addBindValue(stationProvinces);

    if (!qStation.execBatch()) {
        qWarning() << "批量插入车站失败:" << qStation.lastError();
        db.rollback();
        return;
    }

    db.commit();
}