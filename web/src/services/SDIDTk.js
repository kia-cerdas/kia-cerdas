import api from "./api";

const SDIDTK_ENDPOINT = "/tenaga-kesehatan/Pemantauan-Pertumbuhan-Anak";

export const sdidtkService = {
  /**
   * Mengambil riwayat SDIDTK berdasarkan ID Anak
   */
  getByAnakId: async (anakId) => {
    try {
      const response = await api.get(`${SDIDTK_ENDPOINT}?anak_id=${anakId}`);
      return response.data; // Mengembalikan { data: [...], message: "success" }
    } catch (error) {
      throw error;
    }
  },

  /**
   * Menambah data pemeriksaan baru
   */
  create: async (payload) => {
    try {
      const response = await api.post(SDIDTK_ENDPOINT, payload);
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  /**
   * Helper untuk format tanggal ke ISO String (T00:00:00Z)
   */
  formatToISO: (dateStr) => {
    if (!dateStr) return null;
    const date = new Date(dateStr);
    return date.toISOString(); // Menghasilkan format 2026-04-13T00:00:00.000Z
  }
};