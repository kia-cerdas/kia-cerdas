import api from "./api";

const normalizeMessage = (message) => {
  if (Array.isArray(message)) {
    return message.join(", ");
  }
  return message || "";
};

const extractApiError = (error, fallbackMessage = "Terjadi kesalahan") => {
  const message = error?.response?.data?.message;
  const normalized = normalizeMessage(message);
  return normalized || fallbackMessage;
};

const unwrapData = (response) => response.data?.data ?? response.data;

export const listSuperadminUsers = async (params = {}) => {
  const response = await api.get("/superadmin/users", { params });
  return unwrapData(response);
};

export const createBidanUser = async (payload) => {
  const response = await api.post("/superadmin/users/bidan", payload);
  return unwrapData(response);
};

export const createAdminDesaUser = async (payload) => {
  const response = await api.post("/superadmin/users/admin-desa", payload);
  return unwrapData(response);
};

export const createKaderUser = async (payload) => {
  const response = await api.post("/superadmin/users/kader", payload);
  return unwrapData(response);
};

export const createSuperadminUser = async (payload) => {
  const response = await api.post("/superadmin/users", payload);
  return unwrapData(response);
};

export const resetSuperadminUserPassword = async (userId, payload) => {
  const response = await api.patch(`/superadmin/users/${userId}/reset-password`, payload);
  return unwrapData(response);
};

export const updateSuperadminUserRole = async (userId, payload) => {
  const response = await api.patch(`/superadmin/users/${userId}/role`, payload);
  return unwrapData(response);
};

export const deactivateSuperadminUser = async (userId) => {
  const response = await api.patch(`/superadmin/users/${userId}/nonaktif`);
  return unwrapData(response);
};

export const activateSuperadminUser = async (userId) => {
  const response = await api.patch(`/superadmin/users/${userId}/aktif`);
  return unwrapData(response);
};

export const listSuperadminPosyandu = async (params = {}) => {
  const response = await api.get("/superadmin/posyandu", { params });
  return unwrapData(response);
};

export const superadminUserErrorMessage = extractApiError;
