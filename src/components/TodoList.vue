<template>
    <div class="todo-list-container">
        <div class="todo-header">
            <h4><i class="fas fa-tasks"></i> {{ $t("Yapılacaklar Listesi") }}</h4>
            <div class="todo-actions">
                <button class="btn btn-sm btn-primary" @click="addNewTodo">
                    <i class="fas fa-plus"></i> {{ $t("Yeni Görev") }}
                </button>
                <button class="btn btn-sm btn-outline-secondary" @click="exportTodoList">
                    <i class="fas fa-download"></i> {{ $t("Dışa Aktar") }}
                </button>
            </div>
        </div>

        <!-- Yeni görev ekleme formu -->
        <div v-if="showAddForm" class="add-todo-form mb-3">
            <div class="card">
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-6">
                            <label class="form-label">{{ $t("Görev Başlığı") }}</label>
                            <input 
                                v-model="newTodo.title" 
                                type="text" 
                                class="form-control" 
                                :placeholder="$t('Görev başlığını girin')"
                            />
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">{{ $t("Öncelik") }}</label>
                            <select v-model="newTodo.priority" class="form-select">
                                <option value="low">{{ $t("Düşük") }}</option>
                                <option value="medium">{{ $t("Orta") }}</option>
                                <option value="high">{{ $t("Yüksek") }}</option>
                                <option value="urgent">{{ $t("Acil") }}</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">{{ $t("Kategori") }}</label>
                            <select v-model="newTodo.category" class="form-select">
                                <option value="development">{{ $t("Geliştirme") }}</option>
                                <option value="testing">{{ $t("Test") }}</option>
                                <option value="deployment">{{ $t("Dağıtım") }}</option>
                                <option value="maintenance">{{ $t("Bakım") }}</option>
                                <option value="documentation">{{ $t("Dokümantasyon") }}</option>
                                <option value="other">{{ $t("Diğer") }}</option>
                            </select>
                        </div>
                    </div>
                    <div class="row mt-2">
                        <div class="col-md-6">
                            <label class="form-label">{{ $t("Açıklama") }}</label>
                            <textarea 
                                v-model="newTodo.description" 
                                class="form-control" 
                                rows="3"
                                :placeholder="$t('Görev açıklamasını girin')"
                            ></textarea>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">{{ $t("Bitiş Tarihi") }}</label>
                            <input 
                                v-model="newTodo.dueDate" 
                                type="date" 
                                class="form-control"
                            />
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">{{ $t("Atanan Kişi") }}</label>
                            <input 
                                v-model="newTodo.assignedTo" 
                                type="text" 
                                class="form-control"
                                :placeholder="$t('Atanan kişi')"
                            />
                        </div>
                    </div>
                    <div class="mt-3">
                        <button class="btn btn-primary" @click="saveTodo">
                            <i class="fas fa-save"></i> {{ $t("Kaydet") }}
                        </button>
                        <button class="btn btn-outline-secondary ms-2" @click="cancelAdd">
                            {{ $t("İptal") }}
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Filtreler -->
        <div class="todo-filters mb-3">
            <div class="row">
                <div class="col-md-2">
                    <label class="form-label">{{ $t("Durum") }}</label>
                    <select v-model="filterStatus" class="form-select">
                        <option value="all">{{ $t("Tümü") }}</option>
                        <option value="pending">{{ $t("Bekliyor") }}</option>
                        <option value="in-progress">{{ $t("Devam Ediyor") }}</option>
                        <option value="completed">{{ $t("Tamamlandı") }}</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label">{{ $t("Öncelik") }}</label>
                    <select v-model="filterPriority" class="form-select">
                        <option value="all">{{ $t("Tümü") }}</option>
                        <option value="low">{{ $t("Düşük") }}</option>
                        <option value="medium">{{ $t("Orta") }}</option>
                        <option value="high">{{ $t("Yüksek") }}</option>
                        <option value="urgent">{{ $t("Acil") }}</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label">{{ $t("Kategori") }}</label>
                    <select v-model="filterCategory" class="form-select">
                        <option value="all">{{ $t("Tümü") }}</option>
                        <option value="development">{{ $t("Geliştirme") }}</option>
                        <option value="testing">{{ $t("Test") }}</option>
                        <option value="deployment">{{ $t("Dağıtım") }}</option>
                        <option value="maintenance">{{ $t("Bakım") }}</option>
                        <option value="documentation">{{ $t("Dokümantasyon") }}</option>
                        <option value="other">{{ $t("Diğer") }}</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">{{ $t("Arama") }}</label>
                    <input 
                        v-model="searchQuery" 
                        type="text" 
                        class="form-control"
                        :placeholder="$t('Görev ara...')"
                    />
                </div>
                <div class="col-md-3">
                    <label class="form-label">{{ $t("Sıralama") }}</label>
                    <select v-model="sortBy" class="form-select">
                        <option value="created">{{ $t("Oluşturulma Tarihi") }}</option>
                        <option value="dueDate">{{ $t("Bitiş Tarihi") }}</option>
                        <option value="priority">{{ $t("Öncelik") }}</option>
                        <option value="title">{{ $t("Başlık") }}</option>
                    </select>
                </div>
            </div>
        </div>

        <!-- İstatistikler -->
        <div class="todo-stats mb-3">
            <div class="row">
                <div class="col-md-3">
                    <div class="stat-card">
                        <div class="stat-number">{{ totalTodos }}</div>
                        <div class="stat-label">{{ $t("Toplam Görev") }}</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card">
                        <div class="stat-number text-warning">{{ pendingTodos }}</div>
                        <div class="stat-label">{{ $t("Bekleyen") }}</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card">
                        <div class="stat-number text-info">{{ inProgressTodos }}</div>
                        <div class="stat-label">{{ $t("Devam Eden") }}</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card">
                        <div class="stat-number text-success">{{ completedTodos }}</div>
                        <div class="stat-label">{{ $t("Tamamlanan") }}</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Görev listesi -->
        <div class="todo-list">
            <div v-if="filteredTodos.length === 0" class="no-todos">
                <i class="fas fa-clipboard-list"></i>
                <p>{{ $t("Henüz görev eklenmemiş") }}</p>
            </div>
            
            <div v-else class="todo-items">
                <div 
                    v-for="todo in filteredTodos" 
                    :key="todo.id" 
                    class="todo-item"
                    :class="getTodoItemClass(todo)"
                >
                    <div class="todo-checkbox">
                        <input 
                            type="checkbox" 
                            :checked="todo.status === 'completed'"
                            @change="toggleTodoStatus(todo)"
                        />
                    </div>
                    <div class="todo-content">
                        <div class="todo-header">
                            <h5 class="todo-title" :class="{ 'completed': todo.status === 'completed' }">
                                {{ todo.title }}
                            </h5>
                            <div class="todo-meta">
                                <span class="priority-badge" :class="getPriorityClass(todo.priority)">
                                    {{ getPriorityText(todo.priority) }}
                                </span>
                                <span class="category-badge">
                                    {{ getCategoryText(todo.category) }}
                                </span>
                                <span v-if="todo.dueDate" class="due-date" :class="getDueDateClass(todo.dueDate)">
                                    <i class="fas fa-calendar"></i>
                                    {{ formatDate(todo.dueDate) }}
                                </span>
                            </div>
                        </div>
                        <div v-if="todo.description" class="todo-description">
                            {{ todo.description }}
                        </div>
                        <div class="todo-footer">
                            <div class="todo-info">
                                <span v-if="todo.assignedTo" class="assigned-to">
                                    <i class="fas fa-user"></i>
                                    {{ todo.assignedTo }}
                                </span>
                                <span class="created-date">
                                    <i class="fas fa-clock"></i>
                                    {{ formatDate(todo.createdAt) }}
                                </span>
                            </div>
                            <div class="todo-actions">
                                <button class="btn btn-sm btn-outline-primary" @click="editTodo(todo)">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button class="btn btn-sm btn-outline-danger" @click="deleteTodo(todo)">
                                    <i class="fas fa-trash"></i>
                                </button>
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
    name: "TodoList",
    data() {
        return {
            todos: [
                {
                    id: 1,
                    title: "Rapor sistemi geliştirme",
                    description: "Gelişmiş raporlama özelliklerini ekle",
                    priority: "high",
                    category: "development",
                    status: "pending",
                    dueDate: "2024-01-15",
                    assignedTo: "Beyz",
                    createdAt: "2024-01-01"
                },
                {
                    id: 2,
                    title: "Yapılacaklar listesi entegrasyonu",
                    description: "Ana dashboard'a yapılacaklar listesi ekle",
                    priority: "medium",
                    category: "development",
                    status: "in-progress",
                    dueDate: "2024-01-20",
                    assignedTo: "Beyz",
                    createdAt: "2024-01-02"
                },
                {
                    id: 3,
                    title: "Bildirim sistemi iyileştirme",
                    description: "Email ve SMS bildirimlerini geliştir",
                    priority: "low",
                    category: "maintenance",
                    status: "pending",
                    dueDate: "2024-01-25",
                    assignedTo: "Beyz",
                    createdAt: "2024-01-03"
                }
            ],
            showAddForm: false,
            newTodo: {
                title: "",
                description: "",
                priority: "medium",
                category: "development",
                dueDate: "",
                assignedTo: ""
            },
            filterStatus: "all",
            filterPriority: "all",
            filterCategory: "all",
            searchQuery: "",
            sortBy: "created"
        };
    },
    computed: {
        filteredTodos() {
            let filtered = this.todos;

            // Durum filtresi
            if (this.filterStatus !== "all") {
                filtered = filtered.filter(todo => todo.status === this.filterStatus);
            }

            // Öncelik filtresi
            if (this.filterPriority !== "all") {
                filtered = filtered.filter(todo => todo.priority === this.filterPriority);
            }

            // Kategori filtresi
            if (this.filterCategory !== "all") {
                filtered = filtered.filter(todo => todo.category === this.filterCategory);
            }

            // Arama filtresi
            if (this.searchQuery) {
                const query = this.searchQuery.toLowerCase();
                filtered = filtered.filter(todo => 
                    todo.title.toLowerCase().includes(query) ||
                    todo.description.toLowerCase().includes(query) ||
                    (todo.assignedTo && todo.assignedTo.toLowerCase().includes(query))
                );
            }

            // Sıralama
            filtered.sort((a, b) => {
                switch (this.sortBy) {
                    case "created":
                        return new Date(b.createdAt) - new Date(a.createdAt);
                    case "dueDate":
                        if (!a.dueDate) return 1;
                        if (!b.dueDate) return -1;
                        return new Date(a.dueDate) - new Date(b.dueDate);
                    case "priority":
                        const priorityOrder = { urgent: 4, high: 3, medium: 2, low: 1 };
                        return priorityOrder[b.priority] - priorityOrder[a.priority];
                    case "title":
                        return a.title.localeCompare(b.title);
                    default:
                        return 0;
                }
            });

            return filtered;
        },
        totalTodos() {
            return this.todos.length;
        },
        pendingTodos() {
            return this.todos.filter(todo => todo.status === "pending").length;
        },
        inProgressTodos() {
            return this.todos.filter(todo => todo.status === "in-progress").length;
        },
        completedTodos() {
            return this.todos.filter(todo => todo.status === "completed").length;
        }
    },
    methods: {
        addNewTodo() {
            this.showAddForm = true;
            this.newTodo = {
                title: "",
                description: "",
                priority: "medium",
                category: "development",
                dueDate: "",
                assignedTo: ""
            };
        },
        saveTodo() {
            if (!this.newTodo.title.trim()) {
                alert(this.$t("Görev başlığı gereklidir"));
                return;
            }

            const todo = {
                id: Date.now(),
                ...this.newTodo,
                status: "pending",
                createdAt: new Date().toISOString().split('T')[0]
            };

            this.todos.push(todo);
            this.showAddForm = false;
            this.saveToLocalStorage();
        },
        cancelAdd() {
            this.showAddForm = false;
        },
        toggleTodoStatus(todo) {
            if (todo.status === "completed") {
                todo.status = "pending";
            } else if (todo.status === "pending") {
                todo.status = "in-progress";
            } else {
                todo.status = "completed";
            }
            this.saveToLocalStorage();
        },
        editTodo(todo) {
            // Düzenleme modalı açılabilir
            console.log("Edit todo:", todo);
        },
        deleteTodo(todo) {
            if (confirm(this.$t("Bu görevi silmek istediğinizden emin misiniz?"))) {
                const index = this.todos.findIndex(t => t.id === todo.id);
                if (index > -1) {
                    this.todos.splice(index, 1);
                    this.saveToLocalStorage();
                }
            }
        },
        exportTodoList() {
            const data = {
                todos: this.todos,
                exportDate: new Date().toISOString(),
                summary: {
                    total: this.totalTodos,
                    pending: this.pendingTodos,
                    inProgress: this.inProgressTodos,
                    completed: this.completedTodos
                }
            };

            const blob = new Blob([JSON.stringify(data, null, 2)], {
                type: 'application/json'
            });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `todo-list-${new Date().toISOString().split('T')[0]}.json`;
            a.click();
            URL.revokeObjectURL(url);
        },
        getPriorityClass(priority) {
            return {
                'low': 'priority-low',
                'medium': 'priority-medium',
                'high': 'priority-high',
                'urgent': 'priority-urgent'
            }[priority] || '';
        },
        getPriorityText(priority) {
            return {
                'low': this.$t("Düşük"),
                'medium': this.$t("Orta"),
                'high': this.$t("Yüksek"),
                'urgent': this.$t("Acil")
            }[priority] || priority;
        },
        getCategoryText(category) {
            return {
                'development': this.$t("Geliştirme"),
                'testing': this.$t("Test"),
                'deployment': this.$t("Dağıtım"),
                'maintenance': this.$t("Bakım"),
                'documentation': this.$t("Dokümantasyon"),
                'other': this.$t("Diğer")
            }[category] || category;
        },
        getTodoItemClass(todo) {
            return {
                'completed': todo.status === 'completed',
                'overdue': this.isOverdue(todo.dueDate)
            };
        },
        getDueDateClass(dueDate) {
            if (!dueDate) return '';
            const today = new Date();
            const due = new Date(dueDate);
            const diffDays = Math.ceil((due - today) / (1000 * 60 * 60 * 24));
            
            if (diffDays < 0) return 'overdue';
            if (diffDays <= 3) return 'urgent';
            if (diffDays <= 7) return 'warning';
            return 'normal';
        },
        isOverdue(dueDate) {
            if (!dueDate) return false;
            const today = new Date();
            const due = new Date(dueDate);
            return due < today;
        },
        formatDate(dateString) {
            if (!dateString) return '';
            const date = new Date(dateString);
            return date.toLocaleDateString('tr-TR');
        },
        saveToLocalStorage() {
            localStorage.setItem('beyztrack-todos', JSON.stringify(this.todos));
        },
        loadFromLocalStorage() {
            const saved = localStorage.getItem('beyztrack-todos');
            if (saved) {
                this.todos = JSON.parse(saved);
            }
        }
    },
    mounted() {
        this.loadFromLocalStorage();
    }
};
</script>

<style scoped>
.todo-list-container {
    background: #fff;
    border-radius: 8px;
    padding: 20px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.todo-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    padding-bottom: 15px;
    border-bottom: 2px solid #f0f0f0;
}

.todo-header h4 {
    margin: 0;
    color: #333;
}

.todo-actions {
    display: flex;
    gap: 10px;
}

.add-todo-form {
    background: #f8f9fa;
    border-radius: 8px;
    padding: 20px;
}

.todo-filters {
    background: #f8f9fa;
    padding: 15px;
    border-radius: 8px;
}

.todo-stats {
    display: flex;
    gap: 15px;
}

.stat-card {
    background: #fff;
    padding: 15px;
    border-radius: 8px;
    text-align: center;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    border: 1px solid #e9ecef;
}

.stat-number {
    font-size: 24px;
    font-weight: bold;
    color: #007bff;
}

.stat-label {
    font-size: 12px;
    color: #6c757d;
    margin-top: 5px;
}

.todo-list {
    margin-top: 20px;
}

.no-todos {
    text-align: center;
    padding: 40px;
    color: #6c757d;
}

.no-todos i {
    font-size: 48px;
    margin-bottom: 15px;
}

.todo-items {
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.todo-item {
    display: flex;
    align-items: flex-start;
    padding: 15px;
    background: #fff;
    border: 1px solid #e9ecef;
    border-radius: 8px;
    transition: all 0.3s ease;
}

.todo-item:hover {
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    transform: translateY(-2px);
}

.todo-item.completed {
    opacity: 0.7;
    background: #f8f9fa;
}

.todo-item.overdue {
    border-left: 4px solid #dc3545;
}

.todo-checkbox {
    margin-right: 15px;
    margin-top: 3px;
}

.todo-checkbox input[type="checkbox"] {
    width: 18px;
    height: 18px;
    cursor: pointer;
}

.todo-content {
    flex: 1;
}

.todo-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 10px;
}

.todo-title {
    margin: 0;
    font-size: 16px;
    font-weight: 600;
    color: #333;
}

.todo-title.completed {
    text-decoration: line-through;
    color: #6c757d;
}

.todo-meta {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
}

.priority-badge {
    padding: 4px 8px;
    border-radius: 12px;
    font-size: 11px;
    font-weight: 600;
    text-transform: uppercase;
}

.priority-low {
    background: #d4edda;
    color: #155724;
}

.priority-medium {
    background: #fff3cd;
    color: #856404;
}

.priority-high {
    background: #f8d7da;
    color: #721c24;
}

.priority-urgent {
    background: #dc3545;
    color: #fff;
}

.category-badge {
    padding: 4px 8px;
    background: #e9ecef;
    color: #495057;
    border-radius: 12px;
    font-size: 11px;
}

.due-date {
    display: flex;
    align-items: center;
    gap: 4px;
    font-size: 12px;
    padding: 4px 8px;
    border-radius: 12px;
}

.due-date.overdue {
    background: #f8d7da;
    color: #721c24;
}

.due-date.urgent {
    background: #fff3cd;
    color: #856404;
}

.due-date.warning {
    background: #d1ecf1;
    color: #0c5460;
}

.due-date.normal {
    background: #d4edda;
    color: #155724;
}

.todo-description {
    color: #6c757d;
    font-size: 14px;
    margin-bottom: 10px;
    line-height: 1.4;
}

.todo-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 12px;
    color: #6c757d;
}

.todo-info {
    display: flex;
    gap: 15px;
}

.todo-info span {
    display: flex;
    align-items: center;
    gap: 4px;
}

.todo-actions {
    display: flex;
    gap: 5px;
}

.todo-actions .btn {
    padding: 4px 8px;
    font-size: 12px;
}

@media (max-width: 768px) {
    .todo-header {
        flex-direction: column;
        gap: 15px;
        align-items: stretch;
    }
    
    .todo-actions {
        justify-content: center;
    }
    
    .todo-stats {
        flex-wrap: wrap;
    }
    
    .todo-header {
        flex-direction: column;
        gap: 10px;
    }
    
    .todo-meta {
        flex-direction: column;
        gap: 5px;
    }
    
    .todo-footer {
        flex-direction: column;
        gap: 10px;
        align-items: flex-start;
    }
}
</style>
