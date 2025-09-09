#!/bin/bash

# BeyzTrack - Branding ve Özelleştirme Scripti
# Bu script orijinal Uptime Kuma'yı BeyzTrack'e dönüştürür

set -e

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logo
echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    BeyzTrack Branding                       ║"
echo "║              Uptime Kuma → BeyzTrack Dönüşümü               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Kurulum dizini
INSTALL_DIR="/opt/uptime-kuma"
BACKUP_DIR="/opt/uptime-kuma-backup-$(date +%Y%m%d-%H%M%S)"

# Backup oluştur
create_backup() {
    echo -e "${CYAN}💾 Backup oluşturuluyor...${NC}"
    
    if [ -d "$INSTALL_DIR" ]; then
        sudo cp -r "$INSTALL_DIR" "$BACKUP_DIR"
        echo -e "${GREEN}✅ Backup oluşturuldu: $BACKUP_DIR${NC}"
    else
        echo -e "${RED}❌ Uptime Kuma kurulumu bulunamadı!${NC}"
        echo -e "${YELLOW}   Önce orijinal kurulumu yapın:${NC}"
        echo -e "${BLUE}   curl -sSL https://raw.githubusercontent.com/Coosef/beyztrack/main/install-original.sh | bash${NC}"
        exit 1
    fi
}

# BeyzTrack dosyalarını indir
download_beyztrack() {
    echo -e "${CYAN}📥 BeyzTrack dosyaları indiriliyor...${NC}"
    
    # Geçici dizin
    TEMP_DIR="/tmp/beyztrack-$(date +%s)"
    mkdir -p "$TEMP_DIR"
    
    # Repository'yi klonla
    git clone https://github.com/Coosef/beyztrack.git "$TEMP_DIR"
    
    echo -e "${GREEN}✅ BeyzTrack dosyaları indirildi${NC}"
    # Return değerini echo'dan ayır
    printf "%s" "$TEMP_DIR"
}

# Frontend dosyalarını güncelle
update_frontend() {
    echo -e "${CYAN}🎨 Frontend dosyaları güncelleniyor...${NC}"
    
    local temp_dir="$1"
    
    # Frontend dosyalarını kopyala
    sudo cp -r "$temp_dir/src"/* "$INSTALL_DIR/src/"
    sudo cp -r "$temp_dir/public"/* "$INSTALL_DIR/public/" 2>/dev/null || true
    sudo cp "$temp_dir/package.json" "$INSTALL_DIR/"
    sudo cp "$temp_dir/index.html" "$INSTALL_DIR/"
    
    # Vite config
    sudo mkdir -p "$INSTALL_DIR/config"
    sudo cp "$temp_dir/config/vite.config.js" "$INSTALL_DIR/config/"
    
    # Ownership düzelt
    sudo chown -R www-data:www-data "$INSTALL_DIR"
    sudo chmod -R 755 "$INSTALL_DIR"
    
    echo -e "${GREEN}✅ Frontend dosyaları güncellendi${NC}"
}

# Dependencies güncelle
update_dependencies() {
    echo -e "${CYAN}📦 Dependencies güncelleniyor...${NC}"
    
    cd "$INSTALL_DIR"
    
    # Yeni dependencies kur
    sudo npm install --legacy-peer-deps
    
    echo -e "${GREEN}✅ Dependencies güncellendi${NC}"
}

# Frontend rebuild
rebuild_frontend() {
    echo -e "${CYAN}🔨 Frontend yeniden build ediliyor...${NC}"
    
    cd "$INSTALL_DIR"
    
    # Frontend build
    sudo npm run build
    
    # Dosya izinlerini düzelt
    sudo chown -R www-data:www-data "$INSTALL_DIR/dist"
    sudo chmod -R 755 "$INSTALL_DIR/dist"
    
    echo -e "${GREEN}✅ Frontend rebuild tamamlandı${NC}"
}

# Nginx konfigürasyonunu güncelle
update_nginx() {
    echo -e "${CYAN}⚙️  Nginx konfigürasyonu güncelleniyor...${NC}"
    
    # BeyzTrack için Nginx konfigürasyonu
    sudo tee /etc/nginx/sites-available/uptime-kuma << 'EOF'
server {
    listen 80;
    server_name _;
    
    # Frontend static files
    location / {
        root /opt/uptime-kuma/dist;
        try_files $uri $uri/ /index.html;
    }
    
    # Backend API proxy
    location /api/ {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
    
    # WebSocket proxy
    location /socket.io/ {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

    # Nginx'i yeniden başlat
    sudo nginx -t
    sudo systemctl reload nginx
    
    echo -e "${GREEN}✅ Nginx konfigürasyonu güncellendi${NC}"
}

# PM2'yi yeniden başlat
restart_pm2() {
    echo -e "${CYAN}🔄 PM2 yeniden başlatılıyor...${NC}"
    
    # PM2'yi durdur ve başlat
    sudo pm2 restart uptime-kuma
    sudo pm2 save
    
    echo -e "${GREEN}✅ PM2 yeniden başlatıldı${NC}"
}

# Temizlik
cleanup() {
    echo -e "${CYAN}🧹 Temizlik yapılıyor...${NC}"
    
    # Geçici dosyaları temizle
    if [ -n "$1" ] && [ -d "$1" ]; then
        rm -rf "$1"
    fi
    
    echo -e "${GREEN}✅ Temizlik tamamlandı${NC}"
}

# Kurulum tamamlandı
branding_complete() {
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                  BRANDING TAMAMLANDI!                      ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${CYAN}🌐 BeyzTrack Web Arayüz:${NC} http://$(hostname -I | awk '{print $1}')"
    echo -e "${CYAN}🌐 BeyzTrack Web Arayüz:${NC} http://localhost"
    echo -e "${CYAN}🔧 Backend:${NC} http://localhost:3001"
    echo ""
    echo -e "${GREEN}✅ Uptime Kuma başarıyla BeyzTrack'e dönüştürüldü!${NC}"
    echo -e "${YELLOW}📋 Yeni Özellikler:${NC}"
    echo -e "${CYAN}   • BeyzTrack logosu ve branding${NC}"
    echo -e "${CYAN}   • Gelişmiş raporlama sistemi${NC}"
    echo -e "${CYAN}   • Canlı aktivite akışı${NC}"
    echo -e "${CYAN}   • Backup menü entegrasyonu${NC}"
    echo -e "${CYAN}   • Türkçe arayüz${NC}"
    echo ""
    echo -e "${BLUE}💾 Backup konumu: $BACKUP_DIR${NC}"
}

# Ana branding fonksiyonu
main() {
    local temp_dir=""
    
    create_backup
    temp_dir=$(download_beyztrack)
    update_frontend "$temp_dir"
    update_dependencies
    rebuild_frontend
    update_nginx
    restart_pm2
    cleanup "$temp_dir"
    branding_complete
}

# Script'i çalıştır
main "$@"
