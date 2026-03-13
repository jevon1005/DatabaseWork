#include "userprofile.h"
#include <iostream>

UserProfile::UserProfile() {}

UserProfile::UserProfile(const QString &name,
                         const QString &phone_number,
                         const QString &id) {
    this->name = name;
    this->phone_number = phone_number;
    this->id = id;
}

QString UserProfile::getName() {
    return name;
}

bool UserProfile::setName(const QString &name) {
    this->name = name;
    return true;
}

QString UserProfile::getPhoneNumber() {
    return phone_number;
}

bool UserProfile::setPhoneNumber(const QString &phone_number) {
    this->phone_number = phone_number;
    return true;
}

QString UserProfile::getId() {
    return id;
}

bool UserProfile::setId(const QString &id) {
    this->id = id;
    return true;
}

bool operator==(const UserProfile &up1, const UserProfile &up2) {
    return (up1.name == up2.name) && (up1.phone_number == up2.phone_number) && (up1.id == up2.id);
}

bool operator!=(const UserProfile &up1, const UserProfile &up2) {
    return !(up1 == up2);
}

std::istream& operator>>(std::istream& is, UserProfile& up) {
    std::string name, phone_number, id;
    is >> name >> phone_number >> id;
    up.name = QString::fromStdString(name);
    up.phone_number = QString::fromStdString(phone_number);
    up.id = QString::fromStdString(id);
    return is;
}

std::ostream& operator<<(std::ostream& os, const UserProfile& up) {
    os << up.name.toStdString() << " " << up.phone_number.toStdString() << " " << up.id.toStdString();
    return os;
}
