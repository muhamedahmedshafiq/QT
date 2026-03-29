import QtQuick
import QtQuick.Window

Window {
    width: 450
    height: 760
    visible: true
    Image {
        anchors.fill: parent
        source: "qrc:/qt/qml/Weather_app/weather.jpeg"
        fillMode: Image.PreserveAspectCrop

        // dark overlay so text stays readable
        Rectangle {
            anchors.fill: parent
            color: "#000033"
            opacity: 0.35
        }
    }

    property int counter: 0
    function getWeatherEmoji(icon) {
        if (icon === "01d") return "☀️"
        if (icon === "02d") return "🌤️"
        if (icon === "03d") return "☁️"
        if (icon === "04d") return "☁️"
        if (icon === "09d") return "🌧️"
        if (icon === "10d") return "🌦️"
        if (icon === "11d") return "⛈️"
        if (icon === "13d") return "❄️"
        if (icon === "50d") return "🌫️"
        if (icon === "01n") return "🌙"
        if (icon === "02n") return "☁️🌙"
        if (icon === "03n") return "☁️"
        if (icon === "04n") return "☁️"
        if (icon === "09n") return "🌧️"
        if (icon === "10n") return "🌧️🌙"
        if (icon === "11n") return "⛈️"
        if (icon === "13n") return "❄️"
        if (icon === "50n") return "🌫️"
        return "🌡️"
    }

    // --- City Name Section ---
    Rectangle {
        id: citynameId
        width: parent.width * 0.50
        height: parent.height * 0.10
        anchors.left: parent.left
        anchors.top: parent.top
        color: "transparent"
        Text {
            id: cityText
            text: "---"
            font.pixelSize: 28
            font.bold: true
            color: "white"
            anchors.centerIn: parent
        }
    }

    // --- Temperature Section ---
    Rectangle {
        id: tempId
        width: parent.width * 0.80
        height: 100
        anchors.top: parent.top       // Align to the top of the window
        anchors.topMargin: 120        // Push it down slightly (below your city name)
        anchors.horizontalCenter: parent.horizontalCenter // Center it left-to-right

        color: "transparent"

        Text {
            id: tempText
            text: "--°"
            font.pixelSize: 80
            font.bold: true
            color: "#ffffff"
            anchors.centerIn: parent  // Centers the number inside the tempId rectangle

            Behavior on text {
                SequentialAnimation {
                    NumberAnimation { target: tempText; property: "scale"; to: 0.85; duration: 100 }
                    NumberAnimation { target: tempText; property: "scale"; to: 1.0;  duration: 300; easing.type: Easing.OutBack }
                }
            }
        }
    }

Row {
    anchors.top: tempId.bottom
    anchors.topMargin: 100
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: 12

    Rectangle {
        id: feelsLikeid
        width: 130
        height: 100
        radius: 20
        color: "#2effffff"
        border.color: "#80ffffff"
        border.width: 0.5

        Column {
            anchors.centerIn: parent
            spacing: 4

            Text {
                text: "🤔"
                font.pixelSize: 22
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                id: feelsLikeText
                text: "--°"
                font.pixelSize: 20
                color: "white"
                anchors.horizontalCenter: parent.horizontalCenter
                width: feelsLikeid.width - 10
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                text: "FEELS LIKE"
                font.pixelSize: 8
                font.letterSpacing: 1.5
                color: "#ffffff"
                opacity: 0.6
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    Rectangle {
        id: humidityid
        width: 130
        height: 100
        radius: 20
        color: "#2effffff"
        border.color: "#80ffffff"
        border.width: 0.5

        Column {
            anchors.centerIn: parent
            spacing: 4

            Text {
                text: "💧"
                font.pixelSize: 30
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                id: humidityText
                text: "--%"
                font.pixelSize: 28
                color: "white"
                anchors.horizontalCenter: parent.horizontalCenter
                width: humidityid.width - 10    // ✅ max width = card width
                wrapMode: Text.WordWrap         // ✅ wraps if too long
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                text: "HUMIDITY"
                font.pixelSize: 12
                font.letterSpacing: 1.5
                color: "#ffffff"
                opacity: 0.6
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    Rectangle {
        id: windId
        width: 130
        height: 100
        radius: 20
        color: "#2effffff"
        border.color: "#80ffffff"
        border.width: 0.5

        Column {
            anchors.centerIn: parent
            spacing: 4

            Text {
                text: "💨"
                font.pixelSize: 22
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                id: windText
                text: "--"
                font.pixelSize: 20
                color: "white"
                anchors.horizontalCenter: parent.horizontalCenter
                width: windId.width - 10        // ✅ max width = card width
                wrapMode: Text.WordWrap         // ✅ wraps if too long
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                text: "WIND"
                font.pixelSize: 8
                font.letterSpacing: 1.5
                color: "#ffffff"
                opacity: 0.6
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}

    Column {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 50
        spacing: 10

        Text {
            id: weatherIcon
            font.pixelSize: 60
            color: "white"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Text { id: descText
            font.pixelSize: 20
            color: "white"
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Timer {
        id: myTimer
        interval: 10000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            if (typeof weather !== "undefined") weather.fetchWeather("Cairo")
            counter++;
        }
    }

    Connections {
        target: weather
        function onWeatherReady(temp, feelsLike, humidity, windSpeed, desc, city, icon) {
            cityText.text      = city
            descText.text      = desc
            tempText.text      = temp
            feelsLikeText.text = feelsLike
            humidityText.text  = humidity
            windText.text      = windSpeed
            weatherIcon.text   = getWeatherEmoji(icon)
        }
        function onErrorOccurred(error) {
            descText.text = "Error: " + error
        }
    }
}
