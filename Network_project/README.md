# 📡 Network Controller — Qt6 QML + C++ on Linux

A modern, beginner-friendly desktop application to **control WiFi and Bluetooth** on Linux,
built with **Qt6 QML (frontend)** and **C++ (backend)**.

![Qt6](https://img.shields.io/badge/Qt-6.8-green?logo=qt)
![C++](https://img.shields.io/badge/C++-17-blue?logo=cplusplus)
![Linux](https://img.shields.io/badge/Linux-Only-orange?logo=linux)
![License](https://img.shields.io/badge/License-MIT-yellow)

---

## 📑 Table of Contents

- [Overview](#-overview)
- [Project Architecture](#️-project-architecture)
- [File Structure](#-file-structure)
- [How It Works — The Big Picture](#-how-it-works--the-big-picture)
- [Linux Network Stack Explained](#-linux-network-stack-explained)
- [C++ Backend Explained](#-c-backend-explained)
- [QML Frontend Explained](#-qml-frontend-explained)
- [CMakeLists.txt Explained](#-cmakeliststxt-explained)
- [main.cpp Explained](#-maincpp-explained)
- [Dependencies](#-dependencies)
- [Build Instructions](#️-build-instructions)
- [Troubleshooting](#-troubleshooting)
- [How to Extend This Project](#-how-to-extend-this-project)
- [Key Concepts Cheat Sheet](#-key-concepts-cheat-sheet)
- [License](#-license)

---

## 🌟 Overview

This application provides a **graphical interface** to manage network connections:

| Feature | Description |
|---|---|
| ✅ Toggle WiFi ON/OFF | Uses `nmcli` to enable/disable the WiFi radio |
| ✅ Scan WiFi Networks | Lists nearby access points with signal strength |
| ✅ Connect to WiFi | Connects to a selected network (with password dialog) |
| ✅ Toggle Bluetooth ON/OFF | Uses `bluetoothctl` to power the Bluetooth adapter |
| ✅ Scan Bluetooth Devices | Discovers nearby Bluetooth devices |
| ✅ Dynamic UI | Hides scan options when WiFi/Bluetooth is OFF |
| ✅ Smooth Animations | All transitions are animated (toggle, fade, slide) |
| ✅ Dark Modern Theme | Professional dark UI with accent colors |

---

## 🏗️ Project Architecture

```
┌─────────────────────────────────────────────────────────┐
│                      YOUR APPLICATION                   │
│                                                         │
│  ┌──────────────┐  context   ┌───────────────────────┐  │
│  │  Main.qml   │◄──────────►│  networkcontroller    │  │
│  │  (Frontend) │  property  │  .h / .cpp (Backend)  │  │
│  │             │            │                       │  │
│  │ - Toggle UI │◄─ signals  │ - toggleWifi()        │  │
│  │ - Show list │  slots ───►│ - scanWifi()          │  │
│  │ - Animations│            │ - toggleBluetooth()   │  │
│  │ - Dialog    │            │ - scanBluetooth()     │  │
│  └──────────────┘            └──────────┬────────────┘  │
│                                         │               │
│                               QProcess (runs            │
│                               terminal commands)        │
└─────────────────────────────────────────┼───────────────┘
                                          │
              ┌───────────────────────────▼──────────────────┐
              │              LINUX SYSTEM                    │
              │                                              │
              │  nmcli ──D-Bus──► NetworkManager ──► wlan0  │
              │                                              │
              │  bluetoothctl ─D-Bus─► BlueZ ──────► hci0   │
              └──────────────────────────────────────────────┘
```

---

## 📁 File Structure

```
Network_project/
│
├── CMakeLists.txt          # Build configuration
├── main.cpp                # Entry point — creates app, engine, controller
├── networkcontroller.h     # Header — declares the C++ class
├── networkcontroller.cpp   # Implementation — WiFi/Bluetooth logic
├── Main.qml                # QML UI — everything the user sees
└── README.md               # This file
```

| File | Role |
|---|---|
| `CMakeLists.txt` | Tells CMake which files to compile and which Qt modules to link |
| `main.cpp` | Starts the app, creates `NetworkController`, exposes it to QML |
| `networkcontroller.h` | Declares the class: properties, signals, slots |
| `networkcontroller.cpp` | Implements all WiFi and Bluetooth logic using `QProcess` |
| `Main.qml` | The UI: toggle switches, network lists, password dialog, animations |

---

## 🔄 How It Works — The Big Picture

Here is the complete flow when a user **toggles WiFi ON**:

```
1. User clicks the WiFi toggle switch in QML
        │
        ▼
2. QML calls → networkCtrl.toggleWifi()
   (possible because "networkCtrl" is set as a context property in main.cpp)
        │
        ▼
3. C++ toggleWifi() runs → QProcess starts "nmcli radio wifi on"
        │
        ▼
4. nmcli sends a D-Bus message → org.freedesktop.NetworkManager
        │
        ▼
5. NetworkManager daemon talks to the WiFi kernel driver
   → Kernel enables the WiFi hardware radio
        │
        ▼
6. C++ flips m_wifiOn = true → emits wifiChanged() signal
        │
        ▼
7. QML receives the signal automatically via Q_PROPERTY binding
   → Toggle slides, color changes, scan button appears with animation
```

---

## 🐧 Linux Network Stack Explained

### 1️⃣ NetworkManager and nmcli (WiFi)

**NetworkManager** is a system daemon that manages all network connections on modern Linux distros.

```
nmcli (CLI tool)               ← We use this
      │  communicates via D-Bus
      ▼
NetworkManager daemon           ← Background service
(org.freedesktop.NetworkManager)
      │  talks to kernel
      ▼
nl80211 / wpa_supplicant        ← WiFi drivers
      │
      ▼
WiFi Hardware (wlan0)           ← Physical radio
```

#### nmcli Commands Used

| Command | Purpose |
|---|---|
| `nmcli radio wifi` | Check if WiFi is enabled |
| `nmcli radio wifi on/off` | Enable or disable WiFi |
| `nmcli device wifi rescan` | Force a fresh scan |
| `nmcli -t -f SSID,SIGNAL,SECURITY device wifi list` | List networks (machine-readable) |
| `nmcli device wifi connect <SSID> password <PASS>` | Connect to a network |

### 2️⃣ BlueZ and bluetoothctl (Bluetooth)

**BlueZ** is the official Linux Bluetooth stack, also a system daemon.

```
bluetoothctl (CLI tool)         ← We use this
      │  communicates via D-Bus
      ▼
BlueZ daemon                    ← Background service
      │
      ▼
Bluetooth Hardware (hci0)       ← Physical adapter
```

#### bluetoothctl Commands Used

| Command | Purpose |
|---|---|
| `bluetoothctl show` | Check if adapter is powered |
| `bluetoothctl power on/off` | Enable or disable Bluetooth |
| `bluetoothctl --timeout 5 scan on` | Scan for devices for 5 seconds |
| `bluetoothctl devices` | List discovered devices |

### 3️⃣ D-Bus — The Hidden Backbone

D-Bus is the inter-process communication (IPC) system on Linux. Both `nmcli` and `bluetoothctl`
are just **thin wrappers** that send D-Bus messages to their respective daemons. Our app never
talks to D-Bus directly — we let the CLI tools handle it.

> **Advanced:** You can skip the CLI tools entirely and use `Qt6::DBus` to speak D-Bus directly.
> See the [How to Extend](#-how-to-extend-this-project) section below.

---

## 🖥️ C++ Backend Explained

### QProcess — Running Terminal Commands

`QProcess` lets you launch any terminal command from C++ and capture its output.

```cpp
// Helper used throughout the backend
QString NetworkController::runCommand(const QString &program, const QStringList &args)
{
    QProcess process;
    process.start(program, args);
    process.waitForFinished(10000);  // Wait up to 10 seconds
    return process.readAllStandardOutput().trimmed();
}
```

Every WiFi/Bluetooth function calls `runCommand()` internally.

### Q_OBJECT Macro

```cpp
class NetworkController : public QObject
{
    Q_OBJECT   // ← Required! Enables signals, slots, and properties
    ...
};
```

Without `Q_OBJECT`, Qt's Meta-Object Compiler (MOC) won't process the class and nothing will work.
`CMAKE_AUTOMOC ON` in `CMakeLists.txt` runs MOC automatically at build time.

### Q_PROPERTY — Exposing Data to QML

```cpp
Q_PROPERTY(bool wifiOn      READ wifiOn      NOTIFY wifiChanged)
Q_PROPERTY(bool bluetoothOn READ bluetoothOn NOTIFY bluetoothChanged)
```

This makes `networkCtrl.wifiOn` readable in QML. When `wifiChanged()` is emitted, QML
automatically re-reads the value and updates any bindings.

### Signals and Slots

| Signal | When It Fires |
|---|---|
| `wifiChanged()` | After `toggleWifi()` flips the state |
| `bluetoothChanged()` | After `toggleBluetooth()` flips the state |
| `wifiListChanged()` | After `scanWifi()` updates the network list |
| `statusMessage(QString)` | Any time a user-visible status update is needed |

### WiFi Functions

| Function | What It Does |
|---|---|
| `checkWifiStatus()` | Runs `nmcli radio wifi`, returns `true` if output contains `"enabled"` |
| `toggleWifi()` | Runs `nmcli radio wifi on/off`, flips `m_wifiOn`, emits `wifiChanged()` |
| `scanWifi()` | Rescans, parses the network list into `QVariantList`, emits `wifiListChanged()` |
| `getWifiList()` | Returns `m_wifiNetworks` to QML |
| `connectWifi(ssid, password)` | Runs `nmcli device wifi connect ...`, emits result via `statusMessage()` |

**Network list parsing detail:** The `-t` flag makes `nmcli` output colon-separated values
(`SSID:SIGNAL:SECURITY`). Each line is split on `":"` and stored as a `QVariantMap` with keys
`"name"`, `"signal"`, and `"security"`.

> ⚠️ **Known Limitation:** SSIDs or security strings that contain a literal `":"` character
> will be parsed incorrectly. For production use, consider switching to a D-Bus or JSON-based approach.

### Bluetooth Functions

| Function | What It Does |
|---|---|
| `checkBluetoothStatus()` | Runs `bluetoothctl show`, checks for `"Powered: yes"` |
| `toggleBluetooth()` | Runs `bluetoothctl power on/off`, flips `m_bluetoothOn` |
| `scanBluetooth()` | Scans for 5 seconds, parses `bluetoothctl devices` output, returns `QVariantList` |

---

## 🎨 QML Frontend Explained

### What is QML?

QML (Qt Modeling Language) is a declarative language for building UIs. Instead of writing
imperative code like "create a button, set its color to blue, add a click handler", you
**describe** what the UI looks like and Qt handles the rest.

### ApplicationWindow

The root element. Sets the window title, size, and background color.

```qml
ApplicationWindow {
    width: 480; height: 750
    visible: true
    title: "Network Controller"
    color: "#1a1a2e"   // Dark navy background
}
```

### Flickable — Scrolling

Wraps the entire content so it scrolls if it grows taller than the window.

```qml
Flickable {
    anchors.fill: parent
    contentHeight: mainColumn.height + 40
    clip: true
    boundsBehavior: Flickable.StopAtBounds
}
```

### Custom Toggle Switch

The WiFi and Bluetooth toggles are built from two `Rectangle` elements:

```qml
// Outer track
Rectangle {
    width: 60; height: 30; radius: 15
    color: networkCtrl.wifiOn ? "#4dc9f6" : "#333355"
    Behavior on color { ColorAnimation { duration: 300 } }

    // Inner thumb — slides left/right
    Rectangle {
        width: 24; height: 24; radius: 12
        color: "white"; y: 3
        x: networkCtrl.wifiOn ? parent.width - width - 3 : 3
        Behavior on x {
            NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: networkCtrl.toggleWifi()
    }
}
```

### Repeater — Dynamic Lists

Used to render the WiFi network list and Bluetooth device list from C++ data.

```qml
Repeater {
    id: wifiRepeater
    // model is set from C++ via: wifiRepeater.model = networkCtrl.getWifiList()
    delegate: Rectangle {
        // modelData.name, modelData.signal, modelData.security
    }
}
```

### Connections — Listening to C++

```qml
Connections {
    target: networkCtrl

    function onStatusMessage(message) {
        statusText.text = message
        statusAnim.restart()
    }

    function onWifiChanged() {
        if (!networkCtrl.wifiOn) wifiRepeater.model = []
    }

    function onBluetoothChanged() {
        if (!networkCtrl.bluetoothOn) btRepeater.model = []
    }
}
```

### Behavior Animations

`Behavior` blocks auto-animate any property change:

```qml
Behavior on color  { ColorAnimation  { duration: 300 } }
Behavior on x      { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
Behavior on opacity{ NumberAnimation { duration: 300 } }
```

### Dialog — Password Popup

A modal dialog that appears when the user taps a secured WiFi network:

```qml
Dialog {
    id: passwordDialog
    anchors.centerIn: parent
    width: 380; modal: true; dim: true
    property string ssid: ""
    // Contains: TextInput (password field), show/hide checkbox, Cancel + Connect buttons
}
```

The "Show password" toggle works by switching `echoMode` between
`TextInput.Password` and `TextInput.Normal`.

### Visibility Toggle (Show/Hide)

When WiFi or Bluetooth is OFF, scan controls are hidden:

```qml
visible: networkCtrl.wifiOn
opacity: networkCtrl.wifiOn ? 1.0 : 0.0
Behavior on opacity { NumberAnimation { duration: 300 } }
```

Using both `visible` and `opacity` ensures the element is removed from layout **and** fades smoothly.

---

## 🔧 CMakeLists.txt Explained

```cmake
cmake_minimum_required(VERSION 3.16)
project(Network_project VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)               # Runs MOC automatically — required for Q_OBJECT

find_package(Qt6 REQUIRED COMPONENTS Quick)
qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appNetwork_project
    main.cpp
    networkcontroller.h             # .h must be listed so AUTOMOC processes it
    networkcontroller.cpp
)

qt_add_qml_module(appNetwork_project
    URI Network_project             # Must match engine.loadFromModule() in main.cpp
    VERSION 1.0
    QML_FILES Main.qml
)

target_link_libraries(appNetwork_project PRIVATE Qt6::Quick)
```

**Why list the `.h` file?**  
`AUTOMOC` needs to see the header to find `Q_OBJECT` and generate the MOC file.
Without it you get `undefined reference to vtable` linker errors.

---

## 🚀 main.cpp Explained

```
main() starts
    │
    ├── QGuiApplication created      (event loop ready)
    │
    ├── NetworkController created
    │       ├── checkWifiStatus()      → runs nmcli
    │       └── checkBluetoothStatus() → runs bluetoothctl
    │
    ├── QQmlApplicationEngine created
    │
    ├── setContextProperty("networkCtrl", &controller)
    │       └── QML can now access the C++ object as "networkCtrl"
    │
    ├── engine.loadFromModule("Network_project", "Main")
    │       ├── Parses Main.qml
    │       ├── Creates all QML objects
    │       ├── Binds properties to C++ values
    │       └── Window appears on screen
    │
    └── app.exec()  → Event loop starts
            ├── Processes mouse clicks
            ├── Delivers signals/slots
            ├── Runs animations
            └── Blocks until the window is closed
```

---

## 📦 Dependencies

| Package | What It Provides |
|---|---|
| `qt6-base-dev` | `QObject`, `QProcess`, `QGuiApplication` |
| `qt6-declarative-dev` | `QQmlApplicationEngine`, QML parsing |
| `cmake` | Build system |
| `g++` | C++ compiler |
| `network-manager` | NetworkManager daemon + `nmcli` |
| `bluez` | BlueZ daemon + `bluetoothctl` |

### Install Dependencies

**Debian / Ubuntu:**
```bash
sudo apt update
sudo apt install -y \
    qt6-base-dev \
    qt6-declarative-dev \
    cmake \
    g++ \
    network-manager \
    bluez
```

**Fedora:**
```bash
sudo dnf install -y \
    qt6-qtbase-devel \
    qt6-qtdeclarative-devel \
    cmake \
    gcc-c++ \
    NetworkManager \
    bluez
```

**Arch Linux:**
```bash
sudo pacman -S \
    qt6-base \
    qt6-declarative \
    cmake \
    gcc \
    networkmanager \
    bluez bluez-utils
```

---

## 🛠️ Build Instructions

```bash
# 1. Navigate to the project directory
cd /path/to/Network_project

# 2. Create a build directory (keeps the source tree clean)
mkdir -p build && cd build

# 3. Generate build files
cmake ..

# 4. Compile (uses all CPU cores)
make -j$(nproc)

# 5. Run
./appNetwork_project
```

**One-liner:**
```bash
cd Network_project && mkdir -p build && cd build && cmake .. && make -j$(nproc) && ./appNetwork_project
```

---

## 🔧 Troubleshooting

### Build Errors

| Error | Solution |
|---|---|
| `Q_OBJECT not found` | Ensure `set(CMAKE_AUTOMOC ON)` is in `CMakeLists.txt` |
| `QProcess` not found | Install `qt6-base-dev` |
| `QQmlApplicationEngine` not found | Install `qt6-declarative-dev` |
| `undefined reference to vtable` | Clean rebuild: `rm -rf build && mkdir build && cd build && cmake .. && make` |
| MOC file not generated | Confirm `networkcontroller.h` is listed in `qt_add_executable()` |

### Runtime Errors

| Error | Solution |
|---|---|
| WiFi toggle does nothing | Check `which nmcli` — install `network-manager` if missing |
| Bluetooth toggle does nothing | Check `which bluetoothctl` — install `bluez` if missing |
| Permission denied | Run `sudo ./appNetwork_project` or add your user to the `netdev` group |
| No WiFi networks found | Verify the adapter exists: `nmcli device status` |
| No Bluetooth devices found | Check the adapter: `bluetoothctl list` |
| QML file not loading | Ensure the file is named `Main.qml` (capital M) and listed in `CMakeLists.txt` |

### Verify Linux Tools Work

```bash
# WiFi
nmcli radio wifi                    # "enabled" or "disabled"
nmcli device wifi list              # lists nearby networks

# Bluetooth
bluetoothctl show                   # adapter info
bluetoothctl list                   # list adapters

# Services
systemctl status dbus               # must be active
systemctl status NetworkManager     # must be active
systemctl status bluetooth          # must be active
```

---

## 🚀 How to Extend This Project

### Add "Forget Network" Feature

```cpp
// networkcontroller.h
Q_SLOT void forgetNetwork(const QString &ssid);

// networkcontroller.cpp
void NetworkController::forgetNetwork(const QString &ssid)
{
    runCommand("nmcli", {"connection", "delete", ssid});
    emit statusMessage(QString("Forgot network: %1").arg(ssid));
}
```

### Add "Bluetooth Pair" Feature

```cpp
// networkcontroller.h
Q_SLOT void pairBluetooth(const QString &address);

// networkcontroller.cpp
void NetworkController::pairBluetooth(const QString &address)
{
    runCommand("bluetoothctl", {"pair", address});
    runCommand("bluetoothctl", {"connect", address});
    emit statusMessage(QString("Paired with %1").arg(address));
}
```

> The Bluetooth "Pair" button already exists in the QML UI (`btPairMouse`). You just need to
> wire its `onClicked` handler to `networkCtrl.pairBluetooth(modelData.address)`.

### Switch to D-Bus (Advanced — No QProcess)

```cmake
# CMakeLists.txt
find_package(Qt6 REQUIRED COMPONENTS Quick DBus)
target_link_libraries(appNetwork_project PRIVATE Qt6::Quick Qt6::DBus)
```

```cpp
#include <QDBusInterface>
#include <QDBusConnection>

void NetworkController::toggleWifiDBus()
{
    QDBusInterface nm(
        "org.freedesktop.NetworkManager",
        "/org/freedesktop/NetworkManager",
        "org.freedesktop.DBus.Properties",
        QDBusConnection::systemBus()
    );

    bool current = nm.call("Get",
        "org.freedesktop.NetworkManager", "WirelessEnabled"
    ).arguments().at(0).value<QDBusVariant>().variant().toBool();

    nm.call("Set",
        "org.freedesktop.NetworkManager", "WirelessEnabled",
        QVariant::fromValue(QDBusVariant(!current))
    );
}
```

### Add a System Tray Icon

```cpp
#include <QSystemTrayIcon>
#include <QMenu>

// In main.cpp:
QSystemTrayIcon tray;
tray.setIcon(QIcon(":/icons/network.png"));
tray.setToolTip("Network Controller");
tray.show();
```

---

## 📚 Key Concepts Cheat Sheet

### C++ / Qt Concepts

| Concept | Purpose | Example |
|---|---|---|
| `Q_OBJECT` | Enable Qt meta-object features | `class MyClass : public QObject { Q_OBJECT` |
| `Q_PROPERTY` | Expose a variable to QML | `Q_PROPERTY(bool wifiOn READ wifiOn NOTIFY wifiChanged)` |
| `signals:` | Declare outgoing notifications | `void statusMessage(const QString &msg);` |
| `public slots:` | Declare QML-callable functions | `void toggleWifi();` |
| `emit` | Fire a signal | `emit wifiChanged();` |
| `QProcess` | Run terminal commands | `process.start("nmcli", {"radio", "wifi"});` |
| `QVariantMap` | Key-value data for QML | `map["name"] = "HomeWiFi";` |
| `QVariantList` | Array of data for QML | `list.append(map);` |

### QML Concepts

| Concept | Purpose | Example |
|---|---|---|
| `Rectangle` | A colored box/shape | `Rectangle { color: "blue"; radius: 10 }` |
| `Text` | Display text | `Text { text: "Hello"; color: "white" }` |
| `MouseArea` | Make things clickable | `MouseArea { onClicked: doSomething() }` |
| `ColumnLayout` | Stack items vertically | `ColumnLayout { spacing: 10 }` |
| `RowLayout` | Stack items horizontally | `RowLayout { spacing: 10 }` |
| `Repeater` | Create list from data | `Repeater { model: myList; delegate: ... }` |
| `Behavior` | Auto-animate property changes | `Behavior on x { NumberAnimation {} }` |
| `Connections` | Listen for C++ signals | `Connections { target: obj }` |
| `visible` | Show/hide an element | `visible: networkCtrl.wifiOn` |
| `opacity` | Transparency (0 = invisible) | `opacity: 0.5` |
| `Flickable` | Scrollable container | `Flickable { contentHeight: ... }` |
| `Dialog` | Modal popup window | `Dialog { modal: true }` |
| `TextInput` | Text entry field | `TextInput { echoMode: TextInput.Password }` |

### Linux Commands Reference

| Command | Purpose |
|---|---|
| `nmcli radio wifi` | Check WiFi status |
| `nmcli radio wifi on/off` | Toggle WiFi |
| `nmcli device wifi list` | List WiFi networks |
| `nmcli device wifi rescan` | Force rescan |
| `nmcli device wifi connect SSID password PASS` | Connect to WiFi |
| `bluetoothctl show` | Check BT adapter info |
| `bluetoothctl power on/off` | Toggle Bluetooth |
| `bluetoothctl scan on` | Scan for devices |
| `bluetoothctl devices` | List found devices |
| `bluetoothctl pair MAC` | Pair with a device |
| `bluetoothctl connect MAC` | Connect to a device |
| `busctl list` | List D-Bus services |
| `systemctl status NetworkManager` | Check NM service |
| `systemctl status bluetooth` | Check BlueZ service |

---

## 📄 License

MIT License — Feel free to use, modify, and share!

---

## 🙏 Credits

- [Qt6](https://www.qt.io) — The Qt Company
- [NetworkManager](https://networkmanager.dev) — GNOME Project
- [BlueZ](http://www.bluez.org) — The BlueZ Project
- [D-Bus](https://www.freedesktop.org/wiki/Software/dbus/) — freedesktop.org

> Built for learners — every file is commented and explained.
> If you are studying Qt, C++, or QML, this project is a solid starting point!
