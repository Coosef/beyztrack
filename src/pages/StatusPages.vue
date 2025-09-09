<template>
    <div class="status-pages">
        <div class="page-header">
            <h1 class="mb-3">{{ $t("Status Pages") }}</h1>
            <div class="header-actions">
                <button class="btn btn-primary" @click="addStatusPage">
                    <i class="fas fa-plus"></i> {{ $t("Add New Status Page") }}
                </button>
            </div>
        </div>
        
        <div class="status-pages-content">
            <div class="alert alert-info">
                <i class="fas fa-info-circle"></i>
                <strong>{{ $t("Status Pages") }}</strong> - {{ $t("Durum sayfaları burada yönetilir") }}
            </div>
            
            <div class="status-pages-list">
                <div v-if="statusPages.length === 0" class="empty-state">
                    <i class="fas fa-stream fa-3x text-muted mb-3"></i>
                    <h4>{{ $t("No status pages yet") }}</h4>
                    <p>{{ $t("Create your first status page") }}</p>
                </div>
                
                <div v-else class="status-page-items">
                    <div v-for="page in statusPages" :key="page.id" class="status-page-item">
                        <div class="status-page-info">
                            <h5>{{ page.name }}</h5>
                            <p>{{ page.url }}</p>
                        </div>
                        <div class="status-page-actions">
                            <button class="btn btn-sm btn-outline-primary" @click="editStatusPage(page.id)">
                                <i class="fas fa-edit"></i>
                            </button>
                            <button class="btn btn-sm btn-outline-danger" @click="deleteStatusPage(page.id)">
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
    name: "StatusPages",
    data() {
        return {
            statusPages: []
        };
    },
    methods: {
        addStatusPage() {
            this.$root.toastInfo("Status page oluşturma özelliği yakında eklenecek");
        },
        editStatusPage(id) {
            this.$root.toastInfo("Status page düzenleme özelliği yakında eklenecek");
        },
        deleteStatusPage(id) {
            this.$root.toastInfo("Status page silme özelliği yakında eklenecek");
        }
    }
};
</script>

<style lang="scss" scoped>
.status-pages {
    padding: 1rem;
}

.page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;
    padding-bottom: 1rem;
    border-bottom: 1px solid var(--bs-border-color);

    h1 {
        margin: 0;
        color: var(--bs-body-color);
        font-weight: 600;
    }

    .header-actions {
        display: flex;
        gap: 0.5rem;
    }
}

.status-pages-content {
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

.empty-state {
    text-align: center;
    padding: 3rem;
    color: var(--bs-secondary);

    h4 {
        margin-bottom: 1rem;
    }
}

.status-page-items {
    display: flex;
    flex-direction: column;
    gap: 1rem;
}

.status-page-item {
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

    .status-page-info {
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

    .status-page-actions {
        display: flex;
        gap: 0.5rem;
    }
}

@media (max-width: 768px) {
    .page-header {
        flex-direction: column;
        gap: 1rem;
        align-items: stretch;

        .header-actions {
            justify-content: center;
        }
    }
}
</style>
