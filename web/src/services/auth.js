import api from "./api";

const ADMIN_ROLE = "admin";
const SUPERADMIN_ROLE = "superadmin";
const BIDAN_ROLE = "bidan";
const DOKTER_ROLE = "dokter";

const normalizeRole = (role) => (role || "").toString().trim().toLowerCase();

export const isSuperadminUser = (user) =>
  normalizeRole(user?.role) === SUPERADMIN_ROLE;
export const isAdminUser = (user) =>
  [ADMIN_ROLE, SUPERADMIN_ROLE].includes(normalizeRole(user?.role));
export const isDokterUser = (user) => normalizeRole(user?.role) === DOKTER_ROLE;
export const isBidanUser = (user) => normalizeRole(user?.role) === BIDAN_ROLE;

export const getUserRedirectRoute = (user) => {
  const role = normalizeRole(user?.role);
  if (role === SUPERADMIN_ROLE) return "/superadmin/dashboard";
  if (role === ADMIN_ROLE) return "/dashboard/admin";
  if (role === DOKTER_ROLE) return "/dashboard/dokter";
  if (role === BIDAN_ROLE) return "/dashboard/bidan";
  return "/login";
};

export const login = async (identifier, password) => {
  const response = await api.post("/auth/login", { identifier, password });
  const result = response.data.data;
  if (result?.access_token) {
    localStorage.setItem("access_token", result.access_token);
    localStorage.setItem("user", JSON.stringify(result));
  }
  return response.data;
};

export const logout = () => {
  localStorage.removeItem("access_token");
  localStorage.removeItem("user");
  window.location.href = "/login";
};

export const getCurrentUser = () => {
  try {
    const userStr = localStorage.getItem("user");
    return userStr ? JSON.parse(userStr) : null;
  } catch (error) {
    console.error("Error parsing user data:", error);
    return null;
  }
};

export const isAuthenticated = () => {
  const token = localStorage.getItem("access_token");
  const userStr = localStorage.getItem("user");

  if (!token || !userStr) return false;

  try {
    // Decode JWT payload (tanpa library)
    const payload = JSON.parse(atob(token.split(".")[1]));
    const now = Math.floor(Date.now() / 1000);

    // Cek apakah token sudah expired
    if (payload.exp && payload.exp < now) {
      // Auto clear jika expired
      localStorage.removeItem("access_token");
      localStorage.removeItem("user");
      return false;
    }

    return true;
  } catch {
    return false;
  }
};

export const getPostLoginRoute = (user) => {
  if (!user) {
    user = getCurrentUser();
  }
  return getUserRedirectRoute(user);
};

export const registerUser = async (userData) => {
  const response = await api.post("/auth/register", userData);
  return response.data; // Mengembalikan data user yang terdaftar
};

export const createIbuUser = async (data) => {
  // Endpoint untuk membuat akun Ibu
  // Sesuaikan dengan role user yang login
  const response = await api.post("tenaga-kesehatan/users", {
    penduduk_id: data.penduduk_id,
    name: data.name,
    email: data.email,
    phone_number: data.phone_number,
    password: data.password,
  });
  return response.data;
};
