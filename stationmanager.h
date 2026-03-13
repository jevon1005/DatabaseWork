#ifndef STATIONMANAGER_H
#define STATIONMANAGER_H
#include <QObject>
#include <vector>
#include "station.h"
#include "city.h"

class StationManager : public QObject
{
    Q_OBJECT

private:
    std::vector<Station> stations;
    std::vector<City> cities;

public:
    explicit StationManager(QObject *parent = nullptr);
    Q_INVOKABLE QStringList getCitiesName_api();
    Q_INVOKABLE QVariantMap getCitiesByStationNames_api(const QString &startStationName, const QString &endStationName);
    // 时刻表修改、添加时，需要获取所有的车站名
    Q_INVOKABLE QVariantList getAllStationNames_api();
    double computeDistance(City &c1, City &c2);
    std::optional<Station> getStationByStationName(const QString &stationName);
    std::optional<City> getCityByCityName(const QString &cityName);

private:
    void readFromFileStations(const char filename[]);
    void readFromFileCities(const char filename[]);
    void readFromFile(const char filenameStations[], const char filenameCities[]);
    void writeToFileStations(const char filename[]);
    void writeToFileCities(const char filename[]);
    void writeToFile(const char filenameStations[], const char filenameCities[]);
};

#endif // STATIONMANAGER_H
