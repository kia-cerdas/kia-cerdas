import api from './api';

// === Rencana Persalinan ===
export const getRencanaByKehamilanId = async (kehamilanId) => {
  const response = await api.get('/tenaga-kesehatan/rencana-persalinan', {
    params: { kehamilan_id: kehamilanId }
  });
  return response.data.data; // array
};

export const getRencanaById = async (id) => {
  if (!id) throw new Error('ID rencana tidak valid');
  const response = await api.get(`/tenaga-kesehatan/rencana-persalinan/${id}`);
  return response.data.data;
};

export const createRencana = async (data) => {
  const response = await api.post('/tenaga-kesehatan/rencana-persalinan', data);
  return response;
};

export const updateRencana = async (id, data) => {
  const response = await api.put(`/tenaga-kesehatan/rencana-persalinan/${id}`, data);
  return response;
};

// 🔥 Fungsi baru untuk menghapus rencana persalinan
export const deleteRencana = async (id) => {
  const response = await api.delete(`/tenaga-kesehatan/rencana-persalinan/${id}`);
  return response.data;
};

// === (Opsional) Riwayat, Ringkasan, Keterangan ===
export const getRiwayatByKehamilanId = async (kehamilanId) => {
  const response = await api.get('/tenaga-kesehatan/riwayat-proses-melahirkan', {
    params: { kehamilan_id: kehamilanId }
  });
  return response.data.data;
};
export const createRiwayat = async (data) => api.post('/tenaga-kesehatan/riwayat-proses-melahirkan', data);
export const updateRiwayat = async (id, data) => api.put(`/tenaga-kesehatan/riwayat-proses-melahirkan/${id}`, data);

export const getRingkasanByKehamilanId = async (kehamilanId) => {
  const response = await api.get('/tenaga-kesehatan/ringkasan-persalinan', {
    params: { kehamilan_id: kehamilanId }
  });
  return response.data.data;
};
export const createRingkasan = async (data) => api.post('/tenaga-kesehatan/ringkasan-persalinan', data);
export const updateRingkasan = async (id, data) => api.put(`/tenaga-kesehatan/ringkasan-persalinan/${id}`, data);

export const getKeteranganByIbuId = async (ibuId) => {
  const response = await api.get('/tenaga-kesehatan/keterangan-lahir', {
    params: { ibu_id: ibuId }
  });
  return response.data.data;
};
export const createKeterangan = async (data) => api.post('/tenaga-kesehatan/keterangan-lahir', data);
export const updateKeterangan = async (id, data) => api.put(`/tenaga-kesehatan/keterangan-lahir/${id}`, data);
