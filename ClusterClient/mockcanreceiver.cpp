#include "mockcanreceiver.h"

MockCanReceiver::MockCanReceiver(QObject *parent)
    : QObject{parent}
{
    connect(&m_timer, &QTimer::timeout, this, &MockCanReceiver::onTick);
}

void MockCanReceiver::start()
{
    m_timer.start(20); // 20ms một lần
}

void MockCanReceiver::onTick()
{
    // 1. Logic giả lập Tốc độ & Vòng tua
    if(m_increasing){
        m_fakeSpeed += 0.5;
        m_fakeRpm += 20;
        if(m_fakeSpeed >= 240) m_increasing = false;
    }else{
        m_fakeSpeed -= 0.5;
        m_fakeRpm -= 20;
        if(m_fakeSpeed <= 0) m_increasing = true;
    }

    emit speedReceived(m_fakeSpeed);
    emit rpmReceived(m_fakeRpm);

    // 2. Logic giả lập bấm nút Xi nhan
    // Vì timer chạy 20ms -> 50 tick = 1 giây.
    static int tickCount = 0;
    tickCount++;

    if (tickCount < 250) {          // 0 - 5 giây đầu: Bật xi nhan TRÁI
        emit leftSignalReceived(true);
        emit rightSignalReceived(false);
        emit hazardReceived(false);
    } else if (tickCount < 500) {   // 5 - 10 giây tiếp: Bật xi nhan PHẢI
        emit leftSignalReceived(false);
        emit rightSignalReceived(true);
        emit hazardReceived(false);
    } else if (tickCount < 750) {   // 10 - 15 giây cuối: Bật HAZARD
        emit leftSignalReceived(false);
        emit rightSignalReceived(false);
        emit hazardReceived(true);
    } else {
        tickCount = 0; // Quay lại từ đầu
    }
}
