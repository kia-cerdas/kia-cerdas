// src/pages/Ibu/SkriningDashboard.jsx
import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import { getSkriningByKehamilanId } from "../../services/skrining";
import api from "../../services/api";
import { CheckCircle2, AlertCircle, ShieldAlert, Pill, Heart, ClipboardList, Edit2, Plus, FileText } from "lucide-react";

export default function SkriningDashboard() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [kehamilan, setKehamilan] = useState(null);
  const [skrining, setSkrining] = useState(null);
  const [skriningDMG, setSkriningDMG] = useState(null);
  const [rujukan, setRujukan] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const kehamilanList = await getKehamilanByIbuId(id);
        if (kehamilanList.length > 0) {
          const aktif = kehamilanList[0];
          setKehamilan(aktif);

          // Fetch Skrining Preeklampsia
          const skriningData = await getSkriningByKehamilanId(aktif.id);
          if (skriningData && skriningData.length > 0) {
            setSkrining(skriningData[0]);
          }

          // Fetch Skrining DM Gestasional
          const dmRes = await api.get(`/tenaga-kesehatan/skrining-dm-gestasional?kehamilan_id=${aktif.id}`);
          const dmgData = dmRes.data?.data;
          if (dmgData && dmgData.length > 0) {
            setSkriningDMG(dmgData[0]);
          }

          // Fetch Rujukan
          try {
            const rujukanRes = await api.get(`/tenaga-kesehatan/rujukan?kehamilan_id=${aktif.id}`);
            const rujukanData = rujukanRes.data?.data;
            if (rujukanData && rujukanData.length > 0) {
              setRujukan(rujukanData[0]);
            }
          } catch (err) {
            console.log("Belum ada data rujukan");
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

  const hitungRisikoPreeklampsia = () => {
    if (!skrining) return "TIDAK ADA DATA";
    
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

    if (risikoTinggi >= 1 || risikoSedang >= 2 || map || protein) return "RISIKO TINGGI";
    return "RISIKO RENDAH";
  };

  const statusPreeklampsia = hitungRisikoPreeklampsia();
  const isRisikoBermasalah = statusPreeklampsia === "RISIKO TINGGI";

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
      <div className="p-4 md:p-6 max-w-4xl mx-auto">
        <div className="mb-6">
          <h1 className="text-2xl md:text-3xl font-bold text-gray-900 mb-1">Hasil Skrining Risiko Kehamilan</h1>
          <p className="text-sm md:text-base text-gray-500">Monitoring skrining preeklampsia dan DM gestasional</p>
        </div>

        {/* Status Preeklampsia */}
        {skrining ? (
          <div className={`rounded-xl shadow-sm border p-4 md:p-5 mb-6 ${isRisikoBermasalah ? 'bg-red-50 border-red-200' : 'bg-emerald-50 border-emerald-200'}`}>
            <div className="flex items-center gap-3">
              {isRisikoBermasalah ? (
                <ShieldAlert size={32} className="text-red-600 flex-shrink-0" />
              ) : (
                <CheckCircle2 size={32} className="text-emerald-600 flex-shrink-0" />
              )}
              <div>
                <h2 className={`text-lg md:text-xl font-bold ${isRisikoBermasalah ? 'text-red-800' : 'text-emerald-800'}`}>
                  Status: {statusPreeklampsia}
                </h2>
                <p className={`text-xs md:text-sm ${isRisikoBermasalah ? 'text-red-700' : 'text-emerald-700'}`}>
                  {isRisikoBermasalah 
                    ? "Risiko tinggi - Rujukan ke FKRTL sangat disarankan" 
                    : "Risiko terpantau - Lanjutkan ANC rutin"}
                </p>
              </div>
            </div>
          </div>
        ) : (
          <div className="bg-gray-50 border border-gray-200 rounded-xl p-4 md:p-5 mb-6 text-center text-gray-500">
            <AlertCircle size={32} className="mx-auto mb-2 text-gray-300" />
            <p className="text-sm">Data skrining preeklampsia belum tersedia</p>
          </div>
        )}

        {/* Grid Data */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {/* Skrining Preeklampsia Detail */}
          {skrining && (
            <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
              <div className="bg-gradient-to-r from-rose-500 to-red-600 px-4 md:px-5 py-3">
                <div className="flex items-center gap-2">
                  <Heart size={22} className="text-white" />
                  <h3 className="text-base md:text-lg font-bold text-white">Skrining Preeklampsia</h3>
                </div>
              </div>

              <div className="p-3 md:p-4 space-y-4">
                {/* Risiko Sedang */}
                <div>
                  <h4 className="font-semibold text-amber-700 mb-2 flex items-center gap-2 text-sm">
                    <AlertCircle size={16} /> Risiko Sedang
                  </h4>
                  <div className="space-y-1">
                    {[
                      { key: "anamnesis_multipara_pasangan_baru_sedang", label: "Multipara pasangan baru" },
                      { key: "anamnesis_teknologi_reproduksi_berbantu_sedang", label: "Teknologi reproduksi berbantu" },
                      { key: "anamnesis_umur_diatas_35_tahun_sedang", label: "Umur ≥ 35 tahun" },
                      { key: "anamnesis_nulipara_sedang", label: "Nulipara" },
                      { key: "anamnesis_jarak_kehamilan_diatas_10_tahun_sedang", label: "Jarak kehamilan > 10 tahun" },
                      { key: "anamnesis_riwayat_preeklampsia_keluarga_sedang", label: "Riwayat keluarga preeklampsia" },
                      { key: "anamnesis_obesitas_imt_diatas_30_sedang", label: "Obesitas (IMT > 30)" },
                    ].map((item) => (
                      <div key={item.key} className="flex items-center gap-2">
                        {skrining[item.key] ? (
                          <CheckCircle2 size={16} className="text-amber-500 flex-shrink-0" />
                        ) : (
                          <div className="w-4 h-4 rounded-full border-2 border-gray-300 flex-shrink-0"></div>
                        )}
                        <span className={`text-xs md:text-sm ${skrining[item.key] ? "text-gray-900 font-medium" : "text-gray-400"}`}>
                          {item.label}
                        </span>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Risiko Tinggi */}
                <div className="border-t pt-3">
                  <h4 className="font-semibold text-rose-700 mb-2 flex items-center gap-2 text-sm">
                    <ShieldAlert size={16} /> Risiko Tinggi
                  </h4>
                  <div className="space-y-1">
                    {[
                      { key: "anamnesis_riwayat_preeklampsia_sebelumnya_tinggi", label: "Riwayat preeklampsia sebelumnya" },
                      { key: "anamnesis_kehamilan_multipel_tinggi", label: "Kehamilan multipel" },
                      { key: "anamnesis_diabetes_dalam_kehamilan_tinggi", label: "Diabetes dalam kehamilan" },
                      { key: "anamnesis_hipertensi_kronik_tinggi", label: "Hipertensi kronik" },
                      { key: "anamnesis_penyakit_ginjal_tinggi", label: "Penyakit ginjal" },
                      { key: "anamnesis_penyakit_autoimun_sle_tinggi", label: "Penyakit autoimun/SLE" },
                      { key: "anamnesis_anti_phospholipid_syndrome_tinggi", label: "Anti phospholipid syndrome" },
                    ].map((item) => (
                      <div key={item.key} className="flex items-center gap-2">
                        {skrining[item.key] ? (
                          <ShieldAlert size={16} className="text-rose-500 flex-shrink-0" />
                        ) : (
                          <div className="w-4 h-4 rounded-full border-2 border-gray-300 flex-shrink-0"></div>
                        )}
                        <span className={`text-xs md:text-sm ${skrining[item.key] ? "text-gray-900 font-medium" : "text-gray-400"}`}>
                          {item.label}
                        </span>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Pemeriksaan Fisik */}
                <div className="border-t pt-3">
                  <h4 className="font-semibold text-indigo-700 mb-2 text-sm">Pemeriksaan Fisik</h4>
                  <div className="space-y-1">
                    <div className="flex items-center gap-2">
                      {skrining.fisik_map_diatas_90_mmhg ? (
                        <AlertCircle size={16} className="text-red-500 flex-shrink-0" />
                      ) : (
                        <div className="w-4 h-4 rounded-full border-2 border-gray-300 flex-shrink-0"></div>
                      )}
                      <span className={`text-xs md:text-sm ${skrining.fisik_map_diatas_90_mmhg ? "text-gray-900 font-medium" : "text-gray-400"}`}>
                        MAP {'>'}90 mmHg
                      </span>
                    </div>
                    <div className="flex items-center gap-2">
                      {skrining.fisik_proteinuria_urin_celup ? (
                        <AlertCircle size={16} className="text-red-500 flex-shrink-0" />
                      ) : (
                        <div className="w-4 h-4 rounded-full border-2 border-gray-300 flex-shrink-0"></div>
                      )}
                      <span className={`text-xs md:text-sm ${skrining.fisik_proteinuria_urin_celup ? "text-gray-900 font-medium" : "text-gray-400"}`}>
                        Proteinuria (urin celup)
                      </span>
                    </div>
                  </div>
                </div>

                {/* Kesimpulan */}
                {skrining.kesimpulan_skrining_preeklampsia && (
                  <div className="border-t pt-3 bg-blue-50 p-3 rounded-lg">
                    <h4 className="font-semibold text-blue-900 mb-1 text-xs">Kesimpulan Klinis</h4>
                    <p className="text-blue-800 text-xs line-clamp-2">{skrining.kesimpulan_skrining_preeklampsia}</p>
                  </div>
                )}
              </div>
            </div>
          )}

          {/* Skrining DM Gestasional Detail */}
          {skriningDMG ? (
            <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
              <div className="bg-gradient-to-r from-purple-500 to-indigo-600 px-4 md:px-5 py-3">
                <div className="flex items-center gap-2">
                  <Pill size={22} className="text-white" />
                  <h3 className="text-base md:text-lg font-bold text-white">Skrining DM Gestasional</h3>
                </div>
              </div>

              <div className="p-3 md:p-4 space-y-3">
                {/* GDP */}
                <div>
                  <h4 className="font-semibold text-gray-900 mb-2 text-sm">Gula Darah Puasa (GDP)</h4>
                  <div className="bg-purple-50 p-3 rounded-lg space-y-1">
                    <div>
                      <p className="text-xs text-gray-600">Hasil</p>
                      <p className="text-base font-bold text-purple-700">
                        {skriningDMG.gula_darah_puasa_hasil || "-"} mg/dL
                      </p>
                    </div>
                    {skriningDMG.gula_darah_puasa_rencana_tindak_lanjut && (
                      <div>
                        <p className="text-xs text-gray-600">Rencana Tindak Lanjut</p>
                        <p className="text-xs text-purple-900 line-clamp-2">{skriningDMG.gula_darah_puasa_rencana_tindak_lanjut}</p>
                      </div>
                    )}
                  </div>
                </div>

                {/* Gula Darah 2 Jam Post Prandial */}
                <div className="border-t pt-3">
                  <h4 className="font-semibold text-gray-900 mb-2 text-sm">Gula Darah 2 Jam Post Prandial</h4>
                  <div className="bg-indigo-50 p-3 rounded-lg space-y-1">
                    <div>
                      <p className="text-xs text-gray-600">Hasil</p>
                      <p className="text-base font-bold text-indigo-700">
                        {skriningDMG.gula_darah_2_jam_post_prandial_hasil || "-"} mg/dL
                      </p>
                    </div>
                    {skriningDMG.gula_darah_2_jam_post_prandial_rencana_tindak_lanjut && (
                      <div>
                        <p className="text-xs text-gray-600">Rencana Tindak Lanjut</p>
                        <p className="text-xs text-indigo-900 line-clamp-2">
                          {skriningDMG.gula_darah_2_jam_post_prandial_rencana_tindak_lanjut}
                        </p>
                      </div>
                    )}
                  </div>
                </div>

                {/* Status */}
                <div className="border-t pt-3 bg-emerald-50 p-3 rounded-lg">
                  <div className="flex items-center gap-2">
                    <CheckCircle2 size={16} className="text-emerald-600 flex-shrink-0" />
                    <p className="text-emerald-900 font-medium text-sm">Skrining Selesai</p>
                  </div>
                </div>
              </div>
            </div>
          ) : (
            <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-4 md:p-5 flex items-center justify-center h-64 md:h-auto">
              <div className="text-center text-gray-400">
                <Pill size={32} className="mx-auto mb-2 opacity-50" />
                <p className="text-sm">Data DM Gestasional belum tersedia</p>
              </div>
            </div>
          )}
        </div>

        {/* Action Buttons */}
        <div className="mt-6 flex gap-2 md:gap-3 flex-wrap">
          <button 
            onClick={() => navigate(`/data-ibu/${id}/skrining-preeklampsia?edit=true`)}
            className="bg-indigo-600 text-white px-4 md:px-5 py-2.5 rounded-lg font-semibold text-sm hover:bg-indigo-700 transition-colors flex items-center justify-center gap-2"
          >
            <Edit2 size={18} />
            Edit Skrining
          </button>
          {rujukan ? (
            <button 
              onClick={() => navigate(`/data-ibu/${id}/rujukan-display`)}
              className="bg-blue-600 text-white px-4 md:px-5 py-2.5 rounded-lg font-semibold text-sm hover:bg-blue-700 transition-colors flex items-center justify-center gap-2"
            >
              <FileText size={18} />
              Lihat Rujukan
            </button>
          ) : (
            <button 
              onClick={() => navigate(`/data-ibu/${id}/rujukan`)}
              className="bg-green-600 text-white px-4 md:px-5 py-2.5 rounded-lg font-semibold text-sm hover:bg-green-700 transition-colors flex items-center justify-center gap-2"
            >
              <Plus size={18} />
              Tambah Rujukan
            </button>
          )}
        </div>

        {/* Catatan Tanggal */}
        <div className="mt-6 bg-gray-50 rounded-lg p-3 text-xs text-gray-600 flex items-start gap-2">
          <ClipboardList size={14} className="mt-0.5 flex-shrink-0" />
          <div>
            {skrining && <p>Skrining preeklampsia: {new Date(skrining.created_at).toLocaleDateString('id-ID')}</p>}
            {skriningDMG && <p>Skrining DM Gestasional: {new Date(skriningDMG.created_at).toLocaleDateString('id-ID')}</p>}
          </div>
        </div>
      </div>
    </MainLayout>
  );
}
