import api from "./api";

const BASE = "/informasi-umum";

const unwrapData = (response) => response.data?.data;

export const getInformasiUmumList = async () => {
  const response = await api.get(BASE);
  return unwrapData(response);
};

export const getInformasiUmumById = async (id) => {
  const response = await api.get(`${BASE}/${id}`);
  return unwrapData(response);
};

export const createInformasiUmum = async (payload) => {
  const response = await api.post(BASE, payload);
  return unwrapData(response);
};

export const updateInformasiUmum = async (id, payload) => {
  const response = await api.put(`${BASE}/${id}`, payload);
  return unwrapData(response);
};

export const deleteInformasiUmum = async (id) => {
  const response = await api.delete(`${BASE}/${id}`);
  return unwrapData(response);
};