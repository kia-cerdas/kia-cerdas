import api from "./api";

const BASE_T1 = "/tenaga-kesehatan/pemeriksaan-dokter-t1-complete";
const BASE_T3 = "/tenaga-kesehatan/pemeriksaan-dokter-t3-complete";

export const pemeriksaanDokterCompleteService = {
  // T1
  createT1: async (payload) => {
    const res = await api.post(BASE_T1, payload);
    return res.data;
  },
  updateT1: async (id, payload) => {
    const res = await api.put(`${BASE_T1}/${id}`, payload);
    return res.data;
  },
  getT1ByKehamilanId: async (kehamilanId) => {
    const res = await api.get(BASE_T1, { params: { kehamilan_id: kehamilanId } });
    return res.data.data;
  },
  getT1ById: async (id) => {
    const res = await api.get(`${BASE_T1}/${id}`);
    return res.data.data;
  },
  deleteT1: async (id) => {
    const res = await api.delete(`${BASE_T1}/${id}`);
    return res.data;
  },
  // T3
  createT3: async (payload) => {
    const res = await api.post(BASE_T3, payload);
    return res.data;
  },
  updateT3: async (id, payload) => {
    const res = await api.put(`${BASE_T3}/${id}`, payload);
    return res.data;
  },
  getT3ByKehamilanId: async (kehamilanId) => {
    const res = await api.get(BASE_T3, { params: { kehamilan_id: kehamilanId } });
    return res.data.data;
  },
  getT3ById: async (id) => {
    const res = await api.get(`${BASE_T3}/${id}`);
    return res.data.data;
  },
  deleteT3: async (id) => {
    const res = await api.delete(`${BASE_T3}/${id}`);
    return res.data;
  },
};