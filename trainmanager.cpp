#include "trainmanager.h"
#include <iostream>
#include <fstream>
#include <QDebug>
#include <QCoreApplication>

TrainManager::TrainManager(QObject *parent)
    : QObject{parent}
{
    readFromFile("../../data/train.txt");
    connect(qApp, &QCoreApplication::aboutToQuit, this, [this]() {
        this->writeToFile("../../data/train.txt");
    });
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
        map["startHour"] = startTime.getHour();
        map["startMinute"] = startTime.getMinute();
        map["endStationName"] = endStation.getStationName();
        map["endHour"] = endTime.getHour();
        map["endMinute"] = endTime.getMinute();

        int intervalSeconds = train.getTimetable().getInterval(startStation, endStation);
        int hours = intervalSeconds / 3600, minutes = (intervalSeconds % 3600) / 60;
        map["intervalHour"] = hours;
        map["intervalMinute"] = minutes;

        list << map;
    }
    return list;
}

QVariantMap TrainManager::deleteTrain_api(const QString &trainNumber) {
    QVariantMap result;
    for (auto it = trains.begin(); it != trains.end(); it++) {
        if (it->getNumber() == trainNumber) {
            result["success"] = true;
            result["message"] = QString("车次 %1 删除成功！").arg(trainNumber);
            trains.erase(it);
            return result;
        }
    }
    result["success"] = false;
    result["message"] = QString("未找到车次 %1").arg(trainNumber);
    return result;
}

QVariantList TrainManager::getTimetableInfo_api(const QString &trainNumber) {
    QVariantList list;
    auto findResult = getTrainByTrainNumber(trainNumber);
    if (!findResult) {
        return list;
    }
    Train &train = findResult.value();
    std::vector<std::tuple<Station, Time, Time, int, int, int, QString>> info = train.getTimetable().getInfo();
    
    for (auto &t : info) {
        QVariantMap map;
        Station station = std::get<0>(t);
        Time arriveTime = std::get<1>(t);
        Time departureTime = std::get<2>(t);
        int arriveDay = std::get<3>(t);
        int departureDay = std::get<4>(t);
        int stopInterval = std::get<5>(t);
        QString passInfo = std::get<6>(t);
        
        map["stationName"] = station.getStationName();
        map["arriveHour"] = arriveTime.getHour();
        map["arriveMinute"] = arriveTime.getMinute();
        map["arriveDay"] = arriveDay;
        map["departureHour"] = departureTime.getHour();
        map["departureMinute"] = departureTime.getMinute();
        map["departureDay"] = departureDay;
        map["stopInterval"] = stopInterval;
        map["passInfo"] = passInfo;
        list << map;
    }
    return list;
}

QVariantList TrainManager::getTimetableInfo_api(const QString &trainNumber, const QString &startStationName, const QString &endStationName) {
    QVariantList list;
    auto findResult = getTrainByTrainNumber(trainNumber);
    if (!findResult) {
        return list;
    }
    Train &train = findResult.value();
    std::vector<std::tuple<Station, Time, Time, int, int, int, QString>> info = train.getTimetable().getInfo(startStationName, endStationName);
    
    for (auto &t : info) {
        QVariantMap map;
        Station station = std::get<0>(t);
        Time arriveTime = std::get<1>(t);
        Time departureTime = std::get<2>(t);
        int arriveDay = std::get<3>(t);
        int departureDay = std::get<4>(t);
        int stopInterval = std::get<5>(t);
        QString passInfo = std::get<6>(t);
        
        map["stationName"] = station.getStationName();
        map["arriveHour"] = arriveTime.getHour();
        map["arriveMinute"] = arriveTime.getMinute();
        map["arriveDay"] = arriveDay;
        map["departureHour"] = departureTime.getHour();
        map["departureMinute"] = departureTime.getMinute();
        map["departureDay"] = departureDay;
        map["stopInterval"] = stopInterval;
        map["passInfo"] = passInfo;
        list << map;

        qWarning() << station.getStationName();
    }
    return list;
}

QVariantList TrainManager::getCarriages_api(const QString &trainNumber) {
    QVariantList list;
    auto findResult = getTrainByTrainNumber(trainNumber);
    if (!findResult) {
        qWarning() << "未找到车次:" << trainNumber;
        return list;
    }
    Train &train = findResult.value();
    std::vector<std::tuple<QString, int, int>> carriages = train.getCarriages();
    
    for (const auto &carriage : carriages) {
        QVariantMap map;
        map["seatLevel"] = std::get<0>(carriage);
        map["rows"] = std::get<1>(carriage);
        map["cols"] = std::get<2>(carriage);
        list << map;
    }
    
    qWarning() << "获取车次" << trainNumber << "的车厢数量:" << list.size();
    return list;
}

QVariantMap TrainManager::updateTimetableAndTrainNumberByTrainNumber(const QString &oldTrainNumber, Timetable &timetable, const QString &newTrainNumber) {
    QVariantMap result;
    
    // 如果 oldTrainNumber 为空，说明是添加新车次
    if (oldTrainNumber == "") {
        // 检查新车次号是否已存在
        auto findTrainResult = getTrainByTrainNumber(newTrainNumber);
        if (findTrainResult) {
            result["success"] = false;
            result["message"] = QString("车次 %1 已存在！").arg(newTrainNumber);
            return result;
        }
        // 创建新车次
        Train newTrain;
        newTrain.setNumber(newTrainNumber);
        newTrain.setTimetable(timetable);
        trains.push_back(newTrain);
        result["success"] = true;
        result["message"] = QString("添加成功！");
        return result;
    }
    
    // 如果新车次号和旧车次号不同，检查新车次号是否已存在
    if (oldTrainNumber != newTrainNumber) {
        auto findTrainResult = getTrainByTrainNumber(newTrainNumber);
        if (findTrainResult) {
            result["success"] = false;
            result["message"] = QString("车次 %1 已存在！").arg(newTrainNumber);
            return result;
        }
    }
    
    // 修改现有车次
    for (auto &train : trains) {
        if (train.getNumber() == oldTrainNumber) {
            train.setTimetable(timetable);
            train.setNumber(newTrainNumber);
            result["success"] = true;
            result["message"] = QString("更新成功！");
            return result;
        }
    }
    result["success"] = false;
    result["message"] = QString("未找到车次 %1，更新失败！").arg(oldTrainNumber);
    return result;
}

QVariantMap TrainManager::updateSeatTemplateByTrainNumber(const QString &trainNumber, std::vector<std::tuple<QString, int, int> > carriages) {
    QVariantMap result;
    for (auto it = trains.begin(); it != trains.end(); it++) {
        if (it->getNumber() == trainNumber) {
            it->setCarriages(carriages);
            result["success"] = true;
            result["message"] = "修改成功！";
            return result;
        }
    }
    result["success"] = false;
    result["message"] = QString("车次 %1 不存在！").arg(trainNumber);
    return result;
}

std::vector<std::tuple<Train, Station, Station>> TrainManager::getRoutesByCities(const QString &startCityName, const QString &endCityName) {
    std::vector<std::tuple<Train, Station, Station>> result;
    for (auto &train : trains) {
        std::vector<std::tuple<Station, Station>> stationPairs = train.getTimetable().getStationPairsBetweenCities(startCityName, endCityName);
        for (auto &pair : stationPairs) {
            Station s1 = std::get<0>(pair);
            Station s2 = std::get<1>(pair);
            std::tuple<Train, Station, Station> t = std::make_tuple(train, s1, s2);
            result.push_back(t);
        }
    }
    return result;
}

std::optional<Train> TrainManager::getTrainByTrainNumber(const QString &trainNumber) {
    for (auto &train : trains) {
        if (train.getNumber() == trainNumber) {
            return train;
        }
    }
    return std::nullopt;
}


bool TrainManager::readFromFile(const char filename[]) {
    std::fstream fis(filename, std::ios::in);
    if (!fis) {
        qWarning() << "列车文件不存在！";
        return false;
    }
    Train train;
    while (fis >> train) {
        trains.push_back(train);
    }
    return true;
}

bool TrainManager::writeToFile(const char filename[]) {
    std::fstream fos(filename, std::ios::out);
    if (!fos) {
        qWarning() << "无法打开列车文件进行写入！";
        return false;
    }
    for (auto &train : trains) {
        fos << train << std::endl;
    }
    return true;
}
