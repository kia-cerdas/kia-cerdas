import api from "./api";

export const previewLaporanIbu = async (bulan, tahun) => {
  let url = "/tenaga-kesehatan/laporan/ibu/preview";
  if (bulan && tahun) {
    url += `?bulan=${bulan}&tahun=${tahun}`;
  }
  const response = await api.get(url);
  return response.data; // asumsikan { data: [...] }
};

export const exportLaporanIbu = async (bulan, tahun) => {
  let url = "/tenaga-kesehatan/laporan/ibu/export/excel";
  if (bulan && tahun) {
    url += `?bulan=${bulan}&tahun=${tahun}`;
  }
  const response = await api.get(url, {
    responseType: "blob",
  });
  return response.data;
};

// Laporan anak
export const previewLaporanAnak = async (startDate, endDate) => {
  let url = "/tenaga-kesehatan/laporan/anak/preview";
  if (startDate && endDate) {
    url += `?start_date=${startDate}&end_date=${endDate}`;
  }
  const response = await api.get(url);
  return response.data;
};

export const exportLaporanAnak = async (startDate, endDate) => {
  let url = "/tenaga-kesehatan/laporan/anak/export/excel";
  if (startDate && endDate) {
    url += `?start_date=${startDate}&end_date=${endDate}`;
  }
  const res = await api.get(url, {
    responseType: "blob",
  });
  return res.data;
};

// Laporan remaja
export const previewLaporanRemaja = async (startDate, endDate) => {
  let url = "/tenaga-kesehatan/laporan/remaja/preview";
  if (startDate && endDate) {
    url += `?start_date=${startDate}&end_date=${endDate}`;
  }
  const response = await api.get(url);
  return response.data;
};

export const exportLaporanRemaja = async (startDate, endDate) => {
  let url = "/tenaga-kesehatan/laporan/remaja/export/excel";
  if (startDate && endDate) {
    url += `?start_date=${startDate}&end_date=${endDate}`;
  }
  const res = await api.get(url, {
    responseType: "blob",
  });
  return res.data;
};

// Laporan dewasa
export const previewLaporanDewasa = async (startDate, endDate) => {
  let url = "/tenaga-kesehatan/laporan/dewasa/preview";
  if (startDate && endDate) {
    url += `?start_date=${startDate}&end_date=${endDate}`;
  }
  const response = await api.get(url);
  return response.data;
};

export const exportLaporanDewasa = async (startDate, endDate) => {
  let url = "/tenaga-kesehatan/laporan/dewasa/export/excel";
  if (startDate && endDate) {
    url += `?start_date=${startDate}&end_date=${endDate}`;
  }
  const res = await api.get(url, {
    responseType: "blob",
  });
  return res.data;
};

// Laporan lansia
export const previewLaporanLansia = async (startDate, endDate) => {
  let url = "/tenaga-kesehatan/laporan/lansia/preview";
  if (startDate && endDate) {
    url += `?start_date=${startDate}&end_date=${endDate}`;
  }
  const response = await api.get(url);
  return response.data;
};

export const exportLaporanLansia = async (startDate, endDate) => {
  let url = "/tenaga-kesehatan/laporan/lansia/export/excel";
  if (startDate && endDate) {
    url += `?start_date=${startDate}&end_date=${endDate}`;
  }
  const res = await api.get(url, {
    responseType: "blob",
  });
  return res.data;
};