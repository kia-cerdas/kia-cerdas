import api from "./api";

export const getKategoriUmurList = async () => {
  const response = await api.get("/tenaga-kesehatan/kategori-umur");
  const data = response.data;

  if (Array.isArray(data)) return data;
  if (Array.isArray(data?.data)) return data.data;
  return [];
};