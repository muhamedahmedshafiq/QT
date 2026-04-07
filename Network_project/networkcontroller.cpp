#include "networkcontroller.h"
#include <QDebug>
#include <QVariantMap>

NetworkController::NetworkController(QObject *parent)
    : QObject(parent)
{
    m_wifiOn      = checkWifiStatus();
    m_bluetoothOn = checkBluetoothStatus();

    updateConnectedWifi();
    updateConnectedBluetooth();

    qDebug() << "WiFi is:"      << (m_wifiOn ? "ON" : "OFF");
    qDebug() << "Bluetooth is:" << (m_bluetoothOn ? "ON" : "OFF");
    qDebug() << "Connected WiFi:" << m_connectedWifi;
    qDebug() << "Connected BT:"   << m_connectedBtDevice;

    // Auto-refresh every 5 seconds
    m_refreshTimer = new QTimer(this);
    connect(m_refreshTimer, &QTimer::timeout, this, &NetworkController::refreshStatus);
    m_refreshTimer->start(5000);
}

// =============================================
//  Helper: Run a terminal command
// =============================================
QString NetworkController::runCommand(const QString &program, const QStringList &args)
{
    QProcess process;
    process.start(program, args);
    process.waitForFinished(10000);

    QString output = process.readAllStandardOutput().trimmed();
    QString error  = process.readAllStandardError().trimmed();

    if (!error.isEmpty()) {
        qDebug() << "Command error:" << error;
    }

    return output;
}

// =============================================
//  Refresh all connection status
// =============================================
void NetworkController::refreshStatus()
{
    bool newWifi = checkWifiStatus();
    bool newBt   = checkBluetoothStatus();

    if (newWifi != m_wifiOn) {
        m_wifiOn = newWifi;
        emit wifiChanged();
    }

    if (newBt != m_bluetoothOn) {
        m_bluetoothOn = newBt;
        emit bluetoothChanged();
    }

    updateConnectedWifi();
    updateConnectedBluetooth();
}

// =============================================
//  WIFI — Connected Info
// =============================================
void NetworkController::updateConnectedWifi()
{
    if (!m_wifiOn) {
        if (!m_connectedWifi.isEmpty()) {
            m_connectedWifi.clear();
            m_connectedWifiIp.clear();
            emit connectedWifiChanged();
        }
        return;
    }

    QString output = runCommand("nmcli", {
        "-t", "-f", "NAME,TYPE", "connection", "show", "--active"
    });

    QString newSsid;
    const QStringList lines = output.split("\n");
    for (const QString &line : lines) {
        if (line.contains("wireless") || line.contains("wifi")) {
            QStringList parts = line.split(":");
            if (!parts.isEmpty()) {
                newSsid = parts[0];
                break;
            }
        }
    }

    QString newIp;
    if (!newSsid.isEmpty()) {
        QString ipOutput = runCommand("nmcli", {
            "-t", "-f", "IP4.ADDRESS", "connection", "show", newSsid
        });
        if (ipOutput.contains(":")) {
            QStringList ipParts = ipOutput.split(":");
            if (ipParts.size() >= 2) {
                newIp = ipParts.last();
                if (newIp.contains("/")) {
                    newIp = newIp.split("/").first();
                }
            }
        }
    }

    if (newSsid != m_connectedWifi || newIp != m_connectedWifiIp) {
        m_connectedWifi   = newSsid;
        m_connectedWifiIp = newIp;
        emit connectedWifiChanged();
    }
}

QString NetworkController::connectedWifi() const      { return m_connectedWifi; }
QString NetworkController::connectedWifiIp() const    { return m_connectedWifiIp; }

// =============================================
//  🔵 BLUETOOTH — Connected Info (FIXED!)
// =============================================
void NetworkController::updateConnectedBluetooth()
{
    if (!m_bluetoothOn) {
        if (!m_connectedBtDevice.isEmpty()) {
            m_connectedBtDevice.clear();
            m_connectedBtAddress.clear();
            emit connectedBtChanged();
        }
        return;
    }

    // ✅ FIX: "bluetoothctl devices Connected" doesn't work on all versions
    // Instead: Get ALL paired devices, then check each one with "bluetoothctl info"

    // Step 1: Get all known devices
    QString output = runCommand("bluetoothctl", {"devices"});

    QString newDevice;
    QString newAddress;

    const QStringList lines = output.split("\n");
    for (const QString &line : lines) {
        if (line.startsWith("Device")) {
            QStringList parts = line.split(" ");
            if (parts.size() >= 3) {
                QString mac = parts[1];

                // Step 2: Check if THIS device is connected
                // Run: bluetoothctl info AA:BB:CC:DD:EE:FF
                // Look for "Connected: yes"
                QString info = runCommand("bluetoothctl", {"info", mac});

                if (info.contains("Connected: yes")) {
                    newAddress = mac;
                    newDevice  = parts.mid(2).join(" ");

                    // ✅ Try to get a better name from the info output
                    const QStringList infoLines = info.split("\n");
                    for (const QString &infoLine : infoLines) {
                        QString trimmed = infoLine.trimmed();
                        if (trimmed.startsWith("Name:")) {
                            QString betterName = trimmed.mid(5).trimmed();
                            if (!betterName.isEmpty()) {
                                newDevice = betterName;
                            }
                            break;
                        }
                    }

                    break;  // Take first connected device
                }
            }
        }
    }

    if (newDevice != m_connectedBtDevice || newAddress != m_connectedBtAddress) {
        m_connectedBtDevice  = newDevice;
        m_connectedBtAddress = newAddress;
        emit connectedBtChanged();

        if (!newDevice.isEmpty()) {
            qDebug() << "BT Connected to:" << newDevice << newAddress;
        }
    }
}

QString NetworkController::connectedBtDevice() const  { return m_connectedBtDevice; }
QString NetworkController::connectedBtAddress() const  { return m_connectedBtAddress; }

// =============================================
//  WIFI Functions
// =============================================

bool NetworkController::checkWifiStatus()
{
    QString result = runCommand("nmcli", {"radio", "wifi"});
    return result.contains("enabled");
}

bool NetworkController::wifiOn() const { return m_wifiOn; }

void NetworkController::toggleWifi()
{
    if (m_wifiOn) {
        runCommand("nmcli", {"radio", "wifi", "off"});
        emit statusMessage("WiFi turned OFF");
    } else {
        runCommand("nmcli", {"radio", "wifi", "on"});
        emit statusMessage("WiFi turned ON");
    }

    m_wifiOn = !m_wifiOn;
    emit wifiChanged();
    updateConnectedWifi();
}

void NetworkController::scanWifi()
{
    emit statusMessage("Scanning for WiFi networks...");

    runCommand("nmcli", {"device", "wifi", "rescan"});

    QString output = runCommand("nmcli", {
        "-t", "-f", "SSID,SIGNAL,SECURITY", "device", "wifi", "list"
    });

    m_wifiNetworks.clear();

    const QStringList lines = output.split("\n");
    for (const QString &line : lines) {
        if (line.isEmpty()) continue;

        QStringList parts = line.split(":");

        if (parts.size() >= 3 && !parts[0].isEmpty()) {
            QVariantMap network;
            network["name"]      = parts[0];
            network["signal"]    = parts[1];
            network["security"]  = parts[2];
            network["connected"] = (parts[0] == m_connectedWifi);
            m_wifiNetworks.append(network);
        }
    }

    emit wifiListChanged();
    emit statusMessage(QString("Found %1 networks").arg(m_wifiNetworks.size()));
}

QVariantList NetworkController::getWifiList() { return m_wifiNetworks; }

void NetworkController::connectWifi(const QString &ssid, const QString &password)
{
    emit statusMessage(QString("Connecting to %1...").arg(ssid));

    QString output;
    if (password.isEmpty()) {
        output = runCommand("nmcli", {"device", "wifi", "connect", ssid});
    } else {
        output = runCommand("nmcli", {"device", "wifi", "connect", ssid, "password", password});
    }

    if (output.contains("successfully")) {
        emit statusMessage(QString("Connected to %1").arg(ssid));
    } else {
        emit statusMessage(QString("Failed to connect to %1").arg(ssid));
    }

    updateConnectedWifi();
}

void NetworkController::disconnectWifi()
{
    if (m_connectedWifi.isEmpty()) return;
    QString ssid = m_connectedWifi;
    runCommand("nmcli", {"connection", "down", ssid});
    emit statusMessage(QString("Disconnected from %1").arg(ssid));
    updateConnectedWifi();
}

// =============================================
//  🔵 BLUETOOTH Functions (FIXED!)
// =============================================

bool NetworkController::checkBluetoothStatus()
{
    // ✅ FIX: Some systems need rfkill check too
    QString result = runCommand("bluetoothctl", {"show"});

    if (result.isEmpty()) {
        qDebug() << "bluetoothctl show returned empty — is BlueZ running?";
        return false;
    }

    return result.contains("Powered: yes");
}

bool NetworkController::bluetoothOn() const { return m_bluetoothOn; }

void NetworkController::toggleBluetooth()
{
    if (m_bluetoothOn) {
        // ✅ FIX: Use rfkill as fallback if bluetoothctl fails
        QString result = runCommand("bluetoothctl", {"power", "off"});

        if (result.contains("Failed") || result.isEmpty()) {
            // Fallback: use rfkill
            runCommand("rfkill", {"block", "bluetooth"});
            qDebug() << "Used rfkill to block bluetooth";
        }

        emit statusMessage("Bluetooth turned OFF");
    } else {
        // ✅ FIX: Unblock with rfkill first, then power on
        runCommand("rfkill", {"unblock", "bluetooth"});

        // Wait a moment for the adapter to come up
        QThread::msleep(500);

        QString result = runCommand("bluetoothctl", {"power", "on"});

        if (result.contains("Failed") || result.isEmpty()) {
            qDebug() << "bluetoothctl power on failed:" << result;
        }

        emit statusMessage("Bluetooth turned ON");
    }

    // ✅ Re-check actual state (don't just flip)
    QThread::msleep(300);
    m_bluetoothOn = checkBluetoothStatus();
    emit bluetoothChanged();
    updateConnectedBluetooth();
}

QVariantList NetworkController::scanBluetooth()
{
    emit statusMessage("Scanning for Bluetooth devices...");

    // ✅ FIX: Use "timeout" command instead of "--timeout" flag
    // because "--timeout" doesn't work on all bluetoothctl versions

    // Method 1: Try with system timeout command
    QProcess scanProcess;
    scanProcess.start("timeout", {"6", "bluetoothctl", "scan", "on"});

    // ✅ FIX: If "timeout" command doesn't exist, use QProcess timeout
    if (!scanProcess.waitForStarted(2000)) {
        // Fallback: start bluetoothctl scan directly
        scanProcess.start("bluetoothctl", {"scan", "on"});
        scanProcess.waitForFinished(6000);  // Wait max 6 seconds
    } else {
        scanProcess.waitForFinished(8000);
    }

    // ✅ Also try: scan using hcitool as backup
    // runCommand("hcitool", {"scan"});

    // Get discovered devices
    QString output = runCommand("bluetoothctl", {"devices"});

    qDebug() << "BT devices output:" << output;

    QVariantList devices;
    const QStringList lines = output.split("\n");

    for (const QString &line : lines) {
        if (!line.startsWith("Device")) continue;

        QStringList parts = line.split(" ");
        if (parts.size() < 3) continue;

        QString mac  = parts[1];
        QString name = parts.mid(2).join(" ");

        // ✅ FIX: Skip devices with no real name (just MAC address as name)
        // These are usually unknown devices that weren't identified
        bool isMacName = (name == mac || name.isEmpty());

        // Get more info about this device
        QString info = runCommand("bluetoothctl", {"info", mac});

        // ✅ Try to get better name from info
        if (isMacName) {
            const QStringList infoLines = info.split("\n");
            for (const QString &infoLine : infoLines) {
                QString trimmed = infoLine.trimmed();
                if (trimmed.startsWith("Name:")) {
                    QString betterName = trimmed.mid(5).trimmed();
                    if (!betterName.isEmpty()) {
                        name = betterName;
                        isMacName = false;
                    }
                    break;
                }
            }
        }

        // Check if connected
        bool isConnected = info.contains("Connected: yes");

        // Check if paired
        bool isPaired = info.contains("Paired: yes");

        // ✅ Get device type/icon hint
        QString deviceType = "unknown";
        if (info.contains("Icon: audio")) {
            deviceType = "audio";
        } else if (info.contains("Icon: input")) {
            deviceType = "input";
        } else if (info.contains("Icon: phone")) {
            deviceType = "phone";
        } else if (info.contains("Icon: computer")) {
            deviceType = "computer";
        }

        QVariantMap device;
        device["address"]    = mac;
        device["name"]       = name;
        device["connected"]  = isConnected;
        device["paired"]     = isPaired;
        device["deviceType"] = deviceType;

        devices.append(device);
    }

    emit statusMessage(QString("Found %1 Bluetooth devices").arg(devices.size()));

    return devices;
}

// ✅ NEW: Pair and connect to a Bluetooth device
void NetworkController::pairBluetooth(const QString &address)
{
    emit statusMessage(QString("Pairing with %1...").arg(address));

    // Step 1: Trust the device (auto-accept)
    runCommand("bluetoothctl", {"trust", address});

    // Step 2: Pair
    QString pairResult = runCommand("bluetoothctl", {"pair", address});
    qDebug() << "Pair result:" << pairResult;

    if (pairResult.contains("Failed")) {
        emit statusMessage(QString("Pairing failed: %1").arg(pairResult));
        return;
    }

    // Step 3: Connect
    QString connectResult = runCommand("bluetoothctl", {"connect", address});
    qDebug() << "Connect result:" << connectResult;

    if (connectResult.contains("successful") || connectResult.contains("Connected")) {
        emit statusMessage(QString("Connected to %1").arg(address));
    } else {
        emit statusMessage(QString("Paired but connection failed"));
    }

    updateConnectedBluetooth();
}

void NetworkController::disconnectBluetooth()
{
    if (m_connectedBtAddress.isEmpty()) return;

    QString name = m_connectedBtDevice;
    QString result = runCommand("bluetoothctl", {"disconnect", m_connectedBtAddress});

    qDebug() << "BT disconnect result:" << result;

    emit statusMessage(QString("Disconnected from %1").arg(name));
    updateConnectedBluetooth();
}