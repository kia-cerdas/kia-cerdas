import api from "./api";

const BASE = "/tenaga-kesehatan/grafik-evaluasi-kehamilan";

//
// 🔹 DATA TABLE (CRUD utama)
//
export const getGrafikByKehamilanId = async (kehamilanId) => {
  const res = await api.get(BASE, {
    params: { kehamilan_id: kehamilanId },
  });
  return res.data.data;
};

//
// 🔹 DATA CHART (KHUSUS GRAFIK KIA)
//
export const getGrafikChart = async (kehamilanId) => {
  const res = await api.get(`${BASE}/grafik`, {
    params: { kehamilan_id: kehamilanId },
  });

  return res.data.data;
};

//
// 🔹 CREATE
//
export const createGrafik = async (data) => {
  const res = await api.post(BASE, data);
  return res.data.data;
};

//
// 🔹 UPDATE
//
export const updateGrafik = async (id, data) => {
  const res = await api.put(`${BASE}/${id}`, data);
  return res.data.data;
};