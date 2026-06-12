import api from "./api";

export async function getJadwalLayananList(params = {}) {
  try {
    const response = await api.get(`/bidan/dashboard/jadwal-layanan`, { params });
    // support both direct array or paginated { data: [...] }
    return response.data?.data ?? response.data ?? [];
  } catch (error) {
    console.error("Error fetching jadwal layanan list:", error);
    throw error;
  }
}

export async function getJadwalLayananById(id) {
  try {
    const response = await api.get(`/bidan/dashboard/jadwal-layanan/${id}`);
    return response.data?.data ?? response.data;
  } catch (error) {
    console.error(`Error fetching jadwal layanan #${id}:`, error);
    throw error;
  }
}

export async function createJadwalLayanan(data) {
  try {
    const response = await api.post(`/bidan/dashboard/jadwal-layanan`, data);
    return response.data?.data ?? response.data;
  } catch (error) {
    console.error("Error creating jadwal layanan:", error);
    throw error;
  }
}

export async function updateJadwalLayanan(id, data) {
  try {
    const response = await api.put(`/bidan/dashboard/jadwal-layanan/${id}`, data);
    return response.data?.data ?? response.data;
  } catch (error) {
    console.error(`Error updating jadwal layanan #${id}:`, error);
    throw error;
  }
}

export async function deleteJadwalLayanan(id) {
  try {
    const response = await api.delete(`/bidan/dashboard/jadwal-layanan/${id}`);
    return response.data?.data ?? response.data;
  } catch (error) {
    console.error(`Error deleting jadwal layanan #${id}:`, error);
    throw error;
  }
}
