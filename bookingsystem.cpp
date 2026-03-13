#include "bookingsystem.h"
#include <QVariantMap>
#include <QDebug>
#include <QSet>
#include <iostream>
#include <stack>
#include <ctime>
#include <QDebug>
#include <QVariantMap>

BookingSystem::BookingSystem(StationManager* stationManager,
                                OrderManager* orderManager,
                                TrainManager* trainManager,
                                AccountManager* accountManager,
                                PassengerManager *passengerManager,
                                QObject* parent)
    :station_manager(stationManager),
    order_manager(orderManager),
    train_manager(trainManager),
    account_manager(accountManager),
    passenger_manager(passengerManager),
    QObject{parent}
{
    // 获取当前时间戳
    std::time_t t = std::time(nullptr);
    std::tm* now = std::localtime(&t);
    // 分别获取年、月、日
    int year = now->tm_year + 1900;
    int month = now->tm_mon + 1;
    int day = now->tm_mday;
    // 存储今天日期
    today.setYear(year);
    today.setMonth(month);
    today.setDay(day);
}

QVariantList BookingSystem::getQueryHistory_api() {
    QVariantList list;
    std::queue<std::tuple<City, City>> tmp = query_history;
    std::stack<std::tuple<City, City>> s;

    // 倒置
    while (!tmp.empty()) {
        s.push(tmp.front());
        tmp.pop();
    }
    while (!s.empty()) {
        tmp.push(s.top());
        s.pop();
    }

    while (!tmp.empty()) {
        City startCity = std::get<0>(tmp.front());
        City endCity = std::get<1>(tmp.front());
        QVariantMap map;
        map["startCity"] = startCity.getName();
        map["endCity"] = endCity.getName();
        list << map;
        tmp.pop();
    }
    return list;
}

bool BookingSystem::addQueryHistory_api(const QString &startCityName, const QString &endCityName) {
    if (!station_manager) {
        return false;
    }
    auto startCityFindResult = station_manager->getCityByCityName(startCityName);
    auto endCityFindResult = station_manager->getCityByCityName(endCityName);
    if (!startCityFindResult or !endCityFindResult) {
        return false;
    }
    City startCity = startCityFindResult.value();
    City endCity = endCityFindResult.value();
    std::tuple<City, City> t = std::make_tuple(startCity, endCity);
    query_history.push(t);
    if (query_history.size() > 3)
        query_history.pop();
    emit queryHistoryChanged();
    return true;
}

bool BookingSystem::clearQueryHistory_api() {
    while (!query_history.empty()) {
        query_history.pop();
    }
    emit queryHistoryChanged();
    return true;
}

QVariantList BookingSystem::queryTickets_api(const QString &startCityName,
                                             const QString &endCityName,
                                             int year, int month, int day) {
    QVariantList list;
    if (!station_manager || !order_manager || ! train_manager || !account_manager) {
        qWarning() << "管理类为空！";
        return list;
    }

    qWarning() << "日期：" << year << month << day;

    // 查询满足能从起始城市开到终点城市的所有车次和车站安排
    std::vector<std::tuple<Train, Station, Station>> routes = train_manager->getRoutesByCities(startCityName, endCityName);
    // 实例化要查询的日期
    Date queryStartDate(year, month, day);
    // 遍历每趟车次，计算其在那一天的余票
    for (auto &route : routes) {
        // 获得该车次的各等级座位数量，如果座位数减为0，代表没票了
        Train train = std::get<0>(route);
        int firstClassCount = train.getFirstClassCount();
        int secondClassCount = train.getSecondClassCount();
        int businessClassCount = train.getBusinessClassCount();
        // 获得该安排的车站的出发和终点日期时间
        Station startStation = std::get<1>(route), endStation = std::get<2>(route);
        Timetable timetable = train.getTimetable();
        std::tuple<Time, Time, int, int, QString> startStationInfo = timetable.getStationInfo(startStation.getStationName());
        std::tuple<Time, Time, int, int, QString> endStationInfo = timetable.getStationInfo(endStation.getStationName());
        Date queryEndDate = queryStartDate + std::get<2>(endStationInfo) - std::get<3>(startStationInfo);
        Time queryStartTime = std::get<1>(startStationInfo);
        Time queryendTime = std::get<0>(endStationInfo);
        // 根据车次、始末站日期时间，查找和该安排重叠的订单
        std::vector<Order> ordersOverlap = order_manager->getOrdersUnusedAndOverlapByTrainNumber(train.getNumber(),
                                                                                                 queryStartDate, queryEndDate,
                                                                                                 queryStartTime, queryendTime);
        // 遍历每个重叠订单
        for (auto order : ordersOverlap) {
            if (order.getSeatLevel() == "一等座") {
                firstClassCount--;
                qWarning() << "检测到一等座被占用！";
            } else if (order.getSeatLevel() == "二等座") {
                secondClassCount--;
                qWarning() << "检测到二等座被占用！";
            } else if (order.getSeatLevel() == "商务座") {
                businessClassCount--;
                qWarning() << "检测到商务座被占用！";
            }
        }
        // 如果遍历完所有订单后，发现该车次当天仍然有余票，则向前端返回该安排
        QVariantMap map;
        map["trainNumber"] = train.getNumber();
        map["startStationName"] = startStation.getStationName();
        map["startYear"] = queryStartDate.getYear();
        map["startMonth"] = queryStartDate.getMonth();;
        map["startDay"] = queryStartDate.getDay();
        map["startHour"] = std::get<1>(startStationInfo).getHour();
        map["startMinute"] = std::get<1>(startStationInfo).getMinute();
        map["startStationStopInfo"] = std::get<4>(startStationInfo);
        map["endStationName"] = endStation.getStationName();
        map["endYear"] = queryEndDate.getYear();
        map["endMonth"] = queryEndDate.getMonth();
        map["endDay"] = queryEndDate.getDay();
        map["endHour"] = std::get<0>(endStationInfo).getHour();
        map["endMinute"] = std::get<0>(endStationInfo).getMinute();
        map["endStationStopInfo"] = std::get<4>(endStationInfo);

        // 计算历时
        int intervalSeconds = timetable.getInterval(startStation, endStation);
        int hours = intervalSeconds / 3600, minutes = (intervalSeconds % 3600) / 60;
        map["intervalHour"] = hours;
        map["intervalMinute"] = minutes;

        // 计算票价
        std::tuple<double, double, double> prices = computePrice(train.getNumber(), startStation, endStation);
        map["firstClassPrice"] = std::get<0>(prices);
        map["secondClassPrice"] = std::get<1>(prices);
        map["businessClassPrice"] = std::get<2>(prices);

        map["firstClassCount"] = firstClassCount;
        map["secondClassCount"] = secondClassCount;
        map["businessClassCount"] = businessClassCount;

        qWarning() << "firstClassCount =" << firstClassCount
                   << "secondClassCount =" << secondClassCount
                   << "businessClassCount =" << businessClassCount;

        list << map;
    }
    return list;
}

QVariantList BookingSystem::getPassengers_api(const QVariantMap &info) {
    QString username = info["username"].toString();
    int startYear = info["startYear"].toInt(), startMonth = info["startMonth"].toInt(), startDay = info["startDay"].toInt();
    int endYear = info["endYear"].toInt(), endMonth = info["endMonth"].toInt(), endDay = info["endDay"].toInt();
    int startHour = info["startHour"].toInt(), startMinute = info["startMinute"].toInt();
    int endHour = info["endHour"].toInt(), endMinute = info["endMinute"].toInt();
    Date startDate(startYear, startMonth, startDay), endDate(endYear, endMonth, endDay);
    Time startTime(startHour, startMinute, 0), endTime(endHour, endMinute, 0);

    QVariantList list;
    if (username == "") {
        // 管理员改签逻辑
    }
    else {
        std::vector<Passenger> passengers = passenger_manager->getPassengersByUsername(username);
        for (auto passenger : passengers) {
            QVariantMap map;
            map["name"] = passenger.getName();
            map["phoneNumber"] = passenger.getPhoneNumber();
            map["id"] = passenger.getId();
            map["type"] = passenger.getType();

            if (order_manager->isPassengerAvailable(passenger.getId(),
                                                    startDate, endDate,
                                                    startTime, endTime)) {
                map["available"] = true;
            }
            else {
                map["available"] = false;
            }

            list << map;
        }
    }

    return list;
}

QVariantMap BookingSystem::createOrder_api(const QVariantMap &info) {
    QString username = info["username"].toString();
    QString trainNumber = info["trainNumber"].toString();
    QString passengerId = info["passengerId"].toString();
    QString startStationName = info["startStationName"].toString();
    QString endStationName = info["endStationName"].toString();
    int year = info["year"].toInt(), month = info["month"].toInt(), day = info["day"].toInt();
    QString seatLevel = info["seatLevel"].toString();
    QString pendingRescheduleOrderNumber = info["pendingRescheduleOrderNumber"].toString();

    QVariantMap result;
    // 根据用户名、车次号、乘客身份证号、起始站名、终点站名、待改签订单号查找对应实体
    if (username != "") {
        auto userFindResult = account_manager->getUserByUsername(username);
        if (!userFindResult) {
            result["success"] = false;
            result["message"] = QString("用户 %1 不存在！").arg(username);
            return result;
        }
    }
    if (pendingRescheduleOrderNumber != "") {
        auto pendingRescheduleOrderFindResult = order_manager->getOrderByOrderNumber(pendingRescheduleOrderNumber);
        if (!pendingRescheduleOrderFindResult) {
            result["success"] = false;
            result["message"] = QString("待改签订单 %1 不存在！").arg(pendingRescheduleOrderNumber);
            return result;
        }
    }

    User user;
    Order pendingReschduleOrder;
    // 如果是改签模式，从待改签订单中获得用户信息，否则获取参数给的用户信息
    if (pendingRescheduleOrderNumber != "") {
        pendingReschduleOrder = order_manager->getOrderByOrderNumber(pendingRescheduleOrderNumber).value();
        user = account_manager->getUserByUsername(pendingReschduleOrder.getUsername()).value();
    }
    else {
        user = account_manager->getUserByUsername(username).value();
    }

    auto trainFindResult = train_manager->getTrainByTrainNumber(trainNumber);
    if (!trainFindResult) {
        result["success"] = false;
        result["message"] = QString("车次 %1 不存在！").arg(trainNumber);
        return result;
    }
    auto passengerFindResult = passenger_manager->getPassengerByUsernameAndId(user.getUsername(), passengerId);
    if (!passengerFindResult) {
        result["success"] = false;
        result["message"] = QString("用户 %1 下身份证号为 %2 的乘客不存在！").arg(username, passengerId);
        return result;
    }
    auto startStationFindResult = station_manager->getStationByStationName(startStationName);
    if (!startStationFindResult) {
        result["success"] = false;
        result["message"] = QString("车站 %1 不存在！").arg(startStationName);
        return result;
    }
    auto endStationFindResult = station_manager->getStationByStationName(endStationName);
    if (!endStationFindResult) {
        result["success"] = false;
        result["message"] = QString("车站 %1 不存在！").arg(endStationName);
        return result;
    }
    Train train = trainFindResult.value();
    Passenger passenger = passengerFindResult.value();
    Station startStation = startStationFindResult.value();
    Station endStation = endStationFindResult.value();
    Date startDate(year, month, day);
    std::tuple<Time, Time, int, int, QString> startStationInfo = train.getTimetable().getStationInfo(startStation.getStationName());
    std::tuple<Time, Time, int, int, QString> endStationInfo = train.getTimetable().getStationInfo(endStation.getStationName());
    Date endDate = startDate + std::get<2>(endStationInfo) - std::get<3>(startStationInfo);
    Time startTime = std::get<1>(startStationInfo);
    Time endTime = std::get<0>(endStationInfo);
    int carriageNumber = -1, seatRow = -1, seatCol = -1;

    // 检索被占用的座位号信息
    std::vector<std::tuple<int, int, int>> unavailableSeatsInfo = order_manager->getUnavailableSeatsInfo(trainNumber, seatLevel,
                                                                                                         startDate, endDate,
                                                                                                         startTime, endTime,
                                                                                                         pendingRescheduleOrderNumber);
    // 建立三维数组，初值为0，存储每个座位信息
    std::vector<std::tuple<QString, int, int>> carriages = train.getCarriages();
    std::vector<std::vector<std::vector<bool>>> seats(0, std::vector<std::vector<bool>>(0, std::vector<bool> (0, true)));
    int lenCarriages = carriages.size();
    for (int i = 0; i < lenCarriages; i++) {
        int lenRow = std::get<1>(carriages[i]), lenCol = std::get<2>(carriages[i]);
        seats.push_back(std::vector<std::vector<bool>>(lenRow, std::vector<bool>(lenCol, true)));
    }
    // 对于被占用的座位，标记为 false
    int lenUnavailableSeatInfo = unavailableSeatsInfo.size();
    qWarning() << "冲突座位数：" << lenUnavailableSeatInfo;
    for (int i = 0; i < lenUnavailableSeatInfo; i++) {
        int currentCarriageNumber = std::get<0>(unavailableSeatsInfo[i]);
        int row = std::get<1>(unavailableSeatsInfo[i]), col = std::get<2>(unavailableSeatsInfo[i]);
        seats[currentCarriageNumber - 1][row - 1][col - 1] = false; // 这里别忘了减1！！！！
    }
    // 按顺序从小到大遍历，首次适配法选择最终座位
    bool findFlag = false;
    for (int i = 0; i < lenCarriages; i++) {
        if (findFlag)
            break;
        QString currentSeatLevel = std::get<0>(carriages[i]);
        if (currentSeatLevel == seatLevel) {
            int lenRow = std::get<1>(carriages[i]), lenCol = std::get<2>(carriages[i]);
            for (int j = 0; j < lenRow; j++) {
                if (findFlag)
                    break;
                for (int k = 0; k < lenCol; k++) {
                    if (seats[i][j][k]) {
                        carriageNumber = i + 1;
                        seatRow = j + 1;
                        seatCol = k + 1;
                        findFlag = true;
                        break;
                    }
                }
            }
        }
    }

    // 计算票价
    std::tuple<double, double, double> prices = computePrice(train.getNumber(), startStation, endStation);
    double rawPrice = (seatLevel == "一等座") ? std::get<0>(prices) :
                       (seatLevel == "二等座") ? std::get<1>(prices) :
                       (seatLevel == "商务座") ? std::get<2>(prices) : 0.0;
    double discount = (passenger.getType() == "成人") ? 1.0 :
                      (passenger.getType() == "儿童") ? 0.5 :
                      (passenger.getType() == "学生") ? 0.75 : 1.0;
    double price = rawPrice * discount;

    // 创建订单
    Order order("", train.getNumber(), passenger, price, startDate, train.getTimetable(),
                startStation, endStation, seatLevel, carriageNumber, seatRow, seatCol,
                "待乘坐", user.getUsername());
    // 向OrderManager提交
    order_manager->createOrder(order);
    // 如果有待改签订单号，则标记为“已改签”
    if (pendingRescheduleOrderNumber != "")
        order_manager->rescheduleOrder(pendingReschduleOrder.getOrderNumber());

    result["success"] = true;
    result["message"] = "车票预定成功，可在“我的订单”查看车票！";
    return result;
}

QVariantMap BookingSystem::isPassengerEditable_api(const QVariantMap &info) {
    QVariantMap result;
    QString username = info["username"].toString();
    QString passengerId = info["passengerId"].toString();
    auto passengerFindResult = passenger_manager->getPassengerByUsernameAndId(username, passengerId);
    if (!passengerFindResult) {
        result["success"] = false;
        result["message"] = QString("用户 %1 下的乘车人 %2 不存在！").arg(username, passengerId);
        return result;
    }
    if (order_manager->hasUnusedOrderForPassenger(username, passengerId)) {
        result["success"] = false;
        result["message"] = "该乘车人有待乘坐订单，无法修改该乘车人信息！";
        return result;
    }
    result["success"] = true;
    result["message"] = "该乘车人信息可以修改！";
    return result;
}

QVariantMap BookingSystem::deleteUser_api(const QVariantMap &info) {
    QVariantMap result;
    QString username = info["username"].toString();
    if (!account_manager->getUserByUsername(username)) {
        result["success"] = false;
        result["message"] = QString("用户 %1 不存在！").arg(username);
        return result;
    }
    // 删除该用户所有订单
    order_manager->deleteOrdersByUsername(username);
    // 删除该用户所有乘车人信息
    passenger_manager->deletePassengersByUsername(username);
    // 删除该用户
    account_manager->deleteUser(username);
    result["success"] = true;
    result["message"] = QString("用户 %1 注销成功！").arg(username);
    return result;
}

QVariantMap BookingSystem::updateTimetableAndTrainNumber_api(const QVariantMap &info) {
    QVariantMap result;
    // 获取老车次号、新车次号和时刻表
    QString oldTrainNumber = info["oldTrainNumber"].toString();
    QString newTrainNumber = info["newTrainNumber"].toString();
    QVariantList list = info["passingStationList"].toList();
    Timetable timetable;
    if (newTrainNumber == "") {
        result["success"] = false;
        result["message"] = "车次号不能为空！";
        return result;
    }
    // 检查新车次号是否合法（首字母必须为大写字母且后面必须是纯数字)
    for (int i = 0; i < newTrainNumber.size(); i++) {
        QChar c = newTrainNumber.at(i);
        if (i == 0 && (c < QChar('A') || c > QChar('Z'))) {
            result["success"] = false;
            result["message"] = "车次号必须以大写字母开头！";
            return result;
        }
        if (i != 0 && (c < QChar('0') || c > QChar('9'))) {
            result["success"] = false;
            result["message"] = "车次号除第一个大写字母以外必须是纯数字！";
            return result;
        }
    }
    
    // 验证时刻表长度
    if (list.size() <= 1) {
        result["success"] = false;
        result["message"] = "起末站不完整！";
        return result;
    }
    
    // 用于检查站名重复
    QSet<QString> stationSet;
    
    // 遍历前端传过来的时刻表,并检查车站是否存在以及时间合法性
    for (int i = 0; i < list.size(); i++) {
        QVariantMap passingStation = list[i].toMap();
        QString stationName = passingStation["stationName"].toString();
        int arriveHour = passingStation["arriveHour"].toInt();
        int arriveMinute = passingStation["arriveMinute"].toInt();
        int arriveDay = passingStation["arriveDay"].toInt();
        int departureHour = passingStation["departureHour"].toInt();
        int departureMinute = passingStation["departureMinute"].toInt();
        int departureDay = passingStation["departureDay"].toInt();
        
        // 判断站名是否缺失
        if (stationName.isEmpty()) {
            result["success"] = false;
            result["message"] = QString("第 %1 站站名缺失！").arg(i + 1);
            return result;
        }
        
        // 判断是否重复经过某一站
        if (stationSet.contains(stationName)) {
            result["success"] = false;
            result["message"] = QString("重复经过 %1 站！").arg(stationName);
            return result;
        }
        stationSet.insert(stationName);
        
        // 判断起始站各时间字段是否合法
        if (i == 0 && (arriveHour != -1 || arriveMinute != -1 || arriveDay != -1 ||
                       departureHour == -1 || departureMinute == -1 || departureDay != 0)) {
            result["success"] = false;
            result["message"] = QString("第 %1 站时刻项错误！起始站不应有到达时间，发车日期应为0").arg(i + 1);
            return result;
        }
        
        // 判断终点站各时间字段是否合法
        if (i == list.size() - 1 && (arriveHour == -1 || arriveMinute == -1 || arriveDay == -1 ||
                       departureHour != -1 || departureMinute != -1 || departureDay != -1)) {
            result["success"] = false;
            result["message"] = QString("第 %1 站时刻项错误！终点站不应有发车时间").arg(i + 1);
            return result;
        }
        
        // 判断中间站各时间字段是否合法
        if (i != 0 && i != list.size() - 1 && (arriveHour == -1 || arriveMinute == -1 || arriveDay == -1 ||
                       departureHour == -1 || departureMinute == -1 || departureDay == -1)) {
            result["success"] = false;
            result["message"] = QString("第 %1 站时刻项错误！中间站必须有完整的到达和发车时间").arg(i + 1);
            return result;
        }
        
        // 判断中间站的到时是不是在发时的前面
        if (i != 0 && i != list.size() - 1 && (arriveDay > departureDay ||
            (arriveDay == departureDay && arriveHour > departureHour) ||
            (arriveDay == departureDay && arriveHour == departureHour && arriveMinute >= departureMinute))) {
            result["success"] = false;
            result["message"] = QString("第 %1 站到时应在发时之前！").arg(i + 1);
            return result;
        }
        
        // 判断该站的到时是不是在上一站发时的后面
        if (i > 0) {
            QVariantMap prevStation = list[i - 1].toMap();
            int prevDepartureDay = prevStation["departureDay"].toInt();
            int prevDepartureHour = prevStation["departureHour"].toInt();
            int prevDepartureMinute = prevStation["departureMinute"].toInt();
            
            if (arriveDay < prevDepartureDay ||
                (arriveDay == prevDepartureDay && arriveHour < prevDepartureHour) ||
                (arriveDay == prevDepartureDay && arriveHour == prevDepartureHour && arriveMinute <= prevDepartureMinute)) {
                result["success"] = false;
                result["message"] = QString("第 %1 站到时应在上一站发时之后！").arg(i + 1);
                return result;
            }
        }
        
        auto stationFindResult = station_manager->getStationByStationName(stationName);
        if (!stationFindResult) {
            result["success"] = false;
            result["message"] = QString("车站 %1 不存在！").arg(stationName);
            return result;
        }
        Station station = stationFindResult.value();
        Time arriveTime(arriveHour, arriveMinute);
        Time departureTime(departureHour, departureMinute);
        timetable.insertPassingStationAtEnd(station, arriveTime, departureTime, arriveDay, departureDay);
    }
    // 修改车次号和时刻表（必须一起修改，否则一个失败，需要全部撤销）
    result = train_manager->updateTimetableAndTrainNumberByTrainNumber(oldTrainNumber, timetable, newTrainNumber);
    return result;
}

QVariantMap BookingSystem::isTrainEditable_api(const QVariantMap &info) {
    QVariantMap result;
    QString trainNumber = info["trainNumber"].toString();
    if (order_manager->hasUnusedOrderForTrain(trainNumber)) {
        result["success"] = false;
        result["message"] = "该车次有待乘坐订单，无法修改该车次信息！";
        return result;
    }
    result["success"] = true;
    result["message"] = "该车次信息可以修改！";
    return result;
}

QVariantMap BookingSystem::updateSeatTemplate_api(const QVariantMap &info) {
    QVariantMap result;
    QString trainNumber = info["trainNumber"].toString();
    int carriageNum = info["carriageNum"].toInt();
    int firstStart = info["firstStart"].toInt();
    int firstEnd = info["firstEnd"].toInt();
    int firstRows = info["firstRows"].toInt();
    int firstCols = info["firstCols"].toInt();
    int secondStart = info["secondStart"].toInt();
    int secondEnd = info["secondEnd"].toInt();
    int secondRows = info["secondRows"].toInt();
    int secondCols = info["secondCols"].toInt();
    int businessStart = info["businessStart"].toInt();
    int businessEnd = info["businessEnd"].toInt();
    int businessRows = info["businessRows"].toInt();
    int businessCols = info["businessCols"].toInt();

    // qWarning() << carriageNum;
    // qWarning() << firstStart << firstEnd << firstRows << firstCols;
    // qWarning() << secondStart << secondEnd << secondRows << secondCols;
    // qWarning() << businessStart << businessEnd << businessRows << businessCols;

    std::vector<std::tuple<QString, int, int>> carriages;
    carriages.resize(carriageNum);
    for (int i = firstStart; i <= firstEnd; i++) {
        std::tuple<QString, int, int> carriage = std::make_tuple("一等座", firstRows, firstCols);
        carriages[i - 1] = carriage;
    }
    for (int i = secondStart; i <= secondEnd; i++) {
        std::tuple<QString, int, int> carriage = std::make_tuple("二等座", secondRows, secondCols);
        carriages[i - 1] = carriage;
    }
    for (int i = businessStart; i <= businessEnd; i++) {
        std::tuple<QString, int, int> carriage = std::make_tuple("商务座", businessRows, businessCols);
        carriages[i - 1] = carriage;
    }
    result = train_manager->updateSeatTemplateByTrainNumber(trainNumber, carriages);
    return result;
}

std::tuple<double, double, double> BookingSystem::computePrice(const QString &trainNumber, Station &startStation, Station &endStation) {
    Train train = train_manager->getTrainByTrainNumber(trainNumber).value();
    Timetable timetable = train.getTimetable();
    std::vector<Station> stations = timetable.getStationsBetweenStations(startStation, endStation);

    QChar trainType = trainNumber[0];
    double times;
    if (trainType == 'G') {
        times = 1;
    } else if (trainType == 'D') {
        times = 0.8;
    } else if (trainType == 'C') {
        times = 0.7;
    } else if (trainType == 'T') {
        times = 0.8;
    } else if (trainType == 'K') {
        times = 0.5;
    } else {
        times = 0.3;
    }

    double secondClassPrice = 0;
    int len = stations.size();
    for (int i = 0; i < len - 1; i++) {
        auto result1 = station_manager->getCityByCityName(stations[i].getCityName());
        auto result2 = station_manager->getCityByCityName(stations[i+1].getCityName());
        if (!result1 || !result2) {
            return std::make_tuple(0.0, 0.0, 0.0);
        }
        City city1 = result1.value(), city2 = result2.value();
        double distance = station_manager->computeDistance(city1, city2);
        secondClassPrice += distance * times;
    }
    // 保留两位小数
    secondClassPrice = std::round(secondClassPrice * 100.0) / 100.0;
    double firstClassPrice = std::round(secondClassPrice * 1.5 * 100.0) / 100.0;
    double businessClassPrice = std::round(secondClassPrice * 2.0 * 100.0) / 100.0;
    qWarning() << "---" << secondClassPrice;

    return std::make_tuple(firstClassPrice, secondClassPrice, businessClassPrice);
}
