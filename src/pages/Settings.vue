<template>
    <div class="settings-page">
        <div class="page-header">
            <h1 class="mb-3">{{ $t("Settings") }}</h1>
        </div>
        
        <div class="settings-content">
            <div class="alert alert-info">
                <i class="fas fa-info-circle"></i>
                <strong>{{ $t("Settings") }}</strong> - {{ $t("Sistem ayarları burada yapılabilir") }}
            </div>
            
            <div class="settings-grid">
                <div class="setting-card">
                    <h3>{{ $t("General") }}</h3>
                    <p>{{ $t("Genel ayarlar") }}</p>
                    <router-link to="/settings/general" class="btn btn-primary">
                        {{ $t("Configure") }}
                    </router-link>
                </div>
                
                <div class="setting-card">
                    <h3>{{ $t("Backup") }}</h3>
                    <p>{{ $t("Yedekleme ayarları") }}</p>
                    <router-link to="/backup" class="btn btn-primary">
                        {{ $t("Configure") }}
                    </router-link>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    name: "Settings",
    data() {
        return {};
    }
};
</script>

<style lang="scss" scoped>
.settings-page {
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

.settings-content {
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

.settings-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 1.5rem;
}

.setting-card {
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
</style>