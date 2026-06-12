import api from "./api";

const normalizeMessage = (message) => {
  if (Array.isArray(message)) {
    return message.join(", ");
  }
  return message || "";
};

export const desaErrorMessage = (error, fallbackMessage = "Terjadi kesalahan") => {
  const message = error?.response?.data?.message;
  const normalized = normalizeMessage(message);
  return normalized || fallbackMessage;
};

export const listDesa = async () => {
  const response = await api.get("/superadmin/desa");
  return response.data.data || [];
};

export const getDesaDetail = async (id) => {
  const response = await api.get(`/superadmin/desa/${id}`);
  return response.data.data;
};

export const createDesa = async (payload) => {
  const response = await api.post("/superadmin/desa", payload);
  return response.data;
};

export const updateDesa = async (id, payload) => {
  const response = await api.put(`/superadmin/desa/${id}`, payload);
  return response.data;
};

export const deactivateDesa = async (id) => {
  const response = await api.patch(`/superadmin/desa/${id}/nonaktif`);
  return response.data;
};