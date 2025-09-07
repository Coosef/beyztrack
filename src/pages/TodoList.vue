<template>
    <div class="todo-page">
        <div class="page-header">
            <h1 class="mb-3">{{ $t("Yapılacaklar Listesi") }}</h1>
            <p class="text-muted">{{ $t("Proje görevlerinizi yönetin ve takip edin") }}</p>
        </div>

        <TodoList />
    </div>
</template>

<script>
import TodoList from "../components/TodoList.vue";

export default {
    name: "TodoListPage",
    components: {
        TodoList,
    },
};
</script>

<style scoped>
.todo-page {
    padding: 20px;
}

.page-header {
    margin-bottom: 30px;
    text-align: center;
}

.page-header h1 {
    color: #333;
    font-weight: 600;
}

.page-header p {
    font-size: 16px;
    color: #6c757d;
}
</style>
