import React, { useState, useEffect } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import { useParams, Link, useNavigate } from "react-router-dom";
import { getPelayananKesehatanAnakById } from "../../services/PelayananKesehatanAnak";
import { ChevronRight, ArrowLeft, Printer } from "lucide-react";

export default function DetailPelayananKesehatanAnak() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const res = await getPelayananKesehatanAnakById(id);
        setData(res.data);
      } catch (err) {
        setError("Gagal memuat data. Silakan coba lagi.");
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [id]);

  const formatDate = (dateString) => {
    if (!dateString) return "-";
    const date = new Date(dateString);
    return date.toLocaleDateString("id-ID", {
      day: "numeric",
      month: "long",
      year: "numeric",
    });
  };

  if (loading) {
    return (
      <MainLayout>
        <div className="text-center py-20">
          <p className="text-gray-500">Memuat data...</p>
        </div>
      </MainLayout>
    );
  }

  if (error || !data) {
    return (
      <MainLayout>
        <div className="text-center py-20">
          <p className="text-red-500">{error || "Data tidak ditemukan"}</p>
          <Link to="/pelayanan-kesehatan-anak" className="text-indigo-600 hover:underline mt-4 inline-block">
            Kembali ke daftar kunjungan
          </Link>
        </div>
      </MainLayout>
    );
  }

  return (
    <MainLayout>
      {/* BREADCRUMB */}
      <nav className="flex items-center text-sm text-gray-500 mb-6 gap-2 bg-white p-3 rounded-lg shadow-sm border border-gray-100 w-fit">
        <Link to="/dashboard" className="hover:text-indigo-600">Dashboard</Link>
        <ChevronRight size={14} />
        <Link to="/pelayanan-kesehatan-anak" className="hover:text-indigo-600">Pelayanan Kesehatan Anak</Link>
        <ChevronRight size={14} />
        <span className="font-semibold text-indigo-700">Detail Kunjungan</span>
      </nav>

      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold text-gray-800">Detail Kunjungan Pelayanan</h1>
          <p className="text-gray-500 text-sm mt-1">Data pencatatan pelayanan kesehatan anak oleh bidan</p>
        </div>
        <div className="flex gap-2">
          <button
            onClick={() => window.print()}
            className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-xl font-bold hover:bg-blue-700 transition-all"
          >
            <Printer size={18} /> Cetak
          </button>
          <Link
            to={`/pelayanan-kesehatan-anak/edit/${id}`}
            className="px-4 py-2 bg-amber-600 text-white rounded-xl font-bold hover:bg-amber-700 transition-all"
          >
            Edit
          </Link>
        </div>
      </div>

      {/* MAIN CONTENT */}
      <div className="space-y-6">
        {/* SECTION 1: DATA KUNJUNGAN */}
        <div className="bg-white rounded-2xl shadow-lg border border-gray-100 p-8">
          <h2 className="text-xl font-bold text-gray-800 mb-6 pb-4 border-b border-gray-200">
            Data Kunjungan
          </h2>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <p className="text-xs font-bold text-gray-500 uppercase tracking-wider">Nama Anak</p>
              <p className="text-lg font-bold text-gray-800 mt-1">{data.data_anak?.nama || "-"}</p>
            </div>

            <div>
              <p className="text-xs font-bold text-gray-500 uppercase tracking-wider">Kategori Umur</p>
              <p className="text-lg font-bold text-gray-800 mt-1">
                <span className="px-3 py-1 rounded-full bg-indigo-100 text-indigo-700 text-sm">
                  {data.kategori_umur?.kategori_umur || "-"}
                </span>
              </p>
            </div>

            <div>
              <p className="text-xs font-bold text-gray-500 uppercase tracking-wider">Tanggal Periksa</p>
              <p className="text-lg font-bold text-gray-800 mt-1">{formatDate(data.tanggal)}</p>
            </div>

            <div>
              <p className="text-xs font-bold text-gray-500 uppercase tracking-wider">Periode</p>
              <p className="text-lg font-bold text-gray-800 mt-1">{data.periode?.nama || "-"}</p>
            </div>

            <div>
              <p className="text-xs font-bold text-gray-500 uppercase tracking-wider">Lokasi Periksa</p>
              <p className="text-lg font-bold text-gray-800 mt-1">{data.lokasi || "-"}</p>
            </div>

            <div>
              <p className="text-xs font-bold text-gray-500 uppercase tracking-wider">Tanggal Kembali</p>
              <p className="text-lg font-bold text-gray-800 mt-1">
                {data.tanggal_kembali ? formatDate(data.tanggal_kembali) : "-"}
              </p>
            </div>
          </div>
        </div>

        {/* SECTION 2: KELUHAN & PEMERIKSAAN */}
        <div className="bg-white rounded-2xl shadow-lg border border-gray-100 p-8">
          <h2 className="text-xl font-bold text-gray-800 mb-6 pb-4 border-b border-gray-200">
            Keluhan, Pemeriksaan & Tindakan
          </h2>

          {data.keluhan && (
            <div className="mb-6">
              <p className="text-xs font-bold text-gray-500 uppercase tracking-wider mb-2">Keluhan Utama</p>
              <p className="text-gray-800 leading-relaxed bg-gray-50 p-4 rounded-lg">
                {data.keluhan}
              </p>
            </div>
          )}

          {data.pemeriksaan_tindakan && (
            <div className="mb-6">
              <p className="text-xs font-bold text-gray-500 uppercase tracking-wider mb-2">Pemeriksaan & Tindakan</p>
              <p className="text-gray-800 leading-relaxed bg-gray-50 p-4 rounded-lg">
                {data.pemeriksaan_tindakan}
              </p>
            </div>
          )}

          {data.catatan_kie && (
            <div>
              <p className="text-xs font-bold text-gray-500 uppercase tracking-wider mb-2">Catatan KIE</p>
              <p className="text-gray-800 leading-relaxed bg-gray-50 p-4 rounded-lg">
                {data.catatan_kie}
              </p>
            </div>
          )}

          {!data.keluhan && !data.pemeriksaan_tindakan && !data.catatan_kie && (
            <p className="text-gray-500">Tidak ada catatan</p>
          )}
        </div>

        {/* SECTION 3: DETAIL PELAYANAN */}
        <div className="bg-white rounded-2xl shadow-lg border border-gray-100 p-8">
          <h2 className="text-xl font-bold text-gray-800 mb-6 pb-4 border-b border-gray-200">
            Detail Pelayanan yang Dicatat
          </h2>

          {data.detail_pelayanan && data.detail_pelayanan.length > 0 ? (
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse">
                <thead>
                  <tr className="bg-gray-50 border-y border-gray-200">
                    <th className="px-4 py-3 text-xs font-bold text-gray-600 uppercase tracking-wider">Jenis Pelayanan</th>
                    <th className="px-4 py-3 text-xs font-bold text-gray-600 uppercase tracking-wider">Nilai</th>
                    <th className="px-4 py-3 text-xs font-bold text-gray-600 uppercase tracking-wider">Keterangan</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100">
                  {data.detail_pelayanan.map((detail, idx) => (
                    <tr key={idx} className="hover:bg-gray-50">
                      <td className="px-4 py-3 font-semibold text-gray-800">
                        {detail.jenis_pelayanan?.nama || "-"}
                      </td>
                      <td className="px-4 py-3 text-gray-700">
                        {detail.jenis_pelayanan?.tipe_input === "checkbox" && detail.nilai === "true" ? (
                          <span className="px-3 py-1 bg-green-100 text-green-700 rounded-full text-xs font-bold">
                            ✓ Sudah Diberikan
                          </span>
                        ) : (
                          detail.nilai || "-"
                        )}
                      </td>
                      <td className="px-4 py-3 text-gray-600 text-sm">{detail.keterangan || "-"}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ) : (
            <p className="text-gray-500">Tidak ada detail pelayanan</p>
          )}
        </div>

        {/* SECTION 4: INFORMASI SISTEM */}
        <div className="bg-gray-50 rounded-2xl border border-gray-200 p-8">
          <h2 className="text-xl font-bold text-gray-800 mb-6 pb-4 border-b border-gray-200">
            Informasi Sistem
          </h2>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <p className="text-xs font-bold text-gray-500 uppercase tracking-wider">ID Kunjungan</p>
              <p className="text-lg font-mono text-gray-800 mt-1">{data.id}</p>
            </div>

            <div>
              <p className="text-xs font-bold text-gray-500 uppercase tracking-wider">Dibuat Pada</p>
              <p className="text-lg text-gray-800 mt-1">{formatDate(data.created_at)}</p>
            </div>

            <div>
              <p className="text-xs font-bold text-gray-500 uppercase tracking-wider">Terakhir Diubah</p>
              <p className="text-lg text-gray-800 mt-1">{formatDate(data.updated_at)}</p>
            </div>
          </div>
        </div>
      </div>

      {/* FOOTER BUTTONS */}
      <div className="flex justify-between mt-8">
        <button
          onClick={() => navigate("/pelayanan-kesehatan-anak")}
          className="flex items-center gap-2 px-6 py-2.5 text-indigo-600 border border-indigo-600 rounded-xl font-bold hover:bg-indigo-50 transition-all"
        >
          <ArrowLeft size={18} /> Kembali ke Daftar
        </button>

        <div className="flex gap-2">
          <button
            onClick={() => window.print()}
            className="flex items-center gap-2 px-6 py-2.5 bg-blue-600 text-white rounded-xl font-bold hover:bg-blue-700 transition-all"
          >
            <Printer size={18} /> Cetak
          </button>
          <Link
            to={`/pelayanan-kesehatan-anak/edit/${id}`}
            className="px-6 py-2.5 bg-amber-600 text-white rounded-xl font-bold hover:bg-amber-700 transition-all"
          >
            Edit Data
          </Link>
        </div>
      </div>
    </MainLayout>
  );
}
