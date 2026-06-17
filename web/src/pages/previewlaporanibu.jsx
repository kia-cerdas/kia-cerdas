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
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [exporting, setExporting] = useState(false);

  // Filter state
  const [bulan, setBulan] = useState(new Date().getMonth() + 1);
  const [tahun, setTahun] = useState(new Date().getFullYear());
  const [filterEnabled, setFilterEnabled] = useState(false);

  useEffect(() => {
    fetchPreview();
  }, [bulan, tahun, filterEnabled]);

  const fetchPreview = async () => {
    setLoading(true);
    setError("");
    try {
      let rawData;
      if (filterEnabled) {
        rawData = await previewLaporanIbu(bulan, tahun);
      } else {
        rawData = await previewLaporanIbu();
      }
      const normalized = Array.isArray(rawData) ? rawData : rawData?.data || [];
      setData(normalized);
      if (normalized.length === 0 && filterEnabled) {
        setError(`Tidak ada data untuk periode ${bulan}/${tahun}`);
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
      if (filterEnabled) {
        blob = await exportLaporanIbu(bulan, tahun);
      } else {
        blob = await exportLaporanIbu();
      }
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = `laporan_ibu_${filterEnabled ? `${tahun}_${bulan}` : "semua"}.xlsx`;
      a.click();
      window.URL.revokeObjectURL(url);
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

  // Skeleton loading untuk tabel
  const SkeletonRow = ({ cols = 6 }) => (
    <tr className="animate-pulse">
      {[...Array(cols)].map((_, i) => (
        <td key={i} className="px-4 py-3">
          <div className="h-4 bg-gray-200 rounded w-3/4"></div>
        </td>
      ))}
    </tr>
  );

  const renderTable = () => {
    if (!Array.isArray(data) || data.length === 0) return null;
    const columns = Object.keys(data[0]);
    return (
      <>
        <div className="overflow-x-auto rounded-lg border border-gray-200 shadow-sm">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50 sticky top-0">
              <tr>
                {columns.map((col) => (
                  <th
                    key={col}
                    className="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider"
                  >
                    {col.replace(/_/g, " ").toUpperCase()}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-100">
              {data.map((row, idx) => (
                <tr
                  key={idx}
                  className="hover:bg-indigo-50/30 transition-colors duration-150"
                >
                  {columns.map((col) => (
                    <td key={col} className="px-4 py-2.5 text-sm text-gray-700 whitespace-nowrap">
                      {row[col] !== undefined && row[col] !== null ? String(row[col]) : "-"}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div className="mt-3 flex flex-wrap justify-between items-center gap-2 text-sm text-gray-500">
          <span>Menampilkan <strong>{data.length}</strong> data</span>
          <span className="inline-flex items-center gap-1 bg-indigo-50 text-indigo-700 px-2 py-1 rounded-full text-xs">
            <FileSpreadsheet size={12} /> Siap ekspor
          </span>
        </div>
      </>
    );
  };

  return (
    <MainLayout>
      <div className="p-4 md:p-6 max-w-7xl mx-auto">
        {/* Header dengan navigasi */}
        <div className="flex flex-wrap items-center justify-between gap-3 mb-6">
          <button
            onClick={() => navigate(-1)}
            className="inline-flex items-center gap-2 text-gray-600 hover:text-indigo-600 transition-colors"
          >
            <ArrowLeft size={18} /> Kembali
          </button>
          <h1 className="text-xl md:text-2xl font-bold text-gray-800">
            Preview Laporan Data Ibu
          </h1>
          <div className="w-20 md:w-auto"></div> {/* spacer untuk flex balance */}
        </div>

        {/* Card Filter & Export */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-4 mb-6">
          <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
            <div className="flex items-center gap-3">
              <div className="bg-indigo-100 p-2 rounded-full">
                <Filter size={18} className="text-indigo-600" />
              </div>
              <div className="flex flex-wrap items-center gap-2">
                <span className="text-sm font-medium text-gray-700">
                  Filter berdasarkan tanggal pemeriksaan:
                </span>
                <div className="flex gap-2">
                  <select
                    value={bulan}
                    onChange={(e) => setBulan(parseInt(e.target.value))}
                    disabled={!filterEnabled}
                    className={`border rounded-lg px-3 py-1.5 text-sm focus:ring-2 focus:ring-indigo-300 transition ${
                      !filterEnabled ? "bg-gray-50 text-gray-400" : "bg-white"
                    }`}
                  >
                    {Array.from({ length: 12 }, (_, i) => i + 1).map((m) => (
                      <option key={m} value={m}>
                        Bulan {m}
                      </option>
                    ))}
                  </select>
                  <select
                    value={tahun}
                    onChange={(e) => setTahun(parseInt(e.target.value))}
                    disabled={!filterEnabled}
                    className={`border rounded-lg px-3 py-1.5 text-sm focus:ring-2 focus:ring-indigo-300 transition ${
                      !filterEnabled ? "bg-gray-50 text-gray-400" : "bg-white"
                    }`}
                  >
                    {Array.from({ length: 5 }, (_, i) => new Date().getFullYear() - 2 + i).map(
                      (y) => (
                        <option key={y} value={y}>
                          {y}
                        </option>
                      )
                    )}
                  </select>
                </div>
                <button
                  onClick={() => setFilterEnabled(!filterEnabled)}
                  className={`px-3 py-1.5 rounded-lg text-sm font-medium transition ${
                    filterEnabled
                      ? "bg-indigo-600 text-white shadow-sm hover:bg-indigo-700"
                      : "bg-gray-100 text-gray-700 hover:bg-gray-200"
                  }`}
                >
                  {filterEnabled ? "Filter Aktif (klik untuk nonaktif)" : "Gunakan Filter"}
                </button>
              </div>
            </div>

            <button
              onClick={handleExport}
              disabled={exporting || !data?.length}
              className="bg-emerald-600 hover:bg-emerald-700 text-white px-5 py-2 rounded-lg flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed transition shadow-sm"
            >
              {exporting ? <Loader2 className="animate-spin" size={18} /> : <Download size={18} />}
              {exporting ? "Mengekspor..." : "Download Excel"}
            </button>
          </div>

          {filterEnabled && (
            <div className="mt-3 text-xs text-indigo-600 bg-indigo-50 p-2 rounded-lg inline-flex items-center gap-1">
              <Calendar size={12} /> Menampilkan data untuk {bulan}/{tahun}
            </div>
          )}
        </div>

        {/* Loading state dengan skeleton */}
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
            <p className="text-sm text-gray-500 mt-1">
              {filterEnabled &&
                "Coba nonaktifkan filter atau periksa koneksi ke server."}
              {!filterEnabled &&
                "Pastikan data sudah tersedia atau hubungi administrator."}
            </p>
            <button
              onClick={() => fetchPreview()}
              className="mt-4 inline-flex items-center gap-2 text-indigo-600 text-sm hover:underline"
            >
              <RefreshCw size={14} /> Muat ulang
            </button>
          </div>
        )}

        {/* Empty state (tidak ada data, tidak ada error) */}
        {!loading && !error && (!data || data.length === 0) && (
          <div className="bg-gray-50 border border-gray-200 rounded-xl p-12 text-center">
            <Table size={48} className="mx-auto text-gray-400 mb-3" />
            <p className="text-gray-600 font-medium">
              Belum ada data ibu untuk ditampilkan
            </p>
            <p className="text-sm text-gray-400 mt-1">
              Data akan muncul setelah ada pemeriksaan ibu yang tercatat.
            </p>
          </div>
        )}

        {/* Tabel data */}
        {!loading && !error && data && data.length > 0 && renderTable()}
      </div>
    </MainLayout>
  );
}