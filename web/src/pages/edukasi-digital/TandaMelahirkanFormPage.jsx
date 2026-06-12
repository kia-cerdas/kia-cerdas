import React from "react";
import EdukasiDigitalCrudPage from "./EdukasiDigitalCrudPage";

export default function TandaMelahirkanFormPage() {
  return (
    <EdukasiDigitalCrudPage
      title="Form Edukasi Tanda Melahirkan"
      resourcePath="edukasi-tanda-melahirkan"
      view="form"
      listPath="/edukasi-digital/tanda-melahirkan"
      fields={[
        { key: "judul", label: "Judul", type: "text" },
        { key: "gambar_url", label: "URL gambar (opsional)", type: "text" },
        { key: "isi", label: "Isi konten", type: "textarea", rows: 4 },
        { key: "tanda", label: "Tanda-tanda Melahirkan", type: "textarea", rows: 4 },
        { key: "tindakan", label: "Tindakan yang perlu dilakukan", type: "textarea", rows: 4 },
      ]}
    />
  );
}
