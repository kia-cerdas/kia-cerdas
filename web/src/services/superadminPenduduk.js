import api from "./api";

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

export const listPendudukForDropdown = async (params = {}) => {
  const response = await api.get("/superadmin/penduduk", { params });
  return response.data.data || [];
};

export const superadminPendudukErrorMessage = extractApiError;