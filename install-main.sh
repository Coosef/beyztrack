#!/bin/bash

# BeyzTrack - Ana Kurulum Scripti
# Bu script 2 aşamalı kurulum seçenekleri sunar

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
echo "║              Monitoring & Reporting System                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Kurulum seçenekleri
show_menu() {
    echo -e "${CYAN}📋 Kurulum Seçenekleri:${NC}"
    echo -e "${YELLOW}1.${NC} Sadece Orijinal Uptime Kuma (Sonra branding yapılabilir)"
    echo -e "${YELLOW}2.${NC} Tam BeyzTrack Kurulumu (Orijinal + Branding)"
    echo -e "${YELLOW}3.${NC} Sadece Branding (Uptime Kuma zaten kurulu)"
    echo -e "${YELLOW}4.${NC} Çıkış"
    echo ""
}

# Kurulum seçimi
select_installation() {
    if [[ -t 0 ]]; then
        # Interactive mode
        while true; do
            show_menu
            read -p "Seçiminizi yapın (1-4): " choice
            case $choice in
                1)
                    echo -e "${CYAN}🚀 Orijinal Uptime Kuma kurulumu başlatılıyor...${NC}"
                    install_original
                    break
                    ;;
                2)
                    echo -e "${CYAN}🚀 Tam BeyzTrack kurulumu başlatılıyor...${NC}"
                    install_full
                    break
                    ;;
                3)
                    echo -e "${CYAN}🎨 Branding uygulanıyor...${NC}"
                    install_branding
                    break
                    ;;
                4)
                    echo -e "${YELLOW}👋 Çıkılıyor...${NC}"
                    exit 0
                    ;;
                *)
                    echo -e "${RED}❌ Geçersiz seçim! Lütfen 1-4 arası bir sayı girin.${NC}"
                    ;;
            esac
        done
    else
        # Non-interactive mode - default to full installation
        echo -e "${CYAN}🚀 Non-interactive mode: Tam BeyzTrack kurulumu başlatılıyor...${NC}"
        install_full
    fi
}

# Orijinal Uptime Kuma kurulumu
install_original() {
    echo -e "${CYAN}📥 Orijinal Uptime Kuma kurulum scripti indiriliyor...${NC}"
    
    # Orijinal kurulum scriptini indir ve çalıştır
    curl -sSL https://raw.githubusercontent.com/Coosef/beyztrack/main/install-original.sh | bash
}

# Tam BeyzTrack kurulumu
install_full() {
    echo -e "${CYAN}📥 Orijinal Uptime Kuma kurulumu...${NC}"
    install_original
    
    echo -e "${CYAN}📥 BeyzTrack branding uygulanıyor...${NC}"
    install_branding
}

# Sadece branding
install_branding() {
    echo -e "${CYAN}📥 BeyzTrack branding scripti indiriliyor...${NC}"
    
    # Branding scriptini indir ve çalıştır
    curl -sSL https://raw.githubusercontent.com/Coosef/beyztrack/main/brand.sh | bash
}

# Ana fonksiyon
main() {
    select_installation
}

# Script'i çalıştır
main "$@"
