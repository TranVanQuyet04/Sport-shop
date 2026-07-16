import { useAuthStore } from "@/store/useAuthStore";
import axios from "axios";

const normalizeBaseUrl = (configured: string | undefined, fallback: string) =>
  (configured?.trim() || fallback).replace(/\/+$/, "").replace(/\/api$/, "");

const gatewayBaseUrl = import.meta.env.VITE_API_URL?.trim()
  ? normalizeBaseUrl(import.meta.env.VITE_API_URL, "")
  : null;

const serviceBaseUrls = {
  auth: normalizeBaseUrl(import.meta.env.VITE_AUTH_API_URL, "http://localhost:8081"),
  catalog: normalizeBaseUrl(import.meta.env.VITE_CATALOG_API_URL, "http://localhost:8082"),
  order: normalizeBaseUrl(import.meta.env.VITE_ORDER_API_URL, "http://localhost:8083"),
  chat: normalizeBaseUrl(import.meta.env.VITE_CHAT_API_URL, "http://localhost:8084"),
};

const startsWithAny = (path: string, prefixes: string[]) =>
  prefixes.some((prefix) => path === prefix || path.startsWith(`${prefix}/`));

export const resolveApiBaseUrl = (rawPath = "") => {
  if (gatewayBaseUrl) return gatewayBaseUrl;

  const path = rawPath.split("?", 1)[0];
  if (startsWithAny(path, ["/api/chat"])) return serviceBaseUrls.chat;
  if (
    startsWithAny(path, [
      "/api/products",
      "/api/brands",
      "/api/collections",
      "/api/navigation",
      "/api/admin/products",
      "/api/admin/categories",
      "/api/admin/sports",
      "/api/admin/collections",
    ])
  ) {
    return serviceBaseUrls.catalog;
  }
  if (
    startsWithAny(path, [
      "/api/auth",
      "/api/user/profile",
      "/api/user/addresses",
      "/api/admin/users",
      "/api/admin/roles",
      "/api/admin/settings",
    ])
  ) {
    return serviceBaseUrls.auth;
  }
  return serviceBaseUrls.order;
};

const api = axios.create({
  baseURL: gatewayBaseUrl || serviceBaseUrls.order,
  withCredentials: true,
});

api.interceptors.request.use((config) => {
  config.baseURL = resolveApiBaseUrl(config.url);
  const { accessToken } = useAuthStore.getState();
  if (accessToken) {
    config.headers.Authorization = `Bearer ${accessToken}`;
  }
  return config;
});

api.interceptors.response.use(
  (res) => res,
  async (error) => {
    const originalRequest = error.config;

    // Tránh loop cho các request auth
    if (originalRequest.url?.includes("/auth/") && !originalRequest.url?.includes("/profile/me")) {
      return Promise.reject(error);
    }

    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;
      const { refreshToken, refreshAuth } = useAuthStore.getState();

      if (!refreshToken) return Promise.reject(error);

      try {
        // Gọi hàm refreshAuth đã khai báo trong store
        await refreshAuth();
        
        const newAccessToken = useAuthStore.getState().accessToken;
        originalRequest.headers["Authorization"] = `Bearer ${newAccessToken}`;
        return api(originalRequest);
      } catch (refreshError) {
        useAuthStore.getState().clearState();
        if (window.location.pathname !== "/login") window.location.href = "/login";
        return Promise.reject(refreshError);
      }
    }
    return Promise.reject(error);
  }
);

export default api;
