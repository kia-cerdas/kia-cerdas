import api from "./api";

export const getKategoriLingkungan = async () => {
    const res = await api.get("/lingkungan/kategori");
    return res.data?.data || [];
};

export const createKategoriLingkungan = async (data) => {
    const res = await api.post("/tenaga-kesehatan/lingkungan/kategori", data);
    return res.data;
};

export const deleteKategoriLingkungan = async (id) => {
    const res = await api.delete(`/tenaga-kesehatan/lingkungan/kategori/${id}`);
    return res.data;
};

export const addIndikatorLingkungan = async (kategoriId, data) => {
    const res = await api.post(`/tenaga-kesehatan/lingkungan/kategori/${kategoriId}/indikator`, data);
    return res.data;
};

export const deleteIndikatorLingkungan = async (id) => {
    const res = await api.delete(`/tenaga-kesehatan/lingkungan/indikator/${id}`);
    return res.data;
};

export const getLingkunganHistory = async (ibuId = null) => {
    const url = ibuId ? `/lingkungan/history?ibu_id=${ibuId}` : "/lingkungan/history";
    const res = await api.get(url);
    return res.data?.data || [];
};

export const getLingkunganDetail = async (id) => {
    const res = await api.get(`/lingkungan/detail/${id}`);
    return res.data?.data;
};

export const submitLingkungan = async (data) => {
    const res = await api.post("/lingkungan/submit", data);
    return res.data;
};

export const deleteLingkungan = async (id) => {
    const res = await api.delete(`/tenaga-kesehatan/lingkungan/${id}`);
    return res.data;
};
