#include "mockcanreceiver.h"
#include <QDebug>

MockCanReceiver::MockCanReceiver(QObject *parent)
    : QObject{parent}, m_simSpeed(0.0), m_speedIncreasing(true)
{
    // Cài đặt Timer mô phỏng chu kỳ 50ms như nhịp gửi từ STM32 thực tế
    m_dataTimer = new QTimer(this);
    m_dataTimer->setInterval(50); 
    connect(m_dataTimer, &QTimer::timeout,
            this, &MockCanReceiver::simulateTick);

    // Luân chuyển trạng thái đèn xi nhan sau mỗi 5 giây để test UI
    m_turnTimer = new QTimer(this);
    m_turnTimer->setInterval(5000);
    connect(m_turnTimer, &QTimer::timeout,
            this, &MockCanReceiver::simulateTurnSignal);
}

void MockCanReceiver::start() {
    m_dataTimer->start();
    m_turnTimer->start();
    qInfo() << "[MockCAN] Simulation mode active. Real CAN bus is bypassed.";
}

void MockCanReceiver::simulateTick() {
    const double STEP = 0.5;
    const double MAX_SPEED = 120.0;

    // Tăng giảm tốc độ tuần hoàn từ 0 -> 120 km/h
    if (m_speedIncreasing) {
        m_simSpeed += STEP;
        if (m_simSpeed >= MAX_SPEED) {
            m_speedIncreasing = false;
        }
    } else {
        m_simSpeed -= STEP;
        if (m_simSpeed <= 0.0) {
            m_simSpeed = 0.0;
            m_speedIncreasing = true;
        }
    }

    // Tính toán RPM giả lập tương quan với tốc độ
    double rpm = (m_simSpeed < 1.0) ? 1000.0 : (1000.0 + m_simSpeed * 25.0);

    // Phát tín hiệu đồng bộ lên Dashboard
    emit speedReceived(m_simSpeed);
    emit rpmReceived(rpm);
}

void MockCanReceiver::simulateTurnSignal() {
    static int state = 0;
    switch (state % 4) {
        case 0: // Xi nhan Trái bật, Phải tắt
            emit leftSignalReceived(true);  
            emit rightSignalReceived(false);
            emit hazardReceived(false); 
            break;
        case 1: // Xi nhan Trái tắt, Phải bật
            emit leftSignalReceived(false); 
            emit rightSignalReceived(true);
            emit hazardReceived(false); 
            break;
        case 2: // Cả hai đèn cùng nháy (Chế độ khẩn cấp Hazard)
            emit leftSignalReceived(true);  
            emit rightSignalReceived(true);
            emit hazardReceived(true);  
            break; 
        case 3: // Tắt toàn bộ xi nhan
            emit leftSignalReceived(false); 
            emit rightSignalReceived(false);
            emit hazardReceived(false); 
            break;
    }
    state++;
}
