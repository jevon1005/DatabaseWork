#include "railway_pg_codec.h"

#include "timetable.h"
#include "train.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <sstream>
#include <string>

namespace RailwayPgCodec {

static QString timetableToB64(Timetable &timetable)
{
    std::ostringstream oss;
    oss << timetable;
    const std::string &s = oss.str();
    return QString::fromLatin1(QByteArray::fromRawData(s.data(), int(s.size())).toBase64());
}

static bool timetableFromB64(const QString &b64, Timetable &out)
{
    if (b64.isEmpty())
        return false;
    const QByteArray raw = QByteArray::fromBase64(b64.toLatin1());
    std::istringstream iss(std::string(raw.constData(), size_t(raw.size())));
    iss >> out;
    return !iss.fail();
}

QString trainToSeatConfigJson(Train &train)
{
    Timetable tt = train.getTimetable();
    QJsonObject root;
    root[QStringLiteral("timetable_b64")] = timetableToB64(tt);
    QJsonArray cg;
    for (const auto &c : train.getCarriages()) {
        QJsonArray row;
        row.append(std::get<0>(c));
        row.append(std::get<1>(c));
        row.append(std::get<2>(c));
        cg.append(row);
    }
    root[QStringLiteral("carriages")] = cg;
    return QString::fromUtf8(QJsonDocument(root).toJson(QJsonDocument::Compact));
}

bool trainFromSeatConfigJson(const QString &json, const QString &trainNumber, Train &outTrain)
{
    const QJsonDocument doc = QJsonDocument::fromJson(json.toUtf8());
    if (!doc.isObject())
        return false;
    const QJsonObject root = doc.object();
    Timetable tt;
    if (!timetableFromB64(root.value(QStringLiteral("timetable_b64")).toString(), tt))
        return false;
    outTrain.setNumber(trainNumber);
    outTrain.setTimetable(tt);
    std::vector<std::tuple<QString, int, int>> carriages;
    const QJsonArray cg = root.value(QStringLiteral("carriages")).toArray();
    for (const QJsonValue &v : cg) {
        const QJsonArray row = v.toArray();
        if (row.size() != 3)
            continue;
        carriages.push_back(std::make_tuple(row.at(0).toString(), row.at(1).toInt(), row.at(2).toInt()));
    }
    outTrain.setCarriages(carriages);
    return true;
}

QString timetableToStopsJson(Timetable &timetable)
{
    QJsonObject root;
    root[QStringLiteral("timetable_b64")] = timetableToB64(timetable);
    return QString::fromUtf8(QJsonDocument(root).toJson(QJsonDocument::Compact));
}

bool timetableFromStopsJson(const QString &json, Timetable &out)
{
    if (json.isEmpty())
        return false;
    const QJsonDocument doc = QJsonDocument::fromJson(json.toUtf8());
    if (!doc.isObject())
        return false;
    const QString b64 = doc.object().value(QStringLiteral("timetable_b64")).toString();
    return timetableFromB64(b64, out);
}

} // namespace RailwayPgCodec
