#!/bin/bash

# BeyzTrack Branding Script'i
# Uptime Kuma'yı BeyzTrack'e dönüştürür (Sadece Görsel Değişiklikler)
# Setup ekranlarına dokunmaz!
# Kullanım: curl -sSL https://raw.githubusercontent.com/Coosef/beyztrack/main/brand.sh | bash

set -e

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logo
print_logo() {
    echo -e "${BLUE}"
    echo "  ____                    _______             "
    echo " |  _ \                  |__   __|            "
    echo " | |_) |_   _ _ __   __ _    | |_ __ __ _ _ __ "
    echo " |  _ <| | | | '_ \ / _\` |   | | '__/ _\` | '__|"
    echo " | |_) | |_| | | | | (_| |   | | | | (_| | |   "
    echo " |____/ \__,_|_| |_|\__,_|   |_|_|  \__,_|_|   "
    echo -e "${NC}"
    echo -e "${GREEN} BeyzTrack - Sadece Görsel Branding${NC}"
    echo ""
}

# Hata mesajı
error() {
    echo -e "${RED}❌ Hata: $1${NC}" >&2
    exit 1
}

# Başarı mesajı
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Bilgi mesajı
info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# Uyarı mesajı
warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Uptime Kuma'nın kurulu olup olmadığını kontrol et
check_uptime_kuma_installed() {
    if [ ! -d "/opt/uptime-kuma" ] || [ ! -f "/opt/uptime-kuma/server/server.js" ]; then
        error "Uptime Kuma '/opt/uptime-kuma' dizininde kurulu değil. Lütfen önce Uptime Kuma'yı kurun."
        echo -e "${BLUE}   Önce Uptime Kuma'yı kurun, sonra bu script'i çalıştırın.${NC}"
        exit 1
    fi
}

# Backup oluştur
create_backup() {
    info " Backup oluşturuluyor..."
    BACKUP_DIR="/opt/uptime-kuma-backup-$(date +%Y%m%d-%H%M%S)"
    sudo cp -r "/opt/uptime-kuma" "$BACKUP_DIR" || error "Backup oluşturulamadı."
    success "✅ Backup oluşturuldu: $BACKUP_DIR"
}

# BeyzTrack dosyalarını indir
download_beyztrack() {
    info "📥 BeyzTrack dosyaları indiriliyor..."
    
    # Geçici dizin
    TEMP_DIR="/tmp/beyztrack-$(date +%s)"
    mkdir -p "$TEMP_DIR"
    
    # Repository'yi klonla
    git clone https://github.com/Coosef/beyztrack.git "$TEMP_DIR" || error "BeyzTrack repository klonlanamadı."
    
    success "✅ BeyzTrack dosyaları indirildi"
}

# Sadece görsel dosyaları güncelle
update_visual_files() {
    info "🎨 Görsel dosyalar güncelleniyor..."
    
    # Logo dosyalarını kopyala
    sudo cp "$TEMP_DIR/public/1.png" "/opt/uptime-kuma/public/" 2>/dev/null || true
    sudo cp "$TEMP_DIR/public/3.png" "/opt/uptime-kuma/public/" 2>/dev/null || true
    sudo cp "$TEMP_DIR/public/3.svg" "/opt/uptime-kuma/public/" 2>/dev/null || true
    
    # Index.html'i güncelle (sadece title)
    sudo sed -i 's/Uptime Kuma/BeyzTrack - Monitoring System/g' "/opt/uptime-kuma/index.html"
    sudo sed -i 's/A fancy self-hosted monitoring tool/Monitoring \& Reporting System/g' "/opt/uptime-kuma/index.html"
    
    # Package.json'ı güncelle (sadece name ve description)
    sudo sed -i 's/"name": "uptime-kuma"/"name": "beyztrack"/g' "/opt/uptime-kuma/package.json"
    sudo sed -i 's/"description": "A fancy self-hosted monitoring tool"/"description": "BeyzTrack - Monitoring \& Reporting System"/g' "/opt/uptime-kuma/package.json"
    
    success "✅ Görsel dosyalar güncellendi"
}

# BeyzTrack özelliklerini ekle
add_beyztrack_features() {
    info "🚀 BeyzTrack özellikleri ekleniyor..."
    
    # Pages dizinini oluştur ve tüm sayfa dosyalarını kopyala
    sudo mkdir -p "/opt/uptime-kuma/src/pages"
    sudo cp "$TEMP_DIR/src/pages/AdvancedReports.vue" "/opt/uptime-kuma/src/pages/" 2>/dev/null || true
    sudo cp "$TEMP_DIR/src/pages/Settings.vue" "/opt/uptime-kuma/src/pages/" 2>/dev/null || true
    sudo cp "$TEMP_DIR/src/pages/Todo.vue" "/opt/uptime-kuma/src/pages/" 2>/dev/null || true
    sudo cp "$TEMP_DIR/src/pages/Backup.vue" "/opt/uptime-kuma/src/pages/" 2>/dev/null || true
    sudo cp "$TEMP_DIR/src/pages/StatusPages.vue" "/opt/uptime-kuma/src/pages/" 2>/dev/null || true
    
    # Report componentlerini kopyala
    sudo mkdir -p "/opt/uptime-kuma/src/components/reports"
    sudo cp -r "$TEMP_DIR/src/components/reports/"* "/opt/uptime-kuma/src/components/reports/" 2>/dev/null || true
    
    # Login component'ini kopyala
    sudo cp "$TEMP_DIR/src/components/Login.vue" "/opt/uptime-kuma/src/components/" 2>/dev/null || true
    
    # Utils dizinini oluştur ve reportUtils'i kopyala
    sudo mkdir -p "/opt/uptime-kuma/src/utils"
    sudo cp "$TEMP_DIR/src/utils/reportUtils.js" "/opt/uptime-kuma/src/utils/" 2>/dev/null || true
    
    # util-frontend.js'i kopyala
    echo "    📄 util-frontend.js kopyalanıyor..."
    sudo cp "$TEMP_DIR/src/util-frontend.js" "/opt/uptime-kuma/src/" 2>/dev/null || true
    
    # Kopyalama kontrolü
    if [ -f "/opt/uptime-kuma/src/util-frontend.js" ]; then
        echo "    ✅ util-frontend.js başarıyla kopyalandı"
    else
        echo "    ❌ util-frontend.js kopyalanamadı!"
    fi
    
    # Router ve main.js'i güncelle - Tüm route'ları ekle
    echo "    📄 Router ve main.js kopyalanıyor..."
    sudo cp "$TEMP_DIR/src/router.js" "/opt/uptime-kuma/src/" 2>/dev/null || true
    sudo cp "$TEMP_DIR/src/main.js" "/opt/uptime-kuma/src/" 2>/dev/null || true
    
    # Kopyalama kontrolü
    if [ -f "/opt/uptime-kuma/src/main.js" ]; then
        echo "    ✅ main.js başarıyla kopyalandı"
    else
        echo "    ❌ main.js kopyalanamadı!"
    fi
    
    # Layout'u güncelle - Backup menüsü ekle
    sudo cp "$TEMP_DIR/src/layouts/Layout.vue" "/opt/uptime-kuma/src/layouts/" 2>/dev/null || true
    
    # Dil dosyalarını güncelle
    sudo cp "$TEMP_DIR/src/lang/tr-TR.json" "/opt/uptime-kuma/src/lang/" 2>/dev/null || true
    
    success "✅ BeyzTrack özellikleri eklendi"
}

# Layout.vue'yi güncelle (sadece logo ve isim)
update_layout() {
    info " Layout.vue güncelleniyor..."
    
    # Layout.vue'de sadece logo ve isim değişiklikleri
    sudo sed -i 's|src="/icon.png"|src="/1.png"|g' "/opt/uptime-kuma/src/layouts/Layout.vue"
    sudo sed -i 's/Uptime Kuma/BeyzTrack/g' "/opt/uptime-kuma/src/layouts/Layout.vue"
    sudo sed -i 's/A fancy self-hosted monitoring tool/Monitoring \& Reporting System/g' "/opt/uptime-kuma/src/layouts/Layout.vue"
    
    success "✅ Layout.vue güncellendi"
}

# Frontend'i rebuild et
rebuild_frontend() {
    info "🔨 Frontend yeniden build ediliyor..."
    cd "/opt/uptime-kuma" || error "Dizin değiştirilemedi: /opt/uptime-kuma"
    sudo npm run build || error "Frontend rebuild başarısız."
    success "✅ Frontend rebuild tamamlandı"
}

# Servisi yeniden başlat
restart_service() {
    info " Servis yeniden başlatılıyor..."
    sudo systemctl restart uptime-kuma || error "Servis yeniden başlatılamadı."
    success "✅ Servis yeniden başlatıldı"
}

# Temizlik
cleanup() {
    info " Temizlik yapılıyor..."
    
    # Geçici dosyaları temizle
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
    
    success "✅ Temizlik tamamlandı"
}

# Kurulum tamamlandı
branding_complete() {
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                  BRANDING TAMAMLANDI!                      ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo -e "${BLUE} BeyzTrack Web Arayüz: http://$(hostname -I | awk '{print $1}')${NC}"
    echo -e "${BLUE} BeyzTrack Web Arayüz: http://localhost${NC}"
    echo ""
    echo -e "✅ Uptime Kuma başarıyla BeyzTrack'e dönüştürüldü!"
    echo -e " Yapılan Değişiklikler:"
    echo -e "${CYAN}   • Logo değiştirildi (/1.png)${NC}"
    echo -e "${CYAN}   • İsim değiştirildi (BeyzTrack)${NC}"
    echo -e "${CYAN}   • Tagline değiştirildi (Monitoring & Reporting System)${NC}"
    echo -e "${CYAN}   • Package.json güncellendi${NC}"
    echo -e "${CYAN}   • Index.html güncellendi${NC}"
    echo -e "${CYAN}   • Setup ekranlarına dokunulmadı${NC}"
    echo ""
    echo -e "${BLUE}💾 Backup konumu: $BACKUP_DIR${NC}"
}

# Ana branding fonksiyonu
main() {
    print_logo
    check_uptime_kuma_installed
    create_backup
    download_beyztrack
    update_visual_files
    add_beyztrack_features
    update_layout
    rebuild_frontend
    restart_service
    cleanup
    branding_complete
}

# Script'i çalıştır
main "$@"