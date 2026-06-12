// src/pages/Ibu/RujukanDisplay.jsx
import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import { getRujukanByKehamilanId } from "../../services/rujukanService";
import { FileText, CheckCircle2, AlertCircle, Calendar, User, Stethoscope, MapPin, Edit2, ArrowLeft } from "lucide-react";

export default function RujukanDisplay() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [kehamilan, setKehamilan] = useState(null);
  const [rujukan, setRujukan] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const kehamilanList = await getKehamilanByIbuId(id);
        if (kehamilanList.length > 0) {
          const aktif = kehamilanList[0];
          setKehamilan(aktif);
          
          const rujukanData = await getRujukanByKehamilanId(aktif.id);
          if (rujukanData && rujukanData.length > 0) {
            setRujukan(rujukanData[0]);
          }
        }
      } catch (err) {
        console.error("Error loading data:", err);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [id]);

  const formatDate = (date) => {
    if (!date) return "-";
    return new Date(date).toLocaleDateString('id-ID', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  };

  if (loading) {
    return (
      <MainLayout>
        <div className="p-6 text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600 mx-auto"></div>
          <p className="mt-4 text-gray-500">Memuat data rujukan...</p>
        </div>
      </MainLayout>
    );
  }

  return (
    <MainLayout>
      <div className="p-4 md:p-6 max-w-4xl mx-auto">
        <div className="mb-6">
          <h1 className="text-2xl md:text-3xl font-bold text-gray-900 mb-1">Data Rujukan Ibu Hamil</h1>
          <p className="text-sm md:text-base text-gray-500">Dokumentasi rujukan dan rujukan balik ke FKRTL</p>
        </div>

        {rujukan ? (
          <div className="space-y-4">
            {/* Status Header */}
            <div className="bg-gradient-to-r from-indigo-600 to-indigo-700 rounded-xl shadow-sm p-4 md:p-5 text-white">
              <div className="flex items-center gap-3">
                <div className="p-2 bg-white/20 rounded-full">
                  <CheckCircle2 size={32} />
                </div>
                <div>
                  <h2 className="text-lg md:text-xl font-bold">Rujukan Terdokumentasi</h2>
                  <p className="text-xs md:text-sm text-indigo-100">Dibuat pada {formatDate(rujukan.created_at)}</p>
                </div>
              </div>
            </div>

            {/* Rujukan ke FKRTL */}
            <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
              <div className="bg-gradient-to-r from-red-500 to-rose-600 px-4 md:px-5 py-3">
                <div className="flex items-center gap-2">
                  <AlertCircle size={22} className="text-white" />
                  <h3 className="text-lg md:text-xl font-bold text-white">Rujukan ke FKRTL</h3>
                </div>
              </div>

              <div className="p-4 md:p-5 space-y-4">
                {/* Resume Pemeriksaan */}
                <div>
                  <label className="block text-xs md:text-sm font-semibold text-gray-700 mb-2">Resume Pemeriksaan & Tatalaksana</label>
                  <div className="bg-gray-50 p-3 rounded-lg border border-gray-200">
                    <p className="text-sm text-gray-800 whitespace-pre-wrap leading-relaxed line-clamp-4">
                      {rujukan.rujukan_resume_pemeriksaan_tatalaksana || "-"}
                    </p>
                  </div>
                </div>

                {/* Diagnosis Akhir */}
                <div>
                  <label className="block text-xs md:text-sm font-semibold text-gray-700 mb-2">Diagnosis Akhir</label>
                  <div className="bg-red-50 p-3 rounded-lg border border-red-200">
                    <p className="text-sm text-red-900 font-medium">{rujukan.rujukan_diagnosis_akhir || "-"}</p>
                  </div>
                </div>

                {/* Alasan Rujukan */}
                <div>
                  <label className="block text-xs md:text-sm font-semibold text-gray-700 mb-2">Alasan Dirujuk ke FKRTL</label>
                  <div className="bg-yellow-50 p-3 rounded-lg border border-yellow-200">
                    <p className="text-sm text-yellow-900 whitespace-pre-wrap leading-relaxed line-clamp-3">
                      {rujukan.rujukan_alasan_dirujuk_ke_fkrtl || "-"}
                    </p>
                  </div>
                </div>
              </div>
            </div>

            {/* Rujukan Balik */}
            {rujukan.rujukan_balik_tanggal && (
              <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                <div className="bg-gradient-to-r from-emerald-500 to-green-600 px-4 md:px-5 py-3">
                  <div className="flex items-center gap-2">
                    <CheckCircle2 size={22} className="text-white" />
                    <h3 className="text-lg md:text-xl font-bold text-white">Rujukan Balik</h3>
                  </div>
                </div>

                <div className="p-4 md:p-5 space-y-4">
                  {/* Tanggal Rujukan Balik */}
                  <div className="flex items-start gap-3 bg-emerald-50 p-3 rounded-lg border border-emerald-200">
                    <Calendar size={20} className="text-emerald-600 mt-0.5 flex-shrink-0" />
                    <div>
                      <p className="text-xs text-emerald-700 font-medium">Tanggal Rujukan Balik</p>
                      <p className="text-base font-bold text-emerald-900">{formatDate(rujukan.rujukan_balik_tanggal)}</p>
                    </div>
                  </div>

                  {/* Diagnosis Akhir Balik */}
                  <div>
                    <label className="block text-xs md:text-sm font-semibold text-gray-700 mb-2">Diagnosis Akhir Rujukan Balik</label>
                    <div className="bg-green-50 p-3 rounded-lg border border-green-200">
                      <p className="text-sm text-green-900 font-medium">{rujukan.rujukan_balik_diagnosis_akhir || "-"}</p>
                    </div>
                  </div>

                  {/* Resume Pemeriksaan Balik */}
                  <div>
                    <label className="block text-xs md:text-sm font-semibold text-gray-700 mb-2">Resume Pemeriksaan & Tatalaksana Rujukan Balik</label>
                    <div className="bg-green-50 p-3 rounded-lg border border-green-200">
                      <p className="text-sm text-green-900 whitespace-pre-wrap leading-relaxed line-clamp-3">
                        {rujukan.rujukan_balik_resume_pemeriksaan_tatalaksana || "-"}
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* Anjuran */}
            <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
              <div className="bg-gradient-to-r from-blue-500 to-cyan-600 px-4 md:px-5 py-3">
                <div className="flex items-center gap-2">
                  <MapPin size={22} className="text-white" />
                  <h3 className="text-lg md:text-xl font-bold text-white">Anjuran Persalinan</h3>
                </div>
              </div>

              <div className="p-4 md:p-5">
                <div className="bg-blue-50 p-3 rounded-lg border border-blue-200">
                  <p className="text-xs md:text-sm font-bold text-blue-900 mb-2">Tempat Melahirkan yang Direkomendasikan:</p>
                  <p className="text-sm text-blue-800">{rujukan.anjuran_rekomendasi_tempat_melahirkan || "-"}</p>
                </div>
              </div>
            </div>

            {/* Informasi Kehamilan */}
            {kehamilan && (
              <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-4 md:p-5">
                <h3 className="text-base md:text-lg font-bold text-gray-900 mb-3">Informasi Terkait</h3>
                <div className="grid grid-cols-2 md:grid-cols-4 gap-2 md:gap-3">
                  <div className="p-3 bg-indigo-50 rounded-lg">
                    <p className="text-xs text-gray-600 font-medium mb-1">Usia Kehamilan</p>
                    <p className="text-base font-bold text-indigo-900">{kehamilan.usia_kehamilan_minggu || "-"} minggu</p>
                  </div>
                  <div className="p-3 bg-purple-50 rounded-lg">
                    <p className="text-xs text-gray-600 font-medium mb-1">Status</p>
                    <p className="text-base font-bold text-purple-900">{kehamilan.status_kehamilan || "-"}</p>
                  </div>
                  <div className="p-3 bg-pink-50 rounded-lg">
                    <p className="text-xs text-gray-600 font-medium mb-1">Tanggal HPHT</p>
                    <p className="text-xs font-bold text-pink-900">{formatDate(kehamilan.hpht)}</p>
                  </div>
                  <div className="p-3 bg-green-50 rounded-lg">
                    <p className="text-xs text-gray-600 font-medium mb-1">Perkiraan Lahir</p>
                    <p className="text-xs font-bold text-green-900">{formatDate(kehamilan.taksiran_persalinan)}</p>
                  </div>
                </div>
              </div>
            )}

            {/* Action Buttons */}
            <div className="flex gap-2 md:gap-3 flex-wrap pt-2">
              <button 
                onClick={() => navigate(`/data-ibu/${id}/rujukan?edit=true`)}
                className="bg-indigo-600 text-white px-4 md:px-5 py-2.5 rounded-lg font-semibold text-sm hover:bg-indigo-700 transition-colors flex items-center justify-center gap-2"
              >
                <Edit2 size={18} />
                Edit Rujukan
              </button>
              <button 
                onClick={() => navigate(`/data-ibu/${id}/skrining-dashboard`)}
                className="bg-purple-600 text-white px-4 md:px-5 py-2.5 rounded-lg font-semibold text-sm hover:bg-purple-700 transition-colors flex items-center justify-center gap-2"
              >
                <ArrowLeft size={18} />
                Kembali ke Skrining
              </button>
            </div>
          </div>
        ) : (
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6 md:p-8 text-center">
            <AlertCircle size={40} className="mx-auto text-gray-300 mb-3" />
            <h3 className="text-lg font-bold text-gray-900 mb-2">Data Rujukan Tidak Ditemukan</h3>
            <p className="text-sm text-gray-500">
              Belum ada data rujukan. Pastikan skrining sudah dilakukan dengan hasil memerlukan rujukan.
            </p>
          </div>
        )}
      </div>
    </MainLayout>
  );
}
