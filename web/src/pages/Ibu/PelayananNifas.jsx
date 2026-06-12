// src/pages/Ibu/PelayananNifas.jsx
import React, { useEffect, useState } from "react";
import { useParams, useNavigate, Link } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import { getKehamilanByIbuId, updateStatusKehamilan } from "../../services/kehamilan";
import { getNifasByKehamilanId, createNifas, updateNifas } from "../../services/nifas";
import { 
  getCatatanNifasByKehamilanId, 
  createCatatanNifas, 
  updateCatatanNifas, 
  deleteCatatanNifas 
} from "../../services/catatanNifas";
import Swal from "sweetalert2";
import { Save, ArrowLeft, Edit2, CheckCircle, FileText, X, Trash2, Plus, Home, AlertCircle, EyeOff } from "lucide-react";

// ============================================================
// KOMPONEN EMPTY STATE
// ============================================================
const EmptyState = ({ title, message, onAdd }) => (
  <div className="bg-white rounded-xl shadow-sm p-8 text-center">
    <div className="flex flex-col items-center gap-4">
      <div className="p-4 bg-indigo-50 rounded-full">
        <Plus size={40} className="text-indigo-400" />
      </div>
      <h3 className="text-xl font-semibold text-gray-800">{title}</h3>
      <p className="text-gray-500 max-w-md">{message}</p>
      <button
        onClick={onAdd}
        className="bg-indigo-600 text-white px-6 py-2.5 rounded-lg font-semibold flex items-center gap-2 hover:bg-indigo-700 transition"
      >
        <Plus size={18} /> Tambah Data
      </button>
    </div>
  </div>
);

// ============================================================
// KOMPONEN MODAL CATATAN
// ============================================================
const ModalCatatan = ({ isOpen, onClose, catatanData, onSave, onDelete, kunjunganLabel, saving }) => {
  const [formCatatan, setFormCatatan] = useState({
    tanggal_periksa_stamp_paraf: "",
    keluhan_pemeriksaan_tindakan_saran: "",
    tanggal_kembali: "",
  });

  useEffect(() => {
    if (catatanData) {
      setFormCatatan({
        tanggal_periksa_stamp_paraf: catatanData.tanggal_periksa_stamp_paraf || "",
        keluhan_pemeriksaan_tindakan_saran: catatanData.keluhan_pemeriksaan_tindakan_saran || "",
        tanggal_kembali: catatanData.tanggal_kembali || "",
      });
    } else {
      setFormCatatan({
        tanggal_periksa_stamp_paraf: new Date().toISOString().split("T")[0],
        keluhan_pemeriksaan_tindakan_saran: "",
        tanggal_kembali: "",
      });
    }
  }, [catatanData, isOpen]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormCatatan(prev => ({ ...prev, [name]: value }));
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
      <div className="bg-white rounded-xl shadow-xl w-full max-w-2xl mx-4">
        <div className="flex justify-between items-center p-4 border-b">
          <h3 className="text-lg font-semibold text-gray-900">
            {catatanData ? "Edit" : "Tambah"} Catatan Pelayanan Nifas - {kunjunganLabel}
          </h3>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <X size={20} />
          </button>
        </div>
        
        <div className="p-4 space-y-4">
          <div>
            <label className="block text-sm font-medium mb-1">
              Tanggal Periksa / Stamp / Paraf <span className="text-red-500">*</span>
            </label>
            <input
              type="date"
              name="tanggal_periksa_stamp_paraf"
              value={formCatatan.tanggal_periksa_stamp_paraf}
              onChange={handleChange}
              className="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
              required
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium mb-1">
              Keluhan / Pemeriksaan / Tindakan / Saran
            </label>
            <textarea
              name="keluhan_pemeriksaan_tindakan_saran"
              value={formCatatan.keluhan_pemeriksaan_tindakan_saran}
              onChange={handleChange}
              rows={6}
              placeholder="Catatan keluhan ibu, hasil pemeriksaan, tindakan yang dilakukan, dan saran yang diberikan..."
              className="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500 resize-none"
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium mb-1">
              Tanggal Kembali (Kontrol Ulang)
            </label>
            <input
              type="date"
              name="tanggal_kembali"
              value={formCatatan.tanggal_kembali}
              onChange={handleChange}
              className="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
            />
            <p className="text-xs text-gray-500 mt-1">
              Kosongkan jika tidak ada jadwal kontrol
            </p>
          </div>
        </div>
        
        <div className="flex justify-between gap-2 p-4 border-t">
          {catatanData && (
            <button
              onClick={() => onDelete(catatanData.id_catatan_nifas)}
              className="px-4 py-2 text-red-600 border border-red-300 rounded-lg hover:bg-red-50 flex items-center gap-2"
              disabled={saving}
            >
              <Trash2 size={16} />
              Hapus
            </button>
          )}
          <div className="flex gap-2 ml-auto">
            <button
              onClick={onClose}
              className="px-4 py-2 text-gray-600 border border-gray-300 rounded-lg hover:bg-gray-50"
              disabled={saving}
            >
              Batal
            </button>
            <button
              onClick={() => onSave(formCatatan)}
              disabled={saving}
              className="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 disabled:opacity-50 flex items-center gap-2"
            >
              <Save size={16} />
              {saving ? "Menyimpan..." : "Simpan Catatan"}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

// ============================================================
// KOMPONEN CARD RIWAYAT CATATAN
// ============================================================
const RiwayatCatatanCard = ({ catatan, onEdit, onDelete }) => {
  return (
    <div className="bg-white border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow">
      <div className="flex justify-between items-start">
        <div className="flex-1">
          <div className="flex items-center gap-2 mb-2">
            <FileText size={16} className="text-blue-500" />
            <span className="text-xs font-medium text-blue-600 bg-blue-50 px-2 py-0.5 rounded-full">
              {catatan.tanggal_periksa_stamp_paraf}
            </span>
          </div>
          <p className="text-sm text-gray-700 whitespace-pre-wrap">
            {catatan.keluhan_pemeriksaan_tindakan_saran}
          </p>
          {catatan.tanggal_kembali && (
            <p className="text-xs text-gray-500 mt-2 flex items-center gap-1">
              <span>📅 Kontrol kembali:</span>
              <span className="font-medium">{catatan.tanggal_kembali}</span>
            </p>
          )}
        </div>
        <div className="flex gap-1 ml-2">
          <button
            onClick={() => onEdit(catatan)}
            className="p-1 text-gray-400 hover:text-indigo-600 transition-colors"
            title="Edit catatan"
          >
            <Edit2 size={16} />
          </button>
          <button
            onClick={() => onDelete(catatan.id_catatan_nifas)}
            className="p-1 text-gray-400 hover:text-red-600 transition-colors"
            title="Hapus catatan"
          >
            <Trash2 size={16} />
          </button>
        </div>
      </div>
    </div>
  );
};

// ============================================================
// KOMPONEN DAFTAR RIWAYAT CATATAN
// ============================================================
const DaftarRiwayatCatatan = ({ catatanList, onEdit, onDelete, kunjunganLabel }) => {
  if (!catatanList || catatanList.length === 0) {
    return (
      <div className="bg-gray-50 rounded-lg p-6 text-center">
        <FileText size={32} className="text-gray-300 mx-auto mb-2" />
        <p className="text-sm text-gray-500">Belum ada catatan untuk kunjungan {kunjunganLabel}</p>
        <p className="text-xs text-gray-400 mt-1">Klik tombol "Tambah Catatan" untuk menambahkan</p>
      </div>
    );
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-2 mb-3">
        <FileText size={18} className="text-gray-500" />
        <h3 className="text-md font-semibold text-gray-700">Riwayat Catatan</h3>
        <span className="text-xs text-gray-400">({catatanList.length} catatan)</span>
      </div>
      <div className="space-y-3">
        {catatanList.map((catatan) => (
          <RiwayatCatatanCard
            key={catatan.id_catatan_nifas}
            catatan={catatan}
            onEdit={onEdit}
            onDelete={onDelete}
          />
        ))}
      </div>
    </div>
  );
};

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
const DetailNifas = ({ data, onEdit, onOpenCatatan, kunjunganLabel }) => (
  <div className="bg-white rounded-xl shadow-sm p-6 space-y-5">
    <div className="flex justify-between items-center">
      <div className="flex items-center gap-2 text-green-600">
        <CheckCircle size={20} />
        <h2 className="text-lg font-semibold text-gray-800">
          Data Pelayanan Nifas - {kunjunganLabel}
        </h2>
      </div>
      <div className="flex gap-2">
        <button 
          onClick={onOpenCatatan}
          className="flex items-center gap-2 text-sm text-blue-600 border border-blue-300 px-3 py-1.5 rounded-lg hover:bg-blue-50"
        >
          <Plus size={14} /> Tambah Catatan
        </button>
        <button 
          onClick={onEdit}
          className="flex items-center gap-2 text-sm text-indigo-600 border border-indigo-300 px-3 py-1.5 rounded-lg hover:bg-indigo-50"
        >
          <Edit2 size={14} /> Edit Data
        </button>
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
      <DetailItem label="Nama Pemeriksa/Paraf" value={data.nama_pemeriksa_paraf} />
      <DetailItem label="Tanggal Kembali" value={data.tanggal_kembali} />
    </div>
  </div>
);

export default function PelayananNifas() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [kehamilan, setKehamilan] = useState(null);
  const [nifas, setNifas] = useState([]);
  const [catatanList, setCatatanList] = useState([]);
  const [mode, setMode] = useState("empty"); // "empty", "form", "detail"
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [savingCatatan, setSavingCatatan] = useState(false);
  const [selectedKunjungan, setSelectedKunjungan] = useState("KF1");
  const [currentData, setCurrentData] = useState(null);
  const [selectedCatatan, setSelectedCatatan] = useState(null);
  const [isModalCatatanOpen, setIsModalCatatanOpen] = useState(false);
  
  // ========== TAMBAHKAN STATE INI ==========
  const [canAccessNifas, setCanAccessNifas] = useState(false);
  const [accessMessage, setAccessMessage] = useState("");
  
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
    nama_pemeriksa_paraf: "",
    tanggal_kembali: "",
  });

  // Filter catatan berdasarkan kunjungan yang dipilih
  const catatanForSelectedKunjungan = catatanList.filter((c) => c.kunjungan_ke === selectedKunjungan);

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
      nama_pemeriksa_paraf: "",
      tanggal_kembali: "",
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

            // ========== CEK STATUS AKSES ==========
        const allowed = isAllowedStatus(aktif.status_kehamilan);
        setCanAccessNifas(allowed);
        
        if (!allowed) {
          setAccessMessage(getAccessMessage(aktif.status_kehamilan));
          setLoading(false);
          return;
        }
        // =====================================
          
          const dataNifas = await getNifasByKehamilanId(aktif.id);
          const nifasArray = Array.isArray(dataNifas) ? dataNifas : [];
          setNifas(nifasArray);
          
          const dataCatatan = await getCatatanNifasByKehamilanId(aktif.id);
          const catatanArray = Array.isArray(dataCatatan) ? dataCatatan : [];
          setCatatanList(catatanArray);
          
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
  // ====================================

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

  const handleOpenTambahCatatan = () => {
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
  // ====================================
    setSelectedCatatan(null);
    setIsModalCatatanOpen(true);
  };

  const handleEditCatatan = (catatan) => {
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
  // ====================================

    setSelectedCatatan(catatan);
    setIsModalCatatanOpen(true);
  };

  // Fungsi untuk menyimpan catatan
  const handleSaveCatatan = async (catatanForm) => {
    if (!kehamilan) {
      Swal.fire({
        icon: 'error',
        title: 'Error',
        text: 'Data kehamilan tidak ditemukan!'
      });
      return;
    }
    
    setSavingCatatan(true);
    try {
      const payload = {
        kehamilan_id: kehamilan.id,
        kunjungan_ke: selectedKunjungan,
        tanggal_periksa_stamp_paraf: catatanForm.tanggal_periksa_stamp_paraf,
        keluhan_pemeriksaan_tindakan_saran: catatanForm.keluhan_pemeriksaan_tindakan_saran,
        tanggal_kembali: catatanForm.tanggal_kembali || null,
      };
      
      delete payload.id_catatan_nifas;
      delete payload.id;
      
      if (selectedCatatan && selectedCatatan.id_catatan_nifas) {
        await updateCatatanNifas(selectedCatatan.id_catatan_nifas, payload);
      } else {
        await createCatatanNifas(payload);
      }
      
      // Refresh data
      const dataCatatan = await getCatatanNifasByKehamilanId(kehamilan.id);
      setCatatanList(dataCatatan);
      
      alert("Catatan berhasil disimpan!");
      setIsModalCatatanOpen(false);
      setSelectedCatatan(null);
      
    } catch (err) {
      console.error("Error:", err);
      alert("Gagal menyimpan catatan: " + (err.response?.data?.message || err.message));
    } finally {
      setSavingCatatan(false);
    }
  };
  
  // Fungsi untuk menghapus catatan
  const handleDeleteCatatan = async (idCatatan) => {
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
  // ====================================
    if (!confirm("Apakah Anda yakin ingin menghapus catatan ini?")) return;
    
    setSavingCatatan(true);
    try {
      await deleteCatatanNifas(idCatatan);
      setCatatanList(prev => prev.filter(c => c.id_catatan_nifas !== idCatatan));
      alert("Catatan berhasil dihapus!");
      setIsModalCatatanOpen(false);
      setSelectedCatatan(null);
    } catch (err) {
      console.error("Error menghapus catatan:", err);
      alert("Gagal menghapus catatan");
    } finally {
      setSavingCatatan(false);
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
  // ====================================

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

  const handleKunjunganChange = (kunjungan) => {
    setSelectedKunjungan(kunjungan);
    
    const existingNifas = nifas.find((n) => n.kunjungan_ke === kunjungan);
    
    if (existingNifas) {
      setCurrentData(existingNifas);
      setMode("detail");
      populateForm(existingNifas);
    } else {
      setCurrentData(null);
      setMode("empty");
      resetForm(kunjungan);
    }
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
          <button onClick={() => navigate(-1)} className="p-2 rounded-full hover:bg-gray-100 transition-colors">
            <ArrowLeft size={20} />
          </button>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Pelayanan Nifas</h1>
            <p className="text-gray-500">Pencatatan pelayanan masa nifas ibu.</p>
          </div>
        </div>
        
          {/* Banner Peringatan jika tidak dapat akses */}
      {!canAccessNifas && kehamilan && (
        <div className="mb-6 bg-yellow-50 border-l-4 border-yellow-500 p-4 rounded-r-lg">
          <div className="flex items-start gap-3">
            <div className="flex-shrink-0">
              <AlertCircle size={20} className="text-yellow-600" />
            </div>
            <div>
              <p className="text-sm font-semibold text-yellow-800">
                ⚠️ Akses Pelayanan Nifas Dibatasi
              </p>
              <p className="text-sm text-yellow-700 mt-1">{accessMessage}</p>
              <p className="text-xs text-yellow-600 mt-2">
                Status kehamilan saat ini: <strong>{kehamilan.status_kehamilan}</strong>
              </p>
            </div>
          </div>
        </div>
      )}
       {/* Banner Info untuk status NIFAS */}
      {canAccessNifas && kehamilan && kehamilan.status_kehamilan === "NIFAS" && (
        <div className="mb-6 bg-green-50 border-l-4 border-green-500 p-4 rounded-r-lg">
          <div className="flex items-start gap-3">
            <div className="flex-shrink-0">
              <CheckCircle size={20} className="text-green-600" />
            </div>
            <div>
              <p className="text-sm font-semibold text-green-800">✅ Status Kehamilan: NIFAS</p>
              <p className="text-sm text-green-700 mt-1">Ibu sedang dalam masa nifas. Anda dapat melakukan pencatatan pelayanan nifas.</p>
            </div>
          </div>
        </div>
      )}
       {/* Banner Info untuk status NON-AKTIF */}
      {canAccessNifas && kehamilan && kehamilan.status_kehamilan === "NON-AKTIF" && (
        <div className="mb-6 bg-blue-50 border-l-4 border-blue-500 p-4 rounded-r-lg">
          <div className="flex items-start gap-3">
            <div className="flex-shrink-0">
              <FileText size={20} className="text-blue-600" />
            </div>
            <div>
              <p className="text-sm font-semibold text-blue-800">📋 Status Kehamilan: NON-AKTIF (Selesai)</p>
              <p className="text-sm text-blue-700 mt-1">Masa nifas telah selesai. Anda masih dapat melihat data pelayanan nifas yang sudah tercatat.</p>
            </div>
          </div>
        </div>
      )}
      
        {/* Tampilan jika tidak dapat akses */}
      {!canAccessNifas && (
        <div className="bg-white rounded-xl shadow-sm p-12 text-center">
          <div className="w-20 h-20 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <EyeOff size={40} className="text-gray-400" />
          </div>
          <h2 className="text-xl font-semibold text-gray-700 mb-2">Akses Tidak Diizinkan</h2>
          <p className="text-gray-500 max-w-md mx-auto">
            {accessMessage || "Pelayanan Nifas hanya dapat diakses setelah ibu melahirkan (status NIFAS)."}
          </p>
          <button
            onClick={() => navigate(`/data-ibu/${id}`)}
            className="mt-6 bg-indigo-600 text-white px-6 py-2 rounded-lg hover:bg-indigo-700 transition"
          >
            Kembali ke Detail Ibu
          </button>
        </div>
      )}
         {canAccessNifas && (
          <>
        {/* Tombol Pilih Kunjungan */}
        <div className="flex gap-2 mb-6 flex-wrap">
          {["KF1", "KF2", "KF3", "KF4"].map((k) => {
            const hasData = nifas.some((n) => n.kunjungan_ke === k);
            const hasCatatan = catatanList.some((c) => c.kunjungan_ke === k);
            const kunjunganLabel = k === "KF1" ? "6-48 Jam" : k === "KF2" ? "3-7 Hari" : k === "KF3" ? "8-28 Hari" : "29-42 Hari";
            
            return (
              <button 
                key={k} 
                type="button"
                onClick={() => handleKunjunganChange(k)} 
                className={`px-4 py-2 rounded-lg transition-colors flex items-center gap-2 ${
                  selectedKunjungan === k 
                    ? "bg-indigo-600 text-white" 
                    : hasData 
                      ? "bg-green-100 text-green-700 border border-green-300" 
                      : "bg-gray-100 text-gray-700"
                }`}
              >
                {kunjunganLabel}
                {hasData && selectedKunjungan !== k && <CheckCircle size={14} />}
                {hasCatatan && selectedKunjungan !== k && (
                  <FileText size={12} className="text-blue-500" />
                )}
              </button>
            );
          })}
        </div>
        
        {/* Tampilan berdasarkan mode */}
        {mode === "empty" && (
          <EmptyState
            title={`Belum Ada Data Pelayanan Nifas - ${getKunjunganLabel()}`}
            message="Silakan isi data pelayanan nifas untuk kunjungan ini."
            onAdd={() => setMode("form")}
          />
        )}
        
        {mode === "form" && (
          <form onSubmit={handleSubmit} className="bg-white rounded-xl shadow-sm p-6 space-y-4">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-lg font-semibold text-indigo-700">
                Form Pelayanan Nifas - {getKunjunganLabel()}
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
                <label className="block text-sm font-medium mb-1">Tanggal Periksa</label>
                <input 
                  type="date" 
                  name="tanggal_periksa" 
                  value={form.tanggal_periksa} 
                  onChange={handleChange} 
                  className="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500" 
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Tekanan Darah</label>
                <input 
                  name="tanda_vital_tekanan_darah" 
                  value={form.tanda_vital_tekanan_darah} 
                  onChange={handleChange} 
                  placeholder="Contoh: 120/80"
                  className="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500" 
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Suhu Tubuh (°C)</label>
                <input 
                  type="number" 
                  step="0.1" 
                  name="tanda_vital_suhu_tubuh" 
                  value={form.tanda_vital_suhu_tubuh} 
                  onChange={handleChange} 
                  placeholder="Contoh: 36.5"
                  className="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500" 
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Involusi Uteri</label>
                <select 
                  name="pelayanan_involusi_uteri" 
                  value={form.pelayanan_involusi_uteri} 
                  onChange={handleChange}
                  className="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
                >
                  <option value="">-- Pilih --</option>
                  <option value="baik">Baik (normal)</option>
                  <option value="lambat">Lambat (subinvolusi)</option>
                  <option value="cepat">Cepat</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Cairan Pervaginam (Lochia)</label>
                <select 
                  name="pelayanan_cairan_pervaginam" 
                  value={form.pelayanan_cairan_pervaginam} 
                  onChange={handleChange}
                  className="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
                >
                  <option value="">-- Pilih --</option>
                  <option value="normal">Normal (tidak berbau)</option>
                  <option value="sedikit">Sedikit</option>
                  <option value="banyak">Banyak</option>
                  <option value="berbau">Berbau (infeksi)</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Periksa Jalan Lahir</label>
                <select 
                  name="pelayanan_periksa_jalan_lahir" 
                  value={form.pelayanan_periksa_jalan_lahir} 
                  onChange={handleChange}
                  className="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
                >
                  <option value="">-- Pilih --</option>
                  <option value="normal">Normal (baik)</option>
                  <option value="laserasi">Laserasi/jahitan</option>
                  <option value="infeksi">Infeksi</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Periksa Payudara</label>
                <select 
                  name="pelayanan_periksa_payudara" 
                  value={form.pelayanan_periksa_payudara} 
                  onChange={handleChange}
                  className="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
                >
                  <option value="">-- Pilih --</option>
                  <option value="normal">Normal</option>
                  <option value="bengkak">Bengkak</option>
                  <option value="lecet">Puting lecet</option>
                  <option value="asi_keluar">ASI keluar lancar</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">ASI Eksklusif</label>
                <select 
                  name="pelayanan_asi_eksklusif" 
                  value={form.pelayanan_asi_eksklusif} 
                  onChange={handleChange}
                  className="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
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
                  className="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500" 
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Skrining Depresi Nifas</label>
                <select 
                  name="pelayanan_skrining_depresi_nifas" 
                  value={form.pelayanan_skrining_depresi_nifas} 
                  onChange={handleChange}
                  className="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
                >
                  <option value="">-- Pilih --</option>
                  <option value="negatif">Negatif (skor &lt; 10)</option>
                  <option value="positif_ringan">Positif Ringan (skor 10-12)</option>
                  <option value="positif_berat">Positif Berat (skor &gt; 13)</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Kontrasepsi Pasca Persalinan (KB)</label>
                <select 
                  name="pelayanan_kontrasepsi_pasca_persalinan" 
                  value={form.pelayanan_kontrasepsi_pasca_persalinan} 
                  onChange={handleChange}
                  className="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
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
                <label className="block text-sm font-medium mb-1">Penanganan Risiko Malaria</label>
                <select 
                  name="pelayanan_penanganan_risiko_malaria" 
                  value={form.pelayanan_penanganan_risiko_malaria} 
                  onChange={handleChange}
                  className="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
                >
                  <option value="">-- Pilih --</option>
                  <option value="tidak">Tidak</option>
                  <option value="kelambu">Menggunakan kelambu</option>
                  <option value="obat">Mendapat profilaksis</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Komplikasi Nifas</label>
                <select 
                  name="komplikasi_nifas" 
                  value={form.komplikasi_nifas} 
                  onChange={handleChange}
                  className="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
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
                <label className="block text-sm font-medium mb-1">Tindakan/Saran</label>
                <textarea 
                  name="tindakan_saran" 
                  value={form.tindakan_saran} 
                  onChange={handleChange} 
                  rows="2"
                  placeholder="Contoh: Istirahat cukup, konsumsi makanan bergizi, perbanyak ASI"
                  className="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500" 
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Nama Pemeriksa/Paraf</label>
                <input 
                  name="nama_pemeriksa_paraf" 
                  value={form.nama_pemeriksa_paraf} 
                  onChange={handleChange} 
                  placeholder="dr. Siti Aminah"
                  className="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500" 
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
              onOpenCatatan={handleOpenTambahCatatan}
              kunjunganLabel={getKunjunganLabel()}
            />
            
            <div className="bg-white rounded-xl shadow-sm p-6">
              <DaftarRiwayatCatatan 
                catatanList={catatanForSelectedKunjungan}
                onEdit={handleEditCatatan}
                onDelete={handleDeleteCatatan}
                kunjunganLabel={getKunjunganLabel()}
              />
            </div>
            
            <ModalCatatan
              isOpen={isModalCatatanOpen}
              onClose={() => {
                setIsModalCatatanOpen(false);
                setSelectedCatatan(null);
              }}
              catatanData={selectedCatatan}
              onSave={handleSaveCatatan}
              onDelete={handleDeleteCatatan}
              kunjunganLabel={getKunjunganLabel()}
              saving={savingCatatan}
            />
          </div>
        )}
          </>
      )}
      </div>
    </MainLayout>
  );
}