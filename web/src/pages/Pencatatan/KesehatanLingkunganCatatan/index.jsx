import React from "react";
import MainLayout from "../../../components/Layout/MainLayout";
import KesehatanLingkunganCatatan from "../../../components/kesehatan-lingkungan-catatan/KesehatanLingkunganCatatan";

export default function KesehatanLingkunganCatatanPage() {
  return (
    <MainLayout>
      <div className="p-6">
        <KesehatanLingkunganCatatan />
      </div>
    </MainLayout>
  );
}
