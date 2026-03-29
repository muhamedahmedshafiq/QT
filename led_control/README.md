# 💡 Qt LED GPIO Controller

A minimal Qt 6 / QML desktop app that controls a physical **LED via GPIO** on a Linux board (e.g. Raspberry Pi). Press a button on screen → the real LED turns on or off.

---

## ✨ Features

- 💡 **LED ON** button — drives GPIO 17 HIGH
- 🌑 **LED OFF** button — drives GPIO 17 LOW
- 🎨 Smooth color animation on button press
- 🔌 Uses the Linux kernel **GPIO character device** API (`/dev/gpiochip0`) — no WiringPi or third-party libs needed
- 🖥️ Clean dark-panel UI built in QML

---

## 🛠️ Tech Stack

| Layer      | Technology                        |
|------------|-----------------------------------|
| UI         | QML (Qt Quick)                    |
| Backend    | C++ (`GpioController`)            |
| GPIO       | Linux `gpio.h` character device   |
| Build      | CMake + Qt 6.8                    |
| Target     | Linux (Raspberry Pi or any board with `/dev/gpiochip0`) |

---

## 📁 Project Structure

```
led_control/
├── CMakeLists.txt          # Build configuration
├── main.cpp                # App entry point, QML engine setup
├── gpiocontroller.h        # GpioController class declaration
├── gpiocontroller.cpp      # GPIO open/close/on/off logic
└── Main.qml                # UI — two buttons wired to C++ methods
```

---

## 🔌 Hardware Setup

### What you need
- Raspberry Pi (or any Linux SBC with GPIO)
- 1× LED
- 1× 330Ω resistor (protects the LED)
- Jumper wires

### Wiring

```
GPIO 17 (Pin 11) ──── [330Ω resistor] ──── [LED anode +]
                                                 │
GND     (Pin 6)  ──────────────────────── [LED cathode −]
```

> 🔢 Pin 11 on the physical header = **GPIO 17** in software. To use a different pin, change `LED_PIN` in `gpiocontroller.h`:
> ```cpp
> const int LED_PIN = 17;  // ← change this
> ```

---

## 🚀 Getting Started

### Prerequisites

- **Qt 6.8** or later (with the `Quick` component)
- **CMake 3.16** or later
- A C++17-compatible compiler
- A **Linux board** with `/dev/gpiochip0` (Raspberry Pi, BeagleBone, etc.)
- GPIO access permissions (see note below)

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/led_control.git
cd led_control
```

### 2. Build

```bash
mkdir build && cd build
cmake ..
cmake --build .
```

### 3. Run

```bash
./appled_control
```

> ⚠️ **Permission error?** If you get `Failed to open GPIO chip`, your user may not have access to `/dev/gpiochip0`. Fix it with:
> ```bash
> sudo usermod -aG gpio $USER
> # then log out and back in, or run:
> sudo chmod a+rw /dev/gpiochip0
> ```
> Or run the app with `sudo` temporarily to test.

---

## 🏗️ Architecture — How C++ and QML Connect

```
┌──────────────────────────────────────────────┐
│                  main.cpp                    │
│                                              │
│  GpioController gpio;                        │
│  engine.rootContext()                        │
│    .setContextProperty("gpio", &gpio);       │
│                        ↑                     │
│            exposed to QML as "gpio"          │
└───────────────────────┬──────────────────────┘
                        │
        ┌───────────────▼──────────────┐
        │       GpioController         │
        │       (C++ Backend)          │
        │                              │
        │  ledOn()   → GPIO 17 HIGH    │
        │  ledOff()  → GPIO 17 LOW     │
        │                              │
        │  Uses Linux ioctl() calls:   │
        │  - GPIO_GET_LINEHANDLE_IOCTL │
        │  - GPIOHANDLE_SET_LINE_VALUES│
        └──────────────────────────────┘
                        ▲
        ┌───────────────┴──────────────┐
        │           Main.qml           │
        │           (UI Layer)         │
        │                              │
        │  MouseArea {                 │
        │    onClicked: gpio.ledOn()   │  ← calls C++ directly
        │  }                           │
        │  MouseArea {                 │
        │    onClicked: gpio.ledOff()  │  ← calls C++ directly
        │  }                           │
        └──────────────────────────────┘
```

### How it works

**1. C++ object registered in `main.cpp`**

The `GpioController` is created and passed to the QML engine so QML can call its methods by name:

```cpp
GpioController gpio;
engine.rootContext()->setContextProperty("gpio", &gpio);
```

**2. QML buttons call C++ directly**

Both methods are marked `Q_INVOKABLE`, which lets QML call them as if they were JavaScript functions:

```qml
MouseArea {
    onClicked: gpio.ledOn()   // calls C++ ledOn()
}
```

**3. GPIO controlled via Linux kernel API**

No external library is used. The app opens `/dev/gpiochip0` with `ioctl()` calls from `<linux/gpio.h>`:

- On startup → opens the chip and requests GPIO 17 as an **output line**
- `ledOn()` → sends value `1` (HIGH) to the line
- `ledOff()` → sends value `0` (LOW) to the line
- On exit → file descriptors are closed in the destructor

```cpp
void GpioController::ledOn() {
    struct gpiohandle_data data;
    data.values[0] = 1;  // HIGH
    ioctl(m_lineFd, GPIOHANDLE_SET_LINE_VALUES_IOCTL, &data);
}
```

---

## ⚙️ Configuration

| Setting    | Location             | Default | Description                  |
|------------|----------------------|---------|------------------------------|
| GPIO pin   | `gpiocontroller.h`   | `17`    | The GPIO pin number to control |
| GPIO chip  | `gpiocontroller.cpp` | `/dev/gpiochip0` | GPIO chip device path |
| Window size| `Main.qml`           | `640×480` | App window dimensions      |

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).

---

## 🙏 Acknowledgements

- [Qt Framework](https://www.qt.io/) for the QML/C++ bridge
- [Linux GPIO character device API](https://www.kernel.org/doc/html/latest/driver-api/gpio/using-gpio.html) for kernel-level GPIO access
