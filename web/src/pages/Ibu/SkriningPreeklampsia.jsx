// src/pages/Ibu/SkriningPreeklampsia.jsx
import React, { useEffect, useState } from "react";
import { useParams, useSearchParams, useNavigate } from "react-router-dom";
import Swal from "sweetalert2";
import MainLayout from "../../components/Layout/MainLayout";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import { getSkriningByKehamilanId, createSkrining, updateSkrining } from "../../services/skrining";
import { getCurrentUser, isBidanUser, isDokterUser } from "../../services/auth";
import {
  AlertCircle,
  Save,
  ArrowLeft,
  ShieldAlert,
  CheckCircle2,
  Edit2,
  Info,  
  Plus,
  Heart,
  Eye,
  ClipboardList,
  EyeOff,
  XCircle,
  AlertTriangle,
} from "lucide-react";

export default function SkriningPreeklampsia() {
  const { id: ibuId } = useParams();
  const [searchParams] = useSearchParams();
  const kehamilanId = searchParams.get("kehamilan_id");
  const navigate = useNavigate();

  const user = getCurrentUser();
  const isBidan = isBidanUser(user);
  const isDokter = isDokterUser(user);

  const [kehamilan, setKehamilan] = useState(null);
  const [skrining, setSkrining] = useState(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [isActive, setIsActive] = useState(true);

  const canEdit = isBidan && isActive;

  const [form, setForm] = useState({
    anamnesis_multipara_pasangan_baru_sedang: false,
    anamnesis_teknologi_reproduksi_berbantu_sedang: false,
    anamnesis_umur_diatas_35_tahun_sedang: false,
    anamnesis_nulipara_sedang: false,
    anamnesis_jarak_kehamilan_diatas_10_tahun_sedang: false,
    anamnesis_riwayat_preeklampsia_keluarga_sedang: false,
    anamnesis_obesitas_imt_diatas_30_sedang: false,
    anamnesis_riwayat_preeklampsia_sebelumnya_tinggi: false,
    anamnesis_kehamilan_multipel_tinggi: false,
    anamnesis_diabetes_dalam_kehamilan_tinggi: false,
    anamnesis_hipertensi_kronik_tinggi: false,
    anamnesis_penyakit_ginjal_tinggi: false,
    anamnesis_penyakit_autoimun_sle_tinggi: false,
    anamnesis_anti_phospholipid_syndrome_tinggi: false,
    fisik_map_diatas_90_mmhg: false,
    fisik_proteinuria_urin_celup: false,
    kesimpulan: "",
  });

  // Daftar semua field risiko
  const riskFactorKeys = [
    'anamnesis_multipara_pasangan_baru_sedang',
    'anamnesis_teknologi_reproduksi_berbantu_sedang',
    'anamnesis_umur_diatas_35_tahun_sedang',
    'anamnesis_nulipara_sedang',
    'anamnesis_jarak_kehamilan_diatas_10_tahun_sedang',
    'anamnesis_riwayat_preeklampsia_keluarga_sedang',
    'anamnesis_obesitas_imt_diatas_30_sedang',
    'anamnesis_riwayat_preeklampsia_sebelumnya_tinggi',
    'anamnesis_kehamilan_multipel_tinggi',
    'anamnesis_diabetes_dalam_kehamilan_tinggi',
    'anamnesis_hipertensi_kronik_tinggi',
    'anamnesis_penyakit_ginjal_tinggi',
    'anamnesis_penyakit_autoimun_sle_tinggi',
    'anamnesis_anti_phospholipid_syndrome_tinggi',
    'fisik_map_diatas_90_mmhg',
    'fisik_proteinuria_urin_celup'
  ];

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const kehamilanList = await getKehamilanByIbuId(ibuId);
        if (!kehamilanList.length) {
          Swal.fire({
            icon: 'info',
            title: 'Data Tidak Tersedia',
            text: 'Ibu belum memiliki data kehamilan.',
            confirmButtonColor: '#185FA5'
          });
          navigate(`/data-ibu/${ibuId}`);
          return;
        }

        let targetKehamilan = null;
        if (kehamilanId) {
          targetKehamilan = kehamilanList.find((k) => k.id == kehamilanId);
          if (!targetKehamilan) {
            Swal.fire({
              icon: 'error',
              title: 'Tidak Ditemukan',
              text: `Kehamilan dengan ID ${kehamilanId} tidak ditemukan.`
            });
            navigate(`/data-ibu/${ibuId}`);
            return;
          }
        } else {
          targetKehamilan = kehamilanList[0];
        }
        setKehamilan(targetKehamilan);
        setIsActive(targetKehamilan.status_kehamilan !== "NON-AKTIF");

        const skriningData = await getSkriningByKehamilanId(targetKehamilan.id);
        if (skriningData && skriningData.length > 0) {
          const s = skriningData[0];
          setSkrining(s);
          setForm({
            ...s,
            kesimpulan: s.kesimpulan_skrining_preeklampsia || "",
          });
        }

        const isEditMode = searchParams.get("edit") === "true";
        setIsEditing(canEdit && isEditMode);
      } catch (err) {
        console.error(err);
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: 'Gagal memuat data. Silakan coba lagi.'
        });
      } finally {
        setLoading(false);
      }
    };
    if (ibuId) fetchData();
  }, [ibuId, kehamilanId, navigate, searchParams]);

  const handleChange = (e) => {
    if (!canEdit) return;
    const { name, value, type, checked } = e.target;
    setForm((prev) => ({ ...prev, [name]: type === "checkbox" ? checked : value }));
  };

  // CEK apakah ada faktor risiko yang dipilih
  const hasRiskFactors = () => {
    return riskFactorKeys.some(key => form[key] === true);
  };

  // VALIDASI - Semua field opsional
  const validateForm = () => {
    // Tidak ada validasi wajib
    return true;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!canEdit) {
      Swal.fire({
        icon: 'error',
        title: 'Akses Ditolak',
        text: 'Anda tidak memiliki izin untuk mengubah data.'
      });
      return;
    }
    
    // HAPUS validasi wajib - semua field opsional
    // if (!validateForm()) {
    //   Swal.fire({
    //     icon: 'warning',
    //     title: 'Data Belum Lengkap',
    //     text: 'Setidaknya satu faktor risiko harus dipilih.'
    //   });
    //   return;
    // }

    if (!kehamilan) {
      Swal.fire({
        icon: 'error',
        title: 'Error',
        text: 'Data kehamilan tidak ditemukan.'
      });
      return;
    }

    // Konfirmasi jika tidak ada faktor risiko yang dipilih
    if (!hasRiskFactors()) {
      const confirm = await Swal.fire({
        icon: 'info',
        title: 'Konfirmasi',
        text: 'Anda belum memilih faktor risiko apapun. Status risiko akan otomatis menjadi "TIDAK PERLU RUJUKAN". Lanjutkan?',
        showCancelButton: true,
        confirmButtonColor: '#185FA5',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Ya, Lanjutkan',
        cancelButtonText: 'Batal'
      });

      if (!confirm.isConfirmed) {
        return;
      }
    }
    
    setSaving(true);
    try {
      const payload = {
        ...form,
        kehamilan_id: kehamilan.id,
        kesimpulan_skrining_preeklampsia: form.kesimpulan,
      };
      delete payload.kesimpulan;

      if (skrining) {
        await updateSkrining(skrining.id, payload);
      } else {
        const newSkrining = await createSkrining(payload);
        setSkrining(newSkrining);
      }
      await Swal.fire({
        icon: 'success',
        title: 'Berhasil',
        text: 'Skrining preeklampsia berhasil disimpan!',
        timer: 2000,
        showConfirmButton: false
      });
      
      setIsEditing(false);
      const refreshed = await getSkriningByKehamilanId(kehamilan.id);
      if (refreshed && refreshed.length > 0) setSkrining(refreshed[0]);
    } catch (err) {
      console.error(err);
      
      // Handle error duplicate key
      if (err.response?.status === 409 || err.message?.includes('duplicate')) {
        Swal.fire({
          icon: 'info',
          title: 'Data Sudah Ada',
          text: 'Skrining untuk kehamilan ini sudah ada. Silakan refresh halaman.',
          confirmButtonColor: '#185FA5'
        });
      } else {
        Swal.fire({
          icon: 'error',
          title: 'Gagal Menyimpan',
          text: err.response?.data?.message || err.message || 'Terjadi kesalahan.'
        });
      }
    } finally {
      setSaving(false);
    }
  };

  const hitungRisiko = () => {
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
    
    // Jika semua false, return TIDAK PERLU RUJUKAN
    if (risikoSedang === 0 && risikoTinggi === 0 && !map && !protein) {
      return "TIDAK PERLU RUJUKAN";
    }
    
    if (risikoTinggi >= 1 || risikoSedang >= 2 || map || protein) {
      return "PERLU RUJUKAN";
    }
    return "TIDAK PERLU RUJUKAN";
  };

  const isRujukan = hitungRisiko() === "PERLU RUJUKAN";

  // Handler untuk tombol rujukan
  const handleRujukClick = (e) => {
    e.preventDefault();
    Swal.fire({
      title: "Konfirmasi Rujukan",
      text: `Ibu ini memiliki status risiko preeklampsia "${hitungRisiko()}". Lanjutkan ke form rujukan?`,
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#d33",
      cancelButtonColor: "#3085d6",
      confirmButtonText: "Ya, Rujuk",
      cancelButtonText: "Batal",
      reverseButtons: true,
    }).then((result) => {
      if (result.isConfirmed) {
        navigate(`/data-ibu/${ibuId}/rujukan?kehamilan_id=${kehamilan.id}&source=preeklampsia`);
      }
    });
  };

  // Komponen checkbox dengan gaya design system
  const CheckboxItem = ({ name, label, description }) => {
    const isChecked = form[name];
    return (
      <label className="flex items-start gap-3 p-3 rounded-lg border border-gray-200 hover:bg-gray-50 cursor-pointer transition">
        <input
          type="checkbox"
          name={name}
          checked={isChecked}
          onChange={handleChange}
          disabled={!canEdit}
          className="mt-0.5 w-4 h-4 text-[#185FA5] rounded border-gray-300 focus:ring-[#185FA5]"
        />
        <div className="flex-1">
          <span className="text-base text-gray-800">{label}</span>
          {description && <p className="text-sm text-gray-500 mt-0.5">{description}</p>}
        </div>
      </label>
    );
  };

  // Tampilan hasil (view mode)
  const ResultView = () => {
    if (!skrining) {
      return (
        <div className="bg-white rounded-xl shadow-sm p-8 text-center">
          <div className="flex flex-col items-center gap-4">
            <div className="p-4 bg-[#185FA5]/10 rounded-full">
              <ClipboardList size={48} className="text-[#185FA5]" />
            </div>
            <h3 className="text-[22px] font-semibold text-[#185FA5]">Belum Ada Data Skrining Preeklampsia</h3>
            <p className="text-base text-gray-500 max-w-md">
              Silakan lakukan skrining preeklampsia untuk ibu hamil ini.
              <br />
              <span className="text-sm text-blue-600">ℹ️ Semua faktor risiko bersifat opsional.</span>
            </p>
            {canEdit && (
              <button
                onClick={() => setIsEditing(true)}
                className="bg-[#185FA5] text-white rounded-lg px-5 py-2.5 font-semibold flex items-center gap-2 text-base"
              >
                <Plus size={18} /> Mulai Skrining
              </button>
            )}
            {!canEdit && !isActive && (
              <p className="text-gray-400 text-sm mt-2">
                Kehamilan sudah selesai (NON-AKTIF), tidak dapat menambahkan data baru.
              </p>
            )}
          </div>
        </div>
      );
    }

    // Cek apakah ada faktor risiko yang dipilih
    const hasSelectedRisk = riskFactorKeys.some(key => skrining[key] === true);

    return (
      <div className="space-y-6">
        {/* Banner status risiko */}
        <div
          className={`p-5 rounded-2xl flex items-center justify-between shadow-sm border ${
            isRujukan
              ? "bg-[#A32D2D]/10 border-[#A32D2D]/30 text-[#A32D2D]"
              : "bg-[#3B6D11]/10 border-[#3B6D11]/30 text-[#3B6D11]"
          }`}
        >
          <div className="flex items-center gap-4">
            {isRujukan ? (
              <ShieldAlert size={36} className="text-[#A32D2D]" />
            ) : (
              <CheckCircle2 size={36} className="text-[#3B6D11]" />
            )}
            <div>
              <h3 className="text-xl font-bold">Status Risiko Preeklampsia: {hitungRisiko()}</h3>
              <p className="text-base opacity-80">
                {isRujukan
                  ? "Pasien ini memiliki indikasi risiko tinggi dan disarankan untuk segera dirujuk."
                  : "Risiko rendah terpantau. Dapat melanjutkan ANC secara rutin."}
              </p>
            </div>
          </div>
        </div>

        {/* Tampilkan informasi jika tidak ada faktor risiko */}
        {!hasSelectedRisk && (
          <div className="bg-gray-50 border border-gray-200 p-4 rounded-lg flex items-start gap-3">
            <Info size={20} className="text-gray-400 mt-0.5 flex-shrink-0" />
            <div>
              <p className="text-gray-600 text-base">
                <span className="font-semibold">Informasi:</span> Belum ada faktor risiko yang dipilih.
                Status risiko otomatis menjadi <strong>"TIDAK PERLU RUJUKAN"</strong>.
              </p>
              <p className="text-sm text-gray-500 mt-1">
                Jika ada faktor risiko yang muncul di kemudian hari, Anda dapat mengedit skrining ini.
              </p>
            </div>
          </div>
        )}

        {/* Detail skrining */}
        <div className="bg-white rounded-xl shadow-sm overflow-hidden">
          <div className="bg-[#185FA5] px-5 py-3">
            <div className="flex items-center gap-2">
              <Heart size={22} className="text-white" />
              <h3 className="text-xl font-bold text-white">Detail Skrining Preeklampsia</h3>
            </div>
          </div>
          <div className="p-5 space-y-5">
            {/* Risiko Sedang */}
            <div>
              <h4 className="font-semibold text-[#BA7517] text-lg flex items-center gap-2 mb-3">
                <AlertCircle size={18} /> Risiko Sedang
              </h4>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                {[
                  { key: "anamnesis_multipara_pasangan_baru_sedang", label: "Multipara dengan pasangan baru", desc: "Pernah melahirkan dengan pasangan berbeda" },
                  { key: "anamnesis_teknologi_reproduksi_berbantu_sedang", label: "Teknologi reproduksi berbantu", desc: "Kehamilan dengan IVF atau sejenisnya" },
                  { key: "anamnesis_umur_diatas_35_tahun_sedang", label: "Umur ≥ 35 tahun", desc: "Usia ibu saat hamil 35 tahun atau lebih" },
                  { key: "anamnesis_nulipara_sedang", label: "Nulipara", desc: "Belum pernah melahirkan sebelumnya" },
                  { key: "anamnesis_jarak_kehamilan_diatas_10_tahun_sedang", label: "Jarak kehamilan > 10 tahun", desc: "Jarak dengan kehamilan terakhir lebih dari 10 tahun" },
                  { key: "anamnesis_riwayat_preeklampsia_keluarga_sedang", label: "Riwayat keluarga preeklampsia", desc: "Ibu atau saudara perempuan pernah preeklampsia" },
                  { key: "anamnesis_obesitas_imt_diatas_30_sedang", label: "Obesitas (IMT > 30)", desc: "Indeks Massa Tubuh sebelum hamil > 30" },
                ].map((item) => (
                  <div key={item.key} className="flex items-center gap-2 text-base">
                    {skrining[item.key] ? (
                      <CheckCircle2 size={16} className="text-[#3B6D11]" />
                    ) : (
                      <XCircle size={16} className="text-gray-300" />
                    )}
                    <div>
                      <span className={skrining[item.key] ? "text-gray-900 font-medium" : "text-gray-400"}>
                        {item.label}
                      </span>
                      {item.desc && skrining[item.key] && (
                        <p className="text-xs text-gray-500">{item.desc}</p>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Risiko Tinggi */}
            <div>
              <h4 className="font-semibold text-[#A32D2D] text-lg flex items-center gap-2 mb-3">
                <ShieldAlert size={18} /> Risiko Tinggi
              </h4>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                {[
                  { key: "anamnesis_riwayat_preeklampsia_sebelumnya_tinggi", label: "Riwayat preeklampsia sebelumnya", desc: "Pernah mengalami preeklampsia pada kehamilan sebelumnya" },
                  { key: "anamnesis_kehamilan_multipel_tinggi", label: "Kehamilan multipel", desc: "Hamil kembar dua atau lebih" },
                  { key: "anamnesis_diabetes_dalam_kehamilan_tinggi", label: "Diabetes dalam kehamilan", desc: "Diabetes gestasional atau diabetes melitus" },
                  { key: "anamnesis_hipertensi_kronik_tinggi", label: "Hipertensi kronik", desc: "Tekanan darah tinggi sebelum hamil" },
                  { key: "anamnesis_penyakit_ginjal_tinggi", label: "Penyakit ginjal", desc: "Riwayat penyakit ginjal kronis" },
                  { key: "anamnesis_penyakit_autoimun_sle_tinggi", label: "Penyakit autoimun (SLE)", desc: "Lupus atau penyakit autoimun lainnya" },
                  { key: "anamnesis_anti_phospholipid_syndrome_tinggi", label: "Anti phospholipid syndrome", desc: "Gangguan pembekuan darah autoimun" },
                ].map((item) => (
                  <div key={item.key} className="flex items-center gap-2 text-base">
                    {skrining[item.key] ? (
                      <ShieldAlert size={16} className="text-[#A32D2D]" />
                    ) : (
                      <XCircle size={16} className="text-gray-300" />
                    )}
                    <div>
                      <span className={skrining[item.key] ? "text-gray-900 font-medium" : "text-gray-400"}>
                        {item.label}
                      </span>
                      {item.desc && skrining[item.key] && (
                        <p className="text-xs text-gray-500">{item.desc}</p>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Pemeriksaan Fisik */}
            <div>
              <h4 className="font-semibold text-[#185FA5] text-lg mb-3">Pemeriksaan Fisik</h4>
              <div className="space-y-2">
                <div className="flex items-center gap-2 text-base">
                  {skrining.fisik_map_diatas_90_mmhg ? (
                    <AlertCircle size={16} className="text-[#A32D2D]" />
                  ) : (
                    <XCircle size={16} className="text-gray-300" />
                  )}
                  <div>
                    <span className={skrining.fisik_map_diatas_90_mmhg ? "text-gray-900 font-medium" : "text-gray-400"}>
                      MAP {" > "} 90 mmHg
                    </span>
                    <p className="text-xs text-gray-500">MAP = Mean Arterial Pressure (tekanan arteri rata-rata)</p>
                  </div>
                </div>
                <div className="flex items-center gap-2 text-base">
                  {skrining.fisik_proteinuria_urin_celup ? (
                    <AlertCircle size={16} className="text-[#A32D2D]" />
                  ) : (
                    <XCircle size={16} className="text-gray-300" />
                  )}
                  <div>
                    <span className={skrining.fisik_proteinuria_urin_celup ? "text-gray-900 font-medium" : "text-gray-400"}>
                      Proteinuria (urin celup {">"} +1)
                    </span>
                    <p className="text-xs text-gray-500">Protein dalam urine menandakan gangguan ginjal</p>
                  </div>
                </div>
              </div>
            </div>

            {skrining.kesimpulan_skrining_preeklampsia && (
              <div className="bg-blue-50 p-3 rounded-lg">
                <h4 className="font-semibold text-blue-900 text-base">Kesimpulan Klinis</h4>
                <p className="text-blue-800 text-base">{skrining.kesimpulan_skrining_preeklampsia}</p>
              </div>
            )}
          </div>
        </div>

        <div className="flex gap-3 justify-end">
          {canEdit && (
            <button
              onClick={() => setIsEditing(true)}
              className="bg-[#185FA5] text-white rounded-full px-5 py-2.5 flex items-center gap-2 text-base font-semibold"
            >
              <Edit2 size={18} /> Edit Skrining
            </button>
          )}
          {/* Tombol Rujuk: muncul jika PERLU RUJUKAN, dan hanya untuk bidan (canEdit) */}
          {isRujukan && canEdit && (
            <button
              onClick={handleRujukClick}
              className="bg-red-600 hover:bg-red-700 text-white rounded-full px-5 py-2.5 flex items-center gap-2 text-base font-semibold shadow-md hover:shadow-lg animate-pulse"
            >
              <AlertTriangle size={18} /> Rujuk Segera
            </button>
          )}
          <button
            onClick={() => navigate(`/data-ibu/${ibuId}?kehamilan_id=${kehamilan.id}`)}
            className="border border-[#185FA5] text-[#185FA5] rounded-full px-5 py-2.5 flex items-center gap-2 text-base font-semibold hover:bg-[#185FA5]/5"
          >
            <ArrowLeft size={18} /> Kembali ke Detail Ibu
          </button>
        </div>
      </div>
    );
  };

  // FormView (mode edit)
  const FormView = () => {
    const hasSelectedRisk = hasRiskFactors();

    return (
      <form onSubmit={handleSubmit} className="space-y-8">
        {/* Banner informasi - Semua field opsional */}
        <div className="bg-blue-50 border border-blue-200 p-4 rounded-lg flex items-start gap-3">
          <Info size={20} className="text-blue-600 mt-0.5 flex-shrink-0" />
          <div>
            <p className="text-blue-700 text-base font-medium">ℹ️ Semua Faktor Risiko Bersifat Opsional</p>
            <p className="text-blue-600 text-sm mt-1">
              Anda dapat menyimpan skrining tanpa memilih faktor risiko apapun. 
              Status risiko akan otomatis menjadi <strong>"TIDAK PERLU RUJUKAN"</strong>.
            </p>
            {!hasSelectedRisk && (
              <p className="text-blue-600 text-sm mt-2 font-medium">
                ⚠️ Saat ini belum ada faktor risiko yang dipilih.
              </p>
            )}
          </div>
        </div>

        {/* Banner status risiko (real-time) */}
        <div
          className={`p-5 rounded-2xl flex items-center justify-between shadow-sm border ${
            hitungRisiko() === "PERLU RUJUKAN"
              ? "bg-[#A32D2D]/10 border-[#A32D2D]/30 text-[#A32D2D]"
              : "bg-[#3B6D11]/10 border-[#3B6D11]/30 text-[#3B6D11]"
          }`}
        >
          <div className="flex items-center gap-4">
            {hitungRisiko() === "PERLU RUJUKAN" ? (
              <ShieldAlert size={36} className="text-[#A32D2D]" />
            ) : (
              <CheckCircle2 size={36} className="text-[#3B6D11]" />
            )}
            <div>
              <h3 className="text-xl font-bold">Status Risiko: {hitungRisiko()}</h3>
              <p className="text-base">
                {hitungRisiko() === "PERLU RUJUKAN"
                  ? "Pasien ini memiliki indikasi risiko tinggi dan disarankan untuk segera dirujuk."
                  : "Risiko rendah terpantau. Dapat melanjutkan ANC secara rutin."}
              </p>
            </div>
          </div>
        </div>

        {/* Risiko Sedang */}
        <div className="bg-white rounded-xl shadow-sm p-5">
          <h3 className="font-bold text-[22px] text-[#BA7517] border-b pb-2 flex items-center gap-2">
            <AlertCircle size={20} /> Anamnesis - Risiko Sedang
            <span className="text-sm font-normal text-gray-400 ml-2">(Opsional)</span>
          </h3>
          <p className="text-sm text-gray-500 mt-1 mb-4">
            Centang jika kondisi berikut ini dialami oleh ibu hamil.
            <span className="text-blue-600 ml-1">Tidak wajib diisi.</span>
          </p>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            <CheckboxItem
              name="anamnesis_multipara_pasangan_baru_sedang"
              label="Multipara dengan pasangan baru"
              description="Pernah melahirkan dengan pasangan berbeda"
            />
            <CheckboxItem
              name="anamnesis_teknologi_reproduksi_berbantu_sedang"
              label="Teknologi reproduksi berbantu"
              description="Kehamilan dengan IVF atau sejenisnya"
            />
            <CheckboxItem
              name="anamnesis_umur_diatas_35_tahun_sedang"
              label="Umur ≥ 35 tahun"
              description="Usia ibu saat hamil 35 tahun atau lebih"
            />
            <CheckboxItem
              name="anamnesis_nulipara_sedang"
              label="Nulipara"
              description="Belum pernah melahirkan sebelumnya"
            />
            <CheckboxItem
              name="anamnesis_jarak_kehamilan_diatas_10_tahun_sedang"
              label="Jarak kehamilan > 10 tahun"
              description="Jarak dengan kehamilan terakhir lebih dari 10 tahun"
            />
            <CheckboxItem
              name="anamnesis_riwayat_preeklampsia_keluarga_sedang"
              label="Riwayat keluarga preeklampsia"
              description="Ibu atau saudara perempuan pernah preeklampsia"
            />
            <CheckboxItem
              name="anamnesis_obesitas_imt_diatas_30_sedang"
              label="Obesitas (IMT > 30)"
              description="Indeks Massa Tubuh sebelum hamil > 30"
            />
          </div>
        </div>

        {/* Risiko Tinggi */}
        <div className="bg-white rounded-xl shadow-sm p-5">
          <h3 className="font-bold text-[22px] text-[#A32D2D] border-b pb-2 flex items-center gap-2">
            <ShieldAlert size={20} /> Anamnesis - Risiko Tinggi
            <span className="text-sm font-normal text-gray-400 ml-2">(Opsional)</span>
          </h3>
          <p className="text-sm text-gray-500 mt-1 mb-4">
            Centang jika kondisi berikut ini dialami oleh ibu hamil.
            <span className="text-blue-600 ml-1">Tidak wajib diisi.</span>
          </p>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            <CheckboxItem
              name="anamnesis_riwayat_preeklampsia_sebelumnya_tinggi"
              label="Riwayat preeklampsia sebelumnya"
              description="Pernah mengalami preeklampsia pada kehamilan sebelumnya"
            />
            <CheckboxItem
              name="anamnesis_kehamilan_multipel_tinggi"
              label="Kehamilan multipel"
              description="Hamil kembar dua atau lebih"
            />
            <CheckboxItem
              name="anamnesis_diabetes_dalam_kehamilan_tinggi"
              label="Diabetes dalam kehamilan"
              description="Diabetes gestasional atau diabetes melitus"
            />
            <CheckboxItem
              name="anamnesis_hipertensi_kronik_tinggi"
              label="Hipertensi kronik"
              description="Tekanan darah tinggi sebelum hamil"
            />
            <CheckboxItem
              name="anamnesis_penyakit_ginjal_tinggi"
              label="Penyakit ginjal"
              description="Riwayat penyakit ginjal kronis"
            />
            <CheckboxItem
              name="anamnesis_penyakit_autoimun_sle_tinggi"
              label="Penyakit autoimun (SLE)"
              description="Lupus atau penyakit autoimun lainnya"
            />
            <CheckboxItem
              name="anamnesis_anti_phospholipid_syndrome_tinggi"
              label="Anti phospholipid syndrome"
              description="Gangguan pembekuan darah autoimun"
            />
          </div>
        </div>
        <div className="mt-4">
          <label className="block font-semibold mb-2 text-sm text-gray-800">
            Kesimpulan Klinis (Opsional)
          </label>
          <textarea
            name="kesimpulan"
            value={form.kesimpulan}
            onChange={handleChange}
            disabled={!canEdit}
            className="w-full border border-gray-300 rounded-lg px-4 py-3 text-sm focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5]"
            rows="3"
            placeholder="Tambahkan catatan khusus hasil skrining..."
          />
        </div>

        {/* Pemeriksaan Fisik */}
        <div className="bg-white rounded-xl shadow-sm p-5">
          <h3 className="font-bold text-[22px] text-[#185FA5] border-b pb-2 flex items-center gap-2">
            Pemeriksaan Fisik Khusus
            <span className="text-sm font-normal text-gray-400 ml-2">(Opsional)</span>
          </h3>
          <p className="text-sm text-gray-500 mt-1 mb-4">
            Centang jika hasil pemeriksaan menunjukkan kondisi berikut.
            <span className="text-blue-600 ml-1">Tidak wajib diisi.</span>
          </p>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            <CheckboxItem
              name="fisik_map_diatas_90_mmhg"
              label="MAP > 90 mmHg"
              description="MAP = Mean Arterial Pressure (tekanan arteri rata-rata)"
            />
            <CheckboxItem
              name="fisik_proteinuria_urin_celup"
              label="Proteinuria (urin celup > +1)"
              description="Protein dalam urine menandakan gangguan ginjal"
            />
          </div>
          <div className="mt-4">
            <label className="block font-semibold mb-2 text-base text-gray-800">
              Kesimpulan Klinis (Opsional)
            </label>
            <textarea
              name="kesimpulan"
              value={form.kesimpulan}
              onChange={handleChange}
              disabled={!canEdit}
              className="w-full border border-gray-300 rounded-lg px-4 py-3 text-base focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5]"
              rows="3"
              placeholder="Tambahkan catatan khusus hasil skrining..."
            />
          </div>
        </div>

        {canEdit && (
          <div className="flex justify-end gap-4">
            <button
              type="button"
              onClick={() => setIsEditing(false)}
              className="px-5 py-2.5 border border-[#185FA5] text-[#185FA5] rounded-full font-semibold text-base hover:bg-[#185FA5]/5"
            >
              Batal
            </button>
            <button
              type="submit"
              disabled={saving}
              className="bg-[#185FA5] text-white rounded-full px-6 py-2.5 flex items-center gap-2 text-base font-semibold hover:bg-[#185FA5]/90 disabled:opacity-50"
            >
              <Save size={18} /> {saving ? "Menyimpan..." : "Simpan Skrining"}
            </button>
          </div>
        )}
      </form>
    );
  };

  if (loading)
    return (
      <MainLayout>
        <div className="min-h-screen flex items-center justify-center bg-[#F7FAFB]">
          <div className="text-[#185FA5] text-lg">Memuat data...</div>
        </div>
      </MainLayout>
    );
  if (!kehamilan)
    return (
      <MainLayout>
        <div className="min-h-screen flex items-center justify-center bg-[#F7FAFB]">
          <div className="text-[#A32D2D] text-lg">Error: Kehamilan tidak ditemukan</div>
        </div>
      </MainLayout>
    );

  return (
    <MainLayout>
      <div className="min-h-screen bg-[#F7FAFB]">
        <div className="max-w-5xl mx-auto p-5 space-y-6">
          <div className="flex items-center gap-4">
            <button
              onClick={() => navigate(-1)}
              className="p-2 rounded-full hover:bg-gray-100 transition"
            >
              <ArrowLeft size={20} className="text-[#185FA5]" />
            </button>
            <h1 className="text-[28px] font-bold text-gray-900">Skrining Preeklampsia</h1>
          </div>

          {!isActive && (
            <div className="bg-blue-50 border border-blue-200 p-3 rounded-lg text-blue-700 text-base flex items-center gap-2">
              <EyeOff size={16} /> Kehamilan ini sudah selesai (NON-AKTIF). Data hanya dapat dilihat, tidak dapat diubah.
            </div>
          )}
          {!canEdit && isActive && (
            <div className="bg-blue-50 border border-blue-200 p-3 rounded-lg text-blue-700 text-base flex items-center gap-2">
              <Eye size={16} /> Anda dalam mode baca (Dokter). Data hanya dapat dilihat, tidak dapat diubah.
            </div>
          )}

          {isEditing ? <FormView /> : <ResultView />}
        </div>
      </div>
    </MainLayout>
  );
} 