import api from "./api";

export async function getDosisVaksinList(params = {}) {
  try {
    const response = await api.get(`/bidan/dosis-vaksin`, { params });
    return response.data?.data ?? response.data ?? [];
  } catch (error) {
    console.error("Error fetching dosis vaksin list:", error);
    throw error;
  }
}