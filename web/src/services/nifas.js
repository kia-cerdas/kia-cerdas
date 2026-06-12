import api from "./api";

const BASE = "/tenaga-kesehatan/pelayanan-ibu-nifas";

export const getNifasByKehamilanId = async (kehamilanId) => {
  const res = await api.get(`${BASE}?kehamilan_id=${kehamilanId}`);
  return res.data.data;
};

export const createNifas = async (data) => {
  const res = await api.post(BASE, data);
  return res.data.data;
};

export const updateNifas = async (id, data) => {
  const res = await api.put(`${BASE}/${id}`, data);
  return res.data.data;
};

export const deleteNifas = async (id) => {
  const res = await api.delete(`${BASE}/${id}`);
  return res.data;
};