#!/bin/bash

# BeyzTrack Güvenli Branding Script
# Sadece logo ve isim değişikliği - hiçbir fonksiyonaliteyi bozmaz

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
echo -e "${GREEN}🚀 BeyzTrack - Güvenli Branding${NC}"
echo -e "${CYAN}📊 Sadece logo ve isim değişikliği${NC}"
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
    info "Güvenli branding başlatılıyor..."
    
    # Uptime Kuma kurulu mu kontrol et
    if [ ! -d "/opt/uptime-kuma" ]; then
        error "Uptime Kuma kurulu değil! Önce restore-original.sh çalıştırın."
        exit 1
    fi
    
    # Backend server durumunu kontrol et
    check_backend_status
    
    # Güvenli branding uygula
    apply_safe_branding
    
    # Frontend'i rebuild et
    rebuild_frontend
    
    success "Güvenli branding tamamlandı!"
    echo ""
    echo -e "${GREEN}🎉 BeyzTrack hazır!${NC}"
    echo -e "${CYAN}📋 Bilgiler:${NC}"
    echo -e "   • Web Arayüzü: http://$(hostname -I | awk '{print $1}')"
    echo -e "   • Sadece logo ve isim değişti"
    echo -e "   • Tüm fonksiyonlar çalışıyor"
    echo ""
}

# Backend server durumunu kontrol et
check_backend_status() {
    info "Backend server durumu kontrol ediliyor..."
    
    # PM2 durumunu kontrol et
    if command -v pm2 >/dev/null 2>&1; then
        if pm2 list | grep -q "uptime-kuma.*online"; then
            echo "    ✅ Uptime Kuma PM2'de çalışıyor"
        else
            echo "    ❌ Uptime Kuma PM2'de çalışmıyor"
            warning "Backend çalışmıyor, önce restore-original.sh çalıştırın!"
            exit 1
        fi
    else
        echo "    ❌ PM2 bulunamadı"
        warning "PM2 bulunamadı, önce restore-original.sh çalıştırın!"
        exit 1
    fi
    
    # Port 3001'i kontrol et
    if netstat -tlnp 2>/dev/null | grep -q ":3001"; then
        echo "    ✅ Port 3001 açık"
    else
        echo "    ❌ Port 3001 kapalı"
        warning "Backend portu kapalı, önce restore-original.sh çalıştırın!"
        exit 1
    fi
}

# Güvenli branding uygula
apply_safe_branding() {
    info "Güvenli branding uygulanıyor..."
    
    # Logo dosyasını oluştur
    echo "    🖼️ Logo dosyası oluşturuluyor..."
    if [ -f "/opt/uptime-kuma/1.png" ]; then
        echo "    ✅ Logo dosyası zaten var"
    else
        # Basit bir logo oluştur (SVG)
        sudo tee "/opt/uptime-kuma/1.png" > /dev/null << 'EOF'
<svg width="40" height="40" viewBox="0 0 40 40" xmlns="http://www.w3.org/2000/svg">
  <rect width="40" height="40" fill="#4CAF50" rx="8"/>
  <text x="20" y="28" font-family="Arial, sans-serif" font-size="16" font-weight="bold" text-anchor="middle" fill="white">B</text>
</svg>
EOF
        echo "    ✅ Logo dosyası oluşturuldu"
    fi
    
    # Sadece Layout.vue'de logo değişikliği
    echo "    🔄 Logo güncelleniyor..."
    if sudo sed -i 's|src="/icon.png"|src="/1.png"|g' "/opt/uptime-kuma/src/layouts/Layout.vue" 2>/dev/null; then
        echo "    ✅ Logo değişikliği başarılı"
    else
        error "Logo değişikliği başarısız!"
        exit 1
    fi
    
    # Sadece Layout.vue'de isim değişikliği
    echo "    📝 İsim güncelleniyor..."
    if sudo sed -i 's/Uptime Kuma/BeyzTrack/g' "/opt/uptime-kuma/src/layouts/Layout.vue" 2>/dev/null; then
        echo "    ✅ İsim değişikliği başarılı"
    else
        error "İsim değişikliği başarısız!"
        exit 1
    fi
    
    # Değişiklikleri kontrol et
    if grep -q "BeyzTrack" "/opt/uptime-kuma/src/layouts/Layout.vue"; then
        echo "    ✅ İsim değişikliği doğrulandı"
    else
        error "İsim değişikliği doğrulanamadı!"
        exit 1
    fi
    
    if grep -q "/1.png" "/opt/uptime-kuma/src/layouts/Layout.vue"; then
        echo "    ✅ Logo değişikliği doğrulandı"
    else
        error "Logo değişikliği doğrulanamadı!"
        exit 1
    fi
    
    success "Güvenli branding uygulandı"
}

# Frontend'i rebuild et
rebuild_frontend() {
    info "Frontend rebuild ediliyor..."
    
    cd "/opt/uptime-kuma"
    
    # NPM install
    echo "    📦 Bağımlılıklar kuruluyor..."
    sudo npm install --legacy-peer-deps 2>/dev/null || true
    
    # Build
    echo "    🔨 Frontend build ediliyor..."
    if sudo npm run build 2>/dev/null; then
        echo "    ✅ Frontend build başarılı"
    else
        error "Frontend build başarısız!"
        exit 1
    fi
    
    # Nginx restart
    echo "    🔄 Nginx yeniden başlatılıyor..."
    sudo systemctl restart nginx 2>/dev/null || true
    
    success "Frontend rebuild tamamlandı"
}

# Script'i çalıştır
main "$@"
