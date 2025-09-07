<template>
    <div class="real-time-data-module">
        <div class="module-header">
            <h3 class="module-title">
                <i class="fas fa-broadcast-tower"></i>
                {{ $t("Gerçek Zamanlı Veriler") }}
            </h3>
            <div class="module-actions">
                <div class="connection-status" :class="{ 'connected': isConnected }">
                    <i class="fas fa-circle"></i>
                    {{ isConnected ? $t("Bağlı") : $t("Bağlantı Kesildi") }}
                </div>
                <button class="btn btn-sm btn-outline-primary" @click="refreshData">
                    <i class="fas fa-sync-alt"></i> {{ $t("Yenile") }}
                </button>
            </div>
        </div>

        <!-- Real-time Stats -->
        <div class="real-time-stats mb-4">
            <div class="row">
                <div class="col-md-3">
                    <div class="stat-card live">
                        <div class="stat-icon">
                            <i class="fas fa-server"></i>
                        </div>
                        <div class="stat-content">
                            <div class="stat-value">{{ liveData.totalMonitors }}</div>
                            <div class="stat-label">{{ $t("Aktif Monitörler") }}</div>
                            <div class="stat-change" :class="getChangeClass(liveData.monitorChange)">
                                <i :class="getChangeIcon(liveData.monitorChange)"></i>
                                {{ liveData.monitorChange }}
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card live">
                        <div class="stat-icon success">
                            <i class="fas fa-check-circle"></i>
                        </div>
                        <div class="stat-content">
                            <div class="stat-value">{{ liveData.uptimePercentage }}%</div>
                            <div class="stat-label">{{ $t("Anlık Uptime") }}</div>
                            <div class="stat-change" :class="getChangeClass(liveData.uptimeChange)">
                                <i :class="getChangeIcon(liveData.uptimeChange)"></i>
                                {{ liveData.uptimeChange }}
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card live">
                        <div class="stat-icon warning">
                            <i class="fas fa-clock"></i>
                        </div>
                        <div class="stat-content">
                            <div class="stat-value">{{ liveData.avgResponseTime }}ms</div>
                            <div class="stat-label">{{ $t("Ortalama Yanıt") }}</div>
                            <div class="stat-change" :class="getChangeClass(liveData.responseChange)">
                                <i :class="getChangeIcon(liveData.responseChange)"></i>
                                {{ liveData.responseChange }}
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card live">
                        <div class="stat-icon danger">
                            <i class="fas fa-exclamation-triangle"></i>
                        </div>
                        <div class="stat-content">
                            <div class="stat-value">{{ liveData.activeIncidents }}</div>
                            <div class="stat-label">{{ $t("Aktif Olaylar") }}</div>
                            <div class="stat-change" :class="getChangeClass(liveData.incidentChange)">
                                <i :class="getChangeIcon(liveData.incidentChange)"></i>
                                {{ liveData.incidentChange }}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Live Activity Feed -->
        <div class="live-activity-feed">
            <h5><i class="fas fa-stream"></i> {{ $t("Canlı Aktivite Akışı") }}</h5>
            <div class="activity-container">
                <div v-if="activities.length === 0" class="no-activity">
                    <i class="fas fa-info-circle"></i>
                    <p>{{ $t("Henüz aktivite yok") }}</p>
                </div>
                <div v-else class="activity-list">
                    <div 
                        v-for="activity in activities" 
                        :key="activity.id" 
                        class="activity-item"
                        :class="getActivityClass(activity.type)"
                    >
                        <div class="activity-icon">
                            <i :class="getActivityIcon(activity.type)"></i>
                        </div>
                        <div class="activity-content">
                            <div class="activity-title">{{ activity.title }}</div>
                            <div class="activity-description">{{ activity.description }}</div>
                            <div class="activity-time">{{ formatTime(activity.timestamp) }}</div>
                        </div>
                        <div class="activity-status" :class="getStatusClass(activity.status)">
                            {{ getStatusText(activity.status) }}
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- System Health Indicator -->
        <div class="system-health-indicator mt-4">
            <h5><i class="fas fa-heartbeat"></i> {{ $t("Sistem Sağlığı") }}</h5>
            <div class="health-metrics">
                <div class="row">
                    <div class="col-md-4">
                        <div class="health-card">
                            <div class="health-header">
                                <span class="health-label">{{ $t("Genel Sağlık") }}</span>
                                <span class="health-score" :class="getHealthClass(systemHealth.overall)">
                                    {{ systemHealth.overall }}%
                                </span>
                            </div>
                            <div class="health-bar">
                                <div class="health-progress" :style="{ width: systemHealth.overall + '%' }"></div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="health-card">
                            <div class="health-header">
                                <span class="health-label">{{ $t("Performans") }}</span>
                                <span class="health-score" :class="getHealthClass(systemHealth.performance)">
                                    {{ systemHealth.performance }}%
                                </span>
                            </div>
                            <div class="health-bar">
                                <div class="health-progress" :style="{ width: systemHealth.performance + '%' }"></div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="health-card">
                            <div class="health-header">
                                <span class="health-label">{{ $t("Güvenilirlik") }}</span>
                                <span class="health-score" :class="getHealthClass(systemHealth.reliability)">
                                    {{ systemHealth.reliability }}%
                                </span>
                            </div>
                            <div class="health-bar">
                                <div class="health-progress" :style="{ width: systemHealth.reliability + '%' }"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    name: "RealTimeDataModule",
    data() {
        return {
            isConnected: true,
            liveData: {
                totalMonitors: 0,
                uptimePercentage: 0,
                avgResponseTime: 0,
                activeIncidents: 0,
                monitorChange: "+0",
                uptimeChange: "+0%",
                responseChange: "+0ms",
                incidentChange: "+0"
            },
            activities: [],
            systemHealth: {
                overall: 95,
                performance: 92,
                reliability: 98
            }
        };
    },
    mounted() {
        this.startRealTimeUpdates();
        
        // Socket.io event'lerini dinle
        if (this.$root.$socket) {
            this.$root.$socket.on('heartbeat', () => {
                this.updateLiveData();
                this.updateActivities();
            });
            
            this.$root.$socket.on('monitorList', () => {
                this.updateLiveData();
            });
        }
    },
    beforeUnmount() {
        this.stopRealTimeUpdates();
    },
    methods: {
        startRealTimeUpdates() {
            // Her 5 saniyede bir veri güncelle
            this.updateInterval = setInterval(() => {
                this.updateLiveData();
                this.updateActivities();
                this.updateSystemHealth();
            }, 5000);

            // İlk güncelleme
            this.updateLiveData();
        },
        stopRealTimeUpdates() {
            if (this.updateInterval) {
                clearInterval(this.updateInterval);
            }
        },
        updateLiveData() {
            // Gerçek verilerden güncelle
            const monitors = Object.values(this.$root.monitorList || {});
            const uptimeList = this.$root.uptimeList || {};
            const avgPingList = this.$root.avgPingList || {};
            const heartbeatList = this.$root.heartbeatList || {};

            this.liveData.totalMonitors = monitors.length;
            
            // Uptime hesapla
            let totalUptime = 0;
            let monitorCount = 0;
            monitors.forEach(monitor => {
                const uptimeKey = `${monitor.id}_24`;
                if (uptimeList[uptimeKey] !== undefined) {
                    totalUptime += uptimeList[uptimeKey];
                    monitorCount++;
                }
            });
            this.liveData.uptimePercentage = monitorCount > 0 ? Math.round((totalUptime / monitorCount) * 100) / 100 : 99.9;

            // Ortalama yanıt süresi
            let totalResponse = 0;
            let responseCount = 0;
            monitors.forEach(monitor => {
                if (avgPingList[monitor.id] !== undefined) {
                    totalResponse += avgPingList[monitor.id];
                    responseCount++;
                }
            });
            this.liveData.avgResponseTime = responseCount > 0 ? Math.round(totalResponse / responseCount) : 100;

            // Aktif olaylar (down durumundaki monitörler)
            let downCount = 0;
            monitors.forEach(monitor => {
                if (heartbeatList[monitor.id] && heartbeatList[monitor.id].length > 0) {
                    const lastHeartbeat = heartbeatList[monitor.id][heartbeatList[monitor.id].length - 1];
                    if (lastHeartbeat.status === 0) {
                        downCount++;
                    }
                }
            });
            this.liveData.activeIncidents = downCount;
            
            // Değişim göstergelerini güncelle
            this.updateChangeIndicators();
        },
        
        updateChangeIndicators() {
            // Basit değişim göstergeleri (gerçek uygulamada daha karmaşık olabilir)
            const monitors = Object.values(this.$root.monitorList || {});
            const heartbeatList = this.$root.heartbeatList || {};
            
            // Son 24 saatteki değişiklikleri hesapla
            const now = Date.now();
            const yesterday = now - 24 * 60 * 60 * 1000;
            
            let yesterdayDownCount = 0;
            let todayDownCount = 0;
            
            monitors.forEach(monitor => {
                if (heartbeatList[monitor.id]) {
                    heartbeatList[monitor.id].forEach(heartbeat => {
                        if (heartbeat.status === 0) {
                            const heartbeatTime = new Date(heartbeat.time).getTime();
                            if (heartbeatTime < yesterday) {
                                yesterdayDownCount++;
                            } else {
                                todayDownCount++;
                            }
                        }
                    });
                }
            });
            
            const change = todayDownCount - yesterdayDownCount;
            this.liveData.incidentChange = change > 0 ? `+${change}` : change < 0 ? `${change}` : "0";
        },
        updateActivities() {
            // Gerçek monitör aktivitelerini ekle
            const monitors = Object.values(this.$root.monitorList || {});
            const heartbeatList = this.$root.heartbeatList || {};
            const avgPingList = this.$root.avgPingList || {};
            
            // Son aktiviteleri topla
            const recentActivities = [];
            
            monitors.forEach(monitor => {
                if (heartbeatList[monitor.id] && heartbeatList[monitor.id].length > 0) {
                    const lastHeartbeat = heartbeatList[monitor.id][heartbeatList[monitor.id].length - 1];
                    const ping = avgPingList[monitor.id] || 0;
                    
                    let activity = {
                        id: `${monitor.id}-${lastHeartbeat.time}`,
                        type: "monitor",
                        title: `${monitor.name} kontrol edildi`,
                        description: `Yanıt süresi: ${Math.round(ping)}ms`,
                        timestamp: new Date(lastHeartbeat.time),
                        status: lastHeartbeat.status === 1 ? "success" : lastHeartbeat.status === 0 ? "error" : "warning"
                    };
                    
                    recentActivities.push(activity);
                }
            });
            
            // Son aktiviteleri tarihe göre sırala ve en son 10 tanesini al
            recentActivities.sort((a, b) => b.timestamp - a.timestamp);
            this.activities = recentActivities.slice(0, 10);
        },
        updateSystemHealth() {
            // Sistem sağlığını gerçek verilerle güncelle
            const monitors = Object.values(this.$root.monitorList || {});
            const uptimeList = this.$root.uptimeList || {};
            const avgPingList = this.$root.avgPingList || {};
            const heartbeatList = this.$root.heartbeatList || {};
            
            if (monitors.length === 0) {
                this.systemHealth = { overall: 100, performance: 100, reliability: 100 };
                return;
            }
            
            // Genel sağlık (uptime bazlı)
            let totalUptime = 0;
            let monitorCount = 0;
            monitors.forEach(monitor => {
                const uptimeKey = `${monitor.id}_24`;
                if (uptimeList[uptimeKey] !== undefined) {
                    totalUptime += uptimeList[uptimeKey];
                    monitorCount++;
                }
            });
            this.systemHealth.overall = monitorCount > 0 ? Math.round((totalUptime / monitorCount) * 100) : 100;
            
            // Performans (yanıt süresi bazlı)
            let totalPing = 0;
            let pingCount = 0;
            monitors.forEach(monitor => {
                if (avgPingList[monitor.id] !== undefined) {
                    totalPing += avgPingList[monitor.id];
                    pingCount++;
                }
            });
            const avgPing = pingCount > 0 ? totalPing / pingCount : 100;
            this.systemHealth.performance = Math.max(60, 100 - Math.round(avgPing / 10));
            
            // Güvenilirlik (down event sayısı bazlı)
            let downEvents = 0;
            let totalEvents = 0;
            monitors.forEach(monitor => {
                if (heartbeatList[monitor.id]) {
                    heartbeatList[monitor.id].forEach(heartbeat => {
                        totalEvents++;
                        if (heartbeat.status === 0) {
                            downEvents++;
                        }
                    });
                }
            });
            this.systemHealth.reliability = totalEvents > 0 ? Math.max(60, 100 - Math.round((downEvents / totalEvents) * 100)) : 100;
        },
        refreshData() {
            this.updateLiveData();
            this.updateActivities();
            this.updateSystemHealth();
        },
        getChangeClass(change) {
            if (change.startsWith('+')) return 'positive';
            if (change.startsWith('-')) return 'negative';
            return 'neutral';
        },
        getChangeIcon(change) {
            if (change.startsWith('+')) return 'fas fa-arrow-up';
            if (change.startsWith('-')) return 'fas fa-arrow-down';
            return 'fas fa-minus';
        },
        getActivityClass(type) {
            return {
                'monitor': 'activity-monitor',
                'incident': 'activity-incident',
                'system': 'activity-system'
            }[type] || '';
        },
        getActivityIcon(type) {
            return {
                'monitor': 'fas fa-server',
                'incident': 'fas fa-exclamation-triangle',
                'system': 'fas fa-cog'
            }[type] || 'fas fa-info-circle';
        },
        getStatusClass(status) {
            return {
                'success': 'status-success',
                'warning': 'status-warning',
                'error': 'status-error',
                'info': 'status-info'
            }[status] || '';
        },
        getStatusText(status) {
            return {
                'success': this.$t("Başarılı"),
                'warning': this.$t("Uyarı"),
                'error': this.$t("Hata"),
                'info': this.$t("Bilgi")
            }[status] || status;
        },
        getHealthClass(score) {
            if (score >= 90) return 'health-excellent';
            if (score >= 80) return 'health-good';
            if (score >= 70) return 'health-fair';
            return 'health-poor';
        },
        formatTime(timestamp) {
            const now = new Date();
            const diff = now - timestamp;
            
            if (diff < 60000) return this.$t("Az önce");
            if (diff < 3600000) return this.$t("{0} dakika önce", Math.floor(diff / 60000));
            if (diff < 86400000) return this.$t("{0} saat önce", Math.floor(diff / 3600000));
            return timestamp.toLocaleDateString('tr-TR');
        }
    }
};
</script>

<style scoped>
.real-time-data-module {
    background: #fff;
    border-radius: 8px;
    padding: 20px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    margin-bottom: 20px;
}

.module-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    padding-bottom: 15px;
    border-bottom: 2px solid #f0f0f0;
}

.module-title {
    margin: 0;
    color: #333;
    font-size: 18px;
}

.module-actions {
    display: flex;
    align-items: center;
    gap: 15px;
}

.connection-status {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 14px;
    color: #dc3545;
}

.connection-status.connected {
    color: #28a745;
}

.connection-status i {
    font-size: 8px;
}

.real-time-stats {
    margin-bottom: 30px;
}

.stat-card.live {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border-radius: 12px;
    padding: 20px;
    position: relative;
    overflow: hidden;
}

.stat-card.live::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: linear-gradient(45deg, transparent 30%, rgba(255,255,255,0.1) 50%, transparent 70%);
    animation: shimmer 2s infinite;
}

@keyframes shimmer {
    0% { transform: translateX(-100%); }
    100% { transform: translateX(100%); }
}

.stat-icon {
    font-size: 24px;
    margin-bottom: 10px;
}

.stat-icon.success {
    color: #28a745;
}

.stat-icon.warning {
    color: #ffc107;
}

.stat-icon.danger {
    color: #dc3545;
}

.stat-value {
    font-size: 28px;
    font-weight: bold;
    margin-bottom: 5px;
}

.stat-label {
    font-size: 14px;
    opacity: 0.9;
    margin-bottom: 8px;
}

.stat-change {
    font-size: 12px;
    display: flex;
    align-items: center;
    gap: 4px;
}

.stat-change.positive {
    color: #28a745;
}

.stat-change.negative {
    color: #dc3545;
}

.stat-change.neutral {
    color: #6c757d;
}

.live-activity-feed {
    margin-bottom: 30px;
}

.live-activity-feed h5 {
    margin-bottom: 15px;
    color: #333;
}

.activity-container {
    max-height: 300px;
    overflow-y: auto;
    border: 1px solid #e9ecef;
    border-radius: 8px;
    background: #f8f9fa;
}

.no-activity {
    text-align: center;
    padding: 40px;
    color: #6c757d;
}

.no-activity i {
    font-size: 48px;
    margin-bottom: 15px;
}

.activity-list {
    padding: 15px;
}

.activity-item {
    display: flex;
    align-items: flex-start;
    padding: 12px;
    margin-bottom: 10px;
    background: white;
    border-radius: 8px;
    border-left: 4px solid #e9ecef;
    transition: all 0.3s ease;
}

.activity-item:hover {
    transform: translateX(5px);
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.activity-item.activity-monitor {
    border-left-color: #007bff;
}

.activity-item.activity-incident {
    border-left-color: #dc3545;
}

.activity-item.activity-system {
    border-left-color: #6c757d;
}

.activity-icon {
    margin-right: 12px;
    margin-top: 2px;
    color: #6c757d;
}

.activity-content {
    flex: 1;
}

.activity-title {
    font-weight: 600;
    margin-bottom: 4px;
    color: #333;
}

.activity-description {
    font-size: 14px;
    color: #6c757d;
    margin-bottom: 4px;
}

.activity-time {
    font-size: 12px;
    color: #999;
}

.activity-status {
    padding: 4px 8px;
    border-radius: 12px;
    font-size: 11px;
    font-weight: 600;
    text-transform: uppercase;
}

.status-success {
    background: #d4edda;
    color: #155724;
}

.status-warning {
    background: #fff3cd;
    color: #856404;
}

.status-error {
    background: #f8d7da;
    color: #721c24;
}

.status-info {
    background: #d1ecf1;
    color: #0c5460;
}

.system-health-indicator h5 {
    margin-bottom: 15px;
    color: #333;
}

.health-metrics {
    background: #f8f9fa;
    padding: 20px;
    border-radius: 8px;
}

.health-card {
    background: white;
    padding: 15px;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.health-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 10px;
}

.health-label {
    font-weight: 600;
    color: #333;
}

.health-score {
    font-weight: bold;
    font-size: 18px;
}

.health-score.health-excellent {
    color: #28a745;
}

.health-score.health-good {
    color: #17a2b8;
}

.health-score.health-fair {
    color: #ffc107;
}

.health-score.health-poor {
    color: #dc3545;
}

.health-bar {
    height: 8px;
    background: #e9ecef;
    border-radius: 4px;
    overflow: hidden;
}

.health-progress {
    height: 100%;
    background: linear-gradient(90deg, #28a745, #17a2b8);
    border-radius: 4px;
    transition: width 0.3s ease;
}

@media (max-width: 768px) {
    .module-header {
        flex-direction: column;
        gap: 15px;
        align-items: stretch;
    }
    
    .module-actions {
        justify-content: center;
    }
    
    .real-time-stats .row {
        margin: 0;
    }
    
    .real-time-stats .col-md-3 {
        padding: 0 5px;
        margin-bottom: 15px;
    }
    
    .health-metrics .row {
        margin: 0;
    }
    
    .health-metrics .col-md-4 {
        padding: 0 5px;
        margin-bottom: 15px;
    }
}
</style>
