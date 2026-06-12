import axios from './api';

export const immunizationService = {
  getPelayananByAnak: async (anakId) => {
    try {
      const response = await axios.get(`/tenaga-kesehatan/Pelayanan-Imunisasi?anak_id=${anakId}`);
      const rawData = response.data.data; // Ini adalah array kunjungan []

      const mappedData = {};

      rawData.forEach(kunjungan => {
        const bulan = kunjungan.bulan_ke;
        const tglKunjungan = kunjungan.created_at;

        // Kita loop array "detail" untuk mengambil jenis_pelayanan_id
        kunjungan.detail.forEach(item => {
          // Key unik: "bulan-idJenis" (Contoh: "0-32")
          const key = `${bulan}-${item.jenis_pelayanan_id}`;
          
          mappedData[key] = {
            tanggal: tglKunjungan,
            keterangan: item.keterangan,
            id_jenis: item.jenis_pelayanan_id
          };
        });
      });

      return mappedData;
    } catch (error) {
      console.error("Gagal mapping data:", error);
      return {};
    }
  },

  createPelayanan: async (payload) => {
    try {
      const response = await axios.post('/tenaga-kesehatan/Pelayanan-Imunisasi', payload);
      return response.data;
    } catch (error) {
      throw error;
    }
  }
};