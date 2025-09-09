# BeyzTrack Kurulum Scriptleri

Bu repository, Uptime Kuma'yı BeyzTrack olarak kurmak için hazırlanmış scriptleri içerir.

## 📁 Dosyalar

### Kurulum Scriptleri
- `install-uptime-kuma-latest.sh` - **YENİ** - Son versiyon kurulum scripti
- `install-uptime-kuma-1.23.16.sh` - Eski versiyon kurulum scripti

### Branding Scriptleri  
- `brand-latest.sh` - **YENİ** - Son versiyon için branding scripti
- `brand.sh` - Eski versiyon için branding scripti

### Dokümantasyon
- `KURULUM-TALIMATLARI.md` - Detaylı kurulum rehberi
- `README-SCRIPTS.md` - Bu dosya

## 🚀 Hızlı Başlangıç

### 1. Uptime Kuma Kurulumu
```bash
curl -sSL https://raw.githubusercontent.com/Coosef/beyztrack/main/install-uptime-kuma-latest.sh | bash
```

### 2. İlk Setup
- `http://localhost` adresine gidin
- Database ve admin kullanıcısı oluşturun

### 3. BeyzTrack Branding
```bash
curl -sSL https://raw.githubusercontent.com/Coosef/beyztrack/main/brand-latest.sh | bash
```

## ✨ Özellikler

### Kurulum Scripti
- ✅ Uptime Kuma son versiyonunu kurar
- ✅ Node.js 20+ kurar
- ✅ Nginx konfigürasyonu yapar
- ✅ systemd servisi oluşturur
- ✅ Firewall ayarlarını yapar
- ✅ Otomatik başlatma

### Branding Scripti
- ✅ Sadece görsel değişiklikler
- ✅ Setup ekranlarına dokunmaz
- ✅ Logo değişikliği
- ✅ İsim değişikliği (BeyzTrack)
- ✅ Otomatik backup
- ✅ Frontend rebuild

## 🔧 Sistem Gereksinimleri

- Ubuntu/Debian tabanlı sistem
- Root/sudo erişimi
- İnternet bağlantısı
- Minimum 1GB RAM
- Minimum 2GB disk alanı

## 📋 Kurulum Adımları

1. **Sistem Güncellemesi**
   ```bash
   sudo apt-get update && sudo apt-get upgrade -y
   ```

2. **Uptime Kuma Kurulumu**
   ```bash
   curl -sSL https://raw.githubusercontent.com/Coosef/beyztrack/main/install-uptime-kuma-latest.sh | bash
   ```

3. **İlk Kurulum**
   - Web arayüzüne gidin: `http://localhost`
   - Database oluşturun
   - Admin kullanıcısı oluşturun

4. **Branding**
   ```bash
   curl -sSL https://raw.githubusercontent.com/Coosef/beyztrack/main/brand-latest.sh | bash
   ```

## 🛠️ Sorun Giderme

### Servis Kontrolü
```bash
sudo systemctl status uptime-kuma
sudo systemctl restart uptime-kuma
```

### Log Görüntüleme
```bash
sudo journalctl -u uptime-kuma -f
```

### Port Kontrolü
```bash
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :3001
```

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

## 🔄 Güncelleme

Scriptleri güncellemek için:
```bash
git pull origin main
```

## 📝 Lisans

MIT License - Detaylar için LICENSE dosyasına bakın.
