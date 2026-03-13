#ifndef CITY_H
#define CITY_H

#include <QString>

class City
{
private:
    QString name = "";
    double longitude;
    double latitude;
    QString province = "";
public:
    City();

    QString getName();
    double getLongitude();
    double getLatitude();
    QString getProvince();

    friend bool operator==(const City &c1, const City &c2);
    friend bool operator!=(const City &c1, const City &c2);
    friend std::istream& operator>>(std::istream& is, City& c);
    friend std::ostream& operator<<(std::ostream& os, const City& c);
};

#endif // CITY_H
