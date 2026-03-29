#pragma once
#include <QObject>

class GpioController : public QObject {
    Q_OBJECT
public:
    explicit GpioController(QObject *parent = nullptr);
    ~GpioController();

    Q_INVOKABLE void ledOn();
    Q_INVOKABLE void ledOff();

private:
    int m_chipFd   = -1;
    int m_lineFd   = -1;
    const int LED_PIN = 17;   // ← GPIO 17 (change if needed)
};