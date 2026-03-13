#include "train.h"
#include <iostream>
#include <QDebug>

Train::Train() {}

QString Train::getNumber() {
    return number;
}

bool Train::setNumber(const QString &number) {
    this->number = number;
    return true;
}

Timetable Train::getTimetable() {
    return timetable;
}

bool Train::setTimetable(Timetable &timetable) {
    this->timetable = timetable;
    return true;
}

std::vector<std::tuple<QString, int, int>> Train::getCarriages(){
    return carriages;
}

bool Train::setCarriages(std::vector<std::tuple<QString, int, int>> carriages) {
    this->carriages = carriages;
    return true;
}

int Train::getFirstClassCount() {
    int len = carriages.size();
    int count = 0;
    for (int i = 0; i < len; i++) {
        if (std::get<0>(carriages[i]) == "一等座") {
            count += std::get<1>(carriages[i]) * std::get<2>(carriages[i]);
        }
    }
    return count;
}

int Train::getSecondClassCount() {
    int len = carriages.size();
    int count = 0;
    for (int i = 0; i < len; i++) {
        if (std::get<0>(carriages[i]) == "二等座") {
            count += std::get<1>(carriages[i]) * std::get<2>(carriages[i]);
        }
    }
    return count;
}

int Train::getBusinessClassCount() {
    int len = carriages.size();
    int count = 0;
    for (int i = 0; i < len; i++) {
        if (std::get<0>(carriages[i]) == "商务座") {
            count += std::get<1>(carriages[i]) * std::get<2>(carriages[i]);
        }
    }
    return count;
}

bool operator==(const Train &t1, const Train &t2) {
    return t1.number == t2.number &&
           t1.timetable == t2.timetable &&
           t1.carriages == t2.carriages;
}

bool operator!=(const Train &t1, const Train &t2) {
    return !(t1 == t2);
}

std::istream &operator>>(std::istream &is, Train &train) {
    std::string number;
    is >> number;
    if (number == "") {
        return is;
    }
    train.number = QString::fromStdString(number);
    is >> train.timetable;
    int carriageCount;
    is >> carriageCount;
    train.carriages.resize(carriageCount);
    for (int i = 0; i < carriageCount; ++i) {
        std::string seatLevel;
        int seatRow, seatCol;
        is >> seatLevel >> seatRow >> seatCol;
        train.carriages[i] = std::make_tuple(QString::fromStdString(seatLevel), seatRow, seatCol);
    }
    qWarning() << "加载车次的车厢数量：" << train.getNumber() << train.getCarriages().size();
    return is;
}

std::ostream &operator<<(std::ostream &os, Train &train) {
    os << train.number.toStdString() << std::endl;
    os << train.timetable;
    os << train.carriages.size() << std::endl;
    for (auto &carriage : train.carriages) {
        os << std::get<0>(carriage).toStdString() << " "
           << std::get<1>(carriage) << " "
           << std::get<2>(carriage) << std::endl;
    }
    return os;
}

