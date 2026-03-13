#ifndef TIME_H
#define TIME_H
#include <iostream>

class Time
{
private:
    int hour = -1;
    int minute = -1;
    int second = -1;

public:
    Time();
    Time(int hour, int minute, int second=0);

    int getHour();
    bool setHour(int hour);
    int getMinute();
    bool setMinute(int minute);
    int getSecond();
    bool setSecond(int second);
    bool isNull();
    bool setNull();

    bool now();
    
    friend bool operator==(const Time &t1, const Time &t2);
    friend bool operator!=(const Time &t1, const Time &t2);
    friend int operator-(const Time &t1, const Time &t2);
    friend bool operator<(const Time &t1, const Time &t2);
    friend std::ostream &operator<<(std::ostream &os, Time &t);
    friend std::istream &operator>>(std::istream &is, Time &t);
};

#endif // TIME_H
