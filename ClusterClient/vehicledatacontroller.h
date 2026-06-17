#ifndef VEHICLEDATACONTROLLER_H
#define VEHICLEDATACONTROLLER_H

#include <QObject>
#include <QTimer>

class VehicleDataController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double speed   READ speed   NOTIFY speedChanged)
    Q_PROPERTY(double rpm     READ rpm     NOTIFY rpmChanged)
    Q_PROPERTY(bool   leftOn  READ leftOn  NOTIFY leftOnChanged)
    Q_PROPERTY(bool   rightOn READ rightOn NOTIFY rightOnChanged)
    Q_PROPERTY(bool   hazard  READ hazard  NOTIFY hazardChanged)

public:
    explicit VehicleDataController(QObject *parent = nullptr);

    double speed() const { return m_speed; }
    double rpm() const { return m_rpm; }
    bool leftOn() const { return m_leftOn; }
    bool rightOn() const { return m_rightOn; }
    bool hazard() const { return m_hazard; }

public slots:
    void setSpeed(double v){
        if(m_speed!=v){
            m_speed = v;
            emit speedChanged();
        }
    }
    void setRpm(double v){
        if(m_rpm!=v){
            m_rpm = v;
            emit rpmChanged();
        }
    }
    void setLeftOn(bool v){
        if(m_leftOn!=v){
            m_leftOn=v;
            emit leftOnChanged();
        }
    }

    void setRightOn(bool v){
        if(m_rightOn!=v){
            m_rightOn=v;
            emit rightOnChanged();
        }
    }

    void setHazard(bool v){
        if(m_hazard!=v){
            m_hazard=v;
            emit hazardChanged();
        }
    }

signals:
    void speedChanged();
    void rpmChanged();
    void leftOnChanged();
    void rightOnChanged();
    void hazardChanged();

private:
    double m_speed = 0;
    double m_rpm = 0;
    bool m_leftOn = false;
    bool m_rightOn = false;
    bool m_hazard = false;
};

#endif // VEHICLEDATACONTROLLER_H
