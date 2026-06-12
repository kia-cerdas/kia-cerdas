// src/pages/Ibu/PemeriksaanDokterT1CompleteDetail.jsx
import React, { useEffect, useState, useCallback } from "react";
import { useParams, useNavigate, Link } from "react-router-dom";
import Swal from "sweetalert2";
import MainLayout from "../../components/Layout/MainLayout";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import { getCurrentUser, isDokterUser, isBidanUser } from "../../services/auth"; 
import {
  getDokterT1CompleteByKehamilanId,
  deleteDokterT1Complete,
  getCatatanT1ByKehamilanId,
  createCatatanT1,
  updateCatatanT1,
  deleteCatatanT1,
} from "../../services/pemeriksaanDokter";
import {
  ArrowLeft,
  Edit,
  Trash2,
  AlertCircle,
  Loader2,
  StickyNote,
  Plus,
  X,
  Save,
  Calendar,
  CalendarCheck,
  User,
  Activity,
  Eye,
  FlaskConical,
  Brain,
  CheckCircle,
  XCircle,
  ChevronDown,
  ChevronUp,
  MessageSquarePlus,
  Pencil,
} from "lucide-react";

// ─── Helper Components ────────────────────────────────────────────────────────

function InfoRow({ label, value, highlight = false }) {
  return (
    <div className="flex flex-col gap-0.5">
      <span className="text-xs font-semibold text-gray-400 uppercase tracking-wide">
        {label}
      </span>
      <span
        className={`text-sm font-medium ${
          highlight ? "text-indigo-700" : "text-gray-800"
        } ${!value || value === "-" ? "text-gray-400 italic" : ""}`}
      >
        {value || "-"}
      </span>
    </div>
  );
}

function StatusBadge({ value }) {
  if (!value || value === "-") return <span className="text-gray-400 text-sm italic">-</span>;
  return value === "Normal" ? (
    <span className="inline-flex items-center gap-1 text-xs bg-emerald-100 text-emerald-700 px-2 py-0.5 rounded-full font-semibold">
      <CheckCircle size={10} /> Normal
    </span>
  ) : (
    <span className="inline-flex items-center gap-1 text-xs bg-red-100 text-red-700 px-2 py-0.5 rounded-full font-semibold">
      <XCircle size={10} /> Abnormal
    </span>
  );
}

function ReaktifBadge({ value }) {
  if (!value || value === "-") return <span className="text-gray-400 text-sm italic">-</span>;
  return value === "NonReaktif" || value === "Non Reaktif" ? (
    <span className="inline-flex items-center gap-1 text-xs bg-emerald-100 text-emerald-700 px-2 py-1 rounded-full font-semibold">
      <CheckCircle size={10} /> Non Reaktif
    </span>
  ) : (
    <span className="inline-flex items-center gap-1 text-xs bg-red-100 text-red-700 px-2 py-1 rounded-full font-semibold">
      <XCircle size={10} /> Reaktif
    </span>
  );
}

function fmtDate(val) {
  if (!val) return "-";
  try {
    return new Date(val).toLocaleDateString("id-ID", {
      day: "numeric",
      month: "long",
      year: "numeric",
    });
  } catch {
    return "-";
  }
}

function normalizeT1Response(res) {
  if (!res) return null;
  const body =
    res.data && (res.data.dokter || res.data.id || res.data.id_trimester1)
      ? res.data
      : res;

  if (body.dokter && (body.dokter.id || body.dokter.id_trimester1)) {
    return { dokter: body.dokter, lab_jiwa: body.lab_jiwa || null };
  }

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
      lab_jiwa: Object.keys(labFields).length ? labFields : null,
    };
  }

  return null;
}

function mergeLabData(dokter, labJiwa) {
  const lab = labJiwa || {};
  return {
    tanggal_lab: lab.tanggal_lab || dokter?.tanggal_lab,
    lab_hemoglobin_hasil: lab.lab_hemoglobin_hasil ?? dokter?.lab_hemoglobin_hasil,
    lab_hemoglobin_rencana_tindak_lanjut:
      lab.lab_hemoglobin_rencana_tindak_lanjut ||
      dokter?.lab_hemoglobin_rencana_tindak_lanjut,
    lab_gula_darah_sewaktu_hasil:
      lab.lab_gula_darah_sewaktu_hasil ?? dokter?.lab_gula_darah_sewaktu_hasil,
    lab_gula_darah_sewaktu_rencana_tindak_lanjut:
      lab.lab_gula_darah_sewaktu_rencana_tindak_lanjut ||
      dokter?.lab_gula_darah_sewaktu_rencana_tindak_lanjut,
    lab_golongan_darah_rhesus_hasil:
      lab.lab_golongan_darah_rhesus_hasil || dokter?.lab_golongan_darah_rhesus_hasil,
    lab_golongan_darah_rhesus_rencana_tindak_lanjut:
      lab.lab_golongan_darah_rhesus_rencana_tindak_lanjut ||
      dokter?.lab_golongan_darah_rhesus_rencana_tindak_lanjut,
    lab_hiv_hasil: lab.lab_hiv_hasil || dokter?.lab_hiv_hasil,
    lab_hiv_rencana_tindak_lanjut:
      lab.lab_hiv_rencana_tindak_lanjut || dokter?.lab_hiv_rencana_tindak_lanjut,
    lab_sifilis_hasil: lab.lab_sifilis_hasil || dokter?.lab_sifilis_hasil,
    lab_sifilis_rencana_tindak_lanjut:
      lab.lab_sifilis_rencana_tindak_lanjut || dokter?.lab_sifilis_rencana_tindak_lanjut,
    lab_hepatitis_b_hasil: lab.lab_hepatitis_b_hasil || dokter?.lab_hepatitis_b_hasil,
    lab_hepatitis_b_rencana_tindak_lanjut:
      lab.lab_hepatitis_b_rencana_tindak_lanjut ||
      dokter?.lab_hepatitis_b_rencana_tindak_lanjut,
    tanggal_skrining_jiwa: lab.tanggal_skrining_jiwa || dokter?.tanggal_skrining_jiwa,
    skrining_jiwa_hasil: lab.skrining_jiwa_hasil || dokter?.skrining_jiwa_hasil,
    skrining_jiwa_tindak_lanjut:
      lab.skrining_jiwa_tindak_lanjut || dokter?.skrining_jiwa_tindak_lanjut,
    skrining_jiwa_perlu_rujukan:
      lab.skrining_jiwa_perlu_rujukan || dokter?.skrining_jiwa_perlu_rujukan,
    kesimpulan: lab.kesimpulan || dokter?.kesimpulan,
    rekomendasi: lab.rekomendasi || dokter?.rekomendasi,
  };
}

function DetailSection({
  icon: Icon,
  title,
  colorCls = "bg-indigo-50 text-indigo-700 border-indigo-100",
  children,
  defaultOpen = true,
}) {
  const [open, setOpen] = useState(defaultOpen);
  return (
    <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
      <button
        type="button"
        onClick={() => setOpen((v) => !v)}
        className={`w-full flex items-center justify-between px-5 py-4 border-b ${colorCls} transition-colors`}
      >
        <div className="flex items-center gap-2">
          {Icon && <Icon size={17} />}
          <span className="font-semibold text-sm">{title}</span>
        </div>
        {open ? <ChevronUp size={15} /> : <ChevronDown size={15} />}
      </button>
      {open && <div className="p-5">{children}</div>}
    </div>
  );
}

// ─── Modal Catatan ────────────────────────────────────────────────────────────

// ─── Modal Catatan ────────────────────────────────────────────────────────────

function ModalCatatan({ kehamilanId, catatan, onClose, onSaved }) {
  const isEdit = Boolean(catatan);
  
  // Fungsi helper untuk validasi tanggal
  const isDateAfterToday = (dateStr) => {
    if (!dateStr) return false;
    const today = new Date().toISOString().split("T")[0];
    return dateStr > today;
  };
  
  const [form, setForm] = useState({
    tanggal_periksa_stamp_paraf: catatan?.tanggal_periksa_stamp_paraf
      ? catatan.tanggal_periksa_stamp_paraf.split("T")[0]
      : "",
    keluhan_pemeriksaan_tindakan_saran:
      catatan?.keluhan_pemeriksaan_tindakan_saran || "",
    tanggal_kembali: catatan?.tanggal_kembali
      ? catatan.tanggal_kembali.split("T")[0]
      : "",
  });
  const [saving, setSaving] = useState(false);
  const [fieldError, setFieldError] = useState("");
  const [validationErrors, setValidationErrors] = useState({});

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
    // Hapus error field yang sedang diubah
    if (validationErrors[name]) {
      setValidationErrors((prev) => {
        const newErrors = { ...prev };
        delete newErrors[name];
        return newErrors;
      });
    }
    setFieldError("");
  };

  // Fungsi validasi form
  const validateForm = () => {
    const errors = {};
    
    // Validasi Tanggal Periksa - WAJIB DIISI & TIDAK BOLEH MELEBIHI HARI INI
    if (!form.tanggal_periksa_stamp_paraf) {
      errors.tanggal_periksa_stamp_paraf = "Tanggal periksa harus diisi";
    } else if (isDateAfterToday(form.tanggal_periksa_stamp_paraf)) {
      errors.tanggal_periksa_stamp_paraf = "Tanggal periksa tidak boleh melebihi hari ini";
    }
    
    // Validasi Keluhan - WAJIB DIISI
    if (!form.keluhan_pemeriksaan_tindakan_saran.trim()) {
      errors.keluhan_pemeriksaan_tindakan_saran = "Keluhan / pemeriksaan / tindakan / saran harus diisi";
    }
    
    // ✅ Validasi Tanggal Kembali - WAJIB DIISI (boleh melebihi hari ini / boleh di masa depan)
    if (!form.tanggal_kembali) {
      errors.tanggal_kembali = "Tanggal kembali harus diisi";
    }
    // HAPUS validasi isDateAfterToday untuk tanggal_kembali
    
    return errors;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Jalankan validasi
    const errors = validateForm();
    if (Object.keys(errors).length > 0) {
      setValidationErrors(errors);
      setFieldError("Mohon lengkapi data yang wajib diisi dengan benar.");
      return;
    }
    
    setSaving(true);
    try {
      const payload = {
        kehamilan_id: kehamilanId,
        tanggal_periksa_stamp_paraf: form.tanggal_periksa_stamp_paraf,
        keluhan_pemeriksaan_tindakan_saran:
          form.keluhan_pemeriksaan_tindakan_saran.trim(),
        tanggal_kembali: form.tanggal_kembali,
      };

      if (isEdit) {
        await updateCatatanT1(catatan.id_catatan, payload);
      } else {
        await createCatatanT1(payload);
      }
      onSaved();
      onClose();
    } catch (err) {
      const msg =
        err.response?.data?.message || err.message || "Terjadi kesalahan";
      setFieldError("Gagal menyimpan: " + msg);
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div
        className="absolute inset-0 bg-black/40 backdrop-blur-sm"
        onClick={onClose}
      />
      <div className="relative bg-white rounded-2xl shadow-2xl w-full max-w-lg z-10 overflow-hidden">
        <div className="flex items-center justify-between px-6 py-4 bg-indigo-50 border-b border-indigo-100">
          <div className="flex items-center gap-2 text-indigo-700">
            <StickyNote size={18} />
            <h2 className="font-bold text-sm">
              {isEdit ? "Edit Catatan" : "Tambah Catatan Baru"}
            </h2>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="p-1.5 rounded-full hover:bg-indigo-100 transition text-indigo-500"
          >
            <X size={16} />
          </button>
        </div>
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          {/* Field Tanggal Periksa */}
          <div>
            <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1">
              Tanggal Periksa / Stempel / Paraf <span className="text-red-500">*</span>
            </label>
            <input
              type="date"
              name="tanggal_periksa_stamp_paraf"
              value={form.tanggal_periksa_stamp_paraf}
              onChange={handleChange}
              max={new Date().toISOString().split("T")[0]}
              className={`w-full border rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-400 transition ${
                validationErrors.tanggal_periksa_stamp_paraf
                  ? "border-red-500 bg-red-50"
                  : "border-gray-200"
              }`}
            />
            {validationErrors.tanggal_periksa_stamp_paraf && (
              <p className="text-xs text-red-500 font-medium mt-1">
                {validationErrors.tanggal_periksa_stamp_paraf}
              </p>
            )}
          </div>
          
          {/* Field Keluhan */}
          <div>
            <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1">
              Keluhan / Pemeriksaan / Tindakan / Saran{" "}
              <span className="text-red-500">*</span>
            </label>
            <textarea
              name="keluhan_pemeriksaan_tindakan_saran"
              value={form.keluhan_pemeriksaan_tindakan_saran}
              onChange={handleChange}
              placeholder="Tuliskan keluhan pasien, hasil pemeriksaan, tindakan yang dilakukan, atau saran dokter..."
              rows={5}
              className={`w-full border rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-400 transition resize-none ${
                validationErrors.keluhan_pemeriksaan_tindakan_saran
                  ? "border-red-500 bg-red-50"
                  : "border-gray-200"
              }`}
            />
            {validationErrors.keluhan_pemeriksaan_tindakan_saran && (
              <p className="text-xs text-red-500 font-medium mt-1">
                {validationErrors.keluhan_pemeriksaan_tindakan_saran}
              </p>
            )}
          </div>
          
          {/* Field Tanggal Kembali - Boleh di masa depan */}
          <div>
            <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1">
              Tanggal Kembali (Kontrol Selanjutnya) <span className="text-red-500">*</span>
            </label>
            <input
              type="date"
              name="tanggal_kembali"
              value={form.tanggal_kembali}
              onChange={handleChange}
              // HAPUS max attribute - boleh pilih tanggal berapa saja (masa depan)
              className={`w-full border rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-400 transition ${
                validationErrors.tanggal_kembali
                  ? "border-red-500 bg-red-50"
                  : "border-gray-200"
              }`}
            />
            {validationErrors.tanggal_kembali && (
              <p className="text-xs text-red-500 font-medium mt-1">
                {validationErrors.tanggal_kembali}
              </p>
            )}
          </div>
          
          {/* Error umum */}
          {fieldError && (
            <div className="flex items-center gap-2 bg-red-50 border border-red-200 rounded-xl px-3 py-2">
              <AlertCircle size={14} className="text-red-500 shrink-0" />
              <p className="text-xs text-red-600">{fieldError}</p>
            </div>
          )}
          
          {/* Tombol aksi */}
          <div className="flex gap-3 pt-1">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 py-2 rounded-xl border border-gray-200 text-gray-600 text-sm font-medium hover:bg-gray-50 transition"
            >
              Batal
            </button>
            <button
              type="submit"
              disabled={saving}
              className="flex-1 flex items-center justify-center gap-2 bg-indigo-600 hover:bg-indigo-700 disabled:opacity-60 text-white py-2 rounded-xl text-sm font-semibold transition"
            >
              {saving ? (
                <Loader2 className="animate-spin" size={15} />
              ) : (
                <Save size={15} />
              )}
              {saving
                ? "Menyimpan..."
                : isEdit
                ? "Simpan Perubahan"
                : "Tambah Catatan"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

// ─── Komponen Utama ───────────────────────────────────────────────────────────

export default function PemeriksaanDokterT1CompleteDetail() {
  const { id } = useParams();
  const navigate = useNavigate();

  const [kehamilan, setKehamilan] = useState(null);
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const [catatanList, setCatatanList] = useState([]);
  const [loadingCatatan, setLoadingCatatan] = useState(false);
  const [modalOpen, setModalOpen] = useState(false);
  const [editCatatan, setEditCatatan] = useState(null);
 const [canEdit, setCanEdit] = useState(false);
  const [canDelete, setCanDelete] = useState(false);
   // ✅ Cek role user saat komponen mount
  useEffect(() => {
    const user = getCurrentUser();
    const isDokter = isDokterUser(user);
    setCanEdit(isDokter);
    setCanDelete(isDokter);
    
    console.log("[Detail] User role:", user?.role);
    console.log("[Detail] Can Edit:", isDokter);
    console.log("[Detail] Can Delete:", isDokter);
  }, []);

  // ── Fetch data pemeriksaan ─────────────────────────────────────────────
  useEffect(() => {
    const fetchData = async () => {
      try {
        const kehamilanList = await getKehamilanByIbuId(id);
        if (!kehamilanList || kehamilanList.length === 0) {
          setError("Data kehamilan tidak ditemukan.");
          setLoading(false);
          return;
        }
        const aktif = kehamilanList[0];
        setKehamilan(aktif);

        const res = await getDokterT1CompleteByKehamilanId(aktif.id);
        const normalized = normalizeT1Response(res);
        if (!normalized?.dokter) {
          setError(
            "Belum ada data pemeriksaan. Silakan buat data terlebih dahulu."
          );
        } else {
          setData(normalized);
        }
      } catch (err) {
        console.error(err);
        setError("Terjadi kesalahan saat memuat data.");
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [id]);

  // ── Fetch catatan ──────────────────────────────────────────────────────
  const fetchCatatan = useCallback(async () => {
    if (!kehamilan) return;
    setLoadingCatatan(true);
    try {
      const res = await getCatatanT1ByKehamilanId(kehamilan.id);
      if (Array.isArray(res)) {
        setCatatanList(res);
      } else if (res && Array.isArray(res.data)) {
        setCatatanList(res.data);
      } else {
        setCatatanList([]);
      }
    } catch (err) {
      console.error("Error fetch catatan:", err);
      setCatatanList([]);
    } finally {
      setLoadingCatatan(false);
    }
  }, [kehamilan]);

  useEffect(() => {
    fetchCatatan();
  }, [fetchCatatan]);

  // ── Hapus pemeriksaan utama ────────────────────────────────────────────
  const handleDelete = async () => {
    // Pastikan ID tersedia
    const dokterId = data?.dokter?.id || data?.dokter?.id_trimester1;
    if (!dokterId) {
      Swal.fire({
        icon: "error",
        title: "Gagal Menghapus",
        text: "ID pemeriksaan tidak ditemukan. Silakan muat ulang halaman.",
      });
      return;
    }

    const result = await Swal.fire({
      title: "Hapus Data Pemeriksaan T1?",
      html: "<p class='text-sm'>Apakah Anda yakin ingin menghapus semua data pemeriksaan Trimester 1 ini?</p><p class='text-xs text-red-600 mt-2'>⚠️ Seluruh Catatan Pelayanan pada Trimester ini juga akan ikut terhapus.</p>",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#dc2626",
      cancelButtonColor: "#6b7280",
      confirmButtonText: "Ya, Hapus",
      cancelButtonText: "Batal",
    });

    if (!result.isConfirmed) return;

    try {
      // Hapus semua catatan terlebih dahulu
      if (catatanList.length > 0) {
        const deletePromises = catatanList.map((c) =>
          deleteCatatanT1(c.id_catatan)
        );
        await Promise.all(deletePromises);
      }

      // Hapus pemeriksaan utama
      await deleteDokterT1Complete(dokterId);

      await Swal.fire({
        icon: "success",
        title: "Berhasil!",
        text: "Data pemeriksaan dan catatan terkait berhasil dihapus.",
        timer: 2000,
        showConfirmButton: false,
      });
      navigate(`/data-ibu/${id}`);
    } catch (err) {
      console.error("Delete error:", err);
      const errorMsg =
        err.response?.data?.message || err.message || "Terjadi kesalahan";
      Swal.fire({
        icon: "error",
        title: "Gagal Menghapus",
        text: errorMsg,
      });
    }
  };

  // ── Hapus satu catatan ─────────────────────────────────────────────────
  const handleDeleteCatatan = async (idCatatan) => {
    if (!idCatatan) return;
    const result = await Swal.fire({
      title: "Hapus Catatan?",
      text: "Apakah Anda yakin ingin menghapus catatan ini?",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#dc2626",
      cancelButtonColor: "#6b7280",
      confirmButtonText: "Ya, Hapus",
      cancelButtonText: "Batal",
    });

    if (!result.isConfirmed) return;

    try {
      await deleteCatatanT1(idCatatan);
      await Swal.fire({
        icon: "success",
        title: "Berhasil!",
        text: "Catatan berhasil dihapus.",
        timer: 1500,
        showConfirmButton: false,
      });
      fetchCatatan();
    } catch (err) {
      const errorMsg =
        err.response?.data?.message || err.message || "Terjadi kesalahan";
      Swal.fire({
        icon: "error",
        title: "Gagal Menghapus",
        text: errorMsg,
      });
    }
  };

  const handleTambahCatatan = () => {
    setEditCatatan(null);
    setModalOpen(true);
  };

  const handleEditCatatan = (catatan) => {
    setEditCatatan(catatan);
    setModalOpen(true);
  };

  const handleModalClose = () => {
    setModalOpen(false);
    setEditCatatan(null);
  };

  // ── Loading ────────────────────────────────────────────────────────────
  if (loading) {
    return (
      <MainLayout>
        <div className="min-h-screen flex items-center justify-center">
          <div className="flex flex-col items-center gap-3 text-indigo-600">
            <Loader2 className="animate-spin" size={40} />
            <p className="text-sm text-gray-500">Memuat data...</p>
          </div>
        </div>
      </MainLayout>
    );
  }

  // ── Error / tidak ada data ─────────────────────────────────────────────
  if (error || !data) {
    return (
      <MainLayout>
        <div className="p-6 max-w-2xl mx-auto mt-10">
          <div className="bg-yellow-50 border border-yellow-200 rounded-2xl p-8 text-center">
            <div className="w-16 h-16 bg-yellow-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <AlertCircle className="text-yellow-500" size={32} />
            </div>
            <h2 className="text-xl font-bold text-yellow-700 mb-2">
              Data Tidak Ditemukan
            </h2>
            <p className="text-gray-600 mb-6 text-sm">
              {error || "Belum ada data pemeriksaan."}
            </p>
            <div className="flex gap-3 justify-center">
              <Link
                to={`/data-ibu/${id}/pemeriksaan-dokter-t1-complete/form`}
                className="bg-indigo-600 text-white px-5 py-2 rounded-lg text-sm font-medium hover:bg-indigo-700 transition"
              >
                Buat Data Baru
              </Link>
              <button
                onClick={() => navigate(-1)}
                className="bg-gray-100 text-gray-700 px-5 py-2 rounded-lg text-sm font-medium hover:bg-gray-200 transition"
              >
                Kembali
              </button>
            </div>
          </div>
        </div>
      </MainLayout>
    );
  }

  const d = data.dokter;
  const lab = mergeLabData(d, data.lab_jiwa);

  const fisikItems = [
    { label: "Konjungtiva", value: d.fisik_konjungtiva },
    { label: "Sklera", value: d.fisik_sklera },
    { label: "Kulit", value: d.fisik_kulit },
    { label: "Leher", value: d.fisik_leher },
    { label: "Gigi & Mulut", value: d.fisik_gigi_mulut },
    { label: "THT", value: d.fisik_tht },
    { label: "Dada / Jantung", value: d.fisik_dada_jantung },
    { label: "Dada / Paru", value: d.fisik_dada_paru },
    { label: "Perut", value: d.fisik_perut },
    { label: "Tungkai", value: d.fisik_tungkai },
  ];

  const abnormalCount = fisikItems.filter((f) => f.value === "Abnormal").length;

  return (
    <MainLayout>
      <div className="p-4 md:p-6 max-w-5xl mx-auto">
        {/* Header */}
        <div className="flex items-start justify-between mb-6 gap-3">
          <div className="flex items-center gap-3">
            <button
              onClick={() => navigate(`/data-ibu/${id}`)}
              className="p-2 rounded-full hover:bg-gray-100 transition shrink-0"
            >
              <ArrowLeft size={20} className="text-gray-600" />
            </button>
            <div>
              <h1 className="text-xl md:text-2xl font-bold text-gray-800">
                Pemeriksaan Dokter Trimester 1
              </h1>
              <p className="text-sm text-gray-500 mt-0.5">
                Detail pemeriksaan fisik, USG, dan laboratorium
              </p>
            </div>
          </div>
           {/* ✅ Badge Role */}
          <div className={`px-3 py-1 rounded-full text-xs font-semibold ${
            canEdit ? 'bg-green-100 text-green-700' : 'bg-blue-100 text-blue-700'
          }`}>
            {canEdit ? '✏️ Mode Edit (Dokter)' : '👁️ Mode Baca (Bidan)'}
          </div>
        </div>

        {/* ✅ Informasi akses untuk BIDAN */}
        {!canEdit && (
          <div className="mb-6 p-3 bg-blue-50 rounded-lg border border-blue-200">
            <p className="text-sm text-blue-700 flex items-center gap-2">
              <AlertCircle size={16} />
              Anda login sebagai BIDAN. Data hanya dapat dilihat, tidak dapat diedit atau dihapus.
            </p>
          </div>
        )}

        {/* ✅ Tombol Edit dan Hapus - HANYA untuk DOKTER */}
        {canEdit && (
          <div className="flex gap-2 shrink-0 mb-6">
            <Link
              to={`/data-ibu/${id}/pemeriksaan-dokter-t1-complete/form`}
              className="flex items-center gap-1.5 bg-amber-500 hover:bg-amber-600 text-white px-4 py-2 rounded-xl text-sm font-medium transition"
            >
              <Edit size={15} /> Edit
            </Link>
            <button
              onClick={handleDelete}
              className="flex items-center gap-1.5 bg-red-500 hover:bg-red-600 text-white px-4 py-2 rounded-xl text-sm font-medium transition"
            >
              <Trash2 size={15} /> Hapus
            </button>
          </div>
        )}


        {/* Summary cards */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-5">
          <div className="bg-indigo-50 rounded-2xl p-4 border border-indigo-100">
            <p className="text-xs text-indigo-500 font-semibold uppercase tracking-wide mb-1">
              Dokter
            </p>
            <p className="text-sm font-bold text-indigo-800 truncate">
              {d.nama_dokter || "-"}
            </p>
          </div>
          <div className="bg-teal-50 rounded-2xl p-4 border border-teal-100">
            <p className="text-xs text-teal-500 font-semibold uppercase tracking-wide mb-1">
              Tanggal Periksa
            </p>
            <p className="text-sm font-bold text-teal-800">
              {fmtDate(d.tanggal_periksa)}
            </p>
          </div>
          <div
            className={`rounded-2xl p-4 border ${
              abnormalCount > 0
                ? "bg-red-50 border-red-100"
                : "bg-emerald-50 border-emerald-100"
            }`}
          >
            <p
              className={`text-xs font-semibold uppercase tracking-wide mb-1 ${
                abnormalCount > 0 ? "text-red-500" : "text-emerald-500"
              }`}
            >
              Fisik Abnormal
            </p>
            <p
              className={`text-2xl font-bold ${
                abnormalCount > 0 ? "text-red-700" : "text-emerald-700"
              }`}
            >
              {abnormalCount}
              <span className="text-sm font-normal"> / 10</span>
            </p>
          </div>
          <div className="bg-violet-50 rounded-2xl p-4 border border-violet-100">
            <p className="text-xs text-violet-500 font-semibold uppercase tracking-wide mb-1">
              UK USG
            </p>
            <p className="text-sm font-bold text-violet-800">
              {d.umur_hamil_usg_minggu
                ? `${d.umur_hamil_usg_minggu} minggu`
                : "-"}
            </p>
          </div>
        </div>

        <div className="space-y-4">
          {/* Data Dokter */}
          <DetailSection
            icon={User}
            title="Data Dokter & Anamnesis"
            colorCls="bg-indigo-50 text-indigo-700 border-indigo-100"
          >
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <InfoRow label="Nama Dokter" value={d.nama_dokter} highlight />
              <InfoRow
                label="Tanggal Periksa"
                value={fmtDate(d.tanggal_periksa)}
              />
              <div className="sm:col-span-3">
                <InfoRow
                  label="Konsep Anamnesa Pemeriksaan"
                  value={d.konsep_anamnesa_pemeriksaan}
                />
              </div>
            </div>
          </DetailSection>

          {/* Pemeriksaan Fisik */}
          <DetailSection
            icon={Activity}
            title="Pemeriksaan Fisik"
            colorCls="bg-teal-50 text-teal-700 border-teal-100"
          >
            {abnormalCount > 0 && (
              <div className="mb-4 flex items-center gap-2 bg-red-50 border border-red-200 rounded-xl px-4 py-2.5">
                <AlertCircle size={15} className="text-red-500 shrink-0" />
                <p className="text-xs text-red-600 font-medium">
                  Terdapat {abnormalCount} temuan abnormal pada pemeriksaan
                  fisik.
                </p>
              </div>
            )}
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-5 gap-3">
              {fisikItems.map((item) => (
                <div key={item.label} className="flex flex-col gap-1">
                  <span className="text-xs font-semibold text-gray-400 uppercase tracking-wide">
                    {item.label}
                  </span>
                  <StatusBadge value={item.value} />
                </div>
              ))}
            </div>
          </DetailSection>

          {/* USG */}
          <DetailSection
            icon={Eye}
            title="USG Trimester 1"
            colorCls="bg-violet-50 text-violet-700 border-violet-100"
          >
            {/* HPHT */}
            <div className="mb-4">
              <p className="text-xs font-bold text-violet-500 uppercase tracking-widest mb-3">
                Berdasarkan HPHT
              </p>
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                <InfoRow label="HPHT" value={fmtDate(d.hpht)} />
                <InfoRow
                  label="Keteraturan Haid"
                  value={d.keteraturan_haid}
                />
                <InfoRow
                  label="UK HPHT"
                  value={
                    d.umur_hamil_hpht_minggu
                      ? `${d.umur_hamil_hpht_minggu} minggu`
                      : null
                  }
                />
                <InfoRow
                  label="HPL (HPHT)"
                  value={fmtDate(d.hpl_berdasarkan_hpht)}
                />
              </div>
            </div>
            {/* USG */}
            <div className="mb-4">
              <p className="text-xs font-bold text-violet-500 uppercase tracking-widest mb-3">
                Berdasarkan USG
              </p>
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                <InfoRow
                  label="UK USG"
                  value={
                    d.umur_hamil_usg_minggu
                      ? `${d.umur_hamil_usg_minggu} minggu`
                      : null
                  }
                  highlight
                />
                <InfoRow
                  label="HPL (USG)"
                  value={fmtDate(d.hpl_berdasarkan_usg)}
                />
              </div>
            </div>
            {/* GS */}
            <div className="mb-4">
              <p className="text-xs font-bold text-violet-500 uppercase tracking-widest mb-3">
                Gestational Sac (GS)
              </p>
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                <InfoRow label="Jumlah GS" value={d.usg_jumlah_gs} />
                <InfoRow
                  label="Diameter GS"
                  value={
                    d.usg_diameter_gs_cm
                      ? `${d.usg_diameter_gs_cm} cm`
                      : null
                  }
                />
                <InfoRow
                  label="GS (minggu)"
                  value={
                    d.usg_diameter_gs_minggu
                      ? `${d.usg_diameter_gs_minggu} mg`
                      : null
                  }
                />
                <InfoRow
                  label="GS (hari)"
                  value={
                    d.usg_diameter_gs_hari
                      ? `${d.usg_diameter_gs_hari} hr`
                      : null
                  }
                />
              </div>
            </div>
            {/* CRL */}
            <div className="mb-4">
              <p className="text-xs font-bold text-violet-500 uppercase tracking-widest mb-3">
                Crown-Rump Length (CRL)
              </p>
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                <InfoRow label="Jumlah Bayi" value={d.usg_jumlah_bayi} />
                <InfoRow
                  label="CRL"
                  value={d.usg_crl_cm ? `${d.usg_crl_cm} cm` : null}
                />
                <InfoRow
                  label="CRL (minggu)"
                  value={
                    d.usg_crl_minggu ? `${d.usg_crl_minggu} mg` : null
                  }
                />
                <InfoRow
                  label="CRL (hari)"
                  value={d.usg_crl_hari ? `${d.usg_crl_hari} hr` : null}
                />
              </div>
            </div>
            {/* Temuan */}
            <div>
              <p className="text-xs font-bold text-violet-500 uppercase tracking-widest mb-3">
                Temuan Lainnya
              </p>
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                <InfoRow
                  label="Letak Produk"
                  value={d.usg_letak_produk_kehamilan}
                />
                <InfoRow
                  label="Pulsasi Jantung"
                  value={d.usg_pulsasi_jantung}
                />
                <div className="flex flex-col gap-1">
                  <span className="text-xs font-semibold text-gray-400 uppercase tracking-wide">
                    Kecurigaan Abnormal
                  </span>
                  {d.usg_kecurigaan_temuan_abnormal === "Ya" ? (
                    <span className="inline-flex items-center gap-1 text-xs bg-red-100 text-red-700 px-2 py-0.5 rounded-full font-semibold">
                      <XCircle size={10} /> Ya
                    </span>
                  ) : (
                    <span className="inline-flex items-center gap-1 text-xs bg-emerald-100 text-emerald-700 px-2 py-0.5 rounded-full font-semibold">
                      <CheckCircle size={10} /> Tidak
                    </span>
                  )}
                </div>
                {d.usg_kecurigaan_temuan_abnormal === "Ya" && (
                  <InfoRow
                    label="Keterangan Abnormal"
                    value={d.usg_keterangan_temuan_abnormal}
                  />
                )}
              </div>
            </div>
            {d.gambar_usg && (
              <div className="mt-4 pt-4 border-t border-violet-200">
                <p className="text-xs font-bold text-violet-600 uppercase tracking-widest mb-3">
                  Gambar USG
                </p>
                <div className="flex justify-center">
                  <img
                    src={d.gambar_usg}
                    alt="USG"
                    className="max-w-full max-h-96 rounded-lg border border-violet-200 shadow-sm"
                    onError={(e) => {
                      e.target.src =
                        "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='200' height='200'%3E%3Crect fill='%23f3f4f6' width='200' height='200'/%3E%3Ctext x='50%25' y='50%25' text-anchor='middle' dy='.3em' fill='%239ca3af' font-size='14'%3EImage not available%3C/text%3E%3C/svg%3E";
                    }}
                  />
                </div>
              </div>
            )}
          </DetailSection>

          {/* Laboratorium */}
          <DetailSection
            icon={FlaskConical}
            title="Pemeriksaan Laboratorium"
            colorCls="bg-amber-50 text-amber-700 border-amber-100"
          >
            <div className="mb-4">
              <InfoRow
                label="Tanggal Lab"
                value={fmtDate(lab?.tanggal_lab)}
              />
            </div>
            <div className="rounded-xl border border-amber-100 overflow-hidden mb-4">
              <table className="w-full text-sm">
                <thead className="bg-amber-50">
                  <tr>
                    <th className="text-left px-4 py-2.5 text-xs font-bold text-amber-700 uppercase tracking-wide">
                      Pemeriksaan
                    </th>
                    <th className="text-left px-4 py-2.5 text-xs font-bold text-amber-700 uppercase tracking-wide">
                      Hasil
                    </th>
                    <th className="text-left px-4 py-2.5 text-xs font-bold text-amber-700 uppercase tracking-wide">
                      Rencana Tindak Lanjut
                    </th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-amber-50">
                  <tr>
                    <td className="px-4 py-3 font-medium text-gray-700">
                      Hemoglobin
                    </td>
                    <td className="px-4 py-3 text-gray-800">
                      {lab?.lab_hemoglobin_hasil ? (
                        <span>
                          <span className="font-semibold">
                            {lab.lab_hemoglobin_hasil}
                          </span>{" "}
                          <span className="text-xs text-gray-400">g/dL</span>
                        </span>
                      ) : (
                        <span className="text-gray-400 italic text-xs">-</span>
                      )}
                    </td>
                    <td className="px-4 py-3 text-gray-600 text-xs">
                      {lab?.lab_hemoglobin_rencana_tindak_lanjut || (
                        <span className="italic text-gray-400">-</span>
                      )}
                    </td>
                  </tr>
                  <tr className="bg-gray-50/60">
                    <td className="px-4 py-3 font-medium text-gray-700">
                      Gula Darah Sewaktu
                    </td>
                    <td className="px-4 py-3 text-gray-800">
                      {lab?.lab_gula_darah_sewaktu_hasil ? (
                        <span>
                          <span className="font-semibold">
                            {lab.lab_gula_darah_sewaktu_hasil}
                          </span>{" "}
                          <span className="text-xs text-gray-400">mg/dL</span>
                        </span>
                      ) : (
                        <span className="text-gray-400 italic text-xs">-</span>
                      )}
                    </td>
                    <td className="px-4 py-3 text-gray-600 text-xs">
                      {lab?.lab_gula_darah_sewaktu_rencana_tindak_lanjut || (
                        <span className="italic text-gray-400">-</span>
                      )}
                    </td>
                  </tr>
                  <tr>
                    <td className="px-4 py-3 font-medium text-gray-700">
                      Golongan Darah & Rhesus
                    </td>
                    <td className="px-4 py-3 text-gray-800 font-semibold">
                      {lab?.lab_golongan_darah_rhesus_hasil || (
                        <span className="text-gray-400 italic font-normal text-xs">
                          -
                        </span>
                      )}
                    </td>
                    <td className="px-4 py-3 text-gray-600 text-xs">
                      {lab?.lab_golongan_darah_rhesus_rencana_tindak_lanjut || (
                        <span className="italic text-gray-400">-</span>
                      )}
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div className="rounded-xl border border-amber-100 overflow-hidden">
              <table className="w-full text-sm">
                <thead className="bg-amber-50">
                  <tr>
                    <th className="text-left px-4 py-2.5 text-xs font-bold text-amber-700 uppercase tracking-wide">
                      Pemeriksaan
                    </th>
                    <th className="text-left px-4 py-2.5 text-xs font-bold text-amber-700 uppercase tracking-wide">
                      Hasil
                    </th>
                    <th className="text-left px-4 py-2.5 text-xs font-bold text-amber-700 uppercase tracking-wide">
                      Rencana Tindak Lanjut
                    </th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-amber-50">
                  {[
                    {
                      label: "HIV",
                      hasil: lab?.lab_hiv_hasil,
                      rencana: lab?.lab_hiv_rencana_tindak_lanjut,
                    },
                    {
                      label: "Sifilis",
                      hasil: lab?.lab_sifilis_hasil,
                      rencana: lab?.lab_sifilis_rencana_tindak_lanjut,
                    },
                    {
                      label: "Hepatitis B",
                      hasil: lab?.lab_hepatitis_b_hasil,
                      rencana: lab?.lab_hepatitis_b_rencana_tindak_lanjut,
                    },
                  ].map((row, idx) => (
                    <tr
                      key={row.label}
                      className={idx % 2 === 1 ? "bg-gray-50/60" : ""}
                    >
                      <td className="px-4 py-3 font-medium text-gray-700">
                        {row.label}
                      </td>
                      <td className="px-4 py-3">
                        <ReaktifBadge value={row.hasil} />
                      </td>
                      <td className="px-4 py-3 text-gray-600 text-xs">
                        {row.rencana || (
                          <span className="italic text-gray-400">-</span>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </DetailSection>

          {/* Skrining Jiwa */}
          <DetailSection
            icon={Brain}
            title="Skrining Jiwa & Kesimpulan"
            colorCls="bg-rose-50 text-rose-700 border-rose-100"
          >
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-4">
              <InfoRow
                label="Tanggal Skrining Jiwa"
                value={fmtDate(lab?.tanggal_skrining_jiwa)}
              />
              <InfoRow
                label="Hasil Skrining Jiwa"
                value={lab?.skrining_jiwa_hasil}
              />
              <InfoRow
                label="Tindak Lanjut"
                value={lab?.skrining_jiwa_tindak_lanjut}
              />
              <div className="flex flex-col gap-1">
                <span className="text-xs font-semibold text-gray-400 uppercase tracking-wide">
                  Perlu Rujukan
                </span>
                {lab?.skrining_jiwa_perlu_rujukan === "Ya" ? (
                  <span className="inline-flex items-center gap-1 text-xs bg-red-100 text-red-700 px-2 py-0.5 rounded-full font-semibold w-fit">
                    <XCircle size={10} /> Ya, Perlu Rujukan
                  </span>
                ) : (
                  <span className="inline-flex items-center gap-1 text-xs bg-emerald-100 text-emerald-700 px-2 py-0.5 rounded-full font-semibold w-fit">
                    <CheckCircle size={10} /> Tidak Perlu
                  </span>
                )}
              </div>
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div className="bg-gray-50 rounded-xl p-4 border border-gray-100">
                <p className="text-xs font-bold text-gray-400 uppercase tracking-wide mb-2">
                  Kesimpulan
                </p>
                <p className="text-sm text-gray-700 leading-relaxed">
                  {lab?.kesimpulan || (
                    <span className="italic text-gray-400">Belum diisi</span>
                  )}
                </p>
              </div>
              <div className="bg-gray-50 rounded-xl p-4 border border-gray-100">
                <p className="text-xs font-bold text-gray-400 uppercase tracking-wide mb-2">
                  Rekomendasi
                </p>
                <p className="text-sm text-gray-700 leading-relaxed">
                  {lab?.rekomendasi || (
                    <span className="italic text-gray-400">Belum diisi</span>
                  )}
                </p>
              </div>
            </div>
          </DetailSection>

          {/* Catatan Pelayanan */}
          <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
            <div className="flex items-center justify-between px-5 py-4 bg-indigo-50 border-b border-indigo-100">
              <div className="flex items-center gap-2 text-indigo-700">
                <StickyNote size={17} />
                <span className="font-semibold text-sm">
                  Catatan Pelayanan Trimester 1
                </span>
                {catatanList.length > 0 && (
                  <span className="bg-indigo-200 text-indigo-800 text-xs font-bold px-2 py-0.5 rounded-full">
                    {catatanList.length}
                  </span>
                )}
              </div>
              <button
                type="button"
                onClick={handleTambahCatatan}
                className="flex items-center gap-1.5 bg-indigo-600 hover:bg-indigo-700 text-white px-3.5 py-1.5 rounded-xl text-xs font-semibold transition shadow-sm"
              >
                <Plus size={14} /> Tambah Catatan
              </button>
            </div>
            <div className="p-5">
              {loadingCatatan ? (
                <div className="flex items-center justify-center py-8 gap-2 text-gray-400">
                  <Loader2 className="animate-spin" size={20} />
                  <span className="text-sm">Memuat catatan...</span>
                </div>
              ) : catatanList.length === 0 ? (
                <div className="flex flex-col items-center justify-center py-10 text-center">
                  <div className="w-14 h-14 bg-indigo-50 rounded-full flex items-center justify-center mb-3">
                    <MessageSquarePlus size={24} className="text-indigo-300" />
                  </div>
                  <p className="text-sm font-medium text-gray-500 mb-1">
                    Belum ada catatan pelayanan
                  </p>
                  <p className="text-xs text-gray-400 mb-4">
                    Tambahkan catatan keluhan, tindakan, atau saran untuk
                    kunjungan ini
                  </p>
                  <button
                    type="button"
                    onClick={handleTambahCatatan}
                    className="flex items-center gap-1.5 bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-xl text-sm font-semibold transition"
                  >
                    <Plus size={15} /> Tambah Catatan Pertama
                  </button>
                </div>
              ) : (
                <div className="space-y-3">
                  {catatanList.map((catatan, idx) => (
                    <div
                      key={catatan.id_catatan}
                      className="group relative bg-gray-50 hover:bg-indigo-50/40 border border-gray-100 hover:border-indigo-200 rounded-2xl p-4 transition-all"
                    >
                      <div className="absolute top-4 left-4 w-6 h-6 bg-indigo-100 text-indigo-700 rounded-full flex items-center justify-center text-xs font-bold">
                        {idx + 1}
                      </div>
                      <div className="ml-9">
                        <div className="flex flex-wrap items-center gap-3 mb-3">
                          {catatan.tanggal_periksa_stamp_paraf && (
                            <div className="flex items-center gap-1.5 text-xs text-indigo-600 bg-indigo-100 px-2.5 py-1 rounded-full font-medium">
                              <Calendar size={11} />
                              {fmtDate(catatan.tanggal_periksa_stamp_paraf)}
                            </div>
                          )}
                          {catatan.tanggal_kembali && (
                            <div className="flex items-center gap-1.5 text-xs text-teal-600 bg-teal-100 px-2.5 py-1 rounded-full font-medium">
                              <CalendarCheck size={11} />
                              Kembali: {fmtDate(catatan.tanggal_kembali)}
                            </div>
                          )}
                        </div>
                        <p className="text-sm text-gray-700 leading-relaxed whitespace-pre-wrap">
                          {catatan.keluhan_pemeriksaan_tindakan_saran || (
                            <span className="italic text-gray-400">
                              Tidak ada isi catatan
                            </span>
                          )}
                        </p>
                      </div>
                      <div className="absolute top-3 right-3 flex gap-1.5 opacity-0 group-hover:opacity-100 transition-opacity">
                        <button
                          type="button"
                          onClick={() => handleEditCatatan(catatan)}
                          className="p-1.5 rounded-lg bg-white border border-amber-200 text-amber-600 hover:bg-amber-50 transition shadow-sm"
                          title="Edit catatan"
                        >
                          <Pencil size={13} />
                        </button>
                        <button
                          type="button"
                          onClick={() =>
                            handleDeleteCatatan(catatan.id_catatan)
                          }
                          className="p-1.5 rounded-lg bg-white border border-red-200 text-red-500 hover:bg-red-50 transition shadow-sm"
                          title="Hapus catatan"
                        >
                          <Trash2 size={13} />
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {modalOpen && (
        <ModalCatatan
          kehamilanId={kehamilan?.id}
          catatan={editCatatan}
          onClose={handleModalClose}
          onSaved={fetchCatatan}
        />
      )}
    </MainLayout>
  );
}