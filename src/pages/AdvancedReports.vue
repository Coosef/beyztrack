<template>
    <div class="advanced-reports">
        <div class="page-header">
            <h1 class="mb-3">{{ $t("Advanced Reports") }}</h1>
            <div class="header-actions">
                <button class="btn btn-primary" @click="generateReport">
                    <i class="fas fa-file-pdf"></i> {{ $t("Generate Report") }}
                </button>
                <button class="btn btn-outline-secondary" @click="exportData">
                    <i class="fas fa-download"></i> {{ $t("Export Data") }}
                </button>
            </div>
        </div>

        <!-- Real-time Data Module -->
        <RealTimeDataModule class="mb-4" />

        <!-- Advanced Charts Module -->
        <AdvancedCharts class="mb-4" />

        <!-- Advanced Analytics Module -->
        <AdvancedReportModule class="mb-4" />

        <!-- Trend Analysis Module -->
        <TrendAnalysisModule class="mb-4" />

        <!-- Custom Report Builder -->
        <CustomReportBuilder class="mb-4" />

        <!-- Page Info -->
        <div class="page-info mb-4">
            <div class="alert alert-info">
                <i class="fas fa-info-circle"></i>
                <strong>{{ $t("Rapor Sistemi") }}</strong> - {{ $t("Gerçek zamanlı verilerle çalışan gelişmiş rapor modülleri") }}
            </div>
        </div>
        
        <!-- Report Format Modal -->
        <ReportFormatModal 
            :show="showReportModal"
            :reportData="reportData"
            @generate="onReportGenerate"
            @close="onReportModalClose"
        />
        
        <!-- Export Format Modal -->
        <ExportFormatModal 
            :show="showExportModal"
            @export="onExportData"
            @close="onExportModalClose"
        />
    </div>
</template>

<script>
import Status from "../components/Status.vue";
import AdvancedReportModule from "../components/reports/AdvancedReportModule.vue";
import RealTimeDataModule from "../components/reports/RealTimeDataModule.vue";
import AdvancedCharts from "../components/reports/AdvancedCharts.vue";
import TrendAnalysisModule from "../components/reports/TrendAnalysisModule.vue";
import CustomReportBuilder from "../components/reports/CustomReportBuilder.vue";
import ReportFormatModal from "../components/reports/ReportFormatModal.vue";
import ExportFormatModal from "../components/reports/ExportFormatModal.vue";
import { 
    getRecentIncidents, 
    generateHTMLContent, 
    convertToCSV, 
    downloadFile 
} from "../utils/reportUtils.js";

export default {
    name: "AdvancedReports",
    components: {
        Status,
        AdvancedReportModule,
        RealTimeDataModule,
        AdvancedCharts,
        TrendAnalysisModule,
        CustomReportBuilder,
        ReportFormatModal,
        ExportFormatModal,
    },
    data() {
        return {
            showReportModal: false,
            showExportModal: false,
            reportData: null
        };
    },
    methods: {
        async generateReport() {
            try {
                this.$root.toastSuccess("Rapor oluşturuluyor...");
                
                // Rapor verilerini topla
                this.reportData = this.collectReportData();
                
                // Modal'ı göster
                this.showReportModal = true;
                
            } catch (error) {
                console.error("Rapor oluşturma hatası:", error);
                this.$root.toastError("Rapor oluşturulurken hata oluştu");
            }
        },
        async exportData() {
            try {
                this.$root.toastSuccess("Veriler dışa aktarılıyor...");
                
                // Export modal'ını göster
                this.showExportModal = true;
                
            } catch (error) {
                console.error("Veri dışa aktarma hatası:", error);
                this.$root.toastError("Veriler dışa aktarılırken hata oluştu");
            }
        },
        
        collectReportData() {
            const monitors = Object.values(this.$root.monitorList || {});
            const uptimeList = this.$root.uptimeList || {};
            const avgPingList = this.$root.avgPingList || {};
            const heartbeatList = this.$root.heartbeatList || {};
            
            // Monitor istatistikleri
            const monitorStats = monitors.map(monitor => {
                const uptime24h = uptimeList[`${monitor.id}_24`] || 0;
                const uptime7d = uptimeList[`${monitor.id}_7`] || 0;
                const uptime30d = uptimeList[`${monitor.id}_30`] || 0;
                const avgResponse = avgPingList[monitor.id] || 0;
                
                // Monitor durumunu hem monitor.active hem de heartbeat verilerine göre belirle
                const heartbeats = heartbeatList[monitor.id] || [];
                const lastHeartbeat = heartbeats[heartbeats.length - 1];
                const isActive = monitor.active && lastHeartbeat && lastHeartbeat.status === 1;
                
                return {
                    id: monitor.id,
                    name: monitor.name,
                    type: monitor.type,
                    status: isActive ? 1 : 0, // Gerçek durumu kullan
                    uptime24h: Math.round(uptime24h * 100) / 100,
                    uptime7d: Math.round(uptime7d * 100) / 100,
                    uptime30d: Math.round(uptime30d * 100) / 100,
                    avgResponse: Math.round(avgResponse),
                    lastCheck: monitor.lastCheck
                };
            });
            
            // Genel istatistikler
            const totalMonitors = monitors.length;
            const activeMonitors = monitorStats.filter(m => m.status === 1).length;
            const avgUptime24h = monitorStats.reduce((sum, m) => sum + m.uptime24h, 0) / totalMonitors;
            const avgResponseTime = monitorStats.reduce((sum, m) => sum + m.avgResponse, 0) / totalMonitors;
            
            // Son 30 günün olayları
            const incidents = getRecentIncidents(heartbeatList, monitors, 30);
            
            return {
                generatedAt: new Date().toISOString(),
                period: "Son 30 gün",
                summary: {
                    totalMonitors,
                    activeMonitors,
                    avgUptime24h: Math.round(avgUptime24h * 100) / 100,
                    avgResponseTime: Math.round(avgResponseTime),
                    totalIncidents: incidents.length
                },
                monitors: monitorStats,
                incidents: incidents,
                systemHealth: {
                    overall: Math.round(avgUptime24h),
                    performance: Math.round(100 - (avgResponseTime / 10)),
                    reliability: Math.round(avgUptime24h)
                }
            };
        },
        
        generateReportFile(reportData, format) {
            switch (format) {
                case 'pdf':
                    this.generatePDFReport(reportData);
                    break;
                case 'html':
                    this.generateHTMLReport(reportData);
                    break;
                case 'json':
                    this.generateJSONReport(reportData);
                    break;
            }
        },
        
        exportDataFile(format) {
            const monitors = Object.values(this.$root.monitorList || {});
            const uptimeList = this.$root.uptimeList || {};
            const avgPingList = this.$root.avgPingList || {};
            const heartbeatList = this.$root.heartbeatList || {};
            
            const exportData = monitors.map(monitor => {
                // Monitor durumunu heartbeat verilerine göre belirle
                    const heartbeats = heartbeatList[monitor.id] || [];
                    const lastHeartbeat = heartbeats[heartbeats.length - 1];
                    const isActive = monitor.active && lastHeartbeat && lastHeartbeat.status === 1;
                
                return {
                    'Monitor ID': monitor.id,
                    'Monitor Adı': monitor.name,
                    'Tip': monitor.type,
                    'Durum': isActive ? 'Aktif' : 'Pasif',
                    '24h Uptime %': Math.round((uptimeList[`${monitor.id}_24`] || 0) * 100) / 100,
                    '7g Uptime %': Math.round((uptimeList[`${monitor.id}_7`] || 0) * 100) / 100,
                    '30g Uptime %': Math.round((uptimeList[`${monitor.id}_30`] || 0) * 100) / 100,
                    'Ort. Yanıt (ms)': Math.round(avgPingList[monitor.id] || 0),
                    'Son Kontrol': monitor.lastCheck ? new Date(monitor.lastCheck).toLocaleString('tr-TR') : 'Bilinmiyor'
                };
            });
            
            switch (format) {
                case 'csv':
                    this.exportToCSV(exportData);
                    break;
                case 'json':
                    this.exportToJSON(exportData);
                    break;
                case 'xml':
                    this.exportToXML(exportData);
                    break;
            }
        },
        
        generatePDFReport(reportData) {
            const htmlContent = generateHTMLContent(reportData);
            const printWindow = window.open('', '_blank');
            printWindow.document.write(htmlContent);
            printWindow.document.close();
            printWindow.print();
            this.$root.toastSuccess("PDF raporu yazdırma penceresi açıldı");
        },
        
        
        generateHTMLReport(reportData) {
            const htmlContent = generateHTMLContent(reportData);
            downloadFile(htmlContent, 'rapor.html', 'text/html');
            this.$root.toastSuccess("HTML raporu indirildi");
        },
        
        generateJSONReport(reportData) {
            const jsonContent = JSON.stringify(reportData, null, 2);
            downloadFile(jsonContent, 'rapor.json', 'application/json');
            this.$root.toastSuccess("JSON raporu indirildi");
        },
        
        
        exportToCSV(data) {
            // Türkçe karakterleri düzelt
            const cleanedData = data.map(item => {
                const cleaned = {};
                Object.keys(item).forEach(key => {
                    // Türkçe karakterleri İngilizce karşılıklarıyla değiştir
                    const cleanKey = key
                        .replace('ı', 'i')
                        .replace('İ', 'I')
                        .replace('ş', 's')
                        .replace('Ş', 'S')
                        .replace('ğ', 'g')
                        .replace('Ğ', 'G')
                        .replace('ü', 'u')
                        .replace('Ü', 'U')
                        .replace('ö', 'o')
                        .replace('Ö', 'O')
                        .replace('ç', 'c')
                        .replace('Ç', 'C');
                    cleaned[cleanKey] = item[key];
                });
                return cleaned;
            });
            
            const csvData = convertToCSV(cleanedData);
            // UTF-8 BOM ekleyerek karakter kodlama sorununu çöz
            const csvWithBOM = '\uFEFF' + csvData;
            downloadFile(csvWithBOM, 'monitor-verileri.csv', 'text/csv;charset=utf-8');
            this.$root.toastSuccess("CSV dosyası indirildi");
        },
        
        exportToJSON(data) {
            const jsonContent = JSON.stringify(data, null, 2);
            downloadFile(jsonContent, 'monitor-verileri.json', 'application/json');
            this.$root.toastSuccess("JSON dosyası indirildi");
        },
        
        exportToXML(data) {
            let xmlContent = '<?xml version="1.0" encoding="UTF-8"?>\n<monitors>\n';
            data.forEach(item => {
                xmlContent += '  <monitor>\n';
                Object.keys(item).forEach(key => {
                    xmlContent += `    <${key}>${item[key]}</${key}>\n`;
                });
                xmlContent += '  </monitor>\n';
            });
            xmlContent += '</monitors>';
            
            downloadFile(xmlContent, 'monitor-verileri.xml', 'application/xml');
            this.$root.toastSuccess("XML dosyası indirildi");
        },
        
        // Modal event handlers
        onReportGenerate(format, reportData) {
            this.generateReportFile(reportData, format);
        },
        
        onReportModalClose() {
            this.showReportModal = false;
        },
        
        onExportData(format) {
            this.exportDataFile(format);
        },
        
        onExportModalClose() {
            this.showExportModal = false;
        },
    },
};
</script>

<style lang="scss" scoped>
.advanced-reports {
    padding: 1rem;
}

.page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;
    padding-bottom: 1rem;
    border-bottom: 1px solid var(--bs-border-color);

    h1 {
        margin: 0;
        color: var(--bs-body-color);
        font-weight: 600;
    }

    .header-actions {
        display: flex;
        gap: 0.5rem;
    }
}

.page-info {
    .alert {
        border-radius: 0.75rem;
        border: none;
        background: rgba(13, 202, 240, 0.1);
        color: var(--bs-body-color);

        i {
            margin-right: 0.5rem;
        }
    }
}

@media (max-width: 768px) {
    .page-header {
        flex-direction: column;
        gap: 1rem;
        align-items: stretch;

        .header-actions {
            justify-content: center;
        }
    }
}
</style>
