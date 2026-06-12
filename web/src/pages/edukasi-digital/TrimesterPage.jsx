import React from "react";
import EdukasiDigitalCrudPage from "./EdukasiDigitalCrudPage";

export default function TrimesterPage() {
  return (
    <EdukasiDigitalCrudPage
      title="Edukasi Trimester"
      resourcePath="edukasi-trimester"
      view="list"
      createPath="/edukasi-digital/trimester/form"
    />
  );
}
