#pragma once
#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include "config.h"         

class WeatherManager : public QObject {
    Q_OBJECT
public:
    explicit WeatherManager(QObject *parent = nullptr);
    Q_INVOKABLE void fetchWeather(const QString &city);

signals:
        void weatherReady(
        QString temperature,
        QString description,
        QString feelsLike,
        QString humidity,
        QString windSpeed,
        QString city,
        QString icon
    );
    void errorOccurred(QString error);

private:
    QNetworkAccessManager *manager;
    const QString apiKey = WEATHER_API_KEY;   
};
