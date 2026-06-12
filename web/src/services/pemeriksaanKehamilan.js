import api from "./api";

const BASE = "/tenaga-kesehatan/pemeriksaan-kehamilan";
const BASE1 = "/tenaga-kesehatan/pemeriksaan-kehamilan/grafik-anc";

const getAuthHeader = () => ({
  headers: { Authorization: `Bearer ${localStorage.getItem("access_token")}` },
});

export const getPemeriksaanKehamilanByKehamilanId = async (kehamilanId) => {
  const res = await api.get(`${BASE}?kehamilan_id=${kehamilanId}`, getAuthHeader());
  return res.data.data;
};
export const getGrafikehamilanByKehamilanId = async (kehamilanId) => {
  const res = await api.get(`${BASE1}?kehamilan_id=${kehamilanId}`, getAuthHeader());
  return res.data.data;
};
export const getPemeriksaanKehamilanById = async (id) => {
  const res = await api.get(`${BASE}/${id}`, getAuthHeader());
  return res.data.data;
};

export const createPemeriksaanKehamilan = async (data) => {
  const res = await api.post(BASE, data, getAuthHeader());
  return res.data.data;
};

export const updatePemeriksaanKehamilan = async (id, data) => {
  const res = await api.put(`${BASE}/${id}`, data, getAuthHeader());
  return res.data.data;
};

export const deletePemeriksaanKehamilan = async (id) => {
  const res = await api.delete(`${BASE}/${id}`, getAuthHeader());
  return res.data;
};
