import React from "react";
import EdukasiDigitalCrudPage from "./EdukasiDigitalCrudPage";

export default function ImdPage() {
  return (
    <EdukasiDigitalCrudPage
      title="Edukasi IMD"
      resourcePath="edukasi-imd"
      view="list"
      createPath="/edukasi-digital/imd/form"
    />
  );
}
