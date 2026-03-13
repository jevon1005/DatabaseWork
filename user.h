#ifndef USER_H
#define USER_H
#include <QString>
#include "userprofile.h"

class User
{
private:
    UserProfile profile;
    bool locked = false;
    QString username = "";
    QString password = "";
    
public:
    User();
    User(UserProfile &profile, bool locked, const QString &username, const QString &password);

    UserProfile getProfile();
    bool setProfile(const UserProfile &profile);
    bool isLocked();
    bool lock();
    bool unlock();
    QString getUsername();
    bool setUsername(const QString &username);
    QString getPassword();
    bool setPassword(const QString &password);

    User& operator()(const UserProfile &profile, bool locked, const QString &username, const QString &password);
    friend bool operator==(const User &u1, const User &u2);
    friend bool operator!=(const User &u1, const User &u2);
    friend std::istream& operator>>(std::istream& is, User& u);
    friend std::ostream& operator<<(std::ostream& os, const User& u);
};

#endif // USER_H
