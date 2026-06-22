import api from "./api";

const normalizeMessage = (message) => {
  if (Array.isArray(message)) return message.join(", ");
  return message || "";
};

export const wilayahErrorMessage = (error, fallbackMessage = "Terjadi kesalahan") => {
  const message = error?.response?.data?.message;
  return normalizeMessage(message) || fallbackMessage;
};

const unwrap = (response) => response.data?.data ?? [];

// ===================== PROVINSI =====================
export const listProvinsi = async () => {
  const response = await api.get("/superadmin/provinsi");
  return unwrap(response);
};

export const createProvinsi = async (payload) => {
  const response = await api.post("/superadmin/provinsi", payload);
  return response.data;
};

export const updateProvinsi = async (id, payload) => {
  const response = await api.put(`/superadmin/provinsi/${id}`, payload);
  return response.data;
};

export const deleteProvinsi = async (id) => {
  const response = await api.delete(`/superadmin/provinsi/${id}`);
  return response.data;
};

// ===================== KABUPATEN =====================
export const listKabupaten = async (params = {}) => {
  const response = await api.get("/superadmin/kabupaten", { params });
  return unwrap(response);
};

export const createKabupaten = async (payload) => {
  const response = await api.post("/superadmin/kabupaten", payload);
  return response.data;
};

export const updateKabupaten = async (id, payload) => {
  const response = await api.put(`/superadmin/kabupaten/${id}`, payload);
  return response.data;
};

export const deleteKabupaten = async (id) => {
  const response = await api.delete(`/superadmin/kabupaten/${id}`);
  return response.data;
};

// ===================== KECAMATAN =====================
export const listKecamatan = async (params = {}) => {
  const response = await api.get("/superadmin/kecamatan", { params });
  return unwrap(response);
};

export const createKecamatan = async (payload) => {
  const response = await api.post("/superadmin/kecamatan", payload);
  return response.data;
};

export const updateKecamatan = async (id, payload) => {
  const response = await api.put(`/superadmin/kecamatan/${id}`, payload);
  return response.data;
};

export const deleteKecamatan = async (id) => {
  const response = await api.delete(`/superadmin/kecamatan/${id}`);
  return response.data;
};
