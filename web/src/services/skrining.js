import api from "./api";

const BASE = "/tenaga-kesehatan/skrining-preeklampsia";

export const getSkriningByKehamilanId = async (kehamilanId) => {
  const res = await api.get(`${BASE}?kehamilan_id=${kehamilanId}`);
  return res.data.data;
};

export const createSkrining = async (data) => {
  const res = await api.post(BASE, data);
  return res.data.data;
};

export const updateSkrining = async (id, data) => {
  const res = await api.put(`${BASE}/${id}`, data);
  return res.data.data;
};