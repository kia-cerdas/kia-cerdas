import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import { getLingkunganDetail } from "../../services/kesehatanLingkungan";
import {
  ChevronLeft, CheckCircle, XCircle, Calendar, User,
  ClipboardList, AlertTriangle, CheckSquare, Printer
} from "lucide-react";

export default function DetailLembarLingkungan() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    const fetch = async () => {
      try {
        const res = await getLingkunganDetail(id);
        setData(res);
      } catch {
        setError("Gagal memuat detail lembar");
      } finally {
        setLoading(false);
      }
    };
    fetch();
  }, [id]);

  if (loading) return <MainLayout><div className="p-10 text-center text-gray-400 animate-pulse">Memuat...</div></MainLayout>;
  if (error || !data) return <MainLayout><div className="p-10 text-center text-red-500">{error || "Data tidak ditemukan"}</div></MainLayout>;

  // Kelompokkan jawaban berdasarkan kategori
  const jawabanMap = {};
  (data.detail_jawaban || []).forEach((d) => {
    const katNama = d.indikator?.kategori?.nama || "Lainnya";
    if (!jawabanMap[katNama]) jawabanMap[katNama] = [];
    jawabanMap[katNama].push(d);
  });

  const totalIndikator = data.detail_jawaban?.length || 0;
  const totalTerpenuhi = (data.detail_jawaban || []).filter((d) => d.is_ok).length;
  const persentase = totalIndikator > 0 ? Math.round((totalTerpenuhi / totalIndikator) * 100) : 0;

  const getStatusColor = (pct) => {
    if (pct >= 80) return { bg: "bg-green-50", border: "border-green-200", text: "text-green-700", label: "Baik", icon: <CheckCircle size={20} className="text-green-500" /> };
    if (pct >= 50) return { bg: "bg-yellow-50", border: "border-yellow-200", text: "text-yellow-700", label: "Perlu Perhatian", icon: <AlertTriangle size={20} className="text-yellow-500" /> };
    return { bg: "bg-red-50", border: "border-red-200", text: "text-red-700", label: "Perlu Tindakan Segera", icon: <XCircle size={20} className="text-red-500" /> };
  };

  const status = getStatusColor(persentase);

  // Indikator yang belum terpenuhi (untuk rekomendasi)
  const belumTerpenuhi = (data.detail_jawaban || []).filter((d) => !d.is_ok);

  return (
    <MainLayout>
      <div className="max-w-4xl mx-auto space-y-6 pb-10">

        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <button
              onClick={() => navigate("/pencatatan/kesehatan-lingkungan")}
              className="flex items-center gap-1.5 text-xs text-gray-400 hover:text-blue-600 mb-2 transition-all"
            >
              <ChevronLeft size={14} /> Kembali ke Daftar
            </button>
            <h1 className="text-2xl font-bold text-slate-800">Detail Lembar Kesehatan Lingkungan</h1>
          </div>
          <button
            onClick={() => window.print()}
            className="flex items-center gap-2 px-4 py-2 border border-slate-200 rounded-xl text-sm font-semibold text-slate-600 hover:bg-slate-50 transition-all"
          >
            <Printer size={16} /> Cetak
          </button>
        </div>

        {/* Info Kunjungan */}
        <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div>
              <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Nama Ibu</p>
              <p className="text-sm font-bold text-slate-800">{data.ibu?.nama || data.ibu?.kependudukan?.nama_lengkap || "-"}</p>
            </div>
            <div>
              <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1 flex items-center gap-1"><Calendar size={10} /> Tanggal</p>
              <p className="text-sm font-bold text-slate-800">
                {data.tanggal_periksa ? new Date(data.tanggal_periksa).toLocaleDateString("id-ID", { day: "2-digit", month: "long", year: "numeric" }) : "-"}
              </p>
            </div>
            <div>
              <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1 flex items-center gap-1"><User size={10} /> Pemeriksa</p>
              <p className="text-sm font-bold text-slate-800">{data.pemeriksa || "-"}</p>
            </div>
            <div>
              <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Catatan</p>
              <p className="text-sm text-slate-600">{data.catatan || "-"}</p>
            </div>
          </div>
        </div>

        {/* Skor Keseluruhan */}
        <div className={`rounded-2xl border p-6 ${status.bg} ${status.border}`}>
          <div className="flex items-center justify-between flex-wrap gap-4">
            <div className="flex items-center gap-3">
              {status.icon}
              <div>
                <p className="text-[10px] font-black uppercase tracking-widest text-slate-500">Status Kesehatan Lingkungan</p>
                <p className={`text-xl font-black ${status.text}`}>{status.label}</p>
              </div>
            </div>
            <div className="text-right">
              <p className={`text-4xl font-black ${status.text}`}>{persentase}%</p>
              <p className="text-xs text-slate-500">{totalTerpenuhi} dari {totalIndikator} indikator terpenuhi</p>
            </div>
          </div>
          {/* Progress bar */}
          <div className="mt-4 h-3 bg-white/60 rounded-full overflow-hidden">
            <div
              className={`h-full rounded-full transition-all ${persentase >= 80 ? "bg-green-500" : persentase >= 50 ? "bg-yellow-500" : "bg-red-500"}`}
              style={{ width: `${persentase}%` }}
            />
          </div>
        </div>

        {/* Rekomendasi jika ada yang belum terpenuhi */}
        {belumTerpenuhi.length > 0 && (
          <div className="bg-orange-50 border border-orange-200 rounded-2xl p-5">
            <h3 className="text-sm font-black text-orange-700 uppercase tracking-widest mb-3 flex items-center gap-2">
              <AlertTriangle size={16} /> Perlu Tindak Lanjut ({belumTerpenuhi.length} indikator)
            </h3>
            <ul className="space-y-2">
              {belumTerpenuhi.slice(0, 5).map((d) => (
                <li key={d.id} className="flex items-start gap-2 text-sm text-orange-800">
                  <XCircle size={14} className="text-orange-500 mt-0.5 flex-shrink-0" />
                  <span>{d.indikator?.pertanyaan || "-"}</span>
                </li>
              ))}
              {belumTerpenuhi.length > 5 && (
                <li className="text-xs text-orange-600 font-semibold ml-5">
                  + {belumTerpenuhi.length - 5} indikator lainnya belum terpenuhi
                </li>
              )}
            </ul>
          </div>
        )}

        {/* Detail per Kategori */}
        {Object.entries(jawabanMap).map(([katNama, items]) => {
          const terpenuhi = items.filter((i) => i.is_ok).length;
          return (
            <div key={katNama} className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
              {/* Kategori Header */}
              <div className="flex items-center justify-between px-6 py-4 bg-slate-50 border-b border-slate-100">
                <div className="flex items-center gap-3">
                  <ClipboardList size={18} className="text-blue-500" />
                  <span className="font-bold text-slate-800">{katNama}</span>
                </div>
                <span className={`text-xs font-black px-3 py-1 rounded-full ${
                  terpenuhi === items.length ? "bg-green-100 text-green-700" :
                  terpenuhi > 0 ? "bg-yellow-100 text-yellow-700" : "bg-red-100 text-red-700"
                }`}>
                  {terpenuhi}/{items.length} terpenuhi
                </span>
              </div>

              {/* Indikator */}
              <div className="divide-y divide-slate-50">
                {items.map((item, idx) => (
                  <div key={item.id} className={`flex items-start gap-4 px-6 py-4 ${item.is_ok ? "bg-green-50/30" : ""}`}>
                    <div className={`mt-0.5 flex-shrink-0 ${item.is_ok ? "text-green-500" : "text-red-400"}`}>
                      {item.is_ok
                        ? <CheckCircle size={18} />
                        : <XCircle size={18} />
                      }
                    </div>
                    <div className="flex-1">
                      <span className="text-[10px] font-black text-slate-400 mr-2">{idx + 1}.</span>
                      <span className={`text-sm leading-relaxed ${item.is_ok ? "text-green-800" : "text-slate-700"}`}>
                        {item.indikator?.pertanyaan || "-"}
                      </span>
                    </div>
                    <span className={`text-[10px] font-black uppercase flex-shrink-0 ${item.is_ok ? "text-green-600" : "text-red-400"}`}>
                      {item.is_ok ? "✓ Ya" : "✗ Tidak"}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          );
        })}

        {/* Tombol Aksi */}
        <div className="flex gap-3 justify-end">
          <button
            onClick={() => navigate("/pencatatan/kesehatan-lingkungan")}
            className="px-6 py-3 rounded-xl font-bold text-slate-500 hover:bg-slate-100 transition-all"
          >
            Kembali
          </button>
        </div>
      </div>
    </MainLayout>
  );
}
