import React from "react";
import EdukasiDigitalCrudPage from "./EdukasiDigitalCrudPage";

export default function ImdFormPage() {
  return (
    <EdukasiDigitalCrudPage
      title="Form Edukasi IMD"
      resourcePath="edukasi-imd"
      view="form"
      listPath="/edukasi-digital/imd"
      fields={[
        { key: "judul", label: "Judul", type: "text" },
        { key: "gambar_url", label: "URL gambar (opsional)", type: "text" },
        { key: "isi", label: "Isi / Deskripsi Umum", type: "textarea", rows: 4 },
        { key: "manfaat", label: "Manfaat IMD", type: "textarea", rows: 4 },
        { key: "langkah", label: "Langkah-langkah IMD", type: "textarea", rows: 4 },
      ]}
    />
  );
}
