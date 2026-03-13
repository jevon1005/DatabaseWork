#ifndef TRAINMANAGER_H
#define TRAINMANAGER_H

#include <QObject>
#include <vector>
#include <QVariantList>
#include <QVariantMap>
#include <optional>
#include "train.h"

class TrainManager : public QObject
{
    Q_OBJECT

private:
    std::vector<Train> trains;

public:
    explicit TrainManager(QObject *parent = nullptr);
    Q_INVOKABLE QVariantList getTrains_api();
    Q_INVOKABLE QVariantMap deleteTrain_api(const QString &trainNumber);
    // 通过车次号获得该车次的时刻表信息(默认第一个起始站,最后一个终点站)
    Q_INVOKABLE QVariantList getTimetableInfo_api(const QString &trainNumber);
    // 通过车次号和起末站获得该车次的时刻表信息
    Q_INVOKABLE QVariantList getTimetableInfo_api(const QString &trainNumber, const QString &startStationName, const QString &endStationName);
    // 通过车次号获取车厢配置信息
    Q_INVOKABLE QVariantList getCarriages_api(const QString &trainNumber);
    // 通过车次号更新该车次的时刻表信息和车次号
    QVariantMap updateTimetableAndTrainNumberByTrainNumber(const QString &oldTrainNumber, Timetable &timetable, const QString &newTrainNumber);
    // 通过车次号更新该车次的座位模板
    QVariantMap updateSeatTemplateByTrainNumber(const QString &trainNumber, std::vector<std::tuple<QString, int, int>> carriages);
    std::vector<std::tuple<Train, Station, Station>> getRoutesByCities(const QString &startCityName, const QString &endCityName);
    std::optional<Train> getTrainByTrainNumber(const QString &trainNumber);

private:
    bool readFromFile(const char filename[]);
    bool writeToFile(const char filename[]);

signals:
};

#endif // TRAINMANAGER_H
