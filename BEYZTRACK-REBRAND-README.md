# 🚀 BeyzTrack Rebrand Kılavuzu

Bu kılavuz, Ubuntu sisteminde kurulu olan normal Uptime Kuma'yı BeyzTrack'e dönüştürmek için hazırlanmıştır.

## 📋 Gereksinimler

- Ubuntu 18.04+ (veya benzer Linux dağıtımı)
- Uptime Kuma kurulu olmalı
- Bash shell erişimi
- Sudo yetkileri

## 🎯 Rebrand İşlemi

### 1. Dosyaları İndirin

```bash
# Rebrand scriptini indirin
wget https://raw.githubusercontent.com/your-repo/beyztrack-rebrand.sh
chmod +x beyztrack-rebrand.sh

# Logo dosyalarını indirin (opsiyonel)
wget https://raw.githubusercontent.com/your-repo/beyztrack-assets.tar.gz
tar -xzf beyztrack-assets.tar.gz
```

### 2. Rebrand Scriptini Çalıştırın

```bash
./beyztrack-rebrand.sh
```

Script otomatik olarak:
- Uptime Kuma kurulum dizinini bulur
- Backup oluşturur
- Tüm dosyaları BeyzTrack'e dönüştürür
- Servisi yeniden başlatır

## 📁 Değiştirilen Dosyalar

### Ana Dosyalar
- `package.json` - Uygulama adı: "beyztrack"
- `index.html` - Title ve meta bilgileri
- `public/manifest.json` - PWA ayarları
- `server/server.js` - Welcome mesajı

### Frontend Dosyalar
- `src/layouts/Layout.vue` - Logo ve başlık
- `src/lang/tr-TR.json` - Türkçe dil desteği

### Logo Dosyaları
- `public/icon.png` - Ana logo
- `public/icon.svg` - SVG logo
- `public/favicon.ico` - Favicon
- `public/icon-192x192.png` - PWA icon
- `public/icon-512x512.png` - PWA icon

## 🔧 Manuel Değişiklikler

Eğer script çalışmazsa, manuel olarak şu değişiklikleri yapabilirsiniz:

### 1. Package.json
```json
{
    "name": "beyztrack",
    "version": "2.0.0-beta.3"
}
```

### 2. Index.html
```html
<title>BeyzTrack - Monitoring System</title>
<meta name="description" content="BeyzTrack - Beyz System Monitoring and Uptime Tracking Tool" />
```

### 3. Manifest.json
```json
{
    "name": "BeyzTrack - Monitoring System",
    "short_name": "BeyzTrack",
    "description": "Beyz System Monitoring and Uptime Tracking"
}
```

### 4. Server.js
```javascript
console.log("Welcome to BeyzTrack");
console.log("BeyzTrack Version: 2.0.0-beta.3");
```

## 🚨 Sorun Giderme

### Script Çalışmıyor
```bash
# Çalıştırma izni verin
chmod +x beyztrack-rebrand.sh

# Bash ile çalıştırın
bash beyztrack-rebrand.sh
```

### Uptime Kuma Dizini Bulunamıyor
Script otomatik olarak şu dizinleri arar:
- `/opt/uptime-kuma`
- `/home/$USER/uptime-kuma`
- `/var/www/uptime-kuma`
- `/usr/local/uptime-kuma`

Manuel olarak dizin yolunu girebilirsiniz.

### Servis Yeniden Başlamıyor
```bash
# PM2 ile
pm2 restart all

# Systemd ile
sudo systemctl restart uptime-kuma

# Docker ile
docker restart uptime-kuma
```

## 📊 Backup ve Geri Alma

Script otomatik olarak backup oluşturur:
```bash
# Backup dizini
/opt/uptime-kuma_backup_20241208_163025

# Geri alma
sudo rm -rf /opt/uptime-kuma
sudo mv /opt/uptime-kuma_backup_20241208_163025 /opt/uptime-kuma
```

## 🎨 Özelleştirme

### Logo Değiştirme
1. Yeni logo dosyalarını hazırlayın
2. `public/` dizinine kopyalayın
3. Servisi yeniden başlatın

### Renk Değiştirme
`src/assets/` dizinindeki CSS dosyalarını düzenleyin:
- Ana renk: `#1e3a8a` (mavi)
- İkincil renk: `#3b82f6` (açık mavi)

## 📞 Destek

Sorun yaşarsanız:
1. Backup dosyalarını kontrol edin
2. Log dosyalarını inceleyin
3. Manuel değişiklikleri uygulayın

## 🔄 Güncelleme

Uptime Kuma güncellendiğinde rebrand işlemini tekrar çalıştırın:
```bash
./beyztrack-rebrand.sh
```

---

**Not**: Bu script sadece görsel ve metin değişiklikleri yapar. Temel Uptime Kuma fonksiyonları değişmez.
