import api from "./api";

export const getPemantauanHistory = async (anakId, rentangId) => {
  const res = await api.get("/tenaga-kesehatan/pemantauan-anak/history", {
    params: { anak_id: anakId, rentang_usia_id: rentangId },
  });
  return res.data.data;
};

export const getRentangUsia = async () => {
  const res = await api.get("/tenaga-kesehatan/pemantauan-anak/rentang-usia");
  return res.data.data;
};

export const getKategoriByRentang = async (rentangId) => {
  const res = await api.get(`/tenaga-kesehatan/pemantauan-anak/kategori/${rentangId}`);
  return res.data.data;
};

export const savePemantauanAnak = async (payload) => {
  const res = await api.post("/tenaga-kesehatan/pemantauan-anak", payload);
  return res.data;
};

export const deletePemantauanAnak = async (id) => {
  const res = await api.delete(`/tenaga-kesehatan/pemantauan-anak/${id}`);
  return res.data;
};

export const createIndicator = async (payload) => {
  const res = await api.post("/tenaga-kesehatan/pemantauan-anak/indikator", payload);
  return res.data;
};

export const updateIndicator = async (id, payload) => {
  const res = await api.put(`/tenaga-kesehatan/pemantauan-anak/indikator/${id}`, payload);
  return res.data;
};

export const deleteIndicator = async (id) => {
  const res = await api.delete(`/tenaga-kesehatan/pemantauan-anak/indikator/${id}`);
  return res.data;
};

export const verifikasiPemantauanAnak = async (id, payload) => {
  const res = await api.put(`/tenaga-kesehatan/pemantauan-anak/${id}/verifikasi`, payload);
  return res.data;
};
