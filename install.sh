#!/bin/bash

# BeyzTrack Kurulum Script'i
# Tek komutla kurulum: curl -sSL https://raw.githubusercontent.com/kullanici/beyztrack/main/install.sh | bash

set -e

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'  # Bright Blue (daha görünür)
CYAN='\033[0;36m'  # Cyan (lacivert yerine)
NC='\033[0m' # No Color

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
    echo -e "${GREEN}🚀 BeyzTrack - Advanced Uptime Monitoring System${NC}"
    echo -e "${YELLOW}📊 Real-time Reports and Analytics${NC}"
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

# Sistem kontrolü
check_system() {
    info "Sistem kontrolü yapılıyor..."
    
    # OS kontrolü
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        error "Bu script sadece Linux sistemlerde çalışır"
    fi
    
    # Cloud Shell kontrolü
    if [[ -n "$CLOUD_SHELL" ]] || [[ -n "$GOOGLE_CLOUD_PROJECT" ]]; then
        warning "Google Cloud Shell'de çalıştırıyorsunuz. Kurulum geçici olacaktır."
        warning "Kalıcı kurulum için VM kullanmanız önerilir."
    fi
    
    # Root kontrolü
    if [[ $EUID -eq 0 ]]; then
        warning "Root olarak çalıştırıyorsunuz. Güvenlik için normal kullanıcı ile çalıştırmanız önerilir."
    fi
    
    success "Sistem uyumlu"
}

# Paket yöneticisi kontrolü
check_package_manager() {
    info "Paket yöneticisi kontrol ediliyor..."
    
    if command -v apt-get &> /dev/null; then
        PACKAGE_MANAGER="apt"
        UPDATE_CMD="apt-get update"
        INSTALL_CMD="apt-get install -y"
    elif command -v yum &> /dev/null; then
        PACKAGE_MANAGER="yum"
        UPDATE_CMD="yum update -y"
        INSTALL_CMD="yum install -y"
    elif command -v dnf &> /dev/null; then
        PACKAGE_MANAGER="dnf"
        UPDATE_CMD="dnf update -y"
        INSTALL_CMD="dnf install -y"
    else
        error "Desteklenmeyen paket yöneticisi"
    fi
    
    success "Paket yöneticisi: $PACKAGE_MANAGER"
}

# Sistem güncellemesi
update_system() {
    info "Sistem güncelleniyor..."
    
    if [[ $EUID -eq 0 ]]; then
        $UPDATE_CMD
    else
        sudo $UPDATE_CMD
    fi
    
    success "Sistem güncellendi"
}

# Node.js kurulumu
install_nodejs() {
    info "Node.js kontrol ediliyor..."
    
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        info "Node.js zaten kurulu: $NODE_VERSION"
        
        # Minimum versiyon kontrolü
        REQUIRED_VERSION="18.0.0"
        NODE_MAJOR_VERSION=$(echo $NODE_VERSION | cut -d'.' -f1 | sed 's/v//')
        if [[ $NODE_MAJOR_VERSION -lt 18 ]]; then
            warning "Node.js versiyonu çok eski. Güncelleniyor..."
            install_nodejs_force
        else
            success "Node.js versiyonu uygun"
        fi
    else
        info "Node.js kuruluyor..."
        install_nodejs_force
    fi
}

# Node.js zorla kurulum
install_nodejs_force() {
    info "Node.js kurulumu başlatılıyor..."
    
    # NodeSource repository ekle
    if [[ $PACKAGE_MANAGER == "apt" ]]; then
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
    elif [[ $PACKAGE_MANAGER == "yum" ]]; then
        curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
        sudo yum install -y nodejs
    elif [[ $PACKAGE_MANAGER == "dnf" ]]; then
        curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
        sudo dnf install -y nodejs
    fi
    
    success "Node.js kuruldu: $(node --version)"
}

# NPM kurulumu
install_npm() {
    info "NPM kontrol ediliyor..."
    
    if command -v npm &> /dev/null; then
        NPM_VERSION=$(npm --version)
        success "NPM zaten kurulu: $NPM_VERSION"
    else
        error "NPM bulunamadı"
    fi
}

# PM2 kurulumu
install_pm2() {
    info "PM2 kontrol ediliyor..."
    
    if command -v pm2 &> /dev/null; then
        PM2_VERSION=$(pm2 --version)
        success "PM2 zaten kurulu: $PM2_VERSION"
    else
        info "PM2 kuruluyor..."
        sudo npm install -g pm2
        success "PM2 kuruldu: $(pm2 --version)"
    fi
}

# Nginx kurulumu
install_nginx() {
    info "Nginx kontrol ediliyor..."
    
    if command -v nginx &> /dev/null; then
        success "Nginx zaten kurulu"
    else
        info "Nginx kuruluyor..."
        
        if [[ $EUID -eq 0 ]]; then
            $INSTALL_CMD nginx
        else
            sudo $INSTALL_CMD nginx
        fi
        
        # Nginx'i başlat
        if [[ $EUID -eq 0 ]]; then
            systemctl enable nginx
            systemctl start nginx
        else
            sudo systemctl enable nginx
            sudo systemctl start nginx
        fi
        
        success "Nginx kuruldu ve başlatıldı"
    fi
}

# Firewall konfigürasyonu
configure_firewall() {
    info "Firewall konfigürasyonu..."
    
    if command -v ufw &> /dev/null; then
        if [[ $EUID -eq 0 ]]; then
            ufw allow 22
            ufw allow 80
            ufw allow 443
            ufw --force enable
        else
            sudo ufw allow 22
            sudo ufw allow 80
            sudo ufw allow 443
            sudo ufw --force enable
        fi
        success "UFW firewall konfigüre edildi"
    elif command -v firewall-cmd &> /dev/null; then
        if [[ $EUID -eq 0 ]]; then
            firewall-cmd --permanent --add-service=ssh
            firewall-cmd --permanent --add-service=http
            firewall-cmd --permanent --add-service=https
            firewall-cmd --reload
        else
            sudo firewall-cmd --permanent --add-service=ssh
            sudo firewall-cmd --permanent --add-service=http
            sudo firewall-cmd --permanent --add-service=https
            sudo firewall-cmd --reload
        fi
        success "Firewalld konfigüre edildi"
    else
        warning "Firewall bulunamadı, manuel konfigürasyon gerekebilir"
    fi
}

# Mevcut kurulum kontrolü
check_existing_installation() {
    info "Mevcut kurulum kontrol ediliyor..."
    
    INSTALL_DIR="/opt/beyztrack"
    
    if [[ -d "$INSTALL_DIR" ]] && [[ -f "$INSTALL_DIR/package.json" ]]; then
        warning "Mevcut BeyzTrack kurulumu bulundu!"
        echo ""
        echo -e "${YELLOW}Seçenekler:${NC}"
        echo -e "  1) Mevcut kurulumu sil ve sıfırdan kur"
        echo -e "  2) Mevcut kurulumun üzerine güncelle"
        echo -e "  3) Kurulumu iptal et"
        echo ""
        read -p "Seçiminizi yapın (1-3): " choice
        
        case $choice in
            1)
                info "Mevcut kurulum siliniyor..."
                # PM2 process'leri durdur
                pm2 stop beyztrack 2>/dev/null || true
                pm2 delete beyztrack 2>/dev/null || true
                
                # Eski dosyaları sil
                if [[ $EUID -eq 0 ]]; then
                    rm -rf $INSTALL_DIR
                    rm -rf /root/.uptime-kuma 2>/dev/null || true
                    rm -rf /home/*/.uptime-kuma 2>/dev/null || true
                else
                    sudo rm -rf $INSTALL_DIR
                    sudo rm -rf /root/.uptime-kuma 2>/dev/null || true
                    sudo rm -rf /home/*/.uptime-kuma 2>/dev/null || true
                fi
                success "Mevcut kurulum silindi"
                FRESH_INSTALL=true
                ;;
            2)
                info "Mevcut kurulumun üzerine güncelleme yapılacak"
                FRESH_INSTALL=false
                ;;
            3)
                info "Kurulum iptal edildi"
                exit 0
                ;;
            *)
                error "Geçersiz seçim"
                ;;
        esac
    else
        info "Mevcut kurulum bulunamadı, sıfırdan kurulum yapılacak"
        FRESH_INSTALL=true
    fi
}

# BeyzTrack kurulumu
install_beyztrack() {
    info "BeyzTrack kurulumu başlatılıyor..."
    
    # Kurulum dizini
    INSTALL_DIR="/opt/beyztrack"
    
    # Dizin oluştur
    if [[ $EUID -eq 0 ]]; then
        mkdir -p $INSTALL_DIR
    else
        sudo mkdir -p $INSTALL_DIR
    fi
    
    # Proje dosyalarını kopyala
    info "Proje dosyaları kopyalanıyor..."
    
    # GitHub'dan projeyi indir
    info "GitHub'dan proje indiriliyor..."
    cd /tmp
    if [[ -d "beyztrack" ]]; then
        rm -rf beyztrack
    fi
    
    git clone https://github.com/Coosef/beyztrack.git
    cd beyztrack
    
    # NPM bağımlılıklarını kur
    info "Bağımlılıklar kuruluyor..."
    npm install
    
    # Projeyi build et
    info "Proje build ediliyor..."
    npm run build
    
    # Build dosyalarını kurulum dizinine kopyala
    if [[ -d "dist" ]]; then
        info "Build dosyaları kopyalanıyor..."
        if [[ $EUID -eq 0 ]]; then
            # Eski dosyaları temizle
            rm -rf $INSTALL_DIR/*
            # Yeni dosyaları kopyala
            cp -r dist/* $INSTALL_DIR/
            cp package.json $INSTALL_DIR/
            cp -r server/ $INSTALL_DIR/ 2>/dev/null || true
            # İzinleri düzelt
            chown -R www-data:www-data $INSTALL_DIR 2>/dev/null || true
            chmod -R 755 $INSTALL_DIR 2>/dev/null || true
        else
            # Eski dosyaları temizle
            sudo rm -rf $INSTALL_DIR/*
            # Yeni dosyaları kopyala
            sudo cp -r dist/* $INSTALL_DIR/
            sudo cp package.json $INSTALL_DIR/
            sudo cp -r server/ $INSTALL_DIR/ 2>/dev/null || true
            # İzinleri düzelt
            sudo chown -R www-data:www-data $INSTALL_DIR 2>/dev/null || true
            sudo chmod -R 755 $INSTALL_DIR 2>/dev/null || true
        fi
        success "Build dosyaları kopyalandı ve izinler düzeltildi"
    else
        error "Build başarısız oldu"
    fi
    
    # Production bağımlılıklarını kur
    info "Production bağımlılıkları kuruluyor..."
    cd $INSTALL_DIR
    
    if [[ $EUID -eq 0 ]]; then
        npm install --production --legacy-peer-deps
    else
        sudo npm install --production --legacy-peer-deps
    fi
    
    # Sıfırdan kurulum için veritabanı dosyalarını temizle
    if [[ "$FRESH_INSTALL" == "true" ]]; then
        info "Sıfırdan kurulum için veritabanı dosyaları temizleniyor..."
        if [[ $EUID -eq 0 ]]; then
            rm -rf /root/.uptime-kuma 2>/dev/null || true
            rm -rf /home/*/.uptime-kuma 2>/dev/null || true
        else
            sudo rm -rf /root/.uptime-kuma 2>/dev/null || true
            sudo rm -rf /home/*/.uptime-kuma 2>/dev/null || true
        fi
        success "Veritabanı dosyaları temizlendi (sıfırdan kurulum)"
    else
        info "Mevcut kurulumun üzerine güncelleme yapılıyor"
    fi
    
    # Geçici dosyaları temizle
    cd /tmp
    rm -rf beyztrack
    
    success "BeyzTrack kuruldu: $INSTALL_DIR"
}

# PM2 konfigürasyonu
configure_pm2() {
    info "PM2 konfigürasyonu..."
    
    INSTALL_DIR="/opt/beyztrack"
    
    # PM2 ecosystem config oluştur
    cat > /tmp/beyztrack.config.js << EOF
module.exports = {
    apps: [{
        name: 'beyztrack',
        script: 'server/server.js',
        cwd: '$INSTALL_DIR',
        instances: 1,
        autorestart: true,
        watch: false,
        max_memory_restart: '1G',
        env: {
            NODE_ENV: 'production',
            PORT: 3001,
            UPTIME_KUMA_DISABLE_FRAME_SAMEORIGIN: '1'
        }
    }]
};
EOF
    
    if [[ $EUID -eq 0 ]]; then
        mv /tmp/beyztrack.config.js $INSTALL_DIR/
        chown www-data:www-data $INSTALL_DIR/beyztrack.config.js
        pm2 start $INSTALL_DIR/beyztrack.config.js
        pm2 save
        pm2 startup
    else
        sudo mv /tmp/beyztrack.config.js $INSTALL_DIR/
        sudo chown www-data:www-data $INSTALL_DIR/beyztrack.config.js
        pm2 start $INSTALL_DIR/beyztrack.config.js
        pm2 save
        pm2 startup
    fi
    
    success "PM2 konfigüre edildi ve backend server başlatıldı"
}

# Nginx konfigürasyonu
configure_nginx() {
    info "Nginx konfigürasyonu..."
    
    INSTALL_DIR="/opt/beyztrack"
    
    # Nginx config dosyası oluştur (Frontend için)
    cat > /tmp/beyztrack << EOF
server {
    listen 80;
    server_name _;
    root $INSTALL_DIR;
    index index.html;
    
    # Gzip sıkıştırma
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
    
    # Static dosyalar için cache
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # WebSocket proxy (Socket.io için)
    location /socket.io/ {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        proxy_read_timeout 86400;
    }
    
    # API proxy
    location /api/ {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
    
    # Vue.js router için
    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
EOF
    
    if [[ $EUID -eq 0 ]]; then
        mv /tmp/beyztrack /etc/nginx/sites-available/
        ln -sf /etc/nginx/sites-available/beyztrack /etc/nginx/sites-enabled/
        rm -f /etc/nginx/sites-enabled/default
        nginx -t && systemctl reload nginx
    else
        sudo mv /tmp/beyztrack /etc/nginx/sites-available/
        sudo ln -sf /etc/nginx/sites-available/beyztrack /etc/nginx/sites-enabled/
        sudo rm -f /etc/nginx/sites-enabled/default
        sudo nginx -t && sudo systemctl reload nginx
    fi
    
    success "Nginx konfigüre edildi"
}

# SSL sertifikası (opsiyonel)
install_ssl() {
    info "SSL sertifikası kurulumu..."
    
    if command -v certbot &> /dev/null; then
        success "Certbot zaten kurulu"
    else
        info "Certbot kuruluyor..."
        
        if [[ $PACKAGE_MANAGER == "apt" ]]; then
            if [[ $EUID -eq 0 ]]; then
                apt-get install -y certbot python3-certbot-nginx
            else
                sudo apt-get install -y certbot python3-certbot-nginx
            fi
        else
            warning "SSL kurulumu için manuel konfigürasyon gerekebilir"
        fi
    fi
}

# Kurulum sonrası bilgiler
show_final_info() {
    echo ""
    echo -e "${GREEN}🎉 BeyzTrack başarıyla kuruldu!${NC}"
    echo ""
    echo -e "${BLUE}📋 Kurulum Bilgileri:${NC}"
    echo -e "   • Kurulum Dizini: /opt/beyztrack"
    echo -e "   • Port: 3001"
    echo -e "   • Web Arayüzü: http://$(hostname -I | awk '{print $1}')"
    echo ""
    echo -e "${BLUE}🔧 Yönetim Komutları:${NC}"
    echo -e "   • PM2 Durumu: pm2 status"
    echo -e "   • PM2 Yeniden Başlat: pm2 restart beyztrack"
    echo -e "   • PM2 Durdur: pm2 stop beyztrack"
    echo -e "   • PM2 Logları: pm2 logs beyztrack"
    echo ""
    echo -e "${BLUE}📁 Önemli Dosyalar:${NC}"
    echo -e "   • PM2 Config: /opt/beyztrack/beyztrack.config.js"
    echo -e "   • Nginx Config: /etc/nginx/sites-available/beyztrack"
    echo ""
    echo -e "${YELLOW}⚠️  SSL sertifikası için:${NC}"
    echo -e "   sudo certbot --nginx -d yourdomain.com"
    echo ""
    echo -e "${GREEN}🚀 BeyzTrack hazır! Web arayüzüne erişebilirsiniz.${NC}"
}

# Ana kurulum fonksiyonu
main() {
    print_logo
    
    info "BeyzTrack kurulumu başlatılıyor..."
    echo ""
    
    check_system
    check_package_manager
    update_system
    install_nodejs
    install_npm
    install_pm2
    install_nginx
    configure_firewall
    check_existing_installation
    install_beyztrack
    configure_pm2
    configure_nginx
    install_ssl
    
    show_final_info
}

# Script'i çalıştır
main "$@"
