import api from "./api";

const BASE = "/tenaga-kesehatan/pertumbuhan";

export const getRiwayatPertumbuhan = async (anakId) => {
  const res = await api.get(`${BASE}/anak/${anakId}`);
  return res.data;
};

export const getPertumbuhanChart = async (anakId) => {
  const res = await api.get(`${BASE}/chart/${anakId}`);
  return res.data;
};

export const addCatatanPertumbuhan = async (data) => {
  const res = await api.post(BASE, data);
  return res.data;
};

export const updateCatatanPertumbuhan = async (id, data) => {
  const res = await api.put(`${BASE}/${id}`, data);
  return res.data;
};

export const deleteCatatanPertumbuhan = async (id) => {
  const res = await api.delete(`${BASE}/${id}`);
  return res.data;
};

// ── Prediksi Stunting melalui backend Go ─────────────────────────────────

/**
 * Ambil data pengukuran terbaru anak (BB, TB, LILA, Lingkar Kepala)
 * dari backend Go. Digunakan untuk prefill form prediksi.
 */
export const getMeasurementData = async (anakId) => {
  try {
    const res = await api.get(`/api/v1/anak/${anakId}/measurement-data`);
    return res.data;
  } catch {
    return null;
  }
};

/**
 * Kirim request prediksi stunting ke backend Go.
 * Backend Go yang akan meneruskan ke FastAPI ML service.
 */
export const prediksiStunting = async (payload) => {
  const res = await api.post("/api/v1/prediksi-stunting", payload);
  return res.data;
};

/**
 * Ambil riwayat prediksi stunting dari backend Go.
 */
export const getRiwayatPrediksi = async (anakId) => {
  const res = await api.get(`/api/v1/anak/${anakId}/prediksi-stunting`);
  return res.data;
};

/**
 * Ambil prediksi stunting terbaru untuk satu anak.
 */
export const getLatestPrediksi = async (anakId) => {
  try {
    const res = await api.get(`/api/v1/anak/${anakId}/prediksi-stunting/latest`);
    return res.data;
  } catch {
    return null;
  }
};
