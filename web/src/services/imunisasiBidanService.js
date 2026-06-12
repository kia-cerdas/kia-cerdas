import api from "./api";

export async function getImunisasiByAnakId(anakId) {
  try {
    const response = await api.get(`/bidan/imunisasi/anak/${anakId}`);
    return response.data?.data ?? response.data ?? [];
  } catch (error) {
    console.error("Error fetching jadwal imunisasi:", error);
    throw error;
  }
}

export async function setJadwalSelesai(jadwalId) {
  try {
    const response = await api.put(`/bidan/imunisasi/${jadwalId}/selesai`);
    return response.data?.data ?? response.data;
  } catch (error) {
    console.error("Error set jadwal selesai:", error);
    throw error;
  }
}