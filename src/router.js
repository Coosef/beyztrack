import { createRouter, createWebHistory } from "vue-router";

import Layout from "./layouts/Layout.vue";
import DashboardHome from "./pages/DashboardHome.vue";
import NotFound from "./pages/NotFound.vue";
import AdvancedReports from "./pages/AdvancedReports.vue";

const routes = [
    {
        path: "/",
        redirect: "/dashboard",
    },
    {
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
        path: "/reports",
        component: Layout,
        children: [
            {
                path: "",
                component: AdvancedReports,
            },
        ],
    },
    {
        path: "/manage-status-page",
        component: Layout,
        children: [
            {
                path: "",
                component: NotFound, // Geçici olarak NotFound
            },
        ],
    },
    {
        path: "/todo",
        component: Layout,
        children: [
            {
                path: "",
                component: NotFound, // Geçici olarak NotFound
            },
        ],
    },
    {
        path: "/settings",
        component: Layout,
        children: [
            {
                path: "",
                component: NotFound, // Geçici olarak NotFound
            },
        ],
    },
    {
        path: "/backup",
        component: Layout,
        children: [
            {
                path: "",
                component: NotFound, // Geçici olarak NotFound
            },
        ],
    },
    {
        path: "/:pathMatch(.*)*",
        component: NotFound,
    },
];

// Default export olarak dışa aktar
export default createRouter({
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