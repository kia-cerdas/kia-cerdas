import React from "react";
import EdukasiDigitalCrudPage from "./EdukasiDigitalCrudPage";

export default function KesehatanMentalFormPage() {
  return (
    <EdukasiDigitalCrudPage
      title="Form Edukasi Kesehatan Mental"
      resourcePath="edukasi-kesehatan-mental"
      view="form"
      listPath="/edukasi-digital/kesehatan-mental"
      fields={[
        { key: "judul", label: "Judul", type: "text" },
        { key: "gambar_url", label: "URL gambar (opsional)", type: "text" },
        { key: "isi", label: "Isi konten", type: "textarea", rows: 4 },
        { key: "tanda_gejala", label: "Tanda dan Gejala", type: "textarea", rows: 4 },
        { key: "solusi", label: "Solusi / Penanganan", type: "textarea", rows: 4 },
      ]}
    />
  );
}
