import React from "react";
import EdukasiDigitalCrudPage from "./EdukasiDigitalCrudPage";

export default function PerawatanAnakPage() {
  return (
    <EdukasiDigitalCrudPage
      title="Edukasi Perawatan Anak"
      resourcePath="edukasi-perawatan-anak"
      view="list"
      createPath="/edukasi-digital/perawatan-anak/form"
    />
  );
}
