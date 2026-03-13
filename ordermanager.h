#ifndef ORDERMANAGER_H
#define ORDERMANAGER_H

#include <QObject>
#include <vector>
#include "order.h"
#include <QVariantMap>
#include <optional>

class OrderManager : public QObject
{
    Q_OBJECT

private:
    std::vector<Order> orders;

public:
    explicit OrderManager(QObject *parent = nullptr);
    ~OrderManager();

    Q_INVOKABLE QVariantList getOrdersByUsername_api(const QString &username);
    Q_INVOKABLE QVariantMap cancelOrder_api(const QString &orderNumber);
    Q_INVOKABLE QVariantList getTimetableInfo_api(const QString &orderNumber);
    Q_INVOKABLE QVariantList getOrders_api();
    Q_INVOKABLE QVariantMap getOrderByOrderNumber_api(const QString &orderNumber);
    std::optional<Order> getOrderByOrderNumber(const QString &orderNumber);
    // 查找某乘车人是否有空，可选择是否传订单号（改签模式下，也要查找乘车人是否有空，而查找的时候需要排除该订单）
    bool isPassengerAvailable(const QString &passengerId, Date &queryStartDate, Date &queryEndDate, Time &queryStartTime, Time &queryEndTime, const QString orderNumber = "");
    // 查找某个车次的乘车区间和查询区间重复的车票
    std::vector<Order> getOrdersUnusedAndOverlapByTrainNumber(const QString &trainNumber, Date &queryStartDate, Date &queryEndDate, Time &queryStartTime, Time &queryEndTime);
    // 改签模式下，需要根据订单号，获取该订单的乘车人信息
    Q_INVOKABLE QVariantMap getPassengerForReschedule_api(const QVariantMap &info);
    // 根据车次号、座位等级、日期和时间区间，在所有订单中查询与该时间重叠且座位等级相同的订单，返回该订单的座位信息（车厢号、行号、列号）
    std::vector<std::tuple<int, int, int>> getUnavailableSeatsInfo(const QString &trainNumber, const QString &seatLevel,
                                                                   Date &queryStartDate, Date &queryEndDate,
                                                                   Time &queryStartTime, Time &queryEndTime,
                                                                   const QString &excludedOrderNumber = "");
    // 创建订单，分配订单号
    bool createOrder(Order &order);
    // 改签订单
    bool rescheduleOrder(const QString &orderNumber);
    // 输入乘车人，判断该乘车人有无待乘坐订单（用于乘车人修改前判断）
    bool hasUnusedOrderForPassenger(const QString &username, const QString &passengerId);
    // 删除某一用户的所有订单（用于用户注销）
    bool deleteOrdersByUsername(const QString &username);
    // 判断某个车次是否有待乘坐订单
    bool hasUnusedOrderForTrain(const QString &trainNumber);

private:
    std::vector<Order> getOrdersByUsername(const QString &username);
    bool cancelOrder(const QString &orderNumber);
    // 根据当前系统时间，检查订单是否过期，过期的设置为“已乘坐”
    bool refreshOrderStatus();
    bool readFromFile(const char filename[]);
    bool writeToFile(const char filename[]);

signals:
};

#endif // ORDERMANAGER_H
