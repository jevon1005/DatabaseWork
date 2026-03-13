#include "passenger.h"

Passenger::Passenger() {}

Passenger::Passenger(const QString &name, const QString &phoneNumber,
                     const QString &id, const QString &type, const QString &username)
    : name(name),
      phone_number(phoneNumber),
      id(id),
      type(type),
      username(username) {}

QString Passenger::getName() {
    return name;
}

bool Passenger::setName(const QString &name) {
    this->name = name;
    return true;
}

QString Passenger::getPhoneNumber() {
    return phone_number;
}

bool Passenger::setPhoneNumber(const QString &phone) {
    phone_number = phone;
    return true;
}

QString Passenger::getId() {
    return id;
}

bool Passenger::setId(const QString &id) {
    this->id = id;
    return true;
}

QString Passenger::getType() {
    return type;
}

bool Passenger::setType(const QString &type) {
    this->type = type;
    return true;
}

QString Passenger::getUsername() {
    return username;
}

bool Passenger::setUsername(const QString &username) {
    this->username = username;
    return true;
}

bool operator==(const Passenger &p1, const Passenger &p2) {
    return p1.name == p2.name &&
           p1.phone_number == p2.phone_number &&
           p1.id == p2.id &&
           p1.type == p2.type &&
           p1.username == p2.username;
}

bool operator!=(const Passenger &p1, const Passenger &p2) {
    return !(p1 == p2);
}

std::ostream &operator<<(std::ostream &os, const Passenger &p) {
    os << p.name.toStdString() << " ";
    os << p.id.toStdString() << " ";
    os << p.phone_number.toStdString() << " ";
    os << p.type.toStdString() << " ";
    os << p.username.toStdString();
    return os;
}

std::istream &operator>>(std::istream &is, Passenger &p) {
    std::string passengerName;
    std::string phoneNumber;
    std::string id;
    std::string type;
    std::string username;
    is >> passengerName;
    is >> id;
    is >> phoneNumber;
    is >> type;
    is >> username;
    p.name = QString::fromStdString(passengerName);
    p.phone_number = QString::fromStdString(phoneNumber);
    p.id = QString::fromStdString(id);
    p.type = QString::fromStdString(type);
    p.username = QString::fromStdString(username);

    return is;
}
