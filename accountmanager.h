#ifndef ACCOUNTMANAGER_H
#define ACCOUNTMANAGER_H

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <vector>
#include "user.h"
#include "admin.h"

class AccountManager : public QObject
{
    Q_OBJECT

public:
    std::vector<User> users;
    std::vector<Admin> admins;

public:
    explicit AccountManager(QObject *parent = nullptr);

    Q_INVOKABLE QVariantMap loginUser_api(const QString &username, const QString &password);
    Q_INVOKABLE QVariantMap loginAdmin_api(const QString &username, const QString &password);
    Q_INVOKABLE QVariantMap getUserProfile_api(const QString &username);
    Q_INVOKABLE QVariantList getAccounts_api();
    // 对某个用户加锁，传入用户名
    Q_INVOKABLE QVariantMap lockUser_api(const QString &username);
    // 对某个管理员加锁，传入用户名
    Q_INVOKABLE QVariantMap lockAdmin_api(const QString &username);
    // 对某个用户解锁，传入用户名
    Q_INVOKABLE QVariantMap unlockUser_api(const QString &username);
    // 对某个管理员解锁，传入用户名
    Q_INVOKABLE QVariantMap unlockAdmin_api(const QString &username);
    // 修改用户个人信息，传入用户名，以及修改后的姓名、联系方式和身份证号
    Q_INVOKABLE QVariantMap editUserProfile_api(const QString &username, const QString &name, const QString &phoneNumber, const QString &id);
    // 注册账号
    Q_INVOKABLE QVariantMap registerUser_api(QVariantMap info);
    // 重置密码
    Q_INVOKABLE QVariantMap resetPassword_api(QVariantMap info);
    // 注销账户，传入用户名
    bool deleteUser(const QString &username);
    // 通过用户名获得用户信息
    std::optional<User> getUserByUsername(const QString &username);
    // 通过用户名获得管理员信息
    std::optional<Admin> getAdminByUsername(const QString &username);

private:
    std::optional<Admin> findAdminByUsername(const QString &username);
    std::optional<User> findUserById(const QString &id);
    void readFromFileUser(const char filename[]);
    void readFromFileAdmin(const char filename[]);
    void readFromFile(const char filenameUser[], const char filenameAdmin[]);
    void writeToFileUser(const char filename[]);
    void writeToFileAdmin(const char filename[]);
    void writeToFile(const char filenameUser[], const char filenameAdmin[]);

};

#endif // ACCOUNTMANAGER_H
