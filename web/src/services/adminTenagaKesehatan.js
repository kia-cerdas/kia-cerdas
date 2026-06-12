import api from "./api";

const normalizeMessage = (message) => {
  if (Array.isArray(message)) {
    return message.join(", ");
  }
  return message || "";
};

export const adminTenagaErrorMessage = (error, fallbackMessage = "Terjadi kesalahan") => {
  const message = error?.response?.data?.message;
  const normalized = normalizeMessage(message);
  return normalized || fallbackMessage;
};

// BIDAN ENDPOINTS (Role-based access)
export const listPosyanduBidan = async (params = {}) => {
  const response = await api.get("/bidan/posyandu", { params });
  return response.data.data || [];
};

export const createPosyanduBidan = async (payload) => {
  const response = await api.post("/bidan/posyandu", payload);
  return response.data;
};

export const getPosyanduDetailBidan = async (id) => {
  const response = await api.get(`/bidan/posyandu/${id}`);
  return response.data.data;
};

export const updatePosyanduBidan = async (id, payload) => {
  const response = await api.put(`/bidan/posyandu/${id}`, payload);
  return response.data;
};

export const listBidanBidan = async (params = {}) => {
  const response = await api.get("/bidan/bidan", { params });
  return response.data.data || [];
};

export const createBidanBidan = async (payload) => {
  const response = await api.post("/bidan/bidan", payload);
  return response.data;
};

export const getBidanDetailBidan = async (id) => {
  const response = await api.get(`/bidan/bidan/${id}`);
  return response.data.data;
};

export const updateBidanBidan = async (id, payload) => {
  const response = await api.put(`/bidan/bidan/${id}`, payload);
  return response.data;
};

export const listKaderBidan = async (params = {}) => {
  const response = await api.get("/bidan/kader", { params });
  return response.data.data || [];
};

export const createKaderBidan = async (payload) => {
  const response = await api.post("/bidan/kader", payload);
  return response.data;
};

export const getKaderDetailBidan = async (id) => {
  const response = await api.get(`/bidan/kader/${id}`);
  return response.data.data;
};

export const updateKaderBidan = async (id, payload) => {
  const response = await api.put(`/bidan/kader/${id}`, payload);
  return response.data;
};

// DROPDOWN DATA (untuk searchable select)
export const listPendudukForDropdown = async (params = {}) => {
  const response = await api.get("/bidan/penduduk", { params });
  return response.data.data || [];
};

export const listPosyanduForDropdown = async (params = {}) => {
  const response = await api.get("/bidan/posyandu", { params });
  return response.data.data || [];
};
