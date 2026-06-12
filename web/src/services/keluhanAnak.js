import api from "./api";

export const getKeluhanByAnakId = async (anakId) => {
  const res = await api.get(`/tenaga-kesehatan/keluhan-anak/${anakId}`);
  return res.data;
};

export const getKeluhanById = async (id) => {
  const res = await api.get(`/tenaga-kesehatan/keluhan-anak/detail/${id}`);
  return res.data;
};

export const createKeluhan = async (payload) => {
  const res = await api.post("/tenaga-kesehatan/keluhan-anak", payload);
  return res.data;
};

export const updateKeluhan = async (id, payload) => {
  const res = await api.put(`/tenaga-kesehatan/keluhan-anak/${id}`, payload);
  return res.data;
};

export const deleteKeluhan = async (id) => {
  const res = await api.delete(`/tenaga-kesehatan/keluhan-anak/${id}`);
  return res.data;
};
