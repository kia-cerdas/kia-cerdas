// src/pages/Laporan.jsx
import React, { useState } from "react";
import { useNavigate } from "react-router-dom"; // import useNavigate
import MainLayout from "../components/Layout/MainLayout";
import {
  previewLaporanAnak,   // tetap digunakan untuk preview inline anak
  exportLaporanAnak,
  exportLaporanIbu,     // masih diperlukan untuk export langsung jika ada, tapi untuk ibu kita arahkan ke halaman terpisah
} from "../services/laporan";
import { FileDown, Download, Eye, Loader2, Table, Users, UserCheck, HeartPulse } from "lucide-react";
import Swal from "sweetalert2";

export default function Laporan() {
  const navigate = useNavigate();

  // State untuk Laporan Anak (preview inline)
  const [loadingAnak, setLoadingAnak] = useState(false);
  const [previewAnak, setPreviewAnak] = useState(null);
  const [loadingPreviewAnak, setLoadingPreviewAnak] = useState(false);
  const [errorPreviewAnak, setErrorPreviewAnak] = useState("");

  // Helper untuk normalisasi response (sama seperti sebelumnya)
  const normalizeResponse = (responseData) => {
    if (Array.isArray(responseData)) return responseData;
    if (responseData && Array.isArray(responseData.data)) return responseData.data;
    if (responseData && Array.isArray(responseData.results)) return responseData.results;
    return null;
  };

  // Handler Preview Anak (inline)
  const handlePreviewAnak = async () => {
    setLoadingPreviewAnak(true);
    setErrorPreviewAnak("");
    try {
      const rawData = await previewLaporanAnak();
      const normalized = normalizeResponse(rawData);
      setPreviewAnak(normalized);
      if (!normalized || normalized.length === 0) {
        setErrorPreviewAnak("Tidak ada data anak yang tersedia");
      }
    } catch (err) {
      console.error("Preview Anak error:", err);
      setErrorPreviewAnak(err.message || "Gagal memuat preview data anak");
      setPreviewAnak(null);
    } finally {
      setLoadingPreviewAnak(false);
    }
  };

  // Handler Export untuk Anak (inline)
  const handleExportAnak = async () => {
    try {
      setLoadingAnak(true);
      const blob = await exportLaporanAnak();
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = "laporan_data_anak.xlsx";
      a.click();
      window.URL.revokeObjectURL(url);
    } catch (err) {
      console.error("Export error:", err);
      Swal.fire({
        icon: "error",
        title: "Gagal Mengekspor",
        text: "Gagal mengekspor laporan anak",
        confirmButtonColor: "#185FA5",
      });
    } finally {
      setLoadingAnak(false);
    }
  };

  // Render tabel preview untuk Anak
  const renderPreviewTable = (data) => {
    if (!Array.isArray(data) || data.length === 0) {
      return (
        <div className="text-center py-8 text-gray-500">
          <Table className="mx-auto mb-2 text-gray-400" size={40} />
          <p>Tidak ada data untuk ditampilkan</p>
        </div>
      );
    }
    const firstItem = data[0];
    if (!firstItem || typeof firstItem !== "object") {
      return (
        <div className="text-center py-8 text-gray-500">
          <p className="text-red-500">Format data tidak valid</p>
        </div>
      );
    }
    const columns = Object.keys(firstItem);
    if (columns.length === 0) {
      return (
        <div className="text-center py-8 text-gray-500">
          <p>Tidak ada kolom untuk ditampilkan</p>
        </div>
      );
    }
    return (
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              {columns.map((col) => (
                <th key={col} className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">
                  {col.replace(/_/g, " ").toUpperCase()}
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {data.slice(0, 10).map((row, idx) => (
              <tr key={idx} className="hover:bg-gray-50">
                {columns.map((col) => (
                  <td key={col} className="px-4 py-2 text-sm text-gray-900 whitespace-nowrap">
                    {row[col] !== null && row[col] !== undefined ? String(row[col]) : "-"}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
        {data.length > 10 && (
          <div className="text-xs text-gray-500 mt-2 text-right">
            Menampilkan 10 dari {data.length} data
          </div>
        )}
      </div>
    );
  };

  return (
    <MainLayout>
      <div className="p-6 max-w-7xl mx-auto">
        <h1 className="text-2xl font-bold mb-6">Laporan Data</h1>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Card Laporan Ibu - LANGSUNG NAVIGASI KE HALAMAN PREVIEW */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
            <div className="p-6">
              <div className="flex items-center gap-3 mb-4">
                <div className="p-2 bg-indigo-100 rounded-lg">
                  <FileDown className="text-indigo-600" size={28} />
                </div>
                <div>
                  <h2 className="text-xl font-semibold text-gray-800">
                    Laporan Data Ibu
                  </h2>
                  <p className="text-gray-500 text-sm">
                    Data ibu hamil beserta riwayat kehamilan
                  </p>
                </div>
              </div>

              <button
                onClick={() => navigate("/laporan/ibu/preview")}
                className="w-full bg-indigo-600 text-white px-4 py-2 rounded-lg flex items-center justify-center gap-2 hover:bg-indigo-700 transition-colors"
              >
                <Eye size={18} /> Lihat & Export Laporan Ibu
              </button>
            </div>
          </div>

          {/* Card Laporan Anak */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
            <div className="p-6">
              <div className="flex items-center gap-3 mb-4">
                <div className="p-2 bg-green-100 rounded-lg">
                  <FileDown className="text-green-600" size={28} />
                </div>
                <div>
                  <h2 className="text-xl font-semibold text-gray-800">
                    Laporan Data Anak
                  </h2>
                  <p className="text-gray-500 text-sm">
                    Data anak beserta riwayat kesehatan dan imunisasi
                  </p>
                </div>
              </div>

              <button
                onClick={() => navigate("/laporan/anak/preview")}
                className="w-full bg-green-600 text-white px-4 py-2 rounded-lg flex items-center justify-center gap-2 hover:bg-green-700 transition-colors"
              >
                <Eye size={18} /> Lihat & Export Laporan Anak
              </button>
            </div>
          </div>

          {/* Card Laporan Remaja */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
            <div className="p-6">
              <div className="flex items-center gap-3 mb-4">
                <div className="p-2 bg-blue-100 rounded-lg">
                  <Users className="text-blue-600" size={28} />
                </div>
                <div>
                  <h2 className="text-xl font-semibold text-gray-800">
                    Laporan Data Remaja
                  </h2>
                  <p className="text-gray-500 text-sm">
                    Data remaja beserta riwayat kesehatan
                  </p>
                </div>
              </div>

              <button
                onClick={() => navigate("/laporan/remaja/preview")}
                className="w-full bg-blue-600 text-white px-4 py-2 rounded-lg flex items-center justify-center gap-2 hover:bg-blue-700 transition-colors"
              >
                <Eye size={18} /> Lihat & Export Laporan Remaja
              </button>
            </div>
          </div>

          {/* Card Laporan Dewasa */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
            <div className="p-6">
              <div className="flex items-center gap-3 mb-4">
                <div className="p-2 bg-purple-100 rounded-lg">
                  <UserCheck className="text-purple-600" size={28} />
                </div>
                <div>
                  <h2 className="text-xl font-semibold text-gray-800">
                    Laporan Data Dewasa
                  </h2>
                  <p className="text-gray-500 text-sm">
                    Data dewasa beserta riwayat kesehatan
                  </p>
                </div>
              </div>

              <button
                onClick={() => navigate("/laporan/dewasa/preview")}
                className="w-full bg-purple-600 text-white px-4 py-2 rounded-lg flex items-center justify-center gap-2 hover:bg-purple-700 transition-colors"
              >
                <Eye size={18} /> Lihat & Export Laporan Dewasa
              </button>
            </div>
          </div>

          {/* Card Laporan Lansia */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
            <div className="p-6">
              <div className="flex items-center gap-3 mb-4">
                <div className="p-2 bg-orange-100 rounded-lg">
                  <HeartPulse className="text-orange-600" size={28} />
                </div>
                <div>
                  <h2 className="text-xl font-semibold text-gray-800">
                    Laporan Data Lansia
                  </h2>
                  <p className="text-gray-500 text-sm">
                    Data lansia beserta riwayat kesehatan
                  </p>
                </div>
              </div>

              <button
                onClick={() => navigate("/laporan/lansia/preview")}
                className="w-full bg-orange-600 text-white px-4 py-2 rounded-lg flex items-center justify-center gap-2 hover:bg-orange-700 transition-colors"
              >
                <Eye size={18} /> Lihat & Export Laporan Lansia
              </button>
            </div>
          </div>
        </div>
      </div>
    </MainLayout>
  );
}