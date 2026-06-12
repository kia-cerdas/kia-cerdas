import React from "react";
import EdukasiDigitalCrudPage from "./EdukasiDigitalCrudPage";

export default function PolaAsuhPage() {
  return (
    <EdukasiDigitalCrudPage
      title="Edukasi Pola Asuh"
      resourcePath="edukasi-pola-asuh"
      view="list"
      createPath="/edukasi-digital/pola-asuh/form"
    />
  );
}
