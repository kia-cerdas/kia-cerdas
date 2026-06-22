import api from "./api";

const normalizeMessage = (message) => {
  if (Array.isArray(message)) return message.join(", ");
  return message || "";
};

const extractApiError = (error, fallbackMessage = "Terjadi kesalahan") => {
  const message = error?.response?.data?.message;
  return normalizeMessage(message) || fallbackMessage;
};

/**
 * Ambil semua penduduk dari /superadmin/penduduk dengan auto-pagination.
 * Backend membatasi max 100 per request, jadi kita loop sampai habis.
 */
export const listPendudukForDropdown = async (params = {}) => {
  const PAGE_SIZE = 100;
  let page = 1;
  let allItems = [];

  while (true) {
    const response = await api.get("/superadmin/penduduk", {
      params: { ...params, page, limit: PAGE_SIZE },
    });

    const data = response.data?.data;

    // Response format: { items: [...], pagination: { total_pages, ... } }
    const items = Array.isArray(data?.items) ? data.items
      : Array.isArray(data) ? data
      : [];

    allItems = allItems.concat(items);

    const totalPages = data?.pagination?.total_pages ?? 1;
    if (page >= totalPages || items.length === 0) break;
    page++;
  }

  return allItems;
};

export const superadminPendudukErrorMessage = extractApiError;
