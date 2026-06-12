import api from "./api"; // Impor instance axios yang ada interceptor-nya

export const neonatusService = {
  // 0. Fetch periode kunjungan berdasarkan nama kategori umur (untuk mendapat periode_id yang benar)
  getPeriodeKunjungan: async (kategoriUmurNama = "bayi_0_28_hari") => {
    try {
      const response = await api.get("/tenaga-kesehatan/periode-kunjungan", {
        params: { kategori_umur: kategoriUmurNama }
      });
      // Return full response: { data: [...periodes], kategori_umur_id: number }
      return response.data;
    } catch (error) {
      console.warn("Gagal fetch periode kunjungan:", error);
      return { data: [], kategori_umur_id: 1 };
    }
  },

  // 1. Ambil jenis pelayanan berdasarkan periode (Metadata Form)
  getJenisPelayanan: async (periodeId) => {
    try {
      const response = await api.get("/tenaga-kesehatan/jenis-pelayanan", {
        params: {
          kategori_umur_id: 1,
          periode_id: periodeId
        }
      });
      return response.data.data;
    } catch (error) {
      throw error.response?.data || error.message;
    }
  },

  // 2. Simpan data pemeriksaan baru (Create)
  savePemeriksaan: async (payload) => {
    try {
      const response = await api.post("/tenaga-kesehatan/Neonatus", payload);
      return response.data;
    } catch (error) {
      throw error.response?.data || error.message;
    }
  },

  // 3. Ambil data pemeriksaan yang sudah ada (Get Detail)
  getPemeriksaanDetail: async (anakId, periodeId) => {
    try {
      const response = await api.get(`/tenaga-kesehatan/Neonatus`, {
        params: { 
          anak_id: anakId, 
          periode_id: periodeId 
        }
      });
      const finalData = response.data.data || response.data;
      console.log("📡 [Service] Data dari Server:", finalData);
      return finalData;
    } catch (error) {
      if (error.response?.status === 404) return null;
      throw error.response?.data || error.message;
    }
  },

  // 4. Update data pemeriksaan (Edit)
  updatePemeriksaan: async (pemeriksaanId, payload) => {
    try {
      const response = await api.put(`/tenaga-kesehatan/Neonatus/${pemeriksaanId}`, payload);
      return response.data;
    } catch (error) {
      throw error.response?.data || error.message;
    }
  }
};