// src/services/api.js
import axios from "axios";

// const API_BASE_URL = import.meta.env.VITE_API_URL || "https://api.generasisehat.com";
const API_BASE_URL = import.meta.env.VITE_API_URL || "http://localhost:8080";

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
  },
});

// Interceptor untuk menambahkan token JWT
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem("access_token");
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error),
);

// Interceptor untuk menangani error response (seperti token expired)
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem("access_token");
      localStorage.removeItem("user");

      // Pakai SweetAlert2 karena project sudah pakai ini
      import("sweetalert2").then((Swal) => {
        Swal.default
          .fire({
            icon: "warning",
            title: "Sesi Berakhir",
            text: "Silakan login kembali.",
            confirmButtonColor: "#4f46e5",
            allowOutsideClick: false,
          })
          .then(() => {
            window.location.href = "/login";
          });
      });
    }
    return Promise.reject(error);
  },
);

export default api;
