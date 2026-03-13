#ifndef ADMIN_H
#define ADMIN_H
#include <QString>

class Admin
{
private:
    QString username = "";
    QString password = "";
    bool locked = false;
public:
    Admin();

    QString getUsername();
    bool setUsername(const QString &username);
    QString getPassword();
    bool setPassword(const QString &password);
    bool isLocked();
    bool lock();
    bool unlock();

    Admin& operator()(const QString &username, const QString &password, bool locked);
    friend bool operator==(const Admin &a1, const Admin &a2);
    friend bool operator!=(const Admin &a1, const Admin &a2);
    friend std::istream& operator>>(std::istream& is, Admin& a);
    friend std::ostream& operator<<(std::ostream& os, const Admin& a);
};

#endif // ADMIN_H
