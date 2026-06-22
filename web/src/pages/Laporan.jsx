// src/pages/Laporan.jsx
import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import MainLayout from "../components/Layout/MainLayout";
import {
  // previewLaporanAnak,
  // exportLaporanAnak,
  exportLaporanIbu,
} from "../services/laporan";
import { FileDown, Eye, Loader2 } from "lucide-react";
import Swal from "sweetalert2";

export default function Laporan() {
  const navigate = useNavigate();

  // Data laporan dengan warna biru (#185FA5)
  const laporanItems = [
    {
      id: "ibu",
      title: "Laporan Data Ibu",
      description: "Data ibu hamil beserta riwayat kehamilan",
      path: "/laporan/ibu/preview",
      icon: FileDown,
    },
    {
      id: "anak",
      title: "Laporan Data Anak",
      description: "Data anak beserta riwayat kesehatan ",
      path: "/laporan/anak/preview",
      icon: FileDown,
    },
    {
      id: "balita",
      title: "Laporan Data Balita",
      description: "Data balita beserta riwayat pertumbuhan dan perkembangan",
      path: "/laporan/balita/preview",
      icon: FileDown,
    },
    {
      id: "remaja",
      title: "Laporan Data Remaja",
      description: "Data remaja beserta riwayat kesehatan",
      path: "/laporan/remaja/preview",
      icon: FileDown,
    },
    {
      id: "dewasa",
      title: "Laporan Data Dewasa",
      description: "Data dewasa beserta riwayat kesehatan",
      path: "/laporan/dewasa/preview",
      icon: FileDown,
    },
    {
      id: "lansia",
      title: "Laporan Data Lansia",
      description: "Data lansia beserta riwayat kesehatan",
      path: "/laporan/lansia/preview",
      icon: FileDown,
    },
  ];

  return (
    <MainLayout>
      <div className="p-6 max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-2xl font-bold text-gray-800">Laporan Data</h1>
          <p className="text-gray-500 text-sm mt-1">
            Pilih jenis laporan yang ingin Anda lihat dan export
          </p>
        </div>

        {/* Grid Laporan - Satu Warna Biru */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {laporanItems.map((item) => {
            const Icon = item.icon;
            return (
              <div
                key={item.id}
                className="bg-white rounded-xl shadow-sm border border-blue-100 overflow-hidden hover:shadow-md transition-shadow duration-200"
              >
                <div className="p-6">
                  <div className="flex items-center gap-3 mb-4">
                    <div className="p-2 rounded-lg" style={{ backgroundColor: "#185FA5" }}>
                      <Icon className="text-white" size={28} />
                    </div>
                    <div>
                      <h2 className="text-lg font-semibold text-gray-800">
                        {item.title}
                      </h2>
                      <p className="text-gray-500 text-sm">
                        {item.description}
                      </p>
                    </div>
                  </div>

                  <button
                    onClick={() => navigate(item.path)}
                    className="w-full text-white px-4 py-2.5 rounded-lg flex items-center justify-center gap-2 transition-colors"
                    style={{ backgroundColor: "#185FA5" }}
                    onMouseEnter={(e) => {
                      e.currentTarget.style.backgroundColor = "#134B8A";
                    }}
                    onMouseLeave={(e) => {
                      e.currentTarget.style.backgroundColor = "#185FA5";
                    }}
                  >
                    <Eye size={18} /> Lihat & Export Laporan
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </MainLayout>
  );
}