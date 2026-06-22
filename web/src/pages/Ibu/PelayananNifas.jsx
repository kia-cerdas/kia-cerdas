// src/pages/Ibu/PelayananNifas.jsx
import React, { useEffect, useState } from "react";
import { useParams, useNavigate, Link } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import { getKehamilanByIbuId, updateStatusKehamilan } from "../../services/kehamilan";
import { getNifasByKehamilanId, createNifas, updateNifas, deleteNifas } from "../../services/nifas";
import { getCurrentUser, isBidanUser, isDokterUser } from "../../services/auth";
import Swal from "sweetalert2";
import { Save, ArrowLeft, Edit2, CheckCircle, X, Plus, Home, AlertCircle, EyeOff, Eye, Lock, Trash2 } from "lucide-react";

// ============================================================
// KOMPONEN EMPTY STATE
// ============================================================
const EmptyState = ({ title, message, onAdd, canEdit, isLocked }) => (
  <div className="bg-white rounded-xl shadow-sm p-8 text-center">
    <div className="flex flex-col items-center gap-4">
      <div className={`p-4 rounded-full ${isLocked ? "bg-gray-100" : "bg-indigo-50"}`}>
        {isLocked ? <Lock size={40} className="text-gray-400" /> : <Plus size={40} className="text-indigo-400" />}
        {isLocked ? (
          <span className="text-gray-400 text-sm font-medium">Terkunci</span>
        ) : (
          <Plus size={40} className="text-indigo-400" />
        )}
      </div>
      <h3 className="text-xl font-semibold text-gray-800">{title}</h3>
      <p className="text-gray-500 max-w-md">{message}</p>
      {isLocked && (
        <p className="text-sm text-gray-500 mt-2">
          Data belum tersedia karena belum memasuki masa yang sesuai
        </p>
      )}
      {!isLocked && canEdit && (
        <button
          onClick={onAdd}
          className="bg-indigo-600 text-white px-6 py-2.5 rounded-lg font-semibold flex items-center gap-2 hover:bg-indigo-700 transition"
        >
          <Plus size={18} /> Tambah Data
        </button>
      )}
      {!isLocked && !canEdit && (
        <p className="text-xs text-gray-400 mt-2">Hanya Bidan yang dapat menambahkan data Pelayanan Nifas.</p>
      )}
    </div>
  </div>
);


// ============================================================
// KOMPONEN DETAIL ITEM
// ============================================================
const DetailItem = ({ label, value }) => (
  <div className="flex flex-col">
    <span className="text-xs text-gray-500 font-medium uppercase tracking-wide">{label}</span>
    <span className="text-sm text-gray-800 font-semibold mt-0.5">{value ?? "-"}</span>
  </div>
);

// ============================================================
// KOMPONEN DETAIL NIFAS
// ============================================================
const DetailNifas = ({ data, onEdit, onDelete, kunjunganLabel, canEdit }) => (
  <div className="bg-white rounded-xl shadow-sm p-5 space-y-5">
    <div className="flex justify-between items-center">
      <div className="flex items-center gap-2 text-green-600">
        <CheckCircle size={20} />
        <h2 className="text-lg font-semibold text-gray-800">
          Data Pelayanan Nifas {kunjunganLabel}
        </h2>
      </div>
      <div className="flex gap-2">
        {canEdit && (
          <>
            <button 
              onClick={onEdit}
              className="flex items-center gap-2 text-sm text-indigo-600 border border-indigo-300 px-3 py-1.5 rounded-lg hover:bg-indigo-50"
            >
              <Edit2 size={14} /> Edit Data
            </button>
            <button 
              onClick={onDelete}
              className="flex items-center gap-2 text-sm text-red-600 border border-red-300 px-3 py-1.5 rounded-lg hover:bg-red-50"
            >
              <Trash2 size={14} /> Hapus Data
            </button>
          </>
        )}
      </div>
    </div>
    
    <div className="grid grid-cols-1 md:grid-cols-2 gap-5 bg-gray-50 rounded-lg p-4">
      <DetailItem label="Tanggal Periksa" value={data.tanggal_periksa} />
      <DetailItem label="Tekanan Darah" value={data.tanda_vital_tekanan_darah} />
      <DetailItem label="Suhu Tubuh" value={data.tanda_vital_suhu_tubuh ? `${data.tanda_vital_suhu_tubuh} °C` : "-"} />
      <DetailItem label="Involusi Uteri" value={data.pelayanan_involusi_uteri} />
      <DetailItem label="Cairan Pervaginam" value={data.pelayanan_cairan_pervaginam} />
      <DetailItem label="Periksa Jalan Lahir" value={data.pelayanan_periksa_jalan_lahir} />
      <DetailItem label="Periksa Payudara" value={data.pelayanan_periksa_payudara} />
      <DetailItem label="ASI Eksklusif" value={data.pelayanan_asi_eksklusif} />
      <DetailItem label="Vitamin A" value={data.pemberian_kapsul_vitamin_a ? "Sudah diberikan" : "Belum diberikan"} />
      <DetailItem label="Tablet Tambah Darah" value={data.pemberian_tablet_tambah_darah_jumlah ? `${data.pemberian_tablet_tambah_darah_jumlah} tablet` : "-"} />
      <DetailItem label="Skrining Depresi Nifas" value={data.pelayanan_skrining_depresi_nifas} />
      <DetailItem label="Kontrasepsi Pasca Persalinan" value={data.pelayanan_kontrasepsi_pasca_persalinan} />
      <DetailItem label="Penanganan Risiko Malaria" value={data.pelayanan_penanganan_risiko_malaria} />
      <DetailItem label="Komplikasi Nifas" value={data.komplikasi_nifas} />
      <DetailItem label="Tindakan/Saran" value={data.tindakan_saran} />
      <DetailItem label="Keluhan/Pemeriksaan/Tindakan/Saran" value={data.keluhan_pemeriksaan_tindakan_saran} />
      <DetailItem label="Nama Pemeriksa/Paraf" value={data.nama_pemeriksa_paraf} />
      <DetailItem label="Tanggal Kembali" value={data.tanggal_kembali} />
    </div>
  </div>
);

export default function PelayananNifas() {
  const { id } = useParams();
  const navigate = useNavigate();
  
  // Role-based access control
  const user = getCurrentUser();
  const isBidan = isBidanUser(user);
  const isDokter = isDokterUser(user);
  
  // Pelayanan Nifas: bidan mengelola, dokter hanya melihat
  const canEdit = isBidan;
  
  const [kehamilan, setKehamilan] = useState(null);
  const [nifas, setNifas] = useState([]);
  const [mode, setMode] = useState("empty"); // "empty", "form", "detail"
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [selectedKunjungan, setSelectedKunjungan] = useState("KF1");
  const [currentData, setCurrentData] = useState(null);
  
  // ========== TAMBAHKAN STATE INI ==========
  const [canAccessNifas, setCanAccessNifas] = useState(false);
  const [accessMessage, setAccessMessage] = useState("");
  const [tanggalMelahirkan, setTanggalMelahirkan] = useState(null);
  
  // ========== TAMBAHKAN FUNGSI UNTUK CEK AKSES ==========
  const isAllowedStatus = (status) => {
    // Hanya status NIFAS atau NON-AKTIF yang diizinkan untuk akses pelayanan nifas
    return status === "NIFAS" || status === "NON-AKTIF";
  };

   const getAccessMessage = (status) => {
    if (status === "AKTIF") {
      return "Ibu masih dalam masa kehamilan aktif. Pelayanan Nifas hanya dapat diakses setelah ibu melahirkan (status NIFAS). Silakan tunggu hingga ibu memasuki masa nifas.";
    } else if (status === "TRIMESTER 1" || status === "TRIMESTER 2" || status === "TRIMESTER 3") {
      return `Ibu masih dalam masa kehamilan (${status}). Pelayanan Nifas hanya dapat diakses setelah ibu melahirkan dan status kehamilan berubah menjadi NIFAS atau NON-AKTIF.`;
    } else {
      return "Status kehamilan tidak valid untuk mengakses pelayanan nifas.";
    }
  };

  // ========== FUNGSI UNTUK MENENTUKAN STAGE NIFAS SAAT INI ==========
  const getCurrentNifasStage = () => {
    if (!tanggalMelahirkan) return null;

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const birthDate = new Date(tanggalMelahirkan);
    birthDate.setHours(0, 0, 0, 0);
    
    const diffTime = today - birthDate;
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

    if (diffDays <= 2) return "KF1"; // 6-48 Jam
    if (diffDays >= 3 && diffDays <= 7) return "KF2"; // 3-7 Hari
    if (diffDays >= 8 && diffDays <= 28) return "KF3"; // 8-28 Hari
    if (diffDays >= 29 && diffDays <= 42) return "KF4"; // 29-42 Hari
    return null; // Di luar masa nifas
  };

  // ========== FUNGSI CEK APAKAH KUNJUNGAN TERKUNCI ==========
  const isKunjunganLocked = (kunjunganKe) => {
    // Cek apakah kunjungan sudah diisi sebelumnya
    const hasData = nifas.some(n => n.kunjungan_ke === kunjunganKe);
    if (hasData) return false; // Jika sudah ada data, tidak terkunci (bisa dilihat)

    // Jika tidak ada tanggal melahirkan, terkunci
    if (!tanggalMelahirkan) return true;

    // Gunakan canAccessKunjungan untuk menentukan apakah bisa diakses
    return !canAccessKunjungan(kunjunganKe);
  };

  // ========== FUNGSI VALIDASI KUNJUNGAN BERDASARKAN TANGGAL ==========
  const canAccessKunjungan = (kunjunganKe) => {
    if (!tanggalMelahirkan) return true; // Jika tidak ada tanggal melahirkan, izinkan akses

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const birthDate = new Date(tanggalMelahirkan);
    birthDate.setHours(0, 0, 0, 0);
    
    const diffTime = today - birthDate;
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

    // Cek apakah kunjungan sebelumnya sudah diisi
    const previousKunjunganFilled = (kunjungan) => {
      return nifas.some(n => n.kunjungan_ke === kunjungan);
    };

    // Cek apakah masih dalam masa nifas (maksimal 42 hari)
    const isWithinNifasPeriod = diffDays <= 42;

    switch (kunjunganKe) {
      case "KF1": // 6-48 Jam (0-2 hari) - bisa diisi kapan saja selama masih dalam masa nifas
        return isWithinNifasPeriod;
      case "KF2": // 3-7 Hari - bisa diisi jika KF1 sudah diisi dan masih dalam masa nifas
        return previousKunjunganFilled("KF1") && isWithinNifasPeriod;
      case "KF3": // 8-28 Hari - bisa diisi jika KF2 sudah diisi dan masih dalam masa nifas
        return previousKunjunganFilled("KF2") && isWithinNifasPeriod;
      case "KF4": // 29-42 Hari - bisa diisi jika KF3 sudah diisi dan masih dalam masa nifas
        return previousKunjunganFilled("KF3") && isWithinNifasPeriod;
      default:
        return true;
    }
  };

  const getKunjunganAccessMessage = (kunjunganKe) => {
    if (!tanggalMelahirkan) return "";

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const birthDate = new Date(tanggalMelahirkan);
    birthDate.setHours(0, 0, 0, 0);
    
    const diffTime = today - birthDate;
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

    const previousKunjunganFilled = (kunjungan) => {
      return nifas.some(n => n.kunjungan_ke === kunjungan);
    };

    // Cek apakah masih dalam masa nifas (maksimal 42 hari)
    const isWithinNifasPeriod = diffDays <= 42;

    switch (kunjunganKe) {
      case "KF1":
        if (!isWithinNifasPeriod) {
          return `Masa nifas telah selesai (${diffDays} hari sejak melahirkan). Tidak dapat mengisi data.`;
        }
        break;
      case "KF2":
        if (!previousKunjunganFilled("KF1")) {
          return "Harap isi data kunjungan KF1 (6-48 Jam) terlebih dahulu sebelum mengisi kunjungan ini.";
        }
        if (!isWithinNifasPeriod) {
          return `Masa nifas telah selesai (${diffDays} hari sejak melahirkan). Tidak dapat mengisi data.`;
        }
        break;
      case "KF3":
        if (!previousKunjunganFilled("KF2")) {
          return "Harap isi data kunjungan KF2 (3-7 Hari) terlebih dahulu sebelum mengisi kunjungan ini.";
        }
        if (!isWithinNifasPeriod) {
          return `Masa nifas telah selesai (${diffDays} hari sejak melahirkan). Tidak dapat mengisi data.`;
        }
        break;
      case "KF4":
        if (!previousKunjunganFilled("KF3")) {
          return "Harap isi data kunjungan KF3 (8-28 Hari) terlebih dahulu sebelum mengisi kunjungan ini.";
        }
        if (!isWithinNifasPeriod) {
          return `Masa nifas telah selesai (${diffDays} hari sejak melahirkan). Tidak dapat mengisi data.`;
        }
        break;
    }
    return "";
  };

  const [form, setForm] = useState({
    kunjungan_ke: "KF1",
    tanggal_periksa: "",
    tanda_vital_tekanan_darah: "",
    tanda_vital_suhu_tubuh: "",
    pelayanan_involusi_uteri: "",
    pelayanan_cairan_pervaginam: "",
    pelayanan_periksa_jalan_lahir: "",
    pelayanan_periksa_payudara: "",
    pelayanan_asi_eksklusif: "",
    pemberian_kapsul_vitamin_a: false,
    pemberian_tablet_tambah_darah_jumlah: "",
    pelayanan_skrining_depresi_nifas: "",
    pelayanan_kontrasepsi_pasca_persalinan: "",
    pelayanan_penanganan_risiko_malaria: "",
    komplikasi_nifas: "",
    tindakan_saran: "",
    nama_pemeriksa_paraf: user?.name || "",
    tanggal_kembali: "",
    keluhan_pemeriksaan_tindakan_saran: "",
  });


  // Fungsi populate form
  const populateForm = (data) => {
    setForm({
      kunjungan_ke: data.kunjungan_ke,
      tanggal_periksa: data.tanggal_periksa ? new Date(data.tanggal_periksa).toISOString().split("T")[0] : "",
      tanda_vital_tekanan_darah: data.tanda_vital_tekanan_darah || "",
      tanda_vital_suhu_tubuh: data.tanda_vital_suhu_tubuh || "",
      pelayanan_involusi_uteri: data.pelayanan_involusi_uteri || "",
      pelayanan_cairan_pervaginam: data.pelayanan_cairan_pervaginam || "",
      pelayanan_periksa_jalan_lahir: data.pelayanan_periksa_jalan_lahir || "",
      pelayanan_periksa_payudara: data.pelayanan_periksa_payudara || "",
      pelayanan_asi_eksklusif: data.pelayanan_asi_eksklusif || "",
      pemberian_kapsul_vitamin_a: data.pemberian_kapsul_vitamin_a || false,
      pemberian_tablet_tambah_darah_jumlah: data.pemberian_tablet_tambah_darah_jumlah || "",
      pelayanan_skrining_depresi_nifas: data.pelayanan_skrining_depresi_nifas || "",
      pelayanan_kontrasepsi_pasca_persalinan: data.pelayanan_kontrasepsi_pasca_persalinan || "",
      pelayanan_penanganan_risiko_malaria: data.pelayanan_penanganan_risiko_malaria || "",
      komplikasi_nifas: data.komplikasi_nifas || "",
      tindakan_saran: data.tindakan_saran || "",
      nama_pemeriksa_paraf: data.nama_pemeriksa_paraf || "",
      tanggal_kembali: data.tanggal_kembali ? new Date(data.tanggal_kembali).toISOString().split("T")[0] : "",
      keluhan_pemeriksaan_tindakan_saran: data.keluhan_pemeriksaan_tindakan_saran || "",
    });
  };

  const resetForm = (kunjungan) => {
    setForm({
      kunjungan_ke: kunjungan,
      tanggal_periksa: "",
      tanda_vital_tekanan_darah: "",
      tanda_vital_suhu_tubuh: "",
      pelayanan_involusi_uteri: "",
      pelayanan_cairan_pervaginam: "",
      pelayanan_periksa_jalan_lahir: "",
      pelayanan_periksa_payudara: "",
      pelayanan_asi_eksklusif: "",
      pemberian_kapsul_vitamin_a: false,
      pemberian_tablet_tambah_darah_jumlah: "",
      pelayanan_skrining_depresi_nifas: "",
      pelayanan_kontrasepsi_pasca_persalinan: "",
      pelayanan_penanganan_risiko_malaria: "",
      komplikasi_nifas: "",
      tindakan_saran: "",
      nama_pemeriksa_paraf: user?.name || "",
      tanggal_kembali: "",
      keluhan_pemeriksaan_tindakan_saran: "",
    });
  };

  // Breadcrumb component
  // const Breadcrumb = () => {
  //   if (!kehamilan) return null;
  //   return (
  //     <div className="flex items-center gap-2 text-sm text-gray-500 mb-4 flex-wrap">
  //       <Link to="/dashboard" className="hover:text-indigo-600 flex items-center gap-1">
  //         <Home size={14} /> Beranda
  //       </Link>
  //       <span>/</span>
  //       <Link to="/data-ibu" className="hover:text-indigo-600">Data Ibu</Link>
  //       <span>/</span>
  //       <Link to={`/data-ibu/${id}?kehamilan_id=${kehamilan.id}`} className="hover:text-indigo-600">
  //         Detail Ibu
  //       </Link>
  //       <span>/</span>
  //       <span className="text-gray-700 font-medium">Pelayanan Nifas</span>
  //     </div>
  //   );
  // };

  // Fetch data - HANYA SEKALI saat halaman dimuat
  useEffect(() => {
    const fetch = async () => {
      try {
        setLoading(true);
        const kehamilanList = await getKehamilanByIbuId(id);
        if (kehamilanList.length > 0) {
          const aktif = kehamilanList[0];
          setKehamilan(aktif);

          // Set tanggal melahirkan dari data kehamilan
          if (aktif.tanggal_lahir) {
            setTanggalMelahirkan(aktif.tanggal_lahir);
          }

            // ========== CEK STATUS AKSES ==========
        const allowed = isAllowedStatus(aktif.status_kehamilan);
        setCanAccessNifas(allowed);
        
        if (!allowed) {
          setAccessMessage(getAccessMessage(aktif.status_kehamilan));
          setLoading(false);
          return;
        }
        // =====================================

          // Jika status NIFAS tapi tidak ada tanggal_lahir, coba ambil dari ringkasan persalinan
          if (aktif.status_kehamilan === "NIFAS" && !aktif.tanggal_lahir) {
            try {
              const { getRingkasanPersalinanByKehamilanId } = await import("../../services/prosesMelahirkan");
              const ringkasanList = await getRingkasanPersalinanByKehamilanId(aktif.id);
              if (ringkasanList && ringkasanList.length > 0 && ringkasanList[0].tanggal_melahirkan) {
                setTanggalMelahirkan(ringkasanList[0].tanggal_melahirkan);
              }
            } catch (err) {
              console.error("Gagal mengambil tanggal melahirkan dari ringkasan:", err);
            }
          }
          
          const dataNifas = await getNifasByKehamilanId(aktif.id);
          const nifasArray = Array.isArray(dataNifas) ? dataNifas : [];
          setNifas(nifasArray);
          
          // Cek data untuk kunjungan default (KF1)
          const existingNifas = nifasArray.find((n) => n.kunjungan_ke === "KF1");
          
          if (existingNifas) {
            setCurrentData(existingNifas);
            setMode("detail");
            populateForm(existingNifas);
          } else {
            setMode("empty");
            setCurrentData(null);
            resetForm("KF1");
          }
        }
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    };
    fetch();
  }, [id]);

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setForm({ ...form, [name]: type === "checkbox" ? checked : value });
  };

  const handleEdit = () => {
    // ========== VALIDASI AKSES ==========
  if (!canAccessNifas) {
    Swal.fire({
      icon: 'warning',
      title: 'Akses Ditolak',
      text: accessMessage || 'Pelayanan Nifas hanya dapat diakses jika status kehamilan adalah NIFAS atau NON-AKTIF.',
      confirmButtonColor: '#4f46e5'
    });
    return;
  }
  
  if (!canEdit) {
    Swal.fire({
      icon: 'warning',
      title: 'Akses Ditolak',
      text: 'Hanya Bidan yang dapat mengedit data Pelayanan Nifas. Dokter hanya dapat melihat data.',
      confirmButtonColor: '#4f46e5'
    });
    return;
  }
  // ====================================

    // Allow editing of existing data regardless of time period
    // Only restrict NEW data entry based on time
    setMode("form");
  };

  const handleCancel = () => {
    if (currentData) {
      setMode("detail");
      populateForm(currentData);
    } else {
      setMode("empty");
      resetForm(selectedKunjungan);
    }
  };



  

  const handleSubmit = async (e) => {
    e.preventDefault();

     // ========== VALIDASI AKSES ==========
  if (!canAccessNifas) {
    Swal.fire({
      icon: 'warning',
      title: 'Akses Ditolak',
      text: accessMessage || 'Pelayanan Nifas hanya dapat diakses jika status kehamilan adalah NIFAS atau NON-AKTIF.',
      confirmButtonColor: '#4f46e5'
    });
    return;
  }
  
  if (!canEdit) {
    Swal.fire({
      icon: 'warning',
      title: 'Akses Ditolak',
      text: 'Hanya Bidan yang dapat menyimpan data Pelayanan Nifas. Dokter hanya dapat melihat data.',
      confirmButtonColor: '#4f46e5'
    });
    return;
  }
  // ====================================

    // ========== VALIDASI KUNJUNGAN BERDASARKAN TANGGAL ==========
  // Only apply time restrictions for NEW data entry, not for editing existing data
  const existing = nifas.find((n) => n.kunjungan_ke === selectedKunjungan);
  if (!existing && !canAccessKunjungan(selectedKunjungan)) {
    Swal.fire({
      icon: 'warning',
      title: 'Kunjungan Tidak Dapat Diakses',
      text: getKunjunganAccessMessage(selectedKunjungan),
      confirmButtonColor: '#4f46e5'
    });
    return;
  }
  // =========================================================

    // ========== VALIDASI SEMUA FIELD ==========
  const requiredFields = [
    'tanggal_periksa',
    'tanda_vital_tekanan_darah',
    'tanda_vital_suhu_tubuh',
    'pelayanan_involusi_uteri',
    'pelayanan_cairan_pervaginam',
    'pelayanan_periksa_jalan_lahir',
    'pelayanan_periksa_payudara',
    'pelayanan_asi_eksklusif',
    'pelayanan_skrining_depresi_nifas',
    'pelayanan_kontrasepsi_pasca_persalinan',
    'pelayanan_penanganan_risiko_malaria',
    'komplikasi_nifas',
    'tindakan_saran',
    'nama_pemeriksa_paraf',
    'keluhan_pemeriksaan_tindakan_saran'
  ];

  const emptyFields = requiredFields.filter(field => !form[field] || form[field].trim() === '');
  if (emptyFields.length > 0) {
    Swal.fire({
      icon: 'warning',
      title: 'Data Belum Lengkap',
      text: 'Harap isi semua field yang wajib diisi sebelum menyimpan data.',
      confirmButtonColor: '#4f46e5'
    });
    return;
  }
  // ==========================================

    if (!kehamilan) {
      Swal.fire('Error', 'Data kehamilan tidak ditemukan!', 'error');
      return;
    }
    setSaving(true);
    try {
      const payload = {
        kehamilan_id: kehamilan.id,
        kunjungan_ke: form.kunjungan_ke,
        tanggal_periksa: form.tanggal_periksa || null,
        tanda_vital_tekanan_darah: form.tanda_vital_tekanan_darah || "",
        tanda_vital_suhu_tubuh: form.tanda_vital_suhu_tubuh ? parseFloat(form.tanda_vital_suhu_tubuh) : null,
        pelayanan_involusi_uteri: form.pelayanan_involusi_uteri || "",
        pelayanan_cairan_pervaginam: form.pelayanan_cairan_pervaginam || "",
        pelayanan_periksa_jalan_lahir: form.pelayanan_periksa_jalan_lahir || "",
        pelayanan_periksa_payudara: form.pelayanan_periksa_payudara || "",
        pelayanan_asi_eksklusif: form.pelayanan_asi_eksklusif || "",
        pemberian_kapsul_vitamin_a: form.pemberian_kapsul_vitamin_a,
        pemberian_tablet_tambah_darah_jumlah: form.pemberian_tablet_tambah_darah_jumlah ? parseInt(form.pemberian_tablet_tambah_darah_jumlah) : 0,
        pelayanan_skrining_depresi_nifas: form.pelayanan_skrining_depresi_nifas || "",
        pelayanan_kontrasepsi_pasca_persalinan: form.pelayanan_kontrasepsi_pasca_persalinan || "",
        pelayanan_penanganan_risiko_malaria: form.pelayanan_penanganan_risiko_malaria || "",
        komplikasi_nifas: form.komplikasi_nifas || "",
        tindakan_saran: form.tindakan_saran || "",
        nama_pemeriksa_paraf: form.nama_pemeriksa_paraf || "",
        tanggal_kembali: form.tanggal_kembali || null,
        keluhan_pemeriksaan_tindakan_saran: form.keluhan_pemeriksaan_tindakan_saran || "",
      };
      
      Object.keys(payload).forEach(key => {
        if (payload[key] === "" || payload[key] === null || payload[key] === undefined) {
          delete payload[key];
        }
      });
      
      const existing = nifas.find((n) => n.kunjungan_ke === selectedKunjungan);
      
      if (existing) {
        await updateNifas(existing.id, payload);
        await Swal.fire({
          icon: 'success',
          title: 'Diperbarui',
          text: 'Data pelayanan nifas berhasil diperbarui',
          timer: 2000,
          showConfirmButton: false
        });
      } else {
        await createNifas(payload);
        await Swal.fire({
          icon: 'success',
          title: 'Berhasil',
          text: 'Data pelayanan nifas berhasil disimpan',
          timer: 2000,
          showConfirmButton: false
        });
      }
      
      // Refresh data nifas
      const refreshedData = await getNifasByKehamilanId(kehamilan.id);
      const nifasArray = Array.isArray(refreshedData) ? refreshedData : [];
      setNifas(nifasArray);
      
      const newCurrentData = nifasArray.find((n) => n.kunjungan_ke === selectedKunjungan);
      setCurrentData(newCurrentData);
      setMode("detail");
      
      if (newCurrentData) {
        populateForm(newCurrentData);
      }
      // Jika kunjungan KF4 (29-42 hari), ubah status kehamilan menjadi NON-AKTIF
if (selectedKunjungan === "KF4") {
  try {
    await updateStatusKehamilan(kehamilan.id, "NON-AKTIF");
    setKehamilan(prev => ({ ...prev, status_kehamilan: "NON-AKTIF" }));
    await Swal.fire({
      icon: 'success',
      title: 'Status Kehamilan',
      text: 'Kehamilan telah ditandai NON-AKTIF karena masa nifas selesai.',
      timer: 2000,
      showConfirmButton: false
    });
  } catch (err) {
    console.error("Gagal update status kehamilan:", err);
    await Swal.fire({
      icon: 'warning',
      title: 'Perhatian',
      text: 'Data nifas tersimpan, tetapi gagal mengubah status kehamilan menjadi NON-AKTIF. Silakan periksa kembali.',
      confirmButtonText: 'OK'
    });
  }
}
    } catch (err) {
      console.error("Error detail:", err);
      Swal.fire('Gagal Menyimpan', err.response?.data?.message || err.message, 'error');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    // ========== VALIDASI AKSES ==========
    if (!canAccessNifas) {
      Swal.fire({
        icon: 'warning',
        title: 'Akses Ditolak',
        text: accessMessage || 'Pelayanan Nifas hanya dapat diakses jika status kehamilan adalah NIFAS atau NON-AKTIF.',
        confirmButtonColor: '#4f46e5'
      });
      return;
    }

    if (!canEdit) {
      Swal.fire({
        icon: 'warning',
        title: 'Akses Ditolak',
        text: 'Hanya Bidan yang dapat menghapus data Pelayanan Nifas. Dokter hanya dapat melihat data.',
        confirmButtonColor: '#4f46e5'
      });
      return;
    }
    // ====================================

    const result = await Swal.fire({
      title: 'Hapus Data?',
      text: 'Data pelayanan nifas akan dihapus permanen. Apakah Anda yakin?',
      icon: 'warning',
      showCancelButton: true,
      confirmButtonColor: '#ef4444',
      cancelButtonColor: '#6b7280',
      confirmButtonText: 'Ya, Hapus',
      cancelButtonText: 'Batal'
    });

    if (result.isConfirmed) {
      try {
        await deleteNifas(currentData.id);
        
        // Refresh data nifas
        const refreshedData = await getNifasByKehamilanId(kehamilan.id);
        const nifasArray = Array.isArray(refreshedData) ? refreshedData : [];
        setNifas(nifasArray);
        
        // Reset to empty state
        setCurrentData(null);
        setMode("empty");
        resetForm(selectedKunjungan);
        
        await Swal.fire({
          icon: 'success',
          title: 'Terhapus',
          text: 'Data pelayanan nifas berhasil dihapus',
          timer: 2000,
          showConfirmButton: false
        });
      } catch (err) {
        console.error("Error deleting:", err);
        Swal.fire('Gagal Menghapus', err.response?.data?.message || err.message, 'error');
      }
    }
  };

  const handleKunjunganChange = (kunjungan) => {
    const existingNifas = nifas.find((n) => n.kunjungan_ke === kunjungan);
    
    // Allow navigation if:
    // 1. Data already exists (for viewing/editing), OR
    // 2. User is bidan and wants to add new data (subject to time restrictions)
    if (existingNifas) {
      // Allow navigation to view/edit existing data regardless of time period
      setSelectedKunjungan(kunjungan);
      setCurrentData(existingNifas);
      setMode("detail");
      populateForm(existingNifas);
      return;
    }
    
    // For NEW data entry, apply time restrictions
    // ========== VALIDASI KUNJUNGAN BERDASARKAN STAGE ==========
    if (isKunjunganLocked(kunjungan)) {
      const kunjunganLabel = kunjungan === "KF1" ? "6-48 Jam" : kunjungan === "KF2" ? "3-7 Hari" : kunjungan === "KF3" ? "8-28 Hari" : "29-42 Hari";
      const currentStageLabel = getCurrentNifasStage() === "KF1" ? "6-48 Jam" : getCurrentNifasStage() === "KF2" ? "3-7 Hari" : getCurrentNifasStage() === "KF3" ? "8-28 Hari" : getCurrentNifasStage() === "KF4" ? "29-42 Hari" : "Di luar masa nifas";
      
      Swal.fire({
        icon: 'warning',
        title: 'Tahapan Terkunci',
        text: `Data untuk ${kunjunganLabel} masih terkunci. Ibu saat ini berada dalam masa ${currentStageLabel}. Silakan tunggu hingga memasuki masa yang sesuai.`,
        confirmButtonColor: '#4f46e5'
      });
      return;
    }
    // =========================================================

    // ========== VALIDASI KUNJUNGAN BERDASARKAN TANGGAL ==========
    if (!canAccessKunjungan(kunjungan)) {
      Swal.fire({
        icon: 'warning',
        title: 'Kunjungan Tidak Dapat Diakses',
        text: getKunjunganAccessMessage(kunjungan),
        confirmButtonColor: '#4f46e5'
      });
      return;
    }
    // =========================================================

    setSelectedKunjungan(kunjungan);
    setCurrentData(null);
    // Only bidan can switch to empty mode (which allows adding data)
    if (canEdit) {
      setMode("empty");
    } else {
      // For dokter, show empty state but without add button
      setMode("empty");
    }
    resetForm(kunjungan);
  };

  const getKunjunganLabel = () => {
    switch(selectedKunjungan) {
      case "KF1": return "6-48 Jam";
      case "KF2": return "3-7 Hari";
      case "KF3": return "8-28 Hari";
      case "KF4": return "29-42 Hari";
      default: return selectedKunjungan;
    }
  };

  if (loading) {
    return (
      <MainLayout>
        <div className="p-6">Memuat...</div>
      </MainLayout>
    );
  }

  return (
    <MainLayout>
      <div className="p-6 max-w-5xl">
        {/* Breadcrumb */}
        {/* <Breadcrumb /> */}

        <div className="flex items-center gap-4 mb-6">
          <button
            onClick={() => navigate(-1)}
            className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full border border-[#185FA5] text-[#185FA5] text-sm font-semibold hover:bg-[#185FA5]/5 transition"
          >
            <ArrowLeft size={16} />
            Kembali
          </button>
          <div>
            <h1 className="text-[28px] font-bold text-gray-900">Pelayanan Nifas</h1>
            <p className="text-gray-500">Pencatatan pelayanan masa nifas ibu.</p>
          </div>
        </div>
        
          {/* Banner Peringatan jika tidak dapat akses */}
      {!canAccessNifas && kehamilan && (
        <div className="mb-6 bg-[#185FA5]/10 border border-[#185FA5]/20 p-3 rounded-lg text-[#185FA5] text-base flex items-center gap-2">
          <AlertCircle size={16} /> {accessMessage}
        </div>
      )}
       {/* Banner Info untuk status NIFAS */}
      {canAccessNifas && kehamilan && kehamilan.status_kehamilan === "NIFAS" && (
        <div className="mb-6 bg-[#185FA5]/10 border border-[#185FA5]/20 p-3 rounded-lg text-[#185FA5] text-base flex items-center gap-2">
          <CheckCircle size={16} /> Status Kehamilan: NIFAS - Ibu sedang dalam masa nifas. Anda dapat melakukan pencatatan pelayanan nifas.
        </div>
      )}
       {/* Banner Info untuk status NON-AKTIF */}
      {canAccessNifas && kehamilan && kehamilan.status_kehamilan === "NON-AKTIF" && (
        <div className="mb-6 bg-[#185FA5]/10 border border-[#185FA5]/20 p-3 rounded-lg text-[#185FA5] text-base flex items-center gap-2">
          <CheckCircle size={16} /> Status Kehamilan: NON-AKTIF (Selesai) - Masa nifas telah selesai. Anda masih dapat melihat data pelayanan nifas yang sudah tercatat.
        </div>
      )}
      
      {/* Banner Info untuk role Dokter (view-only) */}
      {canAccessNifas && isDokter && (
        <div className="mb-6 bg-[#185FA5]/10 border border-[#185FA5]/20 p-3 rounded-lg text-[#185FA5] text-base flex items-center gap-2">
          <Eye size={16} /> Anda dalam mode baca (Dokter). Data hanya dapat dilihat, tidak dapat diubah.
        </div>
      )}
      
        {/* Tampilan jika belum dapat akses (belum mencapai tahap nifas) */}
      {!canAccessNifas && (
        <div className="bg-white rounded-xl shadow-sm p-12 text-center">
          <div className="w-20 h-20 bg-amber-50 rounded-full flex items-center justify-center mx-auto mb-4">
            <AlertCircle size={40} className="text-amber-500" />
          </div>
          <h2 className="text-[22px] font-semibold text-[#185FA5] mb-2">Pelayanan Nifas Belum Tersedia</h2>
          <p className="text-gray-500 max-w-md mx-auto">
            {accessMessage || "Pelayanan Nifas hanya dapat diakses setelah ibu melahirkan (status NIFAS)."}
          </p>
          <p className="text-sm text-gray-400 max-w-md mx-auto mt-3">
            Halaman ini akan aktif secara otomatis setelah status kehamilan berubah menjadi NIFAS atau NON-AKTIF.
          </p>
          {/* <button
            onClick={() => navigate(`/data-ibu/${id}`)}
            className="mt-6 bg-[#185FA5] text-white rounded-lg px-5 py-2.5 font-semibold flex items-center gap-2 text-base"
          >
            Kembali ke Detail Ibu
          </button> */}
        </div>
      )}
         {canAccessNifas && (
          <>
        {/* Tombol Pilih Kunjungan */}
        <div className="flex gap-2 mb-6 flex-wrap">
          {["KF1", "KF2", "KF3", "KF4"].map((k) => {
            const hasData = nifas.some((n) => n.kunjungan_ke === k);
            const kunjunganLabel = k === "KF1" ? "6-48 Jam" : k === "KF2" ? "3-7 Hari" : k === "KF3" ? "8-28 Hari" : "29-42 Hari";
            const locked = isKunjunganLocked(k);
            const currentStage = getCurrentNifasStage();
            
            // Enable button if:
            // 1. Data already exists (for viewing/editing), OR
            // 2. Not locked (for adding new data)
            const isDisabled = locked && !hasData;
            
            return (
              <button 
                key={k} 
                type="button"
                onClick={() => handleKunjunganChange(k)} 
                disabled={isDisabled}
                className={`px-4 py-2 rounded-lg transition-colors flex items-center gap-2 ${
                  selectedKunjungan === k 
                    ? "bg-indigo-600 text-white" 
                    : hasData 
                      ? "bg-green-100 text-green-700 border border-green-300" 
                      : isDisabled
                        ? "bg-gray-200 text-gray-400 cursor-not-allowed"
                        : "bg-gray-100 text-gray-700"
                }`}
                title={isDisabled ? `Terkunci - Belum memasuki masa ${kunjunganLabel}` : hasData ? `Data tersedia - Klik untuk melihat/edit` : `Klik untuk menambah data`}
              >
                {kunjunganLabel}
                {hasData && selectedKunjungan !== k && <CheckCircle size={14} />}
                {isDisabled && <Lock size={14} />}
              </button>
            );
          })}
        </div>
        
        {/* Banner info untuk stage saat ini */}
        {tanggalMelahirkan && (
          <div className="mb-6 bg-[#185FA5]/10 border-l-4 border-[#185FA5] p-4 rounded-r-lg">
            <div className="flex items-start gap-3">
              <div className="flex-shrink-0">
                <AlertCircle size={20} className="text-[#185FA5]" />
              </div>
              <div>
                <p className="text-sm font-semibold text-[#185FA5]">
                  Masa Nifas Saat Ini: {getCurrentNifasStage() === "KF1" ? "6-48 Jam" : getCurrentNifasStage() === "KF2" ? "3-7 Hari" : getCurrentNifasStage() === "KF3" ? "8-28 Hari" : getCurrentNifasStage() === "KF4" ? "29-42 Hari" : "Di luar masa nifas"}
                </p>
                <p className="text-sm text-[#185FA5]/80 mt-1">
                  Hanya tahapan yang sesuai dengan masa nifas saat ini yang dapat diisi. Tahapan lain akan terkunci hingga waktunya tiba.
                </p>
              </div>
            </div>
          </div>
        )}
        
        {/* Tampilan berdasarkan mode */}
        {mode === "empty" && (
          <EmptyState
            title={`Belum Ada Data Pelayanan Nifas ${getKunjunganLabel()}`}
            message="Silakan isi data pelayanan nifas untuk kunjungan ini."
            onAdd={() => {
              if (isKunjunganLocked(selectedKunjungan)) {
                const kunjunganLabel = getKunjunganLabel();
                const currentStageLabel = getCurrentNifasStage() === "KF1" ? "6-48 Jam" : getCurrentNifasStage() === "KF2" ? "3-7 Hari" : getCurrentNifasStage() === "KF3" ? "8-28 Hari" : getCurrentNifasStage() === "KF4" ? "29-42 Hari" : "Di luar masa nifas";
                Swal.fire({
                  icon: 'warning',
                  title: 'Tahapan Terkunci',
                  text: `Data untuk ${kunjunganLabel} masih terkunci. Ibu saat ini berada dalam masa ${currentStageLabel}. Silakan tunggu hingga memasuki masa yang sesuai.`,
                  confirmButtonColor: '#4f46e5'
                });
                return;
              }
              setMode("form");
            }}
            canEdit={canEdit}
            isLocked={isKunjunganLocked(selectedKunjungan)}
          />
        )}
        
        {mode === "form" && (
          <form onSubmit={handleSubmit} className="bg-white rounded-xl shadow-sm p-6 space-y-4">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-lg font-semibold text-indigo-700">
                Form Pelayanan Nifas {getKunjunganLabel()}
              </h2>
              <div className="flex gap-2">
                {currentData && (
                  <button 
                    type="button"
                    onClick={handleCancel}
                    className="flex items-center gap-2 text-sm text-gray-600 border border-gray-300 px-3 py-1.5 rounded-lg hover:bg-gray-50"
                  >
                    <X size={14} /> Batal
                  </button>
                )}
              </div>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium mb-1">Tanggal Periksa <span className="text-red-500">*</span></label>
                <input 
                  type="date" 
                  name="tanggal_periksa" 
                  value={form.tanggal_periksa} 
                  onChange={handleChange} 
                  className="w-full border rounded-lg px-3 py-2 text-sm focus:ring-indigo-500 focus:border-indigo-500" 
                  required
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Tekanan Darah <span className="text-red-500">*</span></label>
                <input 
                  name="tanda_vital_tekanan_darah" 
                  value={form.tanda_vital_tekanan_darah} 
                  onChange={handleChange} 
                  placeholder="Contoh: 120/80"
                  className="w-full border rounded-lg px-3 py-2 text-sm focus:ring-indigo-500 focus:border-indigo-500" 
                  required
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Suhu Tubuh (°C) <span className="text-red-500">*</span></label>
                <input 
                  type="number" 
                  step="0.1" 
                  name="tanda_vital_suhu_tubuh" 
                  value={form.tanda_vital_suhu_tubuh} 
                  onChange={handleChange} 
                  placeholder="Contoh: 36.5"
                  className="w-full border rounded-lg px-3 py-2 text-sm focus:ring-indigo-500 focus:border-indigo-500" 
                  required
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Involusi Uteri <span className="text-red-500">*</span></label>
                <select 
                  name="pelayanan_involusi_uteri" 
                  value={form.pelayanan_involusi_uteri} 
                  onChange={handleChange}
                  className="w-full border rounded-lg px-3 py-2 text-sm focus:ring-indigo-500 focus:border-indigo-500"
                  required
                >
                  <option value="">-- Pilih --</option>
                  <option value="baik">Baik (normal)</option>
                  <option value="lambat">Lambat (subinvolusi)</option>
                  <option value="cepat">Cepat</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Cairan Pervaginam (Lochia) <span className="text-red-500">*</span></label>
                <select 
                  name="pelayanan_cairan_pervaginam" 
                  value={form.pelayanan_cairan_pervaginam} 
                  onChange={handleChange}
                  className="w-full border rounded-lg px-3 py-2 text-sm focus:ring-indigo-500 focus:border-indigo-500"
                  required
                >
                  <option value="">-- Pilih --</option>
                  <option value="normal">Normal (tidak berbau)</option>
                  <option value="sedikit">Sedikit</option>
                  <option value="banyak">Banyak</option>
                  <option value="berbau">Berbau (infeksi)</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Periksa Jalan Lahir <span className="text-red-500">*</span></label>
                <select 
                  name="pelayanan_periksa_jalan_lahir" 
                  value={form.pelayanan_periksa_jalan_lahir} 
                  onChange={handleChange}
                  className="w-full border rounded-lg px-3 py-2 text-sm focus:ring-indigo-500 focus:border-indigo-500"
                  required
                >
                  <option value="">-- Pilih --</option>
                  <option value="normal">Normal (baik)</option>
                  <option value="laserasi">Laserasi/jahitan</option>
                  <option value="infeksi">Infeksi</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Periksa Payudara <span className="text-red-500">*</span></label>
                <select 
                  name="pelayanan_periksa_payudara" 
                  value={form.pelayanan_periksa_payudara} 
                  onChange={handleChange}
                  className="w-full border rounded-lg px-3 py-2 text-sm focus:ring-indigo-500 focus:border-indigo-500"
                  required
                >
                  <option value="">-- Pilih --</option>
                  <option value="normal">Normal</option>
                  <option value="bengkak">Bengkak</option>
                  <option value="lecet">Puting lecet</option>
                  <option value="asi_keluar">ASI keluar lancar</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">ASI Eksklusif <span className="text-red-500">*</span></label>
                <select 
                  name="pelayanan_asi_eksklusif" 
                  value={form.pelayanan_asi_eksklusif} 
                  onChange={handleChange}
                  className="w-full border rounded-lg px-3 py-2 text-sm focus:ring-indigo-500 focus:border-indigo-500"
                  required
                >
                  <option value="">-- Pilih --</option>
                  <option value="ya">Ya</option>
                  <option value="tidak">Tidak</option>
                  <option value="sebagian">Sebagian</option>
                </select>
              </div>
              
              <div className="flex items-center gap-2">
                <label className="flex items-center gap-2 cursor-pointer">
                  <input 
                    type="checkbox" 
                    name="pemberian_kapsul_vitamin_a" 
                    checked={form.pemberian_kapsul_vitamin_a} 
                    onChange={handleChange} 
                    className="w-4 h-4 text-indigo-600"
                  /> 
                  <span className="text-sm font-medium">Kapsul Vitamin A</span>
                </label>
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Tablet Tambah Darah (jumlah)</label>
                <input 
                  type="number" 
                  name="pemberian_tablet_tambah_darah_jumlah" 
                  value={form.pemberian_tablet_tambah_darah_jumlah} 
                  onChange={handleChange} 
                  placeholder="Jumlah tablet"
                  className="w-full border rounded-lg px-3 py-2 text-sm focus:ring-indigo-500 focus:border-indigo-500" 
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Skrining Depresi Nifas <span className="text-red-500">*</span></label>
                <select 
                  name="pelayanan_skrining_depresi_nifas" 
                  value={form.pelayanan_skrining_depresi_nifas} 
                  onChange={handleChange}
                  className="w-full border rounded-lg px-3 py-2 text-sm focus:ring-indigo-500 focus:border-indigo-500"
                  required
                >
                  <option value="">-- Pilih --</option>
                  <option value="negatif">Negatif (skor &lt; 10)</option>
                  <option value="positif_ringan">Positif Ringan (skor 10-12)</option>
                  <option value="positif_berat">Positif Berat (skor &gt; 13)</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Kontrasepsi Pasca Persalinan (KB) <span className="text-red-500">*</span></label>
                <select 
                  name="pelayanan_kontrasepsi_pasca_persalinan" 
                  value={form.pelayanan_kontrasepsi_pasca_persalinan} 
                  onChange={handleChange}
                  className="w-full border rounded-lg px-3 py-2 text-sm focus:ring-indigo-500 focus:border-indigo-500"
                  required
                >
                  <option value="">-- Pilih --</option>
                  <option value="tidak_ada">Tidak ada</option>
                  <option value="pil">Pil KB</option>
                  <option value="suntik">Suntik (1/3 bulan)</option>
                  <option value="implan">Implan (KB batang)</option>
                  <option value="iud">IUD/AKBK</option>
                  <option value="kondom">Kondom</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Penanganan Risiko Malaria <span className="text-red-500">*</span></label>
                <select 
                  name="pelayanan_penanganan_risiko_malaria" 
                  value={form.pelayanan_penanganan_risiko_malaria} 
                  onChange={handleChange}
                  className="w-full border rounded-lg px-3 py-2 text-sm focus:ring-indigo-500 focus:border-indigo-500"
                  required
                >
                  <option value="">-- Pilih --</option>
                  <option value="tidak">Tidak</option>
                  <option value="kelambu">Menggunakan kelambu</option>
                  <option value="obat">Mendapat profilaksis</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Komplikasi Nifas <span className="text-red-500">*</span></label>
                <select 
                  name="komplikasi_nifas" 
                  value={form.komplikasi_nifas} 
                  onChange={handleChange}
                  className="w-full border rounded-lg px-3 py-2 text-sm focus:ring-indigo-500 focus:border-indigo-500"
                  required
                >
                  <option value="">-- Pilih --</option>
                  <option value="tidak_ada">Tidak ada</option>
                  <option value="perdarahan">Perdarahan postpartum</option>
                  <option value="infeksi">Infeksi nifas</option>
                  <option value="hipertensi">Hipertensi/PE eklampsia</option>
                  <option value="trombosis">Trombosis</option>
                </select>
              </div>
              
              <div className="md:col-span-2">
                <label className="block text-sm font-medium mb-1">Tindakan/Saran <span className="text-red-500">*</span></label>
                <textarea 
                  name="tindakan_saran" 
                  value={form.tindakan_saran} 
                  onChange={handleChange} 
                  rows="2"
                  placeholder="Contoh: Istirahat cukup, konsumsi makanan bergizi, perbanyak ASI"
                  className="w-full border rounded-lg px-3 py-2 text-sm focus:ring-indigo-500 focus:border-indigo-500" 
                  required
                />
              </div>

              <div className="md:col-span-2">
                <label className="block text-sm font-medium mb-1">Keluhan / Pemeriksaan / Tindakan / Saran <span className="text-red-500">*</span></label>
                <textarea 
                  name="keluhan_pemeriksaan_tindakan_saran" 
                  value={form.keluhan_pemeriksaan_tindakan_saran} 
                  onChange={handleChange} 
                  rows="4"
                  placeholder="Catatan keluhan ibu, hasil pemeriksaan, tindakan yang dilakukan, dan saran yang diberikan..."
                  className="w-full border rounded-lg px-3 py-2 text-sm focus:ring-indigo-500 focus:border-indigo-500" 
                  required
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Nama Pemeriksa/Paraf <span className="text-red-500">*</span></label>
                <input 
                  name="nama_pemeriksa_paraf" 
                  value={form.nama_pemeriksa_paraf} 
                  onChange={handleChange} 
                  placeholder="dr. Siti Aminah"
                  className="w-full border rounded-lg px-3 py-2 text-sm focus:ring-indigo-500 focus:border-indigo-500" 
                  required
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Tanggal Kembali (Kontrol Ulang)</label>
                <input 
                  type="date" 
                  name="tanggal_kembali" 
                  value={form.tanggal_kembali} 
                  onChange={handleChange} 
                  className="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500" 
                />
                <p className="text-xs text-gray-500 mt-1">Kosongkan jika tidak ada jadwal kontrol</p>
              </div>
            </div>
            
            <div className="flex gap-3">
              <button 
                type="submit" 
                disabled={saving} 
                className="bg-indigo-600 text-white px-6 py-2 rounded-lg flex items-center gap-2 hover:bg-indigo-700 disabled:opacity-50"
              >
                <Save size={18} /> {saving ? "Menyimpan..." : "Simpan Nifas"}
              </button>
            </div>
          </form>
        )}
        
        {mode === "detail" && currentData && (
          <div className="space-y-6">
            <DetailNifas 
              data={currentData} 
              onEdit={handleEdit}
              onDelete={handleDelete}
              kunjunganLabel={getKunjunganLabel()}
              canEdit={canEdit}
            />
          </div>
        )}
          </>
      )}
      </div>
    </MainLayout>
  );
}