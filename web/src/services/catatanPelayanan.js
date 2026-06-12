import api from "./api";

const BASE_T1 = "/tenaga-kesehatan/catatan-pelayanan-t1";
const BASE_T2 = "/tenaga-kesehatan/catatan-pelayanan-t2";
const BASE_T3 = "/tenaga-kesehatan/catatan-pelayanan-t3";
const BASE_NIFAS = "/tenaga-kesehatan/catatan-pelayanan-nifas";

// Helper generic
const makeService = (base) => ({
  getByKehamilanId: async (kehamilanId) => {
    const res = await api.get(`${base}?kehamilan_id=${kehamilanId}`);
    return res.data.data;
  },
  getById: async (id) => {
    const res = await api.get(`${base}/${id}`);
    return res.data.data;
  },
  create: async (data) => {
    const res = await api.post(base, data);
    return res.data.data;
  },
  update: async (id, data) => {
    const res = await api.put(`${base}/${id}`, data);
    return res.data.data;
  },
  delete: async (id) => {
    const res = await api.delete(`${base}/${id}`);
    return res.data;
  },
});

export const catatanT1 = makeService(BASE_T1);
export const catatanT2 = makeService(BASE_T2);
export const catatanT3 = makeService(BASE_T3);
export const catatanNifas = makeService(BASE_NIFAS);
