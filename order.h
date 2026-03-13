#ifndef ORDER_H
#define ORDER_H
#include <QString>
#include "passenger.h"
#include "timetable.h"
#include "date.h"

class Order
{
private:
    QString order_number = "";
    QString train_number = "";
    Passenger passenger;
    double price = -1;
    Date date;
    Station start_station;
    Station end_station;
    Timetable timetable;
    QString seat_level = "";
    int carriage_number = -1;
    int seat_row = -1;
    int seat_col = -1;
    QString status = "";
    QString username = "";

public:
    Order();
    Order(const QString &orderNumber, const QString &trainNumber,
          const Passenger &passenger, double price, const Date &date,
          const Timetable &timetable, const Station &startStation,
          const Station &endStation, const QString &seatLevel,
          int carriageNumber, int seatRow, int seatCol,
          const QString &status, const QString &username);

    QString getOrderNumber();
    bool setOrderNumber(const QString &orderNumber);
    QString getTrainNumber();
    bool setTrainNumber(const QString &trainNumber);
    Passenger getPassenger();
    bool setPassenger(const Passenger &passenger);
    double getPrice();
    bool setPrice(double price);
    Date getDate();
    bool setDate(const Date &date);
    Station getStartStation();
    bool setStartStation(const Station &startStation);
    Station getEndStation();
    bool setEndStation(const Station &endStation);
    Timetable getTimetable();
    bool setTimetable(const Timetable &timetable);
    QString getSeatLevel();
    bool setSeatLevel(const QString &seatLevel);
    int getCarriageNumber();
    bool setCarriageNumber(int carriageNumber);
    int getSeatRow();
    bool setSeatRow(int seatRow);
    int getSeatCol();
    bool setSeatCol(int seatCol);
    QString getStatus();
    bool setStatus(const QString &status);
    QString getUsername();
    bool setUsername(const QString &username);

    Date getEndDate();
    Time getStartTime();
    Time getEndTime();
    bool isTimeRangeOverlap(Date &queryStartDate, Time &queryStartTime, Date &queryEndDate, Time &queryEndTimeww);

    friend bool operator==(const Order &o1, const Order &o2);
    friend bool operator!=(const Order &o1, const Order &o2);
    friend std::ostream &operator<<(std::ostream &os, Order &o);
    friend std::istream &operator>>(std::istream &is, Order &o);
};

#endif // ORDER_H
