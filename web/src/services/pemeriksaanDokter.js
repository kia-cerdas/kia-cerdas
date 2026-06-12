// src/services/pemeriksaanDokter.js
import api from "./api";

// ========== ENDPOINT LAMA (kompatibilitas) ==========
const BASE_DOKTER_T1 = "/tenaga-kesehatan/pemeriksaan-dokter-t1";
const BASE_DOKTER_T3 = "/tenaga-kesehatan/pemeriksaan-dokter-t3";
const BASE_LAB_JIWA = "/tenaga-kesehatan/pemeriksaan-lab-jiwa";
const BASE_LANJUTAN_T3 = "/tenaga-kesehatan/pemeriksaan-lanjutan-t3";

// TRI 1 (lama) – untuk kompatibilitas jika masih ada komponen lain
export const getDokterT1ByKehamilanId = async (kehamilanId) => {
  const res = await api.get(`${BASE_DOKTER_T1}?kehamilan_id=${kehamilanId}`);
  return res.data;
};
export const getDokterT1ById = async (id) => {
  const res = await api.get(`${BASE_DOKTER_T1}/${id}`);
  return res.data;
};
export const createDokterT1 = async (data) => {
  const res = await api.post(BASE_DOKTER_T1, data);
  return res.data;
};
export const updateDokterT1 = async (id, data) => {
  const res = await api.put(`${BASE_DOKTER_T1}/${id}`, data);
  return res.data;
};
export const deleteDokterT1 = async (id) => {
  const res = await api.delete(`${BASE_DOKTER_T1}/${id}`);
  return res.data;
};

// TRI 3 (lama) - TIDAK DIPAKAI LAGI, gunakan T3 Complete di bawah
export const getDokterT3ByKehamilanId = async (kehamilanId) => {
  // Diarahkan ke endpoint complete yang aktif
  const res = await api.get(`/tenaga-kesehatan/pemeriksaan-dokter-t3-complete?kehamilan_id=${kehamilanId}`);
  return res.data;
};
export const getDokterT3ById = async (id) => {
  const res = await api.get(`/tenaga-kesehatan/pemeriksaan-dokter-t3-complete/${id}`);
  return res.data;
};
export const createDokterT3 = async (data) => {
  const res = await api.post(`/tenaga-kesehatan/pemeriksaan-dokter-t3-complete`, data);
  return res.data;
};
export const updateDokterT3 = async (id, data) => {
  const res = await api.put(`/tenaga-kesehatan/pemeriksaan-dokter-t3-complete/${id}`, data);
  return res.data;
};
export const deleteDokterT3 = async (id) => {
  const res = await api.delete(`/tenaga-kesehatan/pemeriksaan-dokter-t3-complete/${id}`);
  return res.data;
};

// Lab Jiwa (lama)
export const getLabJiwaByKehamilanId = async (kehamilanId) => {
  const res = await api.get(`/tenaga-kesehatan/pemeriksaan-lab-jiwa?kehamilan_id=${kehamilanId}`);
  return res.data.data;
};
export const createLabJiwa = async (data) => {
  const res = await api.post(BASE_LAB_JIWA, data);
  return res.data;
};
export const updateLabJiwa = async (id, data) => {
  const res = await api.put(`${BASE_LAB_JIWA}/${id}`, data);
  return res.data;
};

// Lanjutan T3 (lama)
export const getLanjutanT3ByKehamilanId = async (kehamilanId) => {
  const res = await api.get(`${BASE_LANJUTAN_T3}?kehamilan_id=${kehamilanId}`);
  return res.data;
};
export const createLanjutanT3 = async (data) => {
  const res = await api.post(BASE_LANJUTAN_T3, data);
  return res.data;
};
export const updateLanjutanT3 = async (id, data) => {
  const res = await api.put(`${BASE_LANJUTAN_T3}/${id}`, data);
  return res.data;
};

// ========== ENDPOINT BARU (COMPLETE) ==========
const BASE_DOKTER_T1_COMPLETE = "/tenaga-kesehatan/pemeriksaan-dokter-t1-complete";
const BASE_DOKTER_T3_COMPLETE = "/tenaga-kesehatan/pemeriksaan-dokter-t3-complete";

// T1 Complete
export const getDokterT1CompleteByKehamilanId = async (kehamilanId) => {
  const res = await api.get(`${BASE_DOKTER_T1_COMPLETE}?kehamilan_id=${kehamilanId}`);
  return res.data;
};
export const getDokterT1CompleteById = async (id) => {
  const res = await api.get(`${BASE_DOKTER_T1_COMPLETE}/${id}`);
  return res.data;
};
export const createDokterT1Complete = async (data) => {
  const res = await api.post(BASE_DOKTER_T1_COMPLETE, data);
  return res.data;
};
export const updateDokterT1Complete = async (id, data) => {
  const res = await api.put(`${BASE_DOKTER_T1_COMPLETE}/${id}`, data);
  return res.data;
};
export const deleteDokterT1Complete = async (id) => {
  const res = await api.delete(`${BASE_DOKTER_T1_COMPLETE}/${id}`);
  return res.data;
};

// T3 Complete
export const getDokterT3CompleteByKehamilanId = async (kehamilanId) => {
  const res = await api.get(`${BASE_DOKTER_T3_COMPLETE}?kehamilan_id=${kehamilanId}`);
  return res.data;
};
export const getDokterT3CompleteById = async (id) => {
  const res = await api.get(`${BASE_DOKTER_T3_COMPLETE}/${id}`);
  return res.data;
};
export const createDokterT3Complete = async (data) => {
  const res = await api.post(BASE_DOKTER_T3_COMPLETE, data);
  return res.data;
};
export const updateDokterT3Complete = async (id, data) => {
  const res = await api.put(`${BASE_DOKTER_T3_COMPLETE}/${id}`, data);
  return res.data;
};
export const deleteDokterT3Complete = async (id) => {
  const res = await api.delete(`${BASE_DOKTER_T3_COMPLETE}/${id}`);
  return res.data;
};

// ========== CATATAN PELAYANAN TRIMESTER 1 ==========
const BASE_CATATAN_T1 = "/tenaga-kesehatan/catatan-pelayanan-t1";

export const getCatatanT1ByKehamilanId = async (kehamilanId) => {
  const res = await api.get(`${BASE_CATATAN_T1}?kehamilan_id=${kehamilanId}`);
  return res.data;
};
export const getCatatanT1ById = async (id) => {
  const res = await api.get(`${BASE_CATATAN_T1}/${id}`);
  return res.data;
};
export const createCatatanT1 = async (data) => {
  const res = await api.post(BASE_CATATAN_T1, data);
  return res.data;
};
export const updateCatatanT1 = async (id, data) => {
  const res = await api.put(`${BASE_CATATAN_T1}/${id}`, data);
  return res.data;
};
export const deleteCatatanT1 = async (id) => {
  const res = await api.delete(`${BASE_CATATAN_T1}/${id}`);
  return res.data;
};

// ========== CATATAN PELAYANAN TRIMESTER 3 ==========
// Menggunakan endpoint yang sudah ada di backend: /tenaga-kesehatan/catatan-pelayanan-t3
const BASE_CATATAN_T3 = "/tenaga-kesehatan/catatan-pelayanan-t3";

/**
 * Ambil semua catatan T3 berdasarkan kehamilan_id
 * @param {number} kehamilanId
 * @returns {Promise<Array>} list catatan
 */
export const getCatatanT3ByKehamilanId = async (kehamilanId) => {
  const res = await api.get(`${BASE_CATATAN_T3}?kehamilan_id=${kehamilanId}`);
  return res.data;
};

/**
 * Ambil 1 catatan T3 berdasarkan id
 * @param {number} id
 * @returns {Promise<Object>}
 */
export const getCatatanT3ById = async (id) => {
  const res = await api.get(`${BASE_CATATAN_T3}/${id}`);
  return res.data;
};

/**
 * Buat catatan T3 baru
 * Payload: { kehamilan_id, tanggal_periksa_stamp_paraf, keluhan_pemeriksaan_tindakan_saran, tanggal_kembali }
 * @param {Object} data
 * @returns {Promise<Object>}
 */
export const createCatatanT3 = async (data) => {
  const res = await api.post(BASE_CATATAN_T3, data);
  return res.data;
};

/**
 * Update catatan T3
 * @param {number} id  — ini adalah id_catatan_t3 dari tabel
 * @param {Object} data
 * @returns {Promise<Object>}
 */
export const updateCatatanT3 = async (id, data) => {
  const res = await api.put(`${BASE_CATATAN_T3}/${id}`, data);
  return res.data;
};

/**
 * Hapus catatan T3
 * @param {number} id  — ini adalah id_catatan_t3 dari tabel
 * @returns {Promise<Object>}
 */
export const deleteCatatanT3 = async (id) => {
  const res = await api.delete(`${BASE_CATATAN_T3}/${id}`);
  return res.data;
};
