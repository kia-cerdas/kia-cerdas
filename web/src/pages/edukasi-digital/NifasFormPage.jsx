import React from "react";
import EdukasiDigitalCrudPage from "./EdukasiDigitalCrudPage";

export default function NifasFormPage() {
  return (
    <EdukasiDigitalCrudPage
      title="Form Edukasi Nifas"
      resourcePath="edukasi-nifas"
      view="form"
      listPath="/edukasi-digital/nifas"
      fields={[
        { key: "judul", label: "Judul", type: "text" },
        { key: "gambar_url", label: "URL gambar (opsional)", type: "text" },
        { key: "isi", label: "Isi / Deskripsi Umum", type: "textarea", rows: 4 },
        { key: "perawatan", label: "Perawatan Masa Nifas", type: "textarea", rows: 4 },
        { key: "tanda_bahaya", label: "Tanda Bahaya Nifas", type: "textarea", rows: 4 },
      ]}
    />
  );
}
