// src/pages/Ibu/Rujukan.jsx
import React, { useEffect, useState } from "react";
import { useParams, useSearchParams, useNavigate, Link } from "react-router-dom";
import Swal from "sweetalert2";
import MainLayout from "../../components/Layout/MainLayout";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import { getPemeriksaanKehamilanByKehamilanId } from "../../services/pemeriksaanKehamilan";
import { getSkriningByKehamilanId } from "../../services/skrining";
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
// Helper: hitung status risiko dari skrining preeklampsia
// ─────────────────────────────────────────────
const hitungStatusRisikoPreeklampsia = (skrining) => {
  if (!skrining) return { status_risiko: "-", ringkasan: "-", faktor: [] };
  const faktor = [];

  const risikoSedang = [
    skrining.anamnesis_multipara_pasangan_baru_sedang,
    skrining.anamnesis_teknologi_reproduksi_berbantu_sedang,
    skrining.anamnesis_umur_diatas_35_tahun_sedang,
    skrining.anamnesis_nulipara_sedang,
    skrining.anamnesis_jarak_kehamilan_diatas_10_tahun_sedang,
    skrining.anamnesis_riwayat_preeklampsia_keluarga_sedang,
    skrining.anamnesis_obesitas_imt_diatas_30_sedang,
  ].filter(Boolean).length;

  const risikoTinggi = [
    skrining.anamnesis_riwayat_preeklampsia_sebelumnya_tinggi,
    skrining.anamnesis_kehamilan_multipel_tinggi,
    skrining.anamnesis_diabetes_dalam_kehamilan_tinggi,
    skrining.anamnesis_hipertensi_kronik_tinggi,
    skrining.anamnesis_penyakit_ginjal_tinggi,
    skrining.anamnesis_penyakit_autoimun_sle_tinggi,
    skrining.anamnesis_anti_phospholipid_syndrome_tinggi,
  ].filter(Boolean).length;

  const map = skrining.fisik_map_diatas_90_mmhg;
  const protein = skrining.fisik_proteinuria_urin_celup;

  if (skrining.anamnesis_multipara_pasangan_baru_sedang) faktor.push("Multipara dengan pasangan baru");
  if (skrining.anamnesis_teknologi_reproduksi_berbantu_sedang) faktor.push("Teknologi reproduksi berbantu");
  if (skrining.anamnesis_umur_diatas_35_tahun_sedang) faktor.push("Umur ≥ 35 tahun");
  if (skrining.anamnesis_nulipara_sedang) faktor.push("Nulipara");
  if (skrining.anamnesis_jarak_kehamilan_diatas_10_tahun_sedang) faktor.push("Jarak kehamilan > 10 tahun");
  if (skrining.anamnesis_riwayat_preeklampsia_keluarga_sedang) faktor.push("Riwayat keluarga preeklampsia");
  if (skrining.anamnesis_obesitas_imt_diatas_30_sedang) faktor.push("Obesitas (IMT > 30)");
  if (skrining.anamnesis_riwayat_preeklampsia_sebelumnya_tinggi) faktor.push("Riwayat preeklampsia sebelumnya");
  if (skrining.anamnesis_kehamilan_multipel_tinggi) faktor.push("Kehamilan multipel");
  if (skrining.anamnesis_diabetes_dalam_kehamilan_tinggi) faktor.push("Diabetes dalam kehamilan");
  if (skrining.anamnesis_hipertensi_kronik_tinggi) faktor.push("Hipertensi kronik");
  if (skrining.anamnesis_penyakit_ginjal_tinggi) faktor.push("Penyakit ginjal");
  if (skrining.anamnesis_penyakit_autoimun_sle_tinggi) faktor.push("Penyakit autoimun (SLE)");
  if (skrining.anamnesis_anti_phospholipid_syndrome_tinggi) faktor.push("Anti phospholipid syndrome");
  if (map) faktor.push("MAP > 90 mmHg");
  if (protein) faktor.push("Proteinuria (urin celup > +1)");

  const statusRisiko = (risikoTinggi >= 1 || risikoSedang >= 2 || map || protein) ? "PERLU RUJUKAN" : "TIDAK PERLU RUJUKAN";

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
// Sub-komponen: kartu skrining preeklampsia
// ─────────────────────────────────────────────
const SkriningPreeklampsiaCard = ({ skrining, risiko }) => {
  if (!skrining) return null;
  return (
    <div className="bg-blue-50 border border-blue-200 rounded-xl p-4 space-y-3">
      <h3 className="font-semibold text-blue-800 flex items-center gap-2">
        <AlertTriangle size={16} /> Hasil Skrining Preeklampsia
      </h3>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-3 text-sm">
        {/* Risiko Sedang */}
        <div className="space-y-1">
          <p className="text-xs font-semibold text-blue-700">Faktor Risiko Sedang:</p>
          <div className="space-y-0.5">
            {skrining.anamnesis_multipara_pasangan_baru_sedang && <p className="text-xs text-gray-700">• Multipara dengan pasangan baru</p>}
            {skrining.anamnesis_teknologi_reproduksi_berbantu_sedang && <p className="text-xs text-gray-700">• Teknologi reproduksi berbantu</p>}
            {skrining.anamnesis_umur_diatas_35_tahun_sedang && <p className="text-xs text-gray-700">• Umur ≥ 35 tahun</p>}
            {skrining.anamnesis_nulipara_sedang && <p className="text-xs text-gray-700">• Nulipara</p>}
            {skrining.anamnesis_jarak_kehamilan_diatas_10_tahun_sedang && <p className="text-xs text-gray-700">• Jarak kehamilan &gt; 10 tahun</p>}
            {skrining.anamnesis_riwayat_preeklampsia_keluarga_sedang && <p className="text-xs text-gray-700">• Riwayat keluarga preeklampsia</p>}
            {skrining.anamnesis_obesitas_imt_diatas_30_sedang && <p className="text-xs text-gray-700">• Obesitas (IMT &gt; 30)</p>}
          </div>
        </div>
        
        {/* Risiko Tinggi */}
        <div className="space-y-1">
          <p className="text-xs font-semibold text-red-700">Faktor Risiko Tinggi:</p>
          <div className="space-y-0.5">
            {skrining.anamnesis_riwayat_preeklampsia_sebelumnya_tinggi && <p className="text-xs text-gray-700">• Riwayat preeklampsia sebelumnya</p>}
            {skrining.anamnesis_kehamilan_multipel_tinggi && <p className="text-xs text-gray-700">• Kehamilan multipel</p>}
            {skrining.anamnesis_diabetes_dalam_kehamilan_tinggi && <p className="text-xs text-gray-700">• Diabetes dalam kehamilan</p>}
            {skrining.anamnesis_hipertensi_kronik_tinggi && <p className="text-xs text-gray-700">• Hipertensi kronik</p>}
            {skrining.anamnesis_penyakit_ginjal_tinggi && <p className="text-xs text-gray-700">• Penyakit ginjal</p>}
            {skrining.anamnesis_penyakit_autoimun_sle_tinggi && <p className="text-xs text-gray-700">• Penyakit autoimun (SLE)</p>}
            {skrining.anamnesis_anti_phospholipid_syndrome_tinggi && <p className="text-xs text-gray-700">• Anti phospholipid syndrome</p>}
          </div>
        </div>
      </div>

      {/* Pemeriksaan Fisik */}
      <div className="space-y-1">
        <p className="text-xs font-semibold text-blue-700">Pemeriksaan Fisik:</p>
        <div className="flex gap-4 text-xs">
          <span className={skrining.fisik_map_diatas_90_mmhg ? "text-red-700 font-semibold" : "text-gray-400"}>
            MAP &gt; 90 mmHg: {skrining.fisik_map_diatas_90_mmhg ? "Ya" : "Tidak"}
          </span>
          <span className={skrining.fisik_proteinuria_urin_celup ? "text-red-700 font-semibold" : "text-gray-400"}>
            Proteinuria: {skrining.fisik_proteinuria_urin_celup ? "Ya" : "Tidak"}
          </span>
        </div>
      </div>

      {skrining.kesimpulan_skrining_preeklampsia && (
        <div className="pt-2 border-t border-blue-200">
          <p className="text-xs font-semibold text-blue-700 mb-1">Kesimpulan Klinis:</p>
          <p className="text-xs text-gray-700">{skrining.kesimpulan_skrining_preeklampsia}</p>
        </div>
      )}

      {risiko.faktor.length > 0 && (
        <div className="mt-2 pt-2 border-t border-blue-200">
          <p className="text-xs font-semibold text-red-700 mb-1">Indikator Risiko Terdeteksi:</p>
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
  const sourceParam = searchParams.get("source"); // 'preeklampsia' or undefined (default ANC)
  const navigate = useNavigate();

  const user     = getCurrentUser();
  const isBidan  = isBidanUser(user);
  const isDokter = isDokterUser(user);

  const [kehamilan,    setKehamilan]    = useState(null);
  const [data,         setData]         = useState(null);   // data rujukan dari DB
  const [latestExam,   setLatestExam]   = useState(null);   // pemeriksaan terakhir
  const [skriningPreeklampsia, setSkriningPreeklampsia] = useState(null); // skrining preeklampsia
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

        // Cek source parameter untuk menentukan data apa yang diambil
        if (sourceParam === "preeklampsia") {
          // Ambil skrining preeklampsia
          const skriningList = await getSkriningByKehamilanId(selectedKehamilan.id);
          const skriningData = skriningList && skriningList.length > 0 ? skriningList[0] : null;
          setSkriningPreeklampsia(skriningData);
          setRisiko(hitungStatusRisikoPreeklampsia(skriningData));
          
          // Pre-fill alasan rujukan dengan data preeklampsia
          if (skriningData && risiko.status_risiko === "PERLU RUJUKAN") {
            const faktorList = hitungStatusRisikoPreeklampsia(skriningData).faktor;
            const alasan = `Skrining Preeklampsia menunjukkan risiko tinggi. Faktor risiko terdeteksi: ${faktorList.join(", ")}. ${skriningData.kesimpulan_skrining_preeklampsia ? `Kesimpulan: ${skriningData.kesimpulan_skrining_preeklampsia}` : ""}`;
            setFormBidan(prev => ({ ...prev, rujukan_alasan_dirujuk_ke_fkrtl: alasan }));
          }
        } else {
          // Ambil pemeriksaan terakhir (default ANC)
          const examList = await getPemeriksaanKehamilanByKehamilanId(selectedKehamilan.id);
          const sorted   = (examList || []).sort(
            (a, b) => new Date(b.tanggal_periksa) - new Date(a.tanggal_periksa)
          );
          const lastExam = sorted[0] || null;
          setLatestExam(lastExam);
          setRisiko(hitungStatusRisiko(lastExam));
        }

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
  }, [ibuId, kehamilanIdParam, navigate, sourceParam]);

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
        source: sourceParam || "anc", // Track referral source: preeklampsia, anc, etc.
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
        source: data?.source || sourceParam || "anc", // Maintain existing source or use current source
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
            : s === "PERLU TINDAKAN" ? "bg-amber-50 text-amber-700 border-amber-200"
            : s === "NORMAL"         ? "bg-blue-100 text-blue-700 border-blue-200"
            : "bg-gray-100 text-gray-600 border-gray-300";
    return (
      <span className={`text-xs font-bold px-2 py-0.5 rounded-full border ${cls}`}>{s}</span>
    );
  };

  // ── Style helpers untuk konsistensi warna ──
  const getRiskCardStyles = (status) => {
    if (status === "PERLU RUJUKAN")  return "bg-red-50 border-red-200 text-red-700";
    if (status === "PERLU TINDAKAN") return "bg-amber-50 border-amber-200 text-amber-700";
    if (status === "NORMAL")         return "bg-blue-50 border-blue-200 text-blue-700";
    return "bg-gray-50 border-gray-200 text-gray-700";
  };

  if (loading) return (
    <MainLayout>
      <div className="min-h-screen flex items-center justify-center text-blue-600">Memuat data...</div>
    </MainLayout>
  );

  return (
    <MainLayout>
      <div className="min-h-screen bg-gray-50">
        <div className="max-w-4xl mx-auto p-5 space-y-5">

          {/* Header */}
          <div className="flex items-center gap-3">
            <Link
              to={`/data-ibu/${ibuId}?kehamilan_id=${kehamilanIdParam || (kehamilan?.id || "")}`}
              className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full border border-[#185FA5] text-[#185FA5] text-sm font-semibold hover:bg-[#185FA5]/5 transition"
            >
              <ArrowLeft size={16} />
              <span>Kembali</span>
            </Link>
              <div className="flex-1">
                <div className="flex items-center gap-3 flex-wrap">
                  <h1 className="text-2xl font-bold text-gray-900">Rujukan Medis</h1>
                  <RisikoBadge />
                </div>
                <p className="text-gray-500 text-sm mt-1">
                  <span className="font-medium text-gray-700">Cara kerja:</span> 
                  Bidan membuat permintaan rujukan → Dokter meninjau dan memberikan respon → Bidan melihat hasil rujukan balik
                </p>
              </div>
          </div>

          {/* Banner kehamilan non-aktif */}
          {!isActive && (
            <div className="bg-blue-50 border border-blue-200 p-3 rounded-lg text-blue-700 text-base flex items-center gap-2">
              <EyeOff size={16} /> Kehamilan ini sudah selesai (NON-AKTIF). Data hanya dapat dilihat, tidak dapat diubah.
            </div>
          )}

          {/* Kondisi ibu otomatis — tidak ditampilkan saat mode form-bidan karena sudah ada di dalam form */}
          {mode !== "form-bidan" && (sourceParam === "preeklampsia" ? (
            <SkriningPreeklampsiaCard skrining={skriningPreeklampsia} risiko={risiko} />
          ) : (
            <KondisiIbuCard exam={latestExam} risiko={risiko} />
          ))}

          {/* ══════════════════════════════════════════
              MODE: EMPTY — belum ada rujukan sama sekali
              ══════════════════════════════════════════ */}
          {mode === "empty" && (
            <div className="bg-white rounded-xl shadow-sm p-8 text-center space-y-4">
              <div className="p-4 bg-blue-50 rounded-full w-fit mx-auto">
                <Plus size={40} className="text-blue-600" />
              </div>
              <h3 className="text-[22px] font-semibold text-[#185FA5]">Belum Ada Permintaan Rujukan</h3>
              {isBidan && isActive && (
                <>
                  <p className="text-gray-500 text-sm">Buat permintaan rujukan jika ibu ini memerlukan penanganan lebih lanjut oleh dokter.</p>
                  <button
                    onClick={() => setMode("form-bidan")}
                    className="bg-[#185FA5] text-white rounded-lg px-5 py-2.5 font-semibold flex items-center gap-2 text-base mx-auto"
                  >
                     Buat Permintaan Rujukan
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
                <div className="bg-blue-50 px-5 py-3 flex justify-between items-center border-b border-blue-100">
                  <div className="flex items-center gap-2 text-blue-700 font-semibold">
                    <User size={16} /> Permintaan Rujukan (Bidan)
                  </div>
                  {isBidan && isActive && !data.rujukan_resume_pemeriksaan_tatalaksana && (
                    <button
                      onClick={() => setMode("form-bidan")}
                      className="flex items-center gap-1.5 text-xs text-blue-600 border border-blue-300 px-3 py-1.5 rounded-lg hover:bg-blue-50 font-semibold"
                    >
                      <Edit2 size={12} /> Edit
                    </button>
                  )}
                </div>
                <div className="p-5">
                  <DetailItem
                    label="Alasan Dirujuk ke Fasilitas Kesehatan Rujukan Tingkat Lanjutan"
                    value={data.rujukan_alasan_dirujuk_ke_fkrtl}
                  />
                </div>
              </div>

              {/* ─── Bagian Dokter: Respon ─── */}
              <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                <div className="bg-blue-50 px-5 py-3 flex justify-between items-center border-b border-blue-100">
                  <div className="flex items-center gap-2 text-blue-700 font-semibold">
                    <Stethoscope size={16} /> Respon Dokter
                    {!data.rujukan_resume_pemeriksaan_tatalaksana && (
                      <span className="text-xs font-normal text-blue-600 bg-blue-50 px-2 py-0.5 rounded-full flex items-center gap-1">
                        <Clock size={11} /> Menunggu respon dokter
                      </span>
                    )}
                  </div>
                  {isDokter && isActive && (
                    <button
                      onClick={() => setMode("form-dokter")}
                      className="flex items-center gap-1.5 text-xs text-blue-700 border border-blue-300 px-3 py-1.5 rounded-lg hover:bg-blue-50 font-semibold"
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
              <div className="bg-blue-50 px-5 py-3 border-b border-blue-100">
                <div className="flex items-center gap-2 text-blue-700 font-semibold">
                  <User size={16} /> {data ? "Edit Permintaan Rujukan" : "Buat Permintaan Rujukan"}
                </div>
              </div>
              <div className="p-5 space-y-5">
                {/* Kondisi otomatis — read only */}
                {sourceParam === "preeklampsia" ? (
                  <SkriningPreeklampsiaCard skrining={skriningPreeklampsia} risiko={risiko} />
                ) : (
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
                )}

                {/* Alasan rujukan — diisi bidan */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Alasan Dirujuk ke Dokter / Fasilitas Kesehatan Rujukan Tingkat Lanjutan <span className="text-red-500">*</span>
                  </label>
                  <textarea
                    name="rujukan_alasan_dirujuk_ke_fkrtl"
                    value={formBidan.rujukan_alasan_dirujuk_ke_fkrtl}
                    onChange={e => setFormBidan(prev => ({ ...prev, rujukan_alasan_dirujuk_ke_fkrtl: e.target.value }))}
                    rows={4}
                    placeholder="Jelaskan alasan ibu ini perlu dirujuk ke dokter / rumah sakit..."
                    className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                  />
                </div>

                <div className="flex justify-end gap-3 pt-2 border-t">
                  <button type="button" onClick={handleCancel} className="px-4 py-2 border border-gray-300 rounded-lg text-sm font-medium hover:bg-gray-50">
                    Batal
                  </button>
                  <button
                    type="submit"
                    disabled={saving}
                    className="bg-blue-600 hover:bg-blue-700 text-white px-5 py-2 rounded-lg flex items-center gap-2 text-sm font-semibold disabled:opacity-50"
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
              <div className="bg-blue-50 px-5 py-3 border-b border-blue-100 flex justify-between items-center">
                <div className="flex items-center gap-2 text-blue-700 font-semibold">
                  <Stethoscope size={16} /> Respon Dokter terhadap Rujukan
                </div>
                <button type="button" onClick={handleCancel} className="text-gray-500 hover:text-gray-700">
                  <X size={18} />
                </button>
              </div>
              <div className="p-5 space-y-5">

                {/* Permintaan bidan — read only */}
                <div className="bg-blue-50 border border-blue-100 rounded-lg p-4">
                  <p className="text-xs font-semibold text-blue-600 uppercase tracking-wide mb-1 flex items-center gap-1">
                    <User size={12} /> Permintaan dari Bidan
                  </p>
                  <p className="text-sm text-gray-800 whitespace-pre-wrap">
                    {data?.rujukan_alasan_dirujuk_ke_fkrtl || "-"}
                  </p>
                </div>

                {/* Resume & Diagnosis */}
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Resume Pemeriksaan & Tatalaksana</label>
                    <textarea
                      value={formDokter.rujukan_resume_pemeriksaan_tatalaksana}
                      onChange={e => setFormDokter(p => ({ ...p, rujukan_resume_pemeriksaan_tatalaksana: e.target.value }))}
                      rows={3}
                      placeholder="Ringkasan hasil pemeriksaan dan tatalaksana yang diberikan"
                       className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                     />
                   </div>
                   <div>
                     <label className="block text-sm font-medium text-gray-700 mb-1">Diagnosis Akhir</label>
                     <input
                       value={formDokter.rujukan_diagnosis_akhir}
                       onChange={e => setFormDokter(p => ({ ...p, rujukan_diagnosis_akhir: e.target.value }))}
                       placeholder="Diagnosis akhir"
                       className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                     />
                  </div>
                </div>

                {/* Rujukan Balik */}
                <div className="border-t pt-4 space-y-4">
                  <p className="text-sm font-medium text-gray-700">Rujukan Balik</p>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Tanggal Rujukan Balik</label>
                      <input
                        type="date"
                        value={formDokter.rujukan_balik_tanggal}
                        onChange={e => setFormDokter(p => ({ ...p, rujukan_balik_tanggal: e.target.value }))}
                        min={new Date().toISOString().split('T')[0]}
                         className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                       />
                     </div>
                     <div>
                       <label className="block text-sm font-medium text-gray-700 mb-1">Diagnosis Akhir (dari RS)</label>
                       <input
                         value={formDokter.rujukan_balik_diagnosis_akhir}
                         onChange={e => setFormDokter(p => ({ ...p, rujukan_balik_diagnosis_akhir: e.target.value }))}
                         placeholder="Diagnosis dari RS"
                         className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                       />
                    </div>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Resume dari RS</label>
                    <textarea
                      value={formDokter.rujukan_balik_resume_pemeriksaan_tatalaksana}
                      onChange={e => setFormDokter(p => ({ ...p, rujukan_balik_resume_pemeriksaan_tatalaksana: e.target.value }))}
                      rows={3}
                      placeholder="Ringkasan hasil pemeriksaan dan tatalaksana dari rumah sakit"
                       className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                     />
                   </div>
                 </div>

                 {/* Anjuran */}
                <div className="border-t pt-4">
                  <label className="block text-sm font-medium text-gray-700 mb-1">Rekomendasi Tempat Melahirkan</label>
                  <input
                    value={formDokter.anjuran_rekomendasi_tempat_melahirkan}
                    onChange={e => setFormDokter(p => ({ ...p, anjuran_rekomendasi_tempat_melahirkan: e.target.value }))}
                    placeholder="Contoh: RSUD X, Klinik Y, atau Puskesmas"
                   className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                 />
               </div>

               <div className="flex justify-end gap-3 pt-2 border-t">
                  <button type="button" onClick={handleCancel} className="px-4 py-2 border border-gray-300 rounded-lg text-sm font-medium hover:bg-gray-50">
                    Batal
                  </button>
                  <button
                    type="submit"
                    disabled={saving}
                    className="bg-blue-600 hover:bg-blue-700 text-white px-5 py-2 rounded-lg flex items-center gap-2 text-sm font-semibold disabled:opacity-50"
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
