<template>
    <div class="custom-report-builder">
        <!-- Module Header -->
        <div class="module-header">
            <h3 class="module-title">
                <i class="fas fa-file-alt"></i>
                {{ $t("Custom Report Builder") }}
            </h3>
            <div class="module-actions">
                <button class="btn btn-sm btn-success" @click="generateCustomReport" :disabled="!isFormValid">
                    <i class="fas fa-magic"></i> {{ $t("Generate Report") }}
                </button>
                <button class="btn btn-sm btn-outline-primary" @click="saveTemplate">
                    <i class="fas fa-save"></i> {{ $t("Save Template") }}
                </button>
            </div>
        </div>

        <!-- Report Configuration -->
        <div class="report-configuration">
            <div class="row">
                <!-- Template Selection -->
                <div class="col-md-6">
                    <div class="config-section">
                        <h5 class="section-title">
                            <i class="fas fa-layer-group"></i>
                            {{ $t("Report Template") }}
                        </h5>
                        <div class="template-grid">
                            <div 
                                v-for="template in reportTemplates" 
                                :key="template.id"
                                class="template-card"
                                :class="{ active: selectedTemplate === template.id }"
                                @click="selectTemplate(template.id)"
                            >
                                <div class="template-icon">
                                    <i :class="template.icon"></i>
                                </div>
                                <div class="template-content">
                                    <div class="template-name">{{ template.name }}</div>
                                    <div class="template-description">{{ template.description }}</div>
                                </div>
                                <div class="template-badge" v-if="template.isNew">
                                    <span class="badge bg-success">Yeni</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Date Range Selection -->
                <div class="col-md-6">
                    <div class="config-section">
                        <h5 class="section-title">
                            <i class="fas fa-calendar-alt"></i>
                            {{ $t("Date Range") }}
                        </h5>
                        <div class="date-range-options">
                            <div class="quick-dates">
                                <button 
                                    v-for="quickDate in quickDates" 
                                    :key="quickDate.value"
                                    class="btn btn-sm"
                                    :class="selectedDateRange === quickDate.value ? 'btn-primary' : 'btn-outline-secondary'"
                                    @click="selectQuickDate(quickDate.value)"
                                >
                                    {{ quickDate.label }}
                                </button>
                            </div>
                            <div class="custom-date-range">
                                <div class="form-group">
                                    <label>{{ $t("Start Date") }}</label>
                                    <input 
                                        type="datetime-local" 
                                        v-model="customStartDate" 
                                        class="form-control"
                                        @change="updateCustomDateRange"
                                    >
                                </div>
                                <div class="form-group">
                                    <label>{{ $t("End Date") }}</label>
                                    <input 
                                        type="datetime-local" 
                                        v-model="customEndDate" 
                                        class="form-control"
                                        @change="updateCustomDateRange"
                                    >
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Monitor Selection -->
            <div class="config-section mt-4">
                <h5 class="section-title">
                    <i class="fas fa-server"></i>
                    {{ $t("Monitor Selection") }}
                </h5>
                <div class="monitor-selection">
                    <div class="selection-controls">
                        <button class="btn btn-sm btn-outline-primary" @click="selectAllMonitors">
                            {{ $t("Select All") }}
                        </button>
                        <button class="btn btn-sm btn-outline-secondary" @click="deselectAllMonitors">
                            {{ $t("Deselect All") }}
                        </button>
                        <button class="btn btn-sm btn-outline-info" @click="selectActiveMonitors">
                            {{ $t("Active Only") }}
                        </button>
                    </div>
                    <div class="monitor-list">
                        <div 
                            v-for="monitor in availableMonitors" 
                            :key="monitor.id"
                            class="monitor-item"
                            :class="{ selected: selectedMonitors.includes(monitor.id) }"
                            @click="toggleMonitor(monitor.id)"
                        >
                            <div class="monitor-status" :class="getMonitorStatusClass(monitor)">
                                <i :class="getMonitorStatusIcon(monitor)"></i>
                            </div>
                            <div class="monitor-info">
                                <div class="monitor-name">{{ monitor.name }}</div>
                                <div class="monitor-type">{{ monitor.type }} - {{ monitor.url || monitor.hostname }}</div>
                            </div>
                            <div class="monitor-uptime" v-if="getMonitorUptime(monitor)">
                                {{ getMonitorUptime(monitor) }}%
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Report Options -->
            <div class="config-section mt-4">
                <h5 class="section-title">
                    <i class="fas fa-cog"></i>
                    {{ $t("Report Options") }}
                </h5>
                <div class="report-options">
                    <div class="row">
                        <div class="col-md-4">
                            <div class="option-group">
                                <label class="form-label">{{ $t("Export Format") }}</label>
                                <select v-model="exportFormat" class="form-select">
                                    <option value="pdf">PDF</option>
                                    <option value="excel">Excel</option>
                                    <option value="html">HTML</option>
                                    <option value="json">JSON</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="option-group">
                                <label class="form-label">{{ $t("Language") }}</label>
                                <select v-model="reportLanguage" class="form-select">
                                    <option value="tr">Türkçe</option>
                                    <option value="en">English</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="option-group">
                                <label class="form-label">{{ $t("Include Charts") }}</label>
                                <div class="form-check">
                                    <input type="checkbox" v-model="includeCharts" class="form-check-input" id="includeCharts">
                                    <label class="form-check-label" for="includeCharts">
                                        {{ $t("Yes") }}
                                    </label>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row mt-3">
                        <div class="col-md-6">
                            <div class="option-group">
                                <label class="form-label">{{ $t("Report Title") }}</label>
                                <input type="text" v-model="reportTitle" class="form-control" :placeholder="$t('Enter report title')">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="option-group">
                                <label class="form-label">{{ $t("Report Description") }}</label>
                                <textarea v-model="reportDescription" class="form-control" rows="2" :placeholder="$t('Enter report description')"></textarea>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Generated Report Preview -->
        <div v-if="generatedReport" class="report-preview mt-4">
            <h5 class="section-title">
                <i class="fas fa-eye"></i>
                {{ $t("Report Preview") }}
            </h5>
            <div class="preview-content">
                <div class="preview-header">
                    <h4>{{ generatedReport.title }}</h4>
                    <p class="text-muted">{{ generatedReport.description }}</p>
                    <div class="report-meta">
                        <span class="meta-item">
                            <i class="fas fa-calendar"></i>
                            {{ generatedReport.dateRange }}
                        </span>
                        <span class="meta-item">
                            <i class="fas fa-server"></i>
                            {{ generatedReport.monitorCount }} {{ $t("Monitors") }}
                        </span>
                        <span class="meta-item">
                            <i class="fas fa-chart-line"></i>
                            {{ generatedReport.avgUptime }}% {{ $t("Average Uptime") }}
                        </span>
                    </div>
                </div>
                <div class="preview-actions">
                    <button class="btn btn-primary" @click="downloadReport">
                        <i class="fas fa-download"></i> {{ $t("Download") }}
                    </button>
                    <button class="btn btn-outline-secondary" @click="shareReport">
                        <i class="fas fa-share"></i> {{ $t("Share") }}
                    </button>
                    <button class="btn btn-outline-info" @click="scheduleReport">
                        <i class="fas fa-clock"></i> {{ $t("Schedule") }}
                    </button>
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
            selectedTemplate: "comprehensive",
            selectedDateRange: "7d",
            selectedMonitors: [],
            exportFormat: "pdf",
            reportLanguage: "tr",
            includeCharts: true,
            reportTitle: "",
            reportDescription: "",
            customStartDate: "",
            customEndDate: "",
            generatedReport: null,
            
            reportTemplates: [
                {
                    id: "comprehensive",
                    name: "Kapsamlı Rapor",
                    description: "Tüm metrikleri içeren detaylı rapor",
                    icon: "fas fa-chart-bar",
                    isNew: false
                },
                {
                    id: "executive",
                    name: "Yönetici Özeti",
                    description: "Yüksek seviye performans özeti",
                    icon: "fas fa-briefcase",
                    isNew: false
                },
                {
                    id: "technical",
                    name: "Teknik Detay",
                    description: "Teknik ekip için detaylı analiz",
                    icon: "fas fa-cogs",
                    isNew: false
                },
                {
                    id: "incident",
                    name: "Olay Raporu",
                    description: "Kesinti ve olay analizi",
                    icon: "fas fa-exclamation-triangle",
                    isNew: true
                },
                {
                    id: "trend",
                    name: "Trend Analizi",
                    description: "Zaman içindeki performans trendleri",
                    icon: "fas fa-trending-up",
                    isNew: true
                }
            ],
            
            quickDates: [
                { value: "24h", label: "Son 24 Saat" },
                { value: "7d", label: "Son 7 Gün" },
                { value: "30d", label: "Son 30 Gün" },
                { value: "90d", label: "Son 90 Gün" },
                { value: "custom", label: "Özel Aralık" }
            ]
        };
    },
    
    computed: {
        availableMonitors() {
            return this.$root.monitorList || [];
        },
        
        isFormValid() {
            return this.selectedTemplate && 
                   this.selectedDateRange && 
                   this.selectedMonitors.length > 0 &&
                   this.reportTitle.trim() !== "";
        }
    },
    
    mounted() {
        this.initializeForm();
    },
    
    methods: {
        initializeForm() {
            // Varsayılan değerleri ayarla
            this.reportTitle = `BeyzTrack Raporu - ${new Date().toLocaleDateString('tr-TR')}`;
            this.reportDescription = "Otomatik olarak oluşturulan sistem raporu";
            this.selectedMonitors = this.availableMonitors.map(m => m.id);
            
            // Varsayılan tarih aralığını ayarla
            this.setDefaultDateRange();
        },
        
        setDefaultDateRange() {
            const now = new Date();
            const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
            
            this.customStartDate = sevenDaysAgo.toISOString().slice(0, 16);
            this.customEndDate = now.toISOString().slice(0, 16);
        },
        
        selectTemplate(templateId) {
            this.selectedTemplate = templateId;
            this.updateReportTitle();
        },
        
        selectQuickDate(dateRange) {
            this.selectedDateRange = dateRange;
            if (dateRange !== "custom") {
                this.updateDateRange(dateRange);
            }
        },
        
        updateDateRange(range) {
            const now = new Date();
            let startDate = new Date();
            
            switch (range) {
                case "24h":
                    startDate = new Date(now.getTime() - 24 * 60 * 60 * 1000);
                    break;
                case "7d":
                    startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
                    break;
                case "30d":
                    startDate = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
                    break;
                case "90d":
                    startDate = new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000);
                    break;
            }
            
            this.customStartDate = startDate.toISOString().slice(0, 16);
            this.customEndDate = now.toISOString().slice(0, 16);
        },
        
        updateCustomDateRange() {
            this.selectedDateRange = "custom";
        },
        
        selectAllMonitors() {
            this.selectedMonitors = this.availableMonitors.map(m => m.id);
        },
        
        deselectAllMonitors() {
            this.selectedMonitors = [];
        },
        
        selectActiveMonitors() {
            this.selectedMonitors = this.availableMonitors
                .filter(m => m.active)
                .map(m => m.id);
        },
        
        toggleMonitor(monitorId) {
            const index = this.selectedMonitors.indexOf(monitorId);
            if (index > -1) {
                this.selectedMonitors.splice(index, 1);
            } else {
                this.selectedMonitors.push(monitorId);
            }
        },
        
        getMonitorStatusClass(monitor) {
            const status = this.$root.getMonitorStatus(monitor);
            return {
                'status-up': status === 'up',
                'status-down': status === 'down',
                'status-maintenance': status === 'maintenance'
            };
        },
        
        getMonitorStatusIcon(monitor) {
            const status = this.$root.getMonitorStatus(monitor);
            const icons = {
                'up': 'fas fa-check-circle',
                'down': 'fas fa-times-circle',
                'maintenance': 'fas fa-tools'
            };
            return icons[status] || 'fas fa-question-circle';
        },
        
        getMonitorUptime(monitor) {
            const uptimeList = this.$root.uptimeList || {};
            const uptimeKey = `${monitor.id}_24`;
            if (uptimeList[uptimeKey] !== undefined) {
                return Math.round(uptimeList[uptimeKey] * 100);
            }
            return null;
        },
        
        updateReportTitle() {
            const template = this.reportTemplates.find(t => t.id === this.selectedTemplate);
            if (template) {
                this.reportTitle = `${template.name} - ${new Date().toLocaleDateString('tr-TR')}`;
            }
        },
        
        generateCustomReport() {
            if (!this.isFormValid) {
                this.$root.toastError("Lütfen tüm gerekli alanları doldurun");
                return;
            }
            
            // Rapor verilerini hazırla
            const selectedMonitorsData = this.availableMonitors.filter(m => 
                this.selectedMonitors.includes(m.id)
            );
            
            const avgUptime = this.calculateAverageUptime(selectedMonitorsData);
            
            this.generatedReport = {
                title: this.reportTitle,
                description: this.reportDescription,
                template: this.selectedTemplate,
                dateRange: this.getDateRangeText(),
                monitorCount: selectedMonitorsData.length,
                avgUptime: avgUptime,
                format: this.exportFormat,
                language: this.reportLanguage,
                includeCharts: this.includeCharts,
                monitors: selectedMonitorsData,
                generatedAt: new Date()
            };
            
            this.$root.toastSuccess("Rapor başarıyla oluşturuldu!");
        },
        
        calculateAverageUptime(monitors) {
            const uptimeList = this.$root.uptimeList || {};
            let totalUptime = 0;
            let count = 0;
            
            monitors.forEach(monitor => {
                const uptimeKey = `${monitor.id}_24`;
                if (uptimeList[uptimeKey] !== undefined) {
                    totalUptime += uptimeList[uptimeKey] * 100;
                    count++;
                }
            });
            
            return count > 0 ? Math.round(totalUptime / count) : 0;
        },
        
        getDateRangeText() {
            if (this.selectedDateRange === "custom") {
                const start = new Date(this.customStartDate).toLocaleDateString('tr-TR');
                const end = new Date(this.customEndDate).toLocaleDateString('tr-TR');
                return `${start} - ${end}`;
            }
            
            const quickDate = this.quickDates.find(qd => qd.value === this.selectedDateRange);
            return quickDate ? quickDate.label : this.selectedDateRange;
        },
        
        downloadReport() {
            // Rapor indirme simülasyonu
            this.$root.toastSuccess(`${this.exportFormat.toUpperCase()} raporu indiriliyor...`);
            
            // Gerçek implementasyonda burada dosya oluşturma ve indirme işlemi yapılacak
            setTimeout(() => {
                this.$root.toastSuccess("Rapor başarıyla indirildi!");
            }, 2000);
        },
        
        shareReport() {
            this.$root.toastInfo("Paylaşım özelliği yakında eklenecek");
        },
        
        scheduleReport() {
            this.$root.toastInfo("Zamanlanmış rapor özelliği yakında eklenecek");
        },
        
        saveTemplate() {
            const template = {
                name: this.reportTitle,
                description: this.reportDescription,
                template: this.selectedTemplate,
                dateRange: this.selectedDateRange,
                monitors: this.selectedMonitors,
                options: {
                    format: this.exportFormat,
                    language: this.reportLanguage,
                    includeCharts: this.includeCharts
                }
            };
            
            // Template'i localStorage'a kaydet
            const savedTemplates = JSON.parse(localStorage.getItem('beyztrack_report_templates') || '[]');
            savedTemplates.push({
                ...template,
                id: Date.now(),
                createdAt: new Date()
            });
            localStorage.setItem('beyztrack_report_templates', JSON.stringify(savedTemplates));
            
            this.$root.toastSuccess("Şablon başarıyla kaydedildi!");
        }
    }
};
</script>

<style lang="scss" scoped>
.custom-report-builder {
    background: var(--bs-body-bg);
    border-radius: 0.75rem;
    padding: 1.5rem;
    box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
}

.module-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1.5rem;
    
    .module-title {
        margin: 0;
        font-size: 1.25rem;
        font-weight: 600;
        color: var(--bs-body-color);
        
        i {
            margin-right: 0.5rem;
            color: var(--bs-primary);
        }
    }
    
    .module-actions {
        display: flex;
        gap: 0.5rem;
    }
}

.config-section {
    background: var(--bs-body-bg);
    border: 1px solid var(--bs-border-color);
    border-radius: 0.5rem;
    padding: 1.5rem;
    
    .section-title {
        margin-bottom: 1rem;
        font-size: 1.1rem;
        font-weight: 600;
        color: var(--bs-body-color);
        
        i {
            margin-right: 0.5rem;
            color: var(--bs-primary);
        }
    }
}

.template-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 1rem;
    
    .template-card {
        display: flex;
        align-items: center;
        padding: 1rem;
        border: 2px solid var(--bs-border-color);
        border-radius: 0.5rem;
        cursor: pointer;
        transition: all 0.3s ease;
        position: relative;
        
        &:hover {
            border-color: var(--bs-primary);
            transform: translateY(-2px);
        }
        
        &.active {
            border-color: var(--bs-primary);
            background: rgba(13, 202, 240, 0.1);
        }
        
        .template-icon {
            width: 3rem;
            height: 3rem;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 1rem;
            background: rgba(13, 202, 240, 0.1);
            color: var(--bs-primary);
        }
        
        .template-content {
            flex: 1;
            
            .template-name {
                font-weight: 600;
                color: var(--bs-body-color);
                margin-bottom: 0.25rem;
            }
            
            .template-description {
                font-size: 0.875rem;
                color: var(--bs-secondary);
            }
        }
        
        .template-badge {
            position: absolute;
            top: 0.5rem;
            right: 0.5rem;
        }
    }
}

.date-range-options {
    .quick-dates {
        display: flex;
        flex-wrap: wrap;
        gap: 0.5rem;
        margin-bottom: 1rem;
    }
    
    .custom-date-range {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 1rem;
        
        .form-group {
            label {
                font-weight: 600;
                color: var(--bs-body-color);
                margin-bottom: 0.5rem;
            }
        }
    }
}

.monitor-selection {
    .selection-controls {
        display: flex;
        gap: 0.5rem;
        margin-bottom: 1rem;
    }
    
    .monitor-list {
        max-height: 300px;
        overflow-y: auto;
        border: 1px solid var(--bs-border-color);
        border-radius: 0.5rem;
        
        .monitor-item {
            display: flex;
            align-items: center;
            padding: 0.75rem;
            border-bottom: 1px solid var(--bs-border-color);
            cursor: pointer;
            transition: background-color 0.3s ease;
            
            &:last-child {
                border-bottom: none;
            }
            
            &:hover {
                background: rgba(13, 202, 240, 0.05);
            }
            
            &.selected {
                background: rgba(13, 202, 240, 0.1);
                border-left: 4px solid var(--bs-primary);
            }
            
            .monitor-status {
                width: 2rem;
                height: 2rem;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                margin-right: 1rem;
                
                &.status-up {
                    background: rgba(25, 135, 84, 0.1);
                    color: var(--bs-success);
                }
                
                &.status-down {
                    background: rgba(220, 53, 69, 0.1);
                    color: var(--bs-danger);
                }
                
                &.status-maintenance {
                    background: rgba(255, 193, 7, 0.1);
                    color: var(--bs-warning);
                }
            }
            
            .monitor-info {
                flex: 1;
                
                .monitor-name {
                    font-weight: 600;
                    color: var(--bs-body-color);
                }
                
                .monitor-type {
                    font-size: 0.875rem;
                    color: var(--bs-secondary);
                }
            }
            
            .monitor-uptime {
                font-weight: 600;
                color: var(--bs-primary);
                font-size: 0.875rem;
            }
        }
    }
}

.report-options {
    .option-group {
        margin-bottom: 1rem;
        
        label {
            font-weight: 600;
            color: var(--bs-body-color);
            margin-bottom: 0.5rem;
        }
    }
}

.report-preview {
    .preview-content {
        background: var(--bs-body-bg);
        border: 1px solid var(--bs-border-color);
        border-radius: 0.5rem;
        padding: 1.5rem;
        
        .preview-header {
            margin-bottom: 1.5rem;
            
            h4 {
                color: var(--bs-body-color);
                margin-bottom: 0.5rem;
            }
            
            .report-meta {
                display: flex;
                gap: 1rem;
                margin-top: 1rem;
                
                .meta-item {
                    display: flex;
                    align-items: center;
                    font-size: 0.875rem;
                    color: var(--bs-secondary);
                    
                    i {
                        margin-right: 0.5rem;
                    }
                }
            }
        }
        
        .preview-actions {
            display: flex;
            gap: 0.5rem;
        }
    }
}

@media (max-width: 768px) {
    .template-grid {
        grid-template-columns: 1fr;
    }
    
    .custom-date-range {
        grid-template-columns: 1fr;
    }
    
    .selection-controls {
        flex-direction: column;
    }
    
    .preview-actions {
        flex-direction: column;
    }
    
    .report-meta {
        flex-direction: column;
        gap: 0.5rem;
    }
}
</style>
