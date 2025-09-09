#!/bin/bash

# BeyzTrack Minimal Branding Script
# Sadece logo ve isim değişikliği - fonksiyonaliteyi bozmaz

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
echo -e "${GREEN}🚀 BeyzTrack - Minimal Branding${NC}"
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

# Ana fonksiyon
main() {
    info "Minimal branding başlatılıyor..."
    
    # Uptime Kuma kurulu mu kontrol et
    if [ ! -d "/opt/uptime-kuma" ]; then
        error "Uptime Kuma kurulu değil! Önce install-uptime-kuma-latest.sh çalıştırın."
        exit 1
    fi
    
    # Minimal branding uygula
    apply_minimal_branding
    
    # Frontend'i rebuild et
    rebuild_frontend
    
    success "Minimal branding tamamlandı!"
    echo ""
    echo -e "${GREEN}🎉 BeyzTrack hazır!${NC}"
    echo -e "${CYAN}📋 Bilgiler:${NC}"
    echo -e "   • Web Arayüzü: http://$(hostname -I | awk '{print $1}')"
    echo -e "   • Sadece logo ve isim değişti"
    echo -e "   • Tüm fonksiyonlar çalışıyor"
    echo ""
}

# Minimal branding uygula
apply_minimal_branding() {
    info "Minimal branding uygulanıyor..."
    
    # Sadece logo değişikliği
    echo "    🖼️ Logo güncelleniyor..."
    sudo sed -i 's|src="/icon.png"|src="/1.png"|g' "/opt/uptime-kuma/src/layouts/Layout.vue"
    
    # Sadece isim değişikliği
    echo "    📝 İsim güncelleniyor..."
    sudo sed -i 's/Uptime Kuma/BeyzTrack/g' "/opt/uptime-kuma/src/layouts/Layout.vue"
    
    success "Minimal branding uygulandı"
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
    sudo npm run build 2>/dev/null || {
        error "Frontend rebuild başarısız!"
        exit 1
    }
    
    # Nginx restart
    echo "    🔄 Nginx yeniden başlatılıyor..."
    sudo systemctl restart nginx 2>/dev/null || true
    
    success "Frontend rebuild tamamlandı"
}

# Script'i çalıştır
main "$@"
