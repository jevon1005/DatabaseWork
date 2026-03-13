#include "ordermanager.h"
#include <fstream>
#include <iostream>
#include <QDebug>
#include <QVariantMap>
#include <QCoreApplication>

QVariantMap convertOrderToMap(Order &order) {
    QVariantMap map;
    map["orderNumber"] = order.getOrderNumber();
    map["trainNumber"] = order.getTrainNumber();
    map["year"] = order.getDate().getYear();
    map["month"] = order.getDate().getMonth();
    map["day"] = order.getDate().getDay();
    map["seatLevel"] = order.getSeatLevel();
    map["carriageNumber"] = order.getCarriageNumber();
    map["seatRow"] = order.getSeatRow();
    map["seatCol"] = order.getSeatCol();
    map["price"] = order.getPrice();
    map["status"] = order.getStatus();
    map["passengerName"] = order.getPassenger().getName();
    map["passengerType"] = order.getPassenger().getType();

    Station startSation = order.getStartStation();
    Station endStation = order.getEndStation();
    std::tuple<Time, Time, int, int, QString> startStationInfo =
        order.getTimetable().getStationInfo(startSation.getStationName());
    std::tuple<Time, Time, int, int, QString> endStationInfo =
        order.getTimetable().getStationInfo(endStation.getStationName());
    map["startStationName"] = startSation.getStationName();
    map["startStationStopInfo"] = std::get<4>(startStationInfo);
    map["startHour"] = std::get<1>(startStationInfo).getHour();
    map["startMinute"] = std::get<1>(startStationInfo).getMinute(), 2, 10, QChar('0');
    map["endStationName"] = endStation.getStationName();
    map["endStationStopInfo"] = std::get<4>(endStationInfo);
    map["endHour"] = std::get<0>(endStationInfo).getHour(), 2, 10, QChar('0');
    map["endMinute"] = std::get<0>(endStationInfo).getMinute(), 2, 10, QChar('0');

    int intervalSeconds = order.getTimetable().getInterval(startSation, endStation);
    int hours = intervalSeconds / 3600, minutes = (intervalSeconds % 3600) / 60;
    map["intervalHour"] = hours;
    map["intervalMinute"] = minutes;

    return map;
}

OrderManager::OrderManager(QObject *parent)
    : QObject{parent}
{
    readFromFile("../../data/order.txt");
    connect(qApp, &QCoreApplication::aboutToQuit, this, [this]() {
        this->writeToFile("../../data/order.txt");
    });
    refreshOrderStatus();
}

OrderManager::~OrderManager() {
    writeToFile("../../data/order.txt");
}

QVariantList OrderManager::getOrdersByUsername_api(const QString &username) {
    QVariantList list;
    std::vector<Order> findResult = getOrdersByUsername(username);
    for (auto &order : findResult) {
        QVariantMap map = convertOrderToMap(order);
        list << map;
    }
    
    return list;
}

QVariantMap OrderManager::cancelOrder_api(const QString &orderNumber) {
    QVariantMap result;
    auto findResult = getOrderByOrderNumber(orderNumber);
    if (findResult) {
        Order &order = findResult.value();
        if (order.getStatus() != "待乘坐") {
            result["success"] = false;
            result["message"] = QString("订单 %1 无法取消！").arg(orderNumber);
            return result;
        }
        cancelOrder(orderNumber);
        result["success"] = true;
        result["message"] = QString("订单 %1 取消成功！").arg(orderNumber);
        return result;
    } else {
        result["success"] = false;
        result["message"] = QString("订单 %1 不存在！").arg(orderNumber);
        return result;
    }
}

QVariantList OrderManager::getTimetableInfo_api(const QString &orderNumber) {
    QVariantList list;
    auto findResult = getOrderByOrderNumber(orderNumber);
    if (!findResult) {
        return list;
    }
    Order &order = findResult.value();
    std::vector<std::tuple<Station, Time, Time, int, int, int, QString>> info = order.getTimetable().getInfo(order.getStartStation().getStationName(), order.getEndStation().getStationName());
    for (auto &t : info) {
        QVariantMap map;
        Station station = std::get<0>(t);
        Time arriveTime = std::get<1>(t);
        Time departureTime = std::get<2>(t);
        int arriveDay = std::get<3>(t);
        int departureDay = std::get<4>(t);
        int stopInterval = std::get<5>(t);
        QString passInfo = std::get<6>(t);
        map["stationName"] = station.getStationName();
        map["arriveHour"] = arriveTime.getHour();
        map["arriveMinute"] = arriveTime.getMinute();
        map["departureHour"] = departureTime.getHour();
        map["departureMinute"] = departureTime.getMinute();
        map["stopInterval"] = stopInterval;
        map["passInfo"] = passInfo;
        list << map;
    }
    return list;
}

QVariantList OrderManager::getOrders_api() {
    QVariantList list;
    for (auto &order : orders) {
        QVariantMap map = convertOrderToMap(order);
        list << map;
    }

    return list;
}

QVariantMap OrderManager::getOrderByOrderNumber_api(const QString &orderNumber) {
    auto findResult = getOrderByOrderNumber(orderNumber);
    if (findResult) {
        Order order = findResult.value();
        QVariantMap map = convertOrderToMap(order);
        return map;
    }
    return QVariantMap(); // 返回空 map
}

bool OrderManager::isPassengerAvailable(const QString &passengerId, Date &queryStartDate, Date &queryEndDate, Time &queryStartTime, Time &queryEndTime, const QString orderNumber) {
    for (auto order : orders) {
        if (order.getPassenger().getId() == passengerId && order.getStatus() == "待乘坐") {
            if (orderNumber != "" && order.getOrderNumber() == orderNumber)
                continue;
            
            if (order.isTimeRangeOverlap(queryStartDate, queryStartTime, queryEndDate, queryEndTime)) {
                return false;
            }
        }
    }
    return true;
}

std::vector<Order> OrderManager::getOrdersUnusedAndOverlapByTrainNumber(const QString &trainNumber, Date &queryStartDate, Date &queryEndDate, Time &queryStartTime, Time &queryEndTime) {
    std::vector<Order> result;
    for (auto order : orders) {
        if (order.getStatus() == "待乘坐" && order.getTrainNumber() == trainNumber) {
            if (order.isTimeRangeOverlap(queryStartDate, queryStartTime, queryEndDate, queryEndTime)) {
                result.push_back(order);
            }
        }
    }
    return result;
}

QVariantMap OrderManager::getPassengerForReschedule_api(const QVariantMap &info) {
    QVariantMap result;
    QString orderNumber = info["orderNumber"].toString();
    int startYear = info["startYear"].toInt(), startMonth = info["startMonth"].toInt(), startDay = info["startDay"].toInt();
    int endYear = info["endYear"].toInt(), endMonth = info["endMonth"].toInt(), endDay = info["endDay"].toInt();
    int startHour = info["startHour"].toInt(), startMinute = info["startMinute"].toInt();
    int endHour = info["endHour"].toInt(), endMinute = info["endMinute"].toInt();
    Date startDate(startYear, startMonth, startDay), endDate(endYear, endMonth, endDay);
    Time startTime(startHour, startMinute, 0), endTime(endHour, endMinute, 0);
    auto findResult = getOrderByOrderNumber(orderNumber);
    if (!findResult) {
        result["success"] = false;
        return result;
    }
    Order order = findResult.value();
    Passenger passenger = order.getPassenger();
    QVariantMap p;
    p["name"] = passenger.getName();
    p["phoneNumber"] = passenger.getPhoneNumber();
    p["id"] = passenger.getId();
    p["type"] = passenger.getType();
    p["available"] = isPassengerAvailable(passenger.getId(), startDate, endDate, startTime, endTime, orderNumber);
    result["success"] = true;
    result["passenger"] = p;
    return result;
}

std::vector<std::tuple<int, int, int>> OrderManager::getUnavailableSeatsInfo(const QString &trainNumber, const QString &seatLevel, Date &queryStartDate, Date &queryEndDate, Time &queryStartTime, Time &queryEndTime, const QString &excludedOrderNumber) {
    std::vector<std::tuple<int, int, int>> result;
    for (auto order : orders) {
        if ((excludedOrderNumber == "" || order.getOrderNumber() != excludedOrderNumber) && order.getTrainNumber() == trainNumber && order.getSeatLevel() == seatLevel && order.getStatus() == "待乘坐") {
            if (order.isTimeRangeOverlap(queryStartDate, queryStartTime, queryEndDate, queryEndTime)) {
                std::tuple<int, int, int> t = std::make_tuple(order.getCarriageNumber(), order.getSeatRow(), order.getSeatCol());
                result.push_back(t);
            }
        }
    }
    return result;
}

bool OrderManager::createOrder(Order &order) {
    long long maxOrderNumberLongLong = 0;
    for (auto order : orders) {
        long long orderNumberLongLong = order.getOrderNumber().toLongLong();
        maxOrderNumberLongLong = std::max(maxOrderNumberLongLong, orderNumberLongLong);
    }

    QString newOrderNumber = QString("%1").arg(maxOrderNumberLongLong + 1, 10, 10, QChar('0'));
    order.setOrderNumber(newOrderNumber);
    // 新订单在首部，这样“我的订单”显示顺序就是由新到老
    orders.insert(orders.begin(), order);
    return true;
}

std::vector<Order> OrderManager::getOrdersByUsername(const QString &username) {
    std::vector<Order> result;
    for (auto &order : orders) {
        if (order.getUsername() == username) {
            result.push_back(order);
        }
    }
    return result;
}

std::optional<Order> OrderManager::getOrderByOrderNumber(const QString &orderNumber) {
    for (auto order : orders) {
        if (order.getOrderNumber() == orderNumber) {
            return order;
        }
    }
    return std::nullopt;
}


bool OrderManager::cancelOrder(const QString &orderNumber) {
    for (auto &order : orders) {
        if (order.getOrderNumber() == orderNumber) {
            order.setStatus("已取消");
            return true;
        }
    }
    return false;
}

bool OrderManager::rescheduleOrder(const QString &orderNumber) {
    for (auto &order : orders) {
        if (order.getOrderNumber() == orderNumber) {
            order.setStatus("已改签");
            return true;
        }
    }
    return false;
}

bool OrderManager::hasUnusedOrderForPassenger(const QString &username, const QString &passengerId) {
    for (auto order : orders) {
        if (order.getStatus() == "待乘坐" && order.getPassenger().getUsername() == username && order.getPassenger().getId() == passengerId) {
            return true;
        }
    }
    return false;
}

bool OrderManager::deleteOrdersByUsername(const QString &username) {
    for (auto it = orders.begin(); it != orders.end();) {
        if (it->getUsername() == username) {
            orders.erase(it);
        }
        else {
            it++;
        }
    }
    return true;
}

bool OrderManager::hasUnusedOrderForTrain(const QString &trainNumber) {
    for (auto order : orders) {
        if (order.getTrainNumber() == trainNumber && order.getStatus() == "待乘坐") {
            return true;
        }
    }
    return false;
}

bool OrderManager::refreshOrderStatus() {
    Date nowDate;
    Time nowTime;
    nowDate.now();
    nowTime.now();

    for (auto it = orders.begin(); it != orders.end(); it++) {
        Date orderEndDate = it->getEndDate();
        Time orderEndTime = it->getEndTime();
        if (orderEndDate < nowDate || (orderEndDate == nowDate && orderEndTime < nowTime)) {
            it->setStatus("已乘坐");
        }
    }

    return true;
}

bool OrderManager::readFromFile(const char filename[]) {
    std::fstream fis(filename, std::ios::in);
    if (!fis) {
        qWarning() << "订单文件不存在！";
        return false;
    }
    Order order;
    while (fis >> order) {
        orders.push_back(order);
    }
    return true;
}

bool OrderManager::writeToFile(const char filename[]) {
    std::fstream fos(filename, std::ios::out);
    if (!fos) {
        qWarning() << "无法打开订单文件进行写入！";
        return false;
    }
    for (auto &order : orders) {
        fos << order << std::endl;
    }
    return true;
}
