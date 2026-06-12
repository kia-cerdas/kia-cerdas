import axios from "axios";

const API_BASE_URL = import.meta.env.VITE_API_URL || "http://localhost:8000";

export async function getResepMPASIList() {
  try {
    const response = await axios.get(`${API_BASE_URL}/tenaga-kesehatan/edukasi-mpasi-resep`, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem("token")}`,
      },
    });
    return response.data || [];
  } catch (error) {
    console.error("Error fetching resep MPASI list:", error);
    return [];
  }
}

export async function getResepMPASIById(id) {
  try {
    const response = await axios.get(`${API_BASE_URL}/tenaga-kesehatan/edukasi-mpasi-resep/${id}`, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem("token")}`,
      },
    });
    return response.data;
  } catch (error) {
    console.error(`Error fetching resep MPASI #${id}:`, error);
    throw error;
  }
}

export async function createResepMPASI(data) {
  try {
    const response = await axios.post(`${API_BASE_URL}/tenaga-kesehatan/edukasi-mpasi-resep`, data, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem("token")}`,
      },
    });
    return response.data;
  } catch (error) {
    console.error("Error creating resep MPASI:", error);
    throw error;
  }
}

export async function updateResepMPASI(id, data) {
  try {
    const response = await axios.put(`${API_BASE_URL}/tenaga-kesehatan/edukasi-mpasi-resep/${id}`, data, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem("token")}`,
      },
    });
    return response.data;
  } catch (error) {
    console.error(`Error updating resep MPASI #${id}:`, error);
    throw error;
  }
}

export async function deleteResepMPASI(id) {
  try {
    const response = await axios.delete(`${API_BASE_URL}/tenaga-kesehatan/edukasi-mpasi-resep/${id}`, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem("token")}`,
      },
    });
    return response.data;
  } catch (error) {
    console.error(`Error deleting resep MPASI #${id}:`, error);
    throw error;
  }
}
