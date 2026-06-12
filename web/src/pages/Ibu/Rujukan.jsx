// src/pages/Ibu/Rujukan.jsx
import React, { useEffect, useState } from "react";
import { useParams, useSearchParams, useNavigate } from "react-router-dom";
import Swal from "sweetalert2";
import MainLayout from "../../components/Layout/MainLayout";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import { getPemeriksaanKehamilanByKehamilanId } from "../../services/pemeriksaanKehamilan";
import {
  getRujukanByKehamilanId,
  createRujukan,
  updateRujukan,
} from "../../services/rujukanService";
import { getCurrentUser, isBidanUser, isDokterUser } from "../../services/auth";
import {
  Save, Plus, Edit2, CheckCircle, X, Eye, EyeOff,
  ArrowLeft, AlertTriangle, User, Stethoscope, FileText, Clock,
} from "lucide-react";

// ─────────────────────────────────────────────
// Helper: hitung status risiko dari pemeriksaan
// terakhir (sama dengan logika di halaman list)
// ─────────────────────────────────────────────
const hitungStatusRisiko = (exam) => {
  if (!exam) return { status_risiko: "-", ringkasan: "-", faktor: [] };
  const faktor = [];

  const sistole  = parseFloat(exam.sistole)  || 0;
  const diastole = parseFloat(exam.diastole) || 0;
  if (sistole >= 140 || diastole >= 90)
    faktor.push(`Tekanan darah tinggi (${sistole}/${diastole} mmHg)`);
  else if (sistole >= 130 || diastole >= 80)
    faktor.push(`Tekanan darah batas waspada (${sistole}/${diastole} mmHg)`);

  const djj = parseInt(exam.denyut_jantung_janin) || 0;
  if (djj > 0 && (djj < 120 || djj > 160))
    faktor.push(`DJJ tidak normal (${djj} bpm)`);

  const hb = parseFloat(exam.tes_lab_hb) || 0;
  if (hb > 0 && hb < 7)       faktor.push(`Anemia berat, Hb ${hb} g/dL`);
  else if (hb > 0 && hb < 10) faktor.push(`Anemia sedang, Hb ${hb} g/dL`);

  const gds = parseInt(exam.tes_lab_gula_darah) || 0;
  if (gds > 200)      faktor.push(`Gula darah sangat tinggi (${gds} mg/dL)`);
  else if (gds > 140) faktor.push(`Gula darah meningkat (${gds} mg/dL)`);

  const protein = (exam.tes_lab_protein_urine || "").toLowerCase();
  if (protein.includes("positif 2") || protein.includes("positif 3"))
    faktor.push(`Protein urine ${exam.tes_lab_protein_urine}`);
  else if (protein.includes("positif 1"))
    faktor.push(`Protein urine positif 1`);

  const lila = parseFloat(exam.lingkar_lengan_atas) || 0;
  if (lila > 0 && lila < 23.5) faktor.push(`LILA kurang dari normal (${lila} cm)`);

  const tripel = (exam.tripel_eliminasi || "").toLowerCase();
  if (tripel.includes("reaktif") && !tripel.includes("non"))
    faktor.push(`Triple eliminasi reaktif (${exam.tripel_eliminasi})`);

  const statusRisiko = faktor.length === 0 ? "NORMAL"
    : faktor.some(f => f.includes("tinggi") || f.includes("berat") || f.includes("sangat") || f.includes("reaktif"))
      ? "PERLU RUJUKAN" : "PERLU TINDAKAN";

  return { status_risiko: statusRisiko, faktor };
};

// ─────────────────────────────────────────────
// Sub-komponen: kartu kondisi ibu (auto dari data)
// ─────────────────────────────────────────────
const KondisiIbuCard = ({ exam, risiko }) => {
  if (!exam) return null;
  return (
    <div className="bg-blue-50 border border-blue-200 rounded-xl p-4 space-y-3">
      <h3 className="font-semibold text-blue-800 flex items-center gap-2">
        <FileText size={16} /> Kondisi Ibu (dari kunjungan terakhir)
      </h3>
      <div className="grid grid-cols-2 sm:grid-cols-3 gap-3 text-sm">
        <div>
          <p className="text-gray-500">Tekanan Darah</p>
          <p className="font-semibold text-gray-800">{exam.sistole}/{exam.diastole} mmHg</p>
        </div>
        <div>
          <p className="text-gray-500">DJJ</p>
          <p className="font-semibold text-gray-800">{exam.denyut_jantung_janin || "-"} bpm</p>
        </div>
        <div>
          <p className="text-gray-500">Hb</p>
          <p className="font-semibold text-gray-800">{exam.tes_lab_hb || "-"} g/dL</p>
        </div>
        <div>
          <p className="text-gray-500">Gula Darah</p>
          <p className="font-semibold text-gray-800">{exam.tes_lab_gula_darah || "-"} mg/dL</p>
        </div>
        <div>
          <p className="text-gray-500">Protein Urine</p>
          <p className="font-semibold text-gray-800">{exam.tes_lab_protein_urine || "-"}</p>
        </div>
        <div>
          <p className="text-gray-500">Minggu Kehamilan</p>
          <p className="font-semibold text-gray-800">{exam.minggu_kehamilan || "-"} minggu</p>
        </div>
      </div>

      {risiko.faktor.length > 0 && (
        <div className="mt-2 pt-2 border-t border-blue-200">
          <p className="text-xs font-semibold text-blue-700 mb-1">Indikator Risiko Terdeteksi:</p>
          <ul className="space-y-0.5">
            {risiko.faktor.map((f, i) => (
              <li key={i} className="text-xs text-red-700 flex items-start gap-1">
                <AlertTriangle size={11} className="mt-0.5 flex-shrink-0" /> {f}
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
};

// ─────────────────────────────────────────────
// Sub-komponen: label detail
// ─────────────────────────────────────────────
const DetailItem = ({ label, value }) => (
  <div className="flex flex-col">
    <span className="text-xs text-gray-500 font-medium uppercase tracking-wide">{label}</span>
    <span className="text-sm text-gray-800 font-semibold mt-0.5 whitespace-pre-wrap">{value || "-"}</span>
  </div>
);

// ─────────────────────────────────────────────
// KOMPONEN UTAMA
// ─────────────────────────────────────────────
export default function Rujukan() {
  const { id: ibuId } = useParams();
  const [searchParams] = useSearchParams();
  const kehamilanIdParam = searchParams.get("kehamilan_id");
  const navigate = useNavigate();

  const user     = getCurrentUser();
  const isBidan  = isBidanUser(user);
  const isDokter = isDokterUser(user);

  const [kehamilan,    setKehamilan]    = useState(null);
  const [data,         setData]         = useState(null);   // data rujukan dari DB
  const [latestExam,   setLatestExam]   = useState(null);   // pemeriksaan terakhir
  const [risiko,       setRisiko]       = useState({ status_risiko: "-", faktor: [] });
  const [mode,         setMode]         = useState("loading"); // loading | view | form-bidan | form-dokter
  const [loading,      setLoading]      = useState(true);
  const [saving,       setSaving]       = useState(false);
  const [isActive,     setIsActive]     = useState(true);

  // Form bidan — hanya alasan rujukan
  const [formBidan, setFormBidan] = useState({
    rujukan_alasan_dirujuk_ke_fkrtl: "",
  });

  // Form dokter — resume, diagnosis, rujukan balik, anjuran
  const [formDokter, setFormDokter] = useState({
    rujukan_resume_pemeriksaan_tatalaksana:       "",
    rujukan_diagnosis_akhir:                      "",
    rujukan_balik_tanggal:                        "",
    rujukan_balik_diagnosis_akhir:                "",
    rujukan_balik_resume_pemeriksaan_tatalaksana: "",
    anjuran_rekomendasi_tempat_melahirkan:        "",
  });

  // ── Fetch ──
  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const kehamilanList = await getKehamilanByIbuId(ibuId);
        if (!kehamilanList?.length) {
          await Swal.fire({ icon: "info", title: "Informasi", text: "Ibu belum memiliki data kehamilan.", confirmButtonColor: "#4f46e5" });
          navigate(`/data-ibu/${ibuId}`);
          return;
        }

        // Pilih kehamilan sesuai query param atau default pertama
        const selectedKehamilan = kehamilanIdParam
          ? kehamilanList.find(k => k.id == kehamilanIdParam) || kehamilanList[0]
          : kehamilanList[0];

        setKehamilan(selectedKehamilan);
        setIsActive((selectedKehamilan.status_kehamilan || "") !== "NON-AKTIF");

        // Ambil pemeriksaan terakhir
        const examList = await getPemeriksaanKehamilanByKehamilanId(selectedKehamilan.id);
        const sorted   = (examList || []).sort(
          (a, b) => new Date(b.tanggal_periksa) - new Date(a.tanggal_periksa)
        );
        const lastExam = sorted[0] || null;
        setLatestExam(lastExam);
        setRisiko(hitungStatusRisiko(lastExam));

        // Ambil data rujukan
        const result = await getRujukanByKehamilanId(selectedKehamilan.id);
        if (result?.length > 0) {
          const d = result[0];
          setData(d);
          populateFormBidan(d);
          populateFormDokter(d);
          setMode("view");
        } else {
          setMode("empty");
        }
      } catch (err) {
        console.error(err);
        Swal.fire("Error", "Gagal memuat data. Silakan coba lagi.", "error");
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [ibuId, kehamilanIdParam, navigate]);

  const populateFormBidan = (d) => {
    setFormBidan({
      rujukan_alasan_dirujuk_ke_fkrtl: d.rujukan_alasan_dirujuk_ke_fkrtl || "",
    });
  };

  const populateFormDokter = (d) => {
    setFormDokter({
      rujukan_resume_pemeriksaan_tatalaksana:       d.rujukan_resume_pemeriksaan_tatalaksana       || "",
      rujukan_diagnosis_akhir:                      d.rujukan_diagnosis_akhir                      || "",
      rujukan_balik_tanggal:                        d.rujukan_balik_tanggal ? new Date(d.rujukan_balik_tanggal).toISOString().split("T")[0] : "",
      rujukan_balik_diagnosis_akhir:                d.rujukan_balik_diagnosis_akhir                || "",
      rujukan_balik_resume_pemeriksaan_tatalaksana: d.rujukan_balik_resume_pemeriksaan_tatalaksana || "",
      anjuran_rekomendasi_tempat_melahirkan:        d.anjuran_rekomendasi_tempat_melahirkan        || "",
    });
  };

  // ── Submit bidan ──
  const handleSubmitBidan = async (e) => {
    e.preventDefault();
    if (!formBidan.rujukan_alasan_dirujuk_ke_fkrtl.trim()) {
      Swal.fire({ icon: "warning", title: "Perhatian", text: "Alasan rujukan wajib diisi.", confirmButtonColor: "#4f46e5" });
      return;
    }
    setSaving(true);
    try {
      const payload = {
        kehamilan_id:                    kehamilan.id,
        rujukan_alasan_dirujuk_ke_fkrtl: formBidan.rujukan_alasan_dirujuk_ke_fkrtl,
        // Pertahankan data dokter jika sudah ada
        rujukan_resume_pemeriksaan_tatalaksana:       data?.rujukan_resume_pemeriksaan_tatalaksana       || "",
        rujukan_diagnosis_akhir:                      data?.rujukan_diagnosis_akhir                      || "",
        rujukan_balik_tanggal:                        data?.rujukan_balik_tanggal                        || null,
        rujukan_balik_diagnosis_akhir:                data?.rujukan_balik_diagnosis_akhir                || "",
        rujukan_balik_resume_pemeriksaan_tatalaksana: data?.rujukan_balik_resume_pemeriksaan_tatalaksana || "",
        anjuran_rekomendasi_tempat_melahirkan:        data?.anjuran_rekomendasi_tempat_melahirkan        || "",
      };

      let saved;
      if (data?.id) {
        saved = await updateRujukan(data.id, payload);
      } else {
        saved = await createRujukan(payload);
      }

      // Refresh
      const refreshed = await getRujukanByKehamilanId(kehamilan.id);
      if (refreshed?.length > 0) {
        setData(refreshed[0]);
        populateFormBidan(refreshed[0]);
        populateFormDokter(refreshed[0]);
      }
      setMode("view");
      Swal.fire({ icon: "success", title: "Berhasil", text: "Permintaan rujukan berhasil dikirim.", timer: 2000, showConfirmButton: false });
    } catch (err) {
      console.error(err);
      Swal.fire("Error", err.response?.data?.message || "Gagal menyimpan rujukan.", "error");
    } finally {
      setSaving(false);
    }
  };

  // ── Submit dokter ──
  const handleSubmitDokter = async (e) => {
    e.preventDefault();
    if (!data?.id) {
      Swal.fire({ icon: "warning", title: "Perhatian", text: "Bidan belum membuat permintaan rujukan.", confirmButtonColor: "#4f46e5" });
      return;
    }
    
    // Validation for dokter form
    if (!formDokter.rujukan_resume_pemeriksaan_tatalaksana.trim()) {
      Swal.fire({ icon: "warning", title: "Perhatian", text: "Resume pemeriksaan tatalaksana wajib diisi.", confirmButtonColor: "#4f46e5" });
      return;
    }
    if (!formDokter.rujukan_diagnosis_akhir.trim()) {
      Swal.fire({ icon: "warning", title: "Perhatian", text: "Diagnosis akhir wajib diisi.", confirmButtonColor: "#4f46e5" });
      return;
    }
    setSaving(true);
    try {
      const payload = {
        kehamilan_id:                    kehamilan.id,
        // Pertahankan data bidan
        rujukan_alasan_dirujuk_ke_fkrtl: data?.rujukan_alasan_dirujuk_ke_fkrtl || "",
        // Data dokter
        rujukan_resume_pemeriksaan_tatalaksana:       formDokter.rujukan_resume_pemeriksaan_tatalaksana,
        rujukan_diagnosis_akhir:                      formDokter.rujukan_diagnosis_akhir,
        rujukan_balik_tanggal:                        formDokter.rujukan_balik_tanggal || null,
        rujukan_balik_diagnosis_akhir:                formDokter.rujukan_balik_diagnosis_akhir,
        rujukan_balik_resume_pemeriksaan_tatalaksana: formDokter.rujukan_balik_resume_pemeriksaan_tatalaksana,
        anjuran_rekomendasi_tempat_melahirkan:        formDokter.anjuran_rekomendasi_tempat_melahirkan,
      };

      await updateRujukan(data.id, payload);

      const refreshed = await getRujukanByKehamilanId(kehamilan.id);
      if (refreshed?.length > 0) {
        setData(refreshed[0]);
        populateFormBidan(refreshed[0]);
        populateFormDokter(refreshed[0]);
      }
      setMode("view");
      Swal.fire({ icon: "success", title: "Berhasil", text: "Respon rujukan berhasil disimpan.", timer: 2000, showConfirmButton: false });
    } catch (err) {
      console.error(err);
      Swal.fire("Error", err.response?.data?.message || "Gagal menyimpan respon.", "error");
    } finally {
      setSaving(false);
    }
  };

  const handleCancel = () => {
    if (data) {
      populateFormBidan(data);
      populateFormDokter(data);
      setMode("view");
    } else {
      setMode("empty");
    }
  };

  // ── Badge status risiko ──
  const RisikoBadge = () => {
    const s = risiko.status_risiko;
    const cls = s === "PERLU RUJUKAN"  ? "bg-red-100 text-red-700 border-red-300"
              : s === "PERLU TINDAKAN" ? "bg-yellow-100 text-yellow-700 border-yellow-300"
              : s === "NORMAL"         ? "bg-green-100 text-green-700 border-green-300"
              : "bg-gray-100 text-gray-600 border-gray-300";
    return (
      <span className={`text-xs font-bold px-2 py-0.5 rounded-full border ${cls}`}>{s}</span>
    );
  };

  if (loading) return (
    <MainLayout>
      <div className="min-h-screen flex items-center justify-center text-indigo-600">Memuat data...</div>
    </MainLayout>
  );

  return (
    <MainLayout>
      <div className="min-h-screen bg-gray-50">
        <div className="max-w-4xl mx-auto p-5 space-y-5">

          {/* Header */}
          <div className="flex items-center gap-3">
            <button onClick={() => navigate(-1)} className="p-2 rounded-lg hover:bg-gray-200 transition">
              <ArrowLeft size={20} className="text-indigo-600" />
            </button>
            <div className="flex-1">
              <div className="flex items-center gap-3 flex-wrap">
                <h1 className="text-2xl font-bold text-gray-900">Rujukan Medis</h1>
                <RisikoBadge />
              </div>
              <p className="text-gray-500 text-sm">Alur rujukan bidan → dokter → respon balik</p>
            </div>
          </div>

          {/* Banner kehamilan non-aktif */}
          {!isActive && (
            <div className="bg-gray-100 border-l-4 border-gray-400 p-3 rounded text-gray-700 text-sm flex items-center gap-2">
              <EyeOff size={15} /> Kehamilan ini sudah selesai (NON-AKTIF). Data hanya dapat dilihat.
            </div>
          )}

          {/* Kondisi ibu otomatis */}
          <KondisiIbuCard exam={latestExam} risiko={risiko} />

          {/* ══════════════════════════════════════════
              MODE: EMPTY — belum ada rujukan sama sekali
              ══════════════════════════════════════════ */}
          {mode === "empty" && (
            <div className="bg-white rounded-xl shadow-sm p-8 text-center space-y-4">
              <div className="p-4 bg-indigo-50 rounded-full w-fit mx-auto">
                <Plus size={40} className="text-indigo-600" />
              </div>
              <h3 className="text-lg font-semibold text-gray-800">Belum Ada Permintaan Rujukan</h3>
              {isBidan && isActive && (
                <>
                  <p className="text-gray-500 text-sm">Buat permintaan rujukan jika ibu ini memerlukan penanganan lebih lanjut oleh dokter.</p>
                  <button
                    onClick={() => setMode("form-bidan")}
                    className="bg-indigo-600 hover:bg-indigo-700 text-white px-5 py-2.5 rounded-xl flex items-center gap-2 mx-auto font-semibold transition"
                  >
                    <Plus size={18} /> Buat Permintaan Rujukan
                  </button>
                </>
              )}
              {isDokter && (
                <p className="text-gray-500 text-sm">Bidan belum membuat permintaan rujukan untuk ibu ini.</p>
              )}
            </div>
          )}

          {/* ══════════════════════════════════════════
              MODE: VIEW — tampilan detail
              ══════════════════════════════════════════ */}
          {mode === "view" && data && (
            <div className="space-y-4">

              {/* ─── Bagian Bidan: Permintaan Rujukan ─── */}
              <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                <div className="bg-indigo-50 px-5 py-3 flex justify-between items-center border-b border-indigo-100">
                  <div className="flex items-center gap-2 text-indigo-700 font-semibold">
                    <User size={16} /> Permintaan Rujukan (Bidan)
                  </div>
                  {isBidan && isActive && (
                    <button
                      onClick={() => setMode("form-bidan")}
                      className="flex items-center gap-1.5 text-xs text-indigo-600 border border-indigo-300 px-3 py-1.5 rounded-lg hover:bg-indigo-50 font-semibold"
                    >
                      <Edit2 size={12} /> Edit
                    </button>
                  )}
                </div>
                <div className="p-5">
                  <DetailItem
                    label="Alasan Dirujuk ke FKRTL"
                    value={data.rujukan_alasan_dirujuk_ke_fkrtl}
                  />
                </div>
              </div>

              {/* ─── Bagian Dokter: Respon ─── */}
              <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                <div className="bg-green-50 px-5 py-3 flex justify-between items-center border-b border-green-100">
                  <div className="flex items-center gap-2 text-green-700 font-semibold">
                    <Stethoscope size={16} /> Respon Dokter
                    {!data.rujukan_resume_pemeriksaan_tatalaksana && (
                      <span className="text-xs font-normal text-yellow-600 bg-yellow-100 px-2 py-0.5 rounded-full flex items-center gap-1">
                        <Clock size={11} /> Menunggu respon dokter
                      </span>
                    )}
                  </div>
                  {isDokter && isActive && (
                    <button
                      onClick={() => setMode("form-dokter")}
                      className="flex items-center gap-1.5 text-xs text-green-700 border border-green-300 px-3 py-1.5 rounded-lg hover:bg-green-50 font-semibold"
                    >
                      <Edit2 size={12} /> {data.rujukan_resume_pemeriksaan_tatalaksana ? "Edit Respon" : "Beri Respon"}
                    </button>
                  )}
                </div>
                <div className="p-5 space-y-4">
                  {data.rujukan_resume_pemeriksaan_tatalaksana ? (
                    <>
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <DetailItem label="Resume Pemeriksaan & Tatalaksana" value={data.rujukan_resume_pemeriksaan_tatalaksana} />
                        <DetailItem label="Diagnosis Akhir" value={data.rujukan_diagnosis_akhir} />
                      </div>

                      <div className="border-t pt-4">
                        <p className="text-xs font-semibold text-gray-500 uppercase tracking-wide mb-3">Rujukan Balik</p>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                          <DetailItem
                            label="Tanggal Rujukan Balik"
                            value={data.rujukan_balik_tanggal
                              ? new Date(data.rujukan_balik_tanggal).toLocaleDateString("id-ID", { day: "numeric", month: "long", year: "numeric" })
                              : "-"}
                          />
                          <DetailItem label="Diagnosis Akhir (dari RS)" value={data.rujukan_balik_diagnosis_akhir} />
                          <DetailItem label="Resume dari RS" value={data.rujukan_balik_resume_pemeriksaan_tatalaksana} />
                        </div>
                      </div>

                      <div className="border-t pt-4">
                        <p className="text-xs font-semibold text-gray-500 uppercase tracking-wide mb-2">Anjuran</p>
                        <DetailItem label="Rekomendasi Tempat Melahirkan" value={data.anjuran_rekomendasi_tempat_melahirkan} />
                      </div>
                    </>
                  ) : (
                    <p className="text-sm text-gray-400 italic">Dokter belum memberikan respon.</p>
                  )}
                </div>
              </div>
            </div>
          )}

          {/* ══════════════════════════════════════════
              MODE: FORM BIDAN — hanya alasan rujukan
              ══════════════════════════════════════════ */}
          {mode === "form-bidan" && isBidan && (
            <form onSubmit={handleSubmitBidan} className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
              <div className="bg-indigo-50 px-5 py-3 border-b border-indigo-100 flex justify-between items-center">
                <div className="flex items-center gap-2 text-indigo-700 font-semibold">
                  <User size={16} /> {data ? "Edit Permintaan Rujukan" : "Buat Permintaan Rujukan"}
                </div>
                <button type="button" onClick={handleCancel} className="text-gray-500 hover:text-gray-700">
                  <X size={18} />
                </button>
              </div>
              <div className="p-5 space-y-5">
                {/* Kondisi otomatis — read only */}
                <div className="bg-gray-50 rounded-lg p-4 space-y-2">
                  <p className="text-xs font-semibold text-gray-500 uppercase tracking-wide">Kondisi Ibu (terisi otomatis)</p>
                  <div className="grid grid-cols-2 sm:grid-cols-3 gap-3 text-sm">
                    <div>
                      <p className="text-gray-400 text-xs">Tekanan Darah</p>
                      <p className="font-semibold">{latestExam?.sistole || "-"}/{latestExam?.diastole || "-"} mmHg</p>
                    </div>
                    <div>
                      <p className="text-gray-400 text-xs">DJJ</p>
                      <p className="font-semibold">{latestExam?.denyut_jantung_janin || "-"} bpm</p>
                    </div>
                    <div>
                      <p className="text-gray-400 text-xs">Hb</p>
                      <p className="font-semibold">{latestExam?.tes_lab_hb || "-"} g/dL</p>
                    </div>
                    <div>
                      <p className="text-gray-400 text-xs">Gula Darah</p>
                      <p className="font-semibold">{latestExam?.tes_lab_gula_darah || "-"} mg/dL</p>
                    </div>
                    <div>
                      <p className="text-gray-400 text-xs">Protein Urine</p>
                      <p className="font-semibold">{latestExam?.tes_lab_protein_urine || "-"}</p>
                    </div>
                    <div>
                      <p className="text-gray-400 text-xs">Minggu Kehamilan</p>
                      <p className="font-semibold">{latestExam?.minggu_kehamilan || "-"} minggu</p>
                    </div>
                  </div>
                  {risiko.faktor.length > 0 && (
                    <div className="pt-2 border-t border-gray-200">
                      <p className="text-xs text-red-600 font-semibold mb-1">Indikator risiko:</p>
                      {risiko.faktor.map((f, i) => (
                        <p key={i} className="text-xs text-red-600">• {f}</p>
                      ))}
                    </div>
                  )}
                </div>

                {/* Alasan rujukan — diisi bidan */}
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-1">
                    Alasan Dirujuk ke Dokter / FKRTL <span className="text-red-500">*</span>
                  </label>
                  <textarea
                    name="rujukan_alasan_dirujuk_ke_fkrtl"
                    value={formBidan.rujukan_alasan_dirujuk_ke_fkrtl}
                    onChange={e => setFormBidan(prev => ({ ...prev, rujukan_alasan_dirujuk_ke_fkrtl: e.target.value }))}
                    rows={4}
                    placeholder="Jelaskan alasan ibu ini perlu dirujuk ke dokter / rumah sakit..."
                    className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500"
                  />
                </div>

                <div className="flex justify-end gap-3 pt-2 border-t">
                  <button type="button" onClick={handleCancel} className="px-4 py-2 border border-gray-300 rounded-lg text-sm font-medium hover:bg-gray-50">
                    Batal
                  </button>
                  <button
                    type="submit"
                    disabled={saving}
                    className="bg-indigo-600 hover:bg-indigo-700 text-white px-5 py-2 rounded-lg flex items-center gap-2 text-sm font-semibold disabled:opacity-50"
                  >
                    <Save size={16} /> {saving ? "Menyimpan..." : "Kirim Permintaan Rujukan"}
                  </button>
                </div>
              </div>
            </form>
          )}

          {/* ══════════════════════════════════════════
              MODE: FORM DOKTER — respon lengkap
              ══════════════════════════════════════════ */}
          {mode === "form-dokter" && isDokter && (
            <form onSubmit={handleSubmitDokter} className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
              <div className="bg-green-50 px-5 py-3 border-b border-green-100 flex justify-between items-center">
                <div className="flex items-center gap-2 text-green-700 font-semibold">
                  <Stethoscope size={16} /> Respon Dokter terhadap Rujukan
                </div>
                <button type="button" onClick={handleCancel} className="text-gray-500 hover:text-gray-700">
                  <X size={18} />
                </button>
              </div>
              <div className="p-5 space-y-5">

                {/* Permintaan bidan — read only */}
                <div className="bg-indigo-50 border border-indigo-100 rounded-lg p-4">
                  <p className="text-xs font-semibold text-indigo-600 uppercase tracking-wide mb-1 flex items-center gap-1">
                    <User size={12} /> Permintaan dari Bidan
                  </p>
                  <p className="text-sm text-gray-800 whitespace-pre-wrap">
                    {data?.rujukan_alasan_dirujuk_ke_fkrtl || "-"}
                  </p>
                </div>

                {/* Resume & Diagnosis */}
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-1">Resume Pemeriksaan & Tatalaksana</label>
                    <textarea
                      value={formDokter.rujukan_resume_pemeriksaan_tatalaksana}
                      onChange={e => setFormDokter(p => ({ ...p, rujukan_resume_pemeriksaan_tatalaksana: e.target.value }))}
                      rows={3}
                      placeholder="Ringkasan hasil pemeriksaan dan tatalaksana yang diberikan"
                      className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:border-green-500 focus:ring-1 focus:ring-green-500"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-1">Diagnosis Akhir</label>
                    <input
                      value={formDokter.rujukan_diagnosis_akhir}
                      onChange={e => setFormDokter(p => ({ ...p, rujukan_diagnosis_akhir: e.target.value }))}
                      placeholder="Diagnosis akhir"
                      className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:border-green-500 focus:ring-1 focus:ring-green-500"
                    />
                  </div>
                </div>

                {/* Rujukan Balik */}
                <div className="border-t pt-4 space-y-4">
                  <p className="text-sm font-semibold text-gray-700">Rujukan Balik</p>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-600 mb-1">Tanggal Rujukan Balik</label>
                      <input
                        type="date"
                        value={formDokter.rujukan_balik_tanggal}
                        onChange={e => setFormDokter(p => ({ ...p, rujukan_balik_tanggal: e.target.value }))}
                        className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:border-green-500 focus:ring-1 focus:ring-green-500"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-600 mb-1">Diagnosis Akhir (dari RS)</label>
                      <input
                        value={formDokter.rujukan_balik_diagnosis_akhir}
                        onChange={e => setFormDokter(p => ({ ...p, rujukan_balik_diagnosis_akhir: e.target.value }))}
                        placeholder="Diagnosis dari RS"
                        className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:border-green-500 focus:ring-1 focus:ring-green-500"
                      />
                    </div>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-600 mb-1">Resume dari RS</label>
                    <textarea
                      value={formDokter.rujukan_balik_resume_pemeriksaan_tatalaksana}
                      onChange={e => setFormDokter(p => ({ ...p, rujukan_balik_resume_pemeriksaan_tatalaksana: e.target.value }))}
                      rows={3}
                      placeholder="Ringkasan hasil pemeriksaan dan tatalaksana dari rumah sakit"
                      className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:border-green-500 focus:ring-1 focus:ring-green-500"
                    />
                  </div>
                </div>

                {/* Anjuran */}
                <div className="border-t pt-4">
                  <label className="block text-sm font-semibold text-gray-700 mb-1">Rekomendasi Tempat Melahirkan</label>
                  <input
                    value={formDokter.anjuran_rekomendasi_tempat_melahirkan}
                    onChange={e => setFormDokter(p => ({ ...p, anjuran_rekomendasi_tempat_melahirkan: e.target.value }))}
                    placeholder="Contoh: RSUD X, Klinik Y, atau Puskesmas"
                    className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:border-green-500 focus:ring-1 focus:ring-green-500"
                  />
                </div>

                <div className="flex justify-end gap-3 pt-2 border-t">
                  <button type="button" onClick={handleCancel} className="px-4 py-2 border border-gray-300 rounded-lg text-sm font-medium hover:bg-gray-50">
                    Batal
                  </button>
                  <button
                    type="submit"
                    disabled={saving}
                    className="bg-green-600 hover:bg-green-700 text-white px-5 py-2 rounded-lg flex items-center gap-2 text-sm font-semibold disabled:opacity-50"
                  >
                    <Save size={16} /> {saving ? "Menyimpan..." : "Simpan Respon"}
                  </button>
                </div>
              </div>
            </form>
          )}

        </div>
      </div>
    </MainLayout>
  );
}
