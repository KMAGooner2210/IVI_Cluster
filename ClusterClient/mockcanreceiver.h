#ifndef MOCKCANRECEIVER_H
#define MOCKCANRECEIVER_H

#include <QObject>
#include <QTimer>

class MockCanReceiver : public QObject
{
    Q_OBJECT
public:
    explicit MockCanReceiver(QObject *parent = nullptr);
    void start();

signals:
    void speedReceived(double speed);
    void rpmReceived(double rpm);
    void leftSignalReceived(bool on);
    void rightSignalReceived(bool on);
    void hazardReceived(bool on);

private slots:
    void onTick();

private:
    QTimer m_timer;
    double m_fakeSpeed = 0;
    double m_fakeRpm = 0;
    bool m_increasing = true;
};

#endif // MOCKCANRECEIVER_H
