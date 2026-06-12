// src/services/ibu.js
import api from "./api";

const BASE = "/tenaga-kesehatan/ibu";
const BASE1 = "/tenaga-kesehatan/ibuk";

export const getIbuList = async () => {
  // Return always an array. Try main list endpoint, fallback to dashboard endpoint
  const normalizeIbu = (item) => {
    // If item already has kependudukan object, keep it
    if (item.kependudukan) return item;
    // Dashboard DTO may have NamaLengkap and Dusun -> map to expected shape
    return {
      id_ibu: item.id_ibu || item.IDIbu || item.id || item.ibu_id,
      kependudukan: { nama_lengkap: item.nama_lengkap || item.NamaLengkap || (item.penduduk && item.penduduk.nama) || "" },
    };
  };

  try {
    const res = await api.get(BASE);
    const payload = res?.data?.data ?? res?.data ?? [];
    if (Array.isArray(payload)) return payload.map(normalizeIbu);
  } catch (err) {
    // ignore and try fallback
  }

  // Fallback to dashboard endpoint (/ibuk)
  try {
    const res2 = await api.get(BASE1);
    const payload2 = res2?.data?.data ?? res2?.data ?? [];
    if (Array.isArray(payload2)) return payload2.map(normalizeIbu);
  } catch (err) {
    // final fallback: return empty array
  }

  return [];
};

export const getIbuByPendudukId = async (pendudukId) => {
  const response = await api.get(`/tenaga-kesehatan/ibu/by-penduduk/${pendudukId}`);
  return response.data.data; // bisa null
}
export const getIbuDashboard = async () => {
  const tryNormalize = (res) => {
    if (!res) return [];
    // Prioritize res.data.data -> res.data -> res
    if (res.data && Array.isArray(res.data.data)) return res.data.data;
    if (Array.isArray(res.data)) return res.data;
    if (Array.isArray(res)) return res;
    return [];
  };

  try {
    const res = await api.get(BASE1);
    return tryNormalize(res);
  } catch (err1) {
    try {
      const res2 = await api.get(BASE);
      return tryNormalize(res2);
    } catch (err2) {
      // On failure, return empty array to let UI show empty state
      return [];
    }
  }
};
export const getIbuById = async (id) => {
  const res = await api.get(`${BASE}/${id}`);
  return res.data.data;
};

export const createIbu = async (data) => {
  const response = await api.post('/tenaga-kesehatan/ibu', data);
  return response.data.data;
};

export const updateIbu = async (id, data) => {
  const res = await api.put(`${BASE}/${id}`, data);
  return res.data.data;
};

export const deleteIbu = async (id) => {
  const res = await api.delete(`${BASE}/${id}`);
  return res.data;
};