import api from "./api";

const BASE = "/tenaga-kesehatan/pemeriksaan-kehamilan";

export const getPemeriksaanByKehamilanId = async (kehamilanId) => {
  const res = await api.get(`${BASE}?kehamilan_id=${kehamilanId}`);
  return res.data.data;
};

export const createPemeriksaan = async (data) => {
  const res = await api.post(BASE, data);
  return res.data.data;
};

export const updatePemeriksaan = async (id, data) => {
  const res = await api.put(`${BASE}/${id}`, data);
  return res.data.data;
};

export const getActiveForm = async (kelompok) => {
  const response = await api.get("/tenaga-kesehatan/forms/active", {
    params: { kelompok },
  });
  return response.data; // { versi: {...}, pertanyaan: [...] }
};

// Simpan pemeriksaan (backend akan evaluasi risiko)
export const savePemeriksaan = async (payload) => {
  const response = await api.post("/tenaga-kesehatan/pemeriksaan", payload);
  return response.data;
};

// Ambil riwayat pemeriksaan penduduk
export const getRiwayatPemeriksaan = async (pendudukId, kelompok) => {
  const response = await api.get(`/tenaga-kesehatan/penduduk/${pendudukId}/riwayat`, {
    params: { kelompok },
  });
  return response.data;
};