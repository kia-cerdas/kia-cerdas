    import api from "./api";

    const BASE = "/tenaga-kesehatan/dashboard";

    export const getJumlahUsia = async () => {
      const response = await api.get(`${BASE}/jumlah-usia`);
      return response.data.data; // langsung ambil data di dalamnya
    };

    export const getKesehatanKelompok = async () => {
      const response = await api.get(`${BASE}/kesehatan-per-kelompok`);
      return response.data.data;
    };

    export const getCakupanPemeriksaan = async () => {
      const response = await api.get(`${BASE}/cakupan-pemeriksaan`);
      return response.data.data;
    };

    export const getPendudukByRisk = async (kategori, risiko) => {
      const response = await api.get('/tenaga-kesehatan/penduduk-by-risiko', {
        params: { 
          kategori: kategori,   // backend pakai "kategori"
          risiko: risiko 
        }
      });
      // Asumsikan controller mengembalikan langsung array (c.JSON(http.StatusOK, result))
      // Jika response dibungkus dengan { data: ... }, gunakan response.data.data
      return response.data;
    };

    // Opsional: jika ada endpoint yang mengembalikan semua data dashboard sekaligus
    export const getDashboardData = async () => {
      try {
        const response = await api.get(`${BASE}`);
        return response.data.data;
      } catch (error) {
        console.error("Dashboard API error", error);
        throw error;
      }
    };
    
    export const getRiwayatCard = async (id) => {
    const response = await api.get(`/tenaga-kesehatan/penduduk/${id}/riwayat-card`);
    return response.data.data;
  };
    export const getRiwayat = async (id) => {
    const response = await api.get(`/tenaga-kesehatan/penduduk/${id}/riwayat`);
    return response.data;
  };
  export const getPendudukByKategori = async (kategori) => {
    const response = await api.get('/tenaga-kesehatan/penduduk-by-kategori', {
      params: { kategori }
    });
    return response.data.data;
  };