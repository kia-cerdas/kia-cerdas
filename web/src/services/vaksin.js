import api from "./api";

// Base path for puskesmas module (bidan_puskesmas & dokter)
const BASE = "/puskesmas";

// ==================== VAKSIN ====================

export async function getVaksinList(params = {}) {
  try {
    const response = await api.get(`${BASE}/vaksin`, { params });
    console.log("Response vaksin:", response.data);
    return response.data?.data ?? response.data ?? [];
  } catch (error) {
    console.error("Error fetching vaksin list:", error);
    throw error;
  }
}

export async function getVaksinById(id) {
  try {
    const response = await api.get(`${BASE}/vaksin/${id}`);
    return response.data?.data ?? response.data;
  } catch (error) {
    console.error("Error fetching vaksin detail:", error);
    throw error;
  }
}

export async function createVaksin(data) {
  const response = await api.post(`${BASE}/vaksin`, data);
  return response.data;
}

export async function updateVaksin(id, data) {
  const response = await api.put(`${BASE}/vaksin/${id}`, data);
  return response.data;
}

export async function deleteVaksin(id) {
  const response = await api.delete(`${BASE}/vaksin/${id}`);
  return response.data;
}

// ==================== DOSIS VAKSIN ====================

export async function getDosisVaksinList(params = {}) {
  try {
    const response = await api.get(`${BASE}/dosis-vaksin`, { params });
    return response.data?.data ?? response.data ?? [];
  } catch (error) {
    console.error("Error fetching dosis vaksin list:", error);
    throw error;
  }
}

export async function getDosisByVaksinId(vaksinId) {
  try {
    const response = await api.get(`${BASE}/dosis-vaksin/by-vaksin/${vaksinId}`);
    return response.data?.data ?? response.data ?? [];
  } catch (error) {
    console.error("Error fetching dosis by vaksin:", error);
    throw error;
  }
}

export async function createDosisVaksin(data) {
  const response = await api.post(`${BASE}/dosis-vaksin`, data);
  return response.data;
}

export async function updateDosisVaksin(id, data) {
  const response = await api.put(`${BASE}/dosis-vaksin/${id}`, data);
  return response.data;
}

export async function deleteDosisVaksin(id) {
  const response = await api.delete(`${BASE}/dosis-vaksin/${id}`);
  return response.data;
}
