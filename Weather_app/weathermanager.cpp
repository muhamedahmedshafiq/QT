#include "weathermanager.h"
#include <QNetworkRequest>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QUrl>

WeatherManager::WeatherManager(QObject *parent) : QObject(parent) {
    manager = new QNetworkAccessManager(this);
}

void WeatherManager::fetchWeather(const QString &city) {
    QString url = QString(
        "https://api.openweathermap.org/data/2.5/weather?q=%1&appid=%2&units=metric"
    ).arg(city, apiKey);

    QNetworkRequest request(url);
    QNetworkReply *reply = manager->get(request);

    connect(reply, &QNetworkReply::finished, this, [reply, this]() {
        if (reply->error() != QNetworkReply::NoError) {
            emit errorOccurred(reply->errorString());
            reply->deleteLater();
            return;
        }

        QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
        QJsonObject root  = doc.object();
        QJsonObject main  = root["main"].toObject();
        QJsonObject wind  = root["wind"].toObject();

        QString temp        = QString::number(main["temp"].toDouble())       + " °C";
        QString feelsLike   = QString::number(main["feels_like"].toDouble()) + " °C";
        QString humidity    = QString::number(main["humidity"].toInt())      + " %";
        QString windSpeed   = QString::number(wind["speed"].toDouble())      + " m/s";
        QString description = root["weather"].toArray()[0]
                                  .toObject()["description"].toString();
        QString cityName    = root["name"].toString();
        QString icon        = root["weather"].toArray()[0]       
                                  .toObject()["icon"].toString();

        // ✅ all 7 parameters match the signal
        emit weatherReady(temp, feelsLike, humidity, windSpeed, description, cityName, icon);

        reply->deleteLater();
    });
}