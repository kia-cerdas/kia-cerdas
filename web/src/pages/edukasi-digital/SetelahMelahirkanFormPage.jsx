import React from "react";
import EdukasiDigitalCrudPage from "./EdukasiDigitalCrudPage";

export default function SetelahMelahirkanFormPage() {
  return (
    <EdukasiDigitalCrudPage
      title="Form Edukasi Setelah Melahirkan"
      resourcePath="edukasi-setelah-melahirkan"
      view="form"
      listPath="/edukasi-digital/setelah-melahirkan"
      fields={[
        { key: "judul", label: "Judul", type: "text" },
        { key: "gambar_url", label: "URL gambar (opsional)", type: "text" },
        { key: "isi", label: "Isi konten", type: "textarea", rows: 6 },
      ]}
    />
  );
}
