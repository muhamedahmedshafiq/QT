import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    width: 480
    height: 750
    visible: true
    title: "Network Controller"
    color: "#1a1a2e"

    // Listen for status messages from C++
    Connections {
        target: networkCtrl
        function onStatusMessage(message) {
            statusText.text = message
            statusAnim.restart()
        }

        function onWifiChanged() {
            if (!networkCtrl.wifiOn) {
                wifiRepeater.model = []
            }
        }
        function onBluetoothChanged() {
            if (!networkCtrl.bluetoothOn) {
                btRepeater.model = []
            }
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: mainColumn.height + 40
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: mainColumn
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 20
            }
            spacing: 20

            // ========== HEADER ==========
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 80

                Column {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: "Network Control"
                        font.pixelSize: 30
                        font.bold: true
                        color: "#e94560"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "Manage your connections easily"
                        font.pixelSize: 14
                        color: "#8888aa"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            // ==========================================
            //  📶 WIFI CARD
            // ==========================================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: wifiContent.height + 40
                radius: 20
                color: "#16213e"
                border.color: networkCtrl.wifiOn ? "#4dc9f6" : "#2a2a4a"
                border.width: 2

                Behavior on border.color { ColorAnimation { duration: 400 } }
                Behavior on Layout.preferredHeight {
                    NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
                }

                ColumnLayout {
                    id: wifiContent
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 20
                    }
                    spacing: 15

                    // WiFi Header
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Rectangle {
                            width: 50; height: 50; radius: 15
                            color: networkCtrl.wifiOn ? "#1a3a5c" : "#222244"
                            Behavior on color { ColorAnimation { duration: 300 } }
                            Text {
                                text: networkCtrl.wifiOn ? "📶" : "📵"
                                font.pixelSize: 24
                                anchors.centerIn: parent
                            }
                        }

                        ColumnLayout {
                            spacing: 3
                            Text {
                                text: "WiFi"
                                font.pixelSize: 20; font.bold: true; color: "white"
                            }
                            Text {
                                text: networkCtrl.wifiOn ? "● Enabled" : "○ Disabled"
                                font.pixelSize: 12
                                color: networkCtrl.wifiOn ? "#4dc9f6" : "#666688"
                                Behavior on color { ColorAnimation { duration: 300 } }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // WiFi Toggle
                        Rectangle {
                            width: 60; height: 30; radius: 15
                            color: networkCtrl.wifiOn ? "#4dc9f6" : "#333355"
                            Behavior on color { ColorAnimation { duration: 300 } }

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
                                cursorShape: Qt.PointingHandCursor
                                onClicked: networkCtrl.toggleWifi()
                            }
                        }
                    }

                    // ==========================================
                    //  ✅ CONNECTED WIFI INFO — Shows current connection
                    // ==========================================
                    Rectangle {
                        Layout.fillWidth: true
                        height: wifiConnectedCol.height + 20
                        radius: 14
                        visible: networkCtrl.wifiOn && networkCtrl.connectedWifi !== ""
                        opacity: visible ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 300 } }

                        // Green gradient background
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#0d3b2e" }
                            GradientStop { position: 1.0; color: "#0a2a20" }
                        }
                        border.color: "#2ecc71"
                        border.width: 1

                        ColumnLayout {
                            id: wifiConnectedCol
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                margins: 12
                            }
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                // Green pulse dot
                                Rectangle {
                                    width: 10; height: 10; radius: 5
                                    color: "#2ecc71"

                                    SequentialAnimation on opacity {
                                        loops: Animation.Infinite
                                        NumberAnimation { to: 0.3; duration: 1000 }
                                        NumberAnimation { to: 1.0; duration: 1000 }
                                    }
                                }

                                Text {
                                    text: "CONNECTED"
                                    font.pixelSize: 11
                                    font.bold: true
                                    font.letterSpacing: 2
                                    color: "#2ecc71"
                                }

                                Item { Layout.fillWidth: true }

                                // Disconnect button
                                Rectangle {
                                    width: 85; height: 26; radius: 8
                                    color: disconnWifiMouse.pressed ? "#c0392b" : "#e74c3c"

                                    Text {
                                        text: "Disconnect"
                                        color: "white"
                                        font.pixelSize: 11
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                    MouseArea {
                                        id: disconnWifiMouse
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: networkCtrl.disconnectWifi()
                                    }
                                }
                            }

                            // Network name
                            RowLayout {
                                spacing: 8
                                Text {
                                    text: "📶"
                                    font.pixelSize: 16
                                }
                                Text {
                                    text: networkCtrl.connectedWifi
                                    color: "white"
                                    font.pixelSize: 16
                                    font.bold: true
                                }
                            }

                            // IP Address
                            RowLayout {
                                spacing: 8
                                visible: networkCtrl.connectedWifiIp !== ""

                                Text {
                                    text: "🌐"
                                    font.pixelSize: 14
                                }
                                Text {
                                    text: "IP: " + networkCtrl.connectedWifiIp
                                    color: "#88bbaa"
                                    font.pixelSize: 13
                                    font.family: "monospace"
                                }
                            }
                        }
                    }

                    // "Not connected" info when WiFi is ON but no connection
                    Rectangle {
                        Layout.fillWidth: true
                        height: 45
                        radius: 12
                        visible: networkCtrl.wifiOn && networkCtrl.connectedWifi === ""
                        opacity: visible ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 300 } }
                        color: "#1a1a33"
                        border.color: "#333355"
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Rectangle {
                                width: 10; height: 10; radius: 5
                                color: "#e74c3c"
                            }
                            Text {
                                text: "Not connected to any network"
                                color: "#888899"
                                font.pixelSize: 13
                            }
                        }
                    }

                    // Divider
                    Rectangle {
                        Layout.fillWidth: true; height: 1; color: "#2a2a4a"
                        visible: networkCtrl.wifiOn
                        opacity: networkCtrl.wifiOn ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 300 } }
                    }

                    // Scan Button
                    Rectangle {
                        Layout.fillWidth: true; height: 45; radius: 12
                        visible: networkCtrl.wifiOn
                        opacity: networkCtrl.wifiOn ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 300 } }
                        color: scanWifiMouse.pressed ? "#0a2647" : "#0f3460"

                        Text {
                            text: "🔍  Scan Networks"
                            color: "white"
                            font.pixelSize: 14; font.bold: true
                            anchors.centerIn: parent
                        }
                        MouseArea {
                            id: scanWifiMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                networkCtrl.scanWifi()
                                wifiListTimer.start()
                            }
                        }
                    }

                    Timer {
                        id: wifiListTimer
                        interval: 1500
                        onTriggered: wifiRepeater.model = networkCtrl.getWifiList()
                    }

                    // WiFi List
                    Column {
                        Layout.fillWidth: true
                        spacing: 8
                        visible: networkCtrl.wifiOn
                        opacity: networkCtrl.wifiOn ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 300 } }

                        Repeater {
                            id: wifiRepeater
                            model: []

                            delegate: Rectangle {
                                width: parent.width; height: 65; radius: 12
                                // ✅ Highlight connected network
                                color: modelData.connected
                                       ? "#0d3b2e"
                                       : (wifiItemMouse.containsMouse ? "#1e2d52" : "#111833")
                                border.color: modelData.connected ? "#2ecc71" : "transparent"
                                border.width: modelData.connected ? 1 : 0
                                Behavior on color { ColorAnimation { duration: 150 } }

                                MouseArea {
                                    id: wifiItemMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (!modelData.connected) {
                                            passwordDialog.ssid = modelData.name
                                            passwordField.text = ""
                                            passwordDialog.open()
                                        }
                                    }
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    Rectangle {
                                        width: 40; height: 40; radius: 10
                                        color: modelData.connected ? "#0d3b2e" : "#1a2a4e"
                                        Text {
                                            text: {
                                                var s = parseInt(modelData.signal)
                                                if (s > 75) return "📶"
                                                if (s > 50) return "📡"
                                                return "📻"
                                            }
                                            font.pixelSize: 18
                                            anchors.centerIn: parent
                                        }
                                    }

                                    ColumnLayout {
                                        spacing: 3
                                        RowLayout {
                                            spacing: 6
                                            Text {
                                                text: modelData.name
                                                color: "white"
                                                font.pixelSize: 14; font.bold: true
                                            }
                                            // ✅ "Connected" badge
                                            Rectangle {
                                                width: connLabel.width + 12
                                                height: 18
                                                radius: 9
                                                color: "#2ecc71"
                                                visible: modelData.connected

                                                Text {
                                                    id: connLabel
                                                    text: "Connected"
                                                    color: "white"
                                                    font.pixelSize: 10
                                                    font.bold: true
                                                    anchors.centerIn: parent
                                                }
                                            }
                                        }
                                        RowLayout {
                                            spacing: 8
                                            Rectangle {
                                                width: 60; height: 4; radius: 2
                                                color: "#2a2a4a"
                                                Rectangle {
                                                    width: parent.width * parseInt(modelData.signal) / 100
                                                    height: parent.height; radius: 2
                                                    color: {
                                                        var s = parseInt(modelData.signal)
                                                        if (s > 75) return "#4dc9f6"
                                                        if (s > 50) return "#f6c23e"
                                                        return "#e94560"
                                                    }
                                                }
                                            }
                                            Text {
                                                text: modelData.signal + "% • " + modelData.security
                                                color: "#8888aa"; font.pixelSize: 11
                                            }
                                        }
                                    }

                                    Item { Layout.fillWidth: true }

                                    Text {
                                        text: modelData.connected ? "✅"
                                              : (modelData.security !== "" ? "🔒" : "🔓")
                                        font.pixelSize: 18
                                    }
                                }
                            }
                        }
                    }

                    // "WiFi is OFF" message
                    Text {
                        Layout.fillWidth: true
                        text: "Turn on WiFi to see available networks"
                        color: "#555577"
                        font.pixelSize: 13
                        font.italic: true
                        horizontalAlignment: Text.AlignHCenter
                        visible: !networkCtrl.wifiOn
                        opacity: !networkCtrl.wifiOn ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 300 } }
                    }
                }
            }

            // ==========================================
            //  🔵 BLUETOOTH CARD
            // ==========================================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: btContent.height + 40
                radius: 20
                color: "#16213e"
                border.color: networkCtrl.bluetoothOn ? "#6c63ff" : "#2a2a4a"
                border.width: 2
                Behavior on border.color { ColorAnimation { duration: 400 } }
                Behavior on Layout.preferredHeight {
                    NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
                }

                ColumnLayout {
                    id: btContent
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 20
                    }
                    spacing: 15

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Rectangle {
                            width: 50; height: 50; radius: 15
                            color: networkCtrl.bluetoothOn ? "#2a1f5e" : "#222244"
                            Behavior on color { ColorAnimation { duration: 300 } }
                            Text {
                                text: "🔵"; font.pixelSize: 24
                                anchors.centerIn: parent
                            }
                        }

                        ColumnLayout {
                            spacing: 3
                            Text {
                                text: "Bluetooth"
                                font.pixelSize: 20; font.bold: true; color: "white"
                            }
                            Text {
                                text: networkCtrl.bluetoothOn ? "● Enabled" : "○ Disabled"
                                font.pixelSize: 12
                                color: networkCtrl.bluetoothOn ? "#6c63ff" : "#666688"
                                Behavior on color { ColorAnimation { duration: 300 } }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            width: 60; height: 30; radius: 15
                            color: networkCtrl.bluetoothOn ? "#6c63ff" : "#333355"
                            Behavior on color { ColorAnimation { duration: 300 } }

                            Rectangle {
                                width: 24; height: 24; radius: 12
                                color: "white"; y: 3
                                x: networkCtrl.bluetoothOn ? parent.width - width - 3 : 3
                                Behavior on x {
                                    NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: networkCtrl.toggleBluetooth()
                            }
                        }
                    }

                    // ==========================================
                    //  ✅ CONNECTED BLUETOOTH INFO
                    // ==========================================
                    Rectangle {
                        Layout.fillWidth: true
                        height: btConnectedCol.height + 20
                        radius: 14
                        visible: networkCtrl.bluetoothOn && networkCtrl.connectedBtDevice !== ""
                        opacity: visible ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 300 } }

                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#1a1040" }
                            GradientStop { position: 1.0; color: "#130d30" }
                        }
                        border.color: "#6c63ff"
                        border.width: 1

                        ColumnLayout {
                            id: btConnectedCol
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                margins: 12
                            }
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                // Purple pulse dot
                                Rectangle {
                                    width: 10; height: 10; radius: 5
                                    color: "#6c63ff"

                                    SequentialAnimation on opacity {
                                        loops: Animation.Infinite
                                        NumberAnimation { to: 0.3; duration: 1000 }
                                        NumberAnimation { to: 1.0; duration: 1000 }
                                    }
                                }

                                Text {
                                    text: "CONNECTED"
                                    font.pixelSize: 11
                                    font.bold: true
                                    font.letterSpacing: 2
                                    color: "#6c63ff"
                                }

                                Item { Layout.fillWidth: true }

                                // Disconnect button
                                Rectangle {
                                    width: 85; height: 26; radius: 8
                                    color: disconnBtMouse.pressed ? "#c0392b" : "#e74c3c"

                                    Text {
                                        text: "Disconnect"
                                        color: "white"
                                        font.pixelSize: 11
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                    MouseArea {
                                        id: disconnBtMouse
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: networkCtrl.disconnectBluetooth()
                                    }
                                }
                            }

                            // Device name
                            RowLayout {
                                spacing: 8
                                Text {
                                    text: "🎧"
                                    font.pixelSize: 16
                                }
                                Text {
                                    text: networkCtrl.connectedBtDevice
                                    color: "white"
                                    font.pixelSize: 16
                                    font.bold: true
                                }
                            }

                            // MAC Address
                            RowLayout {
                                spacing: 8
                                Text {
                                    text: "📍"
                                    font.pixelSize: 14
                                }
                                Text {
                                    text: networkCtrl.connectedBtAddress
                                    color: "#8877bb"
                                    font.pixelSize: 13
                                    font.family: "monospace"
                                }
                            }
                        }
                    }

                    // "Not connected" when BT is ON but nothing connected
                    Rectangle {
                        Layout.fillWidth: true
                        height: 45
                        radius: 12
                        visible: networkCtrl.bluetoothOn && networkCtrl.connectedBtDevice === ""
                        opacity: visible ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 300 } }
                        color: "#1a1a33"
                        border.color: "#333355"
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Rectangle {
                                width: 10; height: 10; radius: 5
                                color: "#e74c3c"
                            }
                            Text {
                                text: "No device connected"
                                color: "#888899"
                                font.pixelSize: 13
                            }
                        }
                    }

                    // Divider
                    Rectangle {
                        Layout.fillWidth: true; height: 1; color: "#2a2a4a"
                        visible: networkCtrl.bluetoothOn
                        opacity: networkCtrl.bluetoothOn ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 300 } }
                    }

                    // Scan BT Button
                    Rectangle {
                        Layout.fillWidth: true; height: 45; radius: 12
                        visible: networkCtrl.bluetoothOn
                        opacity: networkCtrl.bluetoothOn ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 300 } }
                        color: scanBtMouse.pressed ? "#2a1f5e" : "#3b3486"

                        Text {
                            text: "🔍  Scan Devices"
                            color: "white"
                            font.pixelSize: 14; font.bold: true
                            anchors.centerIn: parent
                        }
                        MouseArea {
                            id: scanBtMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: btRepeater.model = networkCtrl.scanBluetooth()
                        }
                    }

                    // BT Device List
                    Column {
                        Layout.fillWidth: true
                        spacing: 8
                        visible: networkCtrl.bluetoothOn
                        opacity: networkCtrl.bluetoothOn ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 300 } }

                        Repeater {
                            id: btRepeater
                            model: []

                            delegate: Rectangle {
                                width: parent.width; height: 65; radius: 12
                                color: modelData.connected
                                       ? "#1a1040"
                                       : (btItemMouse.containsMouse ? "#1e2d52" : "#111833")
                                border.color: modelData.connected ? "#6c63ff" : "transparent"
                                border.width: modelData.connected ? 1 : 0
                                Behavior on color { ColorAnimation { duration: 150 } }

                                MouseArea {
                                    id: btItemMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    Rectangle {
                                        width: 40; height: 40; radius: 10
                                        color: modelData.connected ? "#1a1040" : "#2a1f5e"
                                        Text {
                                            // ✅ Icon based on device type
                                            text: {
                                                if (modelData.connected) return "🔗"
                                                if (modelData.deviceType === "audio") return "🎧"
                                                if (modelData.deviceType === "phone") return "📱"
                                                if (modelData.deviceType === "input") return "⌨️"
                                                if (modelData.deviceType === "computer") return "💻"
                                                return "📡"
                                            }
                                            font.pixelSize: 18
                                            anchors.centerIn: parent
                                        }
                                    }

                                    ColumnLayout {
                                        spacing: 3
                                        RowLayout {
                                            spacing: 6
                                            Text {
                                                text: modelData.name
                                                color: "white"
                                                font.pixelSize: 14; font.bold: true
                                            }
                                            // "Connected" badge
                                            Rectangle {
                                                width: btConnBadge.width + 12
                                                height: 18; radius: 9
                                                color: "#6c63ff"
                                                visible: modelData.connected
                                                Text {
                                                    id: btConnBadge
                                                    text: "Connected"
                                                    color: "white"
                                                    font.pixelSize: 10; font.bold: true
                                                    anchors.centerIn: parent
                                                }
                                            }
                                            // "Paired" badge
                                            Rectangle {
                                                width: btPairBadge.width + 12
                                                height: 18; radius: 9
                                                color: "#333366"
                                                visible: modelData.paired && !modelData.connected
                                                Text {
                                                    id: btPairBadge
                                                    text: "Paired"
                                                    color: "#8888bb"
                                                    font.pixelSize: 10; font.bold: true
                                                    anchors.centerIn: parent
                                                }
                                            }
                                        }
                                        Text {
                                            text: modelData.address
                                            color: "#8888aa"
                                            font.pixelSize: 11
                                        }
                                    }

                                    Item { Layout.fillWidth: true }

                                    // ✅ "Connect" button for paired but not connected
                                    Rectangle {
                                        width: 75; height: 30; radius: 8
                                        visible: modelData.paired && !modelData.connected
                                        color: btReconnMouse.pressed ? "#4a3faa" : "#6c63ff"
                                        Text {
                                            text: "Connect"
                                            color: "white"; font.pixelSize: 11; font.bold: true
                                            anchors.centerIn: parent
                                        }
                                        MouseArea {
                                            id: btReconnMouse
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                // ✅ Connect to already paired device
                                                networkCtrl.pairBluetooth(modelData.address)
                                                btRepeater.model = networkCtrl.scanBluetooth()
                                            }
                                        }
                                    }

                                    // ✅ "Pair" button for new devices
                                    Rectangle {
                                        width: 55; height: 30; radius: 8
                                        visible: !modelData.paired && !modelData.connected
                                        color: btPairMouse.pressed ? "#4a3faa" : "#6c63ff"
                                        Text {
                                            text: "Pair"
                                            color: "white"; font.pixelSize: 12; font.bold: true
                                            anchors.centerIn: parent
                                        }
                                        MouseArea {
                                            id: btPairMouse
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                // ✅ NOW ACTUALLY PAIRS!
                                                networkCtrl.pairBluetooth(modelData.address)
                                                btRepeater.model = networkCtrl.scanBluetooth()
                                            }
                                        }
                                    }

                                    // Checkmark for connected
                                    Text {
                                        text: "✅"
                                        font.pixelSize: 18
                                        visible: modelData.connected
                                    }
                                }
                            }
                        }
                    }

                    // "Bluetooth is OFF" message
                    Text {
                        Layout.fillWidth: true
                        text: "Turn on Bluetooth to discover devices"
                        color: "#555577"
                        font.pixelSize: 13
                        font.italic: true
                        horizontalAlignment: Text.AlignHCenter
                        visible: !networkCtrl.bluetoothOn
                        opacity: !networkCtrl.bluetoothOn ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 300 } }
                    }
                }
            }

            // ========== STATUS BAR ==========
            Rectangle {
                Layout.fillWidth: true; height: 55; radius: 16
                color: "#0f3460"

                Text {
                    id: statusText
                    text: "👋 Welcome! Toggle your connections above."
                    color: "white"; font.pixelSize: 13
                    anchors.centerIn: parent

                    NumberAnimation on opacity {
                        id: statusAnim
                        from: 0.0; to: 1.0; duration: 400
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            Item { Layout.preferredHeight: 20 }
        }
    }

    // ========== PASSWORD DIALOG ==========
    Dialog {
        id: passwordDialog
        anchors.centerIn: parent
        width: 380; modal: true; dim: true
        property string ssid: ""

        background: Rectangle {
            color: "#16213e"; radius: 20
            border.color: "#4dc9f6"; border.width: 2
        }

        Overlay.modal: Rectangle { color: "#aa000000" }

        header: Item {
            height: 70
            Column {
                anchors.centerIn: parent; spacing: 5
                Text {
                    text: "🔐 Connect to WiFi"
                    color: "#4dc9f6"; font.pixelSize: 18; font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: passwordDialog.ssid
                    color: "white"; font.pixelSize: 14
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        contentItem: ColumnLayout {
            spacing: 15

            Rectangle {
                Layout.fillWidth: true; height: 45; radius: 12
                color: "#111833"
                border.color: passwordField.focus ? "#4dc9f6" : "#333355"
                border.width: 2
                Behavior on border.color { ColorAnimation { duration: 200 } }

                TextInput {
                    id: passwordField
                    anchors.fill: parent; anchors.margins: 12
                    color: "white"; font.pixelSize: 14
                    echoMode: showPass.checked ? TextInput.Normal : TextInput.Password
                    clip: true
                    verticalAlignment: TextInput.AlignVCenter

                    Text {
                        text: "Enter password..."
                        color: "#555577"; font.pixelSize: 14
                        visible: !passwordField.text && !passwordField.focus
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            RowLayout {
                spacing: 8
                Rectangle {
                    width: 20; height: 20; radius: 4
                    color: showPass.checked ? "#4dc9f6" : "#333355"
                    border.color: "#4dc9f6"
                    Text {
                        text: showPass.checked ? "✓" : ""
                        color: "white"; font.pixelSize: 14; font.bold: true
                        anchors.centerIn: parent
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: showPass.checked = !showPass.checked
                    }
                }
                CheckBox { id: showPass; visible: false }
                Text {
                    text: "Show password"
                    color: "#8888aa"; font.pixelSize: 12
                    MouseArea {
                        anchors.fill: parent
                        onClicked: showPass.checked = !showPass.checked
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true; spacing: 10

                Rectangle {
                    Layout.fillWidth: true; height: 45; radius: 12
                    color: cancelMouse.pressed ? "#222244" : "#333355"
                    Text { text: "Cancel"; color: "white"; font.pixelSize: 14; anchors.centerIn: parent }
                    MouseArea {
                        id: cancelMouse; anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: passwordDialog.close()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true; height: 45; radius: 12
                    color: connectMouse.pressed ? "#3aafdb" : "#4dc9f6"
                    Text { text: "✅ Connect"; color: "white"; font.pixelSize: 14; font.bold: true; anchors.centerIn: parent }
                    MouseArea {
                        id: connectMouse; anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            networkCtrl.connectWifi(passwordDialog.ssid, passwordField.text)
                            passwordDialog.close()
                            passwordField.text = ""
                        }
                    }
                }
            }
        }
    }
}