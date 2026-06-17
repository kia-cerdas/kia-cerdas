import React, { useState, useEffect } from "react";
import { useParams, useNavigate, Link } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import AlertNotification from "../../components/AlertNotification";
import { ChevronLeft, CheckCircle2, XCircle, Calendar, Save, RefreshCw } from "lucide-react";
import { getAnakById } from "../../services/Anak";
import {
  getKategoriCapaianList,
  getPerawatanByAnak,
  updatePerawatan,
  createPerawatan,
} from "../../services/perawatan";

export default function LembarPerawatanAnak() {
  const { id } = useParams();
  const navigate = useNavigate();

  const [child, setChild] = useState(null);
  const [kategoriList, setKategoriList] = useState([]);   // semua indikator dari DB
  const [perawatanMap, setPerawatanMap] = useState({});   // key: kategori_capaian_id → record perawatan
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [activeDate, setActiveDate] = useState(new Date().toISOString().split("T")[0]);
  const [notification, setNotification] = useState(null);

  // ── Muat data awal ──────────────────────────────────────
  const loadData = async () => {
    setLoading(true);
    try {
      const [childRes, kategoriRes, perawatanRes] = await Promise.all([
        getAnakById(id),
        getKategoriCapaianList(),
        getPerawatanByAnak(id),
      ]);

      setChild(childRes.data || childRes);
      setKategoriList(Array.isArray(kategoriRes) ? kategoriRes : []);

      // Buat map: kategori_capaian_id → record perawatan
      const map = {};
      (Array.isArray(perawatanRes) ? perawatanRes : []).forEach((p) => {
        map[p.kategori_capaian_id] = p;
      });
      setPerawatanMap(map);
    } catch (error) {
      console.error("Error loading data:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, [id]);

  // ── Toggle jawaban ──────────────────────────────────────
  const handleJawabanChange = (kategoriId, jawaban) => {
    setPerawatanMap((prev) => ({
      ...prev,
      [kategoriId]: {
        ...(prev[kategoriId] || { kategori_capaian_id: kategoriId }),
        jawaban,
        tanggal_periksa: activeDate,
        _dirty: true,
      },
    }));
  };

  // ── Simpan semua perubahan ──────────────────────────────
  const handleSave = async () => {
    setSaving(true);
    try {
      const dirtyEntries = Object.values(perawatanMap).filter((p) => p._dirty);

      for (const item of dirtyEntries) {
        if (item.id) {
          // Update record yang sudah ada
          await updatePerawatan(item.id, {
            jawaban: item.jawaban,
            tanggal_periksa: activeDate,
          });
        } else {
          // Buat record baru
          const created = await createPerawatan({
            anak_id: parseInt(id),
            kategori_capaian_id: item.kategori_capaian_id,
            jawaban: item.jawaban,
            tanggal_periksa: activeDate,
          });
          // Simpan id yang baru dibuat ke map
          setPerawatanMap((prev) => ({
            ...prev,
            [item.kategori_capaian_id]: { ...created, _dirty: false },
          }));
        }
      }

      // Refresh data dari server
      await loadData();
      setNotification({
        type: "success",
        message: "Data pencatatan perawatan anak berhasil disimpan ke dalam sistem!"
      });
    } catch (error) {
      console.error("Error saving perawatan:", error);
      const errMsg = error?.response?.data?.message || error.message || "Unknown error";
      setNotification({
        type: "error",
        message: "Permintaan gagal diproses. Silakan coba lagi nanti atau hubungi bantuan.",
        code: errMsg
      });
    } finally {
      setSaving(false);
    }
  };

  // ── Hitung statistik ────────────────────────────────────
  const tercapai = Object.values(perawatanMap).filter((p) => p.jawaban === true).length;
  const total = kategoriList.length;

  // ── Kelompokkan kategori berdasarkan rentang_usia ───────
  const grouped = kategoriList.reduce((acc, k) => {
    const key = k.rentang_usia || "Umum";
    if (!acc[key]) acc[key] = [];
    acc[key].push(k);
    return acc;
  }, {});

  if (loading) {
    return (
      <MainLayout>
        <div className="p-6 text-center text-slate-400">Memuat data...</div>
      </MainLayout>
    );
  }

  return (
    <MainLayout>
      <AlertNotification 
        notification={notification} 
        onClose={() => setNotification(null)} 
        onRetry={notification?.type === "error" ? () => setNotification(null) : null}
      />
      <div className="p-6 space-y-6 bg-[#F8FAFC] min-h-screen">

        {/* Header */}
        <div className="flex items-center gap-4 mb-2">
          <Link
            to="/pemantauan/perkembangan"
            className="p-2 hover:bg-slate-100 rounded-lg transition-colors flex items-center justify-center text-slate-600"
          >
            <ChevronLeft size={24} />
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-slate-800">Lembar Perawatan Anak</h1>
            <p className="text-slate-500 text-sm">Catat pencapaian indikator perkembangan anak</p>
          </div>
        </div>

        {/* Info Anak */}
        {child && (
          <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
            <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
              <div>
                <p className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-1">Nama Anak</p>
                <p className="text-lg font-bold text-slate-800">{child.nama}</p>
              </div>
              <div>
                <p className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-1">Usia</p>
                <p className="text-lg font-bold text-slate-800">{child.usia_teks || "-"}</p>
              </div>
              <div>
                <p className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-1">Ibu</p>
                <p className="text-lg font-bold text-slate-800">{child.kehamilan?.ibu?.nama_ibu || "-"}</p>
              </div>
              <div>
                <p className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-1">Capaian</p>
                <p className="text-2xl font-bold text-blue-600">
                  {tercapai}/{total}
                </p>
              </div>
            </div>
          </div>
        )}

        {/* Tanggal Pemeriksaan */}
        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm">
          <div className="flex items-center gap-3">
            <Calendar size={20} className="text-slate-400" />
            <div>
              <label className="text-xs font-bold text-slate-400 uppercase tracking-wider block mb-1">
                Tanggal Pemeriksaan
              </label>
              <input
                type="date"
                value={activeDate}
                onChange={(e) => setActiveDate(e.target.value)}
                className="px-4 py-2 border border-slate-200 rounded-lg text-slate-700 focus:border-blue-500 outline-none"
              />
            </div>
          </div>
        </div>

        {/* Checklist per Rentang Usia */}
        {total === 0 ? (
          <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-12 text-center">
            <p className="text-slate-400 text-sm">
              Belum ada indikator perawatan. Tambahkan melalui menu{" "}
              <strong>Kelola Perawatan Anak</strong>.
            </p>
          </div>
        ) : (
          Object.entries(grouped).map(([rentang, items]) => (
            <div key={rentang} className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
              <div className="p-5 border-b border-slate-100 bg-slate-50">
                <h2 className="text-base font-bold text-slate-700">
                  Rentang Usia: <span className="text-blue-600">{rentang}</span>
                </h2>
              </div>

              <div className="divide-y divide-slate-100">
                {items.map((kategori) => {
                  const record = perawatanMap[kategori.id];
                  const jawaban = record?.jawaban;

                  return (
                    <div key={kategori.id} className="p-5 hover:bg-slate-50/50 transition-colors">
                      <div className="flex items-center justify-between gap-4">
                        <div className="flex-1">
                          <p className="font-semibold text-slate-800 text-sm leading-snug">
                            {kategori.pertanyaan_ceklist || `Indikator #${kategori.id}`}
                          </p>
                          {kategori.aspek && (
                            <span className="mt-1 inline-block text-xs px-2 py-0.5 bg-blue-50 text-blue-600 rounded-full">
                              {kategori.aspek}
                            </span>
                          )}
                        </div>

                        {/* Tombol Ya / Tidak */}
                        <div className="flex items-center gap-2 flex-shrink-0">
                          <button
                            onClick={() => handleJawabanChange(kategori.id, true)}
                            title="Tercapai"
                            className={`p-2.5 rounded-lg transition-all ${
                              jawaban === true
                                ? "bg-green-100 text-green-600 shadow-sm ring-2 ring-green-300"
                                : "bg-slate-100 text-slate-400 hover:bg-slate-200"
                            }`}
                          >
                            <CheckCircle2 size={20} />
                          </button>
                          <button
                            onClick={() => handleJawabanChange(kategori.id, false)}
                            title="Belum Tercapai"
                            className={`p-2.5 rounded-lg transition-all ${
                              jawaban === false
                                ? "bg-red-100 text-red-600 shadow-sm ring-2 ring-red-300"
                                : "bg-slate-100 text-slate-400 hover:bg-slate-200"
                            }`}
                          >
                            <XCircle size={20} />
                          </button>
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          ))
        )}

        {/* Tombol Simpan */}
        {total > 0 && (
          <div className="flex gap-3">
            <button
              onClick={loadData}
              disabled={loading}
              className="flex items-center gap-2 bg-slate-100 hover:bg-slate-200 text-slate-700 px-5 py-3 rounded-lg font-semibold transition-all"
            >
              <RefreshCw size={18} />
              Refresh
            </button>
            <button
              onClick={handleSave}
              disabled={saving}
              className="flex-1 flex items-center justify-center gap-2 bg-blue-600 hover:bg-blue-700 disabled:bg-slate-300 text-white px-6 py-3 rounded-lg font-semibold transition-all"
            >
              <Save size={20} />
              {saving ? "Menyimpan..." : "Simpan Perawatan"}
            </button>
          </div>
        )}
      </div>
    </MainLayout>
  );
}
