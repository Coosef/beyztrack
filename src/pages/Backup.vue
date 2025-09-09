<template>
    <div class="backup-page">
        <div class="page-header">
            <h1 class="mb-3">{{ $t("Backup") }}</h1>
        </div>
        
        <div class="backup-content">
            <div class="alert alert-info">
                <i class="fas fa-info-circle"></i>
                <strong>{{ $t("Backup & Restore") }}</strong> - {{ $t("Sistem yedekleme ve geri yükleme işlemleri") }}
            </div>
            
            <div class="backup-actions">
                <div class="action-card">
                    <h3>{{ $t("Create Backup") }}</h3>
                    <p>{{ $t("Create a new backup of your system") }}</p>
                    <button class="btn btn-primary" @click="createBackup">
                        <i class="fas fa-save"></i> {{ $t("Create Backup") }}
                    </button>
                </div>
                
                <div class="action-card">
                    <h3>{{ $t("Restore Backup") }}</h3>
                    <p>{{ $t("Restore from an existing backup") }}</p>
                    <button class="btn btn-outline-primary" @click="restoreBackup">
                        <i class="fas fa-upload"></i> {{ $t("Restore Backup") }}
                    </button>
                </div>
            </div>
            
            <div class="backup-list">
                <h3>{{ $t("Available Backups") }}</h3>
                <div v-if="backups.length === 0" class="empty-state">
                    <i class="fas fa-archive fa-3x text-muted mb-3"></i>
                    <h4>{{ $t("No backups found") }}</h4>
                    <p>{{ $t("Create your first backup") }}</p>
                </div>
                
                <div v-else class="backup-items">
                    <div v-for="backup in backups" :key="backup.id" class="backup-item">
                        <div class="backup-info">
                            <h5>{{ backup.name }}</h5>
                            <p>{{ backup.date }}</p>
                        </div>
                        <div class="backup-actions">
                            <button class="btn btn-sm btn-outline-primary" @click="downloadBackup(backup.id)">
                                <i class="fas fa-download"></i>
                            </button>
                            <button class="btn btn-sm btn-outline-danger" @click="deleteBackup(backup.id)">
                                <i class="fas fa-trash"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    name: "Backup",
    data() {
        return {
            backups: []
        };
    },
    methods: {
        createBackup() {
            this.$root.toastSuccess("Backup oluşturuluyor...");
            // Backup oluşturma işlemi
        },
        restoreBackup() {
            this.$root.toastInfo("Backup geri yükleme özelliği yakında eklenecek");
        },
        downloadBackup(id) {
            this.$root.toastInfo("Backup indirme özelliği yakında eklenecek");
        },
        deleteBackup(id) {
            this.$root.toastInfo("Backup silme özelliği yakında eklenecek");
        }
    }
};
</script>

<style lang="scss" scoped>
.backup-page {
    padding: 1rem;
}

.page-header {
    margin-bottom: 2rem;
    padding-bottom: 1rem;
    border-bottom: 1px solid var(--bs-border-color);

    h1 {
        margin: 0;
        color: var(--bs-body-color);
        font-weight: 600;
    }
}

.backup-content {
    .alert {
        border-radius: 0.75rem;
        border: none;
        background: rgba(13, 202, 240, 0.1);
        color: var(--bs-body-color);
        margin-bottom: 2rem;

        i {
            margin-right: 0.5rem;
        }
    }
}

.backup-actions {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 1.5rem;
    margin-bottom: 3rem;
}

.action-card {
    background: var(--bs-body-bg);
    border: 1px solid var(--bs-border-color);
    border-radius: 0.75rem;
    padding: 1.5rem;
    text-align: center;
    transition: all 0.2s ease;

    &:hover {
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        transform: translateY(-2px);
    }

    h3 {
        color: var(--bs-primary);
        margin-bottom: 0.5rem;
    }

    p {
        color: var(--bs-secondary);
        margin-bottom: 1rem;
    }
}

.backup-list {
    h3 {
        margin-bottom: 1.5rem;
        color: var(--bs-body-color);
    }
}

.empty-state {
    text-align: center;
    padding: 3rem;
    color: var(--bs-secondary);

    h4 {
        margin-bottom: 1rem;
    }
}

.backup-items {
    display: flex;
    flex-direction: column;
    gap: 1rem;
}

.backup-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: var(--bs-body-bg);
    border: 1px solid var(--bs-border-color);
    border-radius: 0.75rem;
    padding: 1.5rem;
    transition: all 0.2s ease;

    &:hover {
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
    }

    .backup-info {
        flex: 1;

        h5 {
            margin: 0 0 0.5rem 0;
            color: var(--bs-body-color);
        }

        p {
            margin: 0;
            color: var(--bs-secondary);
        }
    }

    .backup-actions {
        display: flex;
        gap: 0.5rem;
    }
}
</style>
