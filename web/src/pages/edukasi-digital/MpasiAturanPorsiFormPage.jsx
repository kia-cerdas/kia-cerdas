import React from "react";
import EdukasiDigitalCrudPage from "./EdukasiDigitalCrudPage";

const fields = [
  { key: "bulan_min", label: "Bulan Minimal", type: "number", required: true },
  { key: "bulan_max", label: "Bulan Maksimal", type: "number", required: true },
  { key: "tekstur", label: "Tekstur", type: "textarea", rows: 2, required: true },
  { key: "frekuensi", label: "Frekuensi", type: "textarea", rows: 2, required: true },
  { key: "porsi", label: "Porsi", type: "textarea", rows: 2, required: true },
];

export default function MpasiAturanPorsiFormPage() {
  return (
    <EdukasiDigitalCrudPage
      title="Form MPASI - Aturan Porsi"
      resourcePath="edukasi-mpasi-aturan-porsi"
      view="form"
      listPath="/edukasi-digital/mpasi-aturan-porsi"
      fields={fields}
    />
  );
}
