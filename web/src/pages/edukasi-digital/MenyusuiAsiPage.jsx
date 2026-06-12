import React from "react";
import EdukasiDigitalCrudPage from "./EdukasiDigitalCrudPage";

export default function MenyusuiAsiPage() {
  return (
    <EdukasiDigitalCrudPage
      title="Edukasi Menyusui & ASI"
      resourcePath="edukasi-menyusui-asi"
      view="list"
      createPath="/edukasi-digital/menyusui-asi/form"
    />
  );
}
