// src/pages/Ibu/SkriningDashboardList.jsx
import React, { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import { getIbuList } from "../../services/ibu";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import { getSkriningByKehamilanId } from "../../services/skrining";
import { ClipboardCheck, ArrowRight, User, Search, AlertCircle, CheckCircle2 } from "lucide-react";

export default function SkriningDashboardList() {
  const [ibuList, setIbuList] = useState([]);
  const [skriningData, setSkriningData] = useState({});
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState("");

  useEffect(() => {
    const fetchData = async () => {
      try {
        const data = await getIbuList();
        setIbuList(data || []);

        // Fetch skrining data untuk setiap ibu
        const skriningMap = {};
        for (const ibu of data) {
          try {
            const kehamilanList = await getKehamilanByIbuId(ibu.id_ibu);
            if (kehamilanList.length > 0) {
              const skrining = await getSkriningByKehamilanId(kehamilanList[0].id);
              skriningMap[ibu.id_ibu] = skrining && skrining.length > 0 ? skrining[0] : null;
            }
          } catch (err) {
            console.error(`Error fetching skrining for ibu ${ibu.id_ibu}:`, err);
          }
        }
        setSkriningData(skriningMap);
      } catch (err) {
        console.error("Gagal memuat data ibu:", err);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  const filteredList = ibuList.filter(ibu => 
    ibu.kependudukan?.nama_lengkap.toLowerCase().includes(searchTerm.toLowerCase()) ||
    ibu.kependudukan?.nik.includes(searchTerm)
  );

  if (loading) {
    return (
      <MainLayout>
        <div className="p-6 text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600 mx-auto"></div>
          <p className="mt-4 text-gray-500">Memuat data skrining...</p>
        </div>
      </MainLayout>
    );
  }

  return (
    <MainLayout>
      <div className="p-6 max-w-6xl mx-auto">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Daftar Skrining Risiko Kehamilan</h1>
          <p className="text-gray-500 font-medium">Lihat hasil skrining preeklampsia dan diabetes gestasional untuk semua ibu hamil.</p>
        </div>

        {/* Search Bar */}
        <div className="bg-white p-4 rounded-xl shadow-sm border border-gray-100 mb-6 flex items-center gap-4">
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
            <input 
              type="text" 
              placeholder="Cari berdasarkan Nama atau NIK..." 
              className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
        </div>

        {/* Table */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="bg-gray-50 border-b border-gray-200">
                  <th className="px-6 py-4 text-left text-sm font-semibold text-gray-900">Nama Ibu</th>
                  <th className="px-6 py-4 text-left text-sm font-semibold text-gray-900">NIK</th>
                  <th className="px-6 py-4 text-left text-sm font-semibold text-gray-900">Status Skrining</th>
                  <th className="px-6 py-4 text-left text-sm font-semibold text-gray-900">Risiko Preeklampsia</th>
                  <th className="px-6 py-4 text-left text-sm font-semibold text-gray-900">Aksi</th>
                </tr>
              </thead>
              <tbody>
                {filteredList.map((ibu) => {
                  const skrining = skriningData[ibu.id_ibu];
                  const hasData = !!skrining;
                  
                  // Calculate risk level
                  let riskLevel = "TIDAK ADA DATA";
                  if (skrining) {
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

                    if (risikoTinggi >= 1 || risikoSedang >= 2 || map || protein) {
                      riskLevel = "RISIKO TINGGI";
                    } else {
                      riskLevel = "RISIKO RENDAH";
                    }
                  }

                  const riskBgColor = riskLevel === "RISIKO TINGGI" ? "bg-red-50" : riskLevel === "RISIKO RENDAH" ? "bg-emerald-50" : "bg-gray-50";
                  const riskTextColor = riskLevel === "RISIKO TINGGI" ? "text-red-700" : riskLevel === "RISIKO RENDAH" ? "text-emerald-700" : "text-gray-500";

                  return (
                    <tr key={ibu.id_ibu} className="border-b border-gray-200 hover:bg-gray-50 transition-colors">
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-3">
                          <div className="p-2 bg-indigo-100 rounded-lg">
                            <User size={18} className="text-indigo-600" />
                          </div>
                          <div>
                            <p className="font-semibold text-gray-900">{ibu.kependudukan?.nama_lengkap || "Tanpa Nama"}</p>
                            <p className="text-xs text-gray-500">{ibu.status_kehamilan}</p>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <p className="text-sm text-gray-600 font-medium">{ibu.kependudukan?.nik || "-"}</p>
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-2">
                          {hasData ? (
                            <>
                              <CheckCircle2 size={18} className="text-emerald-500" />
                              <span className="text-sm font-medium text-emerald-700">Selesai</span>
                            </>
                          ) : (
                            <>
                              <AlertCircle size={18} className="text-amber-500" />
                              <span className="text-sm font-medium text-amber-700">Belum</span>
                            </>
                          )}
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <span className={`px-3 py-1 rounded-full text-xs font-bold ${riskBgColor} ${riskTextColor}`}>
                          {riskLevel}
                        </span>
                      </td>
                      <td className="px-6 py-4">
                        {hasData && (
                          <Link 
                            to={`/data-ibu/${ibu.id_ibu}/skrining-dashboard`}
                            className="inline-flex items-center gap-2 px-4 py-2 bg-indigo-600 text-white text-sm font-semibold rounded-lg hover:bg-indigo-700 transition-colors"
                          >
                            Lihat Detail
                            <ArrowRight size={16} />
                          </Link>
                        )}
                        {!hasData && (
                          <span className="text-xs text-gray-400">Belum ada skrining</span>
                        )}
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </div>

        {filteredList.length === 0 && (
          <div className="text-center py-20 bg-gray-50 rounded-3xl border-2 border-dashed border-gray-200 mt-6">
            <Search className="mx-auto text-gray-300 mb-4" size={48} />
            <p className="text-gray-500 font-medium text-lg">Tidak ada data ibu yang ditemukan.</p>
          </div>
        )}

        {/* Summary */}
        <div className="mt-8 grid grid-cols-3 gap-4">
          <div className="bg-emerald-50 border border-emerald-200 rounded-lg p-4">
            <p className="text-sm text-emerald-700">Total Ibu</p>
            <p className="text-2xl font-bold text-emerald-900">{ibuList.length}</p>
          </div>
          <div className="bg-amber-50 border border-amber-200 rounded-lg p-4">
            <p className="text-sm text-amber-700">Sudah Skrining</p>
            <p className="text-2xl font-bold text-amber-900">{Object.values(skriningData).filter(Boolean).length}</p>
          </div>
          <div className="bg-red-50 border border-red-200 rounded-lg p-4">
            <p className="text-sm text-red-700">Risiko Tinggi</p>
            <p className="text-2xl font-bold text-red-900">
              {Object.values(skriningData).filter(s => s && (() => {
                const risikoSedang = [
                  s.anamnesis_multipara_pasangan_baru_sedang,
                  s.anamnesis_teknologi_reproduksi_berbantu_sedang,
                  s.anamnesis_umur_diatas_35_tahun_sedang,
                  s.anamnesis_nulipara_sedang,
                  s.anamnesis_jarak_kehamilan_diatas_10_tahun_sedang,
                  s.anamnesis_riwayat_preeklampsia_keluarga_sedang,
                  s.anamnesis_obesitas_imt_diatas_30_sedang,
                ].filter(Boolean).length;

                const risikoTinggi = [
                  s.anamnesis_riwayat_preeklampsia_sebelumnya_tinggi,
                  s.anamnesis_kehamilan_multipel_tinggi,
                  s.anamnesis_diabetes_dalam_kehamilan_tinggi,
                  s.anamnesis_hipertensi_kronik_tinggi,
                  s.anamnesis_penyakit_ginjal_tinggi,
                  s.anamnesis_penyakit_autoimun_sle_tinggi,
                  s.anamnesis_anti_phospholipid_syndrome_tinggi,
                ].filter(Boolean).length;

                return risikoTinggi >= 1 || risikoSedang >= 2 || s.fisik_map_diatas_90_mmhg || s.fisik_proteinuria_urin_celup;
              })()).length}
            </p>
          </div>
        </div>
      </div>
    </MainLayout>
  );
}
