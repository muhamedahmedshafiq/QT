#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "gpiocontroller.h"

using namespace Qt::StringLiterals;

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    GpioController gpio;
    engine.rootContext()->setContextProperty("gpio", &gpio);

    engine.load(QUrl(u"qrc:/qt/qml/led_control/Main.qml"_s));
    return app.exec();
}