const BackupManager = require("../backup");

let backupManager;

const backupSocketHandler = (socket) => {
    console.log("Backup socket handler initialized for socket:", socket.id);
    
    if (!backupManager) {
        console.log("Creating new BackupManager instance");
        backupManager = new BackupManager();
    }
    
    socket.on("createBackup", async (data, callback) => {
        console.log("=== BACKUP CREATE REQUEST ===");
        console.log("Socket ID:", socket.id);
        console.log("Received data:", data);
        console.log("Callback function:", typeof callback);
        
        try {
            console.log("Calling backupManager.createBackup...");
            const result = await backupManager.createBackup(data);
            console.log("BackupManager result:", result);
            console.log("Calling callback with result...");
            callback(result);
            console.log("Callback completed");
        } catch (error) {
            console.error("Socket: Error creating backup:", error);
            console.error("Socket: Error stack:", error.stack);
            callback({
                ok: false,
                msg: "Failed to create backup: " + error.message
            });
        }
    });

    socket.on("getBackups", async (callback) => {
        console.log("=== GET BACKUPS REQUEST ===");
        console.log("Socket ID:", socket.id);
        console.log("Callback function:", typeof callback);
        
        try {
            console.log("Calling backupManager.getBackups...");
            const result = await backupManager.getBackups();
            console.log("BackupManager getBackups result:", result);
            console.log("Calling callback with result...");
            callback(result);
            console.log("GetBackups callback completed");
        } catch (error) {
            console.error("Socket: Error getting backups:", error);
            console.error("Socket: Error stack:", error.stack);
            callback({
                ok: false,
                msg: "Failed to get backups: " + error.message
            });
        }
    });

    socket.on("downloadBackup", async (backupId, callback) => {
        try {
            const result = await backupManager.downloadBackup(backupId);
            callback(result);
        } catch (error) {
            console.error("Error downloading backup:", error);
            callback({
                ok: false,
                msg: "Failed to download backup"
            });
        }
    });

    socket.on("restoreBackup", async (backupId, callback) => {
        try {
            const result = await backupManager.restoreBackup(backupId);
            callback(result);
        } catch (error) {
            console.error("Error restoring backup:", error);
            callback({
                ok: false,
                msg: "Failed to restore backup"
            });
        }
    });

    socket.on("deleteBackup", async (backupId, callback) => {
        try {
            const result = await backupManager.deleteBackup(backupId);
            callback(result);
        } catch (error) {
            console.error("Error deleting backup:", error);
            callback({
                ok: false,
                msg: "Failed to delete backup"
            });
        }
    });

    socket.on("uploadBackup", async (backupData, callback) => {
        try {
            const result = await backupManager.uploadBackup(backupData);
            callback(result);
        } catch (error) {
            console.error("Error uploading backup:", error);
            callback({
                ok: false,
                msg: "Failed to upload backup"
            });
        }
    });

    socket.on("testBackup", async (callback) => {
        console.log("=== TEST BACKUP REQUEST ===");
        console.log("Socket ID:", socket.id);
        
        try {
            console.log("Calling backupManager.testConnection...");
            const result = await backupManager.testConnection();
            console.log("Test result:", result);
            callback(result);
        } catch (error) {
            console.error("Test failed:", error);
            callback({
                ok: false,
                msg: "Test failed: " + error.message
            });
        }
    });
};

module.exports = { backupSocketHandler };
