#!/bin/bash

# BeyzTrack Complete Rebrand Script
# Bu script eksik bağımlılıkları kurar ve rebrand işlemini tamamlar

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

# Node.js ve npm kontrolü
check_nodejs() {
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

# NPM bağımlılıklarını kur
install_dependencies() {
    local uptime_dir="$1"
    
    info "NPM bağımlılıkları kuruluyor..."
    
    cd "$uptime_dir"
    
    # NPM install çalıştır
    sudo npm install
    
    success "NPM bağımlılıkları kuruldu"
}

# Frontend dosyalarını güncelle
update_frontend_files() {
    local uptime_dir="$1"
    
    info "Frontend dosyaları güncelleniyor..."
    
    # Layout.vue'yu güncelle
    local layout_file="$uptime_dir/src/layouts/Layout.vue"
    if [[ -f "$layout_file" ]]; then
        info "Layout.vue güncelleniyor..."
        sudo cp "$layout_file" "${layout_file}.backup"
        
        # Uptime Kuma'yı BeyzTrack ile değiştir
        sudo sed -i 's/Uptime Kuma/BeyzTrack/g' "$layout_file"
        sudo sed -i 's/alt="Uptime Kuma Logo"/alt="BeyzTrack Logo"/g' "$layout_file"
        
        success "Layout.vue güncellendi"
    fi
    
    # App.vue'yu güncelle
    local app_file="$uptime_dir/src/App.vue"
    if [[ -f "$app_file" ]]; then
        info "App.vue güncelleniyor..."
        sudo cp "$app_file" "${app_file}.backup"
        
        sudo sed -i 's/Uptime Kuma/BeyzTrack/g' "$app_file"
        
        success "App.vue güncellendi"
    fi
    
    # Diğer Vue dosyalarını güncelle
    sudo find "$uptime_dir/src" -name "*.vue" -type f | while read -r file; do
        if sudo grep -q "Uptime Kuma" "$file"; then
            info "Güncelleniyor: $(basename "$file")"
            sudo cp "$file" "${file}.backup"
            sudo sed -i 's/Uptime Kuma/BeyzTrack/g' "$file"
        fi
    done
}

# Logo dosyalarını oluştur
create_logo_files() {
    local uptime_dir="$1"
    local public_dir="$uptime_dir/public"
    local dist_dir="$uptime_dir/dist"
    
    info "Logo dosyaları oluşturuluyor..."
    
    # Basit bir BeyzTrack logosu oluştur (SVG)
    sudo tee "$public_dir/icon.svg" > /dev/null << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <circle cx="50" cy="50" r="45" fill="#1e3a8a" stroke="#3b82f6" stroke-width="2"/>
  <text x="50" y="60" text-anchor="middle" font-family="Arial, sans-serif" font-size="24" font-weight="bold" fill="white">B</text>
</svg>
EOF
    
    # PNG versiyonu için ImageMagick kullan (varsa)
    if command -v convert &> /dev/null; then
        sudo convert "$public_dir/icon.svg" "$public_dir/icon.png"
        sudo convert "$public_dir/icon.svg" -resize 192x192 "$public_dir/icon-192x192.png"
        sudo convert "$public_dir/icon.svg" -resize 512x512 "$public_dir/icon-512x512.png"
        sudo convert "$public_dir/icon.svg" -resize 32x32 "$public_dir/favicon.ico"
    else
        # ImageMagick yoksa SVG'yi kopyala
        sudo cp "$public_dir/icon.svg" "$public_dir/icon.png"
        sudo cp "$public_dir/icon.svg" "$public_dir/icon-192x192.png"
        sudo cp "$public_dir/icon.svg" "$public_dir/icon-512x512.png"
        sudo cp "$public_dir/icon.svg" "$public_dir/favicon.ico"
    fi
    
    # Dist dizinine de kopyala
    if [[ -d "$dist_dir" ]]; then
        sudo cp "$public_dir/icon.svg" "$dist_dir/"
        sudo cp "$public_dir/icon.png" "$dist_dir/"
        sudo cp "$public_dir/icon-192x192.png" "$dist_dir/"
        sudo cp "$public_dir/icon-512x512.png" "$dist_dir/"
        sudo cp "$public_dir/favicon.ico" "$dist_dir/"
    fi
    
    success "Logo dosyaları oluşturuldu"
}

# Build işlemi yap
build_frontend() {
    local uptime_dir="$1"
    
    info "Frontend build ediliyor..."
    
    cd "$uptime_dir"
    
    # NPM build komutu çalıştır
    if [[ -f "package.json" ]]; then
        sudo npm run build
        success "Frontend build edildi"
    else
        warning "Package.json bulunamadı, build atlanıyor..."
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

# Ana fonksiyon
main() {
    echo "🚀 BeyzTrack Complete Rebrand Script"
    echo "====================================="
    echo ""
    
    # Node.js ve npm kontrolü
    check_nodejs
    
    # Uptime Kuma dizinini bul
    UPTIME_DIR=$(find_uptime_kuma_dir)
    info "Uptime Kuma dizini: $UPTIME_DIR"
    
    # NPM bağımlılıklarını kur
    install_dependencies "$UPTIME_DIR"
    
    # Frontend dosyalarını güncelle
    update_frontend_files "$UPTIME_DIR"
    
    # Logo dosyalarını oluştur
    create_logo_files "$UPTIME_DIR"
    
    # Build işlemi yap
    build_frontend "$UPTIME_DIR"
    
    # Servisi yeniden başlat
    restart_service "$UPTIME_DIR"
    
    echo ""
    success "🎉 BeyzTrack complete rebrand tamamlandı!"
    echo ""
    echo -e "${BLUE}📋 Yapılan İşlemler:${NC}"
    echo "   • Node.js ve NPM kuruldu/kontrol edildi"
    echo "   • NPM bağımlılıkları kuruldu"
    echo "   • Frontend dosyaları güncellendi"
    echo "   • Logo dosyaları oluşturuldu"
    echo "   • Frontend build edildi"
    echo "   • Servis yeniden başlatıldı"
    echo ""
    echo -e "${GREEN}🚀 Şimdi tarayıcıda BeyzTrack'i görebilirsiniz!${NC}"
}

# Script'i çalıştır
main "$@"
