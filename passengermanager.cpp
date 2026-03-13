#include "passengermanager.h"
#include <iostream>
#include <fstream>
#include <QDebug>
#include <QCoreApplication>

PassengerManager::PassengerManager(QObject *parent)
    : QObject{parent}
{
    readFromFile("../../data/passenger.txt");
    connect(qApp, &QCoreApplication::aboutToQuit, this, [this]() {
        this->writeToFile("../../data/passenger.txt");
    });
}

QVariantList PassengerManager::getPassengersByUsername_api(const QString &username) {
    QVariantList list;
    auto passengerList = getPassengersByUsername(username);
    for (auto &passenger : passengerList) {
        QVariantMap map;
        map["name"] = passenger.getName();
        map["phoneNumber"] = passenger.getPhoneNumber();
        map["id"] = passenger.getId();
        map["type"] = passenger.getType();
        map["username"] = passenger.getUsername();
        list << map;
    }
    return list;
}

QVariantMap PassengerManager::deletePassengerByUsernameAndId_api(const QString &username, const QString &id) {
    QVariantMap result;
    for (auto it = passengers.begin(); it != passengers.end(); it++) {
        if (it->getUsername() == username && it->getId() == id) {
            result["success"] = true;
            result["message"] = QString("用户 %1 下的乘车人 %2 删除成功！").arg(username, id);
            passengers.erase(it);
            return result;
        }
    }
    result["success"] = false;
    result["message"] = QString("未找到用户 %1 下的乘车人 %2 ！").arg(username, id);
    return result;
}

QVariantMap PassengerManager::editPassenger_api(const QString &username, const QString &id_old, const QString &name, const QString &phoneNumber, const QString &id_new, const QString &type) {
    QVariantMap result;
    // 判断是否该用户下有重复的乘车人
    auto findResult = getPassengerByUsernameAndId(username, id_new);
    if (findResult && id_new != id_old) {
        result["success"] = false;
        result["message"] = "修改后乘车人已经存在！";
        return result;
    }
    // 如果已有该id和name信息，则根据已有的验证修改后的信息是否合法
    std::vector<Passenger> p = getPassengersById(id_new);
    if (id_new != id_old) {
        if (p.size() > 0 && (p[0].getName() != name || p[0].getType() != type)) {
            result["success"] = false;
            result["message"] = "实名信息不符！";
            return result;
        }
    }
    else {
        if (p.size() > 1 && (p[0].getName() != name || p[0].getType() != type)) {
            result["success"] = false;
            result["message"] = "实名信息不符！";
            return result;
        }
    }
    // 信息合法，准备修改
    for (auto it = passengers.begin(); it != passengers.end(); it++) {
        if (it->getUsername() == username && it->getId() == id_old) {
            it->setName(name);
            it->setPhoneNumber(phoneNumber);
            it->setId(id_new);
            it->setType(type);
            result["success"] = true;
            result["message"] = QString("修改成功！").arg(username);
            return result;
        }
    }
    result["success"] = false;
    result["message"] = "无法找到需要修改的乘车人！";
    return result;
}

QVariantMap PassengerManager::addPassenger_api(QVariantMap info) {
    QString username = info["username"].toString();
    QString name = info["name"].toString();
    QString phoneNumber = info["phoneNumber"].toString();
    QString id = info["id"].toString();
    QString type = info["type"].toString();
    QVariantMap result;

    // 判断是否该用户下有重复的乘车人
    auto findResult = getPassengerByUsernameAndId(username, id);
    if (findResult) {
        result["success"] = false;
        result["message"] = "乘车人信息重复！";
        return result;
    }
    // 如果已有该id和name信息，则根据已有的验证修改后的信息是否合法
    std::vector<Passenger> p = getPassengersById(id);
    if (p.size() > 0 && (p[0].getName() != name || p[0].getType() != type)) {
        result["success"] = false;
        result["message"] = "实名信息不符！";
        return result;
    }
    // 信息合法，准备添加
    Passenger passenger(name, phoneNumber, id, type, username);
    passengers.push_back(passenger);
    result["success"] = true;
    result["message"] = "乘车人添加成功！";
    return result;
}

bool PassengerManager::deletePassengersByUsername(const QString &username) {
    for (auto it = passengers.begin(); it != passengers.end();) {
        if (it->getUsername() == username) {
            passengers.erase(it);
        }
        else {
            it++;
        }
    }
    return true;
}

std::vector<Passenger> PassengerManager::getPassengersById(const QString &id) {
    std::vector<Passenger> result;
    for (auto &passenger : passengers) {
        if (passenger.getId() == id) {
            result.push_back(passenger);
        }
    }
    return result;
}

std::vector<Passenger> PassengerManager::getPassengersByUsername(const QString &username) {
    std::vector<Passenger> result;
    for (auto &passenger : passengers) {
        if (passenger.getUsername() == username) {
            result.push_back(passenger);
        }
    }
    return result;
}

std::optional<Passenger> PassengerManager::getPassengerByUsernameAndId(const QString &username, const QString &id) {
    for (auto &passenger : passengers) {
        if (passenger.getUsername() == username && passenger.getId() == id) {
            return passenger;
        }
    }
    return std::nullopt;
}

bool PassengerManager::readFromFile(const char filename[]) {
    std::fstream fis(filename, std::ios::in);
    if (!fis) {
        qWarning() << "乘车人文件不存在！";
        return false;
    }
    Passenger passenger;
    while (fis >> passenger) {
        passengers.push_back(passenger);
    }
    return true;
}

bool PassengerManager::writeToFile(const char filename[]) {
    std::fstream fos(filename, std::ios::out);
    if (!fos) {
        qWarning() << "无法打开乘车人文件进行写入！";
        return false;
    }
    for (auto &passenger : passengers) {
        fos << passenger << std::endl;
    }
    return true;
}

