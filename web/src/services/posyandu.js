import api from "./api";

const BASE = "/superadmin/posyandu-manage";

const unwrap = (response) => response.data?.data ?? response.data;

export const getAllPosyandu = async (params = {}) => {
	const response = await api.get(BASE, { params });
	return unwrap(response);
};

export const getPosyanduById = async (id) => {
	const response = await api.get(`${BASE}/${id}`);
	return unwrap(response);
};

export const createPosyandu = async (data) => {
	const response = await api.post(BASE, data);
	return unwrap(response);
};

export const updatePosyandu = async (id, data) => {
	const response = await api.put(`${BASE}/${id}`, data);
	return unwrap(response);
};

export const deletePosyandu = async (id) => {
	const response = await api.delete(`${BASE}/${id}`);
	return unwrap(response);
};
