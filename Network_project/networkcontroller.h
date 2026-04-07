#ifndef NETWORKCONTROLLER_H
#define NETWORKCONTROLLER_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QProcess>
#include <QTimer>
#include <QThread>

class NetworkController : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool wifiOn      READ wifiOn      NOTIFY wifiChanged)
    Q_PROPERTY(bool bluetoothOn READ bluetoothOn NOTIFY bluetoothChanged)

    Q_PROPERTY(QString connectedWifi      READ connectedWifi      NOTIFY connectedWifiChanged)
    Q_PROPERTY(QString connectedWifiIp    READ connectedWifiIp    NOTIFY connectedWifiChanged)
    Q_PROPERTY(QString connectedBtDevice  READ connectedBtDevice  NOTIFY connectedBtChanged)
    Q_PROPERTY(QString connectedBtAddress READ connectedBtAddress NOTIFY connectedBtChanged)

public:
    explicit NetworkController(QObject *parent = nullptr);

    bool wifiOn() const;
    bool bluetoothOn() const;

    QString connectedWifi() const;
    QString connectedWifiIp() const;
    QString connectedBtDevice() const;
    QString connectedBtAddress() const;

public slots:
    // WiFi
    void toggleWifi();
    void scanWifi();
    QVariantList getWifiList();
    void connectWifi(const QString &ssid, const QString &password);
    void disconnectWifi();

    // Bluetooth
    void toggleBluetooth();
    QVariantList scanBluetooth();
    void pairBluetooth(const QString &address);   // ✅ NEW
    void disconnectBluetooth();

    void refreshStatus();

signals:
    void wifiChanged();
    void bluetoothChanged();
    void wifiListChanged();
    void statusMessage(const QString &message);
    void connectedWifiChanged();
    void connectedBtChanged();

private:
    bool checkWifiStatus();
    bool checkBluetoothStatus();
    QString runCommand(const QString &program, const QStringList &args);
    void updateConnectedWifi();
    void updateConnectedBluetooth();

    bool m_wifiOn;
    bool m_bluetoothOn;
    QVariantList m_wifiNetworks;

    QString m_connectedWifi;
    QString m_connectedWifiIp;
    QString m_connectedBtDevice;
    QString m_connectedBtAddress;

    QTimer *m_refreshTimer;
};

#endif // NETWORKCONTROLLER_H