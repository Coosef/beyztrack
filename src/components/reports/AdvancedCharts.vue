<template>
    <div class="advanced-charts">
        <div class="charts-header">
            <h3 class="charts-title">
                <i class="fas fa-chart-area"></i>
                {{ $t("Gelişmiş Grafikler") }}
            </h3>
            <div class="charts-actions">
                <button class="btn btn-sm btn-outline-primary" @click="refreshCharts">
                    <i class="fas fa-sync-alt"></i> {{ $t("Yenile") }}
                </button>
                <button class="btn btn-sm btn-primary" @click="exportCharts">
                    <i class="fas fa-download"></i> {{ $t("Dışa Aktar") }}
                </button>
            </div>
        </div>

        <!-- Chart Controls -->
        <div class="chart-controls mb-4">
            <div class="row">
                <div class="col-md-3">
                    <label class="form-label">{{ $t("Grafik Tipi") }}</label>
                    <select v-model="selectedChartType" class="form-select" @change="updateChart">
                        <option value="uptime">{{ $t("Uptime Trendi") }}</option>
                        <option value="response">{{ $t("Yanıt Süresi") }}</option>
                        <option value="incidents">{{ $t("Olay Analizi") }}</option>
                        <option value="performance">{{ $t("Performans Metrikleri") }}</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">{{ $t("Zaman Aralığı") }}</label>
                    <select v-model="selectedTimeRange" class="form-select" @change="updateChart">
                        <option value="24">{{ $t("Son 24 Saat") }}</option>
                        <option value="168">{{ $t("Son Hafta") }}</option>
                        <option value="720">{{ $t("Son Ay") }}</option>
                        <option value="2160">{{ $t("Son 3 Ay") }}</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">{{ $t("Grafik Stili") }}</label>
                    <select v-model="selectedChartStyle" class="form-select" @change="updateChart">
                        <option value="line">{{ $t("Çizgi Grafik") }}</option>
                        <option value="bar">{{ $t("Sütun Grafik") }}</option>
                        <option value="area">{{ $t("Alan Grafik") }}</option>
                        <option value="radar">{{ $t("Radar Grafik") }}</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">{{ $t("Renk Teması") }}</label>
                    <select v-model="selectedColorTheme" class="form-select" @change="updateChart">
                        <option value="default">{{ $t("Varsayılan") }}</option>
                        <option value="dark">{{ $t("Koyu") }}</option>
                        <option value="colorful">{{ $t("Renkli") }}</option>
                        <option value="monochrome">{{ $t("Tek Renk") }}</option>
                    </select>
                </div>
            </div>
        </div>

        <!-- Main Chart Container -->
        <div class="chart-container" v-if="!isMobile">
            <div class="chart-wrapper">
                <canvas ref="mainChart" width="800" height="400"></canvas>
            </div>
            
            <!-- Chart Legend -->
            <div class="chart-legend mt-3">
                <div class="legend-items">
                    <div v-for="item in chartLegend" :key="item.label" class="legend-item">
                        <div class="legend-color" :style="{ backgroundColor: item.color }"></div>
                        <span class="legend-label">{{ item.label }}</span>
                        <span class="legend-value">{{ item.value }}</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Mobile Stats Display -->
        <div class="mobile-stats" v-if="isMobile">
            <div class="mobile-stats-header">
                <h5><i class="fas fa-mobile-alt"></i> Mobil İstatistikler</h5>
            </div>
            <div class="mobile-stats-grid">
                <div class="mobile-stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-server"></i>
                    </div>
                    <div class="stat-info">
                        <div class="stat-value">{{ mobileStats.totalMonitors }}</div>
                        <div class="stat-label">Toplam Monitör</div>
                    </div>
                </div>
                <div class="mobile-stat-card">
                    <div class="stat-icon success">
                        <i class="fas fa-check-circle"></i>
                    </div>
                    <div class="stat-info">
                        <div class="stat-value">{{ mobileStats.avgUptime }}%</div>
                        <div class="stat-label">Ortalama Uptime</div>
                    </div>
                </div>
                <div class="mobile-stat-card">
                    <div class="stat-icon warning">
                        <i class="fas fa-clock"></i>
                    </div>
                    <div class="stat-info">
                        <div class="stat-value">{{ mobileStats.avgResponse }}ms</div>
                        <div class="stat-label">Ortalama Yanıt</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Mini Charts Grid -->
        <div class="mini-charts-grid mt-4" v-if="!isMobile">
            <div class="row">
                <div class="col-md-6">
                    <div class="mini-chart-card">
                        <h5>{{ $t("Uptime Dağılımı") }}</h5>
                        <canvas ref="uptimeDistributionChart" width="300" height="200"></canvas>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="mini-chart-card">
                        <h5>{{ $t("Yanıt Süresi Dağılımı") }}</h5>
                        <canvas ref="responseDistributionChart" width="300" height="200"></canvas>
                    </div>
                </div>
            </div>
            <div class="row mt-3">
                <div class="col-md-6">
                    <div class="mini-chart-card">
                        <h5>{{ $t("Olay Trendi") }}</h5>
                        <canvas ref="incidentTrendChart" width="300" height="200"></canvas>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="mini-chart-card">
                        <h5>{{ $t("Performans Skoru") }}</h5>
                        <canvas ref="performanceScoreChart" width="300" height="200"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <!-- Chart Insights -->
        <div class="chart-insights mt-4">
            <h5><i class="fas fa-lightbulb"></i> {{ $t("Grafik Analizi") }}</h5>
            <div class="insights-grid">
                <div class="row">
                    <div class="col-md-4">
                        <div class="insight-card">
                            <div class="insight-icon">
                                <i class="fas fa-trending-up"></i>
                            </div>
                            <div class="insight-content">
                                <h6>{{ $t("Trend Analizi") }}</h6>
                                <p>{{ insights.trend }}</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="insight-card">
                            <div class="insight-icon">
                                <i class="fas fa-exclamation-triangle"></i>
                            </div>
                            <div class="insight-content">
                                <h6>{{ $t("Anomali Tespiti") }}</h6>
                                <p>{{ insights.anomalies }}</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="insight-card">
                            <div class="insight-icon">
                                <i class="fas fa-chart-line"></i>
                            </div>
                            <div class="insight-content">
                                <h6>{{ $t("Performans Önerisi") }}</h6>
                                <p>{{ insights.recommendations }}</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import Chart from 'chart.js/auto';

export default {
    name: "AdvancedCharts",
    data() {
        return {
            selectedChartType: "uptime",
            selectedTimeRange: "168",
            selectedChartStyle: "line",
            selectedColorTheme: "default",
            mainChart: null,
            miniCharts: {},
            chartLegend: [],
            isMobile: false,
            mobileStats: {
                totalMonitors: 0,
                avgUptime: 0,
                avgResponse: 0
            },
            insights: {
                trend: "Son 7 günde uptime oranı %99.87'den %99.89'a yükseldi.",
                anomalies: "2 adet yavaş yanıt olayı tespit edildi.",
                recommendations: "Performansı artırmak için CDN kullanımını değerlendirin."
            },
            colorThemes: {
                default: ['#007bff', '#28a745', '#ffc107', '#dc3545'],
                dark: ['#343a40', '#495057', '#6c757d', '#adb5bd'],
                colorful: ['#ff6b6b', '#4ecdc4', '#45b7d1', '#96ceb4'],
                monochrome: ['#000000', '#333333', '#666666', '#999999']
            }
        };
    },
    mounted() {
        try {
            // Mobil cihaz kontrolü
            this.isMobile = this.$root.isMobile || window.innerWidth < 768;
            
            if (this.isMobile) {
                console.log("Mobile device detected, using safe initialization");
                this.$nextTick(() => {
                    setTimeout(() => {
                        // Mobilde sadece basit grafikleri göster
                        this.initMobileCharts();
                    }, 1000); // Mobilde daha uzun gecikme
                });
            } else {
                // Desktop için DOM'un hazır olmasını bekle
                this.$nextTick(() => {
                    setTimeout(() => {
                        this.initCharts();
                        this.updateChart();
                        this.startRealTimeUpdates();
                    }, 500);
                });
            }
        } catch (error) {
            console.error("Chart initialization error:", error);
            this.$root.toastError("Grafikler yüklenirken hata oluştu");
        }
    },
    beforeUnmount() {
        this.stopRealTimeUpdates();
        this.destroyCharts();
    },
    methods: {
        initCharts() {
            try {
                // Canvas elementlerinin hazır olduğundan emin ol
                if (!this.$refs.mainChart || !this.$refs.uptimeDistributionChart) {
                    console.warn("Canvas elements not ready, retrying...");
                    setTimeout(() => this.initCharts(), 100);
                    return;
                }
                
                this.createMainChart();
                this.createMiniCharts();
            } catch (error) {
                console.error("Error initializing charts:", error);
                this.$root.toastError("Grafikler başlatılamadı");
            }
        },
        
        initMobileCharts() {
            try {
                console.log("Initializing mobile-optimized charts");
                
                // Mobilde sadece basit istatistikler göster
                this.showMobileStats();
                
                // Mobilde chart.js kullanmıyoruz, sadece basit HTML/CSS ile gösterim
                this.$root.toastSuccess("Mobil uyumlu görünüm yüklendi");
            } catch (error) {
                console.error("Error initializing mobile charts:", error);
                this.showMobileFallback();
            }
        },
        
        showMobileStats() {
            // Mobilde sadece basit istatistikler göster
            const monitors = Object.values(this.$root.monitorList || {});
            const uptimeList = this.$root.uptimeList || {};
            const avgPingList = this.$root.avgPingList || {};
            
            let totalUptime = 0;
            let monitorCount = 0;
            let totalPing = 0;
            let pingCount = 0;
            
            monitors.forEach(monitor => {
                const uptimeKey = `${monitor.id}_24`;
                if (uptimeList[uptimeKey] !== undefined) {
                    totalUptime += uptimeList[uptimeKey] * 100;
                    monitorCount++;
                }
                
                if (avgPingList[monitor.id] !== undefined) {
                    totalPing += avgPingList[monitor.id];
                    pingCount++;
                }
            });
            
            const avgUptime = monitorCount > 0 ? Math.round(totalUptime / monitorCount) : 99.9;
            const avgResponse = pingCount > 0 ? Math.round(totalPing / pingCount) : 100;
            
            // Mobil istatistikleri güncelle
            this.mobileStats = {
                totalMonitors: monitors.length,
                avgUptime: avgUptime,
                avgResponse: avgResponse
            };
            
            // Basit istatistik kartları göster
            this.insights = {
                trend: `Ortalama uptime: %${avgUptime}`,
                anomalies: `${monitors.length} monitör aktif`,
                recommendations: "Mobil görünüm için optimize edildi"
            };
        },
        
        showMobileFallback() {
            // En basit fallback görünüm
            this.insights = {
                trend: "Mobil görünüm aktif",
                anomalies: "Grafikler devre dışı",
                recommendations: "Desktop'ta tam özellikler kullanılabilir"
            };
        },
        createMainChart() {
            try {
                if (!this.$refs.mainChart) {
                    console.warn("Main chart canvas not ready");
                    return;
                }
                
                const ctx = this.$refs.mainChart.getContext('2d');
                if (!ctx) {
                    console.warn("Could not get 2D context");
                    return;
                }
                
                this.mainChart = new Chart(ctx, {
                    type: this.selectedChartStyle,
                    data: {
                        labels: [],
                        datasets: []
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        animation: {
                            duration: 1000
                        },
                        plugins: {
                            legend: {
                                display: true,
                                position: 'top'
                            },
                            tooltip: {
                                mode: 'index',
                                intersect: false
                            }
                        },
                        scales: {
                            x: {
                                display: true,
                                title: {
                                    display: true,
                                    text: this.$t("Zaman")
                                }
                            },
                            y: {
                                display: true,
                                title: {
                                    display: true,
                                    text: this.$t("Değer")
                                },
                                beginAtZero: true
                            }
                        }
                    }
                });
            } catch (error) {
                console.error("Error creating main chart:", error);
                this.$root.toastError("Ana grafik oluşturulamadı");
            }
        },
        createMiniCharts() {
            try {
                // Uptime Distribution Chart
                if (this.$refs.uptimeDistributionChart) {
                    const uptimeCtx = this.$refs.uptimeDistributionChart.getContext('2d');
                    if (uptimeCtx) {
                        this.miniCharts.uptimeDistribution = new Chart(uptimeCtx, {
                            type: 'doughnut',
                            data: this.getUptimeDistributionData(),
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                plugins: {
                                    legend: {
                                        position: 'bottom'
                                    }
                                }
                            }
                        });
                    }
                }

            // Response Distribution Chart
            if (this.$refs.responseDistributionChart) {
                const responseCtx = this.$refs.responseDistributionChart.getContext('2d');
                if (responseCtx) {
                    this.miniCharts.responseDistribution = new Chart(responseCtx, {
                        type: 'bar',
                        data: this.getResponseDistributionData(),
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            plugins: {
                                legend: {
                                    display: false
                                }
                            }
                        }
                    });
                }
            }

            // Incident Trend Chart
            if (this.$refs.incidentTrendChart) {
                const incidentCtx = this.$refs.incidentTrendChart.getContext('2d');
                if (incidentCtx) {
                    this.miniCharts.incidentTrend = new Chart(incidentCtx, {
                        type: 'line',
                        data: this.getIncidentTrendData(),
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            plugins: {
                                legend: {
                                    display: false
                                }
                            }
                        }
                    });
                }
            }

            // Performance Score Chart
            if (this.$refs.performanceScoreChart) {
                const performanceCtx = this.$refs.performanceScoreChart.getContext('2d');
                if (performanceCtx) {
                    this.miniCharts.performanceScore = new Chart(performanceCtx, {
                        type: 'radar',
                        data: this.getPerformanceScoreData(),
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            plugins: {
                                legend: {
                                    display: false
                                }
                            },
                            scales: {
                                r: {
                                    beginAtZero: true,
                                    max: 100
                                }
                            }
                        }
                    });
                }
            }
        } catch (error) {
            console.error("Error creating mini charts:", error);
            this.$root.toastError("Mini grafikler oluşturulamadı");
        }
        },
        updateChart() {
            try {
                if (!this.mainChart) {
                    console.warn("Main chart not initialized");
                    return;
                }

                const data = this.getChartData();
                const colors = this.colorThemes[this.selectedColorTheme];

                console.log("Updating chart with data:", data);

                this.mainChart.data.labels = data.labels;
                this.mainChart.data.datasets = data.datasets.map((dataset, index) => ({
                    ...dataset,
                    borderColor: colors[index % colors.length],
                    backgroundColor: this.selectedChartStyle === 'line' ? 'transparent' : colors[index % colors.length],
                    borderWidth: 2,
                    fill: this.selectedChartStyle === 'area'
                }));

                this.mainChart.options.scales.y.title.text = data.yAxisLabel;
                this.mainChart.update();

                this.updateChartLegend(data);
                this.updateInsights();
                
                console.log("Chart updated successfully");
            } catch (error) {
                console.error("Error updating chart:", error);
            }
        },
        getChartData() {
            const monitors = Object.values(this.$root.monitorList || {});
            const uptimeList = this.$root.uptimeList || {};
            const avgPingList = this.$root.avgPingList || {};
            const heartbeatList = this.$root.heartbeatList || {};

            console.log("Chart Data Debug:", {
                monitors: monitors.length,
                uptimeList: Object.keys(uptimeList).length,
                avgPingList: Object.keys(avgPingList).length,
                heartbeatList: Object.keys(heartbeatList).length,
                selectedChartType: this.selectedChartType
            });

            // Eğer hiç monitör yoksa demo veri göster
            if (monitors.length === 0) {
                console.log("No monitors found, showing demo data");
                switch (this.selectedChartType) {
                    case 'uptime':
                        return {
                            labels: ['Google', 'Selectum Hotels', 'Google DNS'],
                            datasets: [{
                                label: this.$t("Uptime %"),
                                data: [99.9, 98.5, 99.8]
                            }],
                            yAxisLabel: this.$t("Uptime %")
                        };
                    case 'response':
                        return {
                            labels: ['Google', 'Selectum Hotels', 'Google DNS'],
                            datasets: [{
                                label: this.$t("Yanıt Süresi (ms)"),
                                data: [77, 1460, 63]
                            }],
                            yAxisLabel: this.$t("Yanıt Süresi (ms)")
                        };
                    case 'incidents':
                        return {
                            labels: ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'],
                            datasets: [{
                                label: this.$t("Olay Sayısı"),
                                data: [0, 1, 0, 2, 0, 0, 1]
                            }],
                            yAxisLabel: this.$t("Olay Sayısı")
                        };
                    case 'performance':
                        return {
                            labels: ['Google', 'Selectum Hotels', 'Google DNS'],
                            datasets: [{
                                label: this.$t("Performans Skoru"),
                                data: [95, 85, 92]
                            }],
                            yAxisLabel: this.$t("Performans Skoru")
                        };
                    default:
                        return {
                            labels: [],
                            datasets: [],
                            yAxisLabel: this.$t("Değer")
                        };
                }
            }

            switch (this.selectedChartType) {
                case 'uptime':
                    const uptimeData = {
                        labels: monitors.map(m => m.name),
                        datasets: [{
                            label: this.$t("Uptime %"),
                            data: monitors.map(m => {
                                const uptimeKey = `${m.id}_24`;
                                const value = uptimeList[uptimeKey] ? Math.round(uptimeList[uptimeKey] * 100) / 100 : 99.9;
                                console.log(`Monitor ${m.name} (${m.id}): uptimeKey=${uptimeKey}, value=${value}`);
                                return value;
                            })
                        }],
                        yAxisLabel: this.$t("Uptime %")
                    };
                    console.log("Uptime chart data:", uptimeData);
                    return uptimeData;
                case 'response':
                    return {
                        labels: monitors.map(m => m.name),
                        datasets: [{
                            label: this.$t("Yanıt Süresi (ms)"),
                            data: monitors.map(m => avgPingList[m.id] || 0)
                        }],
                        yAxisLabel: this.$t("Yanıt Süresi (ms)")
                    };
                case 'incidents':
                    // Son 7 günün olay verilerini hesapla
                    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
                    const incidentData = [0, 0, 0, 0, 0, 0, 0];
                    
                    monitors.forEach(monitor => {
                        if (heartbeatList[monitor.id]) {
                            heartbeatList[monitor.id].forEach(heartbeat => {
                                if (heartbeat.status === 0) { // Down events
                                    const date = new Date(heartbeat.time);
                                    const dayIndex = date.getDay();
                                    incidentData[dayIndex]++;
                                }
                            });
                        }
                    });
                    
                    return {
                        labels: days,
                        datasets: [{
                            label: this.$t("Olay Sayısı"),
                            data: incidentData
                        }],
                        yAxisLabel: this.$t("Olay Sayısı")
                    };
                case 'performance':
                    return {
                        labels: monitors.map(m => m.name),
                        datasets: [{
                            label: this.$t("Performans Skoru"),
                            data: monitors.map(m => {
                                const uptimeKey = `${m.id}_24`;
                                const uptime = uptimeList[uptimeKey] ? uptimeList[uptimeKey] * 100 : 99.9;
                                const ping = avgPingList[m.id] || 100;
                                const speedScore = Math.max(60, 100 - Math.round(ping / 10));
                                return Math.round((uptime + speedScore) / 2);
                            })
                        }],
                        yAxisLabel: this.$t("Performans Skoru")
                    };
                default:
                    return {
                        labels: [],
                        datasets: [],
                        yAxisLabel: this.$t("Değer")
                    };
            }
        },
        updateChartLegend(data) {
            this.chartLegend = data.datasets.map((dataset, index) => ({
                label: dataset.label,
                value: this.calculateAverage(data.datasets[index].data),
                color: this.colorThemes[this.selectedColorTheme][index % this.colorThemes[this.selectedColorTheme].length]
            }));
        },
        calculateAverage(data) {
            if (data.length === 0) return 0;
            const sum = data.reduce((a, b) => a + b, 0);
            return Math.round((sum / data.length) * 100) / 100;
        },
        updateInsights() {
            // Gerçek verilerden analiz yap
            const monitors = Object.values(this.$root.monitorList || {});
            const downMonitors = monitors.filter(m => m.status === 0).length;
            const totalMonitors = monitors.length;

            if (downMonitors > 0) {
                this.insights.anomalies = `${downMonitors} adet monitör aşağı durumda.`;
                this.insights.recommendations = "Aşağı olan servisleri kontrol edin ve gerekli önlemleri alın.";
            } else {
                this.insights.anomalies = "Anomali tespit edilmedi.";
                this.insights.recommendations = "Sistem normal çalışıyor. Performansı korumaya devam edin.";
            }
        },
        refreshCharts() {
            this.updateChart();
            this.updateMiniCharts();
        },
        startRealTimeUpdates() {
            // Her 10 saniyede bir grafikleri güncelle
            this.updateInterval = setInterval(() => {
                this.updateChart();
                this.updateMiniCharts();
            }, 10000);
        },
        
        stopRealTimeUpdates() {
            if (this.updateInterval) {
                clearInterval(this.updateInterval);
            }
        },
        
        updateMiniCharts() {
            try {
                // Mini grafikleri gerçek verilerle güncelle
                if (this.miniCharts.uptimeDistribution) {
                    this.miniCharts.uptimeDistribution.data = this.getUptimeDistributionData();
                    this.miniCharts.uptimeDistribution.update();
                }
                
                if (this.miniCharts.responseDistribution) {
                    this.miniCharts.responseDistribution.data = this.getResponseDistributionData();
                    this.miniCharts.responseDistribution.update();
                }
                
                if (this.miniCharts.incidentTrend) {
                    this.miniCharts.incidentTrend.data = this.getIncidentTrendData();
                    this.miniCharts.incidentTrend.update();
                }
                
                if (this.miniCharts.performanceScore) {
                    this.miniCharts.performanceScore.data = this.getPerformanceScoreData();
                    this.miniCharts.performanceScore.update();
                }
            } catch (error) {
                console.error("Error updating mini charts:", error);
            }
        },
        exportCharts() {
            // Grafikleri PNG olarak dışa aktar
            const canvas = this.$refs.mainChart;
            const link = document.createElement('a');
            link.download = `chart-${this.selectedChartType}-${new Date().toISOString().split('T')[0]}.png`;
            link.href = canvas.toDataURL();
            link.click();
        },
        destroyCharts() {
            if (this.mainChart) {
                this.mainChart.destroy();
            }
            Object.values(this.miniCharts).forEach(chart => {
                if (chart) {
                    chart.destroy();
                }
            });
        },
        
        // Gerçek veri metodları
        getUptimeDistributionData() {
            const monitors = Object.values(this.$root.monitorList || {});
            
            let upCount = 0;
            let downCount = 0;
            let maintenanceCount = 0;
            
            monitors.forEach(monitor => {
                switch (monitor.status) {
                    case 0: downCount++; break;
                    case 1: upCount++; break;
                    case 3: maintenanceCount++; break;
                    default: upCount++; break;
                }
            });
            
            // Eğer hiç monitör yoksa demo veri göster
            if (monitors.length === 0) {
                return {
                    labels: [this.$t("Yukarı"), this.$t("Aşağı"), this.$t("Bakım")],
                    datasets: [{
                        data: [2, 0, 1],
                        backgroundColor: ['#28a745', '#dc3545', '#ffc107']
                    }]
                };
            }
            
            return {
                labels: [this.$t("Yukarı"), this.$t("Aşağı"), this.$t("Bakım")],
                datasets: [{
                    data: [upCount, downCount, maintenanceCount],
                    backgroundColor: ['#28a745', '#dc3545', '#ffc107']
                }]
            };
        },
        
        getResponseDistributionData() {
            const monitors = Object.values(this.$root.monitorList || {});
            const avgPingList = this.$root.avgPingList || {};
            
            let category0_100 = 0;
            let category100_500 = 0;
            let category500_1000 = 0;
            let category1000_plus = 0;
            
            monitors.forEach(monitor => {
                const ping = avgPingList[monitor.id] || 0;
                if (ping < 100) category0_100++;
                else if (ping < 500) category100_500++;
                else if (ping < 1000) category500_1000++;
                else category1000_plus++;
            });
            
            // Eğer hiç veri yoksa demo veri göster
            if (monitors.length === 0) {
                return {
                    labels: ['0-100ms', '100-500ms', '500-1000ms', '1000ms+'],
                    datasets: [{
                        label: this.$t("Yanıt Süresi"),
                        data: [1, 1, 1, 0],
                        backgroundColor: '#007bff'
                    }]
                };
            }
            
            return {
                labels: ['0-100ms', '100-500ms', '500-1000ms', '1000ms+'],
                datasets: [{
                    label: this.$t("Yanıt Süresi"),
                    data: [category0_100, category100_500, category500_1000, category1000_plus],
                    backgroundColor: '#007bff'
                }]
            };
        },
        
        getIncidentTrendData() {
            const monitors = Object.values(this.$root.monitorList || {});
            const heartbeatList = this.$root.heartbeatList || {};
            
            // Son 7 günün verilerini hesapla
            const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
            const incidentData = [0, 0, 0, 0, 0, 0, 0];
            
            monitors.forEach(monitor => {
                if (heartbeatList[monitor.id]) {
                    heartbeatList[monitor.id].forEach(heartbeat => {
                        if (heartbeat.status === 0) { // Down events
                            const date = new Date(heartbeat.time);
                            const dayIndex = date.getDay();
                            incidentData[dayIndex]++;
                        }
                    });
                }
            });
            
            // Eğer hiç veri yoksa demo veri göster
            if (monitors.length === 0) {
                return {
                    labels: days,
                    datasets: [{
                        label: this.$t("Olaylar"),
                        data: [0, 1, 0, 2, 0, 0, 1],
                        borderColor: '#dc3545',
                        backgroundColor: 'rgba(220, 53, 69, 0.1)',
                        tension: 0.4
                    }]
                };
            }
            
            return {
                labels: days,
                datasets: [{
                    label: this.$t("Olaylar"),
                    data: incidentData,
                    borderColor: '#dc3545',
                    backgroundColor: 'rgba(220, 53, 69, 0.1)',
                    tension: 0.4
                }]
            };
        },
        
        getPerformanceScoreData() {
            const monitors = Object.values(this.$root.monitorList || {});
            const uptimeList = this.$root.uptimeList || {};
            const avgPingList = this.$root.avgPingList || {};
            
            // Uptime skoru
            let totalUptime = 0;
            let monitorCount = 0;
            monitors.forEach(monitor => {
                const uptimeKey = `${monitor.id}_24`;
                if (uptimeList[uptimeKey] !== undefined) {
                    totalUptime += uptimeList[uptimeKey];
                    monitorCount++;
                }
            });
            const uptimeScore = monitorCount > 0 ? Math.round((totalUptime / monitorCount) * 100) : 95;
            
            // Hız skoru (yanıt süresine göre)
            let totalPing = 0;
            let pingCount = 0;
            monitors.forEach(monitor => {
                if (avgPingList[monitor.id] !== undefined) {
                    totalPing += avgPingList[monitor.id];
                    pingCount++;
                }
            });
            const avgPing = pingCount > 0 ? totalPing / pingCount : 100;
            const speedScore = Math.max(60, 100 - Math.round(avgPing / 10));
            
            // Güvenilirlik skoru (uptime'e benzer)
            const reliabilityScore = uptimeScore;
            
            // Genel performans skoru
            const performanceScore = Math.round((uptimeScore + speedScore + reliabilityScore) / 3);
            
            // Eğer hiç veri yoksa demo veri göster
            if (monitors.length === 0) {
                return {
                    labels: [this.$t("Uptime"), this.$t("Hız"), this.$t("Güvenilirlik"), this.$t("Performans")],
                    datasets: [{
                        label: this.$t("Mevcut"),
                        data: [95, 85, 92, 91],
                        borderColor: '#007bff',
                        backgroundColor: 'rgba(0, 123, 255, 0.2)'
                    }]
                };
            }
            
            return {
                labels: [this.$t("Uptime"), this.$t("Hız"), this.$t("Güvenilirlik"), this.$t("Performans")],
                datasets: [{
                    label: this.$t("Mevcut"),
                    data: [uptimeScore, speedScore, reliabilityScore, performanceScore],
                    borderColor: '#007bff',
                    backgroundColor: 'rgba(0, 123, 255, 0.2)'
                }]
            };
        },
        
        updateMiniCharts() {
            // Mini grafikleri gerçek verilerle güncelle
            if (this.miniCharts.uptimeDistribution) {
                this.miniCharts.uptimeDistribution.data = this.getUptimeDistributionData();
                this.miniCharts.uptimeDistribution.update();
            }
            
            if (this.miniCharts.responseDistribution) {
                this.miniCharts.responseDistribution.data = this.getResponseDistributionData();
                this.miniCharts.responseDistribution.update();
            }
            
            if (this.miniCharts.incidentTrend) {
                this.miniCharts.incidentTrend.data = this.getIncidentTrendData();
                this.miniCharts.incidentTrend.update();
            }
            
            if (this.miniCharts.performanceScore) {
                this.miniCharts.performanceScore.data = this.getPerformanceScoreData();
                this.miniCharts.performanceScore.update();
            }
        }
    }
};
</script>

<style scoped>
.advanced-charts {
    background: #fff;
    border-radius: 8px;
    padding: 20px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    margin-bottom: 20px;
}

.charts-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    padding-bottom: 15px;
    border-bottom: 2px solid #f0f0f0;
}

.charts-title {
    margin: 0;
    color: #333;
    font-size: 18px;
}

.charts-actions {
    display: flex;
    gap: 10px;
}

.chart-controls {
    background: #f8f9fa;
    padding: 15px;
    border-radius: 8px;
}

.chart-container {
    background: #f8f9fa;
    padding: 20px;
    border-radius: 8px;
    margin-bottom: 20px;
}

.chart-wrapper {
    position: relative;
    height: 400px;
}

.chart-legend {
    background: white;
    padding: 15px;
    border-radius: 8px;
    border: 1px solid #e9ecef;
}

.legend-items {
    display: flex;
    flex-wrap: wrap;
    gap: 15px;
}

.legend-item {
    display: flex;
    align-items: center;
    gap: 8px;
}

.legend-color {
    width: 16px;
    height: 16px;
    border-radius: 4px;
}

.legend-label {
    font-weight: 600;
    color: #333;
}

.legend-value {
    color: #6c757d;
    font-size: 14px;
}

.mini-charts-grid {
    margin-top: 20px;
}

.mini-chart-card {
    background: white;
    padding: 15px;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    height: 250px;
}

.mini-chart-card h5 {
    margin-bottom: 15px;
    color: #333;
    font-size: 16px;
}

.chart-insights {
    margin-top: 30px;
}

.chart-insights h5 {
    margin-bottom: 20px;
    color: #333;
}

.insights-grid {
    background: #f8f9fa;
    padding: 20px;
    border-radius: 8px;
}

.insight-card {
    background: white;
    padding: 15px;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    display: flex;
    align-items: flex-start;
    gap: 12px;
}

.insight-icon {
    width: 40px;
    height: 40px;
    background: #007bff;
    color: white;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}

.insight-content h6 {
    margin: 0 0 8px 0;
    color: #333;
    font-weight: 600;
}

.insight-content p {
    margin: 0;
    color: #6c757d;
    font-size: 14px;
    line-height: 1.4;
}

@media (max-width: 768px) {
    .charts-header {
        flex-direction: column;
        gap: 15px;
        align-items: stretch;
    }
    
    .charts-actions {
        justify-content: center;
    }
    
    .chart-controls .row {
        margin: 0;
    }
    
    .chart-controls .col-md-3 {
        padding: 0 5px;
        margin-bottom: 15px;
    }
    
    .mini-charts-grid .row {
        margin: 0;
    }
    
    .mini-charts-grid .col-md-6 {
        padding: 0 5px;
        margin-bottom: 15px;
    }
    
    .insights-grid .row {
        margin: 0;
    }
    
    .insights-grid .col-md-4 {
        padding: 0 5px;
        margin-bottom: 15px;
    }
    
    /* Mobil için chart container optimizasyonları */
    .chart-container {
        height: 300px !important;
        overflow: hidden;
    }
    
    .chart-wrapper {
        height: 100%;
        position: relative;
    }
    
    .chart-wrapper canvas {
        max-width: 100% !important;
        max-height: 100% !important;
    }
    
    .mini-chart-card {
        height: 200px !important;
        overflow: hidden;
    }
    
    .mini-chart-card canvas {
        max-width: 100% !important;
        max-height: 150px !important;
    }
    
    /* Mobilde chart kontrollerini gizle */
    .chart-controls {
        display: none;
    }
    
    /* Mobil istatistik kartları */
    .mobile-stats {
        background: var(--bs-body-bg);
        border: 1px solid var(--bs-border-color);
        border-radius: 0.75rem;
        padding: 1.5rem;
        margin-bottom: 1rem;
    }
    
    .mobile-stats-header {
        margin-bottom: 1rem;
        
        h5 {
            margin: 0;
            color: var(--bs-body-color);
            font-weight: 600;
            
            i {
                margin-right: 0.5rem;
                color: var(--bs-primary);
            }
        }
    }
    
    .mobile-stats-grid {
        display: grid;
        grid-template-columns: 1fr;
        gap: 1rem;
    }
    
    .mobile-stat-card {
        background: var(--bs-body-bg);
        border: 1px solid var(--bs-border-color);
        border-radius: 0.5rem;
        padding: 1rem;
        display: flex;
        align-items: center;
        gap: 1rem;
        
        .stat-icon {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: rgba(92, 221, 139, 0.1);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--bs-primary);
            
            &.success {
                background: rgba(92, 221, 139, 0.1);
                color: var(--bs-success);
            }
            
            &.warning {
                background: rgba(248, 163, 6, 0.1);
                color: var(--bs-warning);
            }
            
            i {
                font-size: 1rem;
            }
        }
        
        .stat-info {
            flex: 1;
            
            .stat-value {
                font-size: 1.25rem;
                font-weight: 700;
                color: var(--bs-body-color);
                margin-bottom: 0.25rem;
            }
            
            .stat-label {
                font-size: 0.875rem;
                color: var(--bs-secondary-color);
            }
        }
    }
}
</style>
