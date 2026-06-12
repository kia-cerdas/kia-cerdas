import React from "react";
import EdukasiDigitalCrudPage from "./EdukasiDigitalCrudPage";

export default function InformasiUmumPage() {
  return (
    <EdukasiDigitalCrudPage
      title="Edukasi Informasi Umum"
      resourcePath="edukasi-informasi-umum"
      view="list"
      createPath="/edukasi-digital/informasi-umum/form"
    />
  );
}
