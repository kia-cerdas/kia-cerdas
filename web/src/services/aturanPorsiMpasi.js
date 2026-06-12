import axios from "axios";

const API_BASE_URL = import.meta.env.VITE_API_URL || "http://localhost:8000";

export async function getAturanPorsiMPASIList() {
  try {
    const response = await axios.get(`${API_BASE_URL}/tenaga-kesehatan/edukasi-mpasi-aturan-porsi`, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem("token")}`,
      },
    });
    return response.data || [];
  } catch (error) {
    console.error("Error fetching aturan porsi MPASI list:", error);
    return [];
  }
}

export async function getAturanPorsiMPASIById(id) {
  try {
    const response = await axios.get(`${API_BASE_URL}/tenaga-kesehatan/edukasi-mpasi-aturan-porsi/${id}`, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem("token")}`,
      },
    });
    return response.data;
  } catch (error) {
    console.error(`Error fetching aturan porsi MPASI #${id}:`, error);
    throw error;
  }
}

export async function createAturanPorsiMPASI(data) {
  try {
    const response = await axios.post(`${API_BASE_URL}/tenaga-kesehatan/edukasi-mpasi-aturan-porsi`, data, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem("token")}`,
      },
    });
    return response.data;
  } catch (error) {
    console.error("Error creating aturan porsi MPASI:", error);
    throw error;
  }
}

export async function updateAturanPorsiMPASI(id, data) {
  try {
    const response = await axios.put(`${API_BASE_URL}/tenaga-kesehatan/edukasi-mpasi-aturan-porsi/${id}`, data, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem("token")}`,
      },
    });
    return response.data;
  } catch (error) {
    console.error(`Error updating aturan porsi MPASI #${id}:`, error);
    throw error;
  }
}

export async function deleteAturanPorsiMPASI(id) {
  try {
    const response = await axios.delete(`${API_BASE_URL}/tenaga-kesehatan/edukasi-mpasi-aturan-porsi/${id}`, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem("token")}`,
      },
    });
    return response.data;
  } catch (error) {
    console.error(`Error deleting aturan porsi MPASI #${id}:`, error);
    throw error;
  }
}
