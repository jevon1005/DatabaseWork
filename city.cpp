#include "city.h"
#include <iostream>
#include <iomanip>

City::City() {}

QString City::getName() {
    return name;
}

double City::getLongitude() {
    return longitude;
}

double City::getLatitude() {
    return latitude;
}

QString City::getProvince() {
    return province;
}

bool operator==(const City &c1, const City &c2) {
    return c1.name == c2.name &&
           c1.longitude == c2.longitude &&
           c1.latitude == c2.latitude;
}

bool operator!=(const City &c1, const City &c2) {
    return !(c1 == c2);
}

std::istream& operator>>(std::istream& is, City& c) {
    std::string nameStd;
    std::string provinceStd;
    is >> nameStd >> c.longitude >> c.latitude >> provinceStd;
    c.name = QString::fromStdString(nameStd);
    c.province = QString::fromStdString(provinceStd);
    return is;
}

std::ostream& operator<<(std::ostream& os, const City& c) {
    os << c.name.toStdString() << " "
       << std::fixed << std::setprecision(4) << c.longitude << " "
       << std::fixed << std::setprecision(4) << c.latitude << " "
       << c.province.toStdString();
    return os;
}
