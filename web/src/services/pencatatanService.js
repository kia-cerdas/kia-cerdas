import api from "./api";

export const getPendudukByKategori = async (kategori) => {
  const response = await api.get(`/tenaga-kesehatan/penduduk-by-kategori`, {
    params: { kategori }
  });
  return response.data.data;
};

export const createPemeriksaan = async (kategori, data) => {
  let endpoint = '';
  switch (kategori) {
    case 'anak': endpoint = '/pemeriksaan-anak'; break;
    case 'remaja': endpoint = '/pemeriksaan-remaja'; break;
    case 'dewasa': endpoint = '/pemeriksaan-dewasa'; break;
    case 'lansia': endpoint = '/pemeriksaan-lansia'; break;
    default: throw new Error('Kategori tidak valid');
  }
  const response = await api.post(`/tenaga-kesehatan${endpoint}`, data);
  return response.data;
};