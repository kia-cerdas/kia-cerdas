import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import MainLayout from "../components/Layout/MainLayout";
import { previewLaporanIbu, exportLaporanIbu } from "../services/laporan";
import {
  Download,
  ArrowLeft,
  Loader2,
  Table,
  Filter,
  AlertCircle,
  Calendar,
  FileSpreadsheet,
  RefreshCw,
} from "lucide-react";
import Swal from "sweetalert2";

export default function LaporanIbuPreview() {
  const navigate = useNavigate();
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [exporting, setExporting] = useState(false);

  // Tabs untuk data ibu
  const [activeTab, setActiveTab] = useState("ibu");

  // Filter state
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");
  const [filterEnabled, setFilterEnabled] = useState(false);

  useEffect(() => {
    fetchPreview();
  }, [filterEnabled]);

  const fetchPreview = async () => {
    setLoading(true);
    setError("");
    try {
      let rawData;
      if (filterEnabled && startDate && endDate) {
        rawData = await previewLaporanIbu(startDate, endDate);
      } else {
        rawData = await previewLaporanIbu();
      }
      
      // Normalize response
      const normalized = Array.isArray(rawData) ? rawData : rawData?.data || [];
      setData(normalized);

      if (normalized.length === 0 && filterEnabled) {
        setError(`Tidak ada data ditemukan untuk rentang tanggal ${startDate} s.d. ${endDate}`);
      } else if (normalized.length === 0) {
        setError("Belum ada data ibu yang tersedia");
      }
    } catch (err) {
      console.error("Preview error:", err);
      const msg = err.response?.data?.message || err.message || "Gagal memuat preview data ibu";
      setError(msg);
      setData([]);
    } finally {
      setLoading(false);
    }
  };

  const handleExport = async () => {
    setExporting(true);
    try {
      let blob;
      if (filterEnabled && startDate && endDate) {
        blob = await exportLaporanIbu(startDate, endDate);
      } else {
        blob = await exportLaporanIbu();
      }
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = `laporan_ibu_${filterEnabled ? `${startDate}_to_${endDate}` : "semua"}.xlsx`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      window.URL.revokeObjectURL(url);
      
      Swal.fire({
        icon: "success",
        title: "Export Berhasil",
        text: `File laporan_ibu_${filterEnabled ? `${startDate}_to_${endDate}` : "semua"}.xlsx berhasil diunduh`,
        confirmButtonColor: "#185FA5",
      });
    } catch (err) {
      Swal.fire({
        icon: "error",
        title: "Gagal Mengekspor",
        text: "Gagal mengekspor laporan ibu: " + (err.response?.data?.message || err.message),
        confirmButtonColor: "#185FA5",
      });
    } finally {
      setExporting(false);
    }
  };

  const handleApplyFilter = () => {
    if (!startDate || !endDate) {
      Swal.fire({
        icon: "warning",
        title: "Tanggal Belum Dipilih",
        text: "Silakan pilih tanggal awal dan akhir terlebih dahulu.",
        confirmButtonColor: "#185FA5",
      });
      return;
    }
    setFilterEnabled(true);
  };

  const handleResetFilter = () => {
    setStartDate("");
    setEndDate("");
    setFilterEnabled(false);
  };

  const SkeletonRow = ({ cols = 6 }) => (
    <tr className="animate-pulse">
      {[...Array(cols)].map((_, i) => (
        <td key={i} className="px-4 py-3">
          <div className="h-4 bg-gray-200 rounded w-3/4"></div>
        </td>
      ))}
    </tr>
  );

  const renderTable = (currentData, columns) => {
    if (!currentData || currentData.length === 0) {
      return (
        <div className="bg-gray-50 border border-gray-200 rounded-xl p-12 text-center mt-4">
          <Table size={48} className="mx-auto text-gray-400 mb-3" />
          <p className="text-gray-600 font-medium">
            Tidak ada data untuk ditampilkan
          </p>
          <p className="text-sm text-gray-400 mt-1">
            Data tidak ditemukan atau belum dicatat pada sistem.
          </p>
        </div>
      );
    }

    return (
      <div className="mt-4">
        <div className="overflow-x-auto rounded-lg border border-gray-200 shadow-sm max-h-[500px]">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50 sticky top-0 z-10">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider sticky left-0 bg-gray-50 z-20">
                  No
                </th>
                {columns.map((col) => (
                  <th
                    key={col.field}
                    className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider bg-gray-50 whitespace-nowrap"
                  >
                    {col.label}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-100">
              {currentData.map((row, idx) => (
                <tr
                  key={idx}
                  className="hover:bg-blue-50/30 transition-colors duration-150"
                >
                  <td className="px-4 py-2.5 text-sm text-gray-700 whitespace-nowrap sticky left-0 bg-white z-10">
                    {idx + 1}
                  </td>
                  {columns.map((col) => {
                    let val = row[col.field];
                    if (col.type === "date" && val) {
                      val = new Date(val).toLocaleDateString("id-ID", {
                        year: "numeric",
                        month: "long",
                        day: "numeric",
                      });
                    }
                    if (col.type === "currency" && val) {
                      val = new Intl.NumberFormat("id-ID", {
                        style: "currency",
                        currency: "IDR",
                      }).format(val);
                    }
                    return (
                      <td key={col.field} className="px-4 py-2.5 text-sm text-gray-700 whitespace-nowrap max-w-xs truncate">
                        {val !== undefined && val !== null && val !== "" ? String(val) : "-"}
                      </td>
                    );
                  })}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div className="mt-3 flex flex-wrap justify-between items-center gap-2 text-sm text-gray-500">
          <span>Menampilkan <strong>{currentData.length}</strong> data</span>
           <div className="flex items-center gap-2">
                      <button
                        onClick={() => fetchPreview()}
                        className="text-blue-600 hover:text-blue-800 flex items-center gap-1 text-sm"
                      >
                        <RefreshCw size={14} /> Refresh
                      </button>
                    </div>
        </div>
      </div>
    );
  };

  // Column definitions untuk data ibu
  const ibuCols = [
    { field: "nik", label: "NIK" },
    { field: "nama_ibu", label: "Nama Ibu" },
    { field: "nama_suami", label: "Nama Suami" },
    { field: "tanggal_lahir", label: "Tanggal Lahir", type: "date" },
    { field: "dusun", label: "Dusun" },
    { field: "rt", label: "RT" },
    { field: "rw", label: "RW" },
    { field: "desa", label: "Desa" },
    { field: "hpht", label: "HPHT", type: "date" },
    { field: "hpl", label: "HPL", type: "date" },
    { field: "usia_kehamilan", label: "Usia Kehamilan" },
    { field: "trimester", label: "Trimester" },
    { field: "gravida", label: "Gravida" },
    { field: "paritas", label: "Paritas" },
    { field: "abortus", label: "Abortus" },
    { field: "bb_awal", label: "BB Awal (kg)" },
    { field: "tinggi_badan", label: "Tinggi Badan (cm)" },
    { field: "imt", label: "IMT" },
    { field: "lila", label: "LILA (cm)" },
    { field: "tekanan_darah", label: "Tekanan Darah" },
    { field: "sistole", label: "Sistole" },
    { field: "diastole", label: "Diastole" },
    { field: "tinggi_fundus", label: "Tinggi Fundus (cm)" },
    { field: "hb", label: "Hb (g/dL)" },
    { field: "golongan_darah", label: "Golongan Darah" },
    { field: "status_imunisasi", label: "Status Imunisasi" },
    { field: "tripel_eliminasi", label: "Tripel Eliminasi" },
    { field: "kunjungan_anc", label: "Kunjungan ANC" },
    { field: "tindakan", label: "Tindakan" },
  ];

  return (
    <MainLayout>
      <div className="p-4 md:p-6 max-w-7xl mx-auto">
        {/* Header */}
        <div className="flex flex-wrap items-center justify-between gap-3 mb-6">
          <button
            onClick={() => navigate(-1)}
            className="inline-flex items-center gap-2 text-gray-600 hover:text-blue-600 transition-colors"
          >
            <ArrowLeft size={18} /> Kembali
          </button>
          <h1 className="text-xl md:text-2xl font-bold text-gray-800">
            Preview Laporan Data Ibu
          </h1>
          <div className="w-20 md:w-auto"></div>
        </div>

        {/* Card Filter & Export */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-4 mb-6">
          <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
            <div className="flex flex-wrap items-center gap-3">
              <div className="bg-blue-100 p-2 rounded-full">
                <Filter size={18} className="text-blue-600" />
              </div>
              <div className="flex flex-wrap items-center gap-3">
                <span className="text-sm font-medium text-gray-700">
                  Filter Tanggal:
                </span>
                <div className="flex items-center gap-2">
                  <input
                    type="date"
                    value={startDate}
                    onChange={(e) => setStartDate(e.target.value)}
                    className="border rounded-lg px-5 py-2 text-sm focus:ring-2 focus:ring-blue-300 bg-white"
                  />
                  <span className="text-gray-400 text-sm">s.d.</span>
                  <input
                    type="date"
                    value={endDate}
                    onChange={(e) => setEndDate(e.target.value)}
                    className="border rounded-lg px-5 py-2 text-sm focus:ring-2 focus:ring-blue-300 bg-white"
                  />
                </div>
                <div className="flex gap-2">
                  <button
                    onClick={handleApplyFilter}
                    className="bg-blue-600 hover:bg-blue-700 text-white px-5 py-2 rounded-lg flex items-center justify-center gap-2 transition shadow-sm"
                  >
                    Terapkan Filter
                  </button>
                  {filterEnabled && (
                    <button
                      onClick={handleResetFilter}
                      className="bg-gray-100 hover:bg-gray-200 text-gray-700 px-5 py-2 rounded-lg flex items-center justify-center gap-2 transition"
                    >
                      Reset
                    </button>
                  )}
                </div>
              </div>
            </div>

            <button
              onClick={handleExport}
              disabled={exporting || !data || data.length === 0}
              className="bg-blue-600 hover:bg-blue-700 text-white px-5 py-2 rounded-lg flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed transition shadow-sm w-full lg:w-auto"
            >
              {exporting ? <Loader2 className="animate-spin" size={18} /> : <Download size={18} />}
              {exporting ? "Mengekspor..." : "Download Excel"}
            </button>
          </div>

          {filterEnabled && startDate && endDate && (
            <div className="mt-3 text-xs text-blue-600 bg-blue-50 p-2 rounded-lg inline-flex items-center gap-1">
              <Calendar size={12} /> Memfilter data dari {new Date(startDate).toLocaleDateString("id-ID")} s.d. {new Date(endDate).toLocaleDateString("id-ID")}
            </div>
          )}
        </div>


        {/* Loading skeleton */}
        {loading && (
          <div className="rounded-lg border border-gray-200 overflow-hidden">
            <div className="bg-gray-50 px-4 py-3 border-b">
              <div className="h-5 w-32 bg-gray-200 rounded animate-pulse"></div>
            </div>
            <div className="overflow-x-auto">
              <table className="min-w-full">
                <tbody>
                  {[...Array(5)].map((_, i) => (
                    <SkeletonRow key={i} cols={6} />
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {/* Error state */}
        {!loading && error && (
          <div className="bg-red-50 border border-red-200 rounded-xl p-6 text-center">
            <AlertCircle className="mx-auto text-red-500 mb-2" size={32} />
            <p className="text-red-700 font-medium">{error}</p>
            <button
              onClick={() => fetchPreview()}
              className="mt-4 inline-flex items-center gap-2 text-blue-600 text-sm hover:underline"
            >
              <RefreshCw size={14} /> Muat ulang
            </button>
          </div>
        )}

        {/* Table Views */}
        {!loading && !error && activeTab === "ibu" && renderTable(data, ibuCols)}
      </div>
    </MainLayout>
  );
}