import React from "react";
import EdukasiDigitalCrudPage from "./EdukasiDigitalCrudPage";

export default function MpasiAturanPorsiPage() {
  return (
    <EdukasiDigitalCrudPage
      title="MPASI - Aturan Porsi"
      resourcePath="edukasi-mpasi-aturan-porsi"
      view="inline"
      createPath="/edukasi-digital/mpasi-aturan-porsi/form"
    />
  );
}
