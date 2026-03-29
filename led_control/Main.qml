import QtQuick

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("LED")

    Rectangle {
    id: ledPanel
    width: parent.width * 0.9
    height: 80
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 8
    anchors.horizontalCenter: parent.horizontalCenter
    color: "#1a1a1a"
    radius: 20

    Row {
        anchors.centerIn: parent
        spacing: 20

        // LED ON button
        Rectangle {
            width: 140
            height: 54
            radius: 20
            color: ledOnArea.pressed ? "#27ae60" : "#2ecc71"

            Text {
                text: "💡 LED ON"
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: 18
                font.bold: true
            }

            MouseArea {
                id: ledOnArea
                anchors.fill: parent
                onClicked: gpio.ledOn()
            }

            Behavior on color {
                ColorAnimation { duration: 100 }
            }
        }

        // LED OFF button
        Rectangle {
            width: 140
            height: 54
            radius: 20
            color: ledOffArea.pressed ? "#c0392b" : "#e74c3c"

            Text {
                text: "🌑 LED OFF"
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: 18
                font.bold: true
            }

            MouseArea {
                id: ledOffArea
                anchors.fill: parent
                onClicked: gpio.ledOff()
            }

            Behavior on color {
                ColorAnimation { duration: 100 }
            }
        }
    }
}
}
