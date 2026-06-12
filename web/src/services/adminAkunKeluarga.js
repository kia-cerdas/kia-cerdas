import api from "./api";

export const createAkunKeluargaAdmin = async (payload) => {
  const response = await api.post("/superadmin/kartu-keluarga", payload);
  return response.data?.data ?? response.data;
};

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

export const listKartuKeluargaAdmin = async (params = {}) => {
  const response = await api.get("/superadmin/kartu-keluarga", { params });
  return response.data?.data ?? response.data;
};

export const detailKartuKeluargaAdmin = async (kartuKeluargaId) => {
  const response = await api.get(`/superadmin/kartu-keluarga/${kartuKeluargaId}`);
  return response.data?.data ?? response.data;
};

export const updateKartuKeluargaAdmin = async (kartuKeluargaId, payload) => {
  const response = await api.put(`/superadmin/kartu-keluarga/${kartuKeluargaId}`, payload);
  return response.data?.data ?? response.data;
};

export const updateAnggotaKeluargaAdmin = async (kartuKeluargaId, pendudukId, payload) => {
  const response = await api.put(`/superadmin/kartu-keluarga/${kartuKeluargaId}/anggota/${pendudukId}`, payload);
  return response.data?.data ?? response.data;
};

export const addAnggotaKeluargaAdmin = async (kartuKeluargaId, payload) => {
  const response = await api.post(`/superadmin/kartu-keluarga/${kartuKeluargaId}/anggota`, payload);
  return response.data?.data ?? response.data;
};

export const deleteAnggotaKeluargaAdmin = async (kartuKeluargaId, pendudukId) => {
  const response = await api.delete(`/superadmin/kartu-keluarga/${kartuKeluargaId}/anggota/${pendudukId}`);
  return response.data?.data ?? response.data;
};

export const deleteKartuKeluargaAdmin = async (kartuKeluargaId) => {
  const response = await api.delete(`/superadmin/kartu-keluarga/${kartuKeluargaId}`);
  return response.data?.data ?? response.data;
};

export const adminAkunKeluargaErrorMessage = extractApiError;
