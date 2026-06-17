                #include "vehicledatacontroller.h"
                #include <QJsonDocument>
                #include <QJsonObject>
                #include <QJsonArray>
                #include <QTimer>
                #include <QDebug>
                
                VehicleDataController::VehicleDataController(QObject *parent)
                    : QObject{parent},
                    m_speed(0.0),
                    m_rpm(1000.0),
                    m_leftOn(false),
                    m_rightOn(false),
                    m_hazard(false),
                    m_latitude(20.979269),
                    m_longitude(105.796729),
                
                    // Khởi tạo thời tiết
                    m_weatherTemp("--°"), m_weatherHumid("--%"), m_weatherWind("-- km/h"),
                    m_weatherDesc("Updating..."), m_weatherCity("Hanoi, VN"),
                
                    // Khởi tạo trình phát nhạc mặc định
                    m_currentSongIndex(0),
                    m_mediaTitle("Loading..."),
                    m_mediaArtist("Please wait"),
                    m_mediaPosition(0.0),
                    m_mediaPosText("0:00"),
                    m_mediaDurText("0:00"),
                    m_mediaPlaying(false)
                {
                    // 1. KHỞI TẠO BỘ LẤY THỜI TIẾT
                    m_networkManager = new QNetworkAccessManager(this);
                    connect(m_networkManager, &QNetworkAccessManager::finished, this, &VehicleDataController::onWeatherReplyFinished);
                    fetchWeatherData();
                    QTimer *weatherTimer = new QTimer(this);
                    connect(weatherTimer, &QTimer::timeout, this, &VehicleDataController::fetchWeatherData);
                    weatherTimer->start(600000);
                
                    // 2. TẠO PLAYLIST NHẠC CHẤT LƯỢNG CAO TRỰC TUYẾN (ONLINE STREAMING)
                
                
                    m_playlist.clear(); // Xóa sạch danh sách cũ (nếu có)
                
                    // Hãy thay thế bằng Tên bài, Tên ca sĩ, Tên Github và Tên file .mp3 thật của bạn:
                    m_playlist.append({"Come My Way", "Son Tung MTP", "https://KMAGooner2210.github.io/IVI_Music/ComeMyWay.mp3"});
                    m_playlist.append({"Đi cùng em", "Minh Vuong M4U", "https://KMAGooner2210.github.io/IVI_Music/DiCungEm.mp3"});
                    m_playlist.append({"Em sẽ là cô dâu", "Minh vuong M4U", "https://KMAGooner2210.github.io/IVI_Music/EmSeLaCoDau.mp3"});
                    m_playlist.append({"Nevada", "Vicetone", "https://KMAGooner2210.github.io/IVI_Music/Nevada.mp3"});
                    m_playlist.append({"Hạt mưa vương vấn", "Phan Duy Anh", "https://KMAGooner2210.github.io/IVI_Music/Hat_Mua_Vuong_Van.mp3"});
                    m_playlist.append({"Hẹn hò nhưng không yêu", "Wendy Thảo", "https://KMAGooner2210.github.io/IVI_Music/Hen_Ho_Nhung_Khong_Yeu.mp3"});
                    m_playlist.append({"Mất kết nối", "Dương Dominic", "https://KMAGooner2210.github.io/IVI_Music/Mat_Ket_Noi.mp3"});
                    m_playlist.append({"Phim ba người", "Nguyễn Vĩ", "https://KMAGooner2210.github.io/IVI_Music/Phim_Ba_Nguoi.mp3"});
                    // 3. KHỞI TẠO TRÌNH PHÁT NHẠC QUẬT LÊN LOA (MẶC ĐỊNH BẮT BUỘC TRÊN QT 6)
                    m_audioOutput = new QAudioOutput(this);
                    m_player = new QMediaPlayer(this);
                    m_player->setAudioOutput(m_audioOutput);
                    m_audioOutput->setVolume(0.7); // Cài âm lượng mặc định 70%
                
                    // Kết nối các tín hiệu đồng bộ thời gian từ bài hát
                    connect(m_player, &QMediaPlayer::positionChanged, this, &VehicleDataController::onPlayerPositionChanged);
                    connect(m_player, &QMediaPlayer::durationChanged, this, &VehicleDataController::onPlayerDurationChanged);
                    connect(m_player, &QMediaPlayer::playbackStateChanged, this, &VehicleDataController::onPlayerStateChanged);
                
                    // Chuẩn bị bài hát đầu tiên
                    playCurrentSong();
                }
                
                // --- THUẬT TOÁN ĐIỀU KHIỂN NHẠC ---
                void VehicleDataController::playCurrentSong() {
                    if (m_playlist.isEmpty()) return;
                
                    SongData song = m_playlist[m_currentSongIndex];
                    m_mediaTitle = song.title;
                    m_mediaArtist = song.artist;
                    emit mediaChanged();
                
                    // Ép QMediaPlayer truyền phát trực tuyến (Stream) từ đường link internet
                    m_player->setSource(QUrl(song.mp3Url));
                
                    if (m_mediaPlaying) {
                        m_player->play();
                    }
                }
                
                void VehicleDataController::mediaPlayPause() {
                    if (m_player->playbackState() == QMediaPlayer::PlayingState) {
                        m_player->pause();
                        m_mediaPlaying = false;
                    } else {
                        m_player->play();
                        m_mediaPlaying = true;
                    }
                    emit mediaChanged();
                }
                
                void VehicleDataController::mediaNext() {
                    m_currentSongIndex++;
                    if (m_currentSongIndex >= m_playlist.size()) {
                        m_currentSongIndex = 0; // Quay lại bài đầu
                    }
                    playCurrentSong();
                    if (m_mediaPlaying) m_player->play();
                }
                
                void VehicleDataController::mediaPrevious() {
                    m_currentSongIndex--;
                    if (m_currentSongIndex < 0) {
                        m_currentSongIndex = m_playlist.size() - 1; // Quay lại bài cuối
                    }
                    playCurrentSong();
                    if (m_mediaPlaying) m_player->play();
                }
                
                // Đồng bộ vị trí chạy của bài hát (để chạy thanh progress bar)
                void VehicleDataController::onPlayerPositionChanged(qint64 position) {
                    qint64 duration = m_player->duration();
                    if (duration > 0) {
                        m_mediaPosition = static_cast<double>(position) / duration;
                    } else {
                        m_mediaPosition = 0.0;
                    }
                    m_mediaPosText = formatTime(position);
                    emit mediaChanged();
                }
                
                // Đồng bộ tổng thời gian của bài hát
                void VehicleDataController::onPlayerDurationChanged(qint64 duration) {
                    m_mediaDurText = formatTime(duration);
                    emit mediaChanged();
                }
                
                void VehicleDataController::onPlayerStateChanged(QMediaPlayer::PlaybackState state) {
                    m_mediaPlaying = (state == QMediaPlayer::PlayingState);
                    emit mediaChanged();
                }
                
                // Định dạng thời gian từ mili giây sang dạng "Phút:Giây" (Ví dụ: "02:03")
                QString VehicleDataController::formatTime(qint64 milliseconds) {
                    int seconds = (milliseconds / 1000) % 60;
                    int minutes = (milliseconds / (1000 * 60)) % 60;
                    return QString::asprintf("%02d:%02d", minutes, seconds);
                }
                
                // --- THỜI TIẾT ---
                void VehicleDataController::fetchWeatherData() {
                    QString apiKey = "fc9a4092f7fc9aa1a4eac796b3cf2507"; // Dùng khóa demo đang hoạt động
                    QString url = QString("http://api.openweathermap.org/data/2.5/weather?q=Hanoi,vn&appid=%1&units=metric&lang=en").arg(apiKey);
                    m_networkManager->get(QNetworkRequest(QUrl(url)));
                }
                
                void VehicleDataController::onWeatherReplyFinished(QNetworkReply *reply) {
                    if (reply->error() == QNetworkReply::NoError) {
                        QByteArray responseData = reply->readAll();
                        QJsonDocument jsonDoc = QJsonDocument::fromJson(responseData);
                        QJsonObject jsonObj = jsonDoc.object();
                        double temp = jsonObj["main"].toObject()["temp"].toDouble();
                        m_weatherTemp = QString::number(qRound(temp)) + "°";
                        int humid = jsonObj["main"].toObject()["humidity"].toInt();
                        m_weatherHumid = QString::number(humid) + "%";
                        double windSpeedMs = jsonObj["wind"].toObject()["speed"].toDouble();
                        double windSpeedKmh = windSpeedMs * 3.6;
                        m_weatherWind = QString::number(qRound(windSpeedKmh)) + " km/h";
                        QJsonArray weatherArray = jsonObj["weather"].toArray();
                        if (!weatherArray.isEmpty()) { m_weatherDesc = weatherArray[0].toObject()["main"].toString(); }
                        m_weatherCity = jsonObj["name"].toString() + ", " + jsonObj["sys"].toObject()["country"].toString();
                        emit weatherChanged();
                    }
                    reply->deleteLater();
                }
                
                
                void VehicleDataController::setSpeed(double v) {
                    if (m_speed != v) { m_speed = v; emit speedChanged(); if (v < 1) setRpm(1000.0); else setRpm(1000.0 + (v * 25.0)); }
                }
                
                
                
                double VehicleDataController::volume() const {
                    return m_audioOutput ? m_audioOutput->volume() : 0.0;
                }
                
                
                void VehicleDataController::setVolume(double vol) {
                    if (m_audioOutput) {
                        // qBound giúp giới hạn âm lượng không vượt quá 1.0 (100%) và không dưới 0.0 (0%)
                        double boundedVol = qBound(0.0, vol, 1.0);
                        m_audioOutput->setVolume(boundedVol);
                        emit volumeChanged();
                        qDebug() << "Am luong loa thuc te:" << qRound(boundedVol * 100) << "%";
                    }
                }
                
                
                void VehicleDataController::volumeUp() {
                    setVolume(volume() + 0.1);
                }
                
                
                void VehicleDataController::volumeDown() {
                    setVolume(volume() - 0.1);
                }
                
                void VehicleDataController::setRpm(double v) { if (m_rpm != v) { m_rpm = v; emit rpmChanged(); } }
                void VehicleDataController::setLeftOn(bool v) { if (m_leftOn != v) { m_leftOn = v; emit leftOnChanged(); } }
                void VehicleDataController::setRightOn(bool v) { if (m_rightOn != v) { m_rightOn = v; emit rightOnChanged(); } }
                void VehicleDataController::setHazard(bool v) { if (m_hazard != v) { m_hazard = v; emit hazardChanged(); } }
                void VehicleDataController::setLatitude(double lat) { if (m_latitude != lat) { m_latitude = lat; emit latitudeChanged(); } }
                void VehicleDataController::setLongitude(double lng) { if (m_longitude != lng) { m_longitude = lng; emit longitudeChanged(); } }
