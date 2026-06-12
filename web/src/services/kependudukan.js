import api from "./api";

const BASE = "/tenaga-kesehatan/kependudukan";
const BASE_DESA = "/tenaga-kesehatan/kependudukan/desa";

export const getKependudukanList = async (jenisKelamin = null) => {
   const params = jenisKelamin ? { jenis_kelamin: jenisKelamin } : {};
   const res = await api.get(BASE_DESA, { params }); // ← Tambahkan { params }
  return res.data.data;
};

export const getPerempuanList = async () => {
  return getKependudukanList("perempuan");
};

export const getLakiList = async () => {
  return getKependudukanList("laki");
};

export const getAllPendudukByDesa = async () => {
  return getKependudukanList();
};

export const getKependudukanById = async (id) => {
  const res = await api.get(`${BASE}/${id}`);
  return res.data.data;
};

export const createKependudukan = async (data) => {
  const res = await api.post(BASE, data);
  return res.data.data;
};

export const updateKependudukan = async (id, data) => {
  const res = await api.put(`${BASE}/${id}`, data);
  return res.data.data;
};

export const deleteKependudukan = async (id) => {
  const res = await api.delete(`${BASE}/${id}`);
  return res.data;
};