#ifndef RAILWAY_PG_CODEC_H
#define RAILWAY_PG_CODEC_H

#include <QString>

class Timetable;
class Train;
class Station;

namespace RailwayPgCodec {

// trains.seat_config：JSON 文本 { "stops": [...], "carriages": [...] }
QString trainToSeatConfigJson(Train &train);
bool trainFromSeatConfigJson(const QString &json, const QString &trainNumber, Train &outTrain);

// orders.timetable_snapshot：仅 stops 数组（与 seat_config 内 stops 结构相同）
QString timetableToStopsJson(Timetable &timetable);
bool timetableFromStopsJson(const QString &json, Timetable &out);

} // namespace RailwayPgCodec

#endif
