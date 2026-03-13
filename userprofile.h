#ifndef USERPROFILE_H
#define USERPROFILE_H
#include <QString>

class UserProfile
{
private:
    QString name = "";
    QString phone_number = "";
    QString id = "";

public:
    UserProfile();
    UserProfile(const QString &name,
                const QString &phone_number,
                const QString &id);

    QString getName();
    bool setName(const QString &name);
    QString getPhoneNumber();
    bool setPhoneNumber(const QString &phone_number);
    QString getId();
    bool setId(const QString &id);

    friend bool operator==(const UserProfile &up1, const UserProfile &up2);
    friend bool operator!=(const UserProfile &up1, const UserProfile &up2);
    friend std::istream& operator>>(std::istream& is, UserProfile& up);
    friend std::ostream& operator<<(std::ostream& os, const UserProfile& up);
};

#endif // USERPROFILE_H
