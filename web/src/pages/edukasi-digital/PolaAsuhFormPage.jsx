import React from "react";
import EdukasiDigitalCrudPage from "./EdukasiDigitalCrudPage";

const RENTANG_USIA_OPTIONS = [
  "0-18 Bulan",
  "1.5 Tahun - 3 Tahun",
  "3 tahun - 6 Tahun",
];

export default function PolaAsuhFormPage() {
  return (
    <EdukasiDigitalCrudPage
      title="Form Edukasi Pola Asuh"
      resourcePath="edukasi-pola-asuh"
      view="form"
      listPath="/edukasi-digital/pola-asuh"
      fields={[
        { key: "judul", label: "Judul", type: "text" },
        { 
          key: "rentang_usia", 
          label: "Rentang Usia", 
          type: "select",
          options: RENTANG_USIA_OPTIONS
        },
        { key: "gambar_url", label: "Gambar", type: "image" },
        { key: "isi", label: "Isi konten", type: "textarea", rows: 6 },
      ]}
    />
  );
}
