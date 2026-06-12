import api from "./api";

const BASE_RUJUKAN = "/tenaga-kesehatan/rujukan";
const BASE_DM = "/tenaga-kesehatan/skrining-dm-gestasional";

// ==================== RUJUKAN ====================
export const getRujukanByKehamilanId = async (kehamilanId) => {
  const res = await api.get(`${BASE_RUJUKAN}?kehamilan_id=${kehamilanId}`);
  return res.data.data;
};
export const createRujukan = async (data) => {
  const res = await api.post(BASE_RUJUKAN, data);
  return res.data.data;
};
export const updateRujukan = async (id, data) => {
  const res = await api.put(`${BASE_RUJUKAN}/${id}`, data);
  return res.data.data;
};

// ==================== SKRINING DM GESTASIONAL ====================
export const getSkriningDMByKehamilanId = async (kehamilanId) => {
  const res = await api.get(`${BASE_DM}?kehamilan_id=${kehamilanId}`);
  return res.data.data;
};
export const createSkriningDM = async (data) => {
  const res = await api.post(BASE_DM, data);
  return res.data.data;
};
export const updateSkriningDM = async (id, data) => {
  const res = await api.put(`${BASE_DM}/${id}`, data);
  return res.data.data;
};
