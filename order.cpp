#include "order.h"
#include <iomanip>

Order::Order() {}

Order::Order(const QString &orderNumber, const QString &trainNumber,
             const Passenger &passenger, double price, const Date &date,
             const Timetable &timetable, const Station &startStation,
             const Station &endStation, const QString &seatLevel,
             int carriageNumber, int seatRow, int seatCol,
             const QString &status, const QString &username)
    : order_number(orderNumber),
      train_number(trainNumber),
      passenger(passenger),
      price(price),
      date(date),
      timetable(timetable),
      start_station(startStation),
      end_station(endStation),
      seat_level(seatLevel),
      carriage_number(carriageNumber),
      seat_row(seatRow),
      seat_col(seatCol),
      status(status),
      username(username) {}

QString Order::getOrderNumber() {
    return order_number;
}

bool Order::setOrderNumber(const QString &orderNumber) {
    order_number = orderNumber;
    return true;
}

QString Order::getTrainNumber() {
    return train_number;
}

bool Order::setTrainNumber(const QString &trainNumber) {
    train_number = trainNumber;
    return true;
}

Passenger Order::getPassenger() {
    return passenger;
}

bool Order::setPassenger(const Passenger &passenger) {
    this->passenger = passenger;
    return true;
}

double Order::getPrice() {
    return price;
}

bool Order::setPrice(double price) {
    this->price = price;
    return true;
}

Date Order::getDate() {
    return date;
}

bool Order::setDate(const Date &date) {
    this->date = date;
    return true;
}

Station Order::getStartStation() {
    return start_station;
}

bool Order::setStartStation(const Station &startStation) {
    this->start_station = startStation;
    return true;
}

Station Order::getEndStation() {
    return end_station;
}

bool Order::setEndStation(const Station &endStation) {
    this->end_station = endStation;
    return true;
}

Timetable Order::getTimetable() {
    return timetable;
}

bool Order::setTimetable(const Timetable &timetable) {
    this->timetable = timetable;
    return true;
}

QString Order::getSeatLevel() {
    return seat_level;
}

bool Order::setSeatLevel(const QString &seatLevel) {
    seat_level = seatLevel;
    return true;
}

int Order::getCarriageNumber() {
    return carriage_number;
}

bool Order::setCarriageNumber(int carriageNumber) {
    this->carriage_number = carriageNumber;
    return true;
}

int Order::getSeatRow() {
    return seat_row;
}

bool Order::setSeatRow(int seatRow) {
    this->seat_row = seatRow;
    return true;
}

int Order::getSeatCol() {
    return seat_col;
}

bool Order::setSeatCol(int seatCol) {
    this->seat_col = seatCol;
    return true;
}

QString Order::getStatus() {
    return status;
}

bool Order::setStatus(const QString &status) {
    this->status = status;
    return true;
}

QString Order::getUsername() {
    return username;
}

bool Order::setUsername(const QString &username) {
    this->username = username;
    return true;
}

Date Order::getEndDate() {
    Date startDate = date;
    std::tuple<Time, Time, int, int, QString> startStationInfo = timetable.getStationInfo(start_station.getStationName());
    std::tuple<Time, Time, int, int, QString> endStationInfo = timetable.getStationInfo(end_station.getStationName());
    Date endDate = startDate + std::get<2>(endStationInfo) - std::get<3>(startStationInfo);

    return endDate;
}

Time Order::getStartTime() {
    std::tuple<Time, Time, int, int, QString> startStationInfo = timetable.getStationInfo(start_station.getStationName());
    std::tuple<Time, Time, int, int, QString> endStationInfo = timetable.getStationInfo(end_station.getStationName());
    Time startTime = std::get<1>(startStationInfo);

    return startTime;
}

Time Order::getEndTime() {
    std::tuple<Time, Time, int, int, QString> startStationInfo = timetable.getStationInfo(start_station.getStationName());
    std::tuple<Time, Time, int, int, QString> endStationInfo = timetable.getStationInfo(end_station.getStationName());
    Time endTime = std::get<0>(endStationInfo);

    return endTime;
}

bool Order::isTimeRangeOverlap(Date &queryStartDate, Time &queryStartTime, Date &queryEndDate, Time &queryEndTime) {
    Date orderStartDate = date;
    Date orderEndDate = getEndDate();
    Time orderStartTime = getStartTime();
    Time orderEndTime = getEndTime();

    // 先判断日期区间是否有交集
    if (orderEndDate < queryStartDate || queryEndDate < orderStartDate) {
        return false;
    }
    // 日期区间有交集，进一步判断时间
    // 统一将区间转为 [start, end]，比较是否有重叠
    // 情况1：区间1在区间2前面
    if (orderEndDate == queryStartDate) {
        if (orderEndTime < queryStartTime) return false;
    }
    // 情况2：区间2在区间1前面
    if (queryEndDate == orderStartDate) {
        if (queryEndTime < orderStartTime) return false;
    }
    // 其它情况均视为有重叠
    return true;
}

bool operator==(const Order &o1, const Order &o2) {
    return o1.order_number == o2.order_number &&
           o1.train_number == o2.train_number &&
           o1.passenger == o2.passenger &&
           o1.price == o2.price &&
           o1.date == o2.date &&
           o1.timetable == o2.timetable &&
           o1.start_station == o2.start_station &&
           o1.end_station == o2.end_station &&
           o1.seat_level == o2.seat_level &&
           o1.carriage_number == o2.carriage_number &&
           o1.seat_row == o2.seat_row &&
           o1.seat_col == o2.seat_col &&
           o1.status == o2.status &&
           o1.username == o2.username;
}

bool operator!=(const Order &o1, const Order &o2) {
    return !(o1 == o2);
}

std::ostream &operator<<(std::ostream &os, Order &o) {
    os << o.order_number.toStdString() << " " << o.train_number.toStdString() << " " << std::endl
       << o.passenger << std::endl
       << std::fixed << std::setprecision(2) << o.price << " " << o.date << std::endl
       << o.start_station << std::endl
       << o.end_station << std::endl
       << o.timetable
       << o.seat_level.toStdString() << " " << o.carriage_number << " " << o.seat_row << " " << o.seat_col << " "
       << o.status.toStdString() << " " << o.username.toStdString() << std::endl;
    return os;
}

std::istream &operator>>(std::istream &is, Order &o) {
    std::string orderNumber, trainNumber, seat_level, status, username;
    is >> orderNumber >> trainNumber >> o.passenger >> o.price
       >> o.date >> o.start_station >> o.end_station 
       >> o.timetable >> seat_level >> o.carriage_number
       >> o.seat_row >> o.seat_col >> status >> username;
    o.setOrderNumber(QString::fromStdString(orderNumber));
    o.setTrainNumber(QString::fromStdString(trainNumber));
    o.setSeatLevel(QString::fromStdString(seat_level));
    o.setStatus(QString::fromStdString(status));
    o.setUsername(QString::fromStdString(username));
    return is;
}
