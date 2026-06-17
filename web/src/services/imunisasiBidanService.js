import api from "./api";

// ============================================
// GET DATA IMUNISASI
// ============================================

export async function getImunisasiByAnakId(anakId) {
  try {
    const response = await api.get(`/bidan/imunisasi/anak/${anakId}`);
    return response.data?.data ?? response.data ?? [];
  } catch (error) {
    console.error("Error fetching jadwal imunisasi:", error);
    throw error;
  }
}

// ============================================
// MARK JADWAL SELESAI (existing endpoint)
// ============================================

export async function setJadwalSelesai(jadwalId) {
  try {
    const response = await api.put(`/bidan/imunisasi/${jadwalId}/selesai`);
    return response.data?.data ?? response.data;
  } catch (error) {
    console.error("Error set jadwal selesai:", error);
    throw error;
  }
}

// ============================================
// MARK PENCATATAN SELESAI (new table)
// ============================================

export async function setPencatatanSelesai(pencatatanId) {
  try {
    const response = await api.put(`/bidan/pencatatan-imunisasi/${pencatatanId}/selesai`);
    return response.data?.data ?? response.data;
  } catch (error) {
    console.error("Error set pencatatan selesai:", error);
    throw error;
  }
}

// ============================================
// CREATE PENCATATAN IMUNISASI (via pencatatan_imunisasi table)
// ============================================

export async function createPelayananImunisasi(data) {
  try {
    const response = await api.post('/bidan/pencatatan-imunisasi', data);
    return response.data?.data ?? response.data;
  } catch (error) {
    console.error("Error creating pencatatan imunisasi:", error);
    throw error;
  }
}

// ============================================
// GET PENCATATAN IMUNISASI BY ANAK ID
// ============================================

export async function getPencatatanByAnakId(anakId) {
  try {
    const response = await api.get(`/bidan/pencatatan-imunisasi/anak/${anakId}`);
    return response.data?.data ?? response.data ?? [];
  } catch (error) {
    console.error("Error fetching pencatatan imunisasi:", error);
    return [];
  }
}

// ============================================
// GET ATURAN VAKSIN ANAK (untuk color coding)
// ============================================

export async function getAturanVaksinAnak() {
  try {
    const response = await api.get('/bidan/aturan-vaksin-anak');
    return response.data?.data ?? response.data ?? [];
  } catch (error) {
    console.error("Error fetching aturan vaksin:", error);
    // Return empty array jika endpoint belum ada
    return [];
  }
}

// ============================================
// BATAL PARAF IMUNISASI (cancel)
// ============================================

export async function batalParafImunisasi(jadwalId) {
  try {
    const response = await api.put(`/bidan/imunisasi/${jadwalId}/batal-paraf`);
    return response.data?.data ?? response.data;
  } catch (error) {
    console.error("Error batal paraf imunisasi:", error);
    throw error;
  }
}