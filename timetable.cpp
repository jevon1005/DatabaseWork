#include "timetable.h"

Timetable::Timetable() {}

std::tuple<Time, Time, int, int, QString> Timetable::getStationInfo(const QString &stationName) {
    int len = table.size();
    for (int i = 0; i < len; i++) {
        Station &s = std::get<0>(table[i]);
        if (s.getStationName() == stationName) {
            Time &arrivalTime = std::get<1>(table[i]);
            Time &departureTime = std::get<2>(table[i]);
            int arriveDayOffset = std::get<3>(table[i]);
            int departureDayOffset = std::get<4>(table[i]);
            QString passInfo;
            if (i == 0) {
                passInfo = "始";
            } else if (i == len - 1) {
                passInfo = "终";
            } else {
                passInfo = "过";
            }
            return std::make_tuple(arrivalTime, departureTime, arriveDayOffset, departureDayOffset, passInfo);
        }
    }
    return std::make_tuple(Time(), Time(), -1, -1, QString("Not Found"));
}

int Timetable::getInterval(Station &station1, Station &station2) {
    std::tuple<Time, Time, int, int, QString> stationInfo1 = getStationInfo(station1.getStationName());
    std::tuple<Time, Time, int, int, QString> stationInfo2 = getStationInfo(station2.getStationName());
    Time departureTime = std::get<1>(stationInfo1);
    Time arriveTime = std::get<0>(stationInfo2);
    int departureDay = std::get<3>(stationInfo1);
    int arriveDay = std::get<2>(stationInfo2);
    int interval = (arriveTime - departureTime) + (arriveDay - departureDay) * 24 * 60 * 60;
    return interval;
}

std::vector<std::tuple<Station, Station>> Timetable::getStationPairsBetweenCities(const QString &startCityName, const QString &endCityName) {
    std::vector<std::tuple<Station, Station>> result;
    int len = table.size();
    for (int i = 0; i < len - 1; i++) {
        Station s1 = std::get<0>(table[i]);
        if (s1.getCityName() == startCityName) {
            for (int j = i + 1; j < len; j++) {
                Station s2 = std::get<0>(table[j]);
                if (s2.getCityName() == endCityName) {
                    std::tuple<Station, Station> t = std::make_tuple(s1, s2);
                    result.push_back(t);
                }
            }
        }
    }
    return result;
}

int Timetable::getIndexByStationName(const QString &stationName) {
    int len = table.size();
    for (int i = 0; i < len; i++) {
        if (std::get<0>(table[i]).getStationName() == stationName) {
            return i;
        }
    }
    return -1;
}

std::vector<Station> Timetable::getStationsBetweenStations(const Station &startStation, const Station &endStation) {
    std::vector<Station> result;
    bool flag = false;
    for (auto &stop : table) {
        Station station = std::get<0>(stop);
        if (station == startStation) {
            flag = true;
        }
        if (flag) {
            result.push_back(station);
        }
        if (station == endStation) {
            flag = false;
            break;
        }
    }
    return result;
}

std::vector<std::tuple<Station, Time, Time, int, int, int, QString>> Timetable::getInfo(const QString &startStationName, const QString &endStationName) {
    std::vector<std::tuple<Station, Time, Time, int, int, int, QString>> result;
    int startStationIndex = getIndexByStationName(startStationName);
    int endStationIndex = getIndexByStationName(endStationName);
    int len =table.size();
    for (int i = 0; i < len; i++) {
        QString info;
        if (i < startStationIndex || i > endStationIndex) {
            info = "其他站";
        }
        else if (i == startStationIndex || i == endStationIndex) {
            info = "起末站";
        }
        else {
            info = "中间站";
        }
        Time arriveTime = std::get<1>(table[i]);
        Time departureTime = std::get<2>(table[i]);
        int arriveDay = std::get<3>(table[i]);
        int departureDay = std::get<4>(table[i]);
        int stopInterval;
        if (arriveTime.isNull() || departureTime.isNull() || arriveDay == -1 || departureDay == -1) {
            stopInterval = -1;
        }
        else
            stopInterval = (departureTime - arriveTime + (departureDay - arriveDay) * 24 * 60 * 60) / 60;

        std::tuple<Station, Time, Time, int, int, int, QString> t = std::make_tuple(std::get<0>(table[i]), arriveTime, departureTime, arriveDay, departureDay, stopInterval, info);
        result.push_back(t);
    }
    return result;
}

std::vector<std::tuple<Station, Time, Time, int, int, int, QString>> Timetable::getInfo() {
    std::vector<std::tuple<Station, Time, Time, int, int, int, QString>> result;
    int startStationIndex = 0;
    int endStationIndex = table.size() - 1;
    int len =table.size();
    for (int i = 0; i < len; i++) {
        QString info;
        if (i < startStationIndex || i > endStationIndex) {
            info = "其他站";
        }
        else if (i == startStationIndex || i == endStationIndex) {
            info = "起末站";
        }
        else {
            info = "中间站";
        }
        Time arriveTime = std::get<1>(table[i]);
        Time departureTime = std::get<2>(table[i]);
        int arriveDay = std::get<3>(table[i]);
        int departureDay = std::get<4>(table[i]);
        int stopInterval;
        if (arriveTime.isNull() || departureTime.isNull() || arriveDay == -1 || departureDay == -1) {
            stopInterval = -1;
        }
        else
            stopInterval = (departureTime - arriveTime + (departureDay - arriveDay) * 24 * 60 * 60) / 60;

        std::tuple<Station, Time, Time, int, int, int, QString> t = std::make_tuple(std::get<0>(table[i]), arriveTime, departureTime, arriveDay, departureDay, stopInterval, info);
        result.push_back(t);
    }
    return result;
}

bool Timetable::insertPassingStationAtEnd(Station &station, Time &arriveTime, Time &departureTime, int arriveDay, int departureDay) {
    table.push_back(std::make_tuple(station, arriveTime, departureTime, arriveDay, departureDay));
    return true;
}

std::tuple<Station, Time> Timetable::getStartStationInfo() {
    if (table.empty()) {
        return std::make_tuple(Station(), Time());
    }
    Station startStation = std::get<0>(table[0]);
    Time departureTime = std::get<2>(table[0]);
    return std::make_tuple(startStation, departureTime);
}

std::tuple<Station, Time> Timetable::getEndStationInfo() {
    int len = table.size();
    if (len == 0) {
        return std::make_tuple(Station(), Time());
    }
    Station endStation = std::get<0>(table[len-1]);
    Time arriveTime = std::get<1>(table[len-1]);
    return std::make_tuple(endStation, arriveTime);
}

bool operator==(const Timetable &t1, const Timetable &t2) {
    return t1.table == t2.table;
}

bool operator!=(const Timetable &t1, const Timetable &t2) {
    return !(t1 == t2);
}

std::ostream &operator<<(std::ostream &os, Timetable &timetable) {
    os << timetable.table.size() << std::endl;
    for (auto &entry : timetable.table) {
        Station &station = std::get<0>(entry);
        Time &arrival = std::get<1>(entry);
        Time &departure = std::get<2>(entry);
        int startDayOffset = std::get<3>(entry);
        int endDayOffset = std::get<4>(entry);
        os << station << " " << arrival << " " << departure << " " << startDayOffset << " " << endDayOffset << std::endl;
    }
    return os;
}

std::istream &operator>>(std::istream &is, Timetable &timetable) {
    timetable.table.clear();
    Station station;
    Time arrival, departure;
    int startDayOffset, endDayOffset;
    int count;
    is >> count;
    timetable.table.resize(count);
    for (int i = 0; i < count; ++i) {
        is >> station >> arrival >> departure >> startDayOffset >> endDayOffset;
        timetable.table[i] = std::make_tuple(station, arrival, departure, startDayOffset, endDayOffset);
    }
    return is;
}
