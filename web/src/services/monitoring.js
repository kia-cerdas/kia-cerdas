import api from "./api";

export const getRekapWilayah = async () => {
  const res = await api.get("/tenaga-kesehatan/rekap-wilayah");
  return res.data.data;
};

export const getDaftarRisikoTinggi = async () => {
  const res = await api.get("/tenaga-kesehatan/risiko-tinggi");
  return res.data.data;
};

export const getPrioritasKunjungan = async () => {
  const res = await api.get("/tenaga-kesehatan/prioritas-kunjungan");
  return res.data.data;
};