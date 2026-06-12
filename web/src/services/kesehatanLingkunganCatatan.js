import api from "./api";

const BASE = "/tenaga-kesehatan/kesehatan-lingkungan";
const BASE_FALLBACK = "/api/v1/tenaga-kesehatan/kesehatan-lingkungan";

const isNotFound = (error) => error?.response?.status === 404;

const withFallback = async (primaryCall, fallbackCall) => {
  try {
    return await primaryCall();
  } catch (error) {
    if (!isNotFound(error) || !fallbackCall) {
      throw error;
    }
    return fallbackCall();
  }
};

export const getKesehatanLingkunganList = async (ibuId) => {
  const params = ibuId ? { ibu_id: ibuId } : undefined;
  const res = await withFallback(
    () => api.get(BASE, { params }),
    () => api.get(BASE_FALLBACK, { params })
  );
  return res.data.data || [];
};

export const getKesehatanLingkunganById = async (id) => {
  const res = await withFallback(
    () => api.get(`${BASE}/${id}`),
    () => api.get(`${BASE_FALLBACK}/${id}`)
  );
  return res.data.data;
};

export const createKesehatanLingkungan = async (payload) => {
  const res = await withFallback(
    () => api.post(BASE, payload),
    () => api.post(BASE_FALLBACK, payload)
  );
  return res.data.data;
};

export const getCatatanKaderByKesehatanId = async (kesehatanId) => {
  const res = await withFallback(
    () => api.get(`${BASE}/${kesehatanId}/catatan-kader`),
    () => api.get(`${BASE_FALLBACK}/${kesehatanId}/catatan-kader`)
  );
  return res.data.data || [];
};

export const createCatatanKader = async (kesehatanId, payload) => {
  const res = await withFallback(
    () => api.post(`${BASE}/${kesehatanId}/catatan-kader`, payload),
    () => api.post(`${BASE_FALLBACK}/${kesehatanId}/catatan-kader`, payload)
  );
  return res.data.data;
};

export const updateCatatanKader = async (kesehatanId, catatanId, payload) => {
  const res = await withFallback(
    () => api.put(`${BASE}/${kesehatanId}/catatan-kader/${catatanId}`, payload),
    () => api.put(`${BASE_FALLBACK}/${kesehatanId}/catatan-kader/${catatanId}`, payload)
  );
  return res.data.data;
};

export const deleteCatatanKader = async (kesehatanId, catatanId) => {
  const res = await withFallback(
    () => api.delete(`${BASE}/${kesehatanId}/catatan-kader/${catatanId}`),
    () => api.delete(`${BASE_FALLBACK}/${kesehatanId}/catatan-kader/${catatanId}`)
  );
  return res.data;
};

export const kirimCatatanKeMobile = async (kesehatanId, catatanId) => {
  const res = await withFallback(
    () => api.put(`${BASE}/${kesehatanId}/catatan-kader/${catatanId}/kirim-mobile`),
    () => api.put(`${BASE_FALLBACK}/${kesehatanId}/catatan-kader/${catatanId}/kirim-mobile`)
  );
  return res.data.data;
};

export const updateKesehatanLingkungan = async (id, payload) => {
  const res = await withFallback(
    () => api.put(`${BASE}/${id}`, payload),
    () => api.put(`${BASE_FALLBACK}/${id}`, payload)
  );
  return res.data.data;
};
