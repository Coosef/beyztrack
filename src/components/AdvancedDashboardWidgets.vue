<template>
    <div class="advanced-dashboard-widgets">
        <!-- Debug Info - Only show in development -->
        <div v-if="process.env.NODE_ENV === 'development'" class="alert alert-warning">
            <h4>AdvancedDashboardWidgets Debug:</h4>
            <p>Monitor Count: {{ Object.keys($root.monitorList || {}).length }}</p>
            <p>Avg Response Time: {{ avgResponseTime }}ms</p>
            <p>Uptime Percentage: {{ uptimePercentage }}%</p>
            <p>SLA Metrics Count: {{ slaMetrics.length }}</p>
            <p>Recent Alerts Count: {{ recentAlerts.length }}</p>
            <p>Top Performers Count: {{ topPerformers.length }}</p>
        </div>

        <!-- Performance Trends Widget -->
        <div class="widget-card mb-4">
            <div class="widget-header">
                <h4><font-awesome-icon icon="chart-line" /> {{ $t("Performance Trends") }}</h4>
                <div class="widget-controls">
                    <select v-model="selectedTrendPeriod" class="form-select form-select-sm">
                        <option value="24">{{ $t("Last 24 Hours") }}</option>
                        <option value="168">{{ $t("Last Week") }}</option>
                        <option value="720">{{ $t("Last Month") }}</option>
                    </select>
                </div>
            </div>
            <div class="widget-content">
                <div class="trend-metrics">
                    <div class="trend-item">
                        <span class="trend-label">{{ $t("Average Response Time") }}</span>
                        <span class="trend-value" :class="getTrendClass(avgResponseTimeTrend)">
                            {{ avgResponseTime }}ms
                            <i :class="getTrendIcon(avgResponseTimeTrend)"></i>
                        </span>
                    </div>
                    <div class="trend-item">
                        <span class="trend-label">{{ $t("Uptime Trend") }}</span>
                        <span class="trend-value" :class="getTrendClass(uptimeTrend)">
                            {{ uptimePercentage }}%
                            <i :class="getTrendIcon(uptimeTrend)"></i>
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <!-- SLA Monitoring Widget -->
        <div class="widget-card mb-4">
            <div class="widget-header">
                                 <h4><font-awesome-icon icon="crosshairs" /> {{ $t("SLA Monitoring") }}</h4>
            </div>
            <div class="widget-content">
                <div class="sla-metrics">
                    <div class="sla-item" v-for="sla in slaMetrics" :key="sla.name">
                        <div class="sla-info">
                            <span class="sla-name">{{ sla.name }}</span>
                            <span class="sla-target">{{ $t("Target") }}: {{ sla.target }}%</span>
                        </div>
                        <div class="sla-progress">
                            <div class="progress">
                                <div 
                                    class="progress-bar" 
                                    :class="getSLAStatusClass(sla.current, sla.target)"
                                    :style="{ width: Math.min(sla.current, 100) + '%' }"
                                ></div>
                            </div>
                            <span class="sla-current">{{ sla.current }}%</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Alert History Widget -->
        <div class="widget-card mb-4">
            <div class="widget-header">
                <h4><font-awesome-icon icon="bell" /> {{ $t("Recent Alerts") }}</h4>
                <button class="btn btn-sm btn-outline-primary" @click="refreshAlerts">
                    <font-awesome-icon icon="sync-alt" />
                </button>
            </div>
            <div class="widget-content">
                <div class="alert-list">
                    <div v-for="alert in recentAlerts" :key="alert.id" class="alert-item">
                        <div class="alert-icon">
                            <i :class="getAlertIcon(alert.type)" :style="{ color: getAlertColor(alert.type) }"></i>
                        </div>
                        <div class="alert-content">
                            <div class="alert-title">{{ alert.title }}</div>
                            <div class="alert-time">{{ formatTime(alert.time) }}</div>
                        </div>
                        <div class="alert-status" :class="getAlertStatusClass(alert.status)">
                            {{ alert.status }}
                        </div>
                    </div>
                    <div v-if="recentAlerts.length === 0" class="no-alerts">
                        {{ $t("No recent alerts") }}
                    </div>
                </div>
            </div>
        </div>

        <!-- Top Performers Widget -->
        <div class="widget-card mb-4">
            <div class="widget-header">
                <h4><font-awesome-icon icon="trophy" /> {{ $t("Top Performers") }}</h4>
            </div>
            <div class="widget-content">
                <div class="performer-list">
                    <div v-for="(performer, index) in topPerformers" :key="performer.id" class="performer-item">
                        <div class="performer-rank">
                            <span class="rank-number">{{ index + 1 }}</span>
                        </div>
                        <div class="performer-info">
                            <div class="performer-name">{{ performer.name }}</div>
                            <div class="performer-stats">
                                <span class="uptime">{{ performer.uptime }}% {{ $t("Uptime") }}</span>
                                <span class="response-time">{{ performer.responseTime }}ms {{ $t("Response") }}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import Status from "./Status.vue";

export default {
    name: "AdvancedDashboardWidgets",
    components: {
        Status,
    },
    data() {
        return {
            selectedTrendPeriod: "24",
            // avgResponseTime: 0, // Removed as it's now computed
            // avgResponseTimeTrend: "stable", // Removed as it's now computed
            // uptimePercentage: 0, // Removed as it's now computed
            // uptimeTrend: "stable", // Removed as it's now computed
            // slaMetrics: [ // Removed as it's now computed
            //     { name: "99.9% Uptime", target: 99.9, current: 99.95 },
            //     { name: "Response Time < 200ms", target: 95, current: 92 },
            //     { name: "Error Rate < 1%", target: 99, current: 99.5 },
            // ],
            // recentAlerts: [ // Removed as it's now computed
            //     {
            //         id: 1,
            //         title: "Server response time increased",
            //         type: "warning",
            //         status: "resolved",
            //         time: new Date(Date.now() - 2 * 60 * 60 * 1000),
            //     },
            //     {
            //         id: 2,
            //         title: "Database connection timeout",
            //         type: "error",
            //         status: "active",
            //         time: new Date(Date.now() - 30 * 60 * 1000),
            //     },
            // ],
            // topPerformers: [ // Removed as it's now computed
            //     {
            //         id: 1,
            //         name: "Web Server",
            //         uptime: 99.99,
            //         avgResponseTime: 45,
            //         status: "up",
            //     },
            //     {
            //         id: 2,
            //         name: "Database Server",
            //         uptime: 99.95,
            //         avgResponseTime: 12,
            //         status: "up",
            //     },
            //     {
            //         id: 3,
            //         name: "API Gateway",
            //         uptime: 99.87,
            //         avgResponseTime: 78,
            //         status: "up",
            //     },
            // ],
        };
    },
    computed: {
        avgResponseTime() {
            const monitors = Object.values(this.$root.monitorList);
            if (monitors.length === 0) return 0;
            
            let totalPing = 0;
            let pingCount = 0;
            
            monitors.forEach(monitor => {
                if (this.$root.avgPingList[monitor.id] !== undefined) {
                    totalPing += this.$root.avgPingList[monitor.id];
                    pingCount++;
                }
            });
            
            return pingCount > 0 ? Math.round(totalPing / pingCount) : 0;
        },

        uptimePercentage() {
            const monitors = Object.values(this.$root.monitorList);
            if (monitors.length === 0) return 0;
            
            let totalUptime = 0;
            let monitorCount = 0;
            
            monitors.forEach(monitor => {
                const uptimeKey = `${monitor.id}_24`;
                if (this.$root.uptimeList[uptimeKey] !== undefined) {
                    totalUptime += this.$root.uptimeList[uptimeKey];
                    monitorCount++;
                }
            });
            
            // Convert to percentage (multiply by 100)
            return monitorCount > 0 ? Math.round((totalUptime / monitorCount) * 10000) / 100 : 0;
        },

        avgResponseTimeTrend() {
            // Calculate trend based on recent heartbeats
            const monitors = Object.values(this.$root.monitorList);
            if (monitors.length === 0) return 'stable';
            
            let recentPing = 0;
            let oldPing = 0;
            let pingCount = 0;
            
            monitors.forEach(monitor => {
                if (this.$root.heartbeatList[monitor.id] && this.$root.heartbeatList[monitor.id].length >= 10) {
                    const recent = this.$root.heartbeatList[monitor.id].slice(-5);
                    const old = this.$root.heartbeatList[monitor.id].slice(-10, -5);
                    
                    const recentAvg = recent.reduce((sum, beat) => sum + (beat.ping || 0), 0) / recent.length;
                    const oldAvg = old.reduce((sum, beat) => sum + (beat.ping || 0), 0) / old.length;
                    
                    recentPing += recentAvg;
                    oldPing += oldAvg;
                    pingCount++;
                }
            });
            
            if (pingCount === 0) return 'stable';
            
            const recentAvg = recentPing / pingCount;
            const oldAvg = oldPing / pingCount;
            
            if (recentAvg < oldAvg * 0.9) return 'improving';
            if (recentAvg > oldAvg * 1.1) return 'declining';
            return 'stable';
        },

        uptimeTrend() {
            // Calculate trend based on recent uptime changes
            const monitors = Object.values(this.$root.monitorList);
            if (monitors.length === 0) return 'stable';
            
            let improving = 0;
            let declining = 0;
            
            monitors.forEach(monitor => {
                if (this.$root.heartbeatList[monitor.id] && this.$root.heartbeatList[monitor.id].length >= 20) {
                    const recent = this.$root.heartbeatList[monitor.id].slice(-10);
                    const old = this.$root.heartbeatList[monitor.id].slice(-20, -10);
                    
                    const recentUptime = recent.filter(beat => beat.status === 1).length / recent.length;
                    const oldUptime = old.filter(beat => beat.status === 1).length / old.length;
                    
                    if (recentUptime > oldUptime + 0.05) improving++;
                    else if (recentUptime < oldUptime - 0.05) declining++;
                }
            });
            
            if (improving > declining) return 'improving';
            if (declining > improving) return 'declining';
            return 'stable';
        },

        slaMetrics() {
            const monitors = Object.values(this.$root.monitorList);
            return monitors.map(monitor => {
                const uptimeKey = `${monitor.id}_24`;
                const current = this.$root.uptimeList[uptimeKey] !== undefined 
                    ? Math.round(this.$root.uptimeList[uptimeKey] * 100) / 100 
                    : 0;
                
                return {
                    name: monitor.name,
                    current: current,
                    target: 99.9 // Default SLA target
                };
            }).slice(0, 5); // Show top 5
        },

        recentAlerts() {
            const alerts = [];
            Object.values(this.$root.monitorList).forEach(monitor => {
                if (this.$root.heartbeatList[monitor.id]) {
                    const importantHeartbeats = this.$root.heartbeatList[monitor.id].filter(beat => beat.important);
                    importantHeartbeats.forEach(beat => {
                        alerts.push({
                            id: `${monitor.id}_${beat.time}`,
                            title: `${monitor.name} - ${beat.status === 1 ? 'Up' : 'Down'}`,
                            type: beat.status === 1 ? 'success' : 'error',
                            time: beat.time,
                            status: beat.status === 1 ? 'Resolved' : 'Active'
                        });
                    });
                }
            });
            
            // Sort by time and take recent 10
            return alerts
                .sort((a, b) => new Date(b.time) - new Date(a.time))
                .slice(0, 10);
        },

        topPerformers() {
            const monitors = Object.values(this.$root.monitorList);
            return monitors
                .map(monitor => {
                    const uptimeKey = `${monitor.id}_24`;
                    const uptime = this.$root.uptimeList[uptimeKey] !== undefined 
                        ? Math.round(this.$root.uptimeList[uptimeKey] * 100) / 100 
                        : 0;
                    
                    const ping = this.$root.avgPingList[monitor.id] || 0;
                    
                    return {
                        id: monitor.id,
                        name: monitor.name,
                        uptime: uptime,
                        responseTime: Math.round(ping),
                        score: uptime * 0.7 + (1000 - Math.min(ping, 1000)) * 0.3 // Weighted score
                    };
                })
                .sort((a, b) => b.score - a.score)
                .slice(0, 5);
        }
    },
    methods: {
        getTrendClass(trend) {
            return {
                "trend-up": trend === "up",
                "trend-down": trend === "down",
                "trend-stable": trend === "stable",
            };
        },
        getTrendIcon(trend) {
            return {
                            "text-success": trend === "up",
            "text-danger": trend === "down",
            "text-secondary": trend === "stable",
            };
        },
        getSLAStatusClass(current, target) {
            if (current >= target) return "bg-success";
            if (current >= target * 0.9) return "bg-warning";
            return "bg-danger";
        },
        getAlertIcon(type) {
            return {
                "fas fa-exclamation-triangle": type === "warning",
                "fas fa-times-circle": type === "error",
                "fas fa-info-circle": type === "info",
            };
        },
        getAlertColor(type) {
            return {
                warning: "#ffc107",
                error: "#dc3545",
                info: "#17a2b8",
            };
        },
        getAlertStatusClass(status) {
            return {
                "status-resolved": status === "resolved",
                "status-active": status === "active",
            };
        },
        formatTime(time) {
            return new Intl.RelativeTimeFormat("tr", { numeric: "auto" }).format(
                Math.round((time - new Date()) / (1000 * 60)),
                "minute"
            );
        },
        refreshAlerts() {
            // Simulate refreshing alerts
            this.$root.toastSuccess("Alerts refreshed");
        },
        async loadTrendData() {
            // Simulate loading trend data
            this.avgResponseTime = Math.floor(Math.random() * 100) + 50;
            this.uptimePercentage = (Math.random() * 2 + 98).toFixed(2);
            
            // Simulate trend calculation
            const trends = ["up", "down", "stable"];
            this.avgResponseTimeTrend = trends[Math.floor(Math.random() * trends.length)];
            this.uptimeTrend = trends[Math.floor(Math.random() * trends.length)];
        },
    },
    mounted() {
        console.log("AdvancedDashboardWidgets mounted");
        console.log("$root:", this.$root);
        console.log("$root.monitorList:", this.$root.monitorList);
        console.log("$root.stats:", this.$root.stats);
        console.log("avgResponseTime:", this.avgResponseTime);
        console.log("uptimePercentage:", this.uptimePercentage);
        console.log("slaMetrics:", this.slaMetrics);
        console.log("recentAlerts:", this.recentAlerts);
        console.log("topPerformers:", this.topPerformers);
        
        // Force a re-render
        this.$forceUpdate();
        
        this.loadTrendData();
        // Refresh data every 5 minutes
        setInterval(this.loadTrendData, 5 * 60 * 1000);
    },
};
</script>

<style lang="scss" scoped>
.advanced-dashboard-widgets {
    .widget-card {
        border-radius: 8px !important;
        background: var(--bs-body-bg) !important;
        border: 1px solid var(--bs-border-color) !important;
        box-shadow: 0 15px 70px rgba(0, 0, 0, 0.1) !important;
        
        .widget-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1rem;
            border-bottom: 1px solid var(--bs-border-color) !important;
            
            h4 {
                margin: 0;
                font-size: 1.1rem;
                font-weight: 600;
                color: var(--bs-body-color) !important;
                
                i {
                    margin-right: 0.5rem;
                    color: var(--bs-secondary-color) !important;
                }
            }
            
            .form-select {
                background-color: var(--bs-body-bg) !important;
                border-color: var(--bs-border-color) !important;
                color: var(--bs-body-color) !important;
                
                &:focus {
                    background-color: var(--bs-body-bg) !important;
                    border-color: var(--bs-primary) !important;
                    color: var(--bs-body-color) !important;
                    box-shadow: 0 0 0 0.2rem rgba(var(--bs-primary-rgb), 0.25) !important;
                }
            }
        }
        
        .widget-content {
            padding: 1rem;
        }
    }
    
    .trend-metrics {
        .trend-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 0.5rem;
            
            .trend-label {
                font-weight: 500;
                color: var(--bs-secondary-color) !important;
            }
            
            .trend-value {
                font-weight: 600;
                font-size: 1.1rem;
                color: var(--bs-body-color) !important;
                
                i {
                    margin-left: 0.5rem;
                }
            }
        }
    }
    
    .sla-metrics {
        .sla-item {
            margin-bottom: 1rem;
            
            .sla-info {
                display: flex;
                justify-content: space-between;
                margin-bottom: 0.5rem;
                
                .sla-name {
                    font-weight: 500;
                    color: var(--bs-body-color) !important;
                }
                
                .sla-target {
                    color: var(--bs-secondary-color) !important;
                    font-size: 0.9rem;
                }
            }
            
            .sla-progress {
                display: flex;
                align-items: center;
                gap: 0.5rem;
                
                .progress {
                    flex: 1;
                    height: 8px;
                    border-radius: 4px;
                    background-color: var(--bs-secondary-bg) !important;
                    
                    .progress-bar {
                        height: 100%;
                        border-radius: 4px;
                        transition: width 0.3s ease;
                    }
                }
                
                .sla-current {
                    font-weight: 600;
                    font-size: 0.9rem;
                    min-width: 40px;
                    text-align: right;
                    color: var(--bs-body-color) !important;
                }
            }
        }
    }
    
    .alert-list {
        .alert-item {
            display: flex;
            align-items: center;
            padding: 0.75rem;
            border-radius: 6px;
            background-color: var(--bs-secondary-bg) !important;
            margin-bottom: 0.5rem;
            border: 1px solid var(--bs-border-color) !important;
            
            .alert-icon {
                margin-right: 0.75rem;
                font-size: 1.2rem;
            }
            
            .alert-content {
                flex: 1;
                
                .alert-title {
                    font-weight: 500;
                    margin-bottom: 0.25rem;
                    color: var(--bs-body-color) !important;
                }
                
                .alert-time {
                    font-size: 0.85rem;
                    color: var(--bs-secondary-color) !important;
                }
            }
            
            .alert-status {
                font-size: 0.8rem;
                font-weight: 600;
                padding: 0.25rem 0.5rem;
                border-radius: 4px;
                
                &.status-resolved {
                    background-color: rgba(40, 167, 69, 0.2) !important;
                    color: #28a745 !important;
                }
                
                &.status-active {
                    background-color: rgba(220, 53, 69, 0.2) !important;
                    color: #dc3545 !important;
                }
            }
        }
        
        .no-alerts {
            text-align: center;
            color: var(--bs-secondary-color) !important;
            padding: 2rem;
        }
    }
    
    .performer-list {
        .performer-item {
            display: flex;
            align-items: center;
            padding: 0.75rem;
            border-radius: 6px;
            background-color: var(--bs-secondary-bg) !important;
            margin-bottom: 0.5rem;
            border: 1px solid var(--bs-border-color) !important;
            
            .performer-rank {
                margin-right: 0.75rem;
                
                .rank-number {
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    width: 30px;
                    height: 30px;
                    background-color: var(--bs-primary) !important;
                    color: white;
                    border-radius: 50%;
                    font-weight: 600;
                    font-size: 0.9rem;
                }
            }
            
            .performer-info {
                flex: 1;
                
                .performer-name {
                    font-weight: 500;
                    margin-bottom: 0.25rem;
                    color: var(--bs-body-color) !important;
                }
                
                .performer-stats {
                    font-size: 0.85rem;
                    color: var(--bs-secondary-color) !important;
                    
                    span {
                        margin-right: 1rem;
                    }
                }
            }
            
            .performer-status {
                margin-left: 0.75rem;
            }
        }
    }
}

.trend-up {
    color: #28a745 !important;
}

.trend-down {
    color: #dc3545 !important;
}

.trend-stable {
    color: var(--bs-secondary-color) !important;
}

// Button styling for dark theme
.btn {
    &:focus {
        box-shadow: 0 0 0 0.2rem rgba(var(--bs-primary-rgb), 0.25) !important;
    }
}

// Form elements for dark theme
.form-control,
.form-select {
    &:focus {
        background-color: var(--bs-body-bg) !important;
        border-color: var(--bs-primary) !important;
        color: var(--bs-body-color) !important;
        box-shadow: 0 0 0 0.2rem rgba(var(--bs-primary-rgb), 0.25) !important;
    }
}
</style>
