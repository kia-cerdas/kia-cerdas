import React from "react";
import EdukasiDigitalCrudPage from "./EdukasiDigitalCrudPage";

export default function MenyusuiAsiFormPage() {
  return (
    <EdukasiDigitalCrudPage
      title="Form Edukasi Menyusui ASI"
      resourcePath="edukasi-menyusui-asi"
      view="form"
      listPath="/edukasi-digital/menyusui-asi"
      fields={[
        { key: "judul", label: "Judul", type: "text" },
        { key: "gambar_url", label: "URL gambar (opsional)", type: "text" },
        { key: "isi", label: "Isi / Deskripsi Umum", type: "textarea", rows: 4 },
        { key: "manfaat_asi", label: "Manfaat ASI", type: "textarea", rows: 4 },
        { key: "cara", label: "Cara Menyusui yang Benar", type: "textarea", rows: 4 },
        { key: "masalah", label: "Masalah yang Sering Terjadi", type: "textarea", rows: 4 },
        { key: "solusi", label: "Solusi / Penanganan", type: "textarea", rows: 4 },
      ]}
    />
  );
}
