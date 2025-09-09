#!/bin/bash

# BeyzTrack - Orijinal Uptime Kuma Kurulum Scripti
# Bu script orijinal Uptime Kuma'yı kurar, sonra branding scripti çalıştırılır

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
echo "║                    BeyzTrack Kurulum                        ║"
echo "║              Orijinal Uptime Kuma Kurulumu                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Sistem kontrolü
check_system() {
    echo -e "${CYAN}🔍 Sistem kontrolü yapılıyor...${NC}"
    
    # OS kontrolü
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        echo -e "${RED}❌ Bu script sadece Linux sistemlerde çalışır!${NC}"
        exit 1
    fi
    
    # Root kontrolü
    if [[ $EUID -eq 0 ]]; then
        echo -e "${YELLOW}⚠️  Root kullanıcısı olarak çalıştırıyorsunuz!${NC}"
    fi
    
    echo -e "${GREEN}✅ Sistem uyumlu${NC}"
}

# Node.js kurulumu
install_nodejs() {
    echo -e "${CYAN}📦 Node.js kurulumu kontrol ediliyor...${NC}"
    
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version | cut -d'v' -f2)
        NODE_MAJOR=$(echo $NODE_VERSION | cut -d'.' -f1)
        
        if [ "$NODE_MAJOR" -ge 18 ]; then
            echo -e "${GREEN}✅ Node.js v$NODE_VERSION zaten kurulu${NC}"
            return
        else
            echo -e "${YELLOW}⚠️  Node.js v$NODE_VERSION çok eski, güncelleniyor...${NC}"
        fi
    fi
    
    # Node.js 18+ kurulumu
    echo -e "${CYAN}📥 Node.js 18+ kuruluyor...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
    
    echo -e "${GREEN}✅ Node.js kurulumu tamamlandı${NC}"
}

# PM2 kurulumu
install_pm2() {
    echo -e "${CYAN}📦 PM2 kurulumu kontrol ediliyor...${NC}"
    
    if command -v pm2 &> /dev/null; then
        echo -e "${GREEN}✅ PM2 zaten kurulu${NC}"
    else
        echo -e "${CYAN}📥 PM2 kuruluyor...${NC}"
        sudo npm install -g pm2
        echo -e "${GREEN}✅ PM2 kurulumu tamamlandı${NC}"
    fi
}

# Nginx kurulumu
install_nginx() {
    echo -e "${CYAN}📦 Nginx kurulumu kontrol ediliyor...${NC}"
    
    if command -v nginx &> /dev/null; then
        echo -e "${GREEN}✅ Nginx zaten kurulu${NC}"
    else
        echo -e "${CYAN}📥 Nginx kuruluyor...${NC}"
        sudo apt-get update
        sudo apt-get install -y nginx
        sudo systemctl enable nginx
        sudo systemctl start nginx
        echo -e "${GREEN}✅ Nginx kurulumu tamamlandı${NC}"
    fi
}

# Uptime Kuma kurulumu
install_uptime_kuma() {
    echo -e "${CYAN}📥 Uptime Kuma kuruluyor...${NC}"
    
    # Kurulum dizini
    INSTALL_DIR="/opt/uptime-kuma"
    
    # Eski kurulumu temizle
    if [ -d "$INSTALL_DIR" ]; then
        echo -e "${YELLOW}⚠️  Eski kurulum temizleniyor...${NC}"
        sudo rm -rf "$INSTALL_DIR"
    fi
    
    # Dizin oluştur
    sudo mkdir -p "$INSTALL_DIR"
    
    # Uptime Kuma'yı klonla
    echo -e "${CYAN}📥 Uptime Kuma repository klonlanıyor...${NC}"
    sudo git clone https://github.com/louislam/uptime-kuma.git "$INSTALL_DIR"
    
    # Ownership düzelt
    sudo chown -R www-data:www-data "$INSTALL_DIR"
    sudo chmod -R 755 "$INSTALL_DIR"
    
    # Dependencies kur
    echo -e "${CYAN}📦 Dependencies kuruluyor...${NC}"
    cd "$INSTALL_DIR"
    sudo npm install --legacy-peer-deps
    
    # Frontend build
    echo -e "${CYAN}🔨 Frontend build ediliyor...${NC}"
    sudo npm run build
    
    # Data dizinlerini oluştur
    sudo mkdir -p "$INSTALL_DIR/data/"{upload,backup,logs,screenshots,ssl,docker-tls}
    sudo chown -R www-data:www-data "$INSTALL_DIR/data"
    sudo chmod -R 755 "$INSTALL_DIR/data"
    
    echo -e "${GREEN}✅ Uptime Kuma kurulumu tamamlandı${NC}"
}

# PM2 konfigürasyonu
configure_pm2() {
    echo -e "${CYAN}⚙️  PM2 konfigürasyonu yapılıyor...${NC}"
    
    # PM2'yi durdur
    sudo pm2 delete uptime-kuma 2>/dev/null || true
    
    # PM2 ile başlat
    cd /opt/uptime-kuma
    sudo pm2 start server/server.js --name uptime-kuma --cwd /opt/uptime-kuma
    sudo pm2 save
    sudo pm2 startup
    
    echo -e "${GREEN}✅ PM2 konfigürasyonu tamamlandı${NC}"
}

# Nginx konfigürasyonu
configure_nginx() {
    echo -e "${CYAN}⚙️  Nginx konfigürasyonu yapılıyor...${NC}"
    
    # Nginx konfigürasyonu oluştur
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

    # Konfigürasyonu aktif et
    sudo ln -sf /etc/nginx/sites-available/uptime-kuma /etc/nginx/sites-enabled/
    sudo rm -f /etc/nginx/sites-enabled/default
    
    # Nginx'i yeniden başlat
    sudo nginx -t
    sudo systemctl reload nginx
    
    echo -e "${GREEN}✅ Nginx konfigürasyonu tamamlandı${NC}"
}

# Firewall konfigürasyonu
configure_firewall() {
    echo -e "${CYAN}🔥 Firewall konfigürasyonu yapılıyor...${NC}"
    
    if command -v ufw &> /dev/null; then
        sudo ufw allow 22/tcp
        sudo ufw allow 80/tcp
        sudo ufw allow 443/tcp
        sudo ufw --force enable
        echo -e "${GREEN}✅ Firewall konfigürasyonu tamamlandı${NC}"
    else
        echo -e "${YELLOW}⚠️  UFW bulunamadı, firewall manuel yapılandırılmalı${NC}"
    fi
}

# Kurulum tamamlandı
installation_complete() {
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    KURULUM TAMAMLANDI!                     ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${CYAN}🌐 Web Arayüz:${NC} http://$(hostname -I | awk '{print $1}')"
    echo -e "${CYAN}🌐 Web Arayüz:${NC} http://localhost"
    echo -e "${CYAN}🔧 Backend:${NC} http://localhost:3001"
    echo ""
    echo -e "${YELLOW}📋 Sonraki Adım:${NC}"
    echo -e "${CYAN}   BeyzTrack branding scriptini çalıştırın:${NC}"
    echo -e "${BLUE}   curl -sSL https://raw.githubusercontent.com/Coosef/beyztrack/main/brand.sh | bash${NC}"
    echo ""
    echo -e "${GREEN}✅ Orijinal Uptime Kuma başarıyla kuruldu!${NC}"
}

# Ana kurulum fonksiyonu
main() {
    check_system
    install_nodejs
    install_pm2
    install_nginx
    install_uptime_kuma
    configure_pm2
    configure_nginx
    configure_firewall
    installation_complete
}

# Script'i çalıştır
main "$@"
