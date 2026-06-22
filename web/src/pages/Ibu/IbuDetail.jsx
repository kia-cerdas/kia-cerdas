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
  Info,
  Venus,
  Mars
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
    iconHtml: '<div style="display:flex;align-items:center;justify-content:center;width:80px;height:80px;margin:20px auto;background:#ffffff;border-radius:50%;border:4px solid #ffffff;box-shadow:0 0 0 4px #fecaca"><svg xmlns="http://www.w3.org/2000/svg" width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="#dc2626" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></div>',
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
          <div className="bg-red-50 border-l-4 border-red-500 p-3 mb-3 text-red-700 text-sm">
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
          <div className="bg-yellow-50 border-l-4 border-yellow-500 p-3 text-yellow-700 text-sm">
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
          <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
            {/* Grup kiri - Buttons */}
            <div className="flex flex-wrap items-center gap-3">
              <Link
                to="/data-ibu"
                className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full border border-[#185FA5] text-[#185FA5] text-sm font-semibold hover:bg-[#185FA5]/5 transition"
              >
                <ArrowLeft size={16} />
                <span>Kembali</span>
              </Link>

              {kehamilan.status_kehamilan !== "NON-AKTIF" && (
                <button
                  onClick={handleNonAktif}
                  disabled={nonAktifLoading}
                  className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full border border-red-400 text-red-500 text-sm font-semibold hover:bg-red-50 transition disabled:opacity-50"
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

            {/* Grup kanan - Data Points */}
            <div className="flex flex-wrap items-center gap-4 lg:gap-6 text-xs md:text-sm">
              <div className="flex items-center gap-2">
                <Calendar size={16} className="text-[#0F6E56]" />
                <span className="text-gray-600">HPHT:</span>
                <span className="font-semibold text-gray-800">{hphtFormatted}</span>
              </div>
              <div className="flex items-center gap-2">
                <Target size={16} className="text-[#BA7517]" />
                <span className="text-gray-600">HPL:</span>
                <span className="font-semibold text-gray-800">{hplFormatted}</span>
              </div>
              <div className="flex items-center gap-2">
                <Baby size={16} className="text-[#085041]" />
                <span className="text-gray-600">Usia Kehamilan:</span>
                <span className="font-semibold text-[#085041]">{usiaKehamilan}</span>
              </div>
            </div>
          </div>

          {/* Kartu Identitas Ibu dan Suami */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            {/* Card Data Ibu */}
            <div className="bg-white shadow-sm rounded-xl p-4 border-2 border-gray-100">
              <h2 className="text-base font-semibold text-[#185FA5] flex items-center gap-2 mb-3">
                <Venus size={18} /> Data Ibu
              </h2>
              <div className="grid grid-cols-2 gap-y-2 gap-x-3 text-sm">
                <span className="text-gray-500 text-xs">Nama Lengkap</span>
                <span className="font-medium text-gray-800 text-sm">{kependudukan.nama_lengkap || "-"}</span>
                
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

            {/* Card Data Ayah */}
            <div className="bg-white shadow-sm rounded-xl p-4 border-2 border-gray-100">
              <h2 className="text-base font-semibold text-[#0F6E56] flex items-center gap-2 mb-3">
                <Mars size={18} /> Data Ayah
              </h2>
              {suami ? (
                <div className="grid grid-cols-2 gap-y-2 gap-x-3 text-sm">
                  <span className="text-gray-500 text-xs">Nama Lengkap</span>
                  <span className="font-medium text-gray-800 text-sm">{suami.nama_lengkap || "-"}</span>
                  
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
            <div className="bg-white shadow-sm rounded-xl overflow-hidden border-2 border-gray-100">
              <div className="bg-transparent px-4 py-3 border-b-2 border-gray-200">
                <h3 className="text-sm font-semibold text-[#185FA5] uppercase tracking-wide flex items-center gap-2">
                  <ClipboardList size={16} /> Skrining & Pemeriksaan
                </h3>
              </div>
              <div className="p-4 space-y-2">
                <Link 
                  to={withKehamilan(`/data-ibu/${id}/evaluasi-kesehatan`)}
                  className="flex items-center gap-2 w-full text-left p-2.5 rounded-lg border-2 border-[#0F6E56]/30 hover:bg-[#0F6E56]/5 text-gray-700 text-sm font-medium transition"
                >
                  <Activity size={16} className="text-[#0F6E56] flex-shrink-0" /> Evaluasi Kesehatan
                </Link>
                <Link 
                  to={withKehamilan(`/data-ibu/${id}/pemeriksaan-rutin`)}
                  className="flex items-center gap-2 w-full text-left p-2.5 rounded-lg border-2 border-[#BA7517]/30 hover:bg-[#BA7517]/5 text-gray-700 text-sm font-medium transition"
                >
                  <Activity size={16} className="text-[#BA7517] flex-shrink-0" /> Input ANC Rutin
                </Link>
                <Link 
                  to={withKehamilan(`/data-ibu/${id}/Skrining-Diabetes-Melitus-Gestasional`)}
                  className="flex items-center gap-2 w-full text-left p-2.5 rounded-lg border-2 border-[#185FA5]/30 hover:bg-[#185FA5]/5 text-gray-700 text-sm font-medium transition"
                >
                  <Droplet size={16} className="text-[#185FA5] flex-shrink-0" /> Skrining DMG
                </Link>
              </div>
            </div>

            {/* Pemantauan Trimester */}
            <div className="bg-white shadow-sm rounded-xl overflow-hidden border-2 border-gray-100">
              <div className="bg-transparent px-4 py-3 border-b-2 border-gray-200">
                <h3 className="text-sm font-semibold text-[#0F6E56] uppercase tracking-wide flex items-center gap-2">
                  <Stethoscope size={16} /> Pemantauan Trimester
                </h3>
              </div>
              <div className="p-4 space-y-2">
                <div className="flex flex-col gap-1.5">
                  <button 
                    onClick={handleT1Click} 
                    disabled={checkingT1}
                    className="flex items-center gap-2 w-full text-left p-2.5 rounded-lg border-2 border-[#185FA5]/30 hover:bg-[#185FA5]/5 text-gray-700 text-sm font-medium transition disabled:opacity-50"
                  >
                    {checkingT1 ? <Loader2 size={16} className="animate-spin text-[#185FA5] flex-shrink-0" /> : <UserPlus size={16} className="text-[#185FA5] flex-shrink-0" />} 
                    Trimester 1
                  </button>
                  <Link 
                    to={withKehamilan(`/data-ibu/${id}/skrining-preeklampsia`)}
                    className="flex items-center gap-2 w-full text-left p-2.5 rounded-lg border-2 border-[#185FA5]/30 hover:bg-[#185FA5]/5 text-gray-700 text-sm font-medium transition"
                  >
                    <UserPlus size={16} className="text-[#185FA5] flex-shrink-0" /> Trimester 2
                  </Link>
                  <button 
                    onClick={handleT3Click} 
                    disabled={checkingT3}
                    className="flex items-center gap-2 w-full text-left p-2.5 rounded-lg border-2 border-[#185FA5]/30 hover:bg-[#185FA5]/5 text-gray-700 text-sm font-medium transition disabled:opacity-50"
                  >
                    {checkingT3 ? <Loader2 size={16} className="animate-spin text-[#185FA5] flex-shrink-0" /> : <UserPlus size={16} className="text-[#185FA5] flex-shrink-0" />} 
                    Trimester 3
                  </button>
                </div>
              </div>
            </div>

            {/* Persalinan & Nifas */}
            <div className="bg-white shadow-sm rounded-xl overflow-hidden border-2 border-gray-100">
              <div className="bg-transparent px-4 py-3 border-b-2 border-gray-200">
                <h3 className="text-sm font-semibold text-[#BA7517] uppercase tracking-wide flex items-center gap-2">
                  <Hospital size={16} /> Persalinan & Nifas
                </h3>
              </div>
              <div className="p-4 space-y-2">
                <Link 
                  to={withKehamilan(`/data-ibu/${id}/rencana-persalinan`)}
                  className="flex items-center gap-2 w-full text-left p-2.5 rounded-lg border-2 border-[#BA7517]/30 hover:bg-[#BA7517]/5 text-gray-700 text-sm font-medium transition"
                >
                  <FileText size={16} className="text-[#BA7517] flex-shrink-0" /> Rencana Persalinan
                </Link>
                <Link 
                  to={withKehamilan(`/data-ibu/${id}/pelayanan-persalinan`)}
                  className="flex items-center gap-2 w-full text-left p-2.5 rounded-lg border-2 border-[#0F6E56]/30 hover:bg-[#0F6E56]/5 text-gray-700 text-sm font-medium transition"
                >
                  <Baby size={16} className="text-[#0F6E56] flex-shrink-0" /> Pelayanan Persalinan
                </Link>
                <Link 
                  to={withKehamilan(`/data-ibu/${id}/pelayanan-nifas`)}
                  className="flex items-center gap-2 w-full text-left p-2.5 rounded-lg border-2 border-[#185FA5]/30 hover:bg-[#185FA5]/5 text-gray-700 text-sm font-medium transition"
                >
                  <Heart size={16} className="text-[#185FA5] flex-shrink-0" /> Pelayanan Nifas
                </Link>
              </div>
            </div>

            {/* Rujukan Medis */}
            <div className="bg-white shadow-sm rounded-xl overflow-hidden border-2 border-gray-100">
              <div className="bg-transparent px-4 py-3 border-b-2 border-gray-200">
                <h3 className="text-sm font-semibold text-[#A32D2D] uppercase tracking-wide flex items-center gap-2">
                  <AlertTriangle size={16} /> Rujukan Medis
                </h3>
              </div>
              <div className="p-4 space-y-2">
                <Link 
                  to={withKehamilan(`/data-ibu/${id}/rujukan`)}
                  className="flex items-center gap-2 w-full text-left p-2.5 rounded-lg border-2 border-[#A32D2D]/30 hover:bg-[#A32D2D]/5 text-gray-700 text-sm font-medium transition"
                >
                  <AlertTriangle size={16} className="text-[#A32D2D] flex-shrink-0" /> {isDokter ? 'Lihat Rujukan' : 'Buat / Lihat Rujukan'}
                </Link>
                <Link 
                  to="/daftar-rujukan"
                  className="flex items-center gap-2 w-full text-left p-2.5 rounded-lg border-2 border-[#185FA5]/30 hover:bg-[#185FA5]/5 text-gray-700 text-sm font-medium transition"
                >
                  <AlertTriangle size={16} className="text-[#185FA5] flex-shrink-0" /> Daftar Semua Rujukan
                </Link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </MainLayout>
  );
}