#!/bin/bash

# BeyzTrack Rebrand Script
# Bu script Ubuntu sistemindeki normal Uptime Kuma kurulumunu BeyzTrack'e dönüştürür

set -e

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logo
print_logo() {
    echo -e "${BLUE}"
    echo "  ____                    _____             _    "
    echo " |  _ \                  |_   _|           | |   "
    echo " | |_) |_   _ _ __   ___    | |  _ __  __ _| | __"
    echo " |  _ <| | | | '_ \ / _ \   | | | '_ \/ _\` | |/ /"
    echo " | |_) | |_| | | | |  __/  _| |_| | | | (_| |   < "
    echo " |____/ \__,_|_| |_|\___| |_____|_| |_|\__,_|_|\_\\"
    echo ""
    echo -e "${NC}🚀 BeyzTrack Rebrand Script"
    echo "=================================="
    echo ""
}

# Bilgi mesajı
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Başarı mesajı
success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Uyarı mesajı
warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Hata mesajı
error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Uptime Kuma kurulum dizinini bul
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
    
    # Bulunamazsa kullanıcıdan sor
    echo ""
    warning "Uptime Kuma kurulum dizini otomatik bulunamadı."
    echo "Lütfen Uptime Kuma'nın kurulu olduğu dizini girin:"
    read -p "Dizin yolu: " custom_dir
    
    if [[ -d "$custom_dir" && -f "$custom_dir/package.json" ]]; then
        echo "$custom_dir"
        return 0
    else
        error "Geçersiz dizin: $custom_dir"
        exit 1
    fi
}

# Backup oluştur
create_backup() {
    local uptime_dir="$1"
    local backup_dir="${uptime_dir}_backup_$(date +%Y%m%d_%H%M%S)"
    
    info "Backup oluşturuluyor: $backup_dir"
    
    if [[ $EUID -eq 0 ]]; then
        cp -r "$uptime_dir" "$backup_dir"
        chown -R root:root "$backup_dir"
    else
        sudo cp -r "$uptime_dir" "$backup_dir"
        sudo chown -R root:root "$backup_dir"
    fi
    
    success "Backup oluşturuldu: $backup_dir"
    echo "$backup_dir"
}

# Package.json'u güncelle
update_package_json() {
    local uptime_dir="$1"
    local package_file="$uptime_dir/package.json"
    
    info "Package.json güncelleniyor..."
    
    # Backup oluştur
    cp "$package_file" "${package_file}.backup"
    
    # Name'i beyztrack olarak değiştir
    sed -i 's/"name": "uptime-kuma"/"name": "beyztrack"/g' "$package_file"
    
    success "Package.json güncellendi"
}

# Index.html'i güncelle
update_index_html() {
    local uptime_dir="$1"
    local index_file="$uptime_dir/index.html"
    
    if [[ -f "$index_file" ]]; then
        info "Index.html güncelleniyor..."
        
        # Backup oluştur
        cp "$index_file" "${index_file}.backup"
        
        # Title ve meta bilgilerini güncelle
        sed -i 's/<title>Uptime Kuma<\/title>/<title>BeyzTrack - Monitoring System<\/title>/g' "$index_file"
        sed -i 's/Uptime Kuma/BeyzTrack/g' "$index_file"
        sed -i 's/uptime-kuma/beyztrack/g' "$index_file"
        
        success "Index.html güncellendi"
    else
        warning "Index.html bulunamadı, atlanıyor..."
    fi
}

# Manifest.json'u güncelle
update_manifest() {
    local uptime_dir="$1"
    local manifest_file="$uptime_dir/public/manifest.json"
    
    if [[ -f "$manifest_file" ]]; then
        info "Manifest.json güncelleniyor..."
        
        # Backup oluştur
        cp "$manifest_file" "${manifest_file}.backup"
        
        # Manifest içeriğini güncelle
        cat > "$manifest_file" << 'EOF'
{
    "name": "BeyzTrack - Monitoring System",
    "short_name": "BeyzTrack",
    "description": "Beyz System Monitoring and Uptime Tracking",
    "start_url": "/",
    "background_color": "#1e3a8a",
    "theme_color": "#3b82f6",
    "display": "standalone",
    "orientation": "portrait",
    "icons": [
        {
            "src": "icon-192x192.png",
            "sizes": "192x192",
            "type": "image/png",
            "purpose": "any maskable"
        },
        {
            "src": "icon-512x512.png",
            "sizes": "512x512",
            "type": "image/png",
            "purpose": "any maskable"
        },
        {
            "src": "icon.svg",
            "sizes": "any",
            "type": "image/svg+xml",
            "purpose": "any"
        }
    ],
    "categories": ["business", "productivity", "utilities"],
    "lang": "tr",
    "dir": "ltr"
}
EOF
        
        success "Manifest.json güncellendi"
    else
        warning "Manifest.json bulunamadı, atlanıyor..."
    fi
}

# Server.js'i güncelle
update_server_js() {
    local uptime_dir="$1"
    local server_file="$uptime_dir/server/server.js"
    
    if [[ -f "$server_file" ]]; then
        info "Server.js güncelleniyor..."
        
        # Backup oluştur
        cp "$server_file" "${server_file}.backup"
        
        # Welcome mesajını güncelle
        sed -i 's/console.log("Welcome to Uptime Kuma");/console.log("Welcome to BeyzTrack");/g' "$server_file"
        sed -i 's/Uptime Kuma Version:/BeyzTrack Version:/g' "$server_file"
        
        success "Server.js güncellendi"
    else
        warning "Server.js bulunamadı, atlanıyor..."
    fi
}

# Layout.vue'yu güncelle
update_layout_vue() {
    local uptime_dir="$1"
    local layout_file="$uptime_dir/src/layouts/Layout.vue"
    
    if [[ -f "$layout_file" ]]; then
        info "Layout.vue güncelleniyor..."
        
        # Backup oluştur
        cp "$layout_file" "${layout_file}.backup"
        
        # Logo ve başlık güncellemeleri
        sed -i 's/Uptime Kuma/BeyzTrack/g' "$layout_file"
        sed -i 's/alt="Uptime Kuma Logo"/alt="BeyzTrack Logo"/g' "$layout_file"
        
        success "Layout.vue güncellendi"
    else
        warning "Layout.vue bulunamadı, atlanıyor..."
    fi
}

# Logo dosyalarını kopyala
copy_logo_files() {
    local uptime_dir="$1"
    local public_dir="$uptime_dir/public"
    local dist_dir="$uptime_dir/dist"
    
    info "Logo dosyaları kopyalanıyor..."
    
    # Bu scriptin bulunduğu dizindeki logo dosyalarını kopyala
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Public dizinine kopyala
    if [[ -d "$public_dir" ]]; then
        # Yeni logo dosyalarını kopyala (eğer varsa)
        if [[ -f "$script_dir/public/icon.png" ]]; then
            cp "$script_dir/public/icon.png" "$public_dir/"
        fi
        if [[ -f "$script_dir/public/icon.svg" ]]; then
            cp "$script_dir/public/icon.svg" "$public_dir/"
        fi
        if [[ -f "$script_dir/public/favicon.ico" ]]; then
            cp "$script_dir/public/favicon.ico" "$public_dir/"
        fi
        if [[ -f "$script_dir/public/icon-192x192.png" ]]; then
            cp "$script_dir/public/icon-192x192.png" "$public_dir/"
        fi
        if [[ -f "$script_dir/public/icon-512x512.png" ]]; then
            cp "$script_dir/public/icon-512x512.png" "$public_dir/"
        fi
    fi
    
    # Dist dizinine kopyala
    if [[ -d "$dist_dir" ]]; then
        if [[ -f "$script_dir/dist/icon.png" ]]; then
            cp "$script_dir/dist/icon.png" "$dist_dir/"
        fi
        if [[ -f "$script_dir/dist/icon.svg" ]]; then
            cp "$script_dir/dist/icon.svg" "$dist_dir/"
        fi
        if [[ -f "$script_dir/dist/favicon.ico" ]]; then
            cp "$script_dir/dist/favicon.ico" "$dist_dir/"
        fi
        if [[ -f "$script_dir/dist/icon-192x192.png" ]]; then
            cp "$script_dir/dist/icon-192x192.png" "$dist_dir/"
        fi
        if [[ -f "$script_dir/dist/icon-512x512.png" ]]; then
            cp "$script_dir/dist/icon-512x512.png" "$dist_dir/"
        fi
    fi
    
    success "Logo dosyaları kopyalandı"
}

# Türkçe dil dosyasını güncelle
update_turkish_lang() {
    local uptime_dir="$1"
    local lang_file="$uptime_dir/src/lang/tr-TR.json"
    
    if [[ -f "$lang_file" ]]; then
        info "Türkçe dil dosyası güncelleniyor..."
        
        # Backup oluştur
        cp "$lang_file" "${lang_file}.backup"
        
        # Bazı önemli çevirileri güncelle
        sed -i 's/"BeyzTrack": "Uptime Kuma"/"BeyzTrack": "BeyzTrack"/g' "$lang_file"
        
        success "Türkçe dil dosyası güncellendi"
    else
        warning "Türkçe dil dosyası bulunamadı, atlanıyor..."
    fi
}

# Servisi yeniden başlat
restart_service() {
    local uptime_dir="$1"
    
    info "Servis yeniden başlatılıyor..."
    
    # PM2 ile çalışıyorsa
    if command -v pm2 &> /dev/null; then
        if pm2 list | grep -q "uptime-kuma\|beyztrack"; then
            pm2 restart all
            success "PM2 servisleri yeniden başlatıldı"
        fi
    fi
    
    # Systemd ile çalışıyorsa
    if systemctl is-active --quiet uptime-kuma 2>/dev/null; then
        sudo systemctl restart uptime-kuma
        success "Systemd servisi yeniden başlatıldı"
    fi
    
    # Docker ile çalışıyorsa
    if docker ps | grep -q "uptime-kuma\|beyztrack"; then
        docker restart $(docker ps | grep "uptime-kuma\|beyztrack" | awk '{print $1}')
        success "Docker container yeniden başlatıldı"
    fi
}

# Ana fonksiyon
main() {
    print_logo
    
    # Uptime Kuma dizinini bul
    info "Uptime Kuma kurulum dizini aranıyor..."
    UPTIME_DIR=$(find_uptime_kuma_dir)
    success "Uptime Kuma dizini bulundu: $UPTIME_DIR"
    
    # Backup oluştur
    BACKUP_DIR=$(create_backup "$UPTIME_DIR")
    
    # Dosyaları güncelle
    update_package_json "$UPTIME_DIR"
    update_index_html "$UPTIME_DIR"
    update_manifest "$UPTIME_DIR"
    update_server_js "$UPTIME_DIR"
    update_layout_vue "$UPTIME_DIR"
    copy_logo_files "$UPTIME_DIR"
    update_turkish_lang "$UPTIME_DIR"
    
    # Servisi yeniden başlat
    restart_service "$UPTIME_DIR"
    
    # Sonuç
    echo ""
    success "🎉 BeyzTrack rebrand işlemi tamamlandı!"
    echo ""
    echo -e "${BLUE}📋 Yapılan Değişiklikler:${NC}"
    echo "   • Package.json: name → beyztrack"
    echo "   • Index.html: title ve meta bilgileri"
    echo "   • Manifest.json: PWA ayarları"
    echo "   • Server.js: welcome mesajı"
    echo "   • Layout.vue: logo ve başlık"
    echo "   • Logo dosyaları: yeni iconlar"
    echo "   • Türkçe dil desteği: geliştirildi"
    echo ""
    echo -e "${BLUE}📁 Backup Dizini:${NC} $BACKUP_DIR"
    echo ""
    echo -e "${GREEN}🚀 BeyzTrack hazır! Web arayüzüne erişebilirsiniz.${NC}"
}

# Script'i çalıştır
main "$@"
