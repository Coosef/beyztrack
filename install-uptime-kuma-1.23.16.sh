#!/bin/bash

# Uptime Kuma 1.23.16 Kurulum Script'i
# Temiz kurulum - sadece Uptime Kuma
# Kullanım: curl -sSL https://raw.githubusercontent.com/Coosef/beyztrack/main/install-uptime-kuma-1.23.16.sh | bash

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
    echo -e "${GREEN}🚀 Uptime Kuma 1.23.16 Kurulumu${NC}"
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

# Git kurulumu
install_git() {
    info "📦 Git kurulumu kontrol ediliyor..."
    if command -v git &>/dev/null; then
        success "✅ Git zaten kurulu"
    else
        warning "⚠️  Git kurulu değil. Kuruluyor..."
        sudo apt-get update || error "Apt update başarısız."
        sudo apt-get install -y git || error "Git kurulumu başarısız."
        success "✅ Git kuruldu."
    fi
}

# Node.js kurulumu
install_nodejs() {
    info "📦 Node.js kurulumu kontrol ediliyor..."
    if command -v node &>/dev/null && node --version | grep -q "v18"; then
        success "✅ Node.js $(node --version) zaten kurulu"
    else
        warning "⚠️  Node.js 18+ kurulu değil. Kuruluyor..."
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - || error "Node.js repository eklenemedi."
        sudo apt-get install -y nodejs || error "Node.js kurulumu başarısız."
        success "✅ Node.js kuruldu."
    fi
}

# Uptime Kuma kurulumu
install_uptime_kuma() {
    info "📥 Uptime Kuma 1.23.16 kuruluyor..."
    INSTALL_DIR="/opt/uptime-kuma"

    if [ -d "$INSTALL_DIR" ]; then
        warning "⚠️  Eski kurulum temizleniyor..."
        sudo rm -rf "$INSTALL_DIR" || error "Eski kurulum temizlenemedi."
    fi

    info "📥 Uptime Kuma repository klonlanıyor..."
    sudo git clone https://github.com/louislam/uptime-kuma.git "$INSTALL_DIR" || error "Uptime Kuma klonlanamadı."
    
    cd "$INSTALL_DIR" || error "Dizin değiştirilemedi: $INSTALL_DIR"

    # 1.23.16 versiyonuna geç
    info "📌 Uptime Kuma 1.23.16 versiyonuna geçiliyor..."
    sudo git checkout 1.23.16 || error "Versiyon değiştirilemedi."

    info " Dependencies kuruluyor..."
    sudo npm install --legacy-peer-deps || error "Dependencies kurulumu başarısız."

    info "🔨 Frontend build ediliyor..."
    sudo npm run build || error "Frontend build başarısız."

    info "⚙️  Data dizinleri oluşturuluyor..."
    sudo mkdir -p "$INSTALL_DIR/data"/{upload,backup,logs,screenshots,ssl,docker-tls} || error "Data dizinleri oluşturulamadı."
    sudo chown -R www-data:www-data "$INSTALL_DIR" || error "Dosya sahipliği ayarlanamadı."
    sudo chmod -R 755 "$INSTALL_DIR" || error "Dosya izinleri ayarlanamadı."

    success "✅ Uptime Kuma 1.23.16 kurulumu tamamlandı"
}

# systemd servisi oluştur
create_systemd_service() {
    info "⚙️  systemd servisi oluşturuluyor..."
    INSTALL_DIR="/opt/uptime-kuma"

    # systemd unit dosyası oluştur
    sudo tee /etc/systemd/system/uptime-kuma.service > /dev/null << 'EOF'
[Unit]
Description=Uptime Kuma - Free & Open Source Uptime Monitoring
After=network.target

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/opt/uptime-kuma
Environment=NODE_ENV=production
ExecStart=/usr/bin/node server/server.js
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

    # Servisi etkinleştir ve başlat
    sudo systemctl daemon-reload
    sudo systemctl enable uptime-kuma
    sudo systemctl start uptime-kuma

    success "✅ systemd servisi oluşturuldu ve başlatıldı"
}

# Nginx konfigürasyonu
configure_nginx() {
    info "⚙️  Nginx konfigürasyonu yapılıyor..."
    INSTALL_DIR="/opt/uptime-kuma"

    # Default site'ı devre dışı bırak
    sudo rm -f /etc/nginx/sites-enabled/default

    # Yeni konfigürasyon oluştur
    sudo tee /etc/nginx/sites-available/uptime-kuma > /dev/null << 'EOF'
server {
    listen 80;
    server_name _;
    root /opt/uptime-kuma/dist;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
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

    # Konfigürasyonu aktif et
    sudo ln -sf /etc/nginx/sites-available/uptime-kuma /etc/nginx/sites-enabled/ || error "Nginx site aktif edilemedi."

    # Nginx'i test et ve yeniden başlat
    sudo nginx -t || error "Nginx konfigürasyon testi başarısız."
    sudo systemctl reload nginx || error "Nginx yeniden başlatılamadı."
    success "✅ Nginx konfigürasyonu tamamlandı"
}

# UFW kurulumu
install_ufw() {
    info "📦 UFW kurulumu kontrol ediliyor..."
    if command -v ufw &>/dev/null; then
        success "✅ UFW zaten kurulu"
    else
        warning "⚠️  UFW kurulu değil. Kuruluyor..."
        sudo apt-get update || error "Apt update başarısız."
        sudo apt-get install -y ufw || error "UFW kurulumu başarısız."
        success "✅ UFW kuruldu."
    fi
}

# Firewall konfigürasyonu
configure_firewall() {
    info "️  Firewall konfigürasyonu yapılıyor..."
    sudo ufw allow 80/tcp || warning "UFW port 80 açılamadı."
    sudo ufw allow 443/tcp || warning "UFW port 443 açılamadı."
    sudo ufw allow 22/tcp || warning "UFW port 22 açılamadı."
    sudo ufw --force enable || error "UFW etkinleştirilemedi."
    success "✅ Firewall konfigürasyonu tamamlandı"
}

# Ana fonksiyon
main() {
    print_logo
    info "🔍 Sistem kontrolü yapılıyor..."
    if ! command -v apt-get &>/dev/null; then
        error "Bu script sadece Debian/Ubuntu tabanlı sistemlerde çalışır."
    fi
    success "✅ Sistem uyumlu"

    install_git
    install_nodejs
    install_uptime_kuma
    create_systemd_service
    configure_nginx
    install_ufw
    configure_firewall

    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║             Uptime Kuma 1.23.16 Kurulumu Tamamlandı!        ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo -e "${BLUE}🌐 Uptime Kuma Web Arayüz: http://localhost${NC}"
    echo -e "${BLUE}🔧 Backend: http://localhost:3001${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  Şimdi BeyzTrack branding scriptini çalıştırabilirsiniz:${NC}"
    echo -e "${BLUE}   curl -sSL https://raw.githubusercontent.com/Coosef/beyztrack/main/brand.sh | bash${NC}"
    echo ""
}

# Script'i çalıştır
main "$@"