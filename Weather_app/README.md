# 🌤️ Qt Weather App

A sleek, real-time desktop weather application built with **Qt 6 / QML** and **C++**, powered by the [OpenWeatherMap API](https://openweathermap.org/api).

---

## 📸 Preview

The app displays live weather data on a full-screen background image with a dark overlay for readability. Weather conditions are represented by emoji icons that update automatically every 10 seconds.

---

## ✨ Features

- 🌡️ **Real-time temperature** displayed in °C with a smooth scale animation on update
- 🤔 **Feels like** temperature
- 💧 **Humidity** percentage
- 💨 **Wind speed** in m/s
- 🌦️ **Weather description** with dynamic emoji icons (day & night variants)
- 🏙️ **City name** resolved from the API response
- 🔄 **Auto-refresh** every 10 seconds via a built-in QML `Timer`
- 🖼️ Beautiful background image with frosted-glass stat cards

---

## 🛠️ Tech Stack

| Layer      | Technology                          |
|------------|-------------------------------------|
| UI         | QML (Qt Quick)                      |
| Backend    | C++ (`WeatherManager`)              |
| Networking | Qt Network (`QNetworkAccessManager`)|
| Data       | OpenWeatherMap REST API             |
| Build      | CMake + Qt 6.8                      |

---

## 📁 Project Structure

```
Weather_app/
├── CMakeLists.txt          # Build configuration
├── config.h                # API key definition
├── main.cpp                # App entry point, QML engine setup
├── weathermanager.h        # WeatherManager class declaration
├── weathermanager.cpp      # HTTP fetch logic & JSON parsing
├── Main.qml                # UI layout, animations, and data bindings
└── weather.jpeg            # Background image resource
```

---

## 🚀 Getting Started

### Prerequisites

- **Qt 6.8** or later (with `Quick` and `Network` components)
- **CMake 3.16** or later
- A C++17-compatible compiler
- An [OpenWeatherMap API key](https://home.openweathermap.org/api_keys) (free tier works)

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/Weather_app.git
cd Weather_app
```

### 2. Get an OpenWeatherMap API Key

The app fetches live weather data from [OpenWeatherMap](https://openweathermap.org/), which requires a free API key. Here's how to get one:

1. Go to [https://home.openweathermap.org/users/sign_up](https://home.openweathermap.org/users/sign_up) and create a free account.
2. After signing in, navigate to **API Keys** from the top menu (or go directly to [https://home.openweathermap.org/api_keys](https://home.openweathermap.org/api_keys)).
3. A default key is generated automatically. You can also click **"Generate"** to create a named key (e.g., `weather_app_key`).
4. Copy the key — it looks like this: `a742fb411d9ba0246bc8ae2d5cc9b099`

> ⏳ **Note:** Newly created API keys can take **10–120 minutes** to activate. If you get a `401 Unauthorized` error right away, wait a bit and try again.

> 🆓 The **free tier** (called "One Call API 3.0" or the basic `Current Weather` plan) is sufficient for this app — no credit card needed for the endpoint used here (`/data/2.5/weather`).

### 3. Set Your API Key in the Project

Open `config.h` and replace the placeholder with your copied key:

```cpp
#pragma once
#define WEATHER_API_KEY "your_api_key_here"  // ← paste your key here
```

**Example:**
```cpp
#pragma once
#define WEATHER_API_KEY "a742fb411d9ba0246bc8ae2d5cc9b099"
```

> ⚠️ **Security warning:** Never commit your real API key to a public repository (GitHub, GitLab, etc.). If you plan to share this project, either:
> - Add `config.h` to your `.gitignore`, or
> - Replace the key with an environment variable using `qgetenv("WEATHER_API_KEY")` in `weathermanager.h`

**Safe `.gitignore` entry:**
```
config.h
```

### 3. Build

```bash
mkdir build && cd build
cmake ..
cmake --build .
```

### 4. Run

```bash
./appWeather_app
```

---

## ⚙️ Configuration

| Setting         | Location        | Default  | Description                          |
|-----------------|-----------------|----------|--------------------------------------|
| Target city     | `Main.qml`      | `Cairo`  | City passed to `fetchWeather()`      |
| Refresh interval| `Main.qml`      | `10000ms`| Timer interval for auto-refresh      |
| Temperature unit| `weathermanager.cpp` | `metric` | `metric` = °C, `imperial` = °F  |
| API Key         | `config.h`      | —        | Your OpenWeatherMap API key          |

To change the target city, edit this line in `Main.qml`:

```qml
weather.fetchWeather("Cairo")  // Replace "Cairo" with your city
```

---

## 🌐 API Reference

This app uses the **OpenWeatherMap Current Weather Data** endpoint:

```
GET https://api.openweathermap.org/data/2.5/weather?q={city}&appid={key}&units=metric
```

Fields used from the response:

| JSON Field                        | Displayed As        |
|-----------------------------------|---------------------|
| `main.temp`                       | Temperature         |
| `main.feels_like`                 | Feels Like          |
| `main.humidity`                   | Humidity            |
| `wind.speed`                      | Wind Speed          |
| `weather[0].description`          | Description         |
| `weather[0].icon`                 | Emoji icon          |
| `name`                            | City Name           |

---

## 🌈 Weather Icon Mapping

The app maps OpenWeatherMap icon codes to emojis:

| Icon Code | Emoji | Condition        |
|-----------|-------|------------------|
| `01d`     | ☀️    | Clear sky (day)  |
| `02d`     | 🌤️   | Few clouds       |
| `03d/04d` | ☁️    | Cloudy           |
| `09d`     | 🌧️   | Shower rain      |
| `10d`     | 🌦️   | Rain (day)       |
| `11d`     | ⛈️   | Thunderstorm     |
| `13d`     | ❄️    | Snow             |
| `50d`     | 🌫️   | Mist             |
| `01n`     | 🌙    | Clear sky (night)|
| `10n`     | 🌧️🌙 | Rain (night)     |
| *(others)*| 🌡️   | Default          |

---

## 📦 CMake Notes

- Both `Qt6::Quick` and `Qt6::Network` are linked to the executable.
- QML files and image resources are bundled via `qt_add_qml_module`.
- The app is configured as a `MACOSX_BUNDLE` and `WIN32_EXECUTABLE` for cross-platform packaging.

---

## 🏗️ Architecture — How C++ and QML Connect

This app uses Qt's standard pattern for bridging C++ logic with a QML interface. Here's how the pieces fit together:

```
┌─────────────────────────────────────────────────────────┐
│                        main.cpp                         │
│                                                         │
│  WeatherManager weather;          ← create C++ object   │
│  engine.rootContext()                                    │
│    .setContextProperty("weather", &weather);            │
│                          ↑                              │
│              exposed to QML as "weather"                │
└───────────────────────────┬─────────────────────────────┘
                            │
            ┌───────────────▼──────────────┐
            │        WeatherManager        │
            │        (C++ Backend)         │
            │                              │
            │  fetchWeather(city)  ←───────┼── called from QML Timer
            │       │                      │
            │  QNetworkAccessManager       │
            │       │ HTTP GET             │
            │       ▼                      │
            │  OpenWeatherMap API          │
            │       │ JSON response        │
            │       ▼                      │
            │  Parse JSON fields           │
            │       │                      │
            │  emit weatherReady(...)  ────┼──► received in QML
            └──────────────────────────────┘
                            │
            ┌───────────────▼──────────────┐
            │          Main.qml            │
            │          (UI Layer)          │
            │                              │
            │  Connections {               │
            │    target: weather           │
            │    onWeatherReady(...) {     │
            │      tempText.text = temp    │
            │      cityText.text = city    │
            │      ...                     │
            │    }                         │
            │  }                           │
            └──────────────────────────────┘
```

### Step-by-step breakdown

**1. Registering the C++ object (`main.cpp`)**

The `WeatherManager` object is created in C++ and handed to the QML engine using `setContextProperty`. This makes it available in QML under the name `"weather"` — like a global variable the UI can talk to.

```cpp
WeatherManager weather;
engine.rootContext()->setContextProperty("weather", &weather);
```

**2. QML calls C++ (`Main.qml` → `weathermanager.cpp`)**

A `Timer` in QML fires every 10 seconds and calls the C++ method directly by name:

```qml
Timer {
    interval: 10000
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: {
        weather.fetchWeather("Cairo")  // calls the C++ method
    }
}
```

This works because `fetchWeather` is declared with `Q_INVOKABLE` in the header, which tells Qt to make it callable from QML:

```cpp
Q_INVOKABLE void fetchWeather(const QString &city);
```

**3. C++ fetches and parses data (`weathermanager.cpp`)**

Inside `fetchWeather()`, Qt's `QNetworkAccessManager` sends an HTTP GET request to the OpenWeatherMap API. When the response arrives, a lambda callback parses the JSON and extracts the fields needed by the UI:

```cpp
QString temp        = QString::number(main["temp"].toDouble()) + " °C";
QString humidity    = QString::number(main["humidity"].toInt()) + " %";
QString description = root["weather"].toArray()[0].toObject()["description"].toString();
// ... etc.
```

**4. C++ notifies QML via signals (`weatherReady`)**

Once all data is extracted, C++ fires a **signal** — Qt's event/notification system. The signal carries all the weather data as parameters:

```cpp
emit weatherReady(temp, feelsLike, humidity, windSpeed, description, cityName, icon);
```

The signal is declared in `weathermanager.h`:

```cpp
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
```

**5. QML listens and updates the UI (`Main.qml`)**

QML uses a `Connections` block to listen for the signal and update each text element on screen:

```qml
Connections {
    target: weather
    function onWeatherReady(temp, feelsLike, humidity, windSpeed, desc, city, icon) {
        cityText.text      = city
        tempText.text      = temp
        feelsLikeText.text = feelsLike
        humidityText.text  = humidity
        windText.text      = windSpeed
        descText.text      = desc
        weatherIcon.text   = getWeatherEmoji(icon)
    }
    function onErrorOccurred(error) {
        descText.text = "Error: " + error
    }
}
```

Qt automatically maps the signal name `weatherReady` to the handler name `onWeatherReady` — this is a Qt naming convention.

### Summary

| What happens            | Where it lives          |
|-------------------------|-------------------------|
| UI layout & display     | `Main.qml`              |
| Calling C++ from QML    | `Q_INVOKABLE` + Timer   |
| HTTP network request     | `QNetworkAccessManager` |
| JSON parsing            | `weathermanager.cpp`    |
| Sending data to QML     | `emit weatherReady(...)` signal |
| Receiving data in QML   | `Connections { onWeatherReady }` |

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).

---

## 🙏 Acknowledgements

- [OpenWeatherMap](https://openweathermap.org/) for the free weather API
- [Qt Framework](https://www.qt.io/) for the excellent cross-platform toolkit
