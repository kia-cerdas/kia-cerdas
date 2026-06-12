import React from "react";
import EdukasiDigitalCrudPage from "./EdukasiDigitalCrudPage";

export default function NifasPage() {
  return (
    <EdukasiDigitalCrudPage
      title="Edukasi Nifas"
      resourcePath="edukasi-nifas"
      view="list"
      createPath="/edukasi-digital/nifas/form"
    />
  );
}
