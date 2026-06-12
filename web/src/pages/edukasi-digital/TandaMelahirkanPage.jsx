import React from "react";
import EdukasiDigitalCrudPage from "./EdukasiDigitalCrudPage";

export default function TandaMelahirkanPage() {
  return (
    <EdukasiDigitalCrudPage
      title="Edukasi Tanda Melahirkan"
      resourcePath="edukasi-tanda-melahirkan"
      view="list"
      createPath="/edukasi-digital/tanda-melahirkan/form"
    />
  );
}
