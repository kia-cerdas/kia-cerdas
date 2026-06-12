import api from "./api";

const BASE_EVALUASI = "/tenaga-kesehatan/evaluasi-kesehatan-ibu";
const BASE_RIWAYAT = "/tenaga-kesehatan/riwayat-kehamilan-lalu";

// ==================== EVALUASI KESEHATAN IBU ====================
export const getEvaluasiByKehamilanId = async (kehamilanId) => {
  const res = await api.get(`${BASE_EVALUASI}?kehamilan_id=${kehamilanId}`);
  return res.data.data;
};

export const getEvaluasiById = async (id) => {
  const res = await api.get(`${BASE_EVALUASI}/${id}`);
  return res.data.data;
};

export const createEvaluasi = async (data) => {
  const res = await api.post(BASE_EVALUASI, data);
  return res.data.data;
};

export const updateEvaluasi = async (id, data) => {
  const res = await api.put(`${BASE_EVALUASI}/${id}`, data);
  return res.data.data;
};

export const deleteEvaluasi = async (id) => {
  const res = await api.delete(`${BASE_EVALUASI}/${id}`);
  return res.data;
};

// ==================== RIWAYAT KEHAMILAN LALU ====================
export const getRiwayatKehamilanByEvaluasiId = async (evaluasiId) => {
  const res = await api.get(`${BASE_RIWAYAT}?id_evaluasi=${evaluasiId}`);
  return res.data.data;
};

export const getRiwayatKehamilanById = async (id) => {
  const res = await api.get(`${BASE_RIWAYAT}/${id}`);
  return res.data.data;
};

export const createRiwayatKehamilan = async (data) => {
  const res = await api.post(BASE_RIWAYAT, data);
  return res.data.data;
};

export const updateRiwayatKehamilan = async (id, data) => {
  const res = await api.put(`${BASE_RIWAYAT}/${id}`, data);
  return res.data.data;
};

export const deleteRiwayatKehamilan = async (id) => {
  const res = await api.delete(`${BASE_RIWAYAT}/${id}`);
  return res.data;
};
