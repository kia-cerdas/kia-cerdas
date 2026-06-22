import api from "./api";

export const EDUKASI_RESOURCES = {
  informasiUmum: {
    key: "informasiUmum",
    label: "Informasi Umum",
    path: "edukasi-informasi-umum",
  },
  trimester: {
    key: "trimester",
    label: "Edukasi Trimester",
    path: "edukasi-trimester",
  },
  tandaMelahirkan: {
    key: "tandaMelahirkan",
    label: "Tanda Melahirkan",
    path: "edukasi-tanda-melahirkan",
  },
  imd: {
    key: "imd",
    label: "Edukasi IMD",
    path: "edukasi-imd",
  },
  setelahMelahirkan: {
    key: "setelahMelahirkan",
    label: "Setelah Melahirkan",
    path: "edukasi-setelah-melahirkan",
  },
  menyusuiAsi: {
    key: "menyusuiAsi",
    label: "Menyusui ASI",
    path: "edukasi-menyusui-asi",
  },
  polaAsuh: {
    key: "polaAsuh",
    label: "Pola Asuh",
    path: "edukasi-pola-asuh",
  },
  kesehatanMental: {
    key: "kesehatanMental",
    label: "Kesehatan Mental",
    path: "edukasi-kesehatan-mental",
  },
  perawatanAnak: {
    key: "perawatanAnak",
    label: "Perawatan Anak",
    path: "edukasi-perawatan-anak",
  },
  mpasi: {
    key: "mpasi",
    label: "Edukasi MPASI",
    path: "edukasi-mpasi",
  },
};

const unwrap = (res) => {
  const data = res?.data;
  if (Array.isArray(data)) return data;
  if (Array.isArray(data?.data)) return data.data;
  if (Array.isArray(data?.result)) return data.result;
  return data;
};

const basePath = (resourcePath) => `/tenaga-kesehatan/${resourcePath}`;

export const listEdukasi = async (resourcePath, params = {}) => {
  const queryString = new URLSearchParams(params).toString();
  const url = queryString ? `${basePath(resourcePath)}?${queryString}` : basePath(resourcePath);
  const res = await api.get(url);
  return unwrap(res) || [];
};

export const createEdukasi = async (resourcePath, payload) => {
  const res = await api.post(basePath(resourcePath), payload);
  return unwrap(res);
};

export const updateEdukasi = async (resourcePath, id, payload) => {
  const res = await api.put(`${basePath(resourcePath)}/${id}`, payload);
  return unwrap(res);
};

export const getEdukasiById = async (resourcePath, id) => {
  const res = await api.get(`${basePath(resourcePath)}/${id}`);
  return unwrap(res);
};

export const deleteEdukasi = async (resourcePath, id) => {
  const res = await api.delete(`${basePath(resourcePath)}/${id}`);
  return unwrap(res);
};

export const listPublicEdukasi = async (resourcePath, params = {}) => {
  const queryString = new URLSearchParams(params).toString();
  const url = queryString ? `/${resourcePath}?${queryString}` : `/${resourcePath}`;
  const res = await api.get(url);
  return unwrap(res) || [];
};

export const getPublicEdukasiById = async (resourcePath, id) => {
  const res = await api.get(`/${resourcePath}/${id}`);
  return unwrap(res);
};

