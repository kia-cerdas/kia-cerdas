// src/pages/Ibu/IbuDetail.jsx
import React, { useEffect, useState } from "react";
import { useParams, useSearchParams, Link, useNavigate } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import { getIbuById } from "../../services/ibu";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import { updateStatusKehamilan } from "../../services/kehamilan";
import { getCurrentUser, isDokterUser, isBidanUser } from "../../services/auth";
import { XCircle } from "lucide-react";
import Swal from "sweetalert2";
import { getDokterT1CompleteByKehamilanId } from "../../services/pemeriksaanDokter";
import { 
  ArrowLeft, 
  Users, 
  Heart, 
  Loader2, 
  Calendar, 
  Target, 
  Baby,
  ClipboardList,
  Search,
  Activity,
  FileText,
  AlertTriangle,
  Stethoscope,
  Hospital,
  Droplet,
  UserPlus,
  Info
} from "lucide-react";

// Fungsi helper untuk menghitung usia
const hitungUsia = (tanggalLahir) => {
  if (!tanggalLahir) return 0;
  
  const today = new Date();
  let birthDate;
  
  try {
    birthDate = new Date(tanggalLahir);
    if (isNaN(birthDate.getTime())) return 0;
  } catch (e) {
    return 0;
  }
  
  let age = today.getFullYear() - birthDate.getFullYear();
  const monthDiff = today.getMonth() - birthDate.getMonth();
  
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
    age--;
  }
  
  return age >= 0 ? age : 0;
};

// Fungsi helper untuk format tanggal
const formatTanggal = (dateStr) => {
  if (!dateStr) return "-";
  
  try {
    const date = new Date(dateStr);
    if (isNaN(date.getTime())) return "-";
    
    return date.toLocaleDateString("id-ID", {
      day: "2-digit",
      month: "long",
      year: "numeric"
    });
  } catch (e) {
    return "-";
  }
};

export default function IbuDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const kehamilanId = searchParams.get("kehamilan_id");

  const [ibu, setIbu] = useState(null);
  const [kehamilan, setKehamilan] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const [checkingT1, setCheckingT1] = useState(false);
  const [checkingT3, setCheckingT3] = useState(false);
  const [isDokter, setIsDokter] = useState(false);

  const [nonAktifLoading, setNonAktifLoading] = useState(false);

  // Cek role user saat komponen mount
  useEffect(() => {
    const user = getCurrentUser();
    const dokter = isDokterUser(user);
    setIsDokter(dokter);
  }, []);

const handleNonAktif = async () => {
  const result = await Swal.fire({
    title: "Tandai Abortus?",
    text: "Kehamilan ini akan ditandai sebagai abortus dan dinonaktifkan.",
    icon: "warning",
    showCancelButton: true,
    confirmButtonColor: "#ef4444",
    cancelButtonColor: "#6b7280",
    confirmButtonText: "Ya, Tandai Abortus",
    cancelButtonText: "Batal",
  });

  if (!result.isConfirmed) return;

  setNonAktifLoading(true);
  try {
    await updateStatusKehamilan(kehamilan.id, "NON-AKTIF");
    setKehamilan((prev) => ({ ...prev, status_kehamilan: "NON-AKTIF" }));
    await Swal.fire({
      title: "Berhasil!",
      text: "Kehamilan berhasil ditandai sebagai abortus.",
      icon: "success",
      confirmButtonColor: "#185FA5",
    });
  } catch (err) {
    await Swal.fire({
      title: "Gagal!",
      text: err.response?.data?.message || err.message,
      icon: "error",
      confirmButtonColor: "#185FA5",
    });
  } finally {
    setNonAktifLoading(false);
  }
};

  // Hitung usia kehamilan dari HPHT
  const hitungUsiaKehamilan = (hpht) => {
    if (!hpht) return "? minggu";
    
    try {
      const hphtDate = new Date(hpht);
      const now = new Date();
      
      if (isNaN(hphtDate.getTime())) return "Tanggal tidak valid";
      
      const diffTime = now - hphtDate;
      const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
      
      if (diffDays < 0) return "Belum hamil";
      
      const weeks = Math.floor(diffDays / 7);
      const days = diffDays % 7;
      return `${weeks} minggu ${days} hari`;
    } catch (e) {
      return "? minggu";
    }
  };

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        setError(null);

        // 🔧 PERBAIKAN: getIbuById harus mengembalikan data ibu yang sudah difilter
        const ibuRes = await getIbuById(id);
        console.log("Data ibu response:", ibuRes);
        
        // Handle response dari API
        let ibuData = null;
        if (ibuRes && ibuRes.data) {
          // Jika response memiliki field data
          ibuData = ibuRes.data;
        } else if (ibuRes && !ibuRes.data) {
          // Jika response langsung object ibu
          ibuData = ibuRes;
        }
        
        if (!ibuData) {
          setError("Data ibu tidak ditemukan");
          setIbu(null);
          setLoading(false);
          return;
        }
        
        setIbu(ibuData);

        // Ambil data kehamilan
        const kehamilanRes = await getKehamilanByIbuId(id);
        console.log("Data kehamilan response:", kehamilanRes);
        
        let kehamilanList = [];
        if (kehamilanRes && kehamilanRes.data) {
          kehamilanList = Array.isArray(kehamilanRes.data) ? kehamilanRes.data : [kehamilanRes.data];
        } else if (kehamilanRes && Array.isArray(kehamilanRes)) {
          kehamilanList = kehamilanRes;
        } else if (kehamilanRes && !Array.isArray(kehamilanRes)) {
          kehamilanList = [kehamilanRes];
        }
        
        if (!kehamilanList || kehamilanList.length === 0) {
          setError("Ibu ini belum memiliki data kehamilan.");
          setKehamilan(null);
          return;
        }

        let targetKehamilan = null;
        if (kehamilanId) {
          targetKehamilan = kehamilanList.find((k) => k.id == kehamilanId);
          if (!targetKehamilan) {
            setError(`Kehamilan dengan ID ${kehamilanId} tidak ditemukan.`);
          }
        } else {
          targetKehamilan = kehamilanList[0];
        }
        setKehamilan(targetKehamilan);
      } catch (err) {
        console.error("Error fetching data:", err);
        setError(err.response?.data?.message || err.message || "Gagal memuat data. Silakan coba lagi.");
      } finally {
        setLoading(false);
      }
    };

    if (id) {
      fetchData();
    }
  }, [id, kehamilanId]);

  const handleT1Click = async () => {
    if (!kehamilan) return;
    setCheckingT1(true);
    try {
      const data = await getDokterT1CompleteByKehamilanId(kehamilan.id);
      if (data && data.dokter) {
        navigate(`/data-ibu/${id}/pemeriksaan-dokter-t1-complete/detail?kehamilan_id=${kehamilan.id}`);
      } else {
        navigate(`/data-ibu/${id}/pemeriksaan-dokter-t1-complete/form?kehamilan_id=${kehamilan.id}`);
      }
    } catch (err) {
      console.error(err);
      navigate(`/data-ibu/${id}/pemeriksaan-dokter-t1-complete/form?kehamilan_id=${kehamilan.id}`);
    } finally {
      setCheckingT1(false);
    }
  };

  const handleT3Click = () => {
    if (!kehamilan) return;
    setCheckingT3(true);
    navigate(`/data-ibu/${id}/pemeriksaan-dokter-t3-complete`);
    setCheckingT3(false);
  };

  if (loading) {
    return (
      <MainLayout>
        <div className="min-h-screen flex items-center justify-center bg-[#F7FAFB]">
          <Loader2 className="animate-spin text-[#185FA5]" size={32} />
          <span className="ml-2 text-gray-500">Memuat data...</span>
        </div>
      </MainLayout>
    );
  }

  if (!ibu) {
    return (
      <MainLayout>
        <div className="min-h-screen flex items-center justify-center bg-[#F7FAFB]">
          <div className="text-[#A32D2D] text-sm">Data ibu tidak ditemukan</div>
        </div>
      </MainLayout>
    );
  }

  if (error && !kehamilan) {
    return (
      <MainLayout>
        <div className="min-h-screen bg-[#F7FAFB] p-4">
          <div className="bg-[#FCEBEB] border-l-4 border-[#A32D2D] p-3 mb-3 text-[#791F1F] text-sm">
            {error}
          </div>
          <Link to="/data-ibu" className="text-[#185FA5] flex items-center gap-2 text-sm">
            <ArrowLeft size={16} /> Kembali ke daftar
          </Link>
        </div>
      </MainLayout>
    );
  }

  if (!kehamilan) {
    return (
      <MainLayout>
        <div className="min-h-screen bg-[#F7FAFB] p-4">
          <div className="bg-[#FAEEDA] border-l-4 border-[#BA7517] p-3 text-[#633806] text-sm">
            {error || "Belum ada data kehamilan."}
          </div>
          <Link to="/data-ibu" className="text-[#185FA5] flex items-center gap-2 mt-3 text-sm">
            <ArrowLeft size={16} /> Kembali
          </Link>
        </div>
      </MainLayout>
    );
  }

  // 🔧 PERBAIKAN: Ambil data kependudukan dan suami dari response
  const kependudukan = ibu.kependudukan || {};
  const suami = ibu.suami;
  
  // 🔧 PERBAIKAN: Hitung usia dari tanggal lahir menggunakan fungsi yang sudah dibuat
  const usiaIbu = hitungUsia(kependudukan.tanggal_lahir);
  const tanggalLahirFormatted = formatTanggal(kependudukan.tanggal_lahir);
  const hphtFormatted = formatTanggal(kehamilan.hpht);
  const hplFormatted = formatTanggal(kehamilan.taksiran_persalinan);
  const usiaKehamilan = hitungUsiaKehamilan(kehamilan.hpht);

  const withKehamilan = (path) => `${path}?kehamilan_id=${kehamilan.id}`;

  return (
    <MainLayout>
      <div className="min-h-screen bg-[#F7FAFB]">
        <div className="max-w-7xl mx-auto p-4 space-y-4">
          {/* Header */}
    <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-3">

  {/* Grup kiri */}
  <div className="flex items-center gap-2">
    <Link
      to="/data-ibu"
      className="inline-flex items-center gap-2 px-6 py-3 rounded-full border border-[#185FA5] text-[#185FA5] text-sm font-semibold hover:bg-[#185FA5]/5 transition w-fit"
    >
      <ArrowLeft size={16} />
      <span>Kembali</span>
    </Link>

    {kehamilan.status_kehamilan !== "NON-AKTIF" && (
      <button
        onClick={handleNonAktif}
        disabled={nonAktifLoading}
        className="inline-flex items-center gap-2 px-6 py-3 rounded-full border border-red-400 text-red-500 text-sm font-semibold hover:bg-red-50 transition w-fit disabled:opacity-50"
      >
        <XCircle size={16} />
        {nonAktifLoading ? "Memproses..." : "Tandai Abortus"}
      </button>
    )}

    {kehamilan.status_kehamilan === "NON-AKTIF" && (
      <span className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-red-100 text-red-600 text-sm font-semibold">
        <XCircle size={14} /> Abortus
      </span>
    )}
  </div> 


            <div className="flex flex-wrap gap-2">
              <div className="flex items-center gap-2 bg-white px-4 py-2 rounded-xl shadow-sm text-xs md:text-sm border border-gray-100">
                <Calendar size={16} className="text-[#0F6E56]" />
                <span className="text-gray-700">HPHT: <span className="font-semibold">{hphtFormatted}</span></span>
              </div>
              <div className="flex items-center gap-2 bg-white px-4 py-2 rounded-xl shadow-sm text-xs md:text-sm border border-gray-100">
                <Target size={16} className="text-[#BA7517]" />
                <span className="text-gray-700">HPL: <span className="font-semibold">{hplFormatted}</span></span>
              </div>
              <div className="flex items-center gap-2 bg-[#E1F5EE] px-4 py-2 rounded-xl text-xs md:text-sm border border-[#0F6E56]/20">
                <Baby size={16} className="text-[#085041]" />
                <span className="text-[#085041] font-semibold">Usia: {usiaKehamilan}</span>
              </div>
            </div>
          </div>

          {/* Kartu Identitas Ibu dan Suami */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            {/* Card Data Ibu */}
            <div className="bg-white shadow-sm rounded-xl p-4 border border-gray-100">
              <h2 className="text-base font-semibold text-[#185FA5] flex items-center gap-2 mb-3">
                <Users size={18} /> Data Ibu
              </h2>
              <div className="grid grid-cols-2 gap-y-2 gap-x-3 text-sm">
                <span className="text-gray-500 text-xs">Nama Lengkap</span>
                <span className="font-medium text-gray-800 text-sm">{kependudukan.nama_anggota_keluarga || "-"}</span>
                
                <span className="text-gray-500 text-xs">NIK</span>
                <span className="text-gray-800 text-sm">{kependudukan.nik || "-"}</span>
                
                <span className="text-gray-500 text-xs">Tanggal Lahir</span>
                <span className="text-gray-800 text-sm">
                  {tanggalLahirFormatted}
                  {usiaIbu > 0 && (
                    <span className="ml-1 text-gray-500 text-xs">({usiaIbu} tahun)</span>
                  )}
                  {usiaIbu === 0 && tanggalLahirFormatted !== "-" && (
                    <span className="ml-1 text-yellow-600 text-xs flex items-center gap-1">
                      <Info size={12} /> Periksa tanggal lahir
                    </span>
                  )}
                </span>
                
                <span className="text-gray-500 text-xs">Golongan Darah</span>
                <span className="text-gray-800 text-sm">{kependudukan.golongan_darah || "-"}</span>
                
                <span className="text-gray-500 text-xs">Pekerjaan</span>
                <span className="text-gray-800 text-sm">{kependudukan.pekerjaan || "-"}</span>
                
                <span className="text-gray-500 text-xs">Alamat</span>
                <span className="text-gray-800 text-sm">{kependudukan.dusun || "-"}</span>
                
                {/* <span className="text-gray-500 text-xs">Gravida / Paritas</span>
                <span className="text-gray-800 text-sm">G{ibu.gravida || 0} P{ibu.paritas || 0}</span> */}
              </div>
            </div>

            {/* Card Data Suami */}
            <div className="bg-white shadow-sm rounded-xl p-4 border border-gray-100">
              <h2 className="text-base font-semibold text-[#0F6E56] flex items-center gap-2 mb-3">
                <Heart size={18} /> Data Suami
              </h2>
              {suami ? (
                <div className="grid grid-cols-2 gap-y-2 gap-x-3 text-sm">
                  <span className="text-gray-500 text-xs">Nama Lengkap</span>
                  <span className="font-medium text-gray-800 text-sm">{suami.nama_anggota_keluarga || "-"}</span>
                  
                  <span className="text-gray-500 text-xs">NIK</span>
                  <span className="text-gray-800 text-sm">{suami.nik || "-"}</span>
                  
                  <span className="text-gray-500 text-xs">Pekerjaan</span>
                  <span className="text-gray-800 text-sm">{suami.pekerjaan || "-"}</span>
                  
                  <span className="text-gray-500 text-xs">Golongan Darah</span>
                  <span className="text-gray-800 text-sm">{suami.golongan_darah || "-"}</span>

                  <span className="text-gray-500 text-xs">Alamat</span>
                  <span className="text-gray-800 text-sm">{suami.dusun || "-"}</span>
                </div>
              ) : (
                <div className="text-center py-4 text-gray-400 text-sm italic">
                  Data suami tidak tersedia
                </div>
              )}
            </div>
          </div>

          {/* Jalur Pelayanan KIA - tetap sama */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
            {/* Skrining & Evaluasi */}
            <div className="bg-white shadow-sm rounded-xl overflow-hidden border border-gray-100">
              <div className="bg-transparent px-4 py-3 border-b border-gray-200">
                <h3 className="text-sm font-semibold text-[#185FA5] uppercase tracking-wide flex items-center gap-2">
                  <ClipboardList size={16} /> Skrining & Evaluasi
                </h3>
              </div>
              <div className="p-4 space-y-1">
                <Link 
                  to={withKehamilan(`/data-ibu/${id}/evaluasi-kesehatan`)}
                  className="flex items-center gap-2 w-full text-left p-2.5 rounded-lg hover:bg-gray-50 text-gray-700 text-sm"
                >
                  <Activity size={16} className="text-[#0F6E56] flex-shrink-0" /> Evaluasi Kesehatan
                </Link>
                <Link 
                  to={withKehamilan(`/data-ibu/${id}/skrining-preeklampsia`)}
                  className="flex items-center gap-2 w-full text-left p-2.5 rounded-lg hover:bg-gray-50 text-gray-700 text-sm"
                >
                  <Search size={16} className="text-[#BA7517] flex-shrink-0" /> Skrining Preeklampsia
                </Link>
                <Link 
                  to={withKehamilan(`/data-ibu/${id}/Skrining-Diabetes-Melitus-Gestasional`)}
                  className="flex items-center gap-2 w-full text-left p-2.5 rounded-lg hover:bg-gray-50 text-gray-700 text-sm"
                >
                  <Droplet size={16} className="text-[#185FA5] flex-shrink-0" /> Skrining DMG
                </Link>
              </div>
            </div>

            {/* Pemantauan ANC */}
            <div className="bg-white shadow-sm rounded-xl overflow-hidden border border-gray-100">
              <div className="bg-transparent px-4 py-3 border-b border-gray-200">
                <h3 className="text-sm font-semibold text-[#0F6E56] uppercase tracking-wide flex items-center gap-2">
                  <Stethoscope size={16} /> Pemantauan ANC
                </h3>
              </div>
              <div className="p-4 space-y-1">
                <Link 
                  to={withKehamilan(`/data-ibu/${id}/pemeriksaan-rutin`)}
                  className="flex items-center gap-2 w-full text-left p-2.5 rounded-lg hover:bg-gray-50 text-gray-700 text-sm"
                >
                  <Activity size={16} className="text-[#185FA5] flex-shrink-0" /> Input ANC Rutin
                </Link>
                <div className="flex flex-col gap-1.5 pt-1">
                  <button 
                    onClick={handleT1Click} 
                    disabled={checkingT1}
                    className="w-full flex items-center justify-center gap-2 p-2.5 rounded-lg border border-[#185FA5] text-[#185FA5] text-sm font-semibold hover:bg-[#185FA5]/5 disabled:opacity-50 transition"
                  >
                    {checkingT1 ? <Loader2 size={14} className="animate-spin" /> : <UserPlus size={14} />} 
                    Trimester 1
                  </button>
                  <button 
                    onClick={handleT3Click} 
                    disabled={checkingT3}
                    className="w-full flex items-center justify-center gap-2 p-2.5 rounded-lg border border-[#185FA5] text-[#185FA5] text-sm font-semibold hover:bg-[#185FA5]/5 disabled:opacity-50 transition"
                  >
                    {checkingT3 ? <Loader2 size={14} className="animate-spin" /> : <UserPlus size={14} />} 
                    Trimester 3
                  </button>
                </div>
              </div>
            </div>

            {/* Persalinan & Nifas */}
            <div className="bg-white shadow-sm rounded-xl overflow-hidden border border-gray-100">
              <div className="bg-transparent px-4 py-3 border-b border-gray-200">
                <h3 className="text-sm font-semibold text-[#BA7517] uppercase tracking-wide flex items-center gap-2">
                  <Hospital size={16} /> Persalinan & Nifas
                </h3>
              </div>
              <div className="p-4 space-y-1">
                <Link 
                  to={withKehamilan(`/data-ibu/${id}/rencana-persalinan`)}
                  className="flex items-center gap-2 w-full text-left p-2.5 rounded-lg hover:bg-gray-50 text-gray-700 text-sm"
                >
                  <FileText size={16} className="text-[#BA7517] flex-shrink-0" /> Rencana Persalinan
                </Link>
                <Link 
                  to={withKehamilan(`/data-ibu/${id}/pelayanan-persalinan`)}
                  className="flex items-center gap-2 w-full text-left p-2.5 rounded-lg hover:bg-gray-50 text-gray-700 text-sm"
                >
                  <Baby size={16} className="text-[#0F6E56] flex-shrink-0" /> Riwayat Melahirkan
                </Link>
                <Link 
                  to={withKehamilan(`/data-ibu/${id}/pelayanan-nifas`)}
                  className="flex items-center gap-2 w-full text-left p-2.5 rounded-lg hover:bg-gray-50 text-gray-700 text-sm"
                >
                  <Heart size={16} className="text-[#185FA5] flex-shrink-0" /> Pelayanan Nifas
                </Link>
              </div>
            </div>

            {/* Rujukan Medis */}
            <div className="bg-white shadow-sm rounded-xl overflow-hidden border border-gray-100">
              <div className="bg-transparent px-4 py-3 border-b border-gray-200">
                <h3 className="text-sm font-semibold text-[#A32D2D] uppercase tracking-wide flex items-center gap-2">
                  <AlertTriangle size={16} /> Rujukan Medis
                </h3>
              </div>
              <div className="p-4 space-y-1">
                <Link 
                  to={withKehamilan(`/data-ibu/${id}/rujukan`)}
                  className="flex items-center gap-2 w-full text-left p-2.5 rounded-lg hover:bg-gray-50 text-gray-700 text-sm"
                >
                  <AlertTriangle size={16} className="text-[#A32D2D] flex-shrink-0" /> {isDokter ? 'Lihat Rujukan' : 'Buat / Lihat Rujukan'}
                </Link>
                <Link 
                  to="/daftar-rujukan"
                  className="block text-center text-[#185FA5] text-sm font-semibold py-2.5 hover:underline"
                >
                  Daftar Semua Rujukan
                </Link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </MainLayout>
  );
}