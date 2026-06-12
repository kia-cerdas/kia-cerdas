import React from "react";
import EdukasiDigitalCrudPage from "./EdukasiDigitalCrudPage";

export default function MpasiResepPage() {
  return (
    <EdukasiDigitalCrudPage
      title="MPASI - Resep"
      resourcePath="edukasi-mpasi-resep"
      view="inline"
      createPath="/edukasi-digital/mpasi-resep/form"
    />
  );
}
