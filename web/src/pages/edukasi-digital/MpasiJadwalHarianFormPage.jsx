import React from "react";
import EdukasiDigitalCrudPage from "./EdukasiDigitalCrudPage";

const fields = [
  { key: "bulan_min", label: "Bulan Minimal", type: "number", required: true },
  { key: "bulan_max", label: "Bulan Maksimal", type: "number", required: true },
  { key: "waktu", label: "Waktu (contoh: 08:00)", type: "text", required: true },
  { key: "aktivitas", label: "Aktivitas", type: "text", required: true },
];

export default function MpasiJadwalHarianFormPage() {
  return (
    <EdukasiDigitalCrudPage
      title="Form MPASI - Jadwal Harian"
      resourcePath="edukasi-mpasi-jadwal-harian"
      view="form"
      listPath="/edukasi-digital/mpasi-jadwal-harian"
      fields={fields}
    />
  );
}
