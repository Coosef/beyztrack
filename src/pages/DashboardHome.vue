<template>
    <div class="shadow-box">
        <div class="row">
            <div class="col-md-6 col-xl-3">
                <div class="card">
                    <div class="card-body">
                        <div class="d-flex align-items-center">
                            <div class="flex-shrink-0">
                                <div class="avatar avatar-sm">
                                    <div class="avatar-title bg-primary rounded">
                                        <font-awesome-icon icon="server" />
                                    </div>
                                </div>
                            </div>
                            <div class="flex-grow-1 ms-3">
                                <h5 class="card-title mb-0">{{ $t("Total Monitors") }}</h5>
                                <span class="num">{{ $root.stats ? $root.stats.total : 0 }}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-md-6 col-xl-3">
                <div class="card">
                    <div class="card-body">
                        <div class="d-flex align-items-center">
                            <div class="flex-shrink-0">
                                <div class="avatar avatar-sm">
                                    <div class="avatar-title bg-success rounded">
                                        <font-awesome-icon icon="check-circle" />
                                    </div>
                                </div>
                            </div>
                            <div class="flex-grow-1 ms-3">
                                <h5 class="card-title mb-0">{{ $t("Up") }}</h5>
                                <span class="num">{{ $root.stats ? $root.stats.up : 0 }}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-md-6 col-xl-3">
                <div class="card">
                    <div class="card-body">
                        <div class="d-flex align-items-center">
                            <div class="flex-shrink-0">
                                <div class="avatar avatar-sm">
                                    <div class="avatar-title bg-danger rounded">
                                        <font-awesome-icon icon="times-circle" />
                                    </div>
                                </div>
                            </div>
                            <div class="flex-grow-1 ms-3">
                                <h5 class="card-title mb-0">{{ $t("Down") }}</h5>
                                <span class="num">{{ $root.stats ? $root.stats.down : 0 }}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-md-6 col-xl-3">
                <div class="card">
                    <div class="card-body">
                        <div class="d-flex align-items-center">
                            <div class="flex-shrink-0">
                                <div class="avatar avatar-sm">
                                    <div class="avatar-title bg-warning rounded">
                                        <font-awesome-icon icon="pause-circle" />
                                    </div>
                                </div>
                            </div>
                            <div class="flex-grow-1 ms-3">
                                <h5 class="card-title mb-0">{{ $t("Maintenance") }}</h5>
                                <span class="num">{{ $root.stats ? $root.stats.maintenance : 0 }}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>



        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-header">
                        <h5 class="card-title mb-0">{{ $t("Recent Events") }}</h5>
                    </div>
                    <div class="card-body">
                        <div v-if="recentEvents.length === 0" class="text-center text-muted">
                            {{ $t("No recent events") }}
                        </div>
                        <div v-else class="table-responsive">
                            <table class="table table-hover">
                                <thead>
                                    <tr>
                                        <th>{{ $t("Monitor") }}</th>
                                        <th>{{ $t("Event") }}</th>
                                        <th>{{ $t("Time") }}</th>
                                        <th>{{ $t("Duration") }}</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr v-for="event in recentEvents" :key="event.id">
                                        <td>
                                            <router-link :to="`/dashboard/${event.monitorId}`">
                                                {{ event.monitorName }}
                                            </router-link>
                                        </td>
                                        <td>
                                            <Status :status="event.status" />
                                        </td>
                                        <td>{{ formatDateTime(event.time) }}</td>
                                        <td>{{ formatDuration(event.duration) }}</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import Status from "../components/Status.vue";

export default {
    name: "DashboardHome",
    components: {
        Status,
    },
    data() {
        return {
            recentEvents: [],
        };
    },
    computed: {
        stats() {
            // Frontend-only mode: Mock data
            return {
                total: 0,
                up: 0,
                down: 0,
                maintenance: 0,
                pending: 0,
            };
        },
    },
    methods: {
        formatDateTime(timestamp) {
            return new Date(timestamp).toLocaleString();
        },
        formatDuration(seconds) {
            if (seconds < 60) {
                return `${seconds}s`;
            } else if (seconds < 3600) {
                return `${Math.floor(seconds / 60)}m`;
            } else {
                return `${Math.floor(seconds / 3600)}h ${Math.floor((seconds % 3600) / 60)}m`;
            }
        },
        loadRecentEvents() {
            // Gerçek verilerden recent events yükle
            const monitors = Object.values(this.$root.monitorList || {});
            const heartbeatList = this.$root.heartbeatList || {};
            
            const recentEvents = [];
            
            monitors.forEach(monitor => {
                if (heartbeatList[monitor.id] && heartbeatList[monitor.id].length > 0) {
                    const lastHeartbeat = heartbeatList[monitor.id][heartbeatList[monitor.id].length - 1];
                    
                    recentEvents.push({
                        id: `${monitor.id}-${lastHeartbeat.time}`,
                        monitorId: monitor.id,
                        monitorName: monitor.name,
                        status: lastHeartbeat.status,
                        time: lastHeartbeat.time,
                        duration: this.calculateDuration(monitor.id, heartbeatList)
                    });
                }
            });
            
            // Tarihe göre sırala ve en son 10 tanesini al
            recentEvents.sort((a, b) => b.time - a.time);
            this.recentEvents = recentEvents.slice(0, 10);
        },
        
        calculateDuration(monitorId, heartbeatList) {
            // Son down event'ten bu yana geçen süreyi hesapla
            const heartbeats = heartbeatList[monitorId] || [];
            if (heartbeats.length === 0) return 0;
            
            const lastHeartbeat = heartbeats[heartbeats.length - 1];
            const now = Date.now();
            
            if (lastHeartbeat.status === 1) {
                // Up durumunda, son down event'i bul
                for (let i = heartbeats.length - 1; i >= 0; i--) {
                    if (heartbeats[i].status === 0) {
                        return Math.floor((now - heartbeats[i].time) / 1000);
                    }
                }
                return Math.floor((now - lastHeartbeat.time) / 1000);
            } else {
                // Down durumunda, son up event'i bul
                for (let i = heartbeats.length - 1; i >= 0; i--) {
                    if (heartbeats[i].status === 1) {
                        return Math.floor((now - heartbeats[i].time) / 1000);
                    }
                }
                return Math.floor((now - lastHeartbeat.time) / 1000);
            }
        },
    },
    mounted() {
        this.loadRecentEvents();
        
        // Refresh data every 30 seconds
        setInterval(() => {
            this.loadRecentEvents();
        }, 30000);
    },
};
</script>

<style lang="scss" scoped>
@import "../assets/vars";

.num {
    font-size: 30px;
    color: $primary;
    font-weight: bold;
    display: block;
}

// Dashboard specific styles
.shadow-box {
    padding: 20px;
    border-radius: 0.75rem;
    background-color: white;
    box-shadow: 0 15px 70px rgba(0, 0, 0, 0.1);

    .dark & {
        background-color: $dark-bg;
        box-shadow: 0 15px 70px rgba(0, 0, 0, 0.3);
    }
}

// Card improvements
.card {
    .card-body {
        padding: 1.5rem;
    }

    .avatar-title {
        width: 48px;
        height: 48px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.25rem;
    }
}

.shadow-box {
    padding: 20px;
}

table {
    font-size: 14px;

    tr {
        transition: all ease-in-out 0.2ms;
    }

    @media (max-width: 550px) {
        table-layout: fixed;
        overflow-wrap: break-word;
    }
}

@media screen and (max-width: 1280px) {
    .name-column {
        min-width: 150px;
    }
}

@media screen and (min-aspect-ratio: 4/3) {
    .name-column {
        min-width: 200px;
    }
}
</style>

