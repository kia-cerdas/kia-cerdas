import api from "./api";

export async function getVaksinList(params = {}) {
  try {
    // Tambahkan prefix /bidan seperti di jadwalLayanan.js
    const response = await api.get(`/bidan/vaksin`, { params });
    console.log("Response vaksin:", response.data);
    return response.data?.data ?? response.data ?? [];
  } catch (error) {
    console.error("Error fetching vaksin list:", error);
    throw error;
  }
}