#include "ordermanager.h"
#include "trainmanager.h"
#include "railway_pg_connection.h"
#include "railway_pg_codec.h"
#include <fstream>
#include <iostream>
#include <sstream>
#include <QDebug>
#include <QVariantMap>
#include <QCoreApplication>
#include <QDate>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>

// 辅助函数：将 Order 实体转换为 QVariantMap 供 QML 使用
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
    std::tuple<Time, Time, int, int, QString> startStationInfo = order.getTimetable().getStationInfo(startSation.getStationName());
    std::tuple<Time, Time, int, int, QString> endStationInfo = order.getTimetable().getStationInfo(endStation.getStationName());

    map["startStationName"] = startSation.getStationName();
    map["startStationStopInfo"] = std::get<4>(startStationInfo);
    map["startHour"] = std::get<1>(startStationInfo).getHour();
    map["startMinute"] = std::get<1>(startStationInfo).getMinute();
    map["endStationName"] = endStation.getStationName();
    map["endStationStopInfo"] = std::get<4>(endStationInfo);
    map["endHour"] = std::get<0>(endStationInfo).getHour();
    map["endMinute"] = std::get<0>(endStationInfo).getMinute();

    int intervalSeconds = order.getTimetable().getInterval(startSation, endStation);
    int hours = intervalSeconds / 3600, minutes = (intervalSeconds % 3600) / 60;
    map["intervalHour"] = hours;
    map["intervalMinute"] = minutes;

    return map;
}

OrderManager::OrderManager(TrainManager *trainManager, QObject *parent)
    : QObject{parent}, m_trainManager(trainManager)
{
    if (railwayPgIsOpen()) {
        loadFromPostgres();
    }

    // 💡 自动迁移逻辑：如果云端没数据，读本地并上传
    if (orders.empty()) {
        qDebug() << "[订单] 云端为空，从本地加载并迁移至云端...";
        readFromFile("../../data/order.txt");
        if (railwayPgIsOpen()) saveToPostgres();
    }
    refreshOrderStatus();
}

OrderManager::~OrderManager() {
    if (!railwayPgIsOpen()) writeToFile("../../data/order.txt");
}

QVariantList OrderManager::getOrdersByUsername_api(const QString &username) {
    QVariantList list;
    std::vector<Order> findResult = getOrdersByUsername(username);
    for (auto &order : findResult) list << convertOrderToMap(order);
    return list;
}

QVariantMap OrderManager::cancelOrder_api(const QString &orderNumber) {
    QVariantMap result;
    auto findResult = getOrderByOrderNumber(orderNumber);
    if (findResult) {
        Order &order = findResult.value();
        if (order.getStatus() != "待乘坐") {
            result["success"] = false; result["message"] = QString("订单 %1 无法取消！").arg(orderNumber); return result;
        }
        cancelOrder(orderNumber);
        result["success"] = true; result["message"] = QString("订单 %1 取消成功！").arg(orderNumber); return result;
    }
    result["success"] = false; result["message"] = "订单不存在"; return result;
}

QVariantList OrderManager::getTimetableInfo_api(const QString &orderNumber) {
    QVariantList list;
    auto findResult = getOrderByOrderNumber(orderNumber);
    if (!findResult) return list;

    Order &order = findResult.value();
    std::vector<std::tuple<Station, Time, Time, int, int, int, QString>> info = order.getTimetable().getInfo(order.getStartStation().getStationName(), order.getEndStation().getStationName());

    for (auto &t : info) {
        QVariantMap map;
        map["stationName"] = std::get<0>(t).getStationName();
        map["arriveHour"] = std::get<1>(t).getHour();
        map["arriveMinute"] = std::get<1>(t).getMinute();
        map["departureHour"] = std::get<2>(t).getHour();
        map["departureMinute"] = std::get<2>(t).getMinute();
        map["stopInterval"] = std::get<5>(t);
        map["passInfo"] = std::get<6>(t);
        list << map;
    }
    return list;
}

QVariantList OrderManager::getOrders_api() {
    QVariantList list;
    for (auto &order : orders) list << convertOrderToMap(order);
    return list;
}

QVariantMap OrderManager::getOrderByOrderNumber_api(const QString &orderNumber) {
    auto findResult = getOrderByOrderNumber(orderNumber);
    if (findResult) return convertOrderToMap(findResult.value());
    return QVariantMap();
}

bool OrderManager::isPassengerAvailable(const QString &passengerId, Date &queryStartDate, Date &queryEndDate, Time &queryStartTime, Time &queryEndTime, const QString orderNumber) {
    for (auto order : orders) {
        if (order.getPassenger().getId() == passengerId && order.getStatus() == "待乘坐") {
            if (orderNumber != "" && order.getOrderNumber() == orderNumber) continue;
            if (order.isTimeRangeOverlap(queryStartDate, queryStartTime, queryEndDate, queryEndTime)) return false;
        }
    }
    return true;
}

std::vector<Order> OrderManager::getOrdersUnusedAndOverlapByTrainNumber(const QString &trainNumber, Date &queryStartDate, Date &queryEndDate, Time &queryStartTime, Time &queryEndTime) {
    std::vector<Order> result;
    for (auto order : orders) {
        if (order.getStatus() == "待乘坐" && order.getTrainNumber() == trainNumber) {
            if (order.isTimeRangeOverlap(queryStartDate, queryStartTime, queryEndDate, queryEndTime)) result.push_back(order);
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
    if (!findResult) { result["success"] = false; return result; }

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
                result.push_back(std::make_tuple(order.getCarriageNumber(), order.getSeatRow(), order.getSeatCol()));
            }
        }
    }
    return result;
}

bool OrderManager::createOrder(Order &order) {
    long long maxOrderNumberLongLong = 0;
    for (auto o : orders) maxOrderNumberLongLong = std::max(maxOrderNumberLongLong, o.getOrderNumber().toLongLong());
    order.setOrderNumber(QString("%1").arg(maxOrderNumberLongLong + 1, 10, 10, QChar('0')));
    orders.insert(orders.begin(), order);
    if (railwayPgIsOpen()) saveToPostgres(); // 实时保存到云端
    return true;
}

std::vector<Order> OrderManager::getOrdersByUsername(const QString &username) {
    std::vector<Order> result; for (auto &o : orders) if (o.getUsername() == username) result.push_back(o); return result;
}

std::optional<Order> OrderManager::getOrderByOrderNumber(const QString &orderNumber) {
    for (auto o : orders) if (o.getOrderNumber() == orderNumber) return o; return std::nullopt;
}

bool OrderManager::cancelOrder(const QString &orderNumber) {
    for (auto &order : orders) {
        if (order.getOrderNumber() == orderNumber) {
            order.setStatus("已取消");
            if (railwayPgIsOpen()) saveToPostgres(); // 实时保存到云端
            return true;
        }
    }
    return false;
}

bool OrderManager::rescheduleOrder(const QString &orderNumber) {
    for (auto &order : orders) {
        if (order.getOrderNumber() == orderNumber) {
            order.setStatus("已改签");
            if (railwayPgIsOpen()) saveToPostgres(); // 实时保存到云端
            return true;
        }
    }
    return false;
}

bool OrderManager::hasUnusedOrderForPassenger(const QString &username, const QString &passengerId) {
    for (auto order : orders) { if (order.getStatus() == "待乘坐" && order.getPassenger().getUsername() == username && order.getPassenger().getId() == passengerId) return true; } return false;
}

bool OrderManager::deleteOrdersByUsername(const QString &username) {
    for (auto it = orders.begin(); it != orders.end();) {
        if (it->getUsername() == username) { it = orders.erase(it); } else { it++; }
    }
    if (railwayPgIsOpen()) saveToPostgres();
    return true;
}

bool OrderManager::hasUnusedOrderForTrain(const QString &trainNumber) {
    for (auto order : orders) { if (order.getTrainNumber() == trainNumber && order.getStatus() == "待乘坐") return true; } return false;
}

bool OrderManager::refreshOrderStatus() {
    Date nowDate; Time nowTime; nowDate.now(); nowTime.now();
    bool changed = false;
    for (auto it = orders.begin(); it != orders.end(); it++) {
        if (it->getStatus() == "待乘坐" && (it->getEndDate() < nowDate || (it->getEndDate() == nowDate && it->getEndTime() < nowTime))) {
            it->setStatus("已乘坐");
            changed = true;
        }
    }
    if (changed && railwayPgIsOpen()) saveToPostgres();
    return true;
}

bool OrderManager::readFromFile(const char filename[]) {
    std::fstream fis(filename, std::ios::in);
    if (!fis) { qWarning() << "订单文件不存在！"; return false; }
    Order order;
    while (fis >> order) orders.push_back(order);
    return true;
}

bool OrderManager::writeToFile(const char filename[]) {
    std::fstream fos(filename, std::ios::out);
    if (!fos) return false;
    for (auto &order : orders) fos << order << std::endl;
    return true;
}

namespace {
int lookupUserId(QSqlDatabase &db, const QString &username) {
    QSqlQuery q(db); q.prepare("SELECT user_id FROM users WHERE username = ? LIMIT 1"); q.addBindValue(username);
    if (!q.exec() || !q.next()) return -1; return q.value(0).toInt();
}
int lookupTrainId(QSqlDatabase &db, const QString &trainNumber) {
    QSqlQuery q(db); q.prepare("SELECT train_id FROM trains WHERE train_number = ? LIMIT 1"); q.addBindValue(trainNumber);
    if (!q.exec() || !q.next()) return -1; return q.value(0).toInt();
}
int lookupPassengerId(QSqlDatabase &db, const QString &idNumber) {
    QSqlQuery q(db); q.prepare("SELECT passenger_id FROM passengers WHERE id_number = ? LIMIT 1"); q.addBindValue(idNumber);
    if (!q.exec() || !q.next()) return -1; return q.value(0).toInt();
}
int lookupStationId(QSqlDatabase &db, const QString &stationName) {
    QSqlQuery q(db); q.prepare("SELECT station_id FROM stations WHERE station_name = ? LIMIT 1"); q.addBindValue(stationName);
    if (!q.exec() || !q.next()) return -1; return q.value(0).toInt();
}
}

void OrderManager::loadFromPostgres() {
    orders.clear();
    QSqlDatabase db = QSqlDatabase::database("railway", false);
    if (!db.isOpen()) return;

    QSqlQuery ping(db); if (!ping.exec("SELECT 1")) { db.close(); db.open(); }

    QSqlQuery q(db);
    if (!q.exec("SELECT o.order_number, t.train_number, o.price, o.travel_date, o.seat_level, o.carriage_number, o.seat_row, o.seat_col, o.status, o.timetable_snapshot, u.username, p.name, p.phone, p.id_number, p.passenger_type, ss.station_name, sc.city_name, es.station_name, ec.city_name FROM orders o JOIN trains t ON t.train_id = o.train_id JOIN users u ON u.user_id = o.user_id JOIN passengers p ON p.passenger_id = o.passenger_id JOIN stations ss ON ss.station_id = o.start_station_id JOIN cities sc ON sc.city_id = ss.city_id JOIN stations es ON es.station_id = o.end_station_id JOIN cities ec ON ec.city_id = es.city_id ORDER BY o.order_id")) {
        qWarning() << "orders load:" << q.lastError(); return;
    }

    while (q.next()) {
        const QString trainNum = q.value(1).toString();
        Passenger passenger(q.value(11).toString(), q.value(12).toString(), q.value(13).toString(), q.value(14).toString(), q.value(10).toString());
        Station stStart(q.value(15).toString(), q.value(16).toString());
        Station stEnd(q.value(17).toString(), q.value(18).toString());

        QDate td = q.value(3).toDate();
        Date d = td.isValid() ? Date(td.year(), td.month(), td.day()) : Date(2000, 1, 1);

        Timetable tt;
        const QString snap = q.value(9).toString();
        if (!RailwayPgCodec::timetableFromStopsJson(snap, tt)) {
            if (m_trainManager) {
                auto tr = m_trainManager->getTrainByTrainNumber(trainNum);
                if (tr) tt = tr->getTimetable();
            }
        }

        Order ord(q.value(0).toString(), trainNum, passenger, q.value(2).toDouble(), d, tt, stStart, stEnd, q.value(4).toString(), q.value(5).toInt(), q.value(6).toInt(), q.value(7).toInt(), q.value(8).toString(), q.value(10).toString());
        orders.push_back(ord);
    }
}

void OrderManager::saveToPostgres() {
    QSqlDatabase db = QSqlDatabase::database("railway", false);
    if (!db.isOpen()) return;

    QSqlQuery ping(db); if (!ping.exec("SELECT 1")) { db.close(); db.open(); }
    if (!db.transaction()) return;

    QSqlQuery qDel(db); qDel.exec("DELETE FROM orders");

    for (Order &o : orders) {
        const int uid = lookupUserId(db, o.getUsername());
        const int tid = lookupTrainId(db, o.getTrainNumber());
        const int pid = lookupPassengerId(db, o.getPassenger().getId());
        const int sid = lookupStationId(db, o.getStartStation().getStationName());
        const int eid = lookupStationId(db, o.getEndStation().getStationName());

        // 容错：如果某些外键没找到，跳过该订单以防崩溃
        if (uid < 0 || tid < 0 || pid < 0 || sid < 0 || eid < 0) {
            qWarning() << "警告：订单缺少依赖实体，暂时跳过保存：" << o.getOrderNumber();
            continue;
        }

        Timetable ttCopy = o.getTimetable();
        const QString snap = RailwayPgCodec::timetableToStopsJson(ttCopy);
        const QDate td(o.getDate().getYear(), o.getDate().getMonth(), o.getDate().getDay());

        QSqlQuery qi(db);
        qi.prepare("INSERT INTO orders (order_number, user_id, train_id, passenger_id, start_station_id, end_station_id, seat_level, carriage_number, seat_row, seat_col, price, travel_date, status, timetable_snapshot) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
        qi.addBindValue(o.getOrderNumber()); qi.addBindValue(uid); qi.addBindValue(tid); qi.addBindValue(pid); qi.addBindValue(sid); qi.addBindValue(eid); qi.addBindValue(o.getSeatLevel()); qi.addBindValue(o.getCarriageNumber()); qi.addBindValue(o.getSeatRow()); qi.addBindValue(o.getSeatCol()); qi.addBindValue(o.getPrice()); qi.addBindValue(td); qi.addBindValue(o.getStatus()); qi.addBindValue(snap);
        if (!qi.exec()) { db.rollback(); return; }
    }
    db.commit();
}