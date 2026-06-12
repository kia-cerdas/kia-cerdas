import api from "./api";

const BASE = "/tenaga-kesehatan/Pelayanan-Gizi-Anak";

export const PelayananGiziService = {
  // Ambil Riwayat berdasarkan anak_id (Query Param)
  getByAnakId: async (anakId) => {
    const res = await api.get(`${BASE}`, {
      params: { anak_id: anakId }
    });
    return res.data;
  },

  getById: async (id) => {
    const res = await api.get(`${BASE}/${id}`);
    return res.data;
  },

  create: async (data) => {
    const res = await api.post(BASE, data);
    return res.data;
  },

  update: async (id, data) => {
    const res = await api.put(`${BASE}/${id}`, data);
    return res.data;
  },

  delete: async (id) => {
    const res = await api.delete(`${BASE}/${id}`);
    return res.data;
  }
};