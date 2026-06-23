import React from "react";
import EdukasiDigitalCrudPage from "./EdukasiDigitalCrudPage";

const fields = [
  { key: "judul", label: "Judul Edukasi MPASI", type: "text", required: true },
  { key: "konten", label: "Konten", type: "textarea", rows: 6, required: true },
  { key: "bulan_min", label: "Bulan Minimal", type: "number" },
  { key: "bulan_max", label: "Bulan Maksimal", type: "number" },
  { key: "gambar_url", label: "Gambar", type: "image" },
];

export default function MpasiFormPage() {
  return (
    <EdukasiDigitalCrudPage
      title="Form Edukasi MPASI"
      resourcePath="edukasi-mpasi"
      view="form"
      listPath="/edukasi-digital/mpasi"
      fields={fields}
    />
  );
}
