#ifndef PASSENGERMANAGER_H
#define PASSENGERMANAGER_H

#include <QObject>
#include <vector>
#include <optional>
#include "passenger.h"
#include <QVariantList>
#include <QVariantMap>

class PassengerManager : public QObject
{
    Q_OBJECT
private:
    std::vector<Passenger> passengers;

public:
    explicit PassengerManager(QObject *parent = nullptr);
    Q_INVOKABLE QVariantList getPassengersByUsername_api(const QString &username);
    Q_INVOKABLE QVariantMap deletePassengerByUsernameAndId_api(const QString &username, const QString &id);
    // 修改乘车人信息
    Q_INVOKABLE QVariantMap editPassenger_api(const QString &username, const QString &id_old,
                                              const QString &name, const QString &phoneNumber, const QString &id_new, const QString &type);
    // 添加乘车人
    Q_INVOKABLE QVariantMap addPassenger_api(QVariantMap info);
    std::vector<Passenger> getPassengersByUsername(const QString &username);
    std::optional<Passenger> getPassengerByUsernameAndId(const QString &username, const QString &id);
    // 删除某一用户的所有乘车人（用户注销账号）
    bool deletePassengersByUsername(const QString &username);

private:
    std::vector<Passenger> getPassengersById(const QString &id);
    bool readFromFile(const char filename[]);
    bool writeToFile(const char filename[]);

signals:
};

#endif // PASSENGERMANAGER_H
