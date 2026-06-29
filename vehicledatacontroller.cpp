#include "vehicledatacontroller.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDateTime>
#include <QDebug>

VehicleDataController::VehicleDataController(QObject *parent)
    : QObject{parent},
    m_speed(0.0), m_rpm(1000.0),
    m_leftOn(false), m_rightOn(false), m_hazard(false),
    m_latitude(20.979269), m_longitude(105.796729),
    m_weatherTemp("--°"), m_weatherHumid("--%"),
    m_weatherWind("-- km/h"), m_weatherDesc("Updating..."),
    m_weatherCity("Hanoi, VN"),
    m_esp32Ip(""),
    m_currentSongIndex(0),
    m_totalDurationSeconds(180),
    m_mediaTitle("Loading..."), m_mediaArtist("Please wait"),
    m_mediaPosition(0.0), m_mediaPosText("00:00"), m_mediaDurText("03:00"),
    m_mediaPlaying(false), m_volume(0.7)
{
    m_networkManager = new QNetworkAccessManager(this);
    connect(m_networkManager, &QNetworkAccessManager::finished, this, &VehicleDataController::onWeatherReplyFinished);
    fetchWeatherData();
    QTimer *weatherTimer = new QTimer(this);
    connect(weatherTimer, &QTimer::timeout, this, &VehicleDataController::fetchWeatherData);
    weatherTimer->start(600000); /* Cập nhật thời tiết mỗi 10 phút */

    m_playlist.clear();
    m_playlist.append({"Come My Way",       "Son Tung MTP",    "https://KMAGooner2210.github.io/IVI_Music/ComeMyWay.mp3"});
    m_playlist.append({"Đi cùng em",        "Minh Vuong M4U",  "https://KMAGooner2210.github.io/IVI_Music/DiCungEm.mp3"});
    m_playlist.append({"Em sẽ là cô dâu",   "Minh Vuong M4U",  "https://KMAGooner2210.github.io/IVI_Music/EmSeLaCoDau.mp3"});
    m_playlist.append({"Nevada",             "Vicetone",        "https://KMAGooner2210.github.io/IVI_Music/Nevada.mp3"});
    m_playlist.append({"Hạt mưa vương vấn", "Phan Duy Anh",    "https://KMAGooner2210.github.io/IVI_Music/Hat_Mua_Vuong_Van.mp3"});

    m_udpAudioSocket = new QUdpSocket(this);

    // --- KHỞI TẠO HỆ THỐNG GIẢI MÃ NHẠC THẬT CỦA QT6 (PHÁT RA LOA BLUETOOTH) ---
    m_player = new QMediaPlayer(this);
    m_audioOutput = new QAudioOutput(this);
    m_player->setAudioOutput(m_audioOutput);
    m_audioOutput->setVolume(m_volume); // Thiết lập âm lượng khởi động (0.7)

    // Tự động đồng bộ thanh tiến trình theo bài nhạc thực tế
    connect(m_player, &QMediaPlayer::positionChanged, this, [this](qint64 position) {
        if (m_player->duration() > 0) {
            m_mediaPosition = static_cast<double>(position) / m_player->duration();
            m_mediaPosText = formatTime(position);
            emit mediaChanged();
        }
    });

    connect(m_player, &QMediaPlayer::durationChanged, this, [this](qint64 duration) {
        if (duration > 0) {
            m_totalDurationSeconds = duration / 1000;
            m_mediaDurText = formatTime(duration);
            emit mediaChanged();
        }
    });

    // Tự động chuyển bài khi kết thúc bài hát thật
    connect(m_player, &QMediaPlayer::mediaStatusChanged, this, [this](QMediaPlayer::MediaStatus status) {
        if (status == QMediaPlayer::EndOfMedia) {
            mediaNext();
        }
    });

    loadCurrentSongInfo();
}

void VehicleDataController::loadCurrentSongInfo() {
    if (m_playlist.isEmpty()) return;
    const SongData &song  = m_playlist[m_currentSongIndex];
    m_mediaTitle          = song.title;
    m_mediaArtist         = song.artist;
    m_mediaPosition       = 0.0;
    m_mediaPosText        = "00:00";
    emit mediaChanged();
}

void VehicleDataController::setEsp32Ip(const QString &ip) {
    QString cleanIp = ip;
    /* Loại bỏ prefix IPv4-mapped IPv6 (::ffff:) mà QUdpSocket trả về */
    if (cleanIp.startsWith("::ffff:")) cleanIp = cleanIp.mid(7);
    if (m_esp32Ip != cleanIp) {
        m_esp32Ip = cleanIp;
        qInfo() << "[Controller] ESP32 IP updated:" << m_esp32Ip;
    }
}

void VehicleDataController::sendAudioCommand(const QString &cmd) {
    // Không dùng lệnh này nữa vì nhạc phát trực tiếp trên Pi ra loa Bluetooth
    Q_UNUSED(cmd);
}

void VehicleDataController::mediaPlayPause() {
    if (m_mediaPlaying) {
        m_mediaPlaying = false;
        m_player->pause(); // Tạm dừng nhạc thực tế trên Pi 4
    } else {
        m_mediaPlaying = true;
        // Nếu chưa nạp nguồn nhạc hoặc đang ở đầu bài, nạp bài mới
        if (m_player->source().isEmpty() || m_player->position() == 0) {
            m_player->setSource(QUrl(m_playlist[m_currentSongIndex].mp3Url));
        }
        m_player->play(); // Phát nhạc thực tế ra loa Bluetooth
    }
    emit mediaChanged();
}

void VehicleDataController::mediaNext() {
    // --- BỘ LỌC TRỄ TRÁNH BẤM CHUYỂN BÀI LIÊN TỤC GÂY LỖI FFMPEG ---
    static qint64 lastSkipTime = 0;
    qint64 currentTime = QDateTime::currentMSecsSinceEpoch();
    if (currentTime - lastSkipTime < 800) {
        return; // Bỏ qua nếu bấm quá nhanh (dưới 800ms)
    }
    lastSkipTime = currentTime;

    m_player->stop(); // Dừng hẳn bài cũ để giải phóng bộ đệm mạng

    m_currentSongIndex++;
    if (m_currentSongIndex >= m_playlist.size()) m_currentSongIndex = 0;
    loadCurrentSongInfo();
    m_mediaPlaying = true;
    m_player->setSource(QUrl(m_playlist[m_currentSongIndex].mp3Url));
    m_player->play();
}

void VehicleDataController::mediaPrevious() {
    // --- BỘ LỌC TRỄ TRÁNH BẤM CHUYỂN BÀI LIÊN TỤC GÂY LỖI FFMPEG ---
    static qint64 lastSkipTime = 0;
    qint64 currentTime = QDateTime::currentMSecsSinceEpoch();
    if (currentTime - lastSkipTime < 800) {
        return;
    }
    lastSkipTime = currentTime;

    m_player->stop(); // Dừng hẳn bài cũ để giải phóng bộ đệm mạng

    m_currentSongIndex--;
    if (m_currentSongIndex < 0) m_currentSongIndex = m_playlist.size() - 1;
    loadCurrentSongInfo();
    m_mediaPlaying = true;
    m_player->setSource(QUrl(m_playlist[m_currentSongIndex].mp3Url));
    m_player->play();
}

QString VehicleDataController::formatTime(qint64 milliseconds) {
    int seconds = (milliseconds / 1000) % 60;
    int minutes = (milliseconds / (1000 * 60)) % 60;
    return QString::asprintf("%02d:%02d", minutes, seconds);
}

void VehicleDataController::setVolume(double vol) {
    double bounded = qBound(0.0, vol, 1.0);
    if (!qFuzzyCompare(m_volume, bounded)) {
        m_volume = bounded;
        m_audioOutput->setVolume(m_volume); // Cập nhật âm lượng trực tiếp của hệ thống loa Bluetooth
        emit volumeChanged();
    }
}

void VehicleDataController::volumeUp()   { setVolume(m_volume + 0.1); }
void VehicleDataController::volumeDown() { setVolume(m_volume - 0.1); }

void VehicleDataController::fetchWeatherData() {
    const QString apiKey = "fc9a4092f7fc9aa1a4eac796b3cf2507";
    const QString url    = QString("http://api.openweathermap.org/data/2.5/weather"
                                "?q=Hanoi,vn&appid=%1&units=metric&lang=en")
                            .arg(apiKey);
    m_networkManager->get(QNetworkRequest(QUrl(url)));
}

void VehicleDataController::onWeatherReplyFinished(QNetworkReply *reply) {
    if (reply->error() == QNetworkReply::NoError) {
        QJsonDocument jsonDoc = QJsonDocument::fromJson(reply->readAll());
        QJsonObject   jsonObj = jsonDoc.object();

        m_weatherTemp  = QString::number(
                            qRound(jsonObj["main"].toObject()["temp"].toDouble())) + "°";
        m_weatherHumid = QString::number(
                             jsonObj["main"].toObject()["humidity"].toInt()) + "%";
        m_weatherWind  = QString::number(
                            qRound(jsonObj["wind"].toObject()["speed"].toDouble() * 3.6))
                        + " km/h";

        QJsonArray weatherArray = jsonObj["weather"].toArray();
        if (!weatherArray.isEmpty()) {
            m_weatherDesc = weatherArray[0].toObject()["main"].toString();
        }
        m_weatherCity = jsonObj["name"].toString() + ", "
                        + jsonObj["sys"].toObject()["country"].toString();
        emit weatherChanged();
    } else {
        qWarning() << "[Weather] API error:" << reply->errorString();
    }
    reply->deleteLater();
}

void VehicleDataController::setSpeed(double v) {
    if (!qFuzzyCompare(m_speed + 1.0, v + 1.0)) {
        m_speed = v;
        emit speedChanged();
    }
}

void VehicleDataController::setRpm(double v) {
    if (!qFuzzyCompare(m_rpm + 1.0, v + 1.0)) {
        m_rpm = v;
        emit rpmChanged();
    }
}

void VehicleDataController::setLeftOn(bool v) {
    if (m_leftOn  != v) { m_leftOn  = v; emit leftOnChanged();  }
}
void VehicleDataController::setRightOn(bool v) {
    if (m_rightOn != v) { m_rightOn = v; emit rightOnChanged(); }
}
void VehicleDataController::setHazard(bool v) {
    if (m_hazard  != v) { m_hazard  = v; emit hazardChanged();  }
}
void VehicleDataController::setLatitude(double lat) {
    if (!qFuzzyCompare(m_latitude + 1.0, lat + 1.0)) {
        m_latitude = lat; emit latitudeChanged();
    }
}
void VehicleDataController::setLongitude(double lng) {
    if (!qFuzzyCompare(m_longitude + 1.0, lng + 1.0)) {
        m_longitude = lng; emit longitudeChanged();
    }
}
