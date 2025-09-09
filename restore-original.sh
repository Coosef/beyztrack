#!/bin/bash

# Uptime Kuma Orijinal Haline Geri Alma Script
# Tüm değişiklikleri geri alır ve orijinal Uptime Kuma'yı restore eder

set -e

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logo
echo -e "${BLUE}"
echo "____ _______"
echo "| _ \ |__ __|"
echo "| |_) |_ _ _ __ __ _"
echo "| |_ __ __ _ _ __"
echo "| _ <| | | | '_ \ / _\` |"
echo "| | '__/ _\` | '__|"
echo "| |_) | |_| | | | | (_| |"
echo "| | | (_| | |"
echo "|____/ \__,_|_| |_|\__,_|"
echo "|_|_| \__,_|_|"
echo -e "${NC}"
echo -e "${RED}🔄 Uptime Kuma Orijinal Haline Geri Alınıyor${NC}"
echo -e "${CYAN}📊 Tüm değişiklikler geri alınıyor${NC}"
echo ""

# Fonksiyonlar
info() {
    echo -e "${CYAN}ℹ️ $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

# Ana fonksiyon
main() {
    info "Orijinal Uptime Kuma restore ediliyor..."
    
    # Uptime Kuma kurulu mu kontrol et
    if [ ! -d "/opt/uptime-kuma" ]; then
        error "Uptime Kuma kurulu değil!"
        exit 1
    fi
    
    # PM2 process'ini durdur
    stop_backend
    
    # Orijinal Uptime Kuma'yı yeniden kur
    reinstall_original
    
    # Backend'i başlat
    start_backend
    
    success "Uptime Kuma orijinal haline geri alındı!"
    echo ""
    echo -e "${GREEN}🎉 Uptime Kuma hazır!${NC}"
    echo -e "${CYAN}📋 Bilgiler:${NC}"
    echo -e "   • Web Arayüzü: http://$(hostname -I | awk '{print $1}')"
    echo -e "   • Orijinal Uptime Kuma v1.23.16"
    echo -e "   • Tüm fonksiyonlar çalışıyor"
    echo ""
}

# Backend'i durdur
stop_backend() {
    info "Backend server durduruluyor..."
    
    if command -v pm2 >/dev/null 2>&1; then
        echo "    🛑 PM2 process'leri durduruluyor..."
        pm2 stop uptime-kuma 2>/dev/null || true
        pm2 delete uptime-kuma 2>/dev/null || true
        echo "    ✅ Backend durduruldu"
    else
        echo "    ℹ️ PM2 bulunamadı"
    fi
}

# Orijinal Uptime Kuma'yı yeniden kur
reinstall_original() {
    info "Orijinal Uptime Kuma yeniden kuruluyor..."
    
    # Mevcut dizini temizle
    echo "    🧹 Mevcut dosyalar temizleniyor..."
    sudo rm -rf /opt/uptime-kuma/* 2>/dev/null || true
    
    # Git ile orijinal Uptime Kuma'yı klonla
    echo "    📥 Orijinal Uptime Kuma indiriliyor..."
    cd /opt
    sudo git clone https://github.com/louislam/uptime-kuma.git temp-uptime-kuma 2>/dev/null || {
        error "Uptime Kuma indirilemedi!"
        exit 1
    }
    
    # v1.23.16 tag'ine geç
    echo "    🏷️ v1.23.16 tag'ine geçiliyor..."
    cd /opt/temp-uptime-kuma
    sudo git checkout 1.23.16 2>/dev/null || {
        error "v1.23.16 tag'ine geçilemedi!"
        exit 1
    }
    
    # Dosyaları kopyala
    echo "    📋 Dosyalar kopyalanıyor..."
    sudo cp -r /opt/temp-uptime-kuma/* /opt/uptime-kuma/ 2>/dev/null || true
    sudo cp -r /opt/temp-uptime-kuma/.* /opt/uptime-kuma/ 2>/dev/null || true
    
    # Geçici dizini temizle
    sudo rm -rf /opt/temp-uptime-kuma
    
    # Bağımlılıkları kur
    echo "    📦 Bağımlılıklar kuruluyor..."
    cd /opt/uptime-kuma
    sudo npm install --legacy-peer-deps 2>/dev/null || true
    
    # Frontend'i build et
    echo "    🔨 Frontend build ediliyor..."
    sudo npm run build 2>/dev/null || {
        error "Frontend build başarısız!"
        exit 1
    }
    
    # Nginx'i restart et
    echo "    🔄 Nginx yeniden başlatılıyor..."
    sudo systemctl restart nginx 2>/dev/null || true
    
    success "Orijinal Uptime Kuma kuruldu"
}

# Backend'i başlat
start_backend() {
    info "Backend server başlatılıyor..."
    
    if command -v pm2 >/dev/null 2>&1; then
        echo "    🚀 PM2 ile başlatılıyor..."
        cd /opt/uptime-kuma
        pm2 start server/server.js --name uptime-kuma 2>/dev/null || {
            error "Backend başlatılamadı!"
            exit 1
        }
        
        # PM2'yi kaydet
        pm2 save 2>/dev/null || true
        
        # Durumu kontrol et
        sleep 3
        if pm2 list | grep -q "uptime-kuma.*online"; then
            echo "    ✅ Backend başarıyla başlatıldı"
        else
            echo "    ❌ Backend başlatılamadı"
        fi
    else
        error "PM2 bulunamadı!"
        exit 1
    fi
}

# Script'i çalıştır
main "$@"
