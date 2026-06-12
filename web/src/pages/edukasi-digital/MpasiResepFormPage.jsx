import React from "react";
import EdukasiDigitalCrudPage from "./EdukasiDigitalCrudPage";

const fields = [
  { key: "bulan_min", label: "Bulan Minimal", type: "number", required: true },
  { key: "bulan_max", label: "Bulan Maksimal", type: "number", required: true },
  { key: "judul", label: "Judul Resep", type: "text", required: true },
  { key: "tipe", label: "Tipe Resep", type: "text", required: true },
  { key: "gambar_url", label: "URL Gambar", type: "text" },
  { key: "waktu_persiapan", label: "Waktu Persiapan (menit)", type: "number", required: true },
  { key: "kalori", label: "Kalori", type: "number", required: true },
  { key: "porsi", label: "Porsi", type: "text", required: true },
  {
    key: "bahan_bahan",
    label: "Bahan-bahan (satu baris satu item)",
    type: "array",
    rows: 5,
    required: true,
    placeholder: "Masukkan bahan (satu baris satu item)",
  },
  {
    key: "cara_membuat",
    label: "Cara Membuat (satu baris satu langkah)",
    type: "array",
    rows: 6,
    required: true,
    placeholder: "Masukkan langkah (satu baris satu langkah)",
  },
  { key: "manfaat", label: "Manfaat", type: "textarea", rows: 3 },
  { key: "tips", label: "Tips", type: "textarea", rows: 3 },
];

export default function MpasiResepFormPage() {
  return (
    <EdukasiDigitalCrudPage
      title="Form MPASI - Resep"
      resourcePath="edukasi-mpasi-resep"
      view="form"
      listPath="/edukasi-digital/mpasi-resep"
      fields={fields}
    />
  );
}
