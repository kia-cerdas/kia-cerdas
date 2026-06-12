import api from "./api";

const BASE_URL = "/tenaga-kesehatan/pemantauan-indikator";

const unwrapList = (response) => {
  const payload = response?.data;
  if (Array.isArray(payload)) return payload;
  if (Array.isArray(payload?.data)) return payload.data;
  return [];
};

export const getPemantauanIndikatorList = async (kategoriUsia = "", q = "") => {
  const response = await api.get(BASE_URL, {
    params: {
      kategori_usia: kategoriUsia || undefined,
      q: q || undefined,
    },
  });
  return unwrapList(response);
};

export const createPemantauanIndikator = async (payload) => {
  const response = await api.post(BASE_URL, payload);
  return response.data?.data ?? response.data;
};

export const updatePemantauanIndikator = async (id, payload) => {
  const response = await api.put(`${BASE_URL}/${id}`, payload);
  return response.data?.data ?? response.data;
};

export const deletePemantauanIndikator = async (id) => {
  const response = await api.delete(`${BASE_URL}/${id}`);
  return response.data?.data ?? response.data;
};