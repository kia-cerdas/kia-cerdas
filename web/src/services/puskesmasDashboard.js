import api from "./api";

const BASE = "/puskesmas";

const unwrap = (response) => response.data?.data ?? response.data;

// GET /puskesmas/dashboard — full multi-desa recap
export const getPuskesmasDashboard = async () => {
	const response = await api.get(`${BASE}/dashboard`);
	return unwrap(response);
};
