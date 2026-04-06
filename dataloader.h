#ifndef DATALOADER_H
#define DATALOADER_H

#include <QThread>
#include <QSqlDatabase>
#include "stationmanager.h"
#include "trainmanager.h"
#include "accountmanager.h"
#include "passengermanager.h"
#include "ordermanager.h"

class DataLoader : public QThread
{
    Q_OBJECT

public:
    DataLoader(StationManager* sm, TrainManager* tm, AccountManager* am, PassengerManager* pm, OrderManager* om);
    ~DataLoader();

signals:
    void progressUpdated(int percent, QString message);
    void loadFinished();

protected:
    void run() override;

private:
    StationManager* m_stationManager;
    TrainManager* m_trainManager;
    AccountManager* m_accountManager;
    PassengerManager* m_passengerManager;
    OrderManager* m_orderManager;
};

#endif // DATALOADER_H
