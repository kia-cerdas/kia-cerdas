import axios from "axios";

const API_BASE_URL = import.meta.env.VITE_API_URL || "http://localhost:8000";

export async function getJadwalHarianMPASIList() {
  try {
    const response = await axios.get(`${API_BASE_URL}/tenaga-kesehatan/edukasi-mpasi-jadwal-harian`, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem("token")}`,
      },
    });
    return response.data || [];
  } catch (error) {
    console.error("Error fetching jadwal harian MPASI list:", error);
    return [];
  }
}

export async function getJadwalHarianMPASIById(id) {
  try {
    const response = await axios.get(`${API_BASE_URL}/tenaga-kesehatan/edukasi-mpasi-jadwal-harian/${id}`, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem("token")}`,
      },
    });
    return response.data;
  } catch (error) {
    console.error(`Error fetching jadwal harian MPASI #${id}:`, error);
    throw error;
  }
}

export async function createJadwalHarianMPASI(data) {
  try {
    const response = await axios.post(`${API_BASE_URL}/tenaga-kesehatan/edukasi-mpasi-jadwal-harian`, data, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem("token")}`,
      },
    });
    return response.data;
  } catch (error) {
    console.error("Error creating jadwal harian MPASI:", error);
    throw error;
  }
}

export async function updateJadwalHarianMPASI(id, data) {
  try {
    const response = await axios.put(`${API_BASE_URL}/tenaga-kesehatan/edukasi-mpasi-jadwal-harian/${id}`, data, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem("token")}`,
      },
    });
    return response.data;
  } catch (error) {
    console.error(`Error updating jadwal harian MPASI #${id}:`, error);
    throw error;
  }
}

export async function deleteJadwalHarianMPASI(id) {
  try {
    const response = await axios.delete(`${API_BASE_URL}/tenaga-kesehatan/edukasi-mpasi-jadwal-harian/${id}`, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem("token")}`,
      },
    });
    return response.data;
  } catch (error) {
    console.error(`Error deleting jadwal harian MPASI #${id}:`, error);
    throw error;
  }
}
