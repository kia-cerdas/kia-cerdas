import React from "react";
import EdukasiDigitalCrudPage from "./EdukasiDigitalCrudPage";

export default function KesehatanMentalPage() {
  return (
    <EdukasiDigitalCrudPage
      title="Edukasi Kesehatan Mental"
      resourcePath="edukasi-kesehatan-mental"
      view="list"
      createPath="/edukasi-digital/kesehatan-mental/form"
    />
  );
}
