#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "networkcontroller.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Create the C++ backend
    NetworkController controller;

    QQmlApplicationEngine engine;

    // ✅ Expose C++ object to QML as "networkCtrl"
    engine.rootContext()->setContextProperty("networkCtrl", &controller);

    // ✅ Load QML from your module (matches URI "Network_project")
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection
    );

    engine.loadFromModule("Network_project", "Main");

    return app.exec();
}