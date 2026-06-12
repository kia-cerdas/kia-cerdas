// src/pages/Ibu/PemeriksaanDokterT1Complete.jsx
import React, { useEffect, useState, useRef, useCallback } from "react";
import { useParams, useNavigate, useLocation } from "react-router-dom";
import Swal from "sweetalert2";
import MainLayout from "../../components/Layout/MainLayout";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import { getCurrentUser, isDokterUser, isBidanUser } from "../../services/auth";
import {
  getDokterT1CompleteByKehamilanId,
  createDokterT1Complete,
  updateDokterT1Complete,
  deleteDokterT1Complete,
} from "../../services/pemeriksaanDokter";
import {
  Save,
  ArrowLeft,
  AlertCircle,
  Loader2,
  User,
  Activity,
  Eye,
  FlaskConical,
  Brain,
  ChevronDown,
  ChevronUp,
  CheckCircle,
  ChevronRight,
  ChevronLeft,
  Upload,
  Image as ImageIcon,
  Calendar,
  Baby,
  Info,
  RefreshCw,
  Lock, // Tambahkan import Lock
  Trash2,
} from "lucide-react";
import { getKehamilanById } from "../../services/kehamilan";
// Tambahkan fungsi validasi tanggal setelah formatTanggalIndo
const isValidDate = (dateStr) => {
  if (!dateStr) return false;
  const selected = new Date(dateStr);
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  return selected <= today;
};

const getDateError = (dateStr, fieldName = "Tanggal") => {
  if (!dateStr) return `${fieldName} harus diisi`;
  if (!isValidDate(dateStr))
    return `${fieldName} tidak boleh melebihi hari ini`;
  return null;
};

const hitungHPLDariHPHT = (hpht) => {
  if (!hpht) return null;

  let hphtDate;
  try {
    hphtDate = new Date(hpht);
    if (isNaN(hphtDate.getTime())) {
      const parts = hpht.split("T")[0].split("-");
      if (parts.length === 3) {
        hphtDate = new Date(parts[0], parts[1] - 1, parts[2]);
      }
    }
    if (isNaN(hphtDate.getTime())) return null;
  } catch (e) {
    return null;
  }

  const hplDate = new Date(hphtDate);
  hplDate.setDate(hplDate.getDate() + 280);

  const year = hplDate.getFullYear();
  const month = String(hplDate.getMonth() + 1).padStart(2, "0");
  const day = String(hplDate.getDate()).padStart(2, "0");

  return {
    date: `${year}-${month}-${day}`,
    display: hplDate.toLocaleDateString("id-ID", {
      day: "2-digit",
      month: "long",
      year: "numeric",
    }),
  };
};

// Tambahkan fungsi helper untuk hitung usia kehamilan
const hitungUsiaKehamilanDariHPHT = (hpht, tanggalPeriksa = null) => {
  if (!hpht) return null;

  let hphtDate;
  try {
    hphtDate = new Date(hpht);
    if (isNaN(hphtDate.getTime())) {
      const parts = hpht.split("T")[0].split("-");
      if (parts.length === 3) {
        hphtDate = new Date(parts[0], parts[1] - 1, parts[2]);
      }
    }
    if (isNaN(hphtDate.getTime())) return null;
  } catch (e) {
    return null;
  }

  let periksaDate;
  try {
    if (tanggalPeriksa) {
      periksaDate = new Date(tanggalPeriksa);
      if (isNaN(periksaDate.getTime())) {
        const parts = tanggalPeriksa.split("-");
        if (parts.length === 3) {
          periksaDate = new Date(parts[0], parts[1] - 1, parts[2]);
        }
      }
    } else {
      periksaDate = new Date();
    }
    if (isNaN(periksaDate.getTime())) return null;
  } catch (e) {
    return null;
  }

  const diffTime = periksaDate.getTime() - hphtDate.getTime();
  const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

  if (diffDays < 0) {
    return {
      minggu: 0,
      hari: 0,
      totalHari: 0,
      display: "0 minggu 0 hari (Belum hamil)",
    };
  }

  const weeks = Math.floor(diffDays / 7);
  const remainingDays = diffDays % 7;

  return {
    minggu: weeks,
    hari: remainingDays,
    totalHari: diffDays,
    display: `${weeks} minggu ${remainingDays} hari`,
  };
};

const formatTanggalIndo = (dateStr) => {
  if (!dateStr) return "-";
  const date = new Date(dateStr);
  if (isNaN(date.getTime())) return "-";
  return date.toLocaleDateString("id-ID", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  });
};

// ── Helper: "YYYY-MM-DD" → "YYYY-MM-DDT00:00:00Z" (null jika kosong) ─────
// ── Helper: ambil tanggal (YYYY-MM-DD) dari string ISO maupun plain date ──
const toDateOnly = (val) => {
  if (!val) return "";
  return typeof val === "string" ? val.split("T")[0] : "";
};

const todayDateStr = () => new Date().toISOString().split("T")[0];

const buildKehamilanPrefill = (kehamilanDetail, tanggalPeriksa = todayDateStr()) => {
  if (!kehamilanDetail?.hpht) return {};
  const hpht = toDateOnly(kehamilanDetail.hpht);
  const usia = hitungUsiaKehamilanDariHPHT(kehamilanDetail.hpht, tanggalPeriksa);
  const hpl = hitungHPLDariHPHT(kehamilanDetail.hpht);
  const hplFromKehamilan = toDateOnly(kehamilanDetail.taksiran_persalinan);
  return {
    hpht,
    umur_hamil_hpht_minggu: usia?.minggu?.toString() || "",
    hpl_berdasarkan_hpht: hpl?.date || hplFromKehamilan || "",
  };
};

// ── Helper Components ─────────────────────────────────────────────────────
function Field({ label, children, colSpan = "" }) {
  return (
    <div className={colSpan}>
      <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1">
        {label}
      </label>
      {children}
    </div>
  );
}

function ErrorMessage({ message }) {
  if (!message) return null;
  return <p className="text-xs text-red-500 font-medium mt-0.5">{message}</p>;
}

const inputCls =
  "w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-400 focus:border-transparent bg-white transition";
const selectCls =
  "w-full border border-gray-200 rounded-lg px-3 py-2 text-sm text-gray-700 focus:outline-none focus:ring-2 focus:ring-indigo-400 focus:border-transparent bg-white transition";

function Section({
  icon: Icon,
  title,
  color = "indigo",
  children,
  defaultOpen = true,
}) {
  const [open, setOpen] = useState(defaultOpen);
  const colorMap = {
    indigo: "bg-indigo-50 text-indigo-700 border-indigo-200",
    teal: "bg-teal-50 text-teal-700 border-teal-200",
    violet: "bg-violet-50 text-violet-700 border-violet-200",
    rose: "bg-rose-50 text-rose-700 border-rose-200",
    amber: "bg-amber-50 text-amber-700 border-amber-200",
  };
  const headerColor = colorMap[color] || colorMap.indigo;
  return (
    <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
      <button
        type="button"
        onClick={() => setOpen((v) => !v)}
        className={`w-full flex items-center justify-between px-6 py-4 border-b ${headerColor} transition-colors`}
      >
        <div className="flex items-center gap-3">
          {Icon && <Icon size={18} />}
          <span className="font-semibold text-sm tracking-wide">{title}</span>
        </div>
        {open ? <ChevronUp size={16} /> : <ChevronDown size={16} />}
      </button>
      {open && <div className="p-6">{children}</div>}
    </div>
  );
}

// ── Nilai awal form ───────────────────────────────────────────────────────
const INITIAL_FORM = {
  kehamilan_id: "",
  nama_dokter: "",
  tanggal_periksa: "",
  konsep_anamnesa_pemeriksaan: "",
  fisik_konjungtiva: "Normal",
  fisik_sklera: "Normal",
  fisik_kulit: "Normal",
  fisik_leher: "Normal",
  fisik_gigi_mulut: "Normal",
  fisik_tht: "Normal",
  fisik_dada_jantung: "Normal",
  fisik_dada_paru: "Normal",
  fisik_perut: "Normal",
  fisik_tungkai: "Normal",
  hpht: "",
  keteraturan_haid: "Teratur",
  umur_hamil_hpht_minggu: "",
  hpl_berdasarkan_hpht: "",
  umur_hamil_usg_minggu: "",
  hpl_berdasarkan_usg: "",
  usg_jumlah_gs: "",
  usg_diameter_gs_cm: "",
  usg_diameter_gs_minggu: "",
  usg_diameter_gs_hari: "",
  usg_jumlah_bayi: "",
  usg_crl_cm: "",
  usg_crl_minggu: "",
  usg_crl_hari: "",
  usg_letak_produk_kehamilan: "",
  usg_pulsasi_jantung: "",
  usg_kecurigaan_temuan_abnormal: "Tidak",
  usg_keterangan_temuan_abnormal: "",
  gambar_usg: "",
  tanggal_lab: "",
  lab_hemoglobin_hasil: "",
  lab_hemoglobin_rencana_tindak_lanjut: "",
  lab_golongan_darah_rhesus_hasil: "",
  lab_golongan_darah_rhesus_rencana_tindak_lanjut: "",
  lab_gula_darah_sewaktu_hasil: "",
  lab_gula_darah_sewaktu_rencana_tindak_lanjut: "",
  lab_hiv_hasil: "NonReaktif",
  lab_hiv_rencana_tindak_lanjut: "",
  lab_sifilis_hasil: "NonReaktif",
  lab_sifilis_rencana_tindak_lanjut: "",
  lab_hepatitis_b_hasil: "NonReaktif",
  lab_hepatitis_b_rencana_tindak_lanjut: "",
  tanggal_skrining_jiwa: "",
  skrining_jiwa_hasil: "",
  skrining_jiwa_tindak_lanjut: "",
  skrining_jiwa_perlu_rujukan: "Tidak",
  kesimpulan: "",
  rekomendasi: "",
};

// ── Main Component ────────────────────────────────────────────────────────
export default function PemeriksaanDokterT1Complete() {
  const { id } = useParams();
  const navigate = useNavigate();
  const location = useLocation();
  const fileInputRef = useRef(null);

  const [kehamilan, setKehamilan] = useState(null);
  const [existingData, setExistingData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState(null);
  const [currentStep, setCurrentStep] = useState(1);
  const [validationErrors, setValidationErrors] = useState({});
  // Di dalam komponen, setelah state declarations lainnya
  const [kehamilanDetail, setKehamilanDetail] = useState(null);
  const [usiaKehamilan, setUsiaKehamilan] = useState(null);

  const [usgImageFile, setUsgImageFile] = useState(null);
  const [usgImagePreview, setUsgImagePreview] = useState("");

  const [form, setForm] = useState(INITIAL_FORM);

  const [currentUser, setCurrentUser] = useState(null);
  // const [isEditMode, setIsEditMode] = useState(false);
  const [canEdit, setCanEdit] = useState(false);
  const [canDelete, setCanDelete] = useState(false);
  // Di dalam komponen PemeriksaanDokterT1Complete, setelah state declarations
  const [isTrimester1, setIsTrimester1] = useState(true);
  const [usiaKehamilanSaatIni, setUsiaKehamilanSaatIni] = useState(null);
  const [showTrimesterWarning, setShowTrimesterWarning] = useState(false);

  // Hitung usia kehamilan saat ini (berdasarkan hari ini) untuk validasi trimester
  useEffect(() => {
    if (kehamilanDetail?.hpht) {
      const usia = hitungUsiaKehamilanDariHPHT(
        kehamilanDetail.hpht,
        new Date(),
      );
      if (usia) {
        setUsiaKehamilanSaatIni(usia);
        // Trimester 1: 0-12 minggu
        const isTrimester1Valid = usia.minggu >= 0 && usia.minggu <= 12;
        setIsTrimester1(isTrimester1Valid);

        console.log(
          `Usia kehamilan saat ini: ${usia.display} - Trimester 1: ${isTrimester1Valid}`,
        );
      }
    }
  }, [kehamilanDetail]);

  // Cek role user saat komponen mount
  useEffect(() => {
    const user = getCurrentUser();
    setCurrentUser(user);

    const isDokter = isDokterUser(user);
    const isBidan = isBidanUser(user);

    // Dokter: bisa create, edit, delete
    // Bidan: hanya view
    setCanEdit(isDokter);
    setCanDelete(isDokter);

    // Log untuk debugging
    console.log("[Role Check] User role:", user?.role);
    console.log("[Role Check] Is Dokter:", isDokter);
    console.log("[Role Check] Is Bidan:", isBidan);
    console.log("[Role Check] Can Edit:", isDokter);
    console.log("[Role Check] Can Delete:", isDokter);
  }, []);

  // Update useEffect untuk hitung usia kehamilan dan HPL
  useEffect(() => {
    if (!kehamilanDetail?.hpht) return;
    if (!form.tanggal_periksa) return;

    const usia = hitungUsiaKehamilanDariHPHT(
      kehamilanDetail.hpht,
      form.tanggal_periksa,
    );
    const hpl = hitungHPLDariHPHT(kehamilanDetail.hpht);

    if (usia) {
      setUsiaKehamilan(usia);

      // Auto update field umur_hamil_hpht_minggu
      if (!form.umur_hamil_hpht_minggu || form.umur_hamil_hpht_minggu === "0") {
        setForm((prev) => ({
          ...prev,
          umur_hamil_hpht_minggu: usia.minggu.toString(),
          hpht: toDateOnly(kehamilanDetail.hpht),
        }));
      }

      // Auto update HPL berdasarkan HPHT
      if (
        hpl &&
        (!form.hpl_berdasarkan_hpht || form.hpl_berdasarkan_hpht === "")
      ) {
        setForm((prev) => ({
          ...prev,
          hpl_berdasarkan_hpht: hpl.date,
        }));
      }
    }
  }, [
    kehamilanDetail,
    form.tanggal_periksa,
    form.umur_hamil_hpht_minggu,
    form.hpl_berdasarkan_hpht,
  ]);

  // Tambahkan useEffect untuk mengambil detail kehamilan
  useEffect(() => {
    const fetchKehamilanDetail = async () => {
      // Ambil kehamilan_id dari existingData atau dari parameter
      let targetKehamilanId = null;

      if (existingData?.dokter?.kehamilan_id) {
        targetKehamilanId = existingData.dokter.kehamilan_id;
      } else if (kehamilan?.id) {
        targetKehamilanId = kehamilan.id;
      }

      if (!targetKehamilanId) return;

      try {
        const data = await getKehamilanById(targetKehamilanId);
        setKehamilanDetail(data);
      } catch (err) {
        console.error("Error fetching kehamilan detail:", err);
      }
    };

    if (kehamilan || existingData) {
      fetchKehamilanDetail();
    }
  }, [kehamilan, existingData]);

  // Hitung usia kehamilan otomatis
  useEffect(() => {
    if (!kehamilanDetail?.hpht) return;
    if (!form.tanggal_periksa) return;

    const usia = hitungUsiaKehamilanDariHPHT(
      kehamilanDetail.hpht,
      form.tanggal_periksa,
    );
    if (usia) {
      setUsiaKehamilan(usia);

      // Auto update field umur_hamil_hpht_minggu jika belum diisi atau mode auto
      if (!form.umur_hamil_hpht_minggu || form.umur_hamil_hpht_minggu === "0") {
        setForm((prev) => ({
          ...prev,
          umur_hamil_hpht_minggu: usia.minggu.toString(),
          hpht: toDateOnly(kehamilanDetail.hpht),
        }));
      }
    }
  }, [kehamilanDetail, form.tanggal_periksa, form.umur_hamil_hpht_minggu]);

  // Baca query ?step=N
  useEffect(() => {
    const stepParam = new URLSearchParams(location.search).get("step");
    const step = parseInt(stepParam, 10);
    if (!Number.isNaN(step) && step >= 1 && step <= 4) setCurrentStep(step);
  }, [location.search]);

  // Fungsi untuk cek trimester sebelum menyimpan (untuk mode CREATE)
  const checkTrimesterBeforeSave = () => {
    // Hanya cek untuk mode CREATE (belum ada data)
    if (!isEditModeFlag && !isTrimester1) {
      setShowTrimesterWarning(true);
      return false;
    }
    return true;
  };

  // Fungsi untuk melanjutkan penyimpanan meskipun melewati trimester
  const proceedSaveDespiteWarning = async () => {
    setShowTrimesterWarning(false);
    await handleSaveDirect();
  };

  // ── Fetch data ────────────────────────────────────────────────────────
  const fetchData = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const currentUser = getCurrentUser();
      const dokterName = currentUser?.nama || currentUser?.name || "";
      const isDokter = isDokterUser(currentUser);

      const kehamilanList = await getKehamilanByIbuId(id);
      if (!kehamilanList || kehamilanList.length === 0) {
        setError("Belum ada data kehamilan untuk ibu ini.");
        return;
      }
      const aktif = kehamilanList[0];
      setKehamilan(aktif);

      let kehamilanData = null;
      try {
        kehamilanData = await getKehamilanById(aktif.id);
        setKehamilanDetail(kehamilanData);
      } catch (err) {
        console.error("Error fetching kehamilan detail:", err);
      }

      // Coba ambil data existing
      let res = null;
      try {
        res = await getDokterT1CompleteByKehamilanId(aktif.id);
      } catch {
        res = null;
      }

      const normalized = normalizeResponse(res);
      if (!normalized) {
        // Tidak ada data → mode create
        setExistingData(null);
        const tanggalPeriksa = todayDateStr();
        const prefill = buildKehamilanPrefill(kehamilanData, tanggalPeriksa);
        if (!isDokter) {
          setError(
            "Belum ada data pemeriksaan. Hanya dokter yang dapat menambah data.",
          );
        } else {
          setForm({
            ...INITIAL_FORM,
            kehamilan_id: aktif.id,
            nama_dokter: dokterName,
            tanggal_periksa: tanggalPeriksa,
            ...prefill,
          });
        }
        return;
      }
      // setIsEditMode(true);
      const { dokter, lab_jiwa } = normalized;
      const lab = lab_jiwa || {};

      setExistingData(normalized);
      setForm({
        kehamilan_id: dokter.kehamilan_id ?? aktif.id,
        nama_dokter: dokter.nama_dokter || dokterName || "",
        tanggal_periksa: toDateOnly(dokter.tanggal_periksa),
        konsep_anamnesa_pemeriksaan: dokter.konsep_anamnesa_pemeriksaan || "",
        fisik_konjungtiva: dokter.fisik_konjungtiva || "Normal",
        fisik_sklera: dokter.fisik_sklera || "Normal",
        fisik_kulit: dokter.fisik_kulit || "Normal",
        fisik_leher: dokter.fisik_leher || "Normal",
        fisik_gigi_mulut: dokter.fisik_gigi_mulut || "Normal",
        fisik_tht: dokter.fisik_tht || "Normal",
        fisik_dada_jantung: dokter.fisik_dada_jantung || "Normal",
        fisik_dada_paru: dokter.fisik_dada_paru || "Normal",
        fisik_perut: dokter.fisik_perut || "Normal",
        fisik_tungkai: dokter.fisik_tungkai || "Normal",
        hpht: toDateOnly(dokter.hpht),
        keteraturan_haid: dokter.keteraturan_haid || "Teratur",
        umur_hamil_hpht_minggu: dokter.umur_hamil_hpht_minggu?.toString() || "",
        hpl_berdasarkan_hpht: toDateOnly(dokter.hpl_berdasarkan_hpht),
        umur_hamil_usg_minggu: dokter.umur_hamil_usg_minggu?.toString() || "",
        hpl_berdasarkan_usg: toDateOnly(dokter.hpl_berdasarkan_usg),
        usg_jumlah_gs: dokter.usg_jumlah_gs || "",
        usg_diameter_gs_cm: dokter.usg_diameter_gs_cm?.toString() || "",
        usg_diameter_gs_minggu: dokter.usg_diameter_gs_minggu?.toString() || "",
        usg_diameter_gs_hari: dokter.usg_diameter_gs_hari?.toString() || "",
        usg_jumlah_bayi: dokter.usg_jumlah_bayi || "",
        // Handle variasi nama kolom CRL (dengan/tanpa underscore)
        usg_crl_cm: (dokter.usg_crl_cm ?? dokter.usgcrl_cm)?.toString() || "",
        usg_crl_minggu:
          (dokter.usg_crl_minggu ?? dokter.usgcrl_minggu)?.toString() || "",
        usg_crl_hari:
          (dokter.usg_crl_hari ?? dokter.usgcrl_hari)?.toString() || "",
        usg_letak_produk_kehamilan: dokter.usg_letak_produk_kehamilan || "",
        usg_pulsasi_jantung: dokter.usg_pulsasi_jantung || "",
        usg_kecurigaan_temuan_abnormal:
          dokter.usg_kecurigaan_temuan_abnormal || "Tidak",
        usg_keterangan_temuan_abnormal:
          dokter.usg_keterangan_temuan_abnormal || "",
        gambar_usg: dokter.gambar_usg || dokter.GambarUSG || "",
        // Lab data – ambil dari lab_jiwa atau dari dokter jika datar
        tanggal_lab: toDateOnly(lab.tanggal_lab || dokter.tanggal_lab),
        lab_hemoglobin_hasil:
          lab.lab_hemoglobin_hasil?.toString() ||
          dokter.lab_hemoglobin_hasil?.toString() ||
          "",
        lab_hemoglobin_rencana_tindak_lanjut:
          lab.lab_hemoglobin_rencana_tindak_lanjut ||
          dokter.lab_hemoglobin_rencana_tindak_lanjut ||
          "",
        lab_golongan_darah_rhesus_hasil:
          lab.lab_golongan_darah_rhesus_hasil ||
          dokter.lab_golongan_darah_rhesus_hasil ||
          "",
        lab_golongan_darah_rhesus_rencana_tindak_lanjut:
          lab.lab_golongan_darah_rhesus_rencana_tindak_lanjut ||
          dokter.lab_golongan_darah_rhesus_rencana_tindak_lanjut ||
          "",
        lab_gula_darah_sewaktu_hasil:
          lab.lab_gula_darah_sewaktu_hasil?.toString() ||
          dokter.lab_gula_darah_sewaktu_hasil?.toString() ||
          "",
        lab_gula_darah_sewaktu_rencana_tindak_lanjut:
          lab.lab_gula_darah_sewaktu_rencana_tindak_lanjut ||
          dokter.lab_gula_darah_sewaktu_rencana_tindak_lanjut ||
          "",
        lab_hiv_hasil:
          lab.lab_hiv_hasil || dokter.lab_hiv_hasil || "NonReaktif",
        lab_hiv_rencana_tindak_lanjut:
          lab.lab_hiv_rencana_tindak_lanjut ||
          dokter.lab_hiv_rencana_tindak_lanjut ||
          "",
        lab_sifilis_hasil:
          lab.lab_sifilis_hasil || dokter.lab_sifilis_hasil || "NonReaktif",
        lab_sifilis_rencana_tindak_lanjut:
          lab.lab_sifilis_rencana_tindak_lanjut ||
          dokter.lab_sifilis_rencana_tindak_lanjut ||
          "",
        lab_hepatitis_b_hasil:
          lab.lab_hepatitis_b_hasil ||
          dokter.lab_hepatitis_b_hasil ||
          "NonReaktif",
        lab_hepatitis_b_rencana_tindak_lanjut:
          lab.lab_hepatitis_b_rencana_tindak_lanjut ||
          dokter.lab_hepatitis_b_rencana_tindak_lanjut ||
          "",
        tanggal_skrining_jiwa: toDateOnly(
          lab.tanggal_skrining_jiwa || dokter.tanggal_skrining_jiwa,
        ),
        skrining_jiwa_hasil:
          lab.skrining_jiwa_hasil || dokter.skrining_jiwa_hasil || "",
        skrining_jiwa_tindak_lanjut:
          lab.skrining_jiwa_tindak_lanjut ||
          dokter.skrining_jiwa_tindak_lanjut ||
          "",
        skrining_jiwa_perlu_rujukan:
          lab.skrining_jiwa_perlu_rujukan ||
          dokter.skrining_jiwa_perlu_rujukan ||
          "Tidak",
        kesimpulan: lab.kesimpulan || dokter.kesimpulan || "",
        rekomendasi: lab.rekomendasi || dokter.rekomendasi || "",
      });

      const img = dokter.gambar_usg || dokter.GambarUSG;
      if (img && img.startsWith("data:image")) setUsgImagePreview(img);
    } catch (err) {
      console.error("Error fetch data:", err);
      setError("Terjadi kesalahan saat memuat data.");
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  // ── Normalize Response ─────────────────────────────────────────────────
  function normalizeResponse(res) {
    if (!res) return null;

    // Unwrap .data jika ada
    let body =
      res.data && (res.data.dokter || res.data.id_trimester1) ? res.data : res;

    // Jika sudah memiliki dokter dan lab_jiwa
    if (body.dokter && (body.dokter.id || body.dokter.id_trimester1)) {
      return {
        dokter: body.dokter,
        lab_jiwa: body.lab_jiwa || null,
      };
    }

    // Jika datar (field id_trimester1 di root)
    if (body.id || body.id_trimester1) {
      const dokterFields = {};
      const labFields = {};
      const labPrefixes = [
        "tanggal_lab",
        "lab_",
        "tanggal_skrining_jiwa",
        "skrining_jiwa_",
        "kesimpulan",
        "rekomendasi",
      ];
      for (const key of Object.keys(body)) {
        if (labPrefixes.some((pf) => key.startsWith(pf))) {
          labFields[key] = body[key];
        } else {
          dokterFields[key] = body[key];
        }
      }
      dokterFields.id = dokterFields.id || dokterFields.id_trimester1;
      return {
        dokter: dokterFields,
        lab_jiwa: labFields,
      };
    }

    return null;
  }

  // ── Handlers ──────────────────────────────────────────────────────────
  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
    if (validationErrors[name]) {
      setValidationErrors((prev) => {
        const n = { ...prev };
        delete n[name];
        return n;
      });
    }
  };

  const handleImageChange = (e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setUsgImageFile(file);
    const reader = new FileReader();
    reader.onloadend = () => setUsgImagePreview(reader.result);
    reader.readAsDataURL(file);
  };

  const isDateAfterToday = (dateStr) => {
    if (!dateStr) return false;
    const today = new Date().toISOString().split("T")[0];
    return dateStr > today;
  };

  // Atau versi dengan Date object
  const isDateAfterTodayV2 = (dateStr) => {
    if (!dateStr) return false;
    const selected = new Date(dateStr);
    selected.setHours(0, 0, 0, 0);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    return selected > today;
  };

  const handleRemoveImage = () => {
    setUsgImageFile(null);
    setUsgImagePreview("");
    setForm((prev) => ({ ...prev, gambar_usg: "" }));
    if (fileInputRef.current) fileInputRef.current.value = "";
  };
  // Fungsi helper untuk validasi angka dengan batasan
  const validateNumberWithRange = (
    value,
    fieldName,
    min,
    max,
    isRequired = false,
  ) => {
    if (!value && value !== 0) {
      return isRequired ? `${fieldName} harus diisi` : null;
    }
    const num = parseFloat(value);
    if (isNaN(num)) return `${fieldName} harus berupa angka`;
    if (num < min) return `${fieldName} tidak boleh kurang dari ${min}`;
    if (num > max) return `${fieldName} tidak boleh lebih dari ${max}`;
    return null;
  };

  // Gunakan di validations
  // Contoh untuk CRL, GS, dll
  if (form.usg_crl_cm) {
    const crlError = validateNumberWithRange(
      form.usg_crl_cm,
      "CRL",
      0,
      15,
      false,
    );
    if (crlError) errors.usg_crl_cm = crlError;
  }

  if (form.usg_diameter_gs_cm) {
    const gsError = validateNumberWithRange(
      form.usg_diameter_gs_cm,
      "Diameter GS",
      0,
      10,
      false,
    );
    if (gsError) errors.usg_diameter_gs_cm = gsError;
  }

  // Di validateStep1, tambahkan validasi suhu jika ada
  // (tambahkan field suhu jika belum ada di step 1)
  if (form.suhu) {
    const suhu = parseFloat(form.suhu);
    if (isNaN(suhu)) {
      errors.suhu = "Suhu harus berupa angka";
    } else if (suhu < 35) {
      errors.suhu = "Suhu rendah (<35°C) - Hipotermia";
    } else if (suhu > 38) {
      errors.suhu = "Suhu tinggi (>38°C) - Demam, perlu evaluasi";
    }
  }
  // ── Validasi ───────────────────────────────────────────────────────────
  const validateStep1 = () => {
    const errors = {};
    if (!form.tanggal_periksa) {
      errors.tanggal_periksa = "Tanggal periksa harus diisi";
    } else if (isDateAfterToday(form.tanggal_periksa)) {
      errors.tanggal_periksa = "Tanggal periksa tidak boleh melebihi hari ini";
    }

    // Di validateStep1, tambahkan validasi tekanan darah
    if (form.tekanan_darah_sistol && form.tekanan_darah_diastol) {
      const sistol = parseInt(form.tekanan_darah_sistol);
      const diastol = parseInt(form.tekanan_darah_diastol);

      if (!isNaN(sistol) && !isNaN(diastol)) {
        if (sistol >= 140 || diastol >= 90) {
          errors.tekanan_darah = "Tekanan darah tinggi - waspadai preeklampsia";
        } else if (sistol < 90 || diastol < 60) {
          errors.tekanan_darah = "Tekanan darah rendah - waspadai hipotensi";
        }
      }
    }
    if (!form.konsep_anamnesa_pemeriksaan?.trim())
      errors.konsep_anamnesa_pemeriksaan = "Anamnesa harus diisi";
    const fisikNames = [
      "fisik_konjungtiva",
      "fisik_sklera",
      "fisik_kulit",
      "fisik_leher",
      "fisik_gigi_mulut",
      "fisik_tht",
      "fisik_dada_jantung",
      "fisik_dada_paru",
      "fisik_perut",
      "fisik_tungkai",
    ];
    fisikNames.forEach((f) => {
      if (!form[f]?.trim()) errors[f] = "Harus diisi";
    });
    return errors;
  };

  const validateStep2 = () => {
    const errors = {};
    // Validasi HPHT tidak boleh melebihi hari ini
    const hphtError = getDateError(form.hpht, "HPHT");
    if (hphtError) errors.hpht = hphtError;
    if (!form.hpl_berdasarkan_usg) {
      errors.hpl_berdasarkan_usg = "HPL (USG) harus diisi";
    }
    if (form.umur_hamil_hpht_minggu) {
      const uk = parseInt(form.umur_hamil_hpht_minggu);
      if (isNaN(uk)) {
        errors.umur_hamil_hpht_minggu = "UK HPHT harus berupa angka";
      } else if (uk < 0) {
        errors.umur_hamil_hpht_minggu = "UK HPHT tidak boleh negatif";
      } else if (uk > 42) {
        errors.umur_hamil_hpht_minggu =
          "UK HPHT melebihi 42 minggu (post-term)";
      }
    }

    // Validasi UK USG
    if (form.umur_hamil_usg_minggu) {
      const ukUsg = parseInt(form.umur_hamil_usg_minggu);
      if (isNaN(ukUsg)) {
        errors.umur_hamil_usg_minggu = "UK USG harus berupa angka";
      } else if (ukUsg < 0) {
        errors.umur_hamil_usg_minggu = "UK USG tidak boleh negatif";
      } else if (ukUsg > 42) {
        errors.umur_hamil_usg_minggu = "UK USG melebihi 42 minggu (post-term)";
      }
    }

    if (!form.hpht?.trim()) errors.hpht = "HPHT harus diisi";
    if (!form.keteraturan_haid?.trim())
      errors.keteraturan_haid = "Keteraturan haid harus diisi";
    if (!form.umur_hamil_hpht_minggu?.toString().trim())
      errors.umur_hamil_hpht_minggu = "UK HPHT harus diisi";
    if (!form.umur_hamil_usg_minggu?.toString().trim())
      errors.umur_hamil_usg_minggu = "UK USG harus diisi";
    if (!form.usg_jumlah_gs?.toString().trim())
      errors.usg_jumlah_gs = "Jumlah GS harus diisi";
    if (!form.usg_diameter_gs_cm?.toString().trim())
      errors.usg_diameter_gs_cm = "Diameter GS (cm) harus diisi";
    if (!form.usg_diameter_gs_minggu?.toString().trim())
      errors.usg_diameter_gs_minggu = "Diameter GS (minggu) harus diisi";
    if (!form.usg_diameter_gs_hari?.toString().trim())
      errors.usg_diameter_gs_hari = "Diameter GS (hari) harus diisi";
    if (!form.usg_jumlah_bayi?.toString().trim())
      errors.usg_jumlah_bayi = "Jumlah bayi harus diisi";
    if (!form.usg_crl_cm?.toString().trim())
      errors.usg_crl_cm = "CRL (cm) harus diisi";
    if (!form.usg_crl_minggu?.toString().trim())
      errors.usg_crl_minggu = "CRL (minggu) harus diisi";
    if (!form.usg_crl_hari?.toString().trim())
      errors.usg_crl_hari = "CRL (hari) harus diisi";
    if (!form.usg_letak_produk_kehamilan?.trim())
      errors.usg_letak_produk_kehamilan = "Letak produk harus diisi";
    if (!form.usg_pulsasi_jantung?.trim())
      errors.usg_pulsasi_jantung = "Pulsasi jantung harus diisi";
    if (!form.usg_kecurigaan_temuan_abnormal?.trim())
      errors.usg_kecurigaan_temuan_abnormal = "Kecurigaan abnormal harus diisi";
    if (
      form.usg_kecurigaan_temuan_abnormal === "Ya" &&
      !form.usg_keterangan_temuan_abnormal?.trim()
    )
      errors.usg_keterangan_temuan_abnormal = "Keterangan abnormal harus diisi";
    return errors;
  };

  const validateStep3 = () => {
    const errors = {};
    if (!form.tanggal_lab) {
    errors.tanggal_lab = "Tanggal lab harus diisi";
  } else {
    const today = new Date().toISOString().split("T")[0];
    if (form.tanggal_lab > today) {
      errors.tanggal_lab = "Tanggal lab tidak boleh melebihi hari ini";
    }
  }
    if (form.lab_hemoglobin_hasil) {
      const hb = parseFloat(form.lab_hemoglobin_hasil);
      if (isNaN(hb)) {
        errors.lab_hemoglobin_hasil = "Hasil hemoglobin harus berupa angka";
      } else if (hb < 7) {
        errors.lab_hemoglobin_hasil =
          "Hb sangat rendah (<7 g/dL) - Anemia berat, perlu rujukan!";
      } else if (hb < 10) {
        errors.lab_hemoglobin_hasil =
          "Hb rendah (<10 g/dL) - Anemia sedang, perlu suplemen zat besi";
      } else if (hb < 11) {
        errors.lab_hemoglobin_hasil =
          "Hb di bawah normal (10-11 g/dL) - Perhatikan asupan zat besi";
      } else if (hb > 17) {
        errors.lab_hemoglobin_hasil =
          "Hb tinggi (>17 g/dL) - Perlu evaluasi lebih lanjut";
      }
    } else if (!form.lab_hemoglobin_hasil && form.lab_hemoglobin_hasil !== "") {
      errors.lab_hemoglobin_hasil = "Hasil hemoglobin harus diisi";
    }

    // Validasi Gula Darah
    if (form.lab_gula_darah_sewaktu_hasil) {
      const gds = parseInt(form.lab_gula_darah_sewaktu_hasil);
      if (isNaN(gds)) {
        errors.lab_gula_darah_sewaktu_hasil = "Gula darah harus berupa angka";
      } else if (gds < 70) {
        errors.lab_gula_darah_sewaktu_hasil =
          "Gula darah rendah (<70 mg/dL) - Hipoglikemia";
      } else if (gds > 200) {
        errors.lab_gula_darah_sewaktu_hasil =
          "Gula darah tinggi (>200 mg/dL) - Hiperglikemia";
      } else if (gds > 140) {
        errors.lab_gula_darah_sewaktu_hasil =
          "Gula darah di atas normal (140-200 mg/dL) - Waspada DMG";
      }
    }
    if (!form.lab_hemoglobin_hasil?.toString().trim())
      errors.lab_hemoglobin_hasil = "Hasil hemoglobin harus diisi";
    if (!form.lab_hemoglobin_rencana_tindak_lanjut?.trim())
      errors.lab_hemoglobin_rencana_tindak_lanjut = "Rencana Hb harus diisi";
    if (!form.lab_golongan_darah_rhesus_hasil?.trim())
      errors.lab_golongan_darah_rhesus_hasil = "Golongan darah harus diisi";
    if (!form.lab_golongan_darah_rhesus_rencana_tindak_lanjut?.trim())
      errors.lab_golongan_darah_rhesus_rencana_tindak_lanjut =
        "Rencana goldar harus diisi";
    if (!form.lab_gula_darah_sewaktu_hasil?.toString().trim())
      errors.lab_gula_darah_sewaktu_hasil = "Gula darah harus diisi";
    if (!form.lab_gula_darah_sewaktu_rencana_tindak_lanjut?.trim())
      errors.lab_gula_darah_sewaktu_rencana_tindak_lanjut =
        "Rencana gula darah harus diisi";
    if (!form.lab_hiv_hasil?.trim())
      errors.lab_hiv_hasil = "Hasil HIV harus diisi";
    if (!form.lab_hiv_rencana_tindak_lanjut?.trim())
      errors.lab_hiv_rencana_tindak_lanjut = "Rencana HIV harus diisi";
    if (!form.lab_sifilis_hasil?.trim())
      errors.lab_sifilis_hasil = "Hasil sifilis harus diisi";
    if (!form.lab_sifilis_rencana_tindak_lanjut?.trim())
      errors.lab_sifilis_rencana_tindak_lanjut = "Rencana sifilis harus diisi";
    if (!form.lab_hepatitis_b_hasil?.trim())
      errors.lab_hepatitis_b_hasil = "Hasil hepatitis B harus diisi";
    if (!form.lab_hepatitis_b_rencana_tindak_lanjut?.trim())
      errors.lab_hepatitis_b_rencana_tindak_lanjut =
        "Rencana hepatitis B harus diisi";
    return errors;
  };

  const validateStep4 = () => {
    const errors = {};
   if (!form.tanggal_skrining_jiwa) {
  errors.tanggal_skrining_jiwa = "Tanggal skrining jiwa harus diisi";
} else {
  const today = new Date().toISOString().split("T")[0];
  if (form.tanggal_skrining_jiwa > today) {
    errors.tanggal_skrining_jiwa = "Tanggal skrining jiwa tidak boleh melebihi hari ini";
  }
}
    if (!form.skrining_jiwa_hasil?.trim())
      errors.skrining_jiwa_hasil = "Hasil skrining jiwa harus diisi";
    if (!form.skrining_jiwa_tindak_lanjut?.trim())
      errors.skrining_jiwa_tindak_lanjut = "Tindak lanjut harus diisi";
    if (!form.skrining_jiwa_perlu_rujukan?.trim())
      errors.skrining_jiwa_perlu_rujukan = "Perlu rujukan harus diisi";
    if (!form.kesimpulan?.trim()) errors.kesimpulan = "Kesimpulan harus diisi";
    if (!form.rekomendasi?.trim())
      errors.rekomendasi = "Rekomendasi harus diisi";
    return errors;
  };

  const showValidationAlert = () =>
    Swal.fire({
      icon: "warning",
      title: "Data Belum Lengkap",
      text: "Mohon lengkapi semua data yang wajib diisi.",
      confirmButtonColor: "#4f46e5",
    });

  const handleNextStep = () => {
    let errors = {};
    if (currentStep === 1) errors = validateStep1();
    else if (currentStep === 2) errors = validateStep2();
    else if (currentStep === 3) errors = validateStep3();

    if (Object.keys(errors).length > 0) {
      setValidationErrors(errors);
      showValidationAlert();
      return;
    }
    setCurrentStep((s) => s + 1);
    setValidationErrors({});
    window.scrollTo(0, 0);
  };

  const handlePrevStep = () => {
    if (currentStep > 1) {
      setCurrentStep((s) => s - 1);
      setValidationErrors({});
      window.scrollTo(0, 0);
    }
  };

  // ── Build payload ──────────────────────────────────────────────────────
  const buildPayload = (imageBase64) => {
    const numeric = (val, type = "int") => {
      if (val === "" || val == null) return null;
      return type === "float" ? parseFloat(val) : parseInt(val, 10);
    };
    return {
      kehamilan_id: kehamilan.id,
      nama_dokter: form.nama_dokter,
      tanggal_periksa: form.tanggal_periksa || todayDateStr(),
      konsep_anamnesa_pemeriksaan: form.konsep_anamnesa_pemeriksaan,
      fisik_konjungtiva: form.fisik_konjungtiva,
      fisik_sklera: form.fisik_sklera,
      fisik_kulit: form.fisik_kulit,
      fisik_leher: form.fisik_leher,
      fisik_gigi_mulut: form.fisik_gigi_mulut,
      fisik_tht: form.fisik_tht,
      fisik_dada_jantung: form.fisik_dada_jantung,
      fisik_dada_paru: form.fisik_dada_paru,
      fisik_perut: form.fisik_perut,
      fisik_tungkai: form.fisik_tungkai,
      hpht: form.hpht || null,
      hpl_berdasarkan_hpht: form.hpl_berdasarkan_hpht || null,
      hpl_berdasarkan_usg: form.hpl_berdasarkan_usg || null,
      keteraturan_haid: form.keteraturan_haid,
      umur_hamil_hpht_minggu: numeric(form.umur_hamil_hpht_minggu),
      umur_hamil_usg_minggu: numeric(form.umur_hamil_usg_minggu),
      usg_jumlah_gs: form.usg_jumlah_gs,
      usg_diameter_gs_cm: numeric(form.usg_diameter_gs_cm, "float"),
      usg_diameter_gs_minggu: numeric(form.usg_diameter_gs_minggu),
      usg_diameter_gs_hari: numeric(form.usg_diameter_gs_hari),
      usg_jumlah_bayi: form.usg_jumlah_bayi,
      usg_crl_cm: numeric(form.usg_crl_cm, "float"),
      usg_crl_minggu: numeric(form.usg_crl_minggu),
      usg_crl_hari: numeric(form.usg_crl_hari),
      usg_letak_produk_kehamilan: form.usg_letak_produk_kehamilan,
      usg_pulsasi_jantung: form.usg_pulsasi_jantung,
      usg_kecurigaan_temuan_abnormal: form.usg_kecurigaan_temuan_abnormal,
      usg_keterangan_temuan_abnormal: form.usg_keterangan_temuan_abnormal,
      gambar_usg: imageBase64 ?? "",
      tanggal_lab: form.tanggal_lab || null,
      lab_hemoglobin_hasil: numeric(form.lab_hemoglobin_hasil, "float"),
      lab_hemoglobin_rencana_tindak_lanjut:
        form.lab_hemoglobin_rencana_tindak_lanjut,
      lab_golongan_darah_rhesus_hasil: form.lab_golongan_darah_rhesus_hasil,
      lab_golongan_darah_rhesus_rencana_tindak_lanjut:
        form.lab_golongan_darah_rhesus_rencana_tindak_lanjut,
      lab_gula_darah_sewaktu_hasil: numeric(form.lab_gula_darah_sewaktu_hasil),
      lab_gula_darah_sewaktu_rencana_tindak_lanjut:
        form.lab_gula_darah_sewaktu_rencana_tindak_lanjut,
      lab_hiv_hasil: form.lab_hiv_hasil,
      lab_hiv_rencana_tindak_lanjut: form.lab_hiv_rencana_tindak_lanjut,
      lab_sifilis_hasil: form.lab_sifilis_hasil,
      lab_sifilis_rencana_tindak_lanjut: form.lab_sifilis_rencana_tindak_lanjut,
      lab_hepatitis_b_hasil: form.lab_hepatitis_b_hasil,
      lab_hepatitis_b_rencana_tindak_lanjut:
        form.lab_hepatitis_b_rencana_tindak_lanjut,
      tanggal_skrining_jiwa: form.tanggal_skrining_jiwa || null,
      skrining_jiwa_hasil: form.skrining_jiwa_hasil,
      skrining_jiwa_tindak_lanjut: form.skrining_jiwa_tindak_lanjut,
      skrining_jiwa_perlu_rujukan: form.skrining_jiwa_perlu_rujukan,
      kesimpulan: form.kesimpulan,
      rekomendasi: form.rekomendasi,
    };
  };

  // ── Handle Delete ──────────────────────────────────────────────────────
  const handleDelete = async () => {
    if (!canDelete) {
      Swal.fire({
        icon: "error",
        title: "Akses Ditolak",
        text: "Hanya dokter yang dapat menghapus data pemeriksaan.",
      });
      return;
    }

    const dokterRecord = existingData?.dokter;
    const idToDelete =
      dokterRecord?.id || dokterRecord?.id_trimester1 || dokterRecord?.ID;

    if (!idToDelete) {
      Swal.fire({
        icon: "error",
        title: "Error",
        text: "Data tidak ditemukan untuk dihapus.",
      });
      return;
    }

    const result = await Swal.fire({
      title: "Hapus Data?",
      text: "Data yang dihapus tidak dapat dikembalikan!",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#d33",
      cancelButtonColor: "#3085d6",
      confirmButtonText: "Ya, Hapus!",
      cancelButtonText: "Batal",
    });

    if (result.isConfirmed) {
      setSaving(true);
      try {
        await deleteDokterT1Complete(idToDelete);
        await Swal.fire({
          icon: "success",
          title: "Berhasil",
          text: "Data pemeriksaan berhasil dihapus!",
          timer: 2000,
          showConfirmButton: false,
        });
        navigate(`/data-ibu/${id}`);
      } catch (err) {
        console.error("[DELETE] Error:", err);
        Swal.fire({
          icon: "error",
          title: "Gagal Menghapus",
          text: err?.response?.data?.message || "Terjadi kesalahan",
        });
      } finally {
        setSaving(false);
      }
    }
  };

  // ── Handle Save ───────────────────────────────────────────────────────
  const handleSave = async () => {
    if (!canEdit) {
      Swal.fire({
        icon: "error",
        title: "Akses Ditolak",
        text: "Hanya dokter yang dapat menyimpan atau mengubah data pemeriksaan.",
      });
      return;
    }

    const errors = validateStep4();
    if (Object.keys(errors).length > 0) {
      setValidationErrors(errors);
      showValidationAlert();
      return;
    }
    if (!kehamilan) {
      Swal.fire({
        icon: "error",
        title: "Error",
        text: "Data kehamilan tidak ditemukan.",
      });
      return;
    }
    // Cek trimester untuk mode CREATE
    if (!isEditModeFlag && !isTrimester1) {
      // Tampilkan notifikasi peringatan
      const result = await Swal.fire({
        title: "Peringatan!",
        html: `
        <div class="text-left">
          <p class="text-yellow-700 font-semibold mb-2">⚠️ Usia Kehamilan Melebihi Trimester 1</p>
          <p>Usia kehamilan saat ini: <strong>${usiaKehamilanSaatIni?.display}</strong></p>
          <p class="mt-2 text-sm text-gray-600">Form ini khusus untuk pemeriksaan Trimester 1 (0-12 minggu).</p>
          <p class="text-sm text-red-600 mt-2">Apakah Anda yakin ingin tetap menyimpan data ini?</p>
        </div>
      `,
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#d33",
        cancelButtonColor: "#3085d6",
        confirmButtonText: "Ya, Tetap Simpan",
        cancelButtonText: "Kembali",
      });

      if (!result.isConfirmed) {
        return;
      }
    }

    // Lanjutkan penyimpanan
    await performSave();
  };

  // Pisahkan logika penyimpanan ke fungsi terpisah
  const performSave = async () => {
    if (saving) return;
    setSaving(true);
    try {
      let imageBase64 = form.gambar_usg;
      if (usgImageFile) {
        imageBase64 = await new Promise((resolve, reject) => {
          const reader = new FileReader();
          reader.onloadend = () => resolve(reader.result);
          reader.onerror = reject;
          reader.readAsDataURL(usgImageFile);
        });
      }

      const payload = buildPayload(imageBase64);

      const dokterRecord = existingData?.dokter;
      const idToUpdate =
        dokterRecord?.id || dokterRecord?.id_trimester1 || dokterRecord?.ID;

      console.log(
        "[SAVE] mode:",
        idToUpdate ? "UPDATE" : "CREATE",
        "| id:",
        idToUpdate,
      );

      let response;
      if (idToUpdate) {
        response = await updateDokterT1Complete(idToUpdate, payload);
      } else {
        response = await createDokterT1Complete(payload);
        // Jika response dari create mengandung data (misal ID baru),
        // kita bisa set existingData agar form langsung mode edit saat kembali.
        if (response?.data) {
          const normalized = normalizeResponse(response.data);
          if (normalized) setExistingData(normalized);
        }
      }

      await Swal.fire({
        icon: "success",
        title: "Berhasil",
        text: `Data pemeriksaan berhasil ${idToUpdate ? "diperbarui" : "disimpan"}!`,
        timer: 2000,
        showConfirmButton: false,
      });
      navigate(`/data-ibu/${id}/pemeriksaan-dokter-t1-complete/detail`);
    } catch (err) {
      console.error("[SAVE] Error:", err);
      const errorMsg =
        err?.response?.data?.message || err?.message || "Terjadi kesalahan";
      Swal.fire({
        icon: "error",
        title: "Gagal Menyimpan",
        text: errorMsg,
      });
    } finally {
      setSaving(false);
    }
  };

  // ── Loading / Error states ────────────────────────────────────────────
  if (loading) {
    return (
      <MainLayout>
        <div className="min-h-screen flex items-center justify-center">
          <div className="flex flex-col items-center gap-3 text-indigo-600">
            <Loader2 className="animate-spin" size={40} />
            <p className="text-sm font-medium text-gray-500">Memuat data...</p>
          </div>
        </div>
      </MainLayout>
    );
  }

  if (error) {
    return (
      <MainLayout>
        <div className="p-6 max-w-2xl mx-auto mt-10">
          <div className="bg-red-50 border border-red-200 rounded-2xl p-8 text-center">
            <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <AlertCircle className="text-red-500" size={32} />
            </div>
            <h2 className="text-xl font-bold text-red-700 mb-2">
              Data Kehamilan Tidak Ditemukan
            </h2>
            <p className="text-gray-600 mb-6 text-sm">{error}</p>
            {/* <div className="flex gap-3 justify-center">
              <Link
                to={`/data-ibu/${id}/edit`}
                className="bg-indigo-600 text-white px-5 py-2 rounded-lg text-sm font-medium hover:bg-indigo-700 transition"
              >
                Tambah Data Kehamilan
              </Link>
              <button
                onClick={() => navigate(-1)}
                className="bg-gray-100 text-gray-700 px-5 py-2 rounded-lg text-sm font-medium hover:bg-gray-200 transition"
              >
                Kembali
              </button>
            </div> */}
          </div>
        </div>
      </MainLayout>
    );
  }

  // Untuk bidan yang belum ada data, tampilkan pesan khusus
  if (!canEdit && !existingData) {
    return (
      <MainLayout>
        <div className="p-6 max-w-2xl mx-auto mt-10">
          <div className="bg-blue-50 border border-blue-200 rounded-2xl p-8 text-center">
            <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <Lock size={32} className="text-blue-500" />
            </div>
            <h2 className="text-xl font-bold text-blue-700 mb-2">
              Belum Ada Data Pemeriksaan
            </h2>
            <p className="text-gray-600 mb-6 text-sm">
              Hanya dokter yang dapat menambahkan data pemeriksaan dokter
              trimester 1. Silakan hubungi dokter untuk pengisian data.
            </p>
            <button
              onClick={() => navigate(-1)}
              className="bg-blue-600 text-white px-6 py-2 rounded-lg text-sm font-medium hover:bg-blue-700 transition"
            >
              Kembali
            </button>
          </div>
        </div>
      </MainLayout>
    );
  }

  // ── Render ─────────────────────────────────────────────────────────────
  const fisikFields = [
    { name: "fisik_konjungtiva", label: "Konjungtiva" },
    { name: "fisik_sklera", label: "Sklera" },
    { name: "fisik_kulit", label: "Kulit" },
    { name: "fisik_leher", label: "Leher" },
    { name: "fisik_gigi_mulut", label: "Gigi & Mulut" },
    { name: "fisik_tht", label: "THT" },
    { name: "fisik_dada_jantung", label: "Dada / Jantung" },
    { name: "fisik_dada_paru", label: "Dada / Paru" },
    { name: "fisik_perut", label: "Perut" },
    { name: "fisik_tungkai", label: "Tungkai" },
  ];

  const labReaktifFields = [
    {
      name: "lab_hiv_hasil",
      label: "HIV (H)",
      rencana: "lab_hiv_rencana_tindak_lanjut",
    },
    {
      name: "lab_sifilis_hasil",
      label: "Sifilis (S)",
      rencana: "lab_sifilis_rencana_tindak_lanjut",
    },
    {
      name: "lab_hepatitis_b_hasil",
      label: "Hepatitis B",
      rencana: "lab_hepatitis_b_rencana_tindak_lanjut",
    },
  ];

  const stepTitles = [
    "Data Dokter & Pemeriksaan Fisik",
    "USG Trimester 1",
    "Pemeriksaan Laboratorium",
    "Skrining Jiwa & Kesimpulan",
  ];
  const stepIcons = [User, Eye, FlaskConical, Brain];
  const stepColors = ["indigo", "violet", "amber", "rose"];

  const isEditMode = !!(
    existingData?.dokter?.id ||
    existingData?.dokter?.id_trimester1 ||
    existingData?.dokter?.ID
  );

  // Variabel untuk menentukan apakah readonly
  const isReadOnly = !canEdit;
  const isEditModeFlag = !!(
    existingData?.dokter?.id ||
    existingData?.dokter?.id_trimester1 ||
    existingData?.dokter?.ID
  );

  return (
    <MainLayout>
      <div className="p-4 md:p-6 max-w-5xl mx-auto">
        {/* Header */}
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center gap-3">
            <button
              onClick={() => navigate(-1)}
              className="p-2 rounded-full hover:bg-gray-100 transition"
            >
              <ArrowLeft size={20} className="text-gray-600" />
            </button>
            <div>
              <h1 className="text-xl md:text-2xl font-bold text-gray-800">
                {isEditModeFlag ? "Edit" : "Tambah"} Pemeriksaan Dokter
                Trimester 1
              </h1>
              <p className="text-sm text-gray-500 mt-0.5">
                {stepTitles[currentStep - 1]}
              </p>
            </div>
          </div>

          {/* Badge Role */}
          <div
            className={`px-3 py-1 rounded-full text-xs font-semibold ${
              canEdit
                ? "bg-green-100 text-green-700"
                : "bg-blue-100 text-blue-700"
            }`}
          >
            {canEdit ? "✏️ Mode Edit (Dokter)" : "👁️ Mode Baca (Bidan)"}
          </div>
        </div>

        {/* Informasi akses untuk bidan */}
        {!canEdit && (
          <div className="mb-6 p-3 bg-blue-50 rounded-lg border border-blue-200">
            <p className="text-sm text-blue-700 flex items-center gap-2">
              <Lock size={16} />
              Anda login sebagai BIDAN. Data hanya dapat dilihat, tidak dapat
              diedit atau dihapus.
            </p>
          </div>
        )}

        {/* Informasi status trimester untuk mode CREATE */}
        {!isEditModeFlag && kehamilanDetail && (
          <div
            className={`mb-4 p-3 rounded-lg border ${
              isTrimester1
                ? "bg-green-50 border-green-200"
                : "bg-yellow-50 border-yellow-200"
            }`}
          >
            <div className="flex items-center gap-2">
              {isTrimester1 ? (
                <CheckCircle size={16} className="text-green-600" />
              ) : (
                <AlertCircle size={16} className="text-yellow-600" />
              )}
              <span
                className={`text-sm font-medium ${
                  isTrimester1 ? "text-green-700" : "text-yellow-700"
                }`}
              >
                Usia kehamilan saat ini: {usiaKehamilanSaatIni?.display}
              </span>
            </div>
            {isTrimester1 ? (
              <p className="text-xs text-green-600 mt-1">
                ✅ Usia kehamilan dalam Trimester 1. Data pemeriksaan dapat
                dibuat.
              </p>
            ) : (
              <p className="text-xs text-yellow-600 mt-1">
                ⚠️ Perhatian: Usia kehamilan telah melebihi Trimester 1 (0-12
                minggu). Data tetap dapat disimpan dengan konfirmasi terlebih
                dahulu.
              </p>
            )}
          </div>
        )}

        {/* // Tambahkan setelah header, sebelum step indicator */}
        {kehamilanDetail && kehamilanDetail.hpht && (
          <div className="mb-6 p-4 bg-gradient-to-r from-indigo-50 to-blue-50 rounded-xl border border-indigo-200 shadow-sm">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-indigo-100 rounded-full flex items-center justify-center">
                  <Calendar size={24} className="text-indigo-600" />
                </div>
                <div>
                  <p className="text-xs text-gray-500 uppercase tracking-wide">
                    Data Kehamilan
                  </p>
                  <p className="font-semibold text-indigo-700">
                    HPHT: {formatTanggalIndo(kehamilanDetail.hpht)}
                  </p>
                  <p className="text-xs text-gray-500">
                    Taksiran Persalinan:{" "}
                    {formatTanggalIndo(kehamilanDetail.taksiran_persalinan)}
                  </p>
                </div>
              </div>

              {usiaKehamilan && (
                <div className="flex items-center gap-3 bg-white px-4 py-3 rounded-xl shadow-sm">
                  <Baby size={24} className="text-pink-500" />
                  <div>
                    <p className="text-xs text-gray-500">
                      Usia Kehamilan (Per Tanggal Periksa)
                    </p>
                    {usiaKehamilan.minggu === 0 && usiaKehamilan.hari === 0 ? (
                      <p className="font-bold text-md text-orange-600">
                        Kehamilan baru (&lt; 1 hari)
                      </p>
                    ) : usiaKehamilan.minggu === 0 ? (
                      <p className="font-bold text-md text-indigo-700">
                        {usiaKehamilan.hari} hari
                      </p>
                    ) : (
                      <p className="font-bold text-xl text-indigo-700">
                        {usiaKehamilan.display}
                      </p>
                    )}
                  </div>
                </div>
              )}

              <button
                type="button"
                onClick={() => {
                  if (kehamilanDetail?.hpht && form.tanggal_periksa) {
                    const usia = hitungUsiaKehamilanDariHPHT(
                      kehamilanDetail.hpht,
                      form.tanggal_periksa,
                    );
                    const hpl = hitungHPLDariHPHT(kehamilanDetail.hpht);

                    if (usia && usia.minggu !== undefined) {
                      setForm((prev) => ({
                        ...prev,
                        umur_hamil_hpht_minggu: usia.minggu.toString(),
                        hpht: toDateOnly(kehamilanDetail.hpht),
                        hpl_berdasarkan_hpht:
                          hpl?.date || prev.hpl_berdasarkan_hpht,
                      }));
                      Swal.fire({
                        icon: "success",
                        title: "Data Terisi Otomatis",
                        html: `
            <div class="text-left">
              <p>📅 HPHT: <strong>${formatTanggalIndo(kehamilanDetail.hpht)}</strong></p>
              <p>🤰 Usia Kehamilan: <strong>${usia.display}</strong></p>
              <p>🎯 HPL: <strong>${hpl?.display || "-"}</strong></p>
            </div>
          `,
                        timer: 3000,
                        showConfirmButton: false,
                      });
                    }
                  }
                }}
                className="px-4 py-2 bg-indigo-600 text-white rounded-lg text-sm hover:bg-indigo-700 transition flex items-center gap-2"
              >
                <RefreshCw size={14} />
                Isi Otomatis (HPHT, UK, HPL)
              </button>
            </div>

            <div className="mt-3 p-2 bg-yellow-50 rounded-lg border border-yellow-200">
              <p className="text-xs text-yellow-700 flex items-center gap-1">
                <Info size={14} />
                Trimester 1 (0-12 minggu): Pemeriksaan USG untuk mengkonfirmasi
                kehamilan, deteksi denyut jantung janin, dan skrining awal.
              </p>
            </div>
          </div>
        )}
        {/* Step Indicator */}
        <div className="mb-8">
          <div className="flex items-center justify-between">
            {[1, 2, 3, 4].map((step) => {
              const isActive = step === currentStep;
              const isCompleted = step < currentStep;
              const Icon = stepIcons[step - 1];
              const color = stepColors[step - 1];
              const bgColor = isActive
                ? `bg-${color}-500 text-white shadow-lg scale-110`
                : isCompleted
                  ? "bg-emerald-500 text-white"
                  : "bg-gray-200 text-gray-500";
              const titleColor = isActive
                ? `text-${color}-600`
                : isCompleted
                  ? "text-emerald-600"
                  : "text-gray-500";
              return (
                <div key={step} className="flex flex-col items-center flex-1">
                  <div
                    className={`w-12 h-12 rounded-full flex items-center justify-center transition ${bgColor} mb-2`}
                  >
                    {isCompleted ? (
                      <CheckCircle size={20} />
                    ) : (
                      <Icon size={18} />
                    )}
                  </div>
                  <p
                    className={`text-xs font-semibold text-center ${titleColor} transition`}
                  >
                    {step === 1
                      ? "Dokter & Fisik"
                      : step === 2
                        ? "USG"
                        : step === 3
                          ? "Lab"
                          : "Skrining"}
                  </p>
                </div>
              );
            })}
          </div>
        </div>
        <div className="space-y-4">
          {/* ══ STEP 1 ══ */}
          {currentStep === 1 && (
            <>
              <Section
                icon={User}
                title="Data Dokter & Anamnesis"
                color="indigo"
              >
                <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
                  <Field label="Nama Dokter">
                    <input
                      name="nama_dokter"
                      value={form.nama_dokter}
                      readOnly
                      className={inputCls}
                    />
                    <p className="text-xs text-gray-400 mt-1">
                      Diambil dari data login
                    </p>
                  </Field>
                  <Field label="Tanggal Periksa">
                    <input
                      type="date"
                      name="tanggal_periksa"
                      value={form.tanggal_periksa}
                      onChange={handleChange}
                      required
                      max={new Date().toISOString().split("T")[0]} // Tidak boleh melebihi hari ini
                      className={`${inputCls} ${
                        validationErrors.tanggal_periksa
                          ? "border-red-500 bg-red-50"
                          : ""
                      }`}
                    />
                    <ErrorMessage message={validationErrors.tanggal_periksa} />
                  </Field>
                  <Field
                    label="Konsep Anamnesa"
                    colSpan="sm:col-span-2 md:col-span-1"
                  >
                    <textarea
                      name="konsep_anamnesa_pemeriksaan"
                      value={form.konsep_anamnesa_pemeriksaan}
                      onChange={handleChange}
                      placeholder="Tulis anamnesa pemeriksaan..."
                      className={`${inputCls} ${
                        validationErrors.konsep_anamnesa_pemeriksaan
                          ? "border-red-500 bg-red-50"
                          : ""
                      }`}
                      rows={3}
                    />
                    <ErrorMessage
                      message={validationErrors.konsep_anamnesa_pemeriksaan}
                    />
                  </Field>
                </div>
              </Section>

              <Section icon={Activity} title="Pemeriksaan Fisik" color="teal">
                <div className="mb-4 p-3 bg-gray-50 rounded-xl">
                  <p className="text-xs text-gray-500 mb-2 font-medium">
                    Ringkasan Status
                  </p>
                  <div className="flex flex-wrap gap-2">
                    {fisikFields.map((f) => (
                      <span key={f.name} className="text-xs text-gray-600">
                        <span className="font-medium">{f.label}:</span>{" "}
                        {form[f.name] === "Normal" ? (
                          <span className="text-emerald-600 font-semibold">
                            ✓
                          </span>
                        ) : (
                          <span className="text-red-500 font-semibold">!</span>
                        )}
                      </span>
                    ))}
                  </div>
                </div>
                <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-5 gap-3">
                  {fisikFields.map((field) => (
                    <div key={field.name}>
                      <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1">
                        {field.label}
                      </label>
                      <select
                        name={field.name}
                        value={form[field.name]}
                        onChange={handleChange}
                        className={`${selectCls} ${
                          validationErrors[field.name]
                            ? "border-red-500 bg-red-50"
                            : form[field.name] === "Abnormal"
                              ? "border-red-300 bg-red-50 text-red-700"
                              : "border-gray-200"
                        }`}
                      >
                        <option value="Normal">Normal</option>
                        <option value="Abnormal">Abnormal</option>
                      </select>
                      <ErrorMessage message={validationErrors[field.name]} />
                    </div>
                  ))}
                </div>
              </Section>
            </>
          )}

          {/* ══ STEP 2 ══ */}
          {currentStep === 2 && (
            <Section
              icon={Eye}
              title="USG Trimester 1"
              color="violet"
              defaultOpen={true}
            >
              {/* HPHT */}
              <div className="mb-5">
                <h3 className="text-xs font-bold text-violet-600 uppercase tracking-widest mb-3">
                  Berdasarkan HPHT
                </h3>
                <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                  <Field label="HPHT">
                    <input
                      type="date"
                      name="hpht"
                      value={form.hpht}
                      onChange={handleChange}
                      readOnly={!!kehamilanDetail?.hpht}
                      className={`${inputCls} ${kehamilanDetail?.hpht ? "bg-gray-50" : ""} ${
                        validationErrors.hpht ? "border-red-500 bg-red-50" : ""
                      }`}
                    />
                    {kehamilanDetail?.hpht && (
                      <p className="text-xs text-gray-400 mt-1">
                        Terisi otomatis dari data kehamilan
                      </p>
                    )}
                    <ErrorMessage message={validationErrors.hpht} />
                  </Field>
                  <Field label="Keteraturan Haid">
                    <select
                      name="keteraturan_haid"
                      value={form.keteraturan_haid}
                      onChange={handleChange}
                      className={`${selectCls} ${
                        validationErrors.keteraturan_haid
                          ? "border-red-500 bg-red-50"
                          : ""
                      }`}
                    >
                      <option value="Teratur">Teratur</option>
                      <option value="Tidak Teratur">Tidak Teratur</option>
                    </select>
                    <ErrorMessage message={validationErrors.keteraturan_haid} />
                  </Field>
                  <Field label="UK HPHT (minggu)">
                    <input
                      type="number"
                      name="umur_hamil_hpht_minggu"
                      value={form.umur_hamil_hpht_minggu}
                      onChange={handleChange}
                      readOnly={!!kehamilanDetail?.hpht}
                      placeholder="0"
                      className={`${inputCls} ${kehamilanDetail?.hpht ? "bg-gray-50" : ""} ${
                        validationErrors.umur_hamil_hpht_minggu
                          ? "border-red-500 bg-red-50"
                          : ""
                      }`}
                    />
                    {kehamilanDetail?.hpht && (
                      <p className="text-xs text-gray-400 mt-1">
                        Dihitung otomatis dari HPHT
                      </p>
                    )}
                    <ErrorMessage
                      message={validationErrors.umur_hamil_hpht_minggu}
                    />
                  </Field>
                  {/* Di bagian STEP 2 - USG, update field HPL */}
                  <Field label="HPL (HPHT)">
                    <input
                      type="date"
                      name="hpl_berdasarkan_hpht"
                      value={form.hpl_berdasarkan_hpht}
                      onChange={handleChange}
                      readOnly={!!kehamilanDetail?.hpht}
                      className={`${inputCls} ${kehamilanDetail?.hpht ? "bg-gray-50" : ""} ${
                        validationErrors.hpl_berdasarkan_hpht
                          ? "border-red-500 bg-red-50"
                          : ""
                      }`}
                    />
                    {kehamilanDetail?.hpht && (
                      <p className="text-xs text-gray-400 mt-1">
                        Dihitung otomatis dari HPHT (Rumus Naegele: HPHT + 280
                        hari)
                      </p>
                    )}
                    <ErrorMessage
                      message={validationErrors.hpl_berdasarkan_hpht}
                    />
                  </Field>
                </div>
              </div>
              {/* USG */}
              <div className="mb-5">
                <h3 className="text-xs font-bold text-violet-600 uppercase tracking-widest mb-3">
                  Berdasarkan USG
                </h3>
                <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                  <Field label="UK USG (minggu)">
                    <input
                      type="number"
                      name="umur_hamil_usg_minggu"
                      value={form.umur_hamil_usg_minggu}
                      onChange={handleChange}
                      placeholder="0"
                      className={`${inputCls} ${
                        validationErrors.umur_hamil_usg_minggu
                          ? "border-red-500 bg-red-50"
                          : ""
                      }`}
                    />
                    <ErrorMessage
                      message={validationErrors.umur_hamil_usg_minggu}
                    />
                  </Field>
                  <Field label="HPL (USG)">
                    <input
                      type="date"
                      name="hpl_berdasarkan_usg"
                      value={form.hpl_berdasarkan_usg}
                      onChange={handleChange}
                      required
                      className={`${inputCls} ${
                        validationErrors.hpl_berdasarkan_usg
                          ? "border-red-500 bg-red-50"
                          : ""
                      }`}
                    />
                    <ErrorMessage
                      message={validationErrors.hpl_berdasarkan_usg}
                    />
                  </Field>
                </div>
              </div>
              {/* GS */}
              <div className="mb-5">
                <h3 className="text-xs font-bold text-violet-600 uppercase tracking-widest mb-3">
                  Gestational Sac (GS)
                </h3>
                <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                  <Field label="Jumlah GS">
                    <input
                      name="usg_jumlah_gs"
                      value={form.usg_jumlah_gs}
                      onChange={handleChange}
                      placeholder="Tunggal/Kembar"
                      className={`${inputCls} ${
                        validationErrors.usg_jumlah_gs
                          ? "border-red-500 bg-red-50"
                          : ""
                      }`}
                    />
                    <ErrorMessage message={validationErrors.usg_jumlah_gs} />
                  </Field>
                  <Field label="Diameter GS (cm)">
                    <input
                      type="number"
                      step="0.1"
                      name="usg_diameter_gs_cm"
                      value={form.usg_diameter_gs_cm}
                      onChange={handleChange}
                      placeholder="0.0"
                      className={`${inputCls} ${
                        validationErrors.usg_diameter_gs_cm
                          ? "border-red-500 bg-red-50"
                          : ""
                      }`}
                    />
                    <ErrorMessage
                      message={validationErrors.usg_diameter_gs_cm}
                    />
                  </Field>
                  <Field label="Diameter GS (minggu)">
                    <input
                      type="number"
                      name="usg_diameter_gs_minggu"
                      value={form.usg_diameter_gs_minggu}
                      onChange={handleChange}
                      placeholder="0"
                      className={`${inputCls} ${
                        validationErrors.usg_diameter_gs_minggu
                          ? "border-red-500 bg-red-50"
                          : ""
                      }`}
                    />
                    <ErrorMessage
                      message={validationErrors.usg_diameter_gs_minggu}
                    />
                  </Field>
                  <Field label="Diameter GS (hari)">
                    <input
                      type="number"
                      name="usg_diameter_gs_hari"
                      value={form.usg_diameter_gs_hari}
                      onChange={handleChange}
                      placeholder="0"
                      className={`${inputCls} ${
                        validationErrors.usg_diameter_gs_hari
                          ? "border-red-500 bg-red-50"
                          : ""
                      }`}
                    />
                    <ErrorMessage
                      message={validationErrors.usg_diameter_gs_hari}
                    />
                  </Field>
                </div>
              </div>
              {/* CRL */}
              <div className="mb-5">
                <h3 className="text-xs font-bold text-violet-600 uppercase tracking-widest mb-3">
                  Crown-Rump Length (CRL)
                </h3>
                <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                  <Field label="Jumlah Bayi">
                    <input
                      name="usg_jumlah_bayi"
                      value={form.usg_jumlah_bayi}
                      onChange={handleChange}
                      placeholder="Tunggal/Kembar"
                      className={`${inputCls} ${
                        validationErrors.usg_jumlah_bayi
                          ? "border-red-500 bg-red-50"
                          : ""
                      }`}
                    />
                    <ErrorMessage message={validationErrors.usg_jumlah_bayi} />
                  </Field>
                  <Field label="CRL (cm)">
                    <input
                      type="number"
                      step="0.1"
                      name="usg_crl_cm"
                      value={form.usg_crl_cm}
                      onChange={handleChange}
                      placeholder="0.0"
                      className={`${inputCls} ${
                        validationErrors.usg_crl_cm
                          ? "border-red-500 bg-red-50"
                          : ""
                      }`}
                    />
                    <ErrorMessage message={validationErrors.usg_crl_cm} />
                  </Field>
                  <Field label="CRL (minggu)">
                    <input
                      type="number"
                      name="usg_crl_minggu"
                      value={form.usg_crl_minggu}
                      onChange={handleChange}
                      placeholder="0"
                      className={`${inputCls} ${
                        validationErrors.usg_crl_minggu
                          ? "border-red-500 bg-red-50"
                          : ""
                      }`}
                    />
                    <ErrorMessage message={validationErrors.usg_crl_minggu} />
                  </Field>
                  <Field label="CRL (hari)">
                    <input
                      type="number"
                      name="usg_crl_hari"
                      value={form.usg_crl_hari}
                      onChange={handleChange}
                      placeholder="0"
                      className={`${inputCls} ${
                        validationErrors.usg_crl_hari
                          ? "border-red-500 bg-red-50"
                          : ""
                      }`}
                    />
                    <ErrorMessage message={validationErrors.usg_crl_hari} />
                  </Field>
                </div>
              </div>
              {/* Temuan */}
              <div className="mb-5">
                <h3 className="text-xs font-bold text-violet-600 uppercase tracking-widest mb-3">
                  Temuan Lainnya
                </h3>
                <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                  <Field label="Letak Produk Kehamilan">
                    <input
                      name="usg_letak_produk_kehamilan"
                      value={form.usg_letak_produk_kehamilan}
                      onChange={handleChange}
                      placeholder="Intrauterin/Ekstrauterin"
                      className={`${inputCls} ${
                        validationErrors.usg_letak_produk_kehamilan
                          ? "border-red-500 bg-red-50"
                          : ""
                      }`}
                    />
                    <ErrorMessage
                      message={validationErrors.usg_letak_produk_kehamilan}
                    />
                  </Field>
                  <Field label="Pulsasi Jantung">
                    <input
                      name="usg_pulsasi_jantung"
                      value={form.usg_pulsasi_jantung}
                      onChange={handleChange}
                      placeholder="Tampak/Tidak tampak"
                      className={`${inputCls} ${
                        validationErrors.usg_pulsasi_jantung
                          ? "border-red-500 bg-red-50"
                          : ""
                      }`}
                    />
                    <ErrorMessage
                      message={validationErrors.usg_pulsasi_jantung}
                    />
                  </Field>
                  <Field label="Kecurigaan Abnormal">
                    <select
                      name="usg_kecurigaan_temuan_abnormal"
                      value={form.usg_kecurigaan_temuan_abnormal}
                      onChange={handleChange}
                      className={`${selectCls} ${
                        validationErrors.usg_kecurigaan_temuan_abnormal
                          ? "border-red-500 bg-red-50"
                          : form.usg_kecurigaan_temuan_abnormal === "Ya"
                            ? "border-red-300 bg-red-50 text-red-700"
                            : ""
                      }`}
                    >
                      <option value="Tidak">Tidak</option>
                      <option value="Ya">Ya</option>
                    </select>
                    <ErrorMessage
                      message={validationErrors.usg_kecurigaan_temuan_abnormal}
                    />
                  </Field>
                  {form.usg_kecurigaan_temuan_abnormal === "Ya" && (
                    <Field label="Keterangan Abnormal">
                      <input
                        name="usg_keterangan_temuan_abnormal"
                        value={form.usg_keterangan_temuan_abnormal}
                        onChange={handleChange}
                        placeholder="Jelaskan temuan..."
                        className={`${inputCls} border-red-200 ${
                          validationErrors.usg_keterangan_temuan_abnormal
                            ? "border-red-500 bg-red-50"
                            : ""
                        }`}
                      />
                      <ErrorMessage
                        message={
                          validationErrors.usg_keterangan_temuan_abnormal
                        }
                      />
                    </Field>
                  )}
                </div>
              </div>
              {/* Gambar USG */}
              <div className="mb-5">
                <h3 className="text-xs font-bold text-violet-600 uppercase tracking-widest mb-3">
                  <ImageIcon className="inline mr-1" size={16} /> Hasil USG
                  (Gambar)
                </h3>
                <div className="flex flex-col sm:flex-row gap-4 items-start">
                  <div className="flex-shrink-0">
                    <input
                      ref={fileInputRef}
                      type="file"
                      accept="image/*"
                      onChange={handleImageChange}
                      className="hidden"
                      id="usg-image-upload"
                    />
                    <label
                      htmlFor="usg-image-upload"
                      className="flex items-center gap-2 bg-white border border-gray-200 rounded-lg px-4 py-2.5 text-sm font-medium text-gray-600 hover:bg-gray-50 cursor-pointer transition"
                    >
                      <Upload size={16} /> Pilih Gambar
                    </label>
                  </div>
                  {usgImagePreview && (
                    <div className="relative border rounded-lg overflow-hidden max-w-xs">
                      <img
                        src={usgImagePreview}
                        alt="Preview USG"
                        className="max-h-48 object-contain"
                      />
                      <button
                        type="button"
                        onClick={handleRemoveImage}
                        className="absolute top-1 right-1 bg-red-500 text-white rounded-full w-5 h-5 flex items-center justify-center text-xs"
                      >
                        ✕
                      </button>
                    </div>
                  )}
                </div>
                <p className="text-xs text-gray-400 mt-1">
                  Unggah hasil USG (format JPG/PNG, akan dikonversi ke data
                  digital).
                </p>
              </div>
            </Section>
          )}

          {/* ══ STEP 3 ══ */}
          {currentStep === 3 && (
            <Section
              icon={FlaskConical}
              title="Pemeriksaan Laboratorium"
              color="amber"
              defaultOpen={true}
            >
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-4">
                <Field label="Tanggal Lab">
                  <input
                    type="date"
                    name="tanggal_lab"
                    value={form.tanggal_lab}
                    onChange={handleChange}
                    required
                    max={new Date().toISOString().split("T")[0]}
                    className={`${inputCls} ${
                      validationErrors.tanggal_lab
                        ? "border-red-500 bg-red-50"
                        : ""
                    }`}
                  />
                  <ErrorMessage message={validationErrors.tanggal_lab} />
                </Field>
              </div>
              {/* Tabel Hemoglobin, Goldar, Gula Darah */}
              <div className="rounded-xl border border-amber-100 overflow-hidden mb-4">
                <table className="w-full text-sm">
                  <thead className="bg-amber-50">
                    <tr>
                      <th className="text-left px-4 py-2 text-xs font-bold text-amber-700 uppercase tracking-wide w-1/3">
                        Pemeriksaan
                      </th>
                      <th className="text-left px-4 py-2 text-xs font-bold text-amber-700 uppercase tracking-wide w-1/3">
                        Hasil
                      </th>
                      <th className="text-left px-4 py-2 text-xs font-bold text-amber-700 uppercase tracking-wide w-1/3">
                        Rencana Tindak Lanjut
                      </th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-amber-50">
                    <tr>
                      <td className="px-4 py-3 font-medium text-gray-700">
                        Hemoglobin
                      </td>
                      <td className="px-4 py-3">
                        <div className="flex items-center gap-1">
                          <input
                            type="number"
                            step="0.1"
                            name="lab_hemoglobin_hasil"
                            value={form.lab_hemoglobin_hasil}
                            onChange={handleChange}
                            placeholder="0.0"
                            className={`${inputCls} ${
                              validationErrors.lab_hemoglobin_hasil
                                ? "border-red-500 bg-red-50"
                                : ""
                            }`}
                          />
                          <span className="text-xs text-gray-400">g/dL</span>
                        </div>
                        <ErrorMessage
                          message={validationErrors.lab_hemoglobin_hasil}
                        />
                      </td>
                      <td className="px-4 py-3">
                        <input
                          name="lab_hemoglobin_rencana_tindak_lanjut"
                          value={form.lab_hemoglobin_rencana_tindak_lanjut}
                          onChange={handleChange}
                          placeholder="Rencana..."
                          className={`${inputCls} ${
                            validationErrors.lab_hemoglobin_rencana_tindak_lanjut
                              ? "border-red-500 bg-red-50"
                              : ""
                          }`}
                        />
                        <ErrorMessage
                          message={
                            validationErrors.lab_hemoglobin_rencana_tindak_lanjut
                          }
                        />
                      </td>
                    </tr>
                    <tr className="bg-gray-50/50">
                      <td className="px-4 py-3 font-medium text-gray-700">
                        Golongan Darah & Rhesus
                      </td>
                      <td className="px-4 py-3">
                        <div className="flex gap-2">
                          <select
                            name="lab_golongan_darah"
                            value={
                              form.lab_golongan_darah_rhesus_hasil?.split(
                                " ",
                              )[0] || ""
                            }
                            onChange={(e) => {
                              const goldar = e.target.value;
                              const currentRhesus =
                                form.lab_golongan_darah_rhesus_hasil?.split(
                                  " ",
                                )[1] || "";
                              const newValue =
                                goldar +
                                (currentRhesus ? ` ${currentRhesus}` : "");
                              setForm((prev) => ({
                                ...prev,
                                lab_golongan_darah_rhesus_hasil: newValue,
                              }));
                              if (
                                validationErrors.lab_golongan_darah_rhesus_hasil
                              ) {
                                setValidationErrors((prev) => {
                                  const n = { ...prev };
                                  delete n.lab_golongan_darah_rhesus_hasil;
                                  return n;
                                });
                              }
                            }}
                            className={`${selectCls} flex-1 ${
                              validationErrors.lab_golongan_darah_rhesus_hasil
                                ? "border-red-500 bg-red-50"
                                : ""
                            }`}
                          >
                            <option value="">Pilih Golongan Darah</option>
                            <option value="A">A</option>
                            <option value="B">B</option>
                            <option value="AB">AB</option>
                            <option value="O">O</option>
                          </select>

                          <select
                            name="lab_rhesus"
                            value={
                              form.lab_golongan_darah_rhesus_hasil?.split(
                                " ",
                              )[1] || ""
                            }
                            onChange={(e) => {
                              const rhesus = e.target.value;
                              const currentGoldar =
                                form.lab_golongan_darah_rhesus_hasil?.split(
                                  " ",
                                )[0] || "";
                              const newValue =
                                currentGoldar + (rhesus ? ` ${rhesus}` : "");
                              setForm((prev) => ({
                                ...prev,
                                lab_golongan_darah_rhesus_hasil: newValue,
                              }));
                            }}
                            className={`${selectCls} w-24 ${
                              validationErrors.lab_golongan_darah_rhesus_hasil
                                ? "border-red-500 bg-red-50"
                                : ""
                            }`}
                          >
                            <option value="">Rhesus</option>
                            <option value="+">Positif (+)</option>
                            <option value="-">Negatif (-)</option>
                          </select>
                        </div>
                        <ErrorMessage
                          message={
                            validationErrors.lab_golongan_darah_rhesus_hasil
                          }
                        />
                      </td>
                      <td className="px-4 py-3">
                        <input
                          name="lab_golongan_darah_rhesus_rencana_tindak_lanjut"
                          value={
                            form.lab_golongan_darah_rhesus_rencana_tindak_lanjut
                          }
                          onChange={handleChange}
                          placeholder="Rencana tindak lanjut..."
                          className={`${inputCls} ${
                            validationErrors.lab_golongan_darah_rhesus_rencana_tindak_lanjut
                              ? "border-red-500 bg-red-50"
                              : ""
                          }`}
                        />
                        <ErrorMessage
                          message={
                            validationErrors.lab_golongan_darah_rhesus_rencana_tindak_lanjut
                          }
                        />
                      </td>
                    </tr>
                    <tr>
                      <td className="px-4 py-3 font-medium text-gray-700">
                        Gula Darah Sewaktu
                      </td>
                      <td className="px-4 py-3">
                        <div className="flex items-center gap-1">
                          <input
                            type="number"
                            name="lab_gula_darah_sewaktu_hasil"
                            value={form.lab_gula_darah_sewaktu_hasil}
                            onChange={handleChange}
                            placeholder="0"
                            className={`${inputCls} ${
                              validationErrors.lab_gula_darah_sewaktu_hasil
                                ? "border-red-500 bg-red-50"
                                : ""
                            }`}
                          />
                          <span className="text-xs text-gray-400">Mg/dL</span>
                        </div>
                        <ErrorMessage
                          message={
                            validationErrors.lab_gula_darah_sewaktu_hasil
                          }
                        />
                      </td>
                      <td className="px-4 py-3">
                        <input
                          name="lab_gula_darah_sewaktu_rencana_tindak_lanjut"
                          value={
                            form.lab_gula_darah_sewaktu_rencana_tindak_lanjut
                          }
                          onChange={handleChange}
                          placeholder="Rencana..."
                          className={`${inputCls} ${
                            validationErrors.lab_gula_darah_sewaktu_rencana_tindak_lanjut
                              ? "border-red-500 bg-red-50"
                              : ""
                          }`}
                        />
                        <ErrorMessage
                          message={
                            validationErrors.lab_gula_darah_sewaktu_rencana_tindak_lanjut
                          }
                        />
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
              {/* Tripel Eliminasi */}
              <div className="rounded-xl border border-amber-100 overflow-hidden">
                <table className="w-full text-sm">
                  <thead className="bg-amber-50">
                    <tr>
                      <th className="text-left px-4 py-2 text-xs font-bold text-amber-700 uppercase tracking-wide w-1/3">
                        Pemeriksaan
                      </th>
                      <th className="text-left px-4 py-2 text-xs font-bold text-amber-700 uppercase tracking-wide w-1/3">
                        Hasil
                      </th>
                      <th className="text-left px-4 py-2 text-xs font-bold text-amber-700 uppercase tracking-wide w-1/3">
                        Rencana Tindak Lanjut
                      </th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-amber-50">
                    {labReaktifFields.map((lf, idx) => (
                      <tr
                        key={lf.name}
                        className={idx % 2 === 1 ? "bg-gray-50/50" : ""}
                      >
                        <td className="px-4 py-3 font-medium text-gray-700">
                          {lf.label}
                        </td>
                        <td className="px-4 py-3">
                          <select
                            name={lf.name}
                            value={form[lf.name]}
                            onChange={handleChange}
                            className={`${selectCls} ${
                              validationErrors[lf.name]
                                ? "border-red-500 bg-red-50"
                                : form[lf.name] === "Reaktif"
                                  ? "border-red-300 bg-red-50 text-red-700"
                                  : "border-emerald-200 bg-emerald-50 text-emerald-700"
                            }`}
                          >
                            <option value="NonReaktif">Non Reaktif</option>
                            <option value="Reaktif">Reaktif</option>
                          </select>
                          <ErrorMessage message={validationErrors[lf.name]} />
                        </td>
                        <td className="px-4 py-3">
                          <input
                            name={lf.rencana}
                            value={form[lf.rencana]}
                            onChange={handleChange}
                            placeholder="Rencana..."
                            className={`${inputCls} ${
                              validationErrors[lf.rencana]
                                ? "border-red-500 bg-red-50"
                                : ""
                            }`}
                          />
                          <ErrorMessage
                            message={validationErrors[lf.rencana]}
                          />
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </Section>
          )}

          {/* ══ STEP 4 ══ */}
          {currentStep === 4 && (
            <Section
              icon={Brain}
              title="Skrining Kesehatan Jiwa & Kesimpulan"
              color="rose"
              defaultOpen={true}
            >
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-4">
                <Field label="Tanggal Skrining Jiwa">
                  <input
                    type="date"
                    name="tanggal_skrining_jiwa"
                    value={form.tanggal_skrining_jiwa}
                    onChange={handleChange}
                    required
                    max={new Date().toISOString().split("T")[0]}
                    className={`${inputCls} ${
                      validationErrors.tanggal_skrining_jiwa
                        ? "border-red-500 bg-red-50"
                        : ""
                    }`}
                  />
                  <ErrorMessage
                    message={validationErrors.tanggal_skrining_jiwa}
                  />
                </Field>
                <Field label="Skrining Kesehatan Jiwa">
                  <select
                    name="skrining_jiwa_hasil"
                    value={form.skrining_jiwa_hasil}
                    onChange={handleChange}
                    className={`${selectCls} ${
                      validationErrors.skrining_jiwa_hasil
                        ? "border-red-500 bg-red-50"
                        : ""
                    }`}
                  >
                    <option value="">-- Pilih --</option>
                    <option value="Ya">Ya</option>
                    <option value="Tidak">Tidak</option>
                  </select>
                  <ErrorMessage
                    message={validationErrors.skrining_jiwa_hasil}
                  />
                </Field>
                <Field label="Tindak Lanjut Skrining Jiwa">
                  <select
                    name="skrining_jiwa_tindak_lanjut"
                    value={form.skrining_jiwa_tindak_lanjut}
                    onChange={handleChange}
                    className={`${selectCls} ${
                      validationErrors.skrining_jiwa_tindak_lanjut
                        ? "border-red-500 bg-red-50"
                        : ""
                    }`}
                  >
                    <option value="">-- Pilih --</option>
                    <option value="Edukasi">Edukasi</option>
                    <option value="Konseling">Konseling</option>
                  </select>
                  <ErrorMessage
                    message={validationErrors.skrining_jiwa_tindak_lanjut}
                  />
                </Field>
                <Field label="Perlu Rujukan">
                  <select
                    name="skrining_jiwa_perlu_rujukan"
                    value={form.skrining_jiwa_perlu_rujukan}
                    onChange={handleChange}
                    className={`${selectCls} ${
                      validationErrors.skrining_jiwa_perlu_rujukan
                        ? "border-red-500 bg-red-50"
                        : form.skrining_jiwa_perlu_rujukan === "Ya"
                          ? "border-red-300 bg-red-50 text-red-700"
                          : "border-emerald-200 bg-emerald-50 text-emerald-700"
                    }`}
                  >
                    <option value="Tidak">Tidak</option>
                    <option value="Ya">Ya</option>
                  </select>
                  <ErrorMessage
                    message={validationErrors.skrining_jiwa_perlu_rujukan}
                  />
                </Field>
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <Field label="Kesimpulan">
                  <textarea
                    name="kesimpulan"
                    value={form.kesimpulan}
                    onChange={handleChange}
                    placeholder="Kesimpulan pemeriksaan..."
                    className={`${inputCls} ${
                      validationErrors.kesimpulan
                        ? "border-red-500 bg-red-50"
                        : ""
                    }`}
                    rows={3}
                  />
                  <ErrorMessage message={validationErrors.kesimpulan} />
                </Field>
                <Field label="Rekomendasi">
                  <textarea
                    name="rekomendasi"
                    value={form.rekomendasi}
                    onChange={handleChange}
                    placeholder="Rekomendasi tindak lanjut..."
                    className={`${inputCls} ${
                      validationErrors.rekomendasi
                        ? "border-red-500 bg-red-50"
                        : ""
                    }`}
                    rows={3}
                  />
                  <ErrorMessage message={validationErrors.rekomendasi} />
                </Field>
              </div>
            </Section>
          )}
        </div>
        {/* Navigation Buttons */}
        <div className="flex items-center justify-between pt-6 pb-6 border-t border-gray-200">
          <button
            type="button"
            onClick={() => navigate(-1)}
            className="px-6 py-2.5 rounded-xl border border-gray-200 text-gray-600 text-sm font-medium hover:bg-gray-50 transition"
          >
            Batalkan
          </button>
          <div className="flex gap-3">
            {canDelete && isEditModeFlag && (
              <button
                type="button"
                onClick={handleDelete}
                disabled={saving}
                className="flex items-center gap-2 bg-red-600 hover:bg-red-700 disabled:opacity-60 text-white px-6 py-2.5 rounded-xl text-sm font-semibold transition shadow-sm"
              >
                <Trash2 size={16} />
                {saving ? "Menghapus..." : "Hapus Data"}
              </button>
            )}
            {canEdit ? (
              <>
                {currentStep > 1 && (
                  <button
                    type="button"
                    onClick={handlePrevStep}
                    className="flex items-center gap-2 px-6 py-2.5 rounded-xl border border-gray-300 text-gray-700 text-sm font-medium hover:bg-gray-100 transition"
                  >
                    <ChevronLeft size={16} /> Sebelumnya
                  </button>
                )}
                {currentStep < 4 ? (
                  <button
                    type="button"
                    onClick={handleNextStep}
                    className="flex items-center gap-2 bg-indigo-600 hover:bg-indigo-700 text-white px-8 py-2.5 rounded-xl text-sm font-semibold transition shadow-sm"
                  >
                    Selanjutnya <ChevronRight size={16} />
                  </button>
                ) : (
                  <button
                    type="button"
                    onClick={handleSave}
                    disabled={saving}
                    className="flex items-center gap-2 bg-emerald-600 hover:bg-emerald-700 disabled:opacity-60 text-white px-8 py-2.5 rounded-xl text-sm font-semibold transition shadow-sm"
                  >
                    {saving ? (
                      <Loader2 className="animate-spin" size={16} />
                    ) : (
                      <Save size={16} />
                    )}
                    {saving ? "Menyimpan..." : "Simpan Semua Data"}
                  </button>
                )}
              </>
            ) : (
              // Untuk bidan, tampilkan pesan bahwa hanya view
              <div className="text-sm text-gray-500 bg-gray-100 px-4 py-2.5 rounded-xl">
                Mode Baca - Hubungi Dokter untuk perubahan data
              </div>
            )}
          </div>
        </div>
      </div>
    </MainLayout>
  );
}
