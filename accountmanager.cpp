#include "accountmanager.h"
#include <fstream>
#include <QDebug>
#include <QDir>
#include <QFileInfo>
#include <iostream>
#include <QCoreApplication>
#include "railway_pg_connection.h"
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>

AccountManager::AccountManager(QObject *parent) : QObject{parent} {
    // 数据将通过DataLoader多线程加载
}

void AccountManager::initializeData() {
    // 💡 自动迁移逻辑：如果云端没数据，自动加载本地并同步到云端！
    if (users.empty() && admins.empty()) {
        qDebug() << "[账号] 云端为空，开始从本地加载并自动迁移至云端...";
        readFromFile("../../data/user.txt", "../../data/admin.txt");
        if (railwayPgIsOpen()) saveToPostgres();
    }
}

AccountManager::~AccountManager() {
    if (!railwayPgIsOpen()) writeToFile("../../data/user.txt", "../../data/admin.txt");
}

QVariantMap AccountManager::loginUser_api(const QString &username, const QString &password) {
    QVariantMap result;
    auto findResult = getUserByUsername(username);
    if (findResult) {
        User user = findResult.value();
        if (user.isLocked()) {
            result["success"] = false; result["message"] = QString("账户 %1 已被锁定！请联系管理员解锁。").arg(username); return result;
        }
        if (user.getPassword() != password) {
            result["success"] = false; result["message"] = QString("账户 %1 密码错误！请重新输入。").arg(username); return result;
        }
        result["success"] = true; return result;
    } else {
        result["success"] = false; result["message"] = QString("账户 %1 不存在！").arg(username); return result;
    }
}

QVariantMap AccountManager::loginAdmin_api(const QString &username, const QString &password) {
    QVariantMap result;
    auto findResult = findAdminByUsername(username);
    if (findResult) {
        Admin admin = findResult.value();
        if (admin.isLocked()) { result["success"] = false; result["message"] = QString("账户被锁定").arg(username); return result; }
        if (admin.getPassword() != password) { result["success"] = false; result["message"] = QString("密码错误").arg(username); return result; }
        result["success"] = true; return result;
    } else {
        result["success"] = false; result["message"] = QString("账户不存在"); return result;
    }
}

QVariantMap AccountManager::getUserProfile_api(const QString &username) {
    QVariantMap result;
    auto findResult = getUserByUsername(username);
    if (findResult) {
        User user = findResult.value();
        result["name"] = user.getProfile().getName();
        result["phoneNumber"] = user.getProfile().getPhoneNumber();
        result["id"] = user.getProfile().getId();
    }
    return result;
}

QVariantList AccountManager::getAccounts_api() {
    QVariantList list;
    for (auto &user : users) {
        QVariantMap map; map["type"] = "user"; map["username"] = user.getUsername(); map["password"] = user.getPassword(); map["isLocked"] = user.isLocked(); list << map;
    }
    for (auto &admin : admins) {
        QVariantMap map; map["type"] = "admin"; map["username"] = admin.getUsername(); map["password"] = admin.getPassword(); map["isLocked"] = admin.isLocked(); list << map;
    }
    return list;
}

QVariantMap AccountManager::lockUser_api(const QString &username) {
    QVariantMap result;
    for (auto it = users.begin(); it != users.end(); it++) {
        if (it->getUsername() == username) {
            it->lock();
            if (railwayPgIsOpen()) {
                QSqlDatabase db = QSqlDatabase::database("railway", false);
                QSqlQuery q(db);
                q.prepare("UPDATE users SET locked = true WHERE username = ?");
                q.addBindValue(username);
                q.exec();
            }
            result["success"] = true; result["message"] = "成功锁定"; return result;
        }
    }
    result["success"] = false; return result;
}

QVariantMap AccountManager::lockAdmin_api(const QString &username) {
    QVariantMap result;
    for (auto it = admins.begin(); it != admins.end(); it++) {
        if (it->getUsername() == username) {
            it->lock();
            if (railwayPgIsOpen()) {
                QSqlDatabase db = QSqlDatabase::database("railway", false);
                QSqlQuery q(db);
                q.prepare("UPDATE admins SET locked = true WHERE username = ?");
                q.addBindValue(username);
                q.exec();
            }
            result["success"] = true; result["message"] = "成功锁定"; return result;
        }
    }
    result["success"] = false; return result;
}

QVariantMap AccountManager::unlockUser_api(const QString &username) {
    QVariantMap result;
    for (auto it = users.begin(); it != users.end(); it++) {
        if (it->getUsername() == username) {
            it->unlock();
            if (railwayPgIsOpen()) {
                QSqlDatabase db = QSqlDatabase::database("railway", false);
                QSqlQuery q(db);
                q.prepare("UPDATE users SET locked = false WHERE username = ?");
                q.addBindValue(username);
                q.exec();
            }
            result["success"] = true; return result;
        }
    }
    result["success"] = false; return result;
}

QVariantMap AccountManager::unlockAdmin_api(const QString &username) {
    QVariantMap result;
    for (auto it = admins.begin(); it != admins.end(); it++) {
        if (it->getUsername() == username) {
            it->unlock();
            if (railwayPgIsOpen()) {
                QSqlDatabase db = QSqlDatabase::database("railway", false);
                QSqlQuery q(db);
                q.prepare("UPDATE admins SET locked = false WHERE username = ?");
                q.addBindValue(username);
                q.exec();
            }
            result["success"] = true; return result;
        }
    }
    result["success"] = false; return result;
}

QVariantMap AccountManager::editUserProfile_api(const QString &username, const QString &name, const QString &phoneNumber, const QString &id) {
    QVariantMap result;
    auto findResult = findUserById(id);
    if (findResult && findResult.value().getUsername() != username) {
        result["success"] = false; result["message"] = QString("该身份证号已注册其他账号！"); return result;
    }
    for (auto it = users.begin(); it != users.end(); it++) {
        if (it->getUsername() == username) {
            UserProfile userProfile(name, phoneNumber, id);
            it->setProfile(userProfile);
            if (railwayPgIsOpen()) {
                QSqlDatabase db = QSqlDatabase::database("railway", false);
                QSqlQuery q(db);
                q.prepare("UPDATE users SET full_name = ?, phone = ?, id_card = ? WHERE username = ?");
                q.addBindValue(name); q.addBindValue(phoneNumber); q.addBindValue(id); q.addBindValue(username);
                q.exec();
            }
            result["success"] = true; result["message"] = QString("信息修改成功"); return result;
        }
    }
    result["success"] = false; return result;
}

QVariantMap AccountManager::registerUser_api(QVariantMap info) {
    QVariantMap result;
    QString username = info["username"].toString();
    QString password = info["password"].toString();
    QString name = info["name"].toString();
    QString phoneNumber = info["phoneNumber"].toString();
    QString id = info["id"].toString();

    if (getUserByUsername(username) || getAdminByUsername(username)) {
        result["success"] = false; result["message"] = "用户名重复！"; return result;
    }
    for (auto& user : users) {
        if (user.getProfile().getId() == id) {
            result["success"] = false; result["message"] = "该身份证号已被注册！"; return result;
        }
    }
    UserProfile profile(name, phoneNumber, id);
    User user(profile, false, username, password);
    users.push_back(user);
    if (railwayPgIsOpen()) {
        QSqlDatabase db = QSqlDatabase::database("railway", false);
        QSqlQuery q(db);
        q.prepare("INSERT INTO users (username, password, locked, full_name, phone, id_card) VALUES (?,?,?,?,?,?)");
        q.addBindValue(username); q.addBindValue(password); q.addBindValue(false); q.addBindValue(name); q.addBindValue(phoneNumber); q.addBindValue(id);
        q.exec();
    }
    result["success"] = true; result["message"] = "注册成功！"; return result;
}

QVariantMap AccountManager::resetPassword_api(QVariantMap info) {
    QString username = info["username"].toString();
    QString password = info["password"].toString();
    QVariantMap result;
    for (auto it = users.begin(); it != users.end(); it++) {
        if (it->getUsername() == username) {
            it->setPassword(password);
            if (railwayPgIsOpen()) {
                QSqlDatabase db = QSqlDatabase::database("railway", false);
                QSqlQuery q(db);
                q.prepare("UPDATE users SET password = ? WHERE username = ?");
                q.addBindValue(password); q.addBindValue(username);
                q.exec();
            }
            result["success"] = true; result["message"] = "重置成功"; return result;
        }
    }
    for (auto it = admins.begin(); it != admins.end(); it++) {
        if (it->getUsername() == username) {
            it->setPassword(password);
            if (railwayPgIsOpen()) {
                QSqlDatabase db = QSqlDatabase::database("railway", false);
                QSqlQuery q(db);
                q.prepare("UPDATE admins SET password = ? WHERE username = ?");
                q.addBindValue(password); q.addBindValue(username);
                q.exec();
            }
            result["success"] = true; result["message"] = "重置成功"; return result;
        }
    }
    result["success"] = false; return result;
}

bool AccountManager::deleteUser(const QString &username) {
    for (auto it = users.begin(); it != users.end(); it++) {
        if (it->getUsername() == username) {
            users.erase(it);
            // 实时同步删除操作到数据库
            if (railwayPgIsOpen()) {
                QSqlDatabase db = QSqlDatabase::database("railway", false);
                QSqlQuery q(db);
                q.prepare("DELETE FROM users WHERE username = ?");
                q.addBindValue(username);
                q.exec();
            }
            return true;
        }
    }
    return false;
}

std::optional<User> AccountManager::getUserByUsername(const QString &username) {
    for (auto user : users) { if (user.getUsername() == username) return user; } return std::nullopt;
}
std::optional<Admin> AccountManager::getAdminByUsername(const QString &username) {
    for (auto admin : admins) { if (admin.getUsername() == username) return admin; } return std::nullopt;
}
std::optional<Admin> AccountManager::findAdminByUsername(const QString &username) {
    for (auto &admin : admins) { if (admin.getUsername() == username) return admin; } return std::nullopt;
}
std::optional<User> AccountManager::findUserById(const QString &id) {
    for (auto &user : users) { if (user.getProfile().getId() == id) return user; } return std::nullopt;
}

void AccountManager::readFromFileUser(const char filename[]) {
    std::fstream fis(filename, std::ios::in); User user; while (fis >> user) users.push_back(user);
}
void AccountManager::readFromFileAdmin(const char filename[]) {
    std::fstream fis(filename, std::ios::in); Admin admin; while (fis >> admin) admins.push_back(admin);
}
void AccountManager::readFromFile(const char filenameUser[], const char filenameAdmin[]) {
    readFromFileUser(filenameUser); readFromFileAdmin(filenameAdmin);
}
void AccountManager::writeToFileUser(const char filename[]) {
    std::fstream fos(filename, std::ios::out); for (auto &user : users) fos << user;
}
void AccountManager::writeToFileAdmin(const char filename[]) {
    std::fstream fos(filename, std::ios::out); for (auto &admin : admins) fos << admin;
}
void AccountManager::writeToFile(const char filenameUser[], const char filenameAdmin[]) {
    writeToFileUser(filenameUser); writeToFileAdmin(filenameAdmin);
}

void AccountManager::loadFromPostgres() {
    QSqlDatabase db = QSqlDatabase::database("railway", false);
    loadFromPostgres(db);
}

void AccountManager::loadFromPostgres(QSqlDatabase &db) {
    users.clear(); admins.clear();
    if (!db.isOpen()) return;

    QSqlQuery qUsers(db);
    if (qUsers.exec("SELECT username, password, locked, full_name, phone, id_card FROM users ORDER BY user_id")) {
        while (qUsers.next()) {
            UserProfile profile(qUsers.value(3).toString(), qUsers.value(4).toString(), qUsers.value(5).toString());
            User user(profile, qUsers.value(2).toBool(), qUsers.value(0).toString(), qUsers.value(1).toString());
            users.push_back(user);
        }
    }
    QSqlQuery qAdmins(db);
    if (qAdmins.exec("SELECT username, password, locked FROM admins ORDER BY admin_id")) {
        while (qAdmins.next()) {
            Admin admin(qAdmins.value(0).toString(), qAdmins.value(1).toString(), qAdmins.value(2).toBool());
            admins.push_back(admin);
        }
    }
}

void AccountManager::saveToPostgres() {
    QSqlDatabase db = QSqlDatabase::database("railway", false);
    if (!db.isOpen()) return;

    QSqlQuery ping(db);
    if (!ping.exec("SELECT 1")) { db.close(); db.open(); }
    if (!db.transaction()) return;

    for (User &user : users) {
        QSqlQuery q(db);
        q.prepare("INSERT INTO users (username, password, locked, full_name, phone, id_card) VALUES (?,?,?,?,?,?) "
                  "ON CONFLICT (username) DO UPDATE SET password = EXCLUDED.password, locked = EXCLUDED.locked, full_name = EXCLUDED.full_name, phone = EXCLUDED.phone, id_card = EXCLUDED.id_card");
        q.addBindValue(user.getUsername()); q.addBindValue(user.getPassword()); q.addBindValue(user.isLocked()); q.addBindValue(user.getProfile().getName()); q.addBindValue(user.getProfile().getPhoneNumber()); q.addBindValue(user.getProfile().getId());
        if (!q.exec()) { db.rollback(); return; }
    }
    for (Admin &admin : admins) {
        QSqlQuery q(db);
        q.prepare("INSERT INTO admins (username, password, locked) VALUES (?,?,?) ON CONFLICT (username) DO UPDATE SET password = EXCLUDED.password, locked = EXCLUDED.locked");
        q.addBindValue(admin.getUsername()); q.addBindValue(admin.getPassword()); q.addBindValue(admin.isLocked());
        if (!q.exec()) { db.rollback(); return; }
    }
    db.commit();
}