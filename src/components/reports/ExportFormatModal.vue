<template>
    <div v-if="show" class="modal-overlay" @click="closeModal">
        <div class="modal-container" @click.stop>
            <div class="modal-header">
                <h3 class="modal-title">
                    <i class="fas fa-download"></i>
                    {{ $t("Veri Dışa Aktarma") }}
                </h3>
                <button class="close-btn" @click="closeModal">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            
            <div class="modal-body">
                <p class="modal-description">
                    {{ $t("Monitor verilerinizi hangi formatta dışa aktarmak istiyorsunuz?") }}
                </p>
                
                <div class="format-options">
                    <div 
                        v-for="option in exportOptions" 
                        :key="option.format"
                        class="format-option"
                        :class="{ 'selected': selectedFormat === option.format }"
                        @click="selectFormat(option.format)"
                    >
                        <div class="format-icon">
                            <i :class="option.icon"></i>
                        </div>
                        <div class="format-info">
                            <h4 class="format-name">{{ option.name }}</h4>
                            <p class="format-description">{{ option.description }}</p>
                        </div>
                        <div class="format-badge" v-if="option.recommended">
                            <i class="fas fa-star"></i>
                            {{ $t("Önerilen") }}
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="modal-footer">
                <button class="btn btn-secondary" @click="closeModal">
                    <i class="fas fa-times"></i>
                    {{ $t("İptal") }}
                </button>
                <button 
                    class="btn btn-success" 
                    @click="exportData"
                    :disabled="!selectedFormat"
                >
                    <i class="fas fa-download"></i>
                    {{ $t("Dışa Aktar") }}
                </button>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    name: "ExportFormatModal",
    props: {
        show: {
            type: Boolean,
            default: false
        }
    },
    data() {
        return {
            selectedFormat: null,
            exportOptions: [
                {
                    format: 'csv',
                    name: 'CSV (.csv)',
                    description: 'Virgülle ayrılmış değerler',
                    icon: 'fas fa-file-csv',
                    recommended: true
                },
                {
                    format: 'json',
                    name: 'JSON (.json)',
                    description: 'Yapılandırılmış JSON veri',
                    icon: 'fas fa-file-code',
                    recommended: false
                },
                {
                    format: 'xml',
                    name: 'XML (.xml)',
                    description: 'XML formatında veri',
                    icon: 'fas fa-file-code',
                    recommended: false
                }
            ]
        };
    },
    methods: {
        selectFormat(format) {
            this.selectedFormat = format;
        },
        exportData() {
            if (this.selectedFormat) {
                this.$emit('export', this.selectedFormat);
                this.closeModal();
            }
        },
        closeModal() {
            this.selectedFormat = null;
            this.$emit('close');
        }
    }
};
</script>

<style lang="scss" scoped>
.modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 9999;
    backdrop-filter: blur(5px);
}

.modal-container {
    background: var(--bs-body-bg);
    border-radius: 1rem;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
    max-width: 600px;
    width: 90%;
    max-height: 90vh;
    overflow: hidden;
    animation: modalSlideIn 0.3s ease-out;
}

@keyframes modalSlideIn {
    from {
        opacity: 0;
        transform: translateY(-50px) scale(0.9);
    }
    to {
        opacity: 1;
        transform: translateY(0) scale(1);
    }
}

.modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1.5rem;
    border-bottom: 1px solid var(--bs-border-color);
    background: linear-gradient(135deg, #28a745, #1e7e34);
    color: white;
    
    .modal-title {
        margin: 0;
        font-size: 1.25rem;
        font-weight: 600;
        
        i {
            margin-right: 0.5rem;
        }
    }
    
    .close-btn {
        background: none;
        border: none;
        color: white;
        font-size: 1.25rem;
        cursor: pointer;
        padding: 0.5rem;
        border-radius: 0.5rem;
        transition: background-color 0.2s;
        
        &:hover {
            background: rgba(255, 255, 255, 0.1);
        }
    }
}

.modal-body {
    padding: 2rem;
    
    .modal-description {
        color: var(--bs-secondary-color);
        margin-bottom: 1.5rem;
        text-align: center;
    }
}

.format-options {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 1rem;
}

.format-option {
    border: 2px solid var(--bs-border-color);
    border-radius: 0.75rem;
    padding: 1.5rem;
    cursor: pointer;
    transition: all 0.3s ease;
    position: relative;
    background: var(--bs-body-bg);
    
    &:hover {
        border-color: #28a745;
        transform: translateY(-2px);
        box-shadow: 0 8px 25px rgba(40, 167, 69, 0.15);
    }
    
    &.selected {
        border-color: #28a745;
        background: linear-gradient(135deg, rgba(40, 167, 69, 0.1), rgba(40, 167, 69, 0.05));
        box-shadow: 0 8px 25px rgba(40, 167, 69, 0.2);
    }
    
    .format-icon {
        font-size: 2rem;
        color: #28a745;
        margin-bottom: 1rem;
        text-align: center;
    }
    
    .format-info {
        text-align: center;
        
        .format-name {
            font-size: 1.1rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
            color: var(--bs-body-color);
        }
        
        .format-description {
            color: var(--bs-secondary-color);
            font-size: 0.9rem;
            margin: 0;
        }
    }
    
    .format-badge {
        position: absolute;
        top: 0.75rem;
        right: 0.75rem;
        background: linear-gradient(135deg, #ffc107, #ff8c00);
        color: white;
        padding: 0.25rem 0.5rem;
        border-radius: 0.5rem;
        font-size: 0.75rem;
        font-weight: 600;
        
        i {
            margin-right: 0.25rem;
        }
    }
}

.modal-footer {
    display: flex;
    justify-content: flex-end;
    gap: 1rem;
    padding: 1.5rem;
    border-top: 1px solid var(--bs-border-color);
    background: var(--bs-light);
    
    .btn {
        padding: 0.75rem 1.5rem;
        border-radius: 0.5rem;
        font-weight: 600;
        transition: all 0.2s;
        
        i {
            margin-right: 0.5rem;
        }
        
        &.btn-secondary {
            background: var(--bs-secondary);
            border: 1px solid var(--bs-secondary);
            color: white;
            
            &:hover {
                background: var(--bs-secondary-dark);
                border-color: var(--bs-secondary-dark);
            }
        }
        
        &.btn-success {
            background: linear-gradient(135deg, #28a745, #1e7e34);
            border: 1px solid #28a745;
            color: white;
            
            &:hover:not(:disabled) {
                background: linear-gradient(135deg, #1e7e34, #155724);
                border-color: #1e7e34;
                transform: translateY(-1px);
                box-shadow: 0 4px 15px rgba(40, 167, 69, 0.3);
            }
            
            &:disabled {
                opacity: 0.6;
                cursor: not-allowed;
            }
        }
    }
}

@media (max-width: 768px) {
    .modal-container {
        width: 95%;
        margin: 1rem;
    }
    
    .format-options {
        grid-template-columns: 1fr;
    }
    
    .modal-footer {
        flex-direction: column;
        
        .btn {
            width: 100%;
        }
    }
}
</style>
