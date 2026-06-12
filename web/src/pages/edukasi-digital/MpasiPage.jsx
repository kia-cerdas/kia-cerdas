import React from "react";
import EdukasiDigitalCrudPage from "./EdukasiDigitalCrudPage";

export default function MpasiPage() {
  return (
    <EdukasiDigitalCrudPage
      title="Edukasi MPASI"
      resourcePath="edukasi-mpasi"
      view="list"
      createPath="/edukasi-digital/mpasi/form"
    />
  );
}
