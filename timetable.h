#ifndef TIMETABLE_H
#define TIMETABLE_H
#include "station.h"
#include "time.h"
#include <vector>
#include <tuple>
#include <iostream>

class Timetable
{
private:
    std::vector<std::tuple<Station, Time, Time, int, int>> table;

public:
    Timetable();

    // 输入某个车站，输出这个车站的信息（到时、发时、到天、发天、始/终/过）
    std::tuple<Time, Time, int, int, QString> getStationInfo(const QString &stationName);
    // 获得两个车站的时间间隔
    int getInterval(Station &station1, Station &station2);
    // 输入城市A和城市B，输出这个时刻表从A到B的所有车站组合
    std::vector<std::tuple<Station, Station>> getStationPairsBetweenCities(const QString &startCityName, const QString &endCityName);
    // 获得某个车站的索引（第几个停靠站）
    int getIndexByStationName(const QString &stationName);
    // 输出车站A和车站B，输出A到B经过的所有车站（包括A和B）
    std::vector<Station> getStationsBetweenStations(const Station &startStation, const Station &endStation);
    // 获得从起始站到终点站，中间每一站的信息（站，到时，发时，到达天数，发时天数，停留时间，起末站/中间站/其他站）
    std::vector<std::tuple<Station, Time, Time, int, int, int, QString>> getInfo(const QString &startStationName, const QString &endStationName);
    // 获得从起始站到终点站，中间每一站的信息（站，到时，发时，到达天数，发时天数，停留时间，起末站/中间站/其他站）重载函数
    std::vector<std::tuple<Station, Time, Time, int, int, int, QString>> getInfo();
    // 获得时刻表第一个车站的信息（站，发时）
    std::tuple<Station, Time> getStartStationInfo();
    // 获得时刻表最后一个车站的信息（站，到时）
    std::tuple<Station, Time> getEndStationInfo();
    // 在尾部插入一个停靠站
    bool insertPassingStationAtEnd(Station &station, Time &arriveTime, Time &departureTime, int arriveDay, int departureDay);

    friend bool operator==(const Timetable &t1, const Timetable &t2);
    friend bool operator!=(const Timetable &t1, const Timetable &t2);
    friend std::ostream &operator<<(std::ostream &os, Timetable &timetable);
    friend std::istream &operator>>(std::istream &is, Timetable &timetable);
};

#endif // TIMETABLE_H
