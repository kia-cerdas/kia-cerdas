import api from "./api";

const BASE = "/superadmin/puskesmas";

const unwrap = (response) => response.data?.data ?? response.data;

export const getAllPuskesmas = async () => {
	const response = await api.get(BASE);
	return unwrap(response);
};

export const getPuskesmasById = async (id) => {
	const response = await api.get(`${BASE}/${id}`);
	return unwrap(response);
};

export const createPuskesmas = async (data) => {
	const response = await api.post(BASE, data);
	return unwrap(response);
};

export const updatePuskesmas = async (id, data) => {
	const response = await api.put(`${BASE}/${id}`, data);
	return unwrap(response);
};

export const deletePuskesmas = async (id) => {
	const response = await api.delete(`${BASE}/${id}`);
	return unwrap(response);
};
