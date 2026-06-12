import React from "react";
import EdukasiDigitalCrudPage from "./EdukasiDigitalCrudPage";

export default function SetelahMelahirkanPage() {
  return (
    <EdukasiDigitalCrudPage
      title="Edukasi Setelah Melahirkan"
      resourcePath="edukasi-setelah-melahirkan"
      view="list"
      createPath="/edukasi-digital/setelah-melahirkan/form"
    />
  );
}
