const fs = require("fs");
const path = require("path");
const { R } = require("redbean-node");

class BackupManager {
    constructor() {
        this.backupDir = path.join(process.cwd(), "data", "backups");
        this.ensureBackupDir();
    }

    ensureBackupDir() {
        if (!fs.existsSync(this.backupDir)) {
            fs.mkdirSync(this.backupDir, { recursive: true });
        }
    }

    async createBackup(data) {
        try {
            console.log("Creating backup with data:", data);
            
            const backupId = Date.now().toString();
            const backupName = data.name || `backup_${backupId}`;
            const backupData = {
                id: backupId,
                name: backupName,
                type: data.type || "full",
                createdAt: new Date().toISOString(),
                description: data.description || "",
                data: {}
            };

            console.log("Backup ID:", backupId);
            console.log("Backup Name:", backupName);

            // Get monitors
            if (data.type === "full" || data.type === "monitors") {
                console.log("Fetching monitors...");
                const monitors = await R.getAll("SELECT * FROM monitor");
                backupData.data.monitors = monitors;
                backupData.monitorCount = monitors.length;
                console.log("Found", monitors.length, "monitors");
            }

            // Get settings
            if (data.type === "full" || data.type === "settings") {
                console.log("Fetching settings...");
                const settings = await R.getAll("SELECT * FROM setting");
                backupData.data.settings = settings;
                console.log("Found", settings.length, "settings");
            }

            // Get notification settings
            if (data.includeNotifications) {
                console.log("Fetching notifications...");
                const notifications = await R.getAll("SELECT * FROM notification");
                backupData.data.notifications = notifications;
                console.log("Found", notifications.length, "notifications");
            }

            // Get monitoring history
            if (data.includeHistory) {
                console.log("Fetching heartbeats...");
                const heartbeats = await R.getAll("SELECT * FROM heartbeat");
                backupData.data.heartbeats = heartbeats;
                console.log("Found", heartbeats.length, "heartbeats");
                
                // Get uptime statistics
                console.log("Fetching uptime statistics...");
                const statDaily = await R.getAll("SELECT * FROM stat_daily");
                const statHourly = await R.getAll("SELECT * FROM stat_hourly");
                const statMinutely = await R.getAll("SELECT * FROM stat_minutely");
                backupData.data.statistics = {
                    daily: statDaily,
                    hourly: statHourly,
                    minutely: statMinutely
                };
                console.log("Found", statDaily.length, "daily,", statHourly.length, "hourly,", statMinutely.length, "minutely records");
            }

            // Calculate backup size
            const backupString = JSON.stringify(backupData);
            backupData.size = Buffer.byteLength(backupString, 'utf8');
            console.log("Backup size:", backupData.size, "bytes");

            // Save backup file
            const backupPath = path.join(this.backupDir, `${backupId}.json`);
            console.log("Saving backup to:", backupPath);
            fs.writeFileSync(backupPath, backupString);
            console.log("Backup saved successfully");

            return {
                ok: true,
                backup: backupData
            };
        } catch (error) {
            console.error("Error creating backup:", error);
            console.error("Error stack:", error.stack);
            return {
                ok: false,
                msg: "Failed to create backup: " + error.message
            };
        }
    }

    async getBackups() {
        try {
            const files = fs.readdirSync(this.backupDir);
            const backups = [];

            for (const file of files) {
                if (file.endsWith('.json')) {
                    const backupPath = path.join(this.backupDir, file);
                    const backupContent = fs.readFileSync(backupPath, 'utf8');
                    const backup = JSON.parse(backupContent);
                    backups.push(backup);
                }
            }

            // Sort by creation date (newest first)
            backups.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

            return {
                ok: true,
                backups: backups
            };
        } catch (error) {
            console.error("Error getting backups:", error);
            return {
                ok: false,
                msg: "Failed to get backups: " + error.message
            };
        }
    }

    async downloadBackup(backupId) {
        try {
            const backupPath = path.join(this.backupDir, `${backupId}.json`);
            
            if (!fs.existsSync(backupPath)) {
                return {
                    ok: false,
                    msg: "Backup not found"
                };
            }

            const backupContent = fs.readFileSync(backupPath, 'utf8');
            const backup = JSON.parse(backupContent);

            return {
                ok: true,
                data: backup
            };
        } catch (error) {
            console.error("Error downloading backup:", error);
            return {
                ok: false,
                msg: "Failed to download backup: " + error.message
            };
        }
    }

    async restoreBackup(backupId) {
        try {
            const backupPath = path.join(this.backupDir, `${backupId}.json`);
            
            if (!fs.existsSync(backupPath)) {
                return {
                    ok: false,
                    msg: "Backup not found"
                };
            }

            const backupContent = fs.readFileSync(backupPath, 'utf8');
            const backup = JSON.parse(backupContent);

            // Clear existing data
            await R.exec("DELETE FROM monitor");
            await R.exec("DELETE FROM setting");
            await R.exec("DELETE FROM notification");
            await R.exec("DELETE FROM heartbeat");
            await R.exec("DELETE FROM stat_daily");
            await R.exec("DELETE FROM stat_hourly");
            await R.exec("DELETE FROM stat_minutely");

            // Restore data
            if (backup.data.monitors) {
                for (const monitor of backup.data.monitors) {
                    const columns = Object.keys(monitor).join(', ');
                    const placeholders = Object.keys(monitor).map(() => '?').join(', ');
                    const values = Object.values(monitor);
                    await R.exec(`INSERT INTO monitor (${columns}) VALUES (${placeholders})`, values);
                }
            }

            if (backup.data.settings) {
                for (const setting of backup.data.settings) {
                    const columns = Object.keys(setting).join(', ');
                    const placeholders = Object.keys(setting).map(() => '?').join(', ');
                    const values = Object.values(setting);
                    await R.exec(`INSERT INTO setting (${columns}) VALUES (${placeholders})`, values);
                }
            }

            if (backup.data.notifications) {
                for (const notification of backup.data.notifications) {
                    const columns = Object.keys(notification).join(', ');
                    const placeholders = Object.keys(notification).map(() => '?').join(', ');
                    const values = Object.values(notification);
                    await R.exec(`INSERT INTO notification (${columns}) VALUES (${placeholders})`, values);
                }
            }

            if (backup.data.heartbeats) {
                for (const heartbeat of backup.data.heartbeats) {
                    const columns = Object.keys(heartbeat).join(', ');
                    const placeholders = Object.keys(heartbeat).map(() => '?').join(', ');
                    const values = Object.values(heartbeat);
                    await R.exec(`INSERT INTO heartbeat (${columns}) VALUES (${placeholders})`, values);
                }
            }

            // Restore statistics
            if (backup.data.statistics) {
                if (backup.data.statistics.daily) {
                    for (const stat of backup.data.statistics.daily) {
                        const columns = Object.keys(stat).join(', ');
                        const placeholders = Object.keys(stat).map(() => '?').join(', ');
                        const values = Object.values(stat);
                        await R.exec(`INSERT INTO stat_daily (${columns}) VALUES (${placeholders})`, values);
                    }
                }
                if (backup.data.statistics.hourly) {
                    for (const stat of backup.data.statistics.hourly) {
                        const columns = Object.keys(stat).join(', ');
                        const placeholders = Object.keys(stat).map(() => '?').join(', ');
                        const values = Object.values(stat);
                        await R.exec(`INSERT INTO stat_hourly (${columns}) VALUES (${placeholders})`, values);
                    }
                }
                if (backup.data.statistics.minutely) {
                    for (const stat of backup.data.statistics.minutely) {
                        const columns = Object.keys(stat).join(', ');
                        const placeholders = Object.keys(stat).map(() => '?').join(', ');
                        const values = Object.values(stat);
                        await R.exec(`INSERT INTO stat_minutely (${columns}) VALUES (${placeholders})`, values);
                    }
                }
            }

            // Handle legacy uptime data if exists
            if (backup.data.uptime) {
                console.log("Legacy uptime data found, skipping...");
            }

            return {
                ok: true,
                msg: "Backup restored successfully"
            };
        } catch (error) {
            console.error("Error restoring backup:", error);
            return {
                ok: false,
                msg: "Failed to restore backup: " + error.message
            };
        }
    }

    async deleteBackup(backupId) {
        try {
            const backupPath = path.join(this.backupDir, `${backupId}.json`);
            
            if (!fs.existsSync(backupPath)) {
                return {
                    ok: false,
                    msg: "Backup not found"
                };
            }

            fs.unlinkSync(backupPath);

            return {
                ok: true,
                msg: "Backup deleted successfully"
            };
        } catch (error) {
            console.error("Error deleting backup:", error);
            return {
                ok: false,
                msg: "Failed to delete backup: " + error.message
            };
        }
    }

    async uploadBackup(backupData) {
        try {
            const backupId = Date.now().toString();
            const backupPath = path.join(this.backupDir, `${backupId}.json`);
            
            // Validate backup data
            if (!backupData.data || !backupData.name) {
                return {
                    ok: false,
                    msg: "Invalid backup format"
                };
            }

            // Add metadata
            backupData.id = backupId;
            backupData.uploadedAt = new Date().toISOString();
            backupData.size = Buffer.byteLength(JSON.stringify(backupData), 'utf8');

            // Save backup file
            fs.writeFileSync(backupPath, JSON.stringify(backupData));

            return {
                ok: true,
                backup: backupData
            };
        } catch (error) {
            console.error("Error uploading backup:", error);
            return {
                ok: false,
                msg: "Failed to upload backup: " + error.message
            };
        }
    }

    async testConnection() {
        try {
            console.log("=== BACKUP MANAGER TEST ===");
            console.log("Backup directory:", this.backupDir);
            console.log("Backup directory exists:", fs.existsSync(this.backupDir));
            
            // Test database connection
            console.log("Testing database connection...");
            const testMonitors = await R.getAll("SELECT COUNT(*) as count FROM monitor");
            console.log("Monitor count:", testMonitors);
            
            return {
                ok: true,
                msg: "BackupManager is working correctly",
                backupDir: this.backupDir,
                monitorCount: testMonitors[0]?.count || 0
            };
        } catch (error) {
            console.error("BackupManager test failed:", error);
            return {
                ok: false,
                msg: "BackupManager test failed: " + error.message
            };
        }
    }
}

module.exports = BackupManager;
