#!/bin/bash

# BeyzTrack Build and Deploy Script
# Bu script frontend'i build eder ve deploy eder

set -e

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Uptime Kuma dizinini bul
find_uptime_kuma_dir() {
    local possible_dirs=(
        "/opt/uptime-kuma"
        "/home/$USER/uptime-kuma"
        "/var/www/uptime-kuma"
        "/usr/local/uptime-kuma"
        "/opt/uptime-kuma-master"
    )
    
    for dir in "${possible_dirs[@]}"; do
        if [[ -d "$dir" && -f "$dir/package.json" ]]; then
            echo "$dir"
            return 0
        fi
    done
    
    echo "/opt/uptime-kuma"
}

# Node.js ve npm kontrolü
check_dependencies() {
    info "Node.js ve npm kontrol ediliyor..."
    
    if ! command -v node &> /dev/null; then
        error "Node.js bulunamadı!"
        info "Node.js kuruluyor..."
        
        # Node.js kurulumu
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
        
        success "Node.js kuruldu"
    else
        info "Node.js mevcut: $(node --version)"
    fi
    
    if ! command -v npm &> /dev/null; then
        error "NPM bulunamadı!"
        sudo apt-get install -y npm
        success "NPM kuruldu"
    else
        info "NPM mevcut: $(npm --version)"
    fi
}

# NPM bağımlılıklarını kur
install_dependencies() {
    local uptime_dir="$1"
    
    info "NPM bağımlılıkları kuruluyor..."
    
    cd "$uptime_dir"
    
    # NPM install çalıştır
    sudo npm install
    
    success "NPM bağımlılıkları kuruldu"
}

# Frontend'i build et
build_frontend() {
    local uptime_dir="$1"
    
    info "Frontend build ediliyor..."
    
    cd "$uptime_dir"
    
    # NPM build komutu çalıştır
    if [[ -f "package.json" ]]; then
        sudo npm run build
        success "Frontend build edildi"
    else
        error "Package.json bulunamadı!"
        exit 1
    fi
}

# Build dosyalarını kontrol et
check_build_files() {
    local uptime_dir="$1"
    local dist_dir="$uptime_dir/dist"
    
    info "Build dosyaları kontrol ediliyor..."
    
    if [[ -d "$dist_dir" ]]; then
        info "Dist dizini mevcut: $dist_dir"
        
        # Önemli dosyaları kontrol et
        local important_files=(
            "index.html"
            "assets"
            "icon.png"
            "favicon.ico"
        )
        
        for file in "${important_files[@]}"; do
            if [[ -e "$dist_dir/$file" ]]; then
                success "✓ $file mevcut"
            else
                warning "⚠ $file bulunamadı"
            fi
        done
        
        # Assets dizinindeki dosya sayısını kontrol et
        if [[ -d "$dist_dir/assets" ]]; then
            local asset_count=$(find "$dist_dir/assets" -type f | wc -l)
            info "Assets dizininde $asset_count dosya bulundu"
        fi
        
    else
        error "Dist dizini bulunamadı!"
        exit 1
    fi
}

# Servisi yeniden başlat
restart_service() {
    info "Servis yeniden başlatılıyor..."
    
    # PM2 ile çalışıyorsa
    if command -v pm2 &> /dev/null; then
        if pm2 list | grep -q "uptime-kuma\|beyztrack"; then
            sudo pm2 restart all
            success "PM2 servisleri yeniden başlatıldı"
        fi
    fi
    
    # Systemd ile çalışıyorsa
    if systemctl is-active --quiet uptime-kuma 2>/dev/null; then
        sudo systemctl restart uptime-kuma
        success "Systemd servisi yeniden başlatıldı"
    fi
}

# Cache'i temizle
clear_cache() {
    info "Tarayıcı cache'i temizleniyor..."
    
    # Nginx cache'i temizle (varsa)
    if command -v nginx &> /dev/null; then
        sudo rm -rf /var/cache/nginx/* 2>/dev/null || true
    fi
    
    # PM2 log'larını temizle
    if command -v pm2 &> /dev/null; then
        sudo pm2 flush
    fi
    
    success "Cache temizlendi"
}

# Ana fonksiyon
main() {
    echo "🚀 BeyzTrack Build and Deploy Script"
    echo "===================================="
    echo ""
    
    # Uptime Kuma dizinini bul
    UPTIME_DIR=$(find_uptime_kuma_dir)
    info "Uptime Kuma dizini: $UPTIME_DIR"
    
    # Node.js ve npm kontrolü
    check_dependencies
    
    # NPM bağımlılıklarını kur
    install_dependencies "$UPTIME_DIR"
    
    # Frontend'i build et
    build_frontend "$UPTIME_DIR"
    
    # Build dosyalarını kontrol et
    check_build_files "$UPTIME_DIR"
    
    # Cache'i temizle
    clear_cache
    
    # Servisi yeniden başlat
    restart_service "$UPTIME_DIR"
    
    echo ""
    success "🎉 BeyzTrack build and deploy tamamlandı!"
    echo ""
    echo -e "${BLUE}📋 Yapılan İşlemler:${NC}"
    echo "   • Node.js ve NPM kontrol edildi"
    echo "   • NPM bağımlılıkları kuruldu"
    echo "   • Frontend build edildi"
    echo "   • Build dosyaları kontrol edildi"
    echo "   • Cache temizlendi"
    echo "   • Servis yeniden başlatıldı"
    echo ""
    echo -e "${GREEN}🚀 Şimdi tarayıcıda Reports ve Todo List'i görebilirsiniz!${NC}"
    echo ""
    echo -e "${YELLOW}💡 İpucu: Tarayıcıda Ctrl+F5 ile hard refresh yapın!${NC}"
}

# Script'i çalıştır
main "$@"
