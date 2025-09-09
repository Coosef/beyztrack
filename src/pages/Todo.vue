<template>
    <div class="todo-page">
        <div class="page-header">
            <h1 class="mb-3">{{ $t("Yapılacaklar Listesi") }}</h1>
            <div class="header-actions">
                <button class="btn btn-primary" @click="addTodo">
                    <i class="fas fa-plus"></i> {{ $t("Add New") }}
                </button>
            </div>
        </div>
        
        <div class="todo-content">
            <div class="alert alert-info">
                <i class="fas fa-info-circle"></i>
                <strong>{{ $t("Todo List") }}</strong> - {{ $t("Yapılacaklar listesi burada görüntülenir") }}
            </div>
            
            <div class="todo-list">
                <div v-if="todos.length === 0" class="empty-state">
                    <i class="fas fa-clipboard-list fa-3x text-muted mb-3"></i>
                    <h4>{{ $t("No todos yet") }}</h4>
                    <p>{{ $t("Add your first todo item") }}</p>
                </div>
                
                <div v-else class="todo-items">
                    <div v-for="todo in todos" :key="todo.id" class="todo-item">
                        <div class="todo-content">
                            <h5>{{ todo.title }}</h5>
                            <p>{{ todo.description }}</p>
                        </div>
                        <div class="todo-actions">
                            <button class="btn btn-sm btn-outline-danger" @click="deleteTodo(todo.id)">
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
    name: "Todo",
    data() {
        return {
            todos: []
        };
    },
    methods: {
        addTodo() {
            const title = prompt("Todo başlığı:");
            if (title) {
                this.todos.push({
                    id: Date.now(),
                    title: title,
                    description: "Açıklama eklenmedi",
                    completed: false
                });
            }
        },
        deleteTodo(id) {
            this.todos = this.todos.filter(todo => todo.id !== id);
        }
    }
};
</script>

<style lang="scss" scoped>
.todo-page {
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

.todo-content {
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

.todo-items {
    display: flex;
    flex-direction: column;
    gap: 1rem;
}

.todo-item {
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

    .todo-content {
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

    .todo-actions {
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
