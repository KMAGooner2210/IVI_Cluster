import QtQuick
import QtQuick.Controls
import QtPositioning
import QtLocation

Window {
    id: rootWindow
    width: 1024
    height: 600
    visible: true

    // TẠM THỜI TẮT FULLSCREEN TRÊN LAPTOP ĐỂ HIỂN THỊ ĐÚNG CỬA SỔ 1024x600 CHUẨN WAVESHARE 7-INCH
    // (Khi nào bạn nạp lên Raspberry Pi cắm màn thật thì xóa dấu // ở đầu dòng dưới đi nhé)
    // visibility: Window.FullScreen

    title: "MT Dashboard"
    color: "#13151a"

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

    // =======================================================
    // 1. THANH TRẠNG THÁI TRÊN CÙNG (TOP BAR)
    // =======================================================
    Item {
        id: topBar
        width: parent.width; height: 48
        anchors.top: parent.top

        // Trái: Giờ + Ngày tháng năm thực tế
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
                font.pixelSize: 13; color: "#A0AEC0" // Đã làm sáng
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Giữa: Logo thương hiệu của bạn
        Text {
            anchors.centerIn: parent
            text: "KMAGOONER"
            font.pixelSize: 16; font.weight: Font.Bold
            font.letterSpacing: 8
            color: "#1e3a5a"
        }

        // Phải: Các biểu tượng trạng thái kết nối
        Row {
            anchors.right: parent.right; anchors.rightMargin: 24
            anchors.verticalCenter: parent.verticalCenter
            spacing: 20

            Text { text: "BT"; font.pixelSize: 13; color: "#A0AEC0"; font.weight: Font.Bold } // Đã làm sáng
            Text { text: "LTE"; font.pixelSize: 13; color: "#3a7bd5"; font.weight: Font.Bold }
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
                Text { text: "85%"; font.pixelSize: 13; color: "#2ecc71"; font.weight: Font.Bold }
            }
        }

        // Đường kẻ ngang mỏng phân cách topBar
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width; height: 1
            color: "#1a1e26"
        }
    }

    // =======================================================
    // 2. TOÀN BỘ KHU VỰC NỘI DUNG CHÍNH (MAIN CONTENT)
    // =======================================================
    Item {
        anchors.top: topBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 16
        anchors.topMargin: 12

        // ---------------------------------------------------
        // CỘT BÊN TRÁI: THÔNG TIN XE & ĐỒNG HỒ TỐC ĐỘ (300px)
        // ---------------------------------------------------
        Column {
            id: leftCol
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 300
            spacing: 12

            // THẺ 1: HÌNH ẢNH XE VINFAST VF8 & THÔNG SỐ PIN
            Rectangle {
                width: parent.width; height: 240
                color: "#1a1e28"
                radius: 16
                border.color: "#22283a"; border.width: 1

                // Ánh sáng xanh dương dưới gầm xe cực ảo
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom; anchors.bottomMargin: 42
                    width: 180; height: 20; radius: 100
                    color: "#3a7bd5"; opacity: 0.12
                }

                // Hình ảnh chiếc xe VF8 đã sửa lỗi tràn viền bánh xe
                Image {
                    anchors.top: parent.top; anchors.topMargin: 15
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - 40 // Căn lề rộng rãi sang 2 bên để không chạm bánh xe vào viền
                    height: 130             // Đưa chiều cao về 130px cực kỳ gọn gàng cân đối
                    fillMode: Image.PreserveAspectFit
                    source: "qrc:/ClusterClient/assets/VF8.png"
                    antialiasing: true; smooth: true

                    // Hiệu ứng xe tự động nhấp nhô nhẹ nhàng như đang nổ máy
                    SequentialAnimation on anchors.topMargin {
                        loops: Animation.Infinite
                        NumberAnimation { to: 18; duration: 2200; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 15; duration: 2200; easing.type: Easing.InOutSine }
                    }
                }

                // Thông số kỹ thuật dưới gầm xe (Đã làm sáng rực rỡ)
                Row {
                    anchors.bottom: parent.bottom; anchors.bottomMargin: 14
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 20

                    Column {
                        spacing: 2
                        Text { text: "340 km"; color: "#ffffff"; font.pixelSize: 16; font.weight: Font.Bold }
                        Text { text: "Range"; color: "#A0AEC0"; font.pixelSize: 11; font.weight: Font.Medium }
                    }

                    Rectangle { width: 1; height: 28; color: "#22283a" }

                    Column {
                        spacing: 2
                        Text { text: "15.2"; color: "#3a7bd5"; font.pixelSize: 16; font.weight: Font.Bold }
                        Text { text: "kWh/100km"; color: "#A0AEC0"; font.pixelSize: 11; font.weight: Font.Medium }
                    }

                    Rectangle { width: 1; height: 28; color: "#22283a" }

                    Column {
                        spacing: 2
                        Text { text: "85%"; color: "#2ecc71"; font.pixelSize: 16; font.weight: Font.Bold }
                        Text { text: "Battery"; color: "#A0AEC0"; font.pixelSize: 11; font.weight: Font.Medium }
                    }
                }
            }

            // THẺ 2: ĐỒNG HỒ TỐC ĐỘ, XI NHAN VÀ PHÂN SỐ P-R-N-D
            Rectangle {
                width: parent.width
                height: parent.height - 240 - 12
                color: "#1a1e28"
                radius: 16
                border.color: "#22283a"; border.width: 1

                // Đèn xi nhan chớp tắt và cảnh báo tam giác nguy hiểm
                Row {
                    anchors.top: parent.top; anchors.topMargin: 14
                    anchors.left: parent.left; anchors.leftMargin: 18
                    anchors.right: parent.right; anchors.rightMargin: 18
                    spacing: 0

                    Text {
                        text: "SPEED"
                        font.pixelSize: 11; font.letterSpacing: 3
                        color: "#A0AEC0" // Đã làm sáng nhãn phụ
                    }

                    Item { width: parent.width - 60 - 80; height: 1 }

                    Row {
                        spacing: 12
                        // Đèn xi nhan TRÁI (Vẽ bằng Canvas sắc nét)
                        Canvas {
                            id: leftSignalCanvas // Đã thêm ID để chống lỗi 'parent is not defined'
                            width: 18; height: 14
                            opacity: vehicleData.leftOn ? 1.0 : 0.25 // Tăng độ sáng lúc tắt
                            onPaint: {
                                var c = getContext("2d"); c.clearRect(0,0,width,height);
                                c.fillStyle = vehicleData.leftOn ? "#2ecc71" : "#4A5568"; // Đổi màu xám bạc
                                c.beginPath(); c.moveTo(18,4); c.lineTo(7,4); c.lineTo(7,0);
                                c.lineTo(0,7); c.lineTo(7,14); c.lineTo(7,10); c.lineTo(18,10);
                                c.closePath(); c.fill();
                            }
                            SequentialAnimation on opacity {
                                running: vehicleData.leftOn; loops: Animation.Infinite
                                NumberAnimation { to: 0.15; duration: 380 }
                                NumberAnimation { to: 1.0; duration: 380 }
                            }
                            Connections { target: vehicleData
                                function onLeftOnChanged() { leftSignalCanvas.requestPaint() } } // Sửa lỗi
                        }

                        // Đèn cảnh báo tam giác nguy hiểm
                        Text {
                            text: "⚠"; font.pixelSize: 14
                            color: vehicleData.hazard ? "#e67e22" : "#4A5568" // Làm sáng lúc tắt
                            SequentialAnimation on opacity {
                                running: vehicleData.hazard; loops: Animation.Infinite
                                NumberAnimation { to: 0.15; duration: 300 }
                                NumberAnimation { to: 1.0; duration: 300 }
                            }
                        }

                        // Đèn xi nhan PHẢI (Vẽ bằng Canvas sắc nét)
                        Canvas {
                            id: rightSignalCanvas // Đã thêm ID để chống lỗi 'parent is not defined'
                            width: 18; height: 14
                            opacity: vehicleData.rightOn ? 1.0 : 0.25 // Tăng độ sáng lúc tắt
                            onPaint: {
                                var c = getContext("2d"); c.clearRect(0,0,width,height);
                                c.fillStyle = vehicleData.rightOn ? "#2ecc71" : "#4A5568";
                                c.beginPath(); c.moveTo(0,4); c.lineTo(11,4); c.lineTo(11,0);
                                c.lineTo(18,7); c.lineTo(11,14); c.lineTo(11,10); c.lineTo(0,10);
                                c.closePath(); c.fill();
                            }
                            SequentialAnimation on opacity {
                                running: vehicleData.rightOn; loops: Animation.Infinite
                                NumberAnimation { to: 0.15; duration: 380 }
                                NumberAnimation { to: 1.0; duration: 380 }
                            }
                            Connections { target: vehicleData
                                function onRightOnChanged() { rightSignalCanvas.requestPaint() } } // Sửa lỗi
                        }
                    }
                }

                // Chữ số vận tốc khổng lồ mượt mà (Antialiasing cao)
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
                    color: "#A0AEC0" // Đã làm sáng nhãn phụ
                }

                // Thanh dải màu Vòng tua máy (RPM Bar)
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
                        font.pixelSize: 11; color: "#A0AEC0" // Đã làm sáng cực kỳ sắc nét
                        font.weight: Font.Medium
                    }
                }

                // Cụm phím chuyển số P-R-N-D dạng thuốc nhộng (Pill capsule)
                Rectangle {
                    anchors.bottom: parent.bottom; anchors.bottomMargin: 14
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 220; height: 36; radius: 18
                    color: "#13151a"

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
                                    color: currentGear === modelData ? "#ffffff" : "#4A5568" // Làm sáng chữ xám lúc tắt
                                }
                            }
                        }
                    }
                }
            }
        }

        // ==========================================
        // CỘT BÊN PHẢI: MAP 3D VÀ CÁC WIDGETS PHỤ
        // ==========================================
        Column {
            anchors.left: leftCol.right; anchors.leftMargin: 12
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            spacing: 12

            // THẺ 3: BẢN ĐỒ THỰC TẾ 3D ANGLE (MANG TỌA ĐỘ TỪ GPS)
            Rectangle {
                width: parent.width; height: 300
                color: "#1a1e28"
                radius: 16
                border.color: "#22283a"; border.width: 1
                clip: true

                Map {
                    id: mainMap
                    anchors.fill: parent
                    anchors.margins: 1

                    // KẾT NỐI TRỰC TIẾP VỚI SERVER OPENSTREETMAP CHÍNH CHỦ
                    // Xóa sổ hoàn toàn chữ watermark "API Key Required" khó chịu
                    plugin: Plugin {
                        name: "osm"
                        PluginParameter {
                            name: "osm.mapping.custom.host"
                            value: "https://tile.openstreetmap.org/"
                        }
                    }

                    center: QtPositioning.coordinate(vehicleData.latitude, vehicleData.longitude)
                    zoomLevel: 17
                    tilt: 45 // Độ nghiêng 3D Tesla style cực đẹp

                    // Tự động chọn bản đồ custom sạch sẽ vừa tạo ở trên
                    activeMapType: supportedMapTypes[supportedMapTypes.length - 1]

                    // Điểm tròn định vị xe chạy trên bản đồ thực tế
                    MapQuickItem {
                        coordinate: QtPositioning.coordinate(vehicleData.latitude, vehicleData.longitude)
                        anchorPoint.x: carDot.width / 2
                        anchorPoint.y: carDot.height / 2

                        sourceItem: Rectangle {
                            id: carDot
                            width: 20; height: 24; radius: 12
                            color: "#ffffff"
                            border.color: "#3a7bd5"; border.width: 4

                            // Sóng radar xanh lam nhấp nháy phát sóng
                            Rectangle {
                                anchors.centerIn: parent
                                width: 40; height: 40; radius: 20
                                color: "transparent"
                                border.color: "#3a7bd5"; border.width: 2
                                opacity: 0.5; scale: 1.0

                                SequentialAnimation on scale {
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 1.8; duration: 1500 }
                                }
                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 0.0; duration: 1500 }
                                }
                            }
                        }
                    }
                }

                // Hộp ETA thời gian đến dự kiến đè lên góc phải bản đồ (Đã làm sáng chữ phụ)
                Rectangle {
                    anchors.right: parent.right; anchors.rightMargin: 16
                    anchors.top: parent.top; anchors.topMargin: 16
                    width: 130; height: 60
                    color: "#13151a"; radius: 10
                    border.color: "#22283a"; border.width: 1
                    z: 99

                    Column {
                        anchors.centerIn: parent; spacing: 2
                        Text { anchors.horizontalCenter: parent.horizontalCenter
                            text: "ETA 21:30"; font.pixelSize: 13; font.weight: Font.Bold; color: "#ffffff" }
                        Text { anchors.horizontalCenter: parent.horizontalCenter
                            text: "5.1 km · 9 min"; font.pixelSize: 11; color: "#A0AEC0"; font.weight: Font.Medium }
                    }
                }
            }

            // HÀNG DƯỚI CÙNG: MEDIA PLAYER & THỜI TIẾT
            Row {
                width: parent.width; height: parent.height - 300 - 12
                spacing: 12

                // MEDIA CARD (ĐÃ NÂNG CẤP TRÌNH PHÁT NHẠC THẬT ONLINE STREAMING)
                                Rectangle {
                                    width: (parent.width - 12) * 0.55; height: parent.height
                                    color: "#1a1e28"; radius: 16
                                    border.color: "#22283a"; border.width: 1

                                    Row {
                                        anchors.top: parent.top; anchors.topMargin: 18
                                        anchors.left: parent.left; anchors.leftMargin: 18
                                        spacing: 14

                                        // Ảnh bìa đĩa nhạc quay quay hoặc nhấp nháy phát sáng nếu đang hát
                                        Rectangle {
                                            width: 54; height: 54; radius: 10
                                            color: "#0e1420"
                                            border.color: "#22283a"; border.width: 1

                                            Rectangle {
                                                anchors.centerIn: parent
                                                width: 20; height: 20; radius: 10
                                                color: "#2ecc71"
                                                opacity: vehicleData.mediaPlaying ? 0.4 : 0.1 // Sáng rực rỡ hơn khi đang phát nhạc
                                            }
                                            Text {
                                                anchors.centerIn: parent; text: "♪"; font.pixelSize: 20
                                                color: vehicleData.mediaPlaying ? "#2ecc71" : "#405060"
                                            }
                                        }

                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 4
                                            // Tên bài hát thật từ C++
                                            Text { text: vehicleData.mediaTitle; color: "#2ecc71"; font.pixelSize: 15; font.weight: Font.Bold }
                                            // Tên ca sĩ thật từ C++
                                            Text { text: vehicleData.mediaArtist; color: "#A0AEC0"; font.pixelSize: 12; font.weight: Font.Medium }
                                        }
                                    }

                                    // Thanh tiến trình chạy nhạc động
                                    Item {
                                        anchors.left: parent.left; anchors.right: parent.right
                                        anchors.leftMargin: 18; anchors.rightMargin: 18
                                        anchors.top: parent.top; anchors.topMargin: 88
                                        height: 16

                                        Rectangle {
                                            width: parent.width; height: 3; radius: 2; color: "#0e1420"
                                            // Thanh xanh lá chạy dài ra theo thời gian bài hát thực tế
                                            Rectangle {
                                                width: parent.width * vehicleData.mediaPosition;
                                                height: 3; radius: 2; color: "#2ecc71"
                                            }
                                        }

                                        // Giờ chạy nhạc thực tế (ví dụ: "02:03")
                                        Text {
                                            anchors.left: parent.left; anchors.bottom: parent.top
                                            text: vehicleData.mediaPosText; font.pixelSize: 10; color: "#2ecc71"; font.weight: Font.Bold
                                        }
                                        // Tổng thời lượng bài hát thực tế (ví dụ: "05:04")
                                        Text {
                                            anchors.right: parent.right; anchors.bottom: parent.top
                                            text: vehicleData.mediaDurText; font.pixelSize: 10; color: "#A0AEC0"; font.weight: Font.Bold
                                        }
                                    }

                                    // Các nút điều khiển nhạc & Tăng giảm âm lượng THIẾT KẾ PHẲNG PREMIUM (Đã nâng cấp)
                                                                        Row {
                                                                            anchors.bottom: parent.bottom; anchors.bottomMargin: 16
                                                                            anchors.horizontalCenter: parent.horizontalCenter
                                                                            spacing: 16 // Khoảng cách thiết kế gọn gàng hơn

                                                                            // Nút Previous (Lùi bài)
                                                                            Text {
                                                                                text: "⏮"; color: "#A0AEC0"; font.pixelSize: 22;
                                                                                anchors.verticalCenter: parent.verticalCenter
                                                                                MouseArea {
                                                                                    anchors.fill: parent
                                                                                    onClicked: vehicleData.mediaPrevious()
                                                                                }
                                                                            }

                                                                            // Nút Play / Pause
                                                                            Rectangle {
                                                                                width: 38; height: 38; radius: 19; color: "#2ecc71"
                                                                                Text {
                                                                                    anchors.centerIn: parent
                                                                                    text: vehicleData.mediaPlaying ? "⏸" : "▶"
                                                                                    color: "#ffffff"; font.pixelSize: 16
                                                                                }
                                                                                MouseArea {
                                                                                    anchors.fill: parent
                                                                                    onClicked: vehicleData.mediaPlayPause()
                                                                                }
                                                                            }

                                                                            // Nút Next (Qua bài)
                                                                            Text {
                                                                                text: "⏭"; color: "#A0AEC0"; font.pixelSize: 22;
                                                                                anchors.verticalCenter: parent.verticalCenter
                                                                                MouseArea {
                                                                                    anchors.fill: parent
                                                                                    onClicked: vehicleData.mediaNext()
                                                                                }
                                                                            }

                                                                            // VẠCH PHÂN CÁCH ĐẸP MẮT (GIỮA NHẠC VÀ ÂM LƯỢNG)
                                                                            Rectangle {
                                                                                width: 1; height: 20
                                                                                color: "#22283a"
                                                                                anchors.verticalCenter: parent.verticalCenter
                                                                            }

                                                                            // NÚT GIẢM ÂM LƯỢNG 🔉 (Vẽ bằng Canvas phẳng nét mảnh)
                                                                            Canvas {
                                                                                id: volDownBtn
                                                                                width: 22; height: 22
                                                                                anchors.verticalCenter: parent.verticalCenter
                                                                                opacity: 0.7
                                                                                onPaint: {
                                                                                    var ctx = getContext("2d"); ctx.clearRect(0,0,width,height);
                                                                                    ctx.fillStyle = "#A0AEC0"; ctx.beginPath();
                                                                                    ctx.rect(2, 7, 5, 8); // Thân loa
                                                                                    ctx.moveTo(7, 7); ctx.lineTo(13, 2); ctx.lineTo(13, 20); ctx.lineTo(7, 15);
                                                                                    ctx.closePath(); ctx.fill();
                                                                                    // Dấu trừ (-) báo hiệu giảm âm lượng
                                                                                    ctx.strokeStyle = "#A0AEC0"; ctx.lineWidth = 1.5;
                                                                                    ctx.beginPath(); ctx.moveTo(17, 11); ctx.lineTo(21, 11); ctx.stroke();
                                                                                }
                                                                                MouseArea { anchors.fill: parent; onClicked: vehicleData.volumeDown() }
                                                                            }

                                                                            // THANH ÂM LƯỢNG THU NHỎ (MINI VOLUME BAR - SIÊU SANG)
                                                                            Item {
                                                                                width: 60; height: 16
                                                                                anchors.verticalCenter: parent.verticalCenter

                                                                                Rectangle {
                                                                                    id: volBg
                                                                                    width: parent.width; height: 3; radius: 2; color: "#0e1420"
                                                                                    anchors.verticalCenter: parent.verticalCenter

                                                                                    // Thanh màu xanh lá tự co giãn theo mức âm lượng thật
                                                                                    Rectangle {
                                                                                        width: parent.width * vehicleData.volume
                                                                                        height: parent.height; radius: 2; color: "#2ecc71"
                                                                                    }
                                                                                }
                                                                            }

                                                                            // NÚT TĂNG ÂM LƯỢNG 🔊 (Vẽ bằng Canvas phẳng nét mảnh)
                                                                            Canvas {
                                                                                id: volUpBtn
                                                                                width: 22; height: 22
                                                                                anchors.verticalCenter: parent.verticalCenter
                                                                                opacity: 0.7
                                                                                onPaint: {
                                                                                    var ctx = getContext("2d"); ctx.clearRect(0,0,width,height);
                                                                                    ctx.fillStyle = "#A0AEC0"; ctx.beginPath();
                                                                                    ctx.rect(2, 7, 5, 8);
                                                                                    ctx.moveTo(7, 7); ctx.lineTo(13, 2); ctx.lineTo(13, 20); ctx.lineTo(7, 15);
                                                                                    ctx.closePath(); ctx.fill();
                                                                                    // Dấu cộng (+) báo hiệu tăng âm lượng
                                                                                    ctx.strokeStyle = "#A0AEC0"; ctx.lineWidth = 1.5;
                                                                                    ctx.beginPath();
                                                                                    ctx.moveTo(16, 11); ctx.lineTo(20, 11);
                                                                                    ctx.moveTo(18, 9);  ctx.lineTo(18, 13);
                                                                                    ctx.stroke();
                                                                                }
                                                                                MouseArea { anchors.fill: parent; onClicked: vehicleData.volumeUp() }
                                                                            }
                                                                        }
                                                                    } // Đóng thẻ Rectangle của Media Card

                // THẺ 5: THỜI TIẾT ĐỒ HỌA GRADIENT (Đã làm sáng toàn bộ chữ phụ, đồng bộ thời tiết Internet)
                Rectangle {
                    width: (parent.width - 12) * 0.45; height: parent.height
                    radius: 16; clip: true
                    color: "#1e3a5a"
                    border.color: "#22283a"; border.width: 1

                    Column {
                        anchors.top: parent.top; anchors.topMargin: 18
                        anchors.left: parent.left; anchors.leftMargin: 20
                        spacing: 4

                        // Tên thành phố thật từ C++
                        Text { text: vehicleData.weatherCity; color: "#e2e8f0"; font.pixelSize: 12; font.weight: Font.Medium }

                        // Nhiệt độ thật từ C++
                        Text { text: vehicleData.weatherTemp; color: "#ffffff"; font.pixelSize: 48; font.weight: Font.Thin }

                        // Trạng thái mây/mưa từ C++
                        Text { text: vehicleData.weatherDesc; color: "#e2e8f0"; font.pixelSize: 14; font.weight: Font.Medium }
                    }

                    Column {
                        anchors.bottom: parent.bottom; anchors.bottomMargin: 16
                        anchors.left: parent.left; anchors.leftMargin: 20
                        spacing: 4

                        Row {
                            spacing: 16
                            Column {
                                Text { text: "Humidity"; color: "#92a6c0"; font.pixelSize: 10; font.weight: Font.Bold }
                                // Độ ẩm thật từ C++
                                Text { text: vehicleData.weatherHumid; color: "#ffffff"; font.pixelSize: 13; font.weight: Font.Bold }
                            }
                            Column {
                                Text { text: "Wind"; color: "#92a6c0"; font.pixelSize: 10; font.weight: Font.Bold }
                                // Tốc độ gió thật từ C++
                                Text { text: vehicleData.weatherWind; color: "#ffffff"; font.pixelSize: 13; font.weight: Font.Bold }
                            }
                        }
                    }
                }
            }
        }
    }
}
