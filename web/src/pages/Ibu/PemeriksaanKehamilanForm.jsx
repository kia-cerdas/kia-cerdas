// src/pages/Ibu/PemeriksaanKehamilanForm.jsx
import React, { useEffect, useState, useMemo } from "react";
import { useParams, useNavigate, useSearchParams, Link } from "react-router-dom";
import Swal from "sweetalert2";
import MainLayout from "../../components/Layout/MainLayout";
import {
  getPemeriksaanKehamilanById,
  createPemeriksaanKehamilan,
  updatePemeriksaanKehamilan,
} from "../../services/pemeriksaanKehamilan";
import { getKehamilanById } from "../../services/kehamilan";
import { getCurrentUser, isDokterUser } from "../../services/auth";
import {
  Save,
  ArrowLeft,
  Loader2,
  Activity,
  Beaker,
  MessageCircle,
  AlertCircle,
  Home,
  CheckCircle,
  AlertTriangle,
  ShieldAlert,
  Info,
  Calendar,
  RefreshCw,
  Baby,
  Droplet,
  Heart,
  ChevronDown,
  ChevronUp,
} from "lucide-react";

// ─────────────────────────────────────────────────────────────
// Helper Functions
// ─────────────────────────────────────────────────────────────

// Hitung usia kehamilan dari HPHT
const hitungUsiaKehamilanDariHPHT = (hpht, tanggalPeriksa = null) => {
  if (!hpht) return null;
  
  const hphtDate = new Date(hpht);
  const periksaDate = tanggalPeriksa ? new Date(tanggalPeriksa) : new Date();
  
  if (isNaN(hphtDate.getTime()) || isNaN(periksaDate.getTime())) return null;
  
  const diffTime = periksaDate - hphtDate;
  const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
  
  if (diffDays < 0) return { minggu: 0, hari: 0, totalHari: 0, display: "Belum hamil" };
  
  const weeks = Math.floor(diffDays / 7);
  const remainingDays = diffDays % 7;
  
  return {
    minggu: weeks,
    hari: remainingDays,
    totalHari: diffDays,
    display: `${weeks} minggu ${remainingDays} hari`
  };
};

// Tentukan trimester berdasarkan minggu
const getTrimesterFromWeek = (minggu) => {
  const week = parseInt(minggu);
  if (isNaN(week) || week === 0) return "I";
  if (week <= 12) return "I";
  if (week <= 24) return "II";
  return "III";
};

// Tentukan kunjungan ke berdasarkan minggu (standar ANC)
const getKunjunganKeFromWeek = (minggu) => {
  const week = parseInt(minggu);
  if (isNaN(week) || week === 0) return "1";
  if (week <= 12) return "1";
  if (week <= 24) return "2";
  if (week <= 32) return "3";
  if (week <= 36) return "4";
  if (week <= 40) return "5";
  return "6";
};

// Parse alasan_klinis from JSON string
const parseAlasanKlinis = (alasanString) => {
  if (!alasanString) return [];
  try {
    return JSON.parse(alasanString);
  } catch {
    return [];
  }
};

// Parse risk_types from JSON string
const parseRiskTypes = (riskTypesString) => {
  if (!riskTypesString) return [];
  try {
    return JSON.parse(riskTypesString);
  } catch {
    return [];
  }
};

// Format tanggal ke Indonesia
const formatTanggalIndo = (dateStr) => {
  if (!dateStr) return "-";
  const date = new Date(dateStr);
  if (isNaN(date.getTime())) return "-";
  return date.toLocaleDateString("id-ID", {
    day: "2-digit",
    month: "long",
    year: "numeric"
  });
};

export default function PemeriksaanKehamilanForm() {
  const { id: ibuId, periksaId } = useParams();
  const [searchParams] = useSearchParams();
  const kehamilanId = searchParams.get("kehamilan_id");

  const navigate = useNavigate();
  const isEdit = periksaId !== "baru";

  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [errors, setErrors] = useState({});
  const [step, setStep] = useState(1);
  const [isDokter, setIsDokter] = useState(false);
  const [isReadOnly, setIsReadOnly] = useState(false);
  
  // State untuk data kehamilan
  const [kehamilanDetail, setKehamilanDetail] = useState(null);
  const [loadingKehamilan, setLoadingKehamilan] = useState(false);
  const [autoCalculate, setAutoCalculate] = useState(true);
  const [lastCalculatedDate, setLastCalculatedDate] = useState(null);
  
  // State untuk hasil prediksi ML dari backend
  const [mlPrediction, setMlPrediction] = useState(null);
  
  // State untuk dropdown functionality
  const [expandedRisks, setExpandedRisks] = useState({});

  const [form, setForm] = useState({
    kehamilan_id: kehamilanId || "",
    minggu_kehamilan: "",
    berat_badan: "",
    tinggi_badan: "",
    lingkar_lengan_atas: "",
    sistole: "",
    diastole: "",
    tinggi_rahim: "",
    denyut_jantung_janin: "",
    tablet_tambah_darah: "",
    tes_lab_hb: "",
    tes_lab_gula_darah: "",
    tes_lab_protein_urine: "negatif",
    tripel_eliminasi: "non reaktif",
    usg: "",
    trimester: "I",
    kunjungan_ke: "1",
    tanggal_periksa: new Date().toISOString().split("T")[0],
    tempat_periksa: "",
    letak_denyut_jantung_bayi: "",
    status_imunisasi_tetanus: "Belum pernah imunisasi TT",
    konseling: "",
    skrining_dokter: "",
    tes_golongan_darah: "",
    tata_laksana_kasus: "",
  });

  // ── Cek role user dan set read-only mode ──
  useEffect(() => {
    const user = getCurrentUser();
    const dokter = isDokterUser(user);
    setIsDokter(dokter);
    
    // Dokter tidak bisa edit data ANC yang sudah ada
    if (dokter && isEdit) {
      setIsReadOnly(true);
    }
  }, [isEdit]);

  // ── Ambil detail kehamilan berdasarkan ID ──
  useEffect(() => {
    const fetchKehamilanDetail = async () => {
      if (!kehamilanId) {
        console.warn("kehamilanId tidak ditemukan di URL");
        return;
      }
      
      setLoadingKehamilan(true);
      try {
        const data = await getKehamilanById(kehamilanId);
        console.log("Detail kehamilan:", data);
        
        if (data) {
          setKehamilanDetail(data);
          
          // Pre-fill data dari kehamilan jika ada
          if (data.bb_awal && data.bb_awal > 0) {
            setForm(prev => ({ ...prev, berat_badan: data.bb_awal.toString() }));
          }
          if (data.tb && data.tb > 0) {
            setForm(prev => ({ ...prev, tinggi_badan: data.tb.toString() }));
          }
          if (data.lingkar_lengan_atas) {
            setForm(prev => ({ ...prev, lingkar_lengan_atas: data.lingkar_lengan_atas.toString() }));
          }
        }
      } catch (err) {
        console.error("Gagal mengambil detail kehamilan:", err);
        Swal.fire("Error", "Gagal memuat data kehamilan", "error");
      } finally {
        setLoadingKehamilan(false);
      }
    };
    
    fetchKehamilanDetail();
  }, [kehamilanId]);

  // ── Hitung usia kehamilan otomatis berdasarkan HPHT dan tanggal periksa ──
  useEffect(() => {
    if (!autoCalculate) return;
    if (!kehamilanDetail?.hpht) return;
    if (!form.tanggal_periksa) return;
    
    // Hindari perhitungan berulang untuk tanggal yang sama
    if (lastCalculatedDate === form.tanggal_periksa) return;
    
    const usia = hitungUsiaKehamilanDariHPHT(kehamilanDetail.hpht, form.tanggal_periksa);
    
    if (usia && usia.minggu !== undefined && usia.minggu > 0) {
      const mingguBaru = usia.minggu.toString();
      
      if (form.minggu_kehamilan !== mingguBaru) {
        setForm(prev => ({ ...prev, minggu_kehamilan: mingguBaru }));
        
        // Auto update trimester dan kunjungan
        const newTrimester = getTrimesterFromWeek(mingguBaru);
        const newKunjungan = getKunjunganKeFromWeek(mingguBaru);
        
        setForm(prev => ({
          ...prev,
          trimester: newTrimester,
          kunjungan_ke: newKunjungan
        }));
        
        setLastCalculatedDate(form.tanggal_periksa);
      }
    }
  }, [kehamilanDetail, form.tanggal_periksa, autoCalculate, lastCalculatedDate]);

  // Update trimester dan kunjungan ketika minggu berubah (manual mode)
  useEffect(() => {
    if (autoCalculate) return;
    
    const minggu = form.minggu_kehamilan;
    if (minggu && minggu !== "") {
      const newTrimester = getTrimesterFromWeek(minggu);
      const newKunjungan = getKunjunganKeFromWeek(minggu);
      
      if (newTrimester !== form.trimester) {
        setForm(prev => ({ ...prev, trimester: newTrimester }));
      }
      if (newKunjungan !== form.kunjungan_ke) {
        setForm(prev => ({ ...prev, kunjungan_ke: newKunjungan }));
      }
    }
  }, [form.minggu_kehamilan, autoCalculate]);

  // Fetch data jika edit
  useEffect(() => {
    if (isEdit && periksaId) {
      setLoading(true);
      getPemeriksaanKehamilanById(periksaId)
        .then((data) => {
          setForm(prev => ({
            ...prev,
            minggu_kehamilan: data.minggu_kehamilan || "",
            berat_badan: data.berat_badan || "",
            tinggi_badan: data.tinggi_badan || "",
            lingkar_lengan_atas: data.lingkar_lengan_atas || "",
            sistole: data.sistole || "",
            diastole: data.diastole || "",
            tinggi_rahim: data.tinggi_rahim || "",
            denyut_jantung_janin: data.denyut_jantung_janin || "",
            tablet_tambah_darah: data.tablet_tambah_darah || "",
            tes_lab_hb: data.tes_lab_hb || "",
            tes_lab_gula_darah: data.tes_lab_gula_darah || "",
            tes_lab_protein_urine: data.tes_lab_protein_urine || "negatif",
            tripel_eliminasi: data.tripel_eliminasi || "non reaktif",
            usg: data.usg || "",
            trimester: data.trimester || "I",
            kunjungan_ke: data.kunjungan_ke || "1",
            tanggal_periksa: data.tanggal_periksa ? data.tanggal_periksa.split("T")[0] : new Date().toISOString().split("T")[0],
            tempat_periksa: data.tempat_periksa || "",
            letak_denyut_jantung_bayi: data.letak_denyut_jantung_bayi || "",
            status_imunisasi_tetanus: data.status_imunisasi_tetanus || "Belum pernah imunisasi TT",
            konseling: data.konseling || "",
            skrining_dokter: data.skrining_dokter || "",
            tes_golongan_darah: data.tes_golongan_darah || "",
            tata_laksana_kasus: data.tata_laksana_kasus || "",
          }));
          
          // Set ML prediction results if available
          if (data.overall_label || data.status_risiko) {
            setMlPrediction({
              overall_label: data.overall_label || data.status_risiko,
              skor_risiko: data.skor_risiko || 0,
              active_risk_count: data.active_risk_count || 0,
              alasan_klinis: parseAlasanKlinis(data.alasan_klinis),
              rekomendasi_utama: data.rekomendasi_utama || data.detail_risiko,
              risk_types: parseRiskTypes(data.risk_types),
            });
          }
        })
        .catch((err) => {
          console.error(err);
          Swal.fire("Error", "Gagal memuat data pemeriksaan", "error");
        })
        .finally(() => setLoading(false));
    }
  }, [isEdit, periksaId]);

  // Validasi functions
  const validateNumber = (value, fieldName, min = 0, max = null, allowZero = false) => {
    const num = parseFloat(value);
    if (isNaN(num)) return `${fieldName} harus diisi angka`;
    if (!allowZero && num === 0) return `${fieldName} tidak boleh 0`;
    if (num < min) return `${fieldName} tidak boleh kurang dari ${min}`;
    if (max !== null && num > max) return `${fieldName} tidak boleh lebih dari ${max}`;
    return "";
  };

  const validateDate = (dateStr) => {
    if (!dateStr) return "Tanggal periksa wajib diisi";
    const selected = new Date(dateStr);
    const today = new Date();
    if (selected > today) return "Tanggal periksa tidak boleh melebihi hari ini";
    return "";
  };

  const validateTrimesterMinggu = (minggu, trimester) => {
    const m = parseInt(minggu);
    if (isNaN(m)) return "";
    if (trimester === "I" && (m < 0 || m > 12)) return "Trimester 1 harus berisi minggu 0-12";
    if (trimester === "II" && (m < 13 || m > 24)) return "Trimester 2 harus berisi minggu 13-24";
    if (trimester === "III" && m < 25) return "Trimester 3 harus berisi minggu ≥25";
    return "";
  };

  const validateStep1 = () => {
    const newErrors = {};
    const tanggalErr = validateDate(form.tanggal_periksa);
    if (tanggalErr) newErrors.tanggal_periksa = tanggalErr;
    if (!form.kunjungan_ke) newErrors.kunjungan_ke = "Kunjungan ke- wajib dipilih";

    const mingguErr = validateNumber(form.minggu_kehamilan, "Minggu kehamilan", 0, 42, true);
    if (mingguErr) newErrors.minggu_kehamilan = mingguErr;
    else {
      const trimErr = validateTrimesterMinggu(form.minggu_kehamilan, form.trimester);
      if (trimErr) newErrors.minggu_kehamilan = trimErr;
    }

    const fields = [
      ["berat_badan", "Berat badan", 20, 200, false],
      ["tinggi_badan", "Tinggi badan", 100, 200, false],
      ["lingkar_lengan_atas", "LILA", 15, 50, true],
      ["sistole", "Sistole", 70, 200, false],
      ["diastole", "Diastole", 40, 130, false],
      ["tinggi_rahim", "Tinggi rahim", 5, 50, true],
      ["denyut_jantung_janin", "Denyut jantung janin", 80, 200, false],
    ];
    fields.forEach(([name, label, min, max, allowZero]) => {
      const err = validateNumber(form[name], label, min, max, allowZero);
      if (err) newErrors[name] = err;
    });

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const validateStep2 = () => {
    const newErrors = {};
    const fields = [
      ["tablet_tambah_darah", "Tablet tambah darah", 0, 365, true],
      ["tes_lab_hb", "Kadar Hb", 3, 20, true],
      ["tes_lab_gula_darah", "Gula darah", 40, 500, true],
    ];
    fields.forEach(([name, label, min, max, allowZero]) => {
      const err = validateNumber(form[name], label, min, max, allowZero);
      if (err) newErrors[name] = err;
    });
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const validateStep3 = () => {
    const newErrors = {};
    // Step 3 (Konseling) is optional, so always return true
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleNext = () => {
    const valid = step === 1 ? validateStep1() : step === 2 ? validateStep2() : validateStep3();
    if (valid) {
      setStep(step + 1);
      setErrors({});
    } else {
      // Show alert with list of errors
      const errorList = Object.entries(errors)
        .map(([field, message]) => `• ${message}`)
        .join('\n');
      
      Swal.fire({
        icon: "warning",
        title: "Data Belum Lengkap",
        html: `<div class="text-left" style="white-space: pre-line;">${errorList}</div>`,
        confirmButtonColor: "#4f46e5",
      });

      // Scroll to first error field
      const firstErrorField = Object.keys(errors)[0];
      const errorElement = document.querySelector(`[name="${firstErrorField}"]`);
      if (errorElement) {
        errorElement.scrollIntoView({ behavior: 'smooth', block: 'center' });
        errorElement.focus();
      }
    }
  };

  const handlePrev = () => {
    setStep(step - 1);
    setErrors({});
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
    if (errors[name]) setErrors((prev) => ({ ...prev, [name]: "" }));
  };

  const buildPayload = () => ({
    kehamilan_id: parseInt(kehamilanId || form.kehamilan_id),
    minggu_kehamilan: parseInt(form.minggu_kehamilan) || 0,
    berat_badan: parseFloat(form.berat_badan) || 0,
    tinggi_badan: parseFloat(form.tinggi_badan) || 0,
    lingkar_lengan_atas: parseFloat(form.lingkar_lengan_atas) || 0,
    sistole: parseInt(form.sistole) || 0,
    diastole: parseInt(form.diastole) || 0,
    tinggi_rahim: parseFloat(form.tinggi_rahim) || 0,
    denyut_jantung_janin: parseInt(form.denyut_jantung_janin) || 0,
    tablet_tambah_darah: parseInt(form.tablet_tambah_darah) || 0,
    tes_lab_hb: parseFloat(form.tes_lab_hb) || 0,
    tes_lab_gula_darah: parseInt(form.tes_lab_gula_darah) || 0,
    kunjungan_ke: parseInt(form.kunjungan_ke) || 0,
    tanggal_periksa: form.tanggal_periksa,
    tempat_periksa: form.tempat_periksa,
    letak_denyut_jantung_bayi: form.letak_denyut_jantung_bayi,
    status_imunisasi_tetanus: form.status_imunisasi_tetanus,
    tes_lab_protein_urine: form.tes_lab_protein_urine,
    tripel_eliminasi: form.tripel_eliminasi,
    usg: form.usg,
    konseling: form.konseling,
    skrining_dokter: form.skrining_dokter,
    tes_golongan_darah: form.tes_golongan_darah,
    tata_laksana_kasus: form.tata_laksana_kasus,
    trimester: form.trimester,
  });

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!kehamilanId && !form.kehamilan_id) {
      Swal.fire("Error", "Kehamilan ID tidak ditemukan", "error");
      return;
    }
    
    const step1Valid = validateStep1();
    const step2Valid = validateStep2();
    const step3Valid = validateStep3();
    
    if (!step1Valid || !step2Valid || !step3Valid) {
      // Show alert with list of errors
      const errorList = Object.entries(errors)
        .map(([field, message]) => `• ${message}`)
        .join('\n');
      
      Swal.fire({
        icon: "warning",
        title: "Data Belum Lengkap",
        html: `<div class="text-left" style="white-space: pre-line;">${errorList}</div>`,
        confirmButtonColor: "#4f46e5",
      });
      
      if (!step1Valid) setStep(1);
      else if (!step2Valid) setStep(2);
      else if (!step3Valid) setStep(3);
      
      // Scroll to first error field
      const firstErrorField = Object.keys(errors)[0];
      const errorElement = document.querySelector(`[name="${firstErrorField}"]`);
      if (errorElement) {
        setTimeout(() => {
          errorElement.scrollIntoView({ behavior: 'smooth', block: 'center' });
          errorElement.focus();
        }, 100);
      }
      return;
    }
    
    setSaving(true);
    try {
      const payload = buildPayload();
      console.log("PAYLOAD:", JSON.stringify(payload, null, 2));
      
      let result;
      if (isEdit) {
        result = await updatePemeriksaanKehamilan(periksaId, payload);
        await Swal.fire({ icon: "success", title: "Berhasil", text: "Pemeriksaan ANC berhasil diperbarui", timer: 2000, showConfirmButton: false });
      } else {
        result = await createPemeriksaanKehamilan(payload);
        await Swal.fire({ icon: "success", title: "Berhasil", text: "Pemeriksaan ANC berhasil disimpan", timer: 2000, showConfirmButton: false });
      }
      
      // Update ML prediction state with the result
      console.log("API Response:", result);
      const data = result.data || result; // Handle both wrapped and unwrapped responses
      if (data && (data.overall_label || data.status_risiko)) {
        setMlPrediction({
          overall_label: data.overall_label || data.status_risiko,
          skor_risiko: data.skor_risiko || 0,
          active_risk_count: data.active_risk_count || 0,
          alasan_klinis: parseAlasanKlinis(data.alasan_klinis),
          rekomendasi_utama: data.rekomendasi_utama || data.detail_risiko,
          risk_types: parseRiskTypes(data.risk_types),
        });
      } else {
        console.warn("No ML prediction data in response");
      }
      
      navigate(`/data-ibu/${ibuId}/pemeriksaan-rutin?kehamilan_id=${kehamilanId}`);
    } catch (err) {
      console.error(err);
      Swal.fire("Error", "Gagal menyimpan data pemeriksaan", "error");
    } finally {
      setSaving(false);
    }
  };

  // Hitung usia kehamilan untuk ditampilkan
  const currentUsiaKehamilan = kehamilanDetail?.hpht && form.tanggal_periksa
    ? hitungUsiaKehamilanDariHPHT(kehamilanDetail.hpht, form.tanggal_periksa)
    : null;

  if (loading || loadingKehamilan) {
    return (
      <MainLayout>
        <div className="min-h-screen flex items-center justify-center bg-[#F7FAFB]">
          <Loader2 className="animate-spin text-indigo-600" size={32} />
          <span className="ml-2 text-gray-500">Memuat data...</span>
        </div>
      </MainLayout>
    );
  }

  const ErrorMsg = ({ field }) => errors[field] ? (
    <p className="text-red-500 text-xs mt-1 flex items-center gap-1">
      <AlertCircle size={12} /> {errors[field]}
    </p>
  ) : null;

  const risikoConfig = {
    NORMAL: { bg: "bg-green-50", border: "border-green-500", label: "bg-green-100 text-green-800", icon: <CheckCircle className="text-green-600 flex-shrink-0" size={28} /> },
    "PERLU TINDAKAN": { bg: "bg-yellow-50", border: "border-yellow-500", label: "bg-yellow-100 text-yellow-800", icon: <AlertTriangle className="text-yellow-600 flex-shrink-0" size={28} /> },
    "PERLU RUJUKAN": { bg: "bg-red-50", border: "border-red-500", label: "bg-red-100 text-red-800", icon: <ShieldAlert className="text-red-600 flex-shrink-0" size={28} /> },
  };

  return (
    <MainLayout>
      <div className="min-h-screen bg-[#F7FAFB] p-4 md:p-6">
        <div className="max-w-7xl mx-auto">
          {/* Breadcrumb */}
          <div className="flex items-center gap-2 text-sm text-gray-500 mb-4 flex-wrap">
            <Link to="/dashboard" className="hover:text-indigo-600 flex items-center gap-1">
              <Home size={14} /> Beranda
            </Link>
            <span>/</span>
            <Link to="/data-ibu" className="hover:text-indigo-600">Data Ibu</Link>
            <span>/</span>
            <Link to={`/data-ibu/${ibuId}?kehamilan_id=${kehamilanId}`} className="hover:text-indigo-600">
              Detail Ibu
            </Link>
            <span>/</span>
            <span className="text-gray-700 font-medium">
              {isEdit ? "Edit Pemeriksaan ANC" : "Tambah Pemeriksaan ANC"}
            </span>
          </div>

          {/* Informasi HPHT Card - Auto-fill utama */}
          {kehamilanDetail?.hpht && (
            <div className="mb-6 p-4 bg-gradient-to-r from-indigo-50 to-blue-50 rounded-xl border border-indigo-200 shadow-sm">
              <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div className="flex items-center gap-3">
                  <div className="w-12 h-12 bg-indigo-100 rounded-full flex items-center justify-center">
                    <Calendar size={24} className="text-indigo-600" />
                  </div>
                  <div>
                    <p className="text-xs text-gray-500 uppercase tracking-wide">Hari Pertama Haid Terakhir (HPHT)</p>
                    <p className="font-bold text-lg text-indigo-700">{formatTanggalIndo(kehamilanDetail.hpht)}</p>
                    <p className="text-xs text-gray-500">
                      Taksiran Persalinan: {formatTanggalIndo(kehamilanDetail.taksiran_persalinan)}
                    </p>
                  </div>
                </div>
                
                {currentUsiaKehamilan && currentUsiaKehamilan.minggu > 0 && (
                  <div className="flex items-center gap-3 bg-white px-4 py-3 rounded-xl shadow-sm">
                    <Baby size={24} className="text-pink-500" />
                    <div>
                      <p className="text-xs text-gray-500">Usia Kehamilan (Per Tanggal Periksa)</p>
                      <p className="font-bold text-xl text-indigo-700">{currentUsiaKehamilan.display}</p>
                      <p className="text-xs text-gray-400">{currentUsiaKehamilan.totalHari} hari</p>
                    </div>
                  </div>
                )}
                
                {!isReadOnly && (
                  <button
                    type="button"
                    onClick={() => {
                      if (kehamilanDetail?.hpht && form.tanggal_periksa) {
                        const usia = hitungUsiaKehamilanDariHPHT(kehamilanDetail.hpht, form.tanggal_periksa);
                        if (usia && usia.minggu !== undefined && usia.minggu > 0) {
                          const newTrimester = getTrimesterFromWeek(usia.minggu);
                          const newKunjungan = getKunjunganKeFromWeek(usia.minggu);
                          setForm(prev => ({
                            ...prev,
                            minggu_kehamilan: usia.minggu.toString(),
                            trimester: newTrimester,
                            kunjungan_ke: newKunjungan
                          }));
                          Swal.fire({
                            icon: "success",
                            title: "Usia Kehamilan Terisi",
                            html: `<div class="text-left">
                              <p>Usia kehamilan: <strong>${usia.display}</strong></p>
                              <p>Trimester: <strong>${newTrimester}</strong></p>
                              <p>Kunjungan ke-: <strong>${newKunjungan}</strong></p>
                            </div>`,
                            timer: 2500,
                            showConfirmButton: false
                          });
                        } else {
                          Swal.fire("Info", "Kehamilan masih dibawah 1 minggu. Pastikan HPHT dan tanggal periksa valid.", "info");
                        }
                      }
                    }}
                    className="px-4 py-2 bg-indigo-600 text-white rounded-lg text-sm hover:bg-indigo-700 transition flex items-center gap-2"
                  >
                    <RefreshCw size={14} />
                    Isi Otomatis Usia Kehamilan
                  </button>
                )}
              </div>
              
              {/* Toggle mode */}
              {!isReadOnly && (
                <div className="mt-3 flex items-center justify-end gap-4 border-t border-indigo-100 pt-3">
                  <label className="flex items-center gap-2 text-sm text-gray-600 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={autoCalculate}
                      onChange={(e) => setAutoCalculate(e.target.checked)}
                      className="rounded text-indigo-600 focus:ring-indigo-500 w-4 h-4"
                    />
                    <span className="flex items-center gap-1">
                      <RefreshCw size={12} />
                      Mode Otomatis (hitung usia kehamilan berdasarkan HPHT)
                    </span>
                  </label>
                  {autoCalculate && (
                    <span className="text-xs text-green-600 bg-green-50 px-2 py-1 rounded-full">
                      Aktif - Usia kehamilan akan terisi otomatis
                    </span>
                  )}
                </div>
              )}
            </div>
          )}

          {/* Risk Card - ML Prediction Results */}
          {mlPrediction && (
            <div className={`mb-6 p-4 rounded-lg border-l-4 ${risikoConfig[mlPrediction.overall_label]?.border} ${risikoConfig[mlPrediction.overall_label]?.bg} shadow-sm`}>
              <div className="flex items-start gap-3">
                <div className="mt-1">{risikoConfig[mlPrediction.overall_label]?.icon}</div>
                <div className="flex-1">
                  <h3 className="font-bold text-lg flex items-center gap-2 flex-wrap">
                    Hasil Prediksi Risiko ML:
                    <span className={`inline-block px-3 py-1 rounded-full text-sm font-semibold ${risikoConfig[mlPrediction.overall_label]?.label}`}>
                      {mlPrediction.overall_label}
                    </span>
                    <span className="text-sm text-gray-500">(Skor: {mlPrediction.skor_risiko} | Risiko Aktif: {mlPrediction.active_risk_count})</span>
                  </h3>
                  
                  {/* Only Detected Risks */}
                  {mlPrediction.risk_types && mlPrediction.risk_types.length > 0 && (
                    <div className="mt-4">
                      <p className="text-sm font-semibold text-gray-700 mb-3">Risiko yang Terdeteksi:</p>
                      {mlPrediction.risk_types.filter(risk => risk.detected).length > 0 ? (
                        <div className="space-y-2">
                          {mlPrediction.risk_types
                            .filter(risk => risk.detected)
                            .sort((a, b) => b.probability - a.probability)
                            .map((risk, idx) => (
                            <div 
                              key={idx} 
                              className="bg-white rounded-lg border border-red-200 shadow-sm"
                            >
                              <button
                                onClick={() => setExpandedRisks(prev => ({ ...prev, [idx]: !prev[idx] }))}
                                className="w-full p-3 flex items-center justify-between hover:bg-red-50 transition-colors"
                              >
                                <div className="flex items-center gap-3">
                                  <span className="font-semibold text-sm text-gray-800">{risk.name}</span>
                                  <span className="text-xs px-2 py-1 rounded-full bg-red-100 text-red-700 font-medium">
                                    {(risk.probability * 100).toFixed(1)}%
                                  </span>
                                </div>
                                {expandedRisks[idx] ? <ChevronUp size={16} /> : <ChevronDown size={16} />}
                              </button>
                              {expandedRisks[idx] && risk.tindakan && risk.tindakan.length > 0 && (
                                <div className="p-3 pt-0 border-t border-red-100">
                                  <p className="text-xs font-semibold text-gray-700 mb-2 mt-2">Tindakan yang Disarankan:</p>
                                  <ul className="text-xs text-gray-600 space-y-1">
                                    {risk.tindakan.map((tindakan, tIdx) => (
                                      <li key={tIdx} className="flex items-start gap-2">
                                        <span className="text-red-500 mt-0.5">•</span>
                                        <span>{tindakan}</span>
                                      </li>
                                    ))}
                                  </ul>
                                </div>
                              )}
                            </div>
                          ))}
                        </div>
                      ) : (
                        <div className="p-4 rounded-xl border border-emerald-200 bg-emerald-50">
                          <p className="text-sm text-emerald-700 font-medium">✅ Tidak ada risiko yang terdeteksi</p>
                        </div>
                      )}
                    </div>
                  )}
                  
                  {/* Alasan Klinis */}
                  {mlPrediction.alasan_klinis && mlPrediction.alasan_klinis.length > 0 && (
                    <div className="mt-3">
                      <p className="text-sm font-semibold text-gray-700 mb-1">Alasan Klinis:</p>
                      <ul className="list-disc list-inside text-sm text-gray-600 space-y-1">
                        {mlPrediction.alasan_klinis.map((alasan, idx) => (
                          <li key={idx}>{alasan}</li>
                        ))}
                      </ul>
                    </div>
                  )}
                  
                  {/* Rekomendasi Utama */}
                  {mlPrediction.rekomendasi_utama && (
                    <div className="mt-3 p-3 bg-white rounded border border-gray-200">
                      <p className="text-sm font-semibold text-gray-700 mb-1">Rekomendasi Utama:</p>
                      <p className="text-sm text-gray-600">{mlPrediction.rekomendasi_utama}</p>
                    </div>
                  )}
                  
                  {mlPrediction.overall_label === "PERLU RUJUKAN" && (
                    <div className="mt-2 p-2 bg-red-100 rounded text-red-700 text-xs">
                      ⚠️ Pasien memerlukan rujukan segera ke fasilitas kesehatan yang lebih lengkap.
                    </div>
                  )}
                </div>
              </div>
            </div>
          )}

          {/* Info awal jika belum ada data */}
          {!mlPrediction && (
            <div className="mb-6 p-4 bg-blue-50 rounded-lg border border-blue-200 text-blue-800 flex items-center gap-2">
              <Info size={20} />
              <span>Sistem Machine Learning akan menghitung tingkat risiko kehamilan secara otomatis setelah data disimpan.</span>
            </div>
          )}

          {/* Header Form */}
          <div className="flex items-center gap-4 mb-6">
          <button
            onClick={() => navigate(-1)}
            className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full border border-[#185FA5] text-[#185FA5] text-sm font-semibold hover:bg-[#185FA5]/5 transition"
          >
            <ArrowLeft size={16} />
            <span>Kembali</span>
          </button>
            <div>
              <h1 className="text-[28px] font-bold text-gray-900">
                {isReadOnly ? "Lihat Detail" : (isEdit ? "Edit" : "Input")} Pemeriksaan ANC
              </h1>
              <p className="text-gray-500">
                {isReadOnly ? "Mode baca saja - Data tidak dapat diubah" : "Formulir standar pelayanan kehamilan terintegrasi"}
              </p>
            </div>
          </div>

          {/* Warning banner for read-only mode */}
          {isReadOnly && (
            <div className="mb-6 bg-blue-50 border border-blue-200 p-4 rounded-lg text-blue-800 flex items-center gap-3">
              <Eye size={20} className="flex-shrink-0" />
              <div>
                <p className="font-semibold">Mode Baca Saja (Dokter)</p>
                <p className="text-sm">Anda dalam mode baca. Data pemeriksaan ANC hanya dapat dilihat, tidak dapat diubah. Hubungi bidan jika perlu perubahan data.</p>
              </div>
            </div>
          )}

          {/* Step indicator - hide in read-only mode */}
          {!isReadOnly && (
            <div className="flex items-center justify-center mb-8">
              <div className="flex items-center gap-2">
                {[Activity, Beaker, MessageCircle].map((Icon, i) => (
                  <React.Fragment key={i}>
                    {i > 0 && <div className={`w-16 h-0.5 ${step > i ? "bg-indigo-600" : "bg-gray-200"}`} />}
                    <div className={`w-10 h-10 rounded-full flex items-center justify-center transition-all ${
                      step >= i + 1 ? "bg-indigo-600 text-white shadow-md" : "bg-gray-200 text-gray-500"
                    }`}>
                      <Icon size={20} />
                    </div>
                  </React.Fragment>
                ))}
              </div>
            </div>
          )}

          <form onSubmit={isReadOnly ? (e) => e.preventDefault() : handleSubmit}>
            {/* Step 1: Fisik & Antropometri */}
            {(step === 1 || isReadOnly) && (
              <div className="bg-white rounded-xl shadow-sm p-6 space-y-6 border border-gray-100">
                <h2 className="text-[22px] font-semibold text-[#185FA5] flex items-center gap-2 border-b pb-2">
                  <Activity size={20} /> Pemeriksaan Fisik & Antropometri
                </h2>
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                  {/* Tanggal Periksa */}
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Tanggal Periksa <span className="text-red-500">*</span>
                    </label>
                    <input
                      type="date"
                      name="tanggal_periksa"
                      value={form.tanggal_periksa}
                      onChange={handleChange}
                      disabled={isReadOnly}
                      className={`mt-1 w-full border rounded-lg p-2 ${errors.tanggal_periksa ? "border-red-500" : "border-gray-300"} ${isReadOnly ? "bg-gray-100 cursor-not-allowed" : ""}`}
                    />
                    <ErrorMsg field="tanggal_periksa" />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Tempat Periksa
                    </label>
                    <input
                      name="tempat_periksa"
                      value={form.tempat_periksa}
                      onChange={handleChange}
                      placeholder="Puskesmas / Klinik / RS"
                      disabled={isReadOnly}
                      className={`mt-1 w-full border rounded-lg p-2 border-gray-300 ${isReadOnly ? "bg-gray-100 cursor-not-allowed" : ""}`}
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Kunjungan Ke- <span className="text-red-500">*</span>
                    </label>
                    <select
                      name="kunjungan_ke"
                      value={form.kunjungan_ke}
                      onChange={handleChange}
                      disabled={isReadOnly || autoCalculate}
                      className={`mt-1 w-full border rounded-lg p-2 ${errors.kunjungan_ke ? "border-red-500" : "border-gray-300"} ${isReadOnly ? "bg-gray-100 cursor-not-allowed" : ""}`}
                    >
                      {[1, 2, 3, 4, 5, 6].map((n) => (
                        <option key={n}>{n}</option>
                      ))}
                    </select>
                    {autoCalculate && !isReadOnly && (
                      <p className="text-xs text-gray-400 mt-1">(Otomatis berdasarkan usia kehamilan)</p>
                    )}
                    <ErrorMsg field="kunjungan_ke" />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Trimester
                    </label>
                    <select
                      name="trimester"
                      value={form.trimester}
                      onChange={handleChange}
                      disabled={isReadOnly || autoCalculate}
                      className={`mt-1 w-full border rounded-lg p-2 border-gray-300 ${isReadOnly ? "bg-gray-100 cursor-not-allowed" : ""}`}
                    >
                      <option value="I">Trimester 1 (0-12 minggu)</option>
                      <option value="II">Trimester 2 (13-24 minggu)</option>
                      <option value="III">Trimester 3 (≥25 minggu)</option>
                    </select>
                    {autoCalculate && !isReadOnly && (
                      <p className="text-xs text-gray-400 mt-1">(Otomatis berdasarkan usia kehamilan)</p>
                    )}
                  </div>
                  
                  {/* Minggu Kehamilan - Field penting untuk auto-fill */}
                  <div className="md:col-span-2">
                    <label className="block text-sm font-medium text-gray-700">
                      Usia Kehamilan (Minggu) <span className="text-red-500">*</span>
                    </label>
                    <div className="flex gap-2">
                      <input
                        name="minggu_kehamilan"
                        type="number"
                        value={form.minggu_kehamilan}
                        onChange={handleChange}
                        placeholder="Contoh: 12"
                        disabled={isReadOnly || autoCalculate}
                        className={`mt-1 flex-1 border rounded-lg p-2 ${errors.minggu_kehamilan ? "border-red-500" : "border-gray-300"} ${isReadOnly ? "bg-gray-100 cursor-not-allowed" : ""}`}
                      />
                      {!isReadOnly && !autoCalculate && kehamilanDetail?.hpht && (
                        <button
                          type="button"
                          onClick={() => {
                            const usia = hitungUsiaKehamilanDariHPHT(kehamilanDetail.hpht, form.tanggal_periksa);
                            if (usia && usia.minggu > 0) {
                              setForm(prev => ({ ...prev, minggu_kehamilan: usia.minggu.toString() }));
                            }
                          }}
                          className="mt-1 px-3 py-2 bg-indigo-100 text-indigo-700 rounded-lg text-sm hover:bg-indigo-200 transition flex items-center gap-1"
                        >
                          <RefreshCw size={14} />
                          Hitung dari HPHT
                        </button>
                      )}
                    </div>
                    <ErrorMsg field="minggu_kehamilan" />
                    {currentUsiaKehamilan && currentUsiaKehamilan.minggu > 0 && autoCalculate && (
                      <p className="text-xs text-green-600 mt-1">
                        ✓ Usia kehamilan: {currentUsiaKehamilan.display} (dihitung otomatis dari HPHT)
                      </p>
                    )}
                  </div>
                  
                  {/* Antropometri */}
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Berat Badan (kg)
                    </label>
                    <input
                      name="berat_badan"
                      type="number"
                      step="0.1"
                      value={form.berat_badan}
                      onChange={handleChange}
                      placeholder="58"
                      disabled={isReadOnly}
                      className={`mt-1 w-full border rounded-lg p-2 ${errors.berat_badan ? "border-red-500" : "border-gray-300"} ${isReadOnly ? "bg-gray-100 cursor-not-allowed" : ""}`}
                    />
                    <ErrorMsg field="berat_badan" />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Tinggi Badan (cm)
                    </label>
                    <input
                      name="tinggi_badan"
                      type="number"
                      step="0.1"
                      value={form.tinggi_badan}
                      onChange={handleChange}
                      placeholder="150"
                      disabled={isReadOnly}
                      className={`mt-1 w-full border rounded-lg p-2 ${errors.tinggi_badan ? "border-red-500" : "border-gray-300"} ${isReadOnly ? "bg-gray-100 cursor-not-allowed" : ""}`}
                    />
                    <ErrorMsg field="tinggi_badan" />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      LILA (cm)
                    </label>
                    <input
                      name="lingkar_lengan_atas"
                      type="number"
                      step="0.1"
                      value={form.lingkar_lengan_atas}
                      onChange={handleChange}
                      placeholder="23"
                      disabled={isReadOnly}
                      className={`mt-1 w-full border rounded-lg p-2 ${errors.lingkar_lengan_atas ? "border-red-500" : "border-gray-300"} ${isReadOnly ? "bg-gray-100 cursor-not-allowed" : ""}`}
                    />
                    <ErrorMsg field="lingkar_lengan_atas" />
                  </div>
                  
                  {/* Tekanan Darah */}
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Tekanan Darah Sistole (mmHg)
                    </label>
                    <input
                      name="sistole"
                      type="number"
                      value={form.sistole}
                      onChange={handleChange}
                      placeholder="120"
                      disabled={isReadOnly}
                      className={`mt-1 w-full border rounded-lg p-2 ${errors.sistole ? "border-red-500" : "border-gray-300"} ${isReadOnly ? "bg-gray-100 cursor-not-allowed" : ""}`}
                    />
                    <ErrorMsg field="sistole" />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Tekanan Darah Diastole (mmHg)
                    </label>
                    <input
                      name="diastole"
                      type="number"
                      value={form.diastole}
                      onChange={handleChange}
                      placeholder="80"
                      disabled={isReadOnly}
                      className={`mt-1 w-full border rounded-lg p-2 ${errors.diastole ? "border-red-500" : "border-gray-300"} ${isReadOnly ? "bg-gray-100 cursor-not-allowed" : ""}`}
                    />
                    <ErrorMsg field="diastole" />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Tinggi Rahim / TFU (cm)
                    </label>
                    <input
                      name="tinggi_rahim"
                      type="number"
                      step="0.1"
                      value={form.tinggi_rahim}
                      onChange={handleChange}
                      placeholder="20"
                      disabled={isReadOnly}
                      className={`mt-1 w-full border rounded-lg p-2 ${errors.tinggi_rahim ? "border-red-500" : "border-gray-300"} ${isReadOnly ? "bg-gray-100 cursor-not-allowed" : ""}`}
                    />
                    <ErrorMsg field="tinggi_rahim" />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Denyut Jantung Janin (x/menit)
                    </label>
                    <input
                      name="denyut_jantung_janin"
                      type="number"
                      value={form.denyut_jantung_janin}
                      onChange={handleChange}
                      placeholder="140"
                      disabled={isReadOnly}
                      className={`mt-1 w-full border rounded-lg p-2 ${errors.denyut_jantung_janin ? "border-red-500" : "border-gray-300"} ${isReadOnly ? "bg-gray-100 cursor-not-allowed" : ""}`}
                    />
                    <ErrorMsg field="denyut_jantung_janin" />
                  </div>
                  
                  <div className="md:col-span-2">
                    <label className="block text-sm font-medium text-gray-700">
                      Letak Janin (deskripsi)
                    </label>
                    <input
                      name="letak_denyut_jantung_bayi"
                      value={form.letak_denyut_jantung_bayi}
                      onChange={handleChange}
                      placeholder="Kepala / Sungsang / Melintang"
                      disabled={isReadOnly}
                      className={`mt-1 w-full border rounded-lg p-2 border-gray-300 ${isReadOnly ? "bg-gray-100 cursor-not-allowed" : ""}`}
                    />
                  </div>
                </div>
              </div>
            )}

            {/* Step 2: Laboratorium - sama seperti sebelumnya */}
            {(step === 2 || isReadOnly) && (
              <div className="bg-white rounded-xl shadow-sm p-6 space-y-6 border border-gray-100">
                <h2 className="text-lg font-semibold flex items-center gap-2 text-indigo-800 border-b pb-2">
                  <Beaker size={20} /> Laboratorium & Penunjang
                </h2>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Kadar Hb (g/dL)
                    </label>
                    <input
                      name="tes_lab_hb"
                      type="number"
                      step="0.1"
                      value={form.tes_lab_hb}
                      onChange={handleChange}
                      placeholder="11.5"
                      disabled={isReadOnly}
                      className={`mt-1 w-full border rounded-lg p-2 ${errors.tes_lab_hb ? "border-red-500" : "border-gray-300"} ${isReadOnly ? "bg-gray-100 cursor-not-allowed" : ""}`}
                    />
                    <ErrorMsg field="tes_lab_hb" />
                    {form.tes_lab_hb && parseFloat(form.tes_lab_hb) < 11 && (
                      <p className="text-xs text-yellow-600 mt-1 flex items-center gap-1">
                        <AlertCircle size={12} /> Hb rendah, perlu suplemen zat besi
                      </p>
                    )}
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Gula Darah (mg/dL)
                    </label>
                    <input
                      name="tes_lab_gula_darah"
                      type="number"
                      value={form.tes_lab_gula_darah}
                      onChange={handleChange}
                      placeholder="90"
                      disabled={isReadOnly}
                      className={`mt-1 w-full border rounded-lg p-2 ${errors.tes_lab_gula_darah ? "border-red-500" : "border-gray-300"} ${isReadOnly ? "bg-gray-100 cursor-not-allowed" : ""}`}
                    />
                    <ErrorMsg field="tes_lab_gula_darah" />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Protein Urine
                    </label>
                    <select
                      name="tes_lab_protein_urine"
                      value={form.tes_lab_protein_urine}
                      onChange={handleChange}
                      disabled={isReadOnly}
                      className={`mt-1 w-full border rounded-lg p-2 border-gray-300 ${isReadOnly ? "bg-gray-100 cursor-not-allowed" : ""}`}
                    >
                      <option>negatif</option>
                      <option>positif 1</option>
                      <option>positif 2</option>
                      <option>positif 3</option>
                    </select>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Triple Eliminasi
                    </label>
                    <select
                      name="tripel_eliminasi"
                      value={form.tripel_eliminasi}
                      onChange={handleChange}
                      disabled={isReadOnly}
                      className={`mt-1 w-full border rounded-lg p-2 border-gray-300 ${isReadOnly ? "bg-gray-100 cursor-not-allowed" : ""}`}
                    >
                      <option>non reaktif</option>
                      <option>reaktif HIV</option>
                      <option>reaktif Sifilis</option>
                      <option>reaktif HBsAg</option>
                    </select>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Golongan Darah
                    </label>
                    <select
                      name="tes_golongan_darah"
                      value={form.tes_golongan_darah}
                      onChange={handleChange}
                      disabled={isReadOnly}
                      className={`mt-1 w-full border rounded-lg p-2 border-gray-300 ${isReadOnly ? "bg-gray-100 cursor-not-allowed" : ""}`}
                    >
                      <option value="">Pilih Golongan Darah</option>
                      <option value="A">A</option>
                      <option value="B">B</option>
                      <option value="AB">AB</option>
                      <option value="O">O</option>
                    </select>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      USG (temuan)
                    </label>
                    <input
                      name="usg"
                      value={form.usg}
                      onChange={handleChange}
                      placeholder="Normal / Plasenta letak rendah dll"
                      disabled={isReadOnly}
                      className={`mt-1 w-full border rounded-lg p-2 border-gray-300 ${isReadOnly ? "bg-gray-100 cursor-not-allowed" : ""}`}
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Tablet Tambah Darah (jumlah)
                    </label>
                    <input
                      name="tablet_tambah_darah"
                      type="number"
                      value={form.tablet_tambah_darah}
                      onChange={handleChange}
                      placeholder="90"
                      disabled={isReadOnly}
                      className={`mt-1 w-full border rounded-lg p-2 ${errors.tablet_tambah_darah ? "border-red-500" : "border-gray-300"} ${isReadOnly ? "bg-gray-100 cursor-not-allowed" : ""}`}
                    />
                    <ErrorMsg field="tablet_tambah_darah" />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Status Imunisasi Tetanus
                    </label>
                    <select
                      name="status_imunisasi_tetanus"
                      value={form.status_imunisasi_tetanus}
                      onChange={handleChange}
                      disabled={isReadOnly}
                      className={`mt-1 w-full border rounded-lg p-2 border-gray-300 ${isReadOnly ? "bg-gray-100 cursor-not-allowed" : ""}`}
                    >
                      {[
                        "Belum pernah imunisasi TT",
                        "Dosis pertama",
                        "Dosis kedua",
                        "Dosis ketiga",
                        "Dosis keempat",
                        "Dosis kelima (perlindungan jangka panjang)",
                      ].map((t) => (
                        <option key={t}>{t}</option>
                      ))}
                    </select>
                  </div>
                </div>
              </div>
            )}

            {/* Step 3: Konseling */}
            {(step === 3 || isReadOnly) && (
              <div className="bg-white rounded-xl shadow-sm p-6 space-y-6 border border-gray-100">
                <h2 className="text-lg font-semibold flex items-center gap-2 text-indigo-800 border-b pb-2">
                  <MessageCircle size={20} /> Konseling & Tindak Lanjut
                </h2>
                <div className="grid grid-cols-1 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Skrining Dokter / Temuan
                    </label>
                    <textarea
                      name="skrining_dokter"
                      value={form.skrining_dokter}
                      onChange={handleChange}
                      rows={2}
                      placeholder="Hasil skrining preeklampsia, diabetes, dll"
                      disabled={isReadOnly}
                      className={`mt-1 w-full border rounded-lg p-2 border-gray-300 ${isReadOnly ? "bg-gray-100 cursor-not-allowed" : ""}`}
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Konseling yang Diberikan
                    </label>
                    <textarea
                      name="konseling"
                      value={form.konseling}
                      onChange={handleChange}
                      rows={2}
                      placeholder="Edukasi tanda bahaya, gizi, imunisasi, KB pasca persalinan"
                      disabled={isReadOnly}
                      className={`mt-1 w-full border rounded-lg p-2 border-gray-300 ${isReadOnly ? "bg-gray-100 cursor-not-allowed" : ""}`}
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Tata Laksana Kasus
                    </label>
                    <textarea
                      name="tata_laksana_kasus"
                      value={form.tata_laksana_kasus}
                      onChange={handleChange}
                      rows={2}
                      placeholder="Obat, rujukan, jadwal kontrol berikutnya"
                      disabled={isReadOnly}
                      className={`mt-1 w-full border rounded-lg p-2 border-gray-300 ${isReadOnly ? "bg-gray-100 cursor-not-allowed" : ""}`}
                    />
                  </div>
                </div>
              </div>
            )}

            {/* Navigation Buttons - hide in read-only mode */}
            {!isReadOnly && (
              <div className="flex gap-4 mt-8 pb-8">
                {step > 1 && (
                  <button
                    type="button"
                    onClick={handlePrev}
                    className="px-6 py-3 border border-gray-300 rounded-lg hover:bg-gray-50 font-medium transition"
                  >
                    ← Kembali
                  </button>
                )}
                {step < 3 ? (
                  <button
                    type="button"
                    onClick={handleNext}
                    className="flex-1 bg-indigo-600 hover:bg-indigo-700 text-white font-semibold py-3 rounded-lg shadow transition"
                  >
                    Selanjutnya →
                  </button>
                ) : (
                  <button
                    type="submit"
                    disabled={saving}
                    className="flex-1 bg-green-600 hover:bg-green-700 text-white font-semibold py-3 rounded-lg shadow flex items-center justify-center gap-2 transition disabled:opacity-50"
                  >
                    {saving ? <Loader2 className="animate-spin" size={20} /> : <Save size={20} />}
                    {saving ? "Menyimpan..." : "Simpan Pemeriksaan"}
                  </button>
                )}
              </div>
            )}
          </form>
        </div>
      </div>
    </MainLayout>
  );
}