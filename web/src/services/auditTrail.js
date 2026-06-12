import api from "./api";

const BASE = "/superadmin/audit-trail";

const unwrap = (response) => response.data?.data ?? response.data;

const normalizeMessage = (message) => {
	if (Array.isArray(message)) {
		return message.join(", ");
	}
	return message || "";
};

const extractApiError = (error, fallbackMessage = "Terjadi kesalahan") => {
	const message = error?.response?.data?.message;
	const normalized = normalizeMessage(message);
	return normalized || fallbackMessage;
};

export const listAuditTrails = async (params = {}) => {
	const response = await api.get(BASE, { params });
	return unwrap(response);
};

export const getAuditTrailSummary = async (params = {}) => {
	const response = await api.get(`${BASE}/summary`, { params });
	return unwrap(response);
};

export const auditTrailErrorMessage = extractApiError;