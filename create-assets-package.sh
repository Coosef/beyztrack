#!/bin/bash

# BeyzTrack Asset Paketi Oluşturucu
# Bu script logo ve asset dosyalarını Ubuntu sistemine kopyalamak için paket oluşturur

set -e

# Renk kodları
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Asset dizini oluştur
info "Asset dizini oluşturuluyor..."
mkdir -p beyztrack-assets/public
mkdir -p beyztrack-assets/dist

# Public dosyalarını kopyala
info "Public dosyaları kopyalanıyor..."
cp public/icon.png beyztrack-assets/public/
cp public/icon.svg beyztrack-assets/public/
cp public/favicon.ico beyztrack-assets/public/
cp public/icon-192x192.png beyztrack-assets/public/
cp public/icon-512x512.png beyztrack-assets/public/
cp public/apple-touch-icon.png beyztrack-assets/public/
cp public/apple-touch-icon-precomposed.png beyztrack-assets/public/

# Dist dosyalarını kopyala
info "Dist dosyaları kopyalanıyor..."
cp dist/icon.png beyztrack-assets/dist/
cp dist/icon.svg beyztrack-assets/dist/
cp dist/favicon.ico beyztrack-assets/dist/
cp dist/icon-192x192.png beyztrack-assets/dist/
cp dist/icon-512x512.png beyztrack-assets/dist/
cp dist/apple-touch-icon.png beyztrack-assets/dist/
cp dist/apple-touch-icon-precomposed.png beyztrack-assets/dist/

# Manifest.json'u kopyala
info "Manifest.json kopyalanıyor..."
cp public/manifest.json beyztrack-assets/public/

# README oluştur
info "README oluşturuluyor..."
cat > beyztrack-assets/README.md << 'EOF'
# BeyzTrack Assets

Bu paket BeyzTrack rebrand işlemi için gerekli logo ve asset dosyalarını içerir.

## İçerik

### Public Dizini
- `icon.png` - Ana logo (PNG)
- `icon.svg` - Ana logo (SVG)
- `favicon.ico` - Favicon
- `icon-192x192.png` - PWA icon (192x192)
- `icon-512x512.png` - PWA icon (512x512)
- `apple-touch-icon.png` - Apple touch icon
- `apple-touch-icon-precomposed.png` - Apple touch icon (precomposed)
- `manifest.json` - PWA manifest

### Dist Dizini
- Build edilmiş dosyalar için aynı asset'ler

## Kullanım

1. Bu paketi Ubuntu sistemine kopyalayın
2. `beyztrack-rebrand.sh` scriptini çalıştırın
3. Script otomatik olarak bu asset'leri kullanacak

## Manuel Kopyalama

```bash
# Public dizinine kopyala
cp public/* /path/to/uptime-kuma/public/

# Dist dizinine kopyala
cp dist/* /path/to/uptime-kuma/dist/
```
EOF

# Tar.gz paketi oluştur
info "Tar.gz paketi oluşturuluyor..."
tar -czf beyztrack-assets.tar.gz beyztrack-assets/

# Temizlik
info "Geçici dosyalar temizleniyor..."
rm -rf beyztrack-assets/

success "Asset paketi oluşturuldu: beyztrack-assets.tar.gz"
success "Paket boyutu: $(du -h beyztrack-assets.tar.gz | cut -f1)"

echo ""
echo "📦 Asset paketi hazır!"
echo "Ubuntu sisteminde şu komutla extract edin:"
echo "tar -xzf beyztrack-assets.tar.gz"
