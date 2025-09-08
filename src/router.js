import { createRouter, createWebHistory } from "vue-router";

import Layout from "./layouts/Layout.vue";
import DashboardHome from "./pages/DashboardHome.vue";
import NotFound from "./pages/NotFound.vue";

const routes = [
    {
        path: "/",
        redirect: "/dashboard",
    },
    {
        // Frontend-only mode: Simplified dashboard route
        path: "/dashboard",
        component: Layout,
        children: [
            {
                path: "",
                component: DashboardHome,
            },
        ],
    },
    {
        path: "/:pathMatch(.*)*",
        component: NotFound,
    },
];

export const router = createRouter({
    linkActiveClass: "active",
    history: createWebHistory(),
    routes,
    scrollBehavior(to, from, savedPosition) {
        if (savedPosition) {
            return savedPosition;
        } else {
            return { top: 0 };
        }
    },
});