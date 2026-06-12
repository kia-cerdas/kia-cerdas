import axios from "axios";

const API_URL = import.meta.env.VITE_API_URL || "http://localhost:8081";

export const getEdukasiMPASI = async () => {
    const response = await axios.get(`${API_URL}/tenaga-kesehatan/edukasi-mpasi`, {
        headers: { Authorization: `Bearer ${localStorage.getItem("access_token")}` }
    });
    return response.data;
};

export const getEdukasiMPASIById = async (id) => {
    const response = await axios.get(`${API_URL}/tenaga-kesehatan/edukasi-mpasi/${id}`, {
        headers: { Authorization: `Bearer ${localStorage.getItem("access_token")}` }
    });
    return response.data;
};

export const createEdukasiMPASI = async (data) => {
    const response = await axios.post(`${API_URL}/tenaga-kesehatan/edukasi-mpasi`, data, {
        headers: { Authorization: `Bearer ${localStorage.getItem("access_token")}` }
    });
    return response.data;
};

export const updateEdukasiMPASI = async (id, data) => {
    const response = await axios.put(`${API_URL}/tenaga-kesehatan/edukasi-mpasi/${id}`, data, {
        headers: { Authorization: `Bearer ${localStorage.getItem("access_token")}` }
    });
    return response.data;
};

export const deleteEdukasiMPASI = async (id) => {
    const response = await axios.delete(`${API_URL}/tenaga-kesehatan/edukasi-mpasi/${id}`, {
        headers: { Authorization: `Bearer ${localStorage.getItem("access_token")}` }
    });
    return response.data;
};
