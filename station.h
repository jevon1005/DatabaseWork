#ifndef STATION_H
#define STATION_H
#include <vector>
#include "city.h"

class Station
{
private:
    QString station_name = "";
    QString city_name = "";

public:
    Station();
    Station(const QString &stationName, const QString &cityName);

    QString getStationName();
    QString getCityName();
    bool setStationName(const QString &name);
    bool setCityName(const QString &name);

    friend bool operator==(const Station &s1, const Station &s2);
    friend bool operator!=(const Station &s1, const Station &s2);
    friend std::istream& operator>>(std::istream& is, Station& s);
    friend std::ostream& operator<<(std::ostream& os, const Station& s);
};

#endif // STATION_H
