// src/services/Pelayanan-lila-anak.js
import api from "./api";

const BASE = "/tenaga-kesehatan/Pengukuran-LilA";

export const PelayananLilaService = {
  // Get semua LILA untuk seorang anak
  getByAnakId: async (anakId) => {
    const res = await api.get(`${BASE}?anak_id=${anakId}`);
    return res.data?.data || res.data || [];
  },

  // Get LILA by ID
  getById: async (lilaId) => {
    const res = await api.get(`${BASE}/${lilaId}`);
    return res.data?.data || res.data;
  },

  // Create LILA baru
  create: async (data) => {
    const res = await api.post(BASE, data);
    return res.data?.data || res.data;
  },

  // Update LILA
  update: async (lilaId, data) => {
    const res = await api.put(`${BASE}/${lilaId}`, data);
    return res.data?.data || res.data;
  },

  // Delete LILA
  delete: async (lilaId) => {
    const res = await api.delete(`${BASE}/${lilaId}`);
    return res.data;
  }
};
