<template>
    <div class="backup-restore">
        <div class="page-header">
            <h1 class="mb-3">{{ $t("Backup & Restore") }}</h1>
            <div class="header-actions">
                <button class="btn btn-warning me-2" @click="testBackup">
                    <i class="fas fa-bug"></i> Test Backup System
                </button>
                <button class="btn btn-primary" @click="createBackup">
                    <i class="fas fa-download"></i> {{ $t("Create Backup") }}
                </button>
                <button class="btn btn-outline-secondary" @click="refreshBackups">
                    <i class="fas fa-sync-alt"></i> {{ $t("Refresh") }}
                </button>
            </div>
        </div>

        <!-- Backup Creation -->
        <div class="backup-section shadow-box mb-4">
            <div class="section-header">
                <h4><i class="fas fa-save"></i> {{ $t("Create New Backup") }}</h4>
            </div>
            <div class="section-content">
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label class="form-label">{{ $t("Backup Name") }}</label>
                            <input 
                                v-model="backupName" 
                                type="text" 
                                class="form-control"
                                :placeholder="$t('Enter backup name')"
                            />
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label class="form-label">{{ $t("Backup Type") }}</label>
                            <select v-model="backupType" class="form-select">
                                <option value="full">{{ $t("Full Backup") }}</option>
                                <option value="monitors">{{ $t("Monitors Only") }}</option>
                                <option value="settings">{{ $t("Settings Only") }}</option>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="row mt-3">
                    <div class="col-12">
                        <div class="form-check">
                            <input 
                                v-model="includeHistory" 
                                type="checkbox" 
                                class="form-check-input" 
                                id="includeHistory"
                            />
                            <label class="form-check-label" for="includeHistory">
                                {{ $t("Include Monitoring History") }}
                            </label>
                        </div>
                        <div class="form-check">
                            <input 
                                v-model="includeNotifications" 
                                type="checkbox" 
                                class="form-check-input" 
                                id="includeNotifications"
                            />
                            <label class="form-check-label" for="includeNotifications">
                                {{ $t("Include Notification Settings") }}
                            </label>
                        </div>
                    </div>
                </div>
                <div class="mt-3">
                    <button 
                        class="btn btn-primary" 
                        @click="createBackup"
                        :disabled="creatingBackup"
                    >
                        <i v-if="creatingBackup" class="fas fa-spinner fa-spin"></i>
                        <i v-else class="fas fa-download"></i>
                        {{ creatingBackup ? $t("Creating...") : $t("Create Backup") }}
                    </button>
                </div>
            </div>
        </div>

        <!-- Backup List -->
        <div class="backup-section shadow-box mb-4">
            <div class="section-header">
                <h4><i class="fas fa-list"></i> {{ $t("Available Backups") }}</h4>
            </div>
            <div class="section-content">
                <div v-if="loading" class="text-center py-4">
                    <i class="fas fa-spinner fa-spin fa-2x"></i>
                    <p class="mt-2">{{ $t("Loading backups...") }}</p>
                </div>
                
                <div v-else-if="backups.length === 0" class="text-center py-4">
                    <i class="fas fa-folder-open fa-2x text-muted"></i>
                    <p class="mt-2 text-muted">{{ $t("No backups found") }}</p>
                </div>
                
                <div v-else class="backup-list">
                    <div v-for="backup in backups" :key="backup.id" class="backup-item">
                        <div class="backup-info">
                            <div class="backup-header">
                                <h5 class="backup-name">{{ backup.name }}</h5>
                                <span class="backup-type badge" :class="getBackupTypeClass(backup.type)">
                                    {{ getBackupTypeLabel(backup.type) }}
                                </span>
                            </div>
                            <div class="backup-details">
                                <div class="detail-item">
                                    <i class="fas fa-calendar"></i>
                                    <span>{{ formatDate(backup.createdAt) }}</span>
                                </div>
                                <div class="detail-item">
                                    <i class="fas fa-hdd"></i>
                                    <span>{{ formatSize(backup.size) }}</span>
                                </div>
                                <div class="detail-item">
                                    <i class="fas fa-server"></i>
                                    <span>{{ backup.monitorCount }} {{ $t("monitors") }}</span>
                                </div>
                            </div>
                            <div class="backup-description">
                                {{ backup.description }}
                            </div>
                        </div>
                        <div class="backup-actions">
                            <button 
                                class="btn btn-sm btn-outline-primary" 
                                @click="downloadBackup(backup)"
                                :disabled="downloading === backup.id"
                            >
                                <i v-if="downloading === backup.id" class="fas fa-spinner fa-spin"></i>
                                <i v-else class="fas fa-download"></i>
                                {{ $t("Download") }}
                            </button>
                            <button 
                                class="btn btn-sm btn-outline-success" 
                                @click="restoreBackup(backup)"
                                :disabled="restoring === backup.id"
                            >
                                <i v-if="restoring === backup.id" class="fas fa-spinner fa-spin"></i>
                                <i v-else class="fas fa-undo"></i>
                                {{ $t("Restore") }}
                            </button>
                            <button 
                                class="btn btn-sm btn-outline-danger" 
                                @click="deleteBackup(backup)"
                                :disabled="deleting === backup.id"
                            >
                                <i v-if="deleting === backup.id" class="fas fa-spinner fa-spin"></i>
                                <i v-else class="fas fa-trash"></i>
                                {{ $t("Delete") }}
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Restore Modal -->
        <div class="modal fade" id="restoreModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">{{ $t("Confirm Restore") }}</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="alert alert-warning">
                            <i class="fas fa-exclamation-triangle"></i>
                            <strong>{{ $t("Warning") }}:</strong> {{ $t("This will overwrite all current data. This action cannot be undone.") }}
                        </div>
                        <p>{{ $t("Are you sure you want to restore from backup") }} <strong>{{ selectedBackup?.name }}</strong>?</p>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                            {{ $t("Cancel") }}
                        </button>
                        <button type="button" class="btn btn-danger" @click="confirmRestore">
                            <i class="fas fa-undo"></i> {{ $t("Restore") }}
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Upload Backup -->
        <div class="backup-section shadow-box mb-4">
            <div class="section-header">
                <h4><i class="fas fa-upload"></i> {{ $t("Upload Backup") }}</h4>
            </div>
            <div class="section-content">
                <div class="upload-area" @click="triggerFileUpload" @drop="handleFileDrop" @dragover.prevent>
                    <input 
                        ref="fileInput" 
                        type="file" 
                        accept=".json,.zip" 
                        @change="handleFileSelect"
                        style="display: none;"
                    />
                    <div class="upload-content">
                        <i class="fas fa-cloud-upload-alt fa-3x text-muted"></i>
                        <p class="mt-2">{{ $t("Click to select backup file or drag and drop") }}</p>
                        <p class="text-muted">{{ $t("Supported formats: JSON, ZIP") }}</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import { Modal } from 'bootstrap';

export default {
    name: "BackupRestore",
    data() {
        return {
            backupName: "",
            backupType: "full",
            includeHistory: true,
            includeNotifications: true,
            creatingBackup: false,
            loading: false,
            downloading: null,
            restoring: null,
            deleting: null,
            backups: [],
            selectedBackup: null,
            restoreModal: null,
        };
    },
    methods: {
        createBackup() {
            console.log("createBackup called");
            console.log("Socket connected:", this.$root.socket.connected);
            
            if (!this.backupName.trim()) {
                this.$root.toastError("Please enter a backup name");
                return;
            }

            this.creatingBackup = true;
            
            const backupData = {
                name: this.backupName,
                type: this.backupType,
                includeHistory: this.includeHistory,
                includeNotifications: this.includeNotifications,
            };

            console.log("Sending backup data:", backupData);

            // Use the correct socket access method
            const socket = this.$root.getSocket();
            
            if (socket && typeof socket.emit === 'function') {
                socket.emit("createBackup", backupData, (result) => {
                    console.log("createBackup callback received:", result);
                    if (result.ok) {
                        this.$root.toastSuccess("Backup created successfully");
                        this.backupName = "";
                        this.loadBackups();
                    } else {
                        this.$root.toastError(result.msg || "Failed to create backup");
                    }
                    this.creatingBackup = false;
                });
            } else {
                console.error("Socket emit function not found for createBackup");
                this.$root.toastError("Socket connection error");
                this.creatingBackup = false;
            }
        },

        loadBackups() {
            console.log("=== LOAD BACKUPS CALLED ===");
            console.log("Socket connected:", this.$root.socket.connected);
            
            // Use the correct socket access method
            const socket = this.$root.getSocket();
            this.loading = true;
            
            console.log("Emitting getBackups...");
            
            if (socket && typeof socket.emit === 'function') {
                console.log("Using socket.emit for loadBackups");
                socket.emit("getBackups", (result) => {
                    console.log("=== GET BACKUPS CALLBACK RECEIVED ===");
                    console.log("Result:", result);
                    if (result.ok) {
                        this.backups = result.backups || [];
                        console.log("Backups loaded:", this.backups.length);
                    } else {
                        console.error("Failed to load backups:", result.msg);
                        this.$root.toastError(result.msg || "Failed to load backups");
                    }
                    this.loading = false;
                });
            } else {
                console.error("Socket emit function not found for loadBackups");
                this.$root.toastError("Socket connection error");
                this.loading = false;
            }
            
            console.log("getBackups emit completed");
        },

        downloadBackup(backup) {
            this.downloading = backup.id;
            
            this.$root.getSocket().emit("downloadBackup", backup.id, (result) => {
                if (result.ok) {
                    // Create download link
                    const blob = new Blob([JSON.stringify(result.data)], { type: 'application/json' });
                    const url = window.URL.createObjectURL(blob);
                    const a = document.createElement('a');
                    a.href = url;
                    a.download = `${backup.name}.json`;
                    document.body.appendChild(a);
                    a.click();
                    document.body.removeChild(a);
                    window.URL.revokeObjectURL(url);
                    
                    this.$root.toastSuccess("Backup downloaded successfully");
                } else {
                    this.$root.toastError(result.msg || "Failed to download backup");
                }
                this.downloading = null;
            });
        },

        restoreBackup(backup) {
            this.selectedBackup = backup;
            if (!this.restoreModal) {
                this.restoreModal = new Modal(document.getElementById('restoreModal'));
            }
            this.restoreModal.show();
        },

        confirmRestore() {
            if (!this.selectedBackup) return;

            this.restoring = this.selectedBackup.id;
            this.restoreModal.hide();

            this.$root.getSocket().emit("restoreBackup", this.selectedBackup.id, (result) => {
                if (result.ok) {
                    this.$root.toastSuccess("Backup restored successfully. Please refresh the page.");
                    setTimeout(() => {
                        window.location.reload();
                    }, 2000);
                } else {
                    this.$root.toastError(result.msg || "Failed to restore backup");
                }
                this.restoring = null;
                this.selectedBackup = null;
            });
        },

        deleteBackup(backup) {
            if (!confirm(`Are you sure you want to delete backup "${backup.name}"?`)) {
                return;
            }

            this.deleting = backup.id;
            
            this.$root.getSocket().emit("deleteBackup", backup.id, (result) => {
                if (result.ok) {
                    this.$root.toastSuccess("Backup deleted successfully");
                    this.loadBackups();
                } else {
                    this.$root.toastError(result.msg || "Failed to delete backup");
                }
                this.deleting = null;
            });
        },

        refreshBackups() {
            this.loadBackups();
        },

        triggerFileUpload() {
            this.$refs.fileInput.click();
        },

        handleFileSelect(event) {
            const file = event.target.files[0];
            if (file) {
                this.uploadBackup(file);
            }
        },

        handleFileDrop(event) {
            event.preventDefault();
            const files = event.dataTransfer.files;
            if (files.length > 0) {
                this.uploadBackup(files[0]);
            }
        },

        uploadBackup(file) {
            const reader = new FileReader();
            reader.onload = (e) => {
                try {
                    const backupData = JSON.parse(e.target.result);
                    this.$root.getSocket().emit("uploadBackup", backupData, (result) => {
                        if (result.ok) {
                            this.$root.toastSuccess("Backup uploaded successfully");
                            this.loadBackups();
                        } else {
                            this.$root.toastError(result.msg || "Failed to upload backup");
                        }
                    });
                } catch (error) {
                    this.$root.toastError("Invalid backup file format");
                }
            };
            reader.readAsText(file);
        },

        getBackupTypeClass(type) {
            return {
                'badge-primary': type === 'full',
                'badge-info': type === 'monitors',
                'badge-warning': type === 'settings',
            };
        },

        getBackupTypeLabel(type) {
            return {
                'full': this.$t("Full Backup"),
                'monitors': this.$t("Monitors Only"),
                'settings': this.$t("Settings Only"),
            }[type] || type;
        },

        formatDate(date) {
            return new Intl.DateTimeFormat("tr-TR", {
                year: "numeric",
                month: "short",
                day: "numeric",
                hour: "2-digit",
                minute: "2-digit",
            }).format(new Date(date));
        },

        formatSize(bytes) {
            if (bytes === 0) return "0 B";
            const k = 1024;
            const sizes = ["B", "KB", "MB", "GB"];
            const i = Math.floor(Math.log(bytes) / Math.log(k));
            return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i];
        },

        testBackup() {
            console.log("Testing backup system...");
            console.log("Socket connected:", this.$root.socket.connected);
            
            // Use the correct socket access method
            const socket = this.$root.getSocket();
            console.log("=== SOCKET INSPECTION ===");
            console.log("Socket object:", socket);
            console.log("Socket emit function:", typeof socket?.emit);
            
            if (socket && typeof socket.emit === 'function') {
                console.log("Using socket.emit");
                socket.emit("testBackup", (result) => {
                    if (result.ok) {
                        this.$root.toastSuccess("Backup system is working!");
                        console.log("Backup system test successful.");
                    } else {
                        this.$root.toastError("Backup system is not responding.");
                        console.error("Backup system test failed:", result.msg);
                    }
                });
            } else {
                console.error("Socket emit function not found");
                this.$root.toastError("Socket connection error");
            }
        }
    },
    mounted() {
        console.log("=== BACKUP RESTORE PAGE MOUNTED ===");
        console.log("Socket connected:", this.$root.socket.connected);
        
        // Use the correct socket access method
        const socket = this.$root.getSocket();
        console.log("=== SOCKET INSPECTION ===");
        console.log("Socket object:", socket);
        console.log("Socket emit function:", typeof socket?.emit);
        
        this.loadBackups();
    },
};
</script>

<style lang="scss" scoped>
.backup-restore {
    .page-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 2rem;
        
        .header-actions {
            display: flex;
            gap: 0.5rem;
        }
    }
    
    .backup-section {
        border-radius: 8px;
        background: var(--bs-body-bg);
        border: 1px solid var(--bs-border-color);
        
        .section-header {
            padding: 1rem 1.5rem;
            border-bottom: 1px solid var(--bs-border-color);
            
            h4 {
                margin: 0;
                font-size: 1.1rem;
                font-weight: 600;
                color: var(--bs-body-color);
                
                i {
                    margin-right: 0.5rem;
                    color: var(--bs-secondary-color);
                }
            }
        }
        
        .section-content {
            padding: 1.5rem;
        }
    }
    
    .backup-list {
        .backup-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1rem;
            border: 1px solid var(--bs-border-color);
            border-radius: 6px;
            margin-bottom: 1rem;
            background: var(--bs-secondary-bg);
            
            .backup-info {
                flex: 1;
                
                .backup-header {
                    display: flex;
                    align-items: center;
                    margin-bottom: 0.5rem;
                    
                    .backup-name {
                        margin: 0;
                        margin-right: 0.5rem;
                        color: var(--bs-body-color);
                    }
                }
                
                .backup-details {
                    display: flex;
                    gap: 1rem;
                    margin-bottom: 0.5rem;
                    
                    .detail-item {
                        display: flex;
                        align-items: center;
                        gap: 0.25rem;
                        font-size: 0.85rem;
                        color: var(--bs-secondary-color);
                        
                        i {
                            width: 14px;
                        }
                    }
                }
                
                .backup-description {
                    font-size: 0.9rem;
                    color: var(--bs-secondary-color);
                }
            }
            
            .backup-actions {
                display: flex;
                gap: 0.5rem;
            }
        }
    }
    
    .upload-area {
        border: 2px dashed var(--bs-border-color);
        border-radius: 8px;
        padding: 3rem;
        text-align: center;
        cursor: pointer;
        transition: all 0.3s ease;
        
        &:hover {
            border-color: var(--bs-primary);
            background: var(--bs-secondary-bg);
        }
        
        .upload-content {
            color: var(--bs-secondary-color);
        }
    }
}
</style>
