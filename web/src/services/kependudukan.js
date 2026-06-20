// services/kependudukan.js
import api from "./api";

const BASE = "/tenaga-kesehatan/kependudukan";
const BASE_DESA = "/tenaga-kesehatan/kependudukan/desa";
const BASEADMIN = "/superadmin/penduduk";

// ============================================
// ENDPOINT TENAGA KESEHATAN
// ============================================

export const getKependudukanList = async (jenisKelamin = null) => {
  const params = jenisKelamin ? { jenis_kelamin: jenisKelamin } : {};
  const res = await api.get(BASE_DESA, { params });
  return res.data.data;
};

export const getPerempuanList = async () => {
  return getKependudukanList("perempuan");
};

export const getLakiList = async () => {
  return getKependudukanList("laki");
};

export const getAllPendudukByDesa = async () => {
  return getKependudukanList();
};

export const getKependudukanById = async (id) => {
  const res = await api.get(`${BASE}/${id}`);
  return res.data.data;
};

// ============================================
// ENDPOINT SUPERADMIN
// ============================================

export const createKependudukan = async (data) => {
  const res = await api.post(BASEADMIN, data);
  return res.data.data;
};

export const updateKependudukan = async (id, data) => {
  const res = await api.put(`${BASEADMIN}/${id}`, data);
  return res.data.data;
};

export const deleteKependudukan = async (id) => {
  const res = await api.delete(`${BASEADMIN}/${id}`);
  return res.data;
};

/**
 * Get penduduk dengan filter dan pagination
 * @param {Object} options - Filter options
 * @param {number} options.page - Halaman (default: 1)
 * @param {number} options.limit - Jumlah per halaman (default: 10)
 * @param {string} options.search - Keyword pencarian
 * @param {string} options.rw - Filter RW
 * @param {string} options.rt - Filter RT
 * @param {string} options.dusun - Filter Dusun
 * @param {string} options.kode_keluarga - Filter Kode Keluarga
 * @param {string} options.status - Filter Status
 * @param {string} options.hubungan - Filter Hubungan
 * @param {number} options.desa_id - Filter Desa ID
 * @param {number} options.posyandu_id - Filter Posyandu ID
 */
export const getPendudukWithFilters = async (options = {}) => {
  const {
    page = 1,
    limit = 10,
    search = "",
    rw = "",
    rt = "",
    dusun = "",
    kode_keluarga = "",
    status = "",
    hubungan = "",
    desa_id = null,
    posyandu_id = null,
  } = options;

  // Build query params
  const params = {
    page,
    limit,
  };

  // Tambahkan filter jika ada
  if (search) params.search = search;
  if (rw) params.rw = rw;
  if (rt) params.rt = rt;
  if (dusun) params.dusun = dusun;
  if (kode_keluarga) params.kode_keluarga = kode_keluarga;
  if (status) params.status = status;
  if (hubungan) params.hubungan = hubungan;
  if (desa_id) params.desa_id = desa_id;
  if (posyandu_id) params.posyandu_id = posyandu_id;

  const res = await api.get(BASEADMIN, { params });
  return res.data.data;
};

/**
 * Get penduduk by ID (Superadmin)
 */
export const getPendudukById = async (id) => {
  const res = await api.get(`${BASEADMIN}/${id}`);
  return res.data.data;
};

/**
 * Get penduduk by kode keluarga
 */
export const getPendudukByKodeKeluarga = async (kodeKeluarga) => {
  const res = await api.get(`${BASEADMIN}/keluarga/${kodeKeluarga}`);
  return res.data.data;
};

/**
 * Get kepala keluarga by kode keluarga
 */
export const getKepalaKeluarga = async (kodeKeluarga) => {
  const res = await api.get(`${BASEADMIN}/keluarga/${kodeKeluarga}/kepala`);
  return res.data.data;
};

/**
 * Get statistik penduduk
 */
export const getStatistikPenduduk = async (params = {}) => {
  const res = await api.get(`${BASEADMIN}/statistik`, { params });
  return res.data.data;
};

/**
 * Get all penduduk (tanpa pagination)
 */
export const getAllPenduduk = async () => {
  const res = await api.get(BASEADMIN, { params: { limit: 1000 } });
  return res.data.data.items || [];
};

// ============================================
// ALIAS UNTUK KOMPATIBILITAS
// ============================================

// Untuk kompatibilitas dengan kode lama yang membutuhkan listKependudukan
export const listKependudukan = getPendudukWithFilters;

// ============================================
// DEFAULT EXPORT
// ============================================

export default {
  // Tenaga Kesehatan
  getKependudukanList,
  getPerempuanList,
  getLakiList,
  getAllPendudukByDesa,
  getKependudukanById,
  
  // Superadmin
  createKependudukan,
  updateKependudukan,
  deleteKependudukan,
  getPendudukWithFilters,
  getPendudukById,
  getPendudukByKodeKeluarga,
  getKepalaKeluarga,
  getStatistikPenduduk,
  getAllPenduduk,
  
  // Aliases
  listKependudukan,
};