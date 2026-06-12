import axios from './api';

export const dentalService = {
  getByAnak: async (anakId) => {
    try {
      const response = await axios.get(`/tenaga-kesehatan/Pemeriksaan-Gigi?anak_id=${anakId}`);
      return response.data.data || [];
    } catch (error) {
      console.error("Gagal mengambil data gigi:", error);
      return [];
    }
  },
  create: async (payload) => {
    try {
      const response = await axios.post('/tenaga-kesehatan/Pemeriksaan-Gigi', payload);
      return response.data;
    } catch (error) {
      throw error;
    }
  }
};