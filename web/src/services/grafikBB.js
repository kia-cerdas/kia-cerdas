import api from "./api";

const BASE_BB = "/tenaga-kesehatan/grafik-peningkatan-bb";


// ==================== GRAFIK PENINGKATAN BERAT BADAN ====================
export const getGrafikBBByKehamilanId = async (kehamilanId) => {
  const res = await api.get(`${BASE_BB}?kehamilan_id=${kehamilanId}`);
  return res.data.data;
};

// ====Create ===== 
export const createGrafikBB = async (payload) => {
  const res = await api.post(BASE_BB, payload);
  return res.data.data;
};