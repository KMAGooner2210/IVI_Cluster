import QtQuick
import QtQuick.Controls

Window {
    width: 1024
    height: 600
    visible: true
    title: "KMAGOONER"
    color: "#0f1118"

    property real smoothSpeed: vehicleData.speed
    property real smoothRpm:   vehicleData.rpm
    property string currentGear: smoothSpeed < 1 ? "P" :
                                  smoothSpeed < 30 ? "1" :
                                  smoothSpeed < 60 ? "2" :
                                  smoothSpeed < 90 ? "3" :
                                  smoothSpeed < 130 ? "4" :
                                  smoothSpeed < 180 ? "5" : "6"

    Behavior on smoothSpeed { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    Behavior on smoothRpm   { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

    // ── TOP BAR ──
    Item {
        id: topBar
        width: parent.width; height: 48
        anchors.top: parent.top

        Row {
            anchors.left: parent.left; anchors.leftMargin: 24
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            Text {
                text: Qt.formatTime(new Date(), "hh:mm")
                font.pixelSize: 20; font.weight: Font.Bold; color: "#ffffff"
                Timer { interval: 1000; running: true; repeat: true
                    onTriggered: parent.text = Qt.formatTime(new Date(), "hh:mm") }
            }
            Text {
                text: Qt.formatDate(new Date(), "dddd, MMM d")
                font.pixelSize: 13; color: "#aab8cc"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Text {
            anchors.centerIn: parent
            text: "KMAGOONER"
            font.pixelSize: 16; font.weight: Font.Bold
            font.letterSpacing: 6
            color: "#6a8db8"
        }

        Row {
            anchors.right: parent.right; anchors.rightMargin: 24
            anchors.verticalCenter: parent.verticalCenter
            spacing: 20

            Text { text: "BT"; font.pixelSize: 13; color: "#8a9eb8" }
            Text { text: "LTE"; font.pixelSize: 13; color: "#5a9fe8"; font.weight: Font.Medium }
            Row {
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter
                Rectangle {
                    width: 28; height: 14; radius: 3
                    color: "transparent"
                    border.color: "#2ecc71"; border.width: 1
                    anchors.verticalCenter: parent.verticalCenter
                    Rectangle {
                        anchors.left: parent.left; anchors.leftMargin: 2
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20; height: 10; radius: 2
                        color: "#2ecc71"
                    }
                }
                Text { text: "85%"; font.pixelSize: 13; color: "#2ecc71"; font.weight: Font.Medium }
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width; height: 1
            color: "#1e2530"
        }
    }

    // ── MAIN CONTENT ──
    Item {
        anchors.top: topBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 16
        anchors.topMargin: 12

        // ── LEFT COLUMN ──
        Column {
            id: leftCol
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 300
            spacing: 12

            // CAR CARD
            Rectangle {
                width: parent.width; height: 240
                color: "#181c26"
                radius: 16
                border.color: "#3a4a60"; border.width: 1

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom; anchors.bottomMargin: 42
                    width: 180; height: 20; radius: 100
                    color: "#3a7bd5"; opacity: 0.18
                }

                Image {
                    anchors.top: parent.top; anchors.topMargin: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - 20
                    height: 160
                    fillMode: Image.PreserveAspectFit
                    source: "qrc:/qt/qml/ClusterClient/assets/VF8.png"
                    antialiasing: true; smooth: true

                    SequentialAnimation on anchors.topMargin {
                        loops: Animation.Infinite
                        NumberAnimation { to: 14; duration: 2200; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 10; duration: 2200; easing.type: Easing.InOutSine }
                    }
                }

                Row {
                    anchors.bottom: parent.bottom; anchors.bottomMargin: 14
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 20

                    Column {
                        spacing: 4
                        Text { text: "340 km"; color: "#ffffff"; font.pixelSize: 16; font.weight: Font.Medium }
                        Text { text: "Range"; color: "#b0bece"; font.pixelSize: 11; font.weight: Font.Medium }
                    }

                    Rectangle { width: 1; height: 28; color: "#3a4a60" }

                    Column {
                        spacing: 4
                        Text { text: "15.2"; color: "#5aabff"; font.pixelSize: 16; font.weight: Font.Medium }
                        Text { text: "kWh/100km"; color: "#b0bece"; font.pixelSize: 11; font.weight: Font.Medium }
                    }

                    Rectangle { width: 1; height: 28; color: "#3a4a60" }

                    Column {
                        spacing: 4
                        Text { text: "85%"; color: "#2ecc71"; font.pixelSize: 16; font.weight: Font.Medium }
                        Text { text: "Battery"; color: "#b0bece"; font.pixelSize: 11; font.weight: Font.Medium }
                    }
                }
            }

            // SPEED CARD
            Rectangle {
                width: parent.width
                height: parent.height - 240 - 12
                color: "#181c26"
                radius: 16
                border.color: "#3a4a60"; border.width: 1

                Row {
                    anchors.top: parent.top; anchors.topMargin: 14
                    anchors.left: parent.left; anchors.leftMargin: 18
                    anchors.right: parent.right; anchors.rightMargin: 18
                    spacing: 0

                    Text {
                        text: "SPEED"
                        font.pixelSize: 11; font.letterSpacing: 3
                        color: "#aab8cc"; font.weight: Font.Medium
                    }

                    Item { width: parent.width - 60 - 80; height: 1 }

                    Row {
                        spacing: 12
                        Canvas {
                            width: 18; height: 14
                            opacity: vehicleData.leftOn ? 1.0 : 0.25
                            onPaint: {
                                var c = getContext("2d"); c.clearRect(0,0,width,height);
                                c.fillStyle = vehicleData.leftOn ? "#2ecc71" : "#7a90a8";
                                c.beginPath(); c.moveTo(18,4); c.lineTo(7,4); c.lineTo(7,0);
                                c.lineTo(0,7); c.lineTo(7,14); c.lineTo(7,10); c.lineTo(18,10);
                                c.closePath(); c.fill();
                            }
                            SequentialAnimation on opacity {
                                running: vehicleData.leftOn; loops: Animation.Infinite
                                NumberAnimation { to: 0.1; duration: 380 }
                                NumberAnimation { to: 1.0; duration: 380 }
                            }
                            Connections { target: vehicleData
                                function onLeftOnChanged() { parent.requestPaint() } }
                        }

                        Text {
                            text: "⚠"; font.pixelSize: 14
                            color: vehicleData.hazard ? "#e67e22" : "#28303e"
                            SequentialAnimation on opacity {
                                running: vehicleData.hazard; loops: Animation.Infinite
                                NumberAnimation { to: 0.1; duration: 300 }
                                NumberAnimation { to: 1.0; duration: 300 }
                            }
                        }

                        Canvas {
                            width: 18; height: 14
                            opacity: vehicleData.rightOn ? 1.0 : 0.25
                            onPaint: {
                                var c = getContext("2d"); c.clearRect(0,0,width,height);
                                c.fillStyle = vehicleData.rightOn ? "#2ecc71" : "#7a90a8";
                                c.beginPath(); c.moveTo(0,4); c.lineTo(11,4); c.lineTo(11,0);
                                c.lineTo(18,7); c.lineTo(11,14); c.lineTo(11,10); c.lineTo(0,10);
                                c.closePath(); c.fill();
                            }
                            SequentialAnimation on opacity {
                                running: vehicleData.rightOn; loops: Animation.Infinite
                                NumberAnimation { to: 0.1; duration: 380 }
                                NumberAnimation { to: 1.0; duration: 380 }
                            }
                            Connections { target: vehicleData
                                function onRightOnChanged() { parent.requestPaint() } }
                        }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top; anchors.topMargin: 28
                    text: Math.round(smoothSpeed)
                    font.pixelSize: 82; font.weight: Font.Thin
                    color: "#ffffff"
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top; anchors.topMargin: 118
                    text: "km/h"
                    font.pixelSize: 12; font.letterSpacing: 3
                    color: "#aab8cc"; font.weight: Font.Medium
                }

                Item {
                    anchors.left: parent.left; anchors.right: parent.right
                    anchors.leftMargin: 18; anchors.rightMargin: 18
                    anchors.top: parent.top; anchors.topMargin: 142
                    height: 24

                    Rectangle {
                        id: rpmBg
                        width: parent.width; height: 3; radius: 2
                        color: "#0e1420"

                        Rectangle {
                            width: (smoothRpm / 8000) * parent.width
                            height: 3; radius: 2
                            color: smoothRpm > 6500 ? "#e74c3c" :
                                   smoothRpm > 5000 ? "#e67e22" : "#3a7bd5"
                            Behavior on width { NumberAnimation { duration: 100 } }
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.top: rpmBg.bottom; anchors.topMargin: 4
                        text: Math.round(smoothRpm) + " rpm"
                        font.pixelSize: 10; color: "#8a9eb8"; font.weight: Font.Medium
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom; anchors.bottomMargin: 14
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 220; height: 36; radius: 18
                    color: "#0f1118"

                    Row {
                        anchors.centerIn: parent; spacing: 4

                        Repeater {
                            model: ["P", "R", "N", "D"]
                            Rectangle {
                                width: 46; height: 28; radius: 14
                                color: currentGear === modelData ? "#3a7bd5" : "transparent"
                                Behavior on color { ColorAnimation { duration: 200 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.pixelSize: 14; font.weight: Font.Bold
                                    color: currentGear === modelData ? "#ffffff" : "#7a90a8"
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── RIGHT COLUMN ──
        Column {
            anchors.left: leftCol.right; anchors.leftMargin: 12
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            spacing: 12

            // MAP CARD
            Rectangle {
                width: parent.width; height: 300
                color: "#181c26"
                radius: 16
                border.color: "#3a4a60"; border.width: 1
                clip: true

                Canvas {
                    anchors.fill: parent; opacity: 0.07
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.strokeStyle = "#4a90d9"; ctx.lineWidth = 0.5
                        for (var x = 0; x < width; x += 36) {
                            ctx.beginPath(); ctx.moveTo(x,0); ctx.lineTo(x,height); ctx.stroke()
                        }
                        for (var y = 0; y < height; y += 36) {
                            ctx.beginPath(); ctx.moveTo(0,y); ctx.lineTo(width,y); ctx.stroke()
                        }
                    }
                }

                Canvas {
                    anchors.fill: parent; opacity: 1
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.lineWidth = 16; ctx.lineCap = "round"; ctx.lineJoin = "round"
                        ctx.strokeStyle = "#0c1018"
                        ctx.beginPath()
                        ctx.moveTo(width*0.35, height)
                        ctx.bezierCurveTo(width*0.35, height*0.55, width*0.35, height*0.45, width*0.5, height*0.3)
                        ctx.bezierCurveTo(width*0.65, height*0.15, width*0.75, height*0.1, width*0.9, height*0.05)
                        ctx.stroke()

                        ctx.lineWidth = 10
                        ctx.strokeStyle = "#283040"
                        ctx.beginPath()
                        ctx.moveTo(width*0.35, height)
                        ctx.bezierCurveTo(width*0.35, height*0.55, width*0.35, height*0.45, width*0.5, height*0.3)
                        ctx.bezierCurveTo(width*0.65, height*0.15, width*0.75, height*0.1, width*0.9, height*0.05)
                        ctx.stroke()

                        ctx.lineWidth = 5
                        ctx.strokeStyle = "#3a7bd5"
                        ctx.beginPath()
                        ctx.moveTo(width*0.35, height)
                        ctx.bezierCurveTo(width*0.35, height*0.55, width*0.35, height*0.45, width*0.5, height*0.3)
                        ctx.bezierCurveTo(width*0.65, height*0.15, width*0.75, height*0.1, width*0.9, height*0.05)
                        ctx.stroke()

                        ctx.beginPath(); ctx.arc(width*0.35, height*0.7, 10, 0, Math.PI*2)
                        ctx.fillStyle = "#ffffff"; ctx.fill()
                        ctx.lineWidth = 3; ctx.strokeStyle = "#3a7bd5"; ctx.stroke()
                        ctx.beginPath(); ctx.arc(width*0.35, height*0.7, 4, 0, Math.PI*2)
                        ctx.fillStyle = "#3a7bd5"; ctx.fill()
                    }
                }

                Rectangle {
                    anchors.left: parent.left; anchors.leftMargin: 16
                    anchors.bottom: parent.bottom; anchors.bottomMargin: 16
                    width: 260; height: 72
                    color: "#3a7bd5"; radius: 12

                    Row {
                        anchors.left: parent.left; anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Text { text: "↰"; font.pixelSize: 32; color: "#ffffff" }

                        Column {
                            spacing: 3
                            Text { text: "500 m"; font.pixelSize: 20; font.weight: Font.Bold; color: "#ffffff" }
                            Text { text: "Turn left onto Main St."; font.pixelSize: 12; color: "#ddeeff"; font.weight: Font.Medium }
                        }
                    }
                }

                Rectangle {
                    anchors.right: parent.right; anchors.rightMargin: 16
                    anchors.top: parent.top; anchors.topMargin: 16
                    width: 130; height: 60
                    color: "#0f1118"; radius: 10
                    border.color: "#3a4a60"; border.width: 1

                    Column {
                        anchors.centerIn: parent; spacing: 4
                        Text { anchors.horizontalCenter: parent.horizontalCenter
                            text: "ETA 21:30"; font.pixelSize: 13; font.weight: Font.Bold; color: "#ffffff" }
                        Text { anchors.horizontalCenter: parent.horizontalCenter
                            text: "5.1 km · 9 min"; font.pixelSize: 11; color: "#aab8cc"; font.weight: Font.Medium }
                    }
                }
            }

            // BOTTOM ROW
            Row {
                width: parent.width; height: parent.height - 300 - 12
                spacing: 12

                // MEDIA CARD
                Rectangle {
                    width: (parent.width - 12) * 0.55; height: parent.height
                    color: "#181c26"; radius: 16
                    border.color: "#3a4a60"; border.width: 1

                    Row {
                        anchors.top: parent.top; anchors.topMargin: 18
                        anchors.left: parent.left; anchors.leftMargin: 18
                        spacing: 14

                        Rectangle {
                            width: 54; height: 54; radius: 10
                            color: "#0e1420"
                            border.color: "#3a4a60"; border.width: 1

                            Rectangle {
                                anchors.centerIn: parent
                                width: 20; height: 20; radius: 10
                                color: "#2ecc71"; opacity: 0.3
                            }
                            Text { anchors.centerIn: parent; text: "♪"; font.pixelSize: 20; color: "#2ecc71" }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 5
                            Text { text: "Starboy"; color: "#2ecc71"; font.pixelSize: 15; font.weight: Font.Bold }
                            Text { text: "The Weeknd"; color: "#b0bece"; font.pixelSize: 12; font.weight: Font.Medium }
                        }
                    }

                    Item {
                        anchors.left: parent.left; anchors.right: parent.right
                        anchors.leftMargin: 18; anchors.rightMargin: 18
                        anchors.top: parent.top; anchors.topMargin: 88
                        height: 16

                        Rectangle {
                            width: parent.width; height: 3; radius: 2; color: "#0e1420"
                            Rectangle { width: parent.width * 0.41; height: 3; radius: 2; color: "#2ecc71" }
                        }

                        Text {
                            anchors.left: parent.left; anchors.bottom: parent.top
                            text: "2:03"; font.pixelSize: 10; color: "#2ecc71"; font.weight: Font.Medium
                        }
                        Text {
                            anchors.right: parent.right; anchors.bottom: parent.top
                            text: "5:04"; font.pixelSize: 10; color: "#aab8cc"; font.weight: Font.Medium
                        }
                    }

                    Row {
                        anchors.bottom: parent.bottom; anchors.bottomMargin: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 24

                        Text { text: "⏮"; color: "#aab8cc"; font.pixelSize: 22;
                            anchors.verticalCenter: parent.verticalCenter }

                        Rectangle {
                            width: 38; height: 38; radius: 19; color: "#2ecc71"
                            Text { anchors.centerIn: parent; text: "⏸"; color: "#ffffff"; font.pixelSize: 16 }
                        }

                        Text { text: "⏭"; color: "#aab8cc"; font.pixelSize: 22;
                            anchors.verticalCenter: parent.verticalCenter }
                    }
                }

                // WEATHER CARD
                Rectangle {
                    width: (parent.width - 12) * 0.45; height: parent.height
                    radius: 16; clip: true
                    color: "#162540"
                    border.color: "#2a4870"; border.width: 1

                    Column {
                        anchors.top: parent.top; anchors.topMargin: 18
                        anchors.left: parent.left; anchors.leftMargin: 20
                        spacing: 5

                        Text { text: "Hanoi, Vietnam"; color: "#c0d8f0"; font.pixelSize: 12; font.weight: Font.Medium }
                        Text { text: "24°"; color: "#ffffff"; font.pixelSize: 48; font.weight: Font.Thin }
                        Text { text: "Partly Cloudy"; color: "#d0e4f8"; font.pixelSize: 14; font.weight: Font.Medium }
                    }

                    Column {
                        anchors.bottom: parent.bottom; anchors.bottomMargin: 16
                        anchors.left: parent.left; anchors.leftMargin: 20
                        spacing: 5

                        Row {
                            spacing: 16
                            Column {
                                spacing: 3
                                Text { text: "Humidity"; color: "#88aed0"; font.pixelSize: 10; font.weight: Font.Medium }
                                Text { text: "78%"; color: "#d0e4f8"; font.pixelSize: 13; font.weight: Font.Medium }
                            }
                            Column {
                                spacing: 3
                                Text { text: "Wind"; color: "#88aed0"; font.pixelSize: 10; font.weight: Font.Medium }
                                Text { text: "12 km/h"; color: "#d0e4f8"; font.pixelSize: 13; font.weight: Font.Medium }
                            }
                        }
                    }
                }
            }
        }
    }
}
