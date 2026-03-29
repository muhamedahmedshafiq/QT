#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "weathermanager.h"

using namespace Qt::StringLiterals;
int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    WeatherManager weather;
    engine.rootContext()->setContextProperty("weather", &weather);

    engine.load(QUrl(u"qrc:/qt/qml/Weather_app/Main.qml"_s));
    return app.exec();
}