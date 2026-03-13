#include "date.h"
#include <iomanip>
#include <QChar>

Date::Date() {}

Date::Date(int year, int month, int day)
    : year(year), month(month), day(day) {}

int Date::getYear() {
    return year;
}

bool Date::setYear(int year) {
    this->year = year;
    return true;
}

int Date::getMonth() {
    return month;
}

bool Date::setMonth(int month) {
    this->month = month;
    return true;
}

int Date::getDay() {
    return day;
}

bool Date::setDay(int day) {
    this->day = day;
    return true;
}

// 判断是否闰年
bool isLeapYear(int year) {
    if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0))
        return true;
    return false;
}

// 获取某年某月的天数
int getDaysInMonth(int year, int month) {
    int daysInMonth[] = {0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    if (month == 2 && isLeapYear(year))
        return 29;
    return daysInMonth[month];
}

bool Date::now() {
    std::time_t now = std::time(nullptr); // 当前时间戳
    std::tm* local_time = std::localtime(&now);
    // 分别转换成整型
    int year   = local_time->tm_year + 1900;
    int month  = local_time->tm_mon + 1;
    int day    = local_time->tm_mday;

    this->year = year;
    this->month = month;
    this->day = day;

    return true;
}

Date operator+(const Date &d, int days) {
    Date result = d;
    result.day += days;
    while (true) {
        int daysInCurrentMonth = getDaysInMonth(result.year, result.month);
        if (result.day <= daysInCurrentMonth)
            break;
        result.day -= daysInCurrentMonth;
        result.month++;
        if (result.month > 12) {
            result.month = 1;
            result.year++;
        }
    }
    return result;
}

Date operator-(const Date &d, int days) {
    Date result = d;
    result.day -= days;
    while (result.day <= 0) {
        result.month--;
        if (result.month < 1) {
            result.month = 12;
            result.year--;
        }
        result.day += getDaysInMonth(result.year, result.month);
    }
    return result;
}

int operator-(const Date &d1, const Date &d2) {
    Date start = d2;
    Date end = d1;
    int days = 0;
    while (start.year < end.year || start.month < end.month || start.day < end.day) {
        days++;
        start = start + 1;
    }
    return days;
}

bool operator<(const Date &d1, const Date &d2) {
    if (d1.year != d2.year)
        return d1.year < d2.year;
    if (d1.month != d2.month)
        return d1.month < d2.month;
    return d1.day < d2.day;
}

bool operator>(const Date &d1, const Date &d2) {
    return !(d1 < d2) && (d1 != d2);
}

bool operator>=(const Date &d1, const Date &d2) {
    return (d1 > d2) || (d1 == d2);
}

bool operator<=(const Date &d1, const Date &d2) {
    return (d1 < d2) || (d1 == d2);
}

bool operator==(const Date &d1, const Date &d2) {
    return d1.year == d2.year &&
           d1.month == d2.month &&
           d1.day == d2.day;
}

bool operator!=(const Date &d1, const Date &d2) {
    return !(d1 == d2);
}

std::ostream &operator<<(std::ostream &os, const Date &d) {
    os << std::setw(4) << std::setfill('0') << d.year << "-"
       << std::setw(2) << std::setfill('0') << d.month << "-"
       << std::setw(2) << std::setfill('0') << d.day;
    return os;
}

std::istream &operator>>(std::istream &is, Date &d) {
    char delimiter1, delimiter2;
    is >> d.year >> delimiter1 >> d.month >> delimiter2 >> d.day;
    return is;
}
