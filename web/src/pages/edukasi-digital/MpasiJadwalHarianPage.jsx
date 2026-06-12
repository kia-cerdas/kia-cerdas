import React from "react";
import EdukasiDigitalCrudPage from "./EdukasiDigitalCrudPage";

export default function MpasiJadwalHarianPage() {
  return (
    <EdukasiDigitalCrudPage
      title="MPASI - Jadwal Harian"
      resourcePath="edukasi-mpasi-jadwal-harian"
      view="inline"
      createPath="/edukasi-digital/mpasi-jadwal-harian/form"
    />
  );
}
