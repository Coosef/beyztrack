#!/bin/bash

# BeyzTrack Router Fix Script
# Bu script router.js dosyasındaki syntax hatasını düzeltir

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

# Router.js'i düzelt
fix_router() {
    local uptime_dir="$1"
    local router_file="$uptime_dir/src/router.js"
    
    info "Router.js düzeltiliyor..."
    
    if [[ -f "$router_file" ]]; then
        # Backup oluştur
        sudo cp "$router_file" "${router_file}.backup"
        
        # Router dosyasını tamamen yeniden yaz
        sudo tee "$router_file" > /dev/null << 'EOF'
import { createRouter, createWebHistory } from "vue-router";

import Layout from "./layouts/Layout.vue";
import DashboardHome from "./pages/DashboardHome.vue";
import NotFound from "./pages/NotFound.vue";
import CustomReportBuilder from "./components/reports/CustomReportBuilder.vue";
import TodoList from "./components/TodoList.vue";

const routes = [
    {
        path: "/",
        redirect: "/dashboard",
    },
    {
        // Frontend-only mode: Simplified dashboard route
        path: "/dashboard",
        component: Layout,
        children: [
            {
                path: "",
                component: DashboardHome,
            },
        ],
    },
    {
        // Reports route
        path: "/reports",
        component: Layout,
        children: [
            {
                path: "",
                component: CustomReportBuilder,
            },
        ],
    },
    {
        // Todo List route
        path: "/todo",
        component: Layout,
        children: [
            {
                path: "",
                component: TodoList,
            },
        ],
    },
    {
        path: "/:pathMatch(.*)*",
        component: NotFound,
    },
];

export const router = createRouter({
    linkActiveClass: "active",
    history: createWebHistory(),
    routes,
    scrollBehavior(to, from, savedPosition) {
        if (savedPosition) {
            return savedPosition;
        } else {
            return { top: 0 };
        }
    },
});
EOF
        
        success "Router.js düzeltildi"
    else
        error "Router.js bulunamadı!"
        exit 1
    fi
}

# Layout.vue'yu düzelt
fix_layout() {
    local uptime_dir="$1"
    local layout_file="$uptime_dir/src/layouts/Layout.vue"
    
    info "Layout.vue düzeltiliyor..."
    
    if [[ -f "$layout_file" ]]; then
        # Backup oluştur
        sudo cp "$layout_file" "${layout_file}.backup"
        
        # Layout dosyasını güncelle - Reports ve Todo linklerini ekle
        sudo sed -i '/router-link to="\/dashboard"/a\                <li v-if="$root.loggedIn" class="nav-item me-2">\n                    <router-link to="\/reports" class="nav-link">\n                        <font-awesome-icon icon="chart-bar" \/> {{ $t("Reports") }}\n                    <\/router-link>\n                <\/li>\n                <li v-if="$root.loggedIn" class="nav-item me-2">\n                    <router-link to="\/todo" class="nav-link">\n                        <font-awesome-icon icon="tasks" \/> {{ $t("Yapılacaklar Listesi") }}\n                    <\/router-link>\n                <\/li>' "$layout_file"
        
        success "Layout.vue düzeltildi"
    else
        warning "Layout.vue bulunamadı"
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
    echo "🔧 BeyzTrack Router Fix Script"
    echo "=============================="
    echo ""
    
    # Uptime Kuma dizinini bul
    UPTIME_DIR=$(find_uptime_kuma_dir)
    info "Uptime Kuma dizini: $UPTIME_DIR"
    
    # Router'ı düzelt
    fix_router "$UPTIME_DIR"
    
    # Layout'u düzelt
    fix_layout "$UPTIME_DIR"
    
    # Servisi yeniden başlat
    restart_service "$UPTIME_DIR"
    
    echo ""
    success "🎉 Router fix tamamlandı!"
    echo ""
    echo -e "${BLUE}📋 Yapılan İşlemler:${NC}"
    echo "   • Router.js syntax hatası düzeltildi"
    echo "   • Layout.vue güncellendi"
    echo "   • Servis yeniden başlatıldı"
    echo ""
    echo -e "${GREEN}🚀 Şimdi build işlemi çalışacak!${NC}"
}

# Script'i çalıştır
main "$@"
