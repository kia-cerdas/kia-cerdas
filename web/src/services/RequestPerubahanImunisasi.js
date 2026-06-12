import api from "./api";

export const getAllRequestPerubahanImunisasi = async () => {
    const res = await api.get("/bidan/request-perubahan-jadwal-imunisasi");
    return res.data;
};

export const approveRequestPerubahanImunisasi = async (id) => {
    const res = await api.put(`/bidan/request-perubahan-jadwal-imunisasi/${id}/approve`);
    return res.data;
};

export const rejectRequestPerubahanImunisasi = async (id) => {
    const res = await api.put(`/bidan/request-perubahan-jadwal-imunisasi/${id}/reject`);
    return res.data;
};

