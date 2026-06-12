import React from "react";
import EdukasiDigitalCrudPage from "./EdukasiDigitalCrudPage";

export default function InformasiUmumFormPage() {
  return (
    <EdukasiDigitalCrudPage
      title="Form Edukasi Informasi Umum"
      resourcePath="edukasi-informasi-umum"
      view="form"
      listPath="/edukasi-digital/informasi-umum"
      fields={[
        { key: "tipe", label: "Tipe", type: "select", options: [
          { label: "Tips", value: "tips" },
          { label: "Panduan", value: "panduan" },
          { label: "Artikel", value: "artikel" },
          { label: "Edukasi", value: "edukasi" },
        ] },
        { key: "judul", label: "Judul", type: "text" },
        { key: "umur_target", label: "Umur Target (opsional)", type: "text" },
        { key: "durasi_baca", label: "Durasi Baca (opsional)", type: "text" },
        { key: "ringkasan", label: "Ringkasan", type: "textarea", rows: 2 },
        { key: "konten", label: "Konten", type: "textarea", rows: 6 },
        { key: "yang_perlu_diingat", label: "Yang Perlu Diingat", type: "textarea", rows: 2 },
        { key: "thumbnail_url", label: "URL Thumbnail (opsional)", type: "text" },
        { key: "is_active", label: "Aktif", type: "checkbox", default: true },
      ]}
    />
  );
}
