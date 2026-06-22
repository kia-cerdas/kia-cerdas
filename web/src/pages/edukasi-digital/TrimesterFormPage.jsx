import React from "react";
import EdukasiDigitalCrudPage from "./EdukasiDigitalCrudPage";

export default function TrimesterFormPage() {
  return (
    <EdukasiDigitalCrudPage
      title="Form Edukasi Trimester"
      resourcePath="edukasi-trimester"
      view="form"
      listPath="/edukasi-digital/trimester"
      fields={[
        { key: "judul", label: "Judul", type: "text" },
        { key: "gambar_url", label: "Gambar (opsional)", type: "image" },
        { key: "isi", label: "Isi konten", type: "textarea", rows: 6 },
      ]}
    />
  );
}
