<template>
    <div class="trend-analysis-module">
        <!-- Module Header -->
        <div class="module-header">
            <h3 class="module-title">
                <i class="fas fa-trending-up"></i>
                {{ $t("Trend Analysis") }}
            </h3>
            <div class="module-actions">
                <select v-model="selectedPeriod" class="form-select form-select-sm" style="width: auto;">
                    <option value="24h">{{ $t("Last 24 Hours") }}</option>
                    <option value="7d">{{ $t("Last 7 Days") }}</option>
                    <option value="30d">{{ $t("Last 30 Days") }}</option>
                    <option value="90d">{{ $t("Last 90 Days") }}</option>
                </select>
                <button class="btn btn-sm btn-outline-primary" @click="refreshTrends">
                    <i class="fas fa-sync-alt"></i> {{ $t("Refresh") }}
                </button>
            </div>
        </div>

        <!-- Trend Overview Cards -->
        <div class="trend-overview mb-4">
            <div class="row">
                <div class="col-md-3">
                    <div class="trend-card" :class="getTrendClass(trends.uptimeTrend)">
                        <div class="trend-icon">
                            <i class="fas fa-chart-line"></i>
                        </div>
                        <div class="trend-content">
                            <div class="trend-value">{{ trends.uptimeTrend }}%</div>
                            <div class="trend-label">{{ $t("Uptime Trend") }}</div>
                            <div class="trend-change" :class="getTrendChangeClass(trends.uptimeChange)">
                                <i :class="getTrendIcon(trends.uptimeChange)"></i>
                                {{ Math.abs(trends.uptimeChange) }}%
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="trend-card" :class="getTrendClass(trends.responseTrend)">
                        <div class="trend-icon">
                            <i class="fas fa-tachometer-alt"></i>
                        </div>
                        <div class="trend-content">
                            <div class="trend-value">{{ trends.responseTrend }}ms</div>
                            <div class="trend-label">{{ $t("Response Trend") }}</div>
                            <div class="trend-change" :class="getTrendChangeClass(trends.responseChange)">
                                <i :class="getTrendIcon(trends.responseChange)"></i>
                                {{ Math.abs(trends.responseChange) }}ms
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="trend-card" :class="getTrendClass(trends.incidentTrend)">
                        <div class="trend-icon">
                            <i class="fas fa-exclamation-triangle"></i>
                        </div>
                        <div class="trend-content">
                            <div class="trend-value">{{ trends.incidentTrend }}</div>
                            <div class="trend-label">{{ $t("Incident Trend") }}</div>
                            <div class="trend-change" :class="getTrendChangeClass(trends.incidentChange)">
                                <i :class="getTrendIcon(trends.incidentChange)"></i>
                                {{ Math.abs(trends.incidentChange) }}
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="trend-card" :class="getTrendClass(trends.performanceScore)">
                        <div class="trend-icon">
                            <i class="fas fa-star"></i>
                        </div>
                        <div class="trend-content">
                            <div class="trend-value">{{ trends.performanceScore }}/100</div>
                            <div class="trend-label">{{ $t("Performance Score") }}</div>
                            <div class="trend-change" :class="getTrendChangeClass(trends.performanceChange)">
                                <i :class="getTrendIcon(trends.performanceChange)"></i>
                                {{ Math.abs(trends.performanceChange) }}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Trend Charts -->
        <div class="trend-charts mb-4" v-if="!isMobile">
            <div class="row">
                <div class="col-md-6">
                    <div class="chart-card">
                        <h5 class="chart-title">{{ $t("Uptime Trend") }}</h5>
                        <canvas ref="uptimeTrendChart" width="400" height="200"></canvas>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="chart-card">
                        <h5 class="chart-title">{{ $t("Response Time Trend") }}</h5>
                        <canvas ref="responseTrendChart" width="400" height="200"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <!-- Anomaly Detection -->
        <div class="anomaly-section mb-4">
            <h5 class="section-title">
                <i class="fas fa-exclamation-triangle"></i>
                {{ $t("Anomaly Detection") }}
            </h5>
            <div class="anomaly-list">
                <div v-for="anomaly in anomalies" :key="anomaly.id" class="anomaly-item" :class="anomaly.severity">
                    <div class="anomaly-icon">
                        <i :class="getAnomalyIcon(anomaly.type)"></i>
                    </div>
                    <div class="anomaly-content">
                        <div class="anomaly-title">{{ anomaly.title }}</div>
                        <div class="anomaly-description">{{ anomaly.description }}</div>
                        <div class="anomaly-time">{{ formatTime(anomaly.timestamp) }}</div>
                    </div>
                    <div class="anomaly-severity">
                        <span class="badge" :class="getSeverityClass(anomaly.severity)">
                            {{ anomaly.severity }}
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Performance Predictions -->
        <div class="predictions-section">
            <h5 class="section-title">
                <i class="fas fa-crystal-ball"></i>
                {{ $t("Performance Predictions") }}
            </h5>
            <div class="predictions-grid">
                <div class="prediction-card">
                    <div class="prediction-header">
                        <i class="fas fa-calendar"></i>
                        {{ $t("Next 24 Hours") }}
                    </div>
                    <div class="prediction-content">
                        <div class="prediction-item">
                            <span class="prediction-label">{{ $t("Expected Uptime") }}:</span>
                            <span class="prediction-value">{{ predictions.next24h.uptime }}%</span>
                        </div>
                        <div class="prediction-item">
                            <span class="prediction-label">{{ $t("Expected Response") }}:</span>
                            <span class="prediction-value">{{ predictions.next24h.response }}ms</span>
                        </div>
                        <div class="prediction-item">
                            <span class="prediction-label">{{ $t("Risk Level") }}:</span>
                            <span class="prediction-value" :class="getRiskClass(predictions.next24h.risk)">
                                {{ predictions.next24h.risk }}
                            </span>
                        </div>
                    </div>
                </div>
                <div class="prediction-card">
                    <div class="prediction-header">
                        <i class="fas fa-calendar-week"></i>
                        {{ $t("Next 7 Days") }}
                    </div>
                    <div class="prediction-content">
                        <div class="prediction-item">
                            <span class="prediction-label">{{ $t("Expected Uptime") }}:</span>
                            <span class="prediction-value">{{ predictions.next7d.uptime }}%</span>
                        </div>
                        <div class="prediction-item">
                            <span class="prediction-label">{{ $t("Expected Response") }}:</span>
                            <span class="prediction-value">{{ predictions.next7d.response }}ms</span>
                        </div>
                        <div class="prediction-item">
                            <span class="prediction-label">{{ $t("Risk Level") }}:</span>
                            <span class="prediction-value" :class="getRiskClass(predictions.next7d.risk)">
                                {{ predictions.next7d.risk }}
                            </span>
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
    name: "TrendAnalysisModule",
    data() {
        return {
            selectedPeriod: "7d",
            isMobile: false,
            trends: {
                uptimeTrend: 98.5,
                uptimeChange: 0.3,
                responseTrend: 245,
                responseChange: -12,
                incidentTrend: 2,
                incidentChange: -1,
                performanceScore: 87,
                performanceChange: 2
            },
            anomalies: [
                {
                    id: 1,
                    type: "response_time",
                    title: "Yüksek Yanıt Süresi",
                    description: "Google DNS monitor'da ortalama yanıt süresi %25 arttı",
                    timestamp: new Date(Date.now() - 2 * 60 * 60 * 1000),
                    severity: "warning"
                },
                {
                    id: 2,
                    type: "uptime",
                    title: "Uptime Düşüşü",
                    description: "Selectum Hotels'te kısa süreli kesinti tespit edildi",
                    timestamp: new Date(Date.now() - 6 * 60 * 60 * 1000),
                    severity: "info"
                }
            ],
            predictions: {
                next24h: {
                    uptime: 98.2,
                    response: 238,
                    risk: "low"
                },
                next7d: {
                    uptime: 97.8,
                    response: 245,
                    risk: "medium"
                }
            },
            charts: {
                uptimeTrend: null,
                responseTrend: null
            }
        };
    },
    mounted() {
        this.isMobile = this.$root.isMobile || window.innerWidth < 768;
        if (!this.isMobile) {
            this.$nextTick(() => {
                this.initCharts();
            });
        }
        this.loadTrendData();
    },
    beforeUnmount() {
        if (this.charts.uptimeTrend) {
            this.charts.uptimeTrend.destroy();
        }
        if (this.charts.responseTrend) {
            this.charts.responseTrend.destroy();
        }
    },
    methods: {
        loadTrendData() {
            // Gerçek verilerden trend hesaplama
            const monitors = this.$root.monitorList || [];
            const uptimeList = this.$root.uptimeList || {};
            const avgPingList = this.$root.avgPingList || {};
            
            if (monitors.length > 0) {
                // Uptime trend hesaplama
                let totalUptime = 0;
                let monitorCount = 0;
                
                monitors.forEach(monitor => {
                    const uptimeKey = `${monitor.id}_24`;
                    if (uptimeList[uptimeKey] !== undefined) {
                        totalUptime += uptimeList[uptimeKey] * 100;
                        monitorCount++;
                    }
                });
                
                if (monitorCount > 0) {
                    this.trends.uptimeTrend = Math.round((totalUptime / monitorCount) * 100) / 100;
                }
                
                // Response time trend hesaplama
                let totalResponse = 0;
                let responseCount = 0;
                
                monitors.forEach(monitor => {
                    const pingKey = `${monitor.id}_24`;
                    if (avgPingList[pingKey] !== undefined) {
                        totalResponse += avgPingList[pingKey];
                        responseCount++;
                    }
                });
                
                if (responseCount > 0) {
                    this.trends.responseTrend = Math.round(totalResponse / responseCount);
                }
            }
        },
        
        initCharts() {
            this.initUptimeTrendChart();
            this.initResponseTrendChart();
        },
        
        initUptimeTrendChart() {
            const ctx = this.$refs.uptimeTrendChart;
            if (!ctx) return;
            
            this.charts.uptimeTrend = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: ['00:00', '04:00', '08:00', '12:00', '16:00', '20:00', '24:00'],
                    datasets: [{
                        label: 'Uptime %',
                        data: [98.5, 98.2, 98.8, 98.1, 98.9, 98.3, 98.5],
                        borderColor: 'rgb(75, 192, 192)',
                        backgroundColor: 'rgba(75, 192, 192, 0.1)',
                        tension: 0.4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: false,
                            min: 95,
                            max: 100
                        }
                    }
                }
            });
        },
        
        initResponseTrendChart() {
            const ctx = this.$refs.responseTrendChart;
            if (!ctx) return;
            
            this.charts.responseTrend = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: ['00:00', '04:00', '08:00', '12:00', '16:00', '20:00', '24:00'],
                    datasets: [{
                        label: 'Response Time (ms)',
                        data: [245, 238, 252, 248, 235, 242, 245],
                        borderColor: 'rgb(255, 99, 132)',
                        backgroundColor: 'rgba(255, 99, 132, 0.1)',
                        tension: 0.4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: false
                        }
                    }
                }
            });
        },
        
        refreshTrends() {
            this.loadTrendData();
            if (!this.isMobile && this.charts.uptimeTrend) {
                this.updateCharts();
            }
            this.$root.toastSuccess("Trend verileri güncellendi");
        },
        
        updateCharts() {
            // Chart verilerini güncelle
            if (this.charts.uptimeTrend) {
                this.charts.uptimeTrend.update();
            }
            if (this.charts.responseTrend) {
                this.charts.responseTrend.update();
            }
        },
        
        getTrendClass(value) {
            if (value >= 95) return 'positive';
            if (value >= 90) return 'neutral';
            return 'negative';
        },
        
        getTrendChangeClass(change) {
            if (change > 0) return 'positive';
            if (change < 0) return 'negative';
            return 'neutral';
        },
        
        getTrendIcon(change) {
            if (change > 0) return 'fas fa-arrow-up';
            if (change < 0) return 'fas fa-arrow-down';
            return 'fas fa-minus';
        },
        
        getAnomalyIcon(type) {
            const icons = {
                response_time: 'fas fa-clock',
                uptime: 'fas fa-server',
                performance: 'fas fa-tachometer-alt'
            };
            return icons[type] || 'fas fa-exclamation';
        },
        
        getSeverityClass(severity) {
            const classes = {
                low: 'bg-success',
                warning: 'bg-warning',
                danger: 'bg-danger',
                info: 'bg-info'
            };
            return classes[severity] || 'bg-secondary';
        },
        
        getRiskClass(risk) {
            const classes = {
                low: 'text-success',
                medium: 'text-warning',
                high: 'text-danger'
            };
            return classes[risk] || 'text-secondary';
        },
        
        formatTime(timestamp) {
            return new Date(timestamp).toLocaleString('tr-TR');
        }
    }
};
</script>

<style lang="scss" scoped>
.trend-analysis-module {
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
        align-items: center;
    }
}

.trend-overview {
    .trend-card {
        display: flex;
        align-items: center;
        padding: 1rem;
        border-radius: 0.5rem;
        background: var(--bs-body-bg);
        border: 1px solid var(--bs-border-color);
        transition: all 0.3s ease;
        
        &.positive {
            border-left: 4px solid var(--bs-success);
        }
        
        &.negative {
            border-left: 4px solid var(--bs-danger);
        }
        
        &.neutral {
            border-left: 4px solid var(--bs-warning);
        }
        
        .trend-icon {
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
        
        .trend-content {
            flex: 1;
            
            .trend-value {
                font-size: 1.5rem;
                font-weight: 700;
                color: var(--bs-body-color);
                line-height: 1;
            }
            
            .trend-label {
                font-size: 0.875rem;
                color: var(--bs-secondary);
                margin-bottom: 0.25rem;
            }
            
            .trend-change {
                font-size: 0.75rem;
                font-weight: 600;
                
                &.positive {
                    color: var(--bs-success);
                }
                
                &.negative {
                    color: var(--bs-danger);
                }
                
                &.neutral {
                    color: var(--bs-secondary);
                }
                
                i {
                    margin-right: 0.25rem;
                }
            }
        }
    }
}

.trend-charts {
    .chart-card {
        background: var(--bs-body-bg);
        border: 1px solid var(--bs-border-color);
        border-radius: 0.5rem;
        padding: 1rem;
        
        .chart-title {
            margin-bottom: 1rem;
            font-size: 1rem;
            font-weight: 600;
            color: var(--bs-body-color);
        }
        
        canvas {
            max-height: 200px;
        }
    }
}

.anomaly-section {
    .section-title {
        margin-bottom: 1rem;
        font-size: 1.1rem;
        font-weight: 600;
        color: var(--bs-body-color);
        
        i {
            margin-right: 0.5rem;
            color: var(--bs-warning);
        }
    }
    
    .anomaly-list {
        .anomaly-item {
            display: flex;
            align-items: center;
            padding: 1rem;
            margin-bottom: 0.5rem;
            border-radius: 0.5rem;
            background: var(--bs-body-bg);
            border: 1px solid var(--bs-border-color);
            
            &.warning {
                border-left: 4px solid var(--bs-warning);
            }
            
            &.danger {
                border-left: 4px solid var(--bs-danger);
            }
            
            &.info {
                border-left: 4px solid var(--bs-info);
            }
            
            .anomaly-icon {
                width: 2.5rem;
                height: 2.5rem;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                margin-right: 1rem;
                background: rgba(255, 193, 7, 0.1);
                color: var(--bs-warning);
            }
            
            .anomaly-content {
                flex: 1;
                
                .anomaly-title {
                    font-weight: 600;
                    color: var(--bs-body-color);
                    margin-bottom: 0.25rem;
                }
                
                .anomaly-description {
                    font-size: 0.875rem;
                    color: var(--bs-secondary);
                    margin-bottom: 0.25rem;
                }
                
                .anomaly-time {
                    font-size: 0.75rem;
                    color: var(--bs-secondary);
                }
            }
            
            .anomaly-severity {
                .badge {
                    font-size: 0.75rem;
                }
            }
        }
    }
}

.predictions-section {
    .section-title {
        margin-bottom: 1rem;
        font-size: 1.1rem;
        font-weight: 600;
        color: var(--bs-body-color);
        
        i {
            margin-right: 0.5rem;
            color: var(--bs-info);
        }
    }
    
    .predictions-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        gap: 1rem;
        
        .prediction-card {
            background: var(--bs-body-bg);
            border: 1px solid var(--bs-border-color);
            border-radius: 0.5rem;
            padding: 1rem;
            
            .prediction-header {
                display: flex;
                align-items: center;
                margin-bottom: 1rem;
                font-weight: 600;
                color: var(--bs-body-color);
                
                i {
                    margin-right: 0.5rem;
                    color: var(--bs-info);
                }
            }
            
            .prediction-content {
                .prediction-item {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    padding: 0.5rem 0;
                    border-bottom: 1px solid var(--bs-border-color);
                    
                    &:last-child {
                        border-bottom: none;
                    }
                    
                    .prediction-label {
                        font-size: 0.875rem;
                        color: var(--bs-secondary);
                    }
                    
                    .prediction-value {
                        font-weight: 600;
                        color: var(--bs-body-color);
                    }
                }
            }
        }
    }
}

@media (max-width: 768px) {
    .trend-overview {
        .trend-card {
            margin-bottom: 1rem;
        }
    }
    
    .predictions-grid {
        grid-template-columns: 1fr;
    }
}
</style>
