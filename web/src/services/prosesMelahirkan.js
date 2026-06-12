import api from "./api";

const BASE_RINGKASAN = "/tenaga-kesehatan/ringkasan-persalinan";
const BASE_RIWAYAT = "/tenaga-kesehatan/riwayat-proses-melahirkan";
const BASE_KETERANGAN_LAHIR = "/tenaga-kesehatan/keterangan-lahir";

// 1. Ringkasan Pelayanan Persalinan
export const getRingkasanPersalinanByKehamilanId = async (kehamilanId) => {
  const res = await api.get(`${BASE_RINGKASAN}?kehamilan_id=${kehamilanId}`);
  return res.data.data;
};

export const createRingkasanPersalinan = async (data) => {
  const res = await api.post(BASE_RINGKASAN, data);
  return res.data.data;
};

export const updateRingkasanPersalinan = async (id, data) => {
  const res = await api.put(`${BASE_RINGKASAN}/${id}`, data);
  return res.data.data;
};

export const deleteRingkasanPersalinan = async (id) => {
  const res = await api.delete(`${BASE_RINGKASAN}/${id}`);
  return res.data;
};

// 2. Riwayat Proses Melahirkan
export const getRiwayatMelahirkanByKehamilanId = async (kehamilanId) => {
  const res = await api.get(`${BASE_RIWAYAT}?kehamilan_id=${kehamilanId}`);
  return res.data.data;
};

export const createRiwayatMelahirkan = async (data) => {
  const res = await api.post(BASE_RIWAYAT, data);
  return res.data.data;
};

export const updateRiwayatMelahirkan = async (id, data) => {
  const res = await api.put(`${BASE_RIWAYAT}/${id}`, data);
  return res.data.data;
};

// 3. Keterangan Lahir (Berdasarkan relasi Ibu)
export const getKeteranganLahirByIbuId = async (ibuId) => {
  const res = await api.get(`${BASE_KETERANGAN_LAHIR}?ibu_id=${ibuId}`);
  return res.data.data;
};

export const createKeteranganLahir = async (data) => {
  const res = await api.post(BASE_KETERANGAN_LAHIR, data);
  return res.data.data;
};

export const updateKeteranganLahir = async (id, data) => {
  const res = await api.put(`${BASE_KETERANGAN_LAHIR}/${id}`, data);
  return res.data.data;
};
