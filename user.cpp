#include "user.h"
#include <iostream>

User::User() {}

User::User(UserProfile &profile, bool locked, const QString &username, const QString &password)
    : profile(profile),
      locked(locked),
      username(username),
      password(password) {}

UserProfile User::getProfile() {
    return profile;
}

bool User::setProfile(const UserProfile &profile) {
    this->profile = profile;
    return true;
}

bool User::isLocked() {
    return locked;
}

bool User::lock() {
    locked = true;
    return true;
}

bool User::unlock() {
    locked = false;
    return true;
}

QString User::getUsername() {
    return username;
}

bool User::setUsername(const QString &username) {
    this->username = username;
    return true;
}

QString User::getPassword() {
    return password;
}

bool User::setPassword(const QString &password) {
    this->password = password;
    return true;
}

User& User::operator()(const UserProfile &profile, bool locked, const QString &username, const QString &password) {
    this->profile = profile;
    this->locked = locked;
    this->username = username;
    this->password = password;
    return *this;
}

bool operator==(const User &u1, const User &u2) {
    return (u1.profile == u2.profile) &&
           (u1.locked == u2.locked) &&
           (u1.username == u2.username) &&
           (u1.password == u2.password);
}

bool operator!=(const User &u1, const User &u2) {
    return !(u1 == u2);
}

std::istream& operator>>(std::istream& is, User& u) {
    std::string username, password;
    int locked_int;
    is >> username >> password >> locked_int;
    u.username = QString::fromStdString(username);
    u.password = QString::fromStdString(password);
    u.locked = locked_int ? true : false;
    is >> u.profile;
    return is;
}

std::ostream& operator<<(std::ostream& os, const User& u) {
    os << u.username.toStdString() << " " << u.password.toStdString() << " ";
    int locked_int = u.locked ? 1 : 0;
    os << locked_int << " " << u.profile << std::endl;
    return os;
}
