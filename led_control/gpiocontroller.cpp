#include "gpiocontroller.h"
#include <QDebug>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <linux/gpio.h>

GpioController::GpioController(QObject *parent) : QObject(parent) {
    // Open GPIO chip
    m_chipFd = open("/dev/gpiochip0", O_RDONLY);
    if (m_chipFd < 0) {
        qWarning() << "Failed to open GPIO chip";
        return;
    }

    // Request LED pin as output
    struct gpiohandle_request req;
    memset(&req, 0, sizeof(req));
    req.lineoffsets[0] = LED_PIN;
    req.lines          = 1;
    req.flags          = GPIOHANDLE_REQUEST_OUTPUT;
    req.default_values[0] = 0;   // start LOW (off)
    strcpy(req.consumer_label, "qt-led");

    if (ioctl(m_chipFd, GPIO_GET_LINEHANDLE_IOCTL, &req) < 0) {
        qWarning() << "Failed to get GPIO line";
        return;
    }

    m_lineFd = req.fd;
    qDebug() << "GPIO initialized on pin" << LED_PIN;
}

GpioController::~GpioController() {
    if (m_lineFd >= 0)  close(m_lineFd);
    if (m_chipFd >= 0)  close(m_chipFd);
}

void GpioController::ledOn() {
    if (m_lineFd < 0) return;
    struct gpiohandle_data data;
    data.values[0] = 1;   // HIGH
    ioctl(m_lineFd, GPIOHANDLE_SET_LINE_VALUES_IOCTL, &data);
    qDebug() << "LED ON";
}

void GpioController::ledOff() {
    if (m_lineFd < 0) return;
    struct gpiohandle_data data;
    data.values[0] = 0;   // LOW
    ioctl(m_lineFd, GPIOHANDLE_SET_LINE_VALUES_IOCTL, &data);
    qDebug() << "LED OFF";
}