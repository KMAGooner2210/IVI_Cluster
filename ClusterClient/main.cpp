#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "vehicledatacontroller.h"
#include "mockcanreceiver.h"


int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    VehicleDataController controller;
    MockCanReceiver receiver;

    QObject::connect(
        &receiver,
        &MockCanReceiver::speedReceived,
        &controller,
        &VehicleDataController::setSpeed
        );

    QObject::connect(
        &receiver,
        &MockCanReceiver::rpmReceived,
        &controller,
        &VehicleDataController::setRpm
        );


    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("vehicleData", &controller);

    const QUrl url(QStringLiteral("qrc:/qt/qml/ClusterClient/Main.qml"));
    engine.load(url);

    receiver.start();

    return app.exec();
}
