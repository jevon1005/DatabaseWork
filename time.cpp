#include "time.h"
#include <iomanip>

Time::Time() {}

Time::Time(int hour, int minute, int second)
    : hour(hour), minute(minute), second(second) {
    if (hour < 0 || hour > 23 ||
        minute < 0 || minute > 59 ||
        second < 0 || second > 59) {
        setNull();
    }
}

int Time::getHour() {
    return hour;
}

bool Time::setHour(int hour) {
    this->hour = hour;
    return true;
}

int Time::getMinute() {
    return minute;
}

bool Time::setMinute(int minute) {
    this->minute = minute;
    return true;
}

int Time::getSecond() {
    return second;
}

bool Time::setSecond(int second) {
    this->second = second;
    return true;
}

bool Time::isNull() {
    if (hour == -1 || minute == -1 || second == -1) {
        return true;
    }
    return false;
}

bool Time::setNull() {
    hour = -1;
    minute = -1;
    second = -1;
    return true;
}

bool Time::now() {
    std::time_t now = std::time(nullptr); // 当前时间戳
    std::tm* local_time = std::localtime(&now);
    // 分别转换成整型;
    int hour   = local_time->tm_hour;
    int minute = local_time->tm_min;
    int second = local_time->tm_sec;

    this->hour = hour;
    this->minute = minute;
    this->second = second;

    return true;
}

bool operator==(const Time &t1, const Time &t2) {
    return t1.hour == t2.hour &&
           t1.minute == t2.minute &&
           t1.second == t2.second;
}

bool operator!=(const Time &t1, const Time &t2) {
    return !(t1 == t2);
}

int operator-(const Time &t1, const Time &t2) {
    int totalSeconds1 = t1.hour * 3600 + t1.minute * 60 + t1.second;
    int totalSeconds2 = t2.hour * 3600 + t2.minute * 60 + t2.second;
    return totalSeconds1 - totalSeconds2;
}

bool operator<(const Time &t1, const Time &t2) {
    if (t1.hour != t2.hour) {
        return t1.hour < t2.hour;
    }
    if (t1.minute != t2.minute) {
        return t1.minute < t2.minute;
    }
    return t1.second < t2.second;
}

std::ostream &operator<<(std::ostream &os, Time &t) {
    if (t.isNull()) {
        os << "---";
    }
    else {
        os << std::setw(2) << std::setfill('0') << t.hour << ":"
           << std::setw(2) << std::setfill('0') << t.minute << ":"
           << std::setw(2) << std::setfill('0') << t.second;
    }

    return os;
}

std::istream &operator>>(std::istream &is, Time &t) {
    std::string input;
    is >> input;
    if (input == "---") {
        t.setNull();
    } else {
        std::istringstream ss(input);
        char delimiter1, delimiter2;
        ss >> t.hour >> delimiter1 >> t.minute >> delimiter2 >> t.second;
    }
    return is;
}
