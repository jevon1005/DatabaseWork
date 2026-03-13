#ifndef DATE_H
#define DATE_H
#include <iostream>

class Date
{
private:
    int year = -1;
    int month = -1;
    int day = -1;

public:
    Date();
    Date(int year, int month, int day);
    int getYear();
    bool setYear(int year);
    int getMonth();
    bool setMonth(int month);
    int getDay();
    bool setDay(int day);

    bool now();

    friend Date operator+(const Date &d, int days);
    friend Date operator-(const Date &d, int days);
    friend int operator-(const Date &d1, const Date &d2);
    friend bool operator<(const Date &d1, const Date &d2);
    friend bool operator>(const Date &d1, const Date &d2);
    friend bool operator>=(const Date &d1, const Date &d2);
    friend bool operator<=(const Date &d1, const Date &d2);
    friend bool operator==(const Date &d1, const Date &d2);
    friend bool operator!=(const Date &d1, const Date &d2);
    friend std::ostream &operator<<(std::ostream &os, const Date &d);
    friend std::istream &operator>>(std::istream &is, Date &d);
};

#endif // DATE_H
