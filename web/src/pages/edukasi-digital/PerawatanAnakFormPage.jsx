import React from "react";
import EdukasiDigitalCrudPage from "./EdukasiDigitalCrudPage";

const RENTANG_USIA_OPTIONS = [
  "0-28 hari",
  "0-3 bulan",
  "3-6 bulan",
  "6-9 bulan",
  "9-12 bulan",
  "12-18 bulan",
  "18-24 bulan",
  "2-3 tahun",
  "3-4 tahun",
  "4-5 tahun",
  "5-6 tahun",
];

export default function PerawatanAnakFormPage() {
  return (
    <EdukasiDigitalCrudPage
      title="Form Edukasi Perawatan Anak"
      resourcePath="edukasi-perawatan-anak"
      view="form"
      listPath="/edukasi-digital/perawatan-anak"
      fields={[
        { key: "judul", label: "Judul", type: "text" },
        { 
          key: "rentang_usia", 
          label: "Rentang Usia", 
          type: "select",
          options: RENTANG_USIA_OPTIONS
        },
        { key: "gambar_url", label: "Gambar (opsional)", type: "image" },
        { key: "isi_konten", label: "Isi", type: "textarea", rows: 10 },
      ]}
    />
  );
}
