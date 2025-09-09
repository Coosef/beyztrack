# BeyzTrack Kurulum Talimatları

Bu rehber, Uptime Kuma'yı BeyzTrack olarak kurmak ve brand işlemi yapmak için hazırlanmıştır.

## 🚀 Hızlı Kurulum

### 1. Uptime Kuma Kurulumu (Temiz Kurulum)

```bash
curl -sSL https://raw.githubusercontent.com/Coosef/beyztrack/main/install-uptime-kuma-latest.sh | bash
```

Bu script:
- ✅ Uptime Kuma'nın son versiyonunu kurar
- ✅ Node.js 20+ kurar
- ✅ Nginx konfigürasyonu yapar
- ✅ systemd servisi oluşturur
- ✅ Firewall ayarlarını yapar

### 2. İlk Kurulum Sonrası

Kurulum tamamlandıktan sonra:
1. `http://localhost` adresine gidin
2. Database ve admin kullanıcısı oluşturun
3. İlk setup işlemlerini tamamlayın

### 3. BeyzTrack Branding

Setup işlemleri tamamlandıktan sonra:

```bash
curl -sSL https://raw.githubusercontent.com/Coosef/beyztrack/main/brand-latest.sh | bash
```

Bu script:
- ✅ Sadece görsel değişiklikler yapar
- ✅ Setup ekranlarına dokunmaz
- ✅ Logo ve isim değişiklikleri yapar
- ✅ Frontend'i yeniden build eder

## 📋 Özellikler

### Uptime Kuma Kurulum Scripti
- **Versiyon**: Latest (2.0.0-beta.3+)
- **Node.js**: 20.x
- **Kurulum Dizini**: `/opt/uptime-kuma`
- **Servis**: systemd
- **Web Server**: Nginx
- **Port**: 80 (HTTP)

### BeyzTrack Branding Scripti
- **Setup Ekranları**: Dokunulmaz
- **Database**: Dokunulmaz
- **Sadece Görsel Değişiklikler**:
  - Logo değişikliği
  - İsim değişikliği (BeyzTrack)
  - Tagline değişikliği
  - Package.json güncellemesi
  - Frontend rebuild

## 🔧 Manuel Kurulum

Eğer script kullanmak istemiyorsanız:

### 1. Uptime Kuma Kurulumu
```bash
# Git ve Node.js kur
sudo apt-get update
sudo apt-get install -y git nginx
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Uptime Kuma'yı klonla
sudo git clone https://github.com/louislam/uptime-kuma.git /opt/uptime-kuma
cd /opt/uptime-kuma
sudo npm install --legacy-peer-deps
sudo npm run build

# Servis oluştur
sudo systemctl enable uptime-kuma
sudo systemctl start uptime-kuma
```

### 2. Branding
```bash
# BeyzTrack dosyalarını indir
git clone https://github.com/Coosef/beyztrack.git /tmp/beyztrack

# Logo dosyalarını kopyala
sudo cp /tmp/beyztrack/public/*.png /opt/uptime-kuma/public/
sudo cp /tmp/beyztrack/public/*.svg /opt/uptime-kuma/public/
sudo cp /tmp/beyztrack/public/*.ico /opt/uptime-kuma/public/

# Frontend'i rebuild et
cd /opt/uptime-kuma
sudo npm run build
sudo systemctl restart uptime-kuma
```

## 🛠️ Sorun Giderme

### Servis Durumu
```bash
sudo systemctl status uptime-kuma
sudo systemctl restart uptime-kuma
```

### Logları Görüntüle
```bash
sudo journalctl -u uptime-kuma -f
```

### Nginx Durumu
```bash
sudo systemctl status nginx
sudo nginx -t
```

### Port Kontrolü
```bash
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :3001
```

## 📁 Dosya Yapısı

```
/opt/uptime-kuma/
├── server/           # Backend kodları
├── src/             # Frontend kodları
├── public/          # Statik dosyalar
├── dist/            # Build edilmiş frontend
├── data/            # Database ve yüklenen dosyalar
└── package.json     # Proje konfigürasyonu
```

## 🔒 Güvenlik

- Firewall otomatik olarak yapılandırılır
- Sadece gerekli portlar açılır (80, 443, 22)
- Servis www-data kullanıcısı ile çalışır
- Dosya izinleri güvenli şekilde ayarlanır

## 📞 Destek

Herhangi bir sorun yaşarsanız:
1. Logları kontrol edin
2. Servis durumunu kontrol edin
3. Portların açık olduğunu kontrol edin
4. Backup dosyalarını kontrol edin

## ⚠️ Önemli Notlar

- **Setup ekranlarına dokunulmaz** - İlk kurulumda database ve admin kullanıcısı oluşturma işlemleri aynen çalışır
- **Backup otomatik oluşturulur** - Branding öncesi otomatik backup alınır
- **Sadece görsel değişiklikler** - Fonksiyonellik değişmez
- **Geri alınabilir** - Backup dosyalarından geri dönülebilir
