import api from "./api";

const BASE = "/tenaga-kesehatan/perawatan";
const KATEGORI_BASE = "/tenaga-kesehatan/kategori-capaian";

// ─── KATEGORI CAPAIAN ───────────────────────────────────

export const getKategoriCapaianList = async (rentangUsia = "") => {
  const params = rentangUsia ? { rentang_usia: rentangUsia } : {};
  const response = await api.get(KATEGORI_BASE, { params });
  const data = response.data;
  if (Array.isArray(data)) return data;
  if (Array.isArray(data?.data)) return data.data;
  return [];
};

// Buat kategori capaian baru
export const createKategoriCapaian = async (data) => {
  const response = await api.post(KATEGORI_BASE, data);
  return response.data?.data ?? response.data;
};

// Update kategori capaian
export const updateKategoriCapaian = async (id, data) => {
  const response = await api.put(`${KATEGORI_BASE}/${id}`, data);
  return response.data?.data ?? response.data;
};

// Hapus kategori capaian
export const deleteKategoriCapaian = async (id) => {
  const response = await api.delete(`${KATEGORI_BASE}/${id}`);
  return response.data;
};

// ─── PERAWATAN ──────────────────────────────────────────

// Ambil semua perawatan milik satu anak
export const getPerawatanByAnak = async (anakId) => {
  const response = await api.get(BASE, { params: { anak_id: anakId } });
  const data = response.data;
  if (Array.isArray(data)) return data;
  if (Array.isArray(data?.data)) return data.data;
  return [];
};

// Ambil satu record perawatan by ID
export const getPerawatanById = async (id) => {
  const response = await api.get(`${BASE}/${id}`);
  return response.data?.data ?? response.data;
};

// Buat record perawatan baru
export const createPerawatan = async (data) => {
  const response = await api.post(BASE, data);
  return response.data?.data ?? response.data;
};

// Update record perawatan
export const updatePerawatan = async (id, data) => {
  const response = await api.put(`${BASE}/${id}`, data);
  return response.data?.data ?? response.data;
};

// Hapus record perawatan
export const deletePerawatan = async (id) => {
  const response = await api.delete(`${BASE}/${id}`);
  return response.data;
};
