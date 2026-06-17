import React, { useEffect, useState, useMemo, useCallback } from "react";
import { useParams, useNavigate } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import AlertNotification from "../../components/AlertNotification";
import { PelayananGiziService } from "../../services/Pelayanan-gizi-anak";
import { getAnakById } from "../../services/Anak";
import {
  Plus, Baby, Loader2, Check, X, Save,
  Utensils, Droplets, Info, ChevronRight, Calendar, ArrowLeft, User
} from 'lucide-react';

const PelayananGiziIndex = () => {
  const { id: anakId } = useParams();
  const navigate = useNavigate();

  // --- STATE MANAGEMENT ---
  const [riwayat, setRiwayat] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [notification, setNotification] = useState(null);
  const [anakData, setAnakData] = useState(null);

  const authUser = useMemo(() => {
    try {
      const storedUser = localStorage.getItem('user');
      return storedUser ? JSON.parse(storedUser) : { id: 0, nama: 'Petugas' };
    } catch {
      return { id: 0, nama: 'Petugas' };
    }
  }, []);

  const calculateAgeInMonths = useCallback((birthDateString) => {
    if (!birthDateString) return 1;
    const birth = new Date(birthDateString);
    const now = new Date();
    const diffYears = now.getFullYear() - birth.getFullYear();
    const diffMonths = now.getMonth() - birth.getMonth();
    let months = diffYears * 12 + diffMonths;
    if (now.getDate() < birth.getDate()) months--;
    return months < 1 ? 1 : months > 60 ? 60 : months;
  }, []);

  const ageNow = anakData ? calculateAgeInMonths(anakData.tanggal_lahir) : null;

  const initialForm = {
    bulan_ke: ageNow || 1,
    asi: {
      frekuensi_menyusui: "",
      posisi_menyusui: "baik",
      asiperah: "tidak"
    },
    mpasi: {
      sudah_mpasi: false,
      varian_mpasi: [],
      jumlah_makan: "",
      frekuensi_makan: {
        makanan_utama: "",
        makanan_selingan: ""
      }
    },
    obat_cacing: false,
    jenis_pemberian_susu: "ASI Eksklusif",
    masih_menyusui: true,
    menggunakan_formula: false,
    alasan_formula: "",
    usia_mulai_mpasi: 6
  };

  const [formData, setFormData] = useState(initialForm);

  // --- LOGIC FETCH & TABEL ---
  // Bulan 0 dihapus karena tidak relevan secara klinis (bayi 0 bulan hanya ASI)
  const kolomBulan = ["1", "2", "3", "4", "5", "6 - 8", "9 - 11", "12 - 23", "23 - 59"];

  const fetchRiwayat = async () => {
    setLoading(true);
    try {
      const data = await PelayananGiziService.getByAnakId(anakId);
      setRiwayat(Array.isArray(data) ? data : []);
    } catch (err) {
      console.error("Error fetching data:", err);
    } finally {
      setLoading(false);
    }
  };

  const fetchAnak = async () => {
    try {
      const res = await getAnakById(anakId);
      if (res && res.data) setAnakData(res.data);
    } catch (err) {
      console.error("Gagal mengambil data anak:", err);
    }
  };

  useEffect(() => {
    if (anakId) {
      fetchRiwayat();
      fetchAnak();
    }
  }, [anakId]);

  const handleOpenModal = () => {
    const currentAge = anakData ? calculateAgeInMonths(anakData.tanggal_lahir) : 1;
    setFormData({
      ...initialForm,
      bulan_ke: currentAge
    });
    setIsModalOpen(true);
  };

  const isMatchBulan = (bulanData, labelKolom) => {
    if (labelKolom.includes("-")) {
      const [min, max] = labelKolom.split("-").map(s => parseInt(s.trim()));
      return bulanData >= min && bulanData <= max;
    }
    return bulanData === parseInt(labelKolom);
  };

  const getCellContent = (labelKolom, fn, type = "check") => {
    const match = riwayat.find(item => isMatchBulan(item.bulan, labelKolom));
    if (!match) return null;
    const val = fn(match);
    if (val === undefined || val === null) return null;
    if (type === "text") return val;
    if (val === false) return null;
    return "checkmark";
  };

  // --- FORM HANDLERS ---
  // --- FORM HANDLERS ---
  const requestPayload = useMemo(() => {
    const formatFrekuensi = () => {
      const utama = formData.mpasi.frekuensi_makan.makanan_utama || "0";
      const selingan = formData.mpasi.frekuensi_makan.makanan_selingan || "0";
      const cleanUtama = utama.replace('/hari', '').toLowerCase();
      const cleanSelingan = selingan.replace('/hari', '').toLowerCase();
      return `${cleanUtama} utama, ${cleanSelingan} selingan`;
    };

    const bulan = parseInt(formData.bulan_ke);

    return {
      anak_id: parseInt(anakId),
      tanggal: new Date().toISOString().split('T')[0],
      tenaga_kesehatan_id: parseInt(authUser.id || authUser.user_id || 0),
      bulan_ke: bulan,
      lokasi: authUser.lokasi || "Puskesmas Medan",

      asi: bulan < 24 ? {
        frekuensi_menyusui: parseInt(formData.asi.frekuensi_menyusui) || 0,
        posisi_menyusui: formData.asi.posisi_menyusui,
        asi_perah: formData.asi.asiperah
      } : null,

      mpasi: (bulan >= 6) ? {
        diberikan_mp_asi: formData.mpasi.sudah_mpasi,
        variasi_mpasi: formData.mpasi.varian_mpasi.map(v => v.toLowerCase()),
        jumlah_makan_perporsi: formData.mpasi.jumlah_makan || "-",
        frekuensi_makan_perhari: formData.mpasi.sudah_mpasi ? formatFrekuensi() : "-"
      } : null,

      obat_cacing: (bulan >= 24) ? formData.obat_cacing : null,
      jenis_pemberian_susu: bulan < 24 ? formData.jenis_pemberian_susu : "",
      masih_menyusui: (bulan >= 6) ? formData.masih_menyusui : null,
      menggunakan_formula: (bulan < 24) ? (formData.jenis_pemberian_susu === "ASI + Formula" || formData.jenis_pemberian_susu === "Formula") : false,
      alasan_formula: (bulan < 24 && (formData.jenis_pemberian_susu === "ASI + Formula" || formData.jenis_pemberian_susu === "Formula")) ? formData.alasan_formula : "",
      usia_mulai_mpasi: (bulan >= 6 && formData.mpasi.sudah_mpasi) ? parseInt(formData.usia_mulai_mpasi) : null
    };
  }, [formData, anakId, authUser]);

  const handleSave = async () => {
    const bulan = parseInt(formData.bulan_ke);

    if (bulan < 6 && formData.mpasi.sudah_mpasi) {
      setNotification({
        type: "error",
        message: "MPASI hanya dapat diberikan mulai usia 6 bulan."
      });
      return;
    }

    if (bulan < 24 && formData.asi.frekuensi_menyusui === "") {
      setNotification({
        type: "error",
        message: "Mohon isi frekuensi menyusui."
      });
      return;
    }

    setSubmitting(true);
    try {
      console.log("[Gizi] Payload:", JSON.stringify(requestPayload, null, 2));
      await PelayananGiziService.create(requestPayload);
      setIsModalOpen(false);
      setFormData(initialForm);
      await fetchRiwayat();
      setNotification({
        type: "success",
        message: "Data pelayanan gizi berhasil disimpan ke dalam sistem!"
      });
    } catch (err) {
      const errorMsg = err.response?.data?.error || err.response?.data?.message || err.message;
      console.error("[Gizi] Error:", errorMsg, err.response?.data);
      setNotification({
        type: "error",
        message: errorMsg || "Permintaan gagal diproses.",
        code: errorMsg
      });
    } finally {
      setSubmitting(false);
    }
  };
  return (
    <MainLayout>
      <AlertNotification
        notification={notification}
        onClose={() => setNotification(null)}
        onRetry={notification?.type === "error" ? () => {
          setNotification(null);
          setIsModalOpen(true);
        } : null}
      />
      <div className="max-w-7xl mx-auto p-4 md:p-8 bg-slate-50 min-h-screen font-sans">

        {/* NAVIGASI KEMBALI */}
        <button
          onClick={() => navigate(`/data-anak/dashboard/${anakId}`)}
          className="flex items-center gap-2 px-6 py-2 border border-blue-600 text-blue-600 hover:bg-blue-50 rounded-full font-medium text-sm transition-all group w-fit mb-6 mt-2"
        >
          <ArrowLeft size={16} className="group-hover:-translate-x-1 transition-transform" /> Kembali
        </button>

        {/* HEADER SECTION */}
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-6 mb-8">
          <div>
            <h1 className="text-3xl font-bold text-slate-800 tracking-tight flex items-center gap-3">
              <Baby className="text-blue-600" size={32} />
              Monitoring Gizi & Nutrisi
            </h1>
            <p className="text-slate-500 text-sm mt-1">Pantau perkembangan asupan nutrisi anak secara berkala.</p>
          </div>
          <button
            onClick={handleOpenModal}
            className="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-xl font-bold text-sm shadow-md transition-all active:scale-95"
          >
            <Plus size={18} /> Tambah Data Pelayanan
          </button>
        </div>

        {/* TABLE VIEW */}
        {loading ? (
          <div className="flex flex-col items-center justify-center py-32 bg-white rounded-3xl border border-slate-200">
            <Loader2 className="animate-spin text-blue-600 mb-4" size={40} />
            <p className="text-slate-400 text-sm font-medium">Memproses data riwayat...</p>
          </div>
        ) : (
          <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse">
                <thead>
                  <tr className="bg-slate-50 text-slate-600 text-[11px] uppercase tracking-wider border-b border-slate-200">
                    <th colSpan="2" className="p-5 font-bold border-r border-slate-100">Indikator Pemantauan</th>
                    {kolomBulan.map(b => (
                      <th key={b} className="p-3 text-center border-r border-slate-100 w-24">Bulan {b}</th>
                    ))}
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  <SectionHeader label="Pola Pemberian ASI & Susu" />
                  <DataRow label="Jenis Pemberian Susu" type="text" kolom={kolomBulan} getContent={getCellContent} fn={(d) => d.jenis_pemberian_susu || "-"} />
                  <DataRow label="Masih Menyusui" type="text" kolom={kolomBulan} getContent={getCellContent} fn={(d) => d.masih_menyusui !== null && d.masih_menyusui !== undefined ? (d.masih_menyusui ? "Ya" : "Tidak") : "-"} />
                  <DataRow label="Menggunakan Susu Formula" type="text" kolom={kolomBulan} getContent={getCellContent} fn={(d) => d.menggunakan_formula !== null && d.menggunakan_formula !== undefined ? (d.menggunakan_formula ? "Ya" : "Tidak") : "-"} />
                  <DataRow label="Alasan Pemberian Formula" type="text" kolom={kolomBulan} getContent={getCellContent} fn={(d) => d.alasan_formula || "-"} />
                  <DataRow label="Frekuensi Menyusui (Kali/Hari)" type="text" kolom={kolomBulan} getContent={getCellContent} fn={(d) => d.ASI?.frekuensi_menyusui} />
                  <DataRow label="Posisi Menyusu Sudah Baik" type="check" kolom={kolomBulan} getContent={getCellContent} fn={(d) => d.ASI?.posisi_menyusui === "baik"} />
                  <DataRow label="Diberikan ASI Perah (ASIP)" type="check" kolom={kolomBulan} getContent={getCellContent} fn={(d) => d.ASI?.asi_perah === "ya"} />

                  <SectionHeader label="Status & Variasi MPASI" />
                  <DataRow label="Sudah Mendapat MPASI" type="check" kolom={kolomBulan} getContent={getCellContent} fn={(d) => d.MPASI?.diberikan_mp_asi === true} />
                  <DataRow label="Usia Mulai MPASI" type="text" kolom={kolomBulan} getContent={getCellContent} fn={(d) => d.usia_mulai_mpasi !== null && d.usia_mulai_mpasi !== undefined ? `${d.usia_mulai_mpasi} Bulan` : "-"} />
                  <DataRow label="Variasi: Karbohidrat" type="check" kolom={kolomBulan} getContent={getCellContent} fn={(d) => d.MPASI?.variasi_mpasi?.some(v => ["nasi", "beras", "bubur", "makanan pokok"].includes(v.toLowerCase()))} />
                  <DataRow label="Variasi: Protein Hewani/Nabati" type="check" kolom={kolomBulan} getContent={getCellContent} fn={(d) => d.MPASI?.variasi_mpasi?.some(v => ["lauk", "protein", "ayam", "ikan", "telur"].includes(v.toLowerCase()))} />
                  <DataRow label="Variasi: Sayur & Buah" type="check" kolom={kolomBulan} getContent={getCellContent} fn={(d) => d.MPASI?.variasi_mpasi?.some(v => ["sayur", "buah"].includes(v.toLowerCase()))} />

                  <SectionHeader label="Porsi & Jadwal Makan" />
                  <DataRow label="Jumlah Porsi per Makan" type="text" kolom={kolomBulan} getContent={getCellContent} fn={(d) => d.MPASI?.jumlah_makan_perporsi} />
                  <DataRow label="Frekuensi Makan per Hari" type="text" kolom={kolomBulan} getContent={getCellContent} fn={(d) => d.MPASI?.frekuensi_makan_perhari} />

                  <SectionHeader label="Pemberian Obat Cacing" />
                  <DataRow label="Status Pemberian Obat Cacing" type="text" kolom={kolomBulan} getContent={getCellContent} fn={(d) => {
                    if (parseInt(d.bulan) < 24) return "Belum Direkomendasikan";
                    return d.obat_cacing !== undefined && d.obat_cacing !== null ? (d.obat_cacing ? "Sudah" : "Belum") : "-";
                  }} />
                </tbody>
              </table>
            </div>
          </div>
        )}

        {/* FORM MODAL */}
        {isModalOpen && (
          <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-slate-900/40 backdrop-blur-sm overflow-y-auto">
            <div className="bg-white w-full max-w-4xl rounded-3xl shadow-2xl overflow-hidden flex flex-col max-h-[90vh] animate-in fade-in zoom-in duration-200">

              {/* MODAL HEADER */}
              <div className="px-8 py-6 border-b border-slate-100 flex justify-between items-center bg-white sticky top-0 z-10">
                <div>
                  <h2 className="text-xl font-bold text-slate-800">Form Input Pelayanan Gizi</h2>
                  <div className="flex items-center gap-3 mt-1">
                    <p className="text-xs text-slate-400 uppercase font-bold tracking-widest">Petugas: {authUser.nama}</p>
                    {ageNow && (
                      <span className="inline-flex items-center gap-1.5 px-3 py-1 bg-blue-50 text-blue-700 text-[10px] font-black rounded-full border border-blue-100">
                        <User size={10} /> Usia Anak: <strong>{ageNow} Bulan</strong>
                      </span>
                    )}
                  </div>
                </div>
                <button onClick={() => setIsModalOpen(false)} className="p-2 hover:bg-slate-100 rounded-full transition-colors text-slate-400">
                  <X size={20} />
                </button>
              </div>

              {/* MODAL BODY */}
              <div className="p-8 overflow-y-auto custom-scrollbar bg-slate-50/30">

                {/* INFO BANNER */}


                {/* EDUCATIONAL/SCHEDULE BANNER FOR OBAT CACING */}
                {parseInt(formData.bulan_ke) < 24 ? (
                  <div className="flex items-start gap-4 bg-orange-50 p-4 rounded-2xl border border-orange-100 mb-6">
                    <Info size={20} className="text-orange-600 shrink-0 mt-0.5" />
                    <div className="text-sm text-orange-800 leading-relaxed">
                      <strong>Info Obat Cacing:</strong> Belum masuk usia rekomendasi pemberian obat cacing menurut IDAI.
                    </div>
                  </div>
                ) : (
                  <div className="flex items-start gap-4 bg-rose-50 p-4 rounded-2xl border border-rose-100 mb-6">
                    <Info size={20} className="text-rose-600 shrink-0 mt-0.5" />
                    <div className="text-sm text-rose-800 leading-relaxed">
                      <strong>🚨 Jadwal Suplementasi Obat Cacing:</strong> Anak berada di usia <strong>{`${formData.bulan_ke} bulan >= 24 bulan`}</strong>. Jadwalkan pemberian obat cacing dan catat statusnya di bawah.</div>
                  </div>
                )}

                <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">

                  {/* LEFT COLUMN: BASIC & ASI */}
                  <div className="space-y-6">
                    <section className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
                      <h4 className="text-sm font-bold text-slate-800 mb-4 flex items-center gap-2">
                        <Calendar size={18} className="text-blue-500" /> Waktu Kunjungan
                      </h4>
                      <div className="space-y-1">
                        <label className="text-[11px] font-bold text-slate-400 uppercase tracking-wider">
                          Bulan Ke-{ageNow ? ` (Usia Sekarang: ${ageNow} Bulan)` : ""}
                        </label>
                        <select
                          className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm font-semibold outline-none focus:ring-2 ring-blue-100 transition-all"
                          value={formData.bulan_ke}
                          onChange={(e) => {
                            const newBulan = parseInt(e.target.value);
                            setFormData({
                              ...formData,
                              bulan_ke: newBulan,
                              mpasi: {
                                ...formData.mpasi,
                                sudah_mpasi: newBulan >= 6 ? formData.mpasi.sudah_mpasi : false
                              }
                            });
                          }}
                        >
                          {[...Array(60)].map((_, m) => (
                            <option key={m} value={m + 1}>
                              Bulan {m + 1}{ageNow === m + 1 ? " ← Usia Sekarang" : ""}
                            </option>
                          ))}
                        </select>
                      </div>
                    </section>
                    {parseInt(formData.bulan_ke) < 6 ? (
                      <section className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-5">
                        <h4 className="text-sm font-bold text-slate-800 mb-2 flex items-center gap-2">
                          <Droplets size={18} className="text-blue-500" /> Pola Pemberian ASI
                        </h4>

                        <div className="space-y-1">
                          <label className="text-[11px] font-bold text-slate-400 uppercase tracking-wider block">Jenis Pemberian Susu</label>
                          <select
                            className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2.5 text-sm outline-none"
                            value={formData.jenis_pemberian_susu}
                            onChange={(e) => {
                              const val = e.target.value;
                              setFormData({
                                ...formData,
                                jenis_pemberian_susu: val,
                                menggunakan_formula: val === "ASI + Formula" || val === "Formula",
                                alasan_formula: (val === "ASI + Formula" || val === "Formula") ? formData.alasan_formula : ""
                              });
                            }}
                          >
                            <option value="ASI Eksklusif">ASI Eksklusif</option>
                            <option value="ASI + Formula">ASI + Formula</option>
                            <option value="Formula">Formula</option>
                          </select>
                        </div>

                        {(formData.jenis_pemberian_susu === "ASI + Formula" || formData.jenis_pemberian_susu === "Formula") && (
                          <div className="space-y-1 animate-in fade-in duration-200">
                            <label className="text-[11px] font-bold text-slate-400 uppercase tracking-wider block">Alasan Pemberian Formula</label>
                            <select
                              className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2.5 text-sm outline-none"
                              value={formData.alasan_formula}
                              onChange={(e) => setFormData({ ...formData, alasan_formula: e.target.value })}
                            >
                              <option value="">Pilih Alasan...</option>
                              <option value="Produksi ASI kurang">Produksi ASI kurang</option>
                              <option value="Ibu bekerja">Ibu bekerja</option>
                              <option value="Kondisi medis ibu">Kondisi medis ibu</option>
                              <option value="Bayi sulit menyusu">Bayi sulit menyusu</option>
                              <option value="Lainnya">Lainnya</option>
                            </select>
                          </div>
                        )}

                        <div className="space-y-1">
                          <label className="text-[11px] font-bold text-slate-400 uppercase tracking-wider block">Frekuensi Menyusui (Kali/Hari)</label>
                          <input
                            type="number" placeholder="Contoh: 8"
                            className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm focus:bg-white focus:ring-2 ring-blue-100 outline-none transition-all"
                            value={formData.asi.frekuensi_menyusui}
                            onChange={(e) => setFormData({ ...formData, asi: { ...formData.asi, frekuensi_menyusui: e.target.value } })}
                          />
                        </div>

                        <div className="grid grid-cols-2 gap-4">
                          <div className="space-y-1">
                            <label className="text-[11px] font-bold text-slate-400 uppercase tracking-wider block">Posisi Menyusu</label>
                            <select
                              className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2.5 text-sm outline-none"
                              value={formData.asi.posisi_menyusui}
                              onChange={(e) => setFormData({ ...formData, asi: { ...formData.asi, posisi_menyusui: e.target.value } })}
                            >
                              <option value="baik">Sudah Baik</option>
                              <option value="tidak">Perlu Perbaikan</option>
                            </select>
                          </div>
                          <div className="space-y-1">
                            <label className="text-[11px] font-bold text-slate-400 uppercase tracking-wider block">Gunakan ASIP?</label>
                            <select
                              className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2.5 text-sm outline-none"
                              value={formData.asi.asiperah}
                              onChange={(e) => setFormData({ ...formData, asi: { ...formData.asi, asiperah: e.target.value } })}
                            >
                              <option value="tidak">Tidak</option>
                              <option value="ya">Ya</option>
                            </select>
                          </div>
                        </div>
                      </section>
                    ) : parseInt(formData.bulan_ke) < 24 ? (
                      <section className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-5">
                        <h4 className="text-sm font-bold text-slate-800 mb-2 flex items-center gap-2">
                          <Droplets size={18} className="text-blue-500" /> Pola Pemberian ASI & Susu
                        </h4>

                        <div className="grid grid-cols-2 gap-4">
                          <div className="space-y-1">
                            <label className="text-[11px] font-bold text-slate-400 uppercase tracking-wider block">Masih Mendapat ASI?</label>
                            <select
                              className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2.5 text-sm outline-none"
                              value={formData.masih_menyusui ? "ya" : "tidak"}
                              onChange={(e) => setFormData({ ...formData, masih_menyusui: e.target.value === "ya" })}
                            >
                              <option value="ya">Ya</option>
                              <option value="tidak">Tidak</option>
                            </select>
                          </div>

                          <div className="space-y-1">
                            <label className="text-[11px] font-bold text-slate-400 uppercase tracking-wider block">Jenis Pemberian Susu</label>
                            <select
                              className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2.5 text-sm outline-none"
                              value={formData.jenis_pemberian_susu}
                              onChange={(e) => {
                                const val = e.target.value;
                                setFormData({
                                  ...formData,
                                  jenis_pemberian_susu: val,
                                  menggunakan_formula: val === "ASI + Formula" || val === "Formula",
                                  alasan_formula: (val === "ASI + Formula" || val === "Formula") ? formData.alasan_formula : ""
                                });
                              }}
                            >
                              <option value="ASI">ASI</option>
                              <option value="ASI + Formula">ASI + Formula</option>
                              <option value="Formula">Formula</option>
                            </select>
                          </div>
                        </div>

                        {(formData.jenis_pemberian_susu === "ASI + Formula" || formData.jenis_pemberian_susu === "Formula") && (
                          <div className="space-y-1 animate-in fade-in duration-200">
                            <label className="text-[11px] font-bold text-slate-400 uppercase tracking-wider block">Alasan Pemberian Formula</label>
                            <select
                              className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2.5 text-sm outline-none"
                              value={formData.alasan_formula}
                              onChange={(e) => setFormData({ ...formData, alasan_formula: e.target.value })}
                            >
                              <option value="">Pilih Alasan...</option>
                              <option value="Produksi ASI kurang">Produksi ASI kurang</option>
                              <option value="Ibu bekerja">Ibu bekerja</option>
                              <option value="Kondisi medis ibu">Kondisi medis ibu</option>
                              <option value="Bayi sulit menyusu">Bayi sulit menyusu</option>
                              <option value="Lainnya">Lainnya</option>
                            </select>
                          </div>
                        )}

                        <div className="space-y-1">
                          <label className="text-[11px] font-bold text-slate-400 uppercase tracking-wider block">Frekuensi Menyusui (Kali/Hari)</label>
                          <input
                            type="number" placeholder="Contoh: 8"
                            className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm focus:bg-white focus:ring-2 ring-blue-100 outline-none transition-all"
                            value={formData.asi.frekuensi_menyusui}
                            onChange={(e) => setFormData({ ...formData, asi: { ...formData.asi, frekuensi_menyusui: e.target.value } })}
                          />
                        </div>

                        <div className="grid grid-cols-2 gap-4">
                          <div className="space-y-1">
                            <label className="text-[11px] font-bold text-slate-400 uppercase tracking-wider block">Posisi Menyusu</label>
                            <select
                              className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2.5 text-sm outline-none"
                              value={formData.asi.posisi_menyusui}
                              onChange={(e) => setFormData({ ...formData, asi: { ...formData.asi, posisi_menyusui: e.target.value } })}
                            >
                              <option value="baik">Sudah Baik</option>
                              <option value="tidak">Perlu Perbaikan</option>
                            </select>
                          </div>
                          <div className="space-y-1">
                            <label className="text-[11px] font-bold text-slate-400 uppercase tracking-wider block">Gunakan ASIP?</label>
                            <select
                              className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2.5 text-sm outline-none"
                              value={formData.asi.asiperah}
                              onChange={(e) => setFormData({ ...formData, asi: { ...formData.asi, asiperah: e.target.value } })}
                            >
                              <option value="tidak">Tidak</option>
                              <option value="ya">Ya</option>
                            </select>
                          </div>
                        </div>
                      </section>
                    ) : (
                      <section className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-5">
                        <h4 className="text-sm font-bold text-slate-800 mb-2 flex items-center gap-2">
                          <Droplets size={18} className="text-blue-500" /> Pola Menyusui
                        </h4>
                        <div className="space-y-1">
                          <label className="text-[11px] font-bold text-slate-400 uppercase tracking-wider block">Masih Menyusui?</label>
                          <select
                            className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2.5 text-sm outline-none"
                            value={formData.masih_menyusui ? "ya" : "tidak"}
                            onChange={(e) => setFormData({ ...formData, masih_menyusui: e.target.value === "ya" })}
                          >
                            <option value="ya">Ya</option>
                            <option value="tidak">Tidak</option>
                          </select>
                        </div>
                      </section>
                    )}

                    {/* OBAT CACING SECTION */}
                    {parseInt(formData.bulan_ke) >= 24 && (
                      <section className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-4">
                        <h4 className="text-sm font-bold text-slate-800 flex items-center gap-2">
                          <Info size={18} className="text-rose-500" /> Pemberian Obat Cacing
                        </h4>
                        <div className="flex justify-between items-center bg-slate-50 p-3 rounded-xl border border-slate-100">
                          <span className="text-xs font-semibold text-slate-600">Apakah obat cacing sudah diberikan?</span>
                          <div className="flex bg-slate-200/60 p-0.5 rounded-lg">
                            {[{ l: 'Sudah', v: true }, { l: 'Belum', v: false }].map(item => (
                              <button
                                key={item.l}
                                type="button"
                                onClick={() => setFormData({ ...formData, obat_cacing: item.v })}
                                className={`px-4 py-1.5 text-[10px] font-bold rounded-md transition-all ${formData.obat_cacing === item.v ? 'bg-white text-blue-600 shadow-sm' : 'text-slate-500'}`}
                              >
                                {item.l.toUpperCase()}
                              </button>
                            ))}
                          </div>
                        </div>
                      </section>
                    )}
                  </div>

                  {/* RIGHT COLUMN: MPASI */}
                  <div className="space-y-6">
                    {parseInt(formData.bulan_ke) < 6 ? (
                      <div className="py-16 px-6 flex flex-col items-center justify-center border-2 border-dashed border-slate-200 bg-white rounded-3xl text-center shadow-sm">
                        <Utensils size={48} className="text-slate-300 mb-4 shrink-0" />
                        <h4 className="text-sm font-bold text-slate-700 mb-2">MPASI Belum Tersedia</h4>
                        <p className="text-xs text-slate-400 leading-relaxed max-w-xs">
                          Status MPASI tidak tersedia untuk anak usia di bawah 6 bulan. Anak di fase ini hanya diperbolehkan mendapatkan ASI Eksklusif (atau susu formula jika ibu tidak dapat menghasilkan ASI).
                        </p>
                      </div>
                    ) : (
                      <section className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
                        <div className="flex items-center justify-between mb-6">
                          <h4 className="text-sm font-bold text-slate-800 flex items-center gap-2">
                            <Utensils size={18} className="text-orange-500" /> Status MPASI
                          </h4>
                          <div className="flex bg-slate-100 p-1 rounded-lg">
                            {[{ l: 'Sudah', v: true }, { l: 'Belum', v: false }].map(item => (
                              <button
                                key={item.l}
                                type="button"
                                onClick={() => setFormData({ ...formData, mpasi: { ...formData.mpasi, sudah_mpasi: item.v } })}
                                className={`px-4 py-1.5 text-[10px] font-bold rounded-md transition-all ${formData.mpasi.sudah_mpasi === item.v ? 'bg-white text-blue-600 shadow-sm' : 'text-slate-400'}`}
                              >
                                {item.l.toUpperCase()}
                              </button>
                            ))}
                          </div>
                        </div>

                        {parseInt(formData.bulan_ke) >= 12 && parseInt(formData.bulan_ke) <= 24 && (
                          <div className="p-4 bg-blue-50 border border-blue-100 rounded-2xl flex items-start gap-3 mb-4">
                            <Info size={16} className="text-blue-600 shrink-0 mt-0.5" />
                            <div className="text-xs text-blue-800 leading-relaxed">
                              <strong>Rekomendasi Usia 1-2 Tahun:</strong> Pada rentang usia 1-2 tahun (12-24 bulan), anak dapat diberikan makanan tambahan dengan proporsi nutrisi: <strong>ASI 30% dan MPASI 70%</strong>.
                            </div>
                          </div>
                        )}

                        {formData.mpasi.sudah_mpasi ? (
                          <div className="space-y-6 animate-in fade-in slide-in-from-top-2 duration-300">

                            <div className="space-y-1">
                              <label className="text-[11px] font-bold text-slate-400 uppercase tracking-wider block">Usia Mulai MPASI (Bulan)</label>
                              <input
                                type="number"
                                placeholder="Contoh: 6"
                                className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm focus:bg-white focus:ring-2 ring-orange-100 outline-none transition-all"
                                value={formData.usia_mulai_mpasi}
                                onChange={(e) => setFormData({ ...formData, usia_mulai_mpasi: e.target.value })}
                              />
                            </div>

                            <div className="space-y-2">
                              <label className="text-[11px] font-bold text-slate-400 uppercase tracking-wider block">Variasi Makanan</label>
                              <div className="flex flex-wrap gap-2">
                                {['Nasi', 'Sayur', 'Buah', 'Lauk Pauk', 'Lemak'].map(item => {
                                  const isSelected = formData.mpasi.varian_mpasi.includes(item);
                                  return (
                                    <button
                                      key={item}
                                      type="button"
                                      onClick={() => {
                                        const next = isSelected
                                          ? formData.mpasi.varian_mpasi.filter(i => i !== item)
                                          : [...formData.mpasi.varian_mpasi, item];
                                        setFormData({ ...formData, mpasi: { ...formData.mpasi, varian_mpasi: next } });
                                      }}
                                      className={`px-3 py-1.5 rounded-lg text-xs font-semibold border transition-all ${isSelected ? 'bg-orange-50 border-orange-200 text-orange-600' : 'bg-white border-slate-200 text-slate-500 hover:bg-slate-50'}`}
                                    >
                                      {isSelected ? '✓ ' : '+ '} {item}
                                    </button>
                                  );
                                })}
                              </div>
                            </div>

                            <div className="space-y-4">
                              <div className="space-y-1">
                                <label className="text-[11px] font-bold text-slate-400 uppercase tracking-wider block">Porsi per Makan</label>
                                <select
                                  className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm outline-none focus:ring-2 ring-orange-100 transition-all"
                                  value={formData.mpasi.jumlah_makan}
                                  onChange={(e) => setFormData({ ...formData, mpasi: { ...formData.mpasi, jumlah_makan: e.target.value } })}
                                >
                                  <option value="">Pilih Ukuran Porsi...</option>
                                  <option value="2 - 3 sdm (1/2 mangkok ukuran 250 ml)">2 - 3 sdm (1/2 mangkok 250 ml)</option>
                                  <option value="1/2 - 3/4 mangkok (ukuran 250 ml)">1/2 - 3/4 mangkok (250 ml)</option>
                                  <option value="3/4 - 1 mangkok (ukuran 250 ml)">3/4 - 1 mangkok (250 ml)</option>
                                  <option value="1 mangkok (ukuran 250 ml)">1 mangkok (250 ml)</option>
                                </select>
                              </div>

                              <div className="grid grid-cols-2 gap-4">
                                <div className="space-y-1">
                                  <label className="text-[11px] font-bold text-slate-400 uppercase tracking-wider block">Makanan Utama</label>
                                  <select
                                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2.5 text-sm outline-none focus:ring-2 ring-orange-100"
                                    value={formData.mpasi.frekuensi_makan.makanan_utama}
                                    onChange={(e) => setFormData({ ...formData, mpasi: { ...formData.mpasi, frekuensi_makan: { ...formData.mpasi.frekuensi_makan, makanan_utama: e.target.value } } })}
                                  >
                                    <option value="">Frekuensi...</option>
                                    <option value="1x/hari">1x / hari</option>
                                    <option value="2x/hari">2x / hari</option>
                                    <option value="3x/hari">3x / hari</option>
                                  </select>
                                </div>
                                <div className="space-y-1">
                                  <label className="text-[11px] font-bold text-slate-400 uppercase tracking-wider block">Selingan</label>
                                  <select
                                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2.5 text-sm outline-none focus:ring-2 ring-orange-100"
                                    value={formData.mpasi.frekuensi_makan.makanan_selingan}
                                    onChange={(e) => setFormData({ ...formData, mpasi: { ...formData.mpasi, frekuensi_makan: { ...formData.mpasi.frekuensi_makan, makanan_selingan: e.target.value } } })}
                                  >
                                    <option value="">Frekuensi...</option>
                                    <option value="0x/hari">Tidak Ada</option>
                                    <option value="1x/hari">1x / hari</option>
                                    <option value="2x/hari">2x / hari</option>
                                  </select>
                                </div>
                              </div>
                            </div>
                          </div>
                        ) : (
                          <div className="py-16 flex flex-col items-center justify-center border-2 border-dashed border-slate-100 rounded-2xl">
                            <Utensils size={32} className="text-slate-200 mb-2" />
                            <p className="text-xs font-semibold text-slate-300 italic">Belum waktunya atau belum diberikan MPASI</p>
                          </div>
                        )}
                      </section>
                    )}
                  </div>
                </div>
              </div>

              {/* MODAL FOOTER */}
              <div className="p-6 border-t border-slate-100 bg-white flex justify-end items-center gap-3">
                <button
                  onClick={() => setIsModalOpen(false)}
                  className="px-6 py-2.5 text-slate-500 font-bold text-sm hover:bg-slate-50 rounded-xl transition-all"
                >
                  Batal
                </button>
                <button
                  onClick={handleSave}
                  disabled={submitting}
                  className="px-8 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold text-sm shadow-lg shadow-blue-100 transition-all flex items-center gap-2 disabled:opacity-50"
                >
                  {submitting ? <Loader2 size={18} className="animate-spin" /> : <Save size={18} />}
                  Simpan
                </button>
              </div>
            </div>
          </div>
        )}
      </div>

      <style>{`
        .custom-scrollbar::-webkit-scrollbar { width: 6px; }
        .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
        .custom-scrollbar::-webkit-scrollbar-thumb { background: #e2e8f0; border-radius: 10px; }
      `}</style>
    </MainLayout>
  );
};

// --- SUB-COMPONENTS ---

const SectionHeader = ({ label }) => (
  <tr className="bg-slate-50/50">
    <td colSpan="12" className="px-5 py-3 font-bold text-blue-600 text-[10px] uppercase tracking-widest">{label}</td>
  </tr>
);

const DataRow = ({ label, kolom, type, getContent, fn }) => (
  <tr className="group hover:bg-slate-50 transition-colors border-b border-slate-50">
    <td className="w-1 bg-slate-200 group-hover:bg-blue-400 transition-colors"></td>
    <td className="p-4 font-medium text-slate-700 min-w-[240px] text-sm">{label}</td>
    {kolom.map(bln => {
      const content = getContent(bln, fn, type);
      return (
        <td key={bln} className="p-3 text-center border-r border-slate-50 last:border-r-0">
          {type === "check" ? (
            content === "checkmark" ? (
              <div className="flex justify-center">
                <div className="p-1 bg-green-50 rounded-full">
                  <Check size={16} className="text-green-600 stroke-[3px]" />
                </div>
              </div>
            ) : null
          ) : (
            <span className="font-bold text-blue-600 text-xs">{content || "-"}</span>
          )}
        </td>
      );
    })}
  </tr>
);

export default PelayananGiziIndex;