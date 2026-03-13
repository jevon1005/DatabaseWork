#ifndef BOOKINGSYSTEM_H
#define BOOKINGSYSTEM_H

#include <QObject>
#include <queue>
#include <tuple>
#include "stationmanager.h"
#include "ordermanager.h"
#include "trainmanager.h"
#include "accountmanager.h"
#include "passengermanager.h"

class BookingSystem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList queryHistory READ getQueryHistory_api NOTIFY queryHistoryChanged)

private:
    StationManager *station_manager = nullptr;
    OrderManager *order_manager = nullptr;
    TrainManager *train_manager = nullptr;
    AccountManager *account_manager = nullptr;
    PassengerManager *passenger_manager = nullptr;
    Date today;
    std::queue<std::tuple<City, City>> query_history;
public:
    explicit BookingSystem(StationManager* stationManager, 
                            OrderManager* orderManager,
                            TrainManager* trainManager,
                            AccountManager* accountManager,
                            PassengerManager* passengerManager,
                            QObject *parent = nullptr);
    Q_INVOKABLE QVariantList getQueryHistory_api();
    Q_INVOKABLE bool addQueryHistory_api(const QString &startCityName, const QString &endCityName);
    Q_INVOKABLE bool clearQueryHistory_api();
    Q_INVOKABLE QVariantList queryTickets_api(const QString &startCityName,
                                              const QString &endCityName,
                                              int year, int month, int day);
    // 根据时间区间，查找该用户所有乘车人并标记是否空闲
    Q_INVOKABLE QVariantList getPassengers_api(const QVariantMap &info);
    // 提交订单，创建新订单
    Q_INVOKABLE QVariantMap createOrder_api(const QVariantMap &info);
    // 修改乘车人信息，需要检查该乘车人是否没有待乘坐的订单
    Q_INVOKABLE QVariantMap isPassengerEditable_api(const QVariantMap &info);
    // 注销用户，同时要删除该用户的所有待乘坐订单
    Q_INVOKABLE QVariantMap deleteUser_api(const QVariantMap &info);
    // 更新某个车次的时刻表和车次号
    Q_INVOKABLE QVariantMap updateTimetableAndTrainNumber_api(const QVariantMap &info);
    // 修改车次信息，需要检查该车次是否有待乘坐订单
    Q_INVOKABLE QVariantMap isTrainEditable_api(const QVariantMap &info);
    // 更新某个车次的座位模板
    Q_INVOKABLE QVariantMap updateSeatTemplate_api(const QVariantMap &info);

private:
    std::tuple<double, double, double> computePrice(const QString &trainNumber, Station &startStation, Station &endStation);

signals:
    void queryHistoryChanged();
};

#endif // BOOKINGSYSTEM_H
