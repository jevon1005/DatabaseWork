#include "station.h"
#include <iostream>

Station::Station() {}

Station::Station(const QString &stationName, const QString &cityName)
    : station_name(stationName), city_name(cityName) {}

QString Station::getStationName() {
    return station_name;
}

QString Station::getCityName() {
    return city_name;
}

bool Station::setStationName(const QString &name) {
    station_name = name;
    return true;
}

bool Station::setCityName(const QString &name) {
    city_name = name;
    return true;
}

bool operator==(const Station &s1, const Station &s2) {
    return s1.station_name == s2.station_name &&
           s1.city_name == s2.city_name;
}

bool operator!=(const Station &s1, const Station &s2) {
    return !(s1 == s2);
}

std::istream& operator>>(std::istream& is, Station& s) {
    std::string stationNameStd, cityNameStd;
    is >> stationNameStd >> cityNameStd;
    s.station_name = QString::fromStdString(stationNameStd);
    s.city_name = QString::fromStdString(cityNameStd);
    return is;
}

std::ostream& operator<<(std::ostream& os, const Station& s) {
    os << s.station_name.toStdString() << " " << s.city_name.toStdString();
    return os;
}
