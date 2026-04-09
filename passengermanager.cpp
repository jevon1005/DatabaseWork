#include "passengermanager.h"
#include "railway_pg_connection.h"
#include <fstream>
#include <QDebug>
#include <QCoreApplication>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QStringList>

PassengerManager::PassengerManager(QObject *parent) : QObject{parent} {
    // 数据将通过DataLoader多线程加载
}

void PassengerManager::initializeData() {
    // 💡 自动迁移逻辑
    if (passengers.empty()) {
        qDebug() << "[乘车人] 云端为空，从本地 txt 加载并迁移至云端...";
        readFromFile("../../data/passenger.txt");
        if (railwayPgCanWriteImmediately()) saveToPostgres();
    }
}

QVariantList PassengerManager::getPassengersByUsername_api(const QString &username) {
    QVariantList list;
    auto passengerList = getPassengersByUsername(username);
    for (auto &passenger : passengerList) {
        QVariantMap map; map["name"] = passenger.getName(); map["phoneNumber"] = passenger.getPhoneNumber(); map["id"] = passenger.getId(); map["type"] = passenger.getType(); map["username"] = passenger.getUsername(); list << map;
    }
    return list;
}

QVariantMap PassengerManager::deletePassengerByUsernameAndId_api(const QString &username, const QString &id) {
    QVariantMap result;
    for (auto it = passengers.begin(); it != passengers.end(); it++) {
        if (it->getUsername() == username && it->getId() == id) {
            Passenger backup = *it;
            passengers.erase(it);
            // 实时数据库删除
            m_dirty = true;
            if (railwayPgIsOpen()) {
                QSqlDatabase db = QSqlDatabase::database("railway", false);
                QSqlQuery q(db);
                q.prepare("DELETE FROM passengers WHERE id_number = ?");
                q.addBindValue(id);
                if (!q.exec()) {
                    passengers.push_back(backup);
                    result["success"] = false;
                    result["message"] = QString("云端删除失败：%1").arg(q.lastError().text());
                    return result;
                }
            }
            result["success"] = true; result["message"] = "删除成功！"; return result;
        }
    }
    result["success"] = false; return result;
}

QVariantMap PassengerManager::editPassenger_api(const QString &username, const QString &id_old, const QString &name, const QString &phoneNumber, const QString &id_new, const QString &type) {
    QVariantMap result;
    auto findResult = getPassengerByUsernameAndId(username, id_new);
    if (findResult && id_new != id_old) { result["success"] = false; return result; }
    for (auto it = passengers.begin(); it != passengers.end(); it++) {
        if (it->getUsername() == username && it->getId() == id_old) {
            it->setName(name); it->setPhoneNumber(phoneNumber); it->setId(id_new); it->setType(type);
            m_dirty = true;
            if (railwayPgIsOpen()) {
                QSqlDatabase db = QSqlDatabase::database("railway", false);
                QSqlQuery q(db);
                q.prepare("UPDATE passengers SET name = ?, phone = ?, id_number = ?, passenger_type = ? WHERE id_number = ?");
                q.addBindValue(name); q.addBindValue(phoneNumber); q.addBindValue(id_new); q.addBindValue(type); q.addBindValue(id_old);
                q.exec();
            }
            result["success"] = true; result["message"] = "修改成功！"; return result;
        }
    }
    result["success"] = false; return result;
}

QVariantMap PassengerManager::addPassenger_api(QVariantMap info) {
    QString username = info["username"].toString(), name = info["name"].toString(), phoneNumber = info["phoneNumber"].toString(), id = info["id"].toString(), type = info["type"].toString();
    QVariantMap result;
    if (getPassengerByUsernameAndId(username, id)) { result["success"] = false; result["message"] = "重复"; return result; }
    Passenger passenger(name, phoneNumber, id, type, username);
    passengers.push_back(passenger);
    m_dirty = true;
    if (railwayPgIsOpen()) {
        QSqlDatabase db = QSqlDatabase::database("railway", false);
        QSqlQuery qu(db);
        qu.prepare("SELECT user_id FROM users WHERE username = ? LIMIT 1");
        qu.addBindValue(username);
        if (qu.exec() && qu.next()) {
            int uid = qu.value(0).toInt();
            QSqlQuery q(db);
            q.prepare("INSERT INTO passengers (user_id, name, id_number, phone, passenger_type) VALUES (?,?,?,?,?)");
            q.addBindValue(uid); q.addBindValue(name); q.addBindValue(id); q.addBindValue(phoneNumber); q.addBindValue(type);
            q.exec();
        }
    }
    result["success"] = true; result["message"] = "添加成功"; return result;
}

bool PassengerManager::deletePassengersByUsername(const QString &username) {
    for (auto it = passengers.begin(); it != passengers.end();) {
        if (it->getUsername() == username) { it = passengers.erase(it); } else { it++; }
    }
    m_dirty = true;
    if (railwayPgIsOpen()) {
        QSqlDatabase db = QSqlDatabase::database("railway", false);
        QSqlQuery q(db); q.prepare("DELETE FROM passengers WHERE user_id = (SELECT user_id FROM users WHERE username = ? LIMIT 1)"); q.addBindValue(username); q.exec();
    }
    return true;
}

std::vector<Passenger> PassengerManager::getPassengersById(const QString &id) {
    std::vector<Passenger> result; for (auto &p : passengers) if (p.getId() == id) result.push_back(p); return result;
}
std::vector<Passenger> PassengerManager::getPassengersByUsername(const QString &username) {
    std::vector<Passenger> result; for (auto &p : passengers) if (p.getUsername() == username) result.push_back(p); return result;
}
std::optional<Passenger> PassengerManager::getPassengerByUsernameAndId(const QString &username, const QString &id) {
    for (auto &p : passengers) if (p.getUsername() == username && p.getId() == id) return p; return std::nullopt;
}
bool PassengerManager::readFromFile(const char filename[]) {
    std::fstream fis(filename, std::ios::in); Passenger p; while (fis >> p) passengers.push_back(p); return true;
}
bool PassengerManager::writeToFile(const char filename[]) {
    std::fstream fos(filename, std::ios::out); for (auto &p : passengers) fos << p << std::endl; return true;
}

void PassengerManager::loadFromPostgres() {
    QSqlDatabase db = QSqlDatabase::database("railway", false);
    loadFromPostgres(db);
}

void PassengerManager::loadFromPostgres(QSqlDatabase &db) {
    passengers.clear();
    if (!db.isOpen()) return;
    QSqlQuery q(db);
    if (q.exec("SELECT u.username, p.name, p.phone, p.id_number, p.passenger_type FROM passengers p JOIN users u ON u.user_id = p.user_id ORDER BY p.passenger_id")) {
        while (q.next()) passengers.push_back(Passenger(q.value(1).toString(), q.value(2).toString(), q.value(3).toString(), q.value(4).toString(), q.value(0).toString()));
    }
    m_dirty = false;
}

void PassengerManager::saveToPostgres() {
    QSqlDatabase db = QSqlDatabase::database("railway", false);
    if (!db.isOpen()) return;
    QSqlQuery ping(db); if (!ping.exec("SELECT 1")) { db.close(); db.open(); }
    if (!db.transaction()) return;

    for (Passenger &p : passengers) {
        QSqlQuery qu(db); qu.prepare("SELECT user_id FROM users WHERE username = ? LIMIT 1"); qu.addBindValue(p.getUsername());
        if (!qu.exec() || !qu.next()) { db.rollback(); return; }
        const int uid = qu.value(0).toInt();

        QSqlQuery q(db); q.prepare("INSERT INTO passengers (user_id, name, id_number, phone, passenger_type) VALUES (?,?,?,?,?) ON CONFLICT (id_number) DO UPDATE SET user_id = EXCLUDED.user_id, name = EXCLUDED.name, phone = EXCLUDED.phone, passenger_type = EXCLUDED.passenger_type");
        q.addBindValue(uid); q.addBindValue(p.getName()); q.addBindValue(p.getId()); q.addBindValue(p.getPhoneNumber()); q.addBindValue(p.getType());
        if (!q.exec()) { db.rollback(); return; }
    }

    // 清理云端已被本地删除的乘车人
    if (passengers.empty()) {
        QSqlQuery qClear(db);
        if (!qClear.exec("DELETE FROM passengers")) { db.rollback(); return; }
    } else {
        QStringList ids;
        ids.reserve(static_cast<qsizetype>(passengers.size()));
        for (Passenger &p : passengers) {
            QString escaped = p.getId();
            escaped.replace("'", "''");
            ids << QString("'%1'").arg(escaped);
        }
        QSqlQuery qDelete(db);
        const QString sql = QString(
            "DELETE FROM passengers p "
            "WHERE p.id_number NOT IN (%1) "
            "AND NOT EXISTS (SELECT 1 FROM orders o WHERE o.passenger_id = p.passenger_id)"
        ).arg(ids.join(","));
        if (!qDelete.exec(sql)) { db.rollback(); return; }
    }

    db.commit();
    m_dirty = false;
}

bool PassengerManager::loadFromLocalCache() {
    passengers.clear();
    readFromFile("../../data/passenger.txt");
    m_dirty = false;
    return !passengers.empty();
}

bool PassengerManager::saveToLocalCache() const {
    auto *self = const_cast<PassengerManager *>(this);
    return self->writeToFile("../../data/passenger.txt");
}

bool PassengerManager::hasDirtyChanges() const {
    return m_dirty;
}

void PassengerManager::markClean() {
    m_dirty = false;
}