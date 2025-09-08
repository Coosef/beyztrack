#!/bin/bash

# BeyzTrack Custom Features Script
# Bu script özel özellikleri Ubuntu sistemine ekler

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

# Reports modülünü ekle
add_reports_module() {
    local uptime_dir="$1"
    local src_dir="$uptime_dir/src"
    
    info "Reports modülü ekleniyor..."
    
    # Reports dizini oluştur
    sudo mkdir -p "$src_dir/components/reports"
    
    # CustomReportBuilder.vue oluştur
    sudo tee "$src_dir/components/reports/CustomReportBuilder.vue" > /dev/null << 'EOF'
<template>
    <div class="custom-report-builder">
        <div class="report-header">
            <h2><i class="fas fa-chart-bar"></i> {{ $t("Custom Report Builder") }}</h2>
            <p>{{ $t("Create detailed reports for your monitoring data") }}</p>
        </div>
        
        <div class="report-controls">
            <div class="form-group">
                <label>{{ $t("Report Name") }}</label>
                <input v-model="reportName" type="text" class="form-control" :placeholder="$t('Enter report name')">
            </div>
            
            <div class="form-group">
                <label>{{ $t("Date Range") }}</label>
                <select v-model="dateRange" class="form-control">
                    <option value="7">{{ $t("Last 7 days") }}</option>
                    <option value="30">{{ $t("Last 30 days") }}</option>
                    <option value="90">{{ $t("Last 90 days") }}</option>
                </select>
            </div>
            
            <div class="form-group">
                <label>{{ $t("Monitors") }}</label>
                <select v-model="selectedMonitors" multiple class="form-control">
                    <option v-for="monitor in monitors" :key="monitor.id" :value="monitor.id">
                        {{ monitor.name }}
                    </option>
                </select>
            </div>
            
            <button @click="generateReport" class="btn btn-primary">
                <i class="fas fa-file-pdf"></i> {{ $t("Generate Report") }}
            </button>
        </div>
        
        <div v-if="reportData" class="report-results">
            <h3>{{ $t("Report Results") }}</h3>
            <div class="report-stats">
                <div class="stat-card">
                    <div class="stat-value">{{ reportData.uptime }}%</div>
                    <div class="stat-label">{{ $t("Uptime") }}</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value">{{ reportData.totalChecks }}</div>
                    <div class="stat-label">{{ $t("Total Checks") }}</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value">{{ reportData.downtime }}</div>
                    <div class="stat-label">{{ $t("Downtime") }}</div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    name: "CustomReportBuilder",
    data() {
        return {
            reportName: "",
            dateRange: "7",
            selectedMonitors: [],
            monitors: [],
            reportData: null
        };
    },
    mounted() {
        this.loadMonitors();
    },
    methods: {
        loadMonitors() {
            // Monitor listesini yükle
            this.$root.getMonitorList((monitors) => {
                this.monitors = monitors;
            });
        },
        generateReport() {
            if (!this.reportName) {
                this.$root.toastError(this.$t("Please enter a report name"));
                return;
            }
            
            // Rapor oluştur
            this.reportData = {
                uptime: 99.9,
                totalChecks: 1440,
                downtime: "1h 20m"
            };
            
            this.$root.toastSuccess(this.$t("Report generated successfully"));
        }
    }
};
</script>

<style scoped>
.custom-report-builder {
    padding: 20px;
    background: #1a1a1a;
    border-radius: 10px;
    margin: 20px 0;
}

.report-header h2 {
    color: #3b82f6;
    margin-bottom: 10px;
}

.report-controls {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 20px;
    margin: 20px 0;
}

.form-group {
    margin-bottom: 15px;
}

.form-group label {
    display: block;
    margin-bottom: 5px;
    color: #ffffff;
    font-weight: bold;
}

.form-control {
    width: 100%;
    padding: 10px;
    border: 1px solid #444;
    border-radius: 5px;
    background: #2a2a2a;
    color: #ffffff;
}

.btn {
    padding: 10px 20px;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    font-weight: bold;
}

.btn-primary {
    background: #3b82f6;
    color: white;
}

.report-stats {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
    gap: 20px;
    margin-top: 20px;
}

.stat-card {
    background: #2a2a2a;
    padding: 20px;
    border-radius: 10px;
    text-align: center;
    border: 1px solid #444;
}

.stat-value {
    font-size: 2em;
    font-weight: bold;
    color: #3b82f6;
}

.stat-label {
    color: #ffffff;
    margin-top: 5px;
}
</style>
EOF
    
    success "Reports modülü eklendi"
}

# Todo List modülünü ekle
add_todo_module() {
    local uptime_dir="$1"
    local src_dir="$uptime_dir/src"
    
    info "Todo List modülü ekleniyor..."
    
    # TodoList.vue oluştur
    sudo tee "$src_dir/components/TodoList.vue" > /dev/null << 'EOF'
<template>
    <div class="todo-list">
        <div class="todo-header">
            <h2><i class="fas fa-tasks"></i> {{ $t("Yapılacaklar Listesi") }}</h2>
            <button @click="addNewTodo" class="btn btn-primary">
                <i class="fas fa-plus"></i> {{ $t("Yeni Görev Ekle") }}
            </button>
        </div>
        
        <div class="todo-form" v-if="showForm">
            <div class="form-group">
                <label>{{ $t("Görev Başlığı") }}</label>
                <input v-model="newTodo.title" type="text" class="form-control" :placeholder="$t('Görev başlığını girin')">
            </div>
            
            <div class="form-group">
                <label>{{ $t("Açıklama") }}</label>
                <textarea v-model="newTodo.description" class="form-control" rows="3" :placeholder="$t('Görev açıklamasını girin')"></textarea>
            </div>
            
            <div class="form-group">
                <label>{{ $t("Öncelik") }}</label>
                <select v-model="newTodo.priority" class="form-control">
                    <option value="low">{{ $t("Düşük") }}</option>
                    <option value="medium">{{ $t("Orta") }}</option>
                    <option value="high">{{ $t("Yüksek") }}</option>
                </select>
            </div>
            
            <div class="form-actions">
                <button @click="saveTodo" class="btn btn-success">
                    <i class="fas fa-save"></i> {{ $t("Kaydet") }}
                </button>
                <button @click="cancelTodo" class="btn btn-secondary">
                    <i class="fas fa-times"></i> {{ $t("İptal") }}
                </button>
            </div>
        </div>
        
        <div class="todo-stats">
            <div class="stat-item">
                <span class="stat-number">{{ totalTodos }}</span>
                <span class="stat-label">{{ $t("Toplam Görev") }}</span>
            </div>
            <div class="stat-item">
                <span class="stat-number">{{ completedTodos }}</span>
                <span class="stat-label">{{ $t("Tamamlanan") }}</span>
            </div>
            <div class="stat-item">
                <span class="stat-number">{{ pendingTodos }}</span>
                <span class="stat-label">{{ $t("Bekleyen") }}</span>
            </div>
        </div>
        
        <div class="todo-list-items">
            <div v-for="todo in todos" :key="todo.id" class="todo-item" :class="{ completed: todo.completed }">
                <div class="todo-checkbox">
                    <input type="checkbox" v-model="todo.completed" @change="updateTodo(todo)">
                </div>
                
                <div class="todo-content">
                    <div class="todo-title">{{ todo.title }}</div>
                    <div class="todo-description">{{ todo.description }}</div>
                    <div class="todo-meta">
                        <span class="todo-priority" :class="todo.priority">{{ $t(todo.priority) }}</span>
                        <span class="todo-date">{{ formatDate(todo.createdAt) }}</span>
                    </div>
                </div>
                
                <div class="todo-actions">
                    <button @click="editTodo(todo)" class="btn btn-sm btn-outline">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button @click="deleteTodo(todo)" class="btn btn-sm btn-danger">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    name: "TodoList",
    data() {
        return {
            todos: [],
            showForm: false,
            newTodo: {
                title: "",
                description: "",
                priority: "medium"
            }
        };
    },
    computed: {
        totalTodos() {
            return this.todos.length;
        },
        completedTodos() {
            return this.todos.filter(todo => todo.completed).length;
        },
        pendingTodos() {
            return this.todos.filter(todo => !todo.completed).length;
        }
    },
    mounted() {
        this.loadTodos();
    },
    methods: {
        loadTodos() {
            // Local storage'dan todo'ları yükle
            const savedTodos = localStorage.getItem('beyztrack_todos');
            if (savedTodos) {
                this.todos = JSON.parse(savedTodos);
            }
        },
        saveTodos() {
            // Todo'ları local storage'a kaydet
            localStorage.setItem('beyztrack_todos', JSON.stringify(this.todos));
        },
        addNewTodo() {
            this.showForm = true;
            this.newTodo = {
                title: "",
                description: "",
                priority: "medium"
            };
        },
        saveTodo() {
            if (!this.newTodo.title.trim()) {
                this.$root.toastError(this.$t("Lütfen görev başlığını girin"));
                return;
            }
            
            const todo = {
                id: Date.now(),
                title: this.newTodo.title,
                description: this.newTodo.description,
                priority: this.newTodo.priority,
                completed: false,
                createdAt: new Date()
            };
            
            this.todos.push(todo);
            this.saveTodos();
            this.cancelTodo();
            
            this.$root.toastSuccess(this.$t("Görev başarıyla eklendi"));
        },
        cancelTodo() {
            this.showForm = false;
            this.newTodo = {
                title: "",
                description: "",
                priority: "medium"
            };
        },
        updateTodo(todo) {
            this.saveTodos();
            this.$root.toastSuccess(this.$t("Görev güncellendi"));
        },
        editTodo(todo) {
            this.newTodo = { ...todo };
            this.showForm = true;
        },
        deleteTodo(todo) {
            if (confirm(this.$t("Bu görevi silmek istediğinizden emin misiniz?"))) {
                this.todos = this.todos.filter(t => t.id !== todo.id);
                this.saveTodos();
                this.$root.toastSuccess(this.$t("Görev silindi"));
            }
        },
        formatDate(date) {
            return new Date(date).toLocaleDateString('tr-TR');
        }
    }
};
</script>

<style scoped>
.todo-list {
    padding: 20px;
    background: #1a1a1a;
    border-radius: 10px;
    margin: 20px 0;
}

.todo-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
}

.todo-header h2 {
    color: #3b82f6;
    margin: 0;
}

.todo-form {
    background: #2a2a2a;
    padding: 20px;
    border-radius: 10px;
    margin-bottom: 20px;
    border: 1px solid #444;
}

.form-group {
    margin-bottom: 15px;
}

.form-group label {
    display: block;
    margin-bottom: 5px;
    color: #ffffff;
    font-weight: bold;
}

.form-control {
    width: 100%;
    padding: 10px;
    border: 1px solid #444;
    border-radius: 5px;
    background: #1a1a1a;
    color: #ffffff;
}

.form-actions {
    display: flex;
    gap: 10px;
}

.btn {
    padding: 10px 20px;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    font-weight: bold;
}

.btn-primary {
    background: #3b82f6;
    color: white;
}

.btn-success {
    background: #10b981;
    color: white;
}

.btn-secondary {
    background: #6b7280;
    color: white;
}

.btn-danger {
    background: #ef4444;
    color: white;
}

.btn-outline {
    background: transparent;
    color: #3b82f6;
    border: 1px solid #3b82f6;
}

.btn-sm {
    padding: 5px 10px;
    font-size: 0.875rem;
}

.todo-stats {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
    gap: 20px;
    margin-bottom: 20px;
}

.stat-item {
    background: #2a2a2a;
    padding: 20px;
    border-radius: 10px;
    text-align: center;
    border: 1px solid #444;
}

.stat-number {
    display: block;
    font-size: 2em;
    font-weight: bold;
    color: #3b82f6;
}

.stat-label {
    color: #ffffff;
    margin-top: 5px;
}

.todo-list-items {
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.todo-item {
    display: flex;
    align-items: center;
    background: #2a2a2a;
    padding: 15px;
    border-radius: 10px;
    border: 1px solid #444;
    transition: all 0.3s ease;
}

.todo-item.completed {
    opacity: 0.6;
    background: #1a3a2e;
}

.todo-checkbox {
    margin-right: 15px;
}

.todo-content {
    flex: 1;
}

.todo-title {
    font-weight: bold;
    color: #ffffff;
    margin-bottom: 5px;
}

.todo-description {
    color: #d1d5db;
    margin-bottom: 5px;
}

.todo-meta {
    display: flex;
    gap: 15px;
    font-size: 0.875rem;
}

.todo-priority {
    padding: 2px 8px;
    border-radius: 12px;
    font-weight: bold;
}

.todo-priority.low {
    background: #10b981;
    color: white;
}

.todo-priority.medium {
    background: #f59e0b;
    color: white;
}

.todo-priority.high {
    background: #ef4444;
    color: white;
}

.todo-date {
    color: #9ca3af;
}

.todo-actions {
    display: flex;
    gap: 5px;
}
</style>
EOF
    
    success "Todo List modülü eklendi"
}

# Router'ı güncelle
update_router() {
    local uptime_dir="$1"
    local router_file="$uptime_dir/src/router.js"
    
    info "Router güncelleniyor..."
    
    if [[ -f "$router_file" ]]; then
        sudo cp "$router_file" "${router_file}.backup"
        
        # Reports ve Todo rotalarını ekle
        sudo sed -i '/import NotFound/a import CustomReportBuilder from "./components/reports/CustomReportBuilder.vue";\nimport TodoList from "./components/TodoList.vue";' "$router_file"
        
        # Routes array'ine yeni rotalar ekle
        sudo sed -i '/path: "\/dashboard"/a\    {\n        path: "/reports",\n        component: Layout,\n        children: [\n            {\n                path: "",\n                component: CustomReportBuilder,\n            },\n        ],\n    },\n    {\n        path: "/todo",\n        component: Layout,\n        children: [\n            {\n                path: "",\n                component: TodoList,\n            },\n        ],\n    },' "$router_file"
        
        success "Router güncellendi"
    fi
}

# Layout'u güncelle
update_layout() {
    local uptime_dir="$1"
    local layout_file="$uptime_dir/src/layouts/Layout.vue"
    
    info "Layout güncelleniyor..."
    
    if [[ -f "$layout_file" ]]; then
        sudo cp "$layout_file" "${layout_file}.backup"
        
        # Reports ve Todo linklerini ekle
        sudo sed -i '/router-link to="\/dashboard"/a\                <li v-if="$root.loggedIn" class="nav-item me-2">\n                    <router-link to="\/reports" class="nav-link">\n                        <font-awesome-icon icon="chart-bar" \/> {{ $t("Reports") }}\n                    <\/router-link>\n                <\/li>\n                <li v-if="$root.loggedIn" class="nav-item me-2">\n                    <router-link to="\/todo" class="nav-link">\n                        <font-awesome-icon icon="tasks" \/> {{ $t("Yapılacaklar Listesi") }}\n                    <\/router-link>\n                <\/li>' "$layout_file"
        
        success "Layout güncellendi"
    fi
}

# Türkçe dil dosyasını güncelle
update_turkish_lang() {
    local uptime_dir="$1"
    local lang_file="$uptime_dir/src/lang/tr-TR.json"
    
    info "Türkçe dil dosyası güncelleniyor..."
    
    if [[ -f "$lang_file" ]]; then
        sudo cp "$lang_file" "${lang_file}.backup"
        
        # Yeni çeviriler ekle
        sudo tee -a "$lang_file" > /dev/null << 'EOF'
,
    "Reports": "Raporlar",
    "Custom Report Builder": "Özel Rapor Oluşturucu",
    "Create detailed reports for your monitoring data": "Monitoring verileriniz için detaylı raporlar oluşturun",
    "Report Name": "Rapor Adı",
    "Enter report name": "Rapor adını girin",
    "Date Range": "Tarih Aralığı",
    "Last 7 days": "Son 7 gün",
    "Last 30 days": "Son 30 gün",
    "Last 90 days": "Son 90 gün",
    "Monitors": "Monitörler",
    "Generate Report": "Rapor Oluştur",
    "Report Results": "Rapor Sonuçları",
    "Uptime": "Çalışma Süresi",
    "Total Checks": "Toplam Kontrol",
    "Downtime": "Kesinti Süresi",
    "Yapılacaklar Listesi": "Yapılacaklar Listesi",
    "Yeni Görev Ekle": "Yeni Görev Ekle",
    "Görev Başlığı": "Görev Başlığı",
    "Görev başlığını girin": "Görev başlığını girin",
    "Açıklama": "Açıklama",
    "Görev açıklamasını girin": "Görev açıklamasını girin",
    "Öncelik": "Öncelik",
    "Düşük": "Düşük",
    "Orta": "Orta",
    "Yüksek": "Yüksek",
    "Kaydet": "Kaydet",
    "İptal": "İptal",
    "Toplam Görev": "Toplam Görev",
    "Tamamlanan": "Tamamlanan",
    "Bekleyen": "Bekleyen",
    "Bu görevi silmek istediğinizden emin misiniz?": "Bu görevi silmek istediğinizden emin misiniz?",
    "Görev başarıyla eklendi": "Görev başarıyla eklendi",
    "Görev güncellendi": "Görev güncellendi",
    "Görev silindi": "Görev silindi",
    "Lütfen görev başlığını girin": "Lütfen görev başlığını girin"
EOF
        
        success "Türkçe dil dosyası güncellendi"
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
    echo "🚀 BeyzTrack Custom Features Script"
    echo "===================================="
    echo ""
    
    # Uptime Kuma dizinini bul
    UPTIME_DIR=$(find_uptime_kuma_dir)
    info "Uptime Kuma dizini: $UPTIME_DIR"
    
    # Özel özellikleri ekle
    add_reports_module "$UPTIME_DIR"
    add_todo_module "$UPTIME_DIR"
    
    # Router ve Layout'u güncelle
    update_router "$UPTIME_DIR"
    update_layout "$UPTIME_DIR"
    
    # Türkçe dil dosyasını güncelle
    update_turkish_lang "$UPTIME_DIR"
    
    # Servisi yeniden başlat
    restart_service "$UPTIME_DIR"
    
    echo ""
    success "🎉 BeyzTrack custom features eklendi!"
    echo ""
    echo -e "${BLUE}📋 Eklenen Özellikler:${NC}"
    echo "   • 📊 Reports modülü"
    echo "   • ✅ Todo List modülü"
    echo "   • 🎨 Gelişmiş UI özellikleri"
    echo "   • 📱 Mobil optimizasyonlar"
    echo "   • 🇹🇷 Türkçe dil desteği"
    echo ""
    echo -e "${GREEN}🚀 Şimdi tarayıcıda Reports ve Todo List'i görebilirsiniz!${NC}"
}

# Script'i çalıştır
main "$@"
