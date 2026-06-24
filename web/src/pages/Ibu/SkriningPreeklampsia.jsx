// src/pages/Ibu/SkriningPreeklampsia.jsx
import React, { useEffect, useState } from "react";
import { useParams, useSearchParams, useNavigate } from "react-router-dom";
import Swal from "sweetalert2";
import MainLayout from "../../components/Layout/MainLayout";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import { getSkriningByKehamilanId, createSkrining, updateSkrining } from "../../services/skrining";
import { getCurrentUser, isBidanUser } from "../../services/auth";
import {
  AlertCircle,
  Save,
  ArrowLeft,
  ShieldAlert,
  CheckCircle2,
  Edit2,
  Plus,
  Heart,
  Eye,
  ClipboardList,
  EyeOff,
  XCircle,
  AlertTriangle,
  Info,
} from "lucide-react";

export default function SkriningPreeklampsia() {
  const { id: ibuId } = useParams();
  const [searchParams] = useSearchParams();
  const kehamilanId = searchParams.get("kehamilan_id");
  const navigate = useNavigate();

  const user = getCurrentUser();
  const isBidan = isBidanUser(user);

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

  const riskFactorKeys = [
    "anamnesis_multipara_pasangan_baru_sedang",
    "anamnesis_teknologi_reproduksi_berbantu_sedang",
    "anamnesis_umur_diatas_35_tahun_sedang",
    "anamnesis_nulipara_sedang",
    "anamnesis_jarak_kehamilan_diatas_10_tahun_sedang",
    "anamnesis_riwayat_preeklampsia_keluarga_sedang",
    "anamnesis_obesitas_imt_diatas_30_sedang",
    "anamnesis_riwayat_preeklampsia_sebelumnya_tinggi",
    "anamnesis_kehamilan_multipel_tinggi",
    "anamnesis_diabetes_dalam_kehamilan_tinggi",
    "anamnesis_hipertensi_kronik_tinggi",
    "anamnesis_penyakit_ginjal_tinggi",
    "anamnesis_penyakit_autoimun_sle_tinggi",
    "anamnesis_anti_phospholipid_syndrome_tinggi",
    "fisik_map_diatas_90_mmhg",
    "fisik_proteinuria_urin_celup",
  ];

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const kehamilanList = await getKehamilanByIbuId(ibuId);
        if (!kehamilanList.length) {
          Swal.fire({
            icon: "info",
            title: "Data Tidak Tersedia",
            text: "Ibu belum memiliki data kehamilan.",
            confirmButtonColor: "#185FA5",
          });
          navigate(`/data-ibu/${ibuId}`);
          return;
        }

        let targetKehamilan = null;
        if (kehamilanId) {
          targetKehamilan = kehamilanList.find((k) => k.id == kehamilanId);
          if (!targetKehamilan) {
            Swal.fire({
              icon: "error",
              title: "Tidak Ditemukan",
              text: `Kehamilan dengan ID ${kehamilanId} tidak ditemukan.`,
            });
            navigate(`/data-ibu/${ibuId}`);
            return;
          }
        } else {
          targetKehamilan = kehamilanList[0];
        }
        setKehamilan(targetKehamilan);
        setIsActive(targetKehamilan.status_kehamilan !== "TIDAK AKTIF");

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
          icon: "error",
          title: "Kesalahan",
          text: "Gagal memuat data. Silakan coba lagi.",
        });
      } finally {
        setLoading(false);
      }
    };
    if (ibuId) fetchData();
  }, [ibuId, kehamilanId, navigate, searchParams, canEdit]);

  const handleChange = (e) => {
    if (!canEdit) return;
    const { name, value, type, checked } = e.target;
    setForm((prev) => ({ ...prev, [name]: type === "checkbox" ? checked : value }));
  };

  const hasRiskFactors = () => riskFactorKeys.some((key) => form[key] === true);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!canEdit) {
      Swal.fire({
        icon: "error",
        title: "Akses Ditolak",
        text: "Anda tidak memiliki izin untuk mengubah data.",
      });
      return;
    }

    if (!kehamilan) {
      Swal.fire({
        icon: "error",
        title: "Kesalahan",
        text: "Data kehamilan tidak ditemukan.",
      });
      return;
    }

    if (!hasRiskFactors()) {
      const confirm = await Swal.fire({
        icon: "info",
        title: "Konfirmasi",
        text: 'Anda belum memilih faktor risiko apapun. Status risiko akan otomatis menjadi "TIDAK PERLU RUJUKAN". Lanjutkan?',
        showCancelButton: true,
        confirmButtonColor: "#185FA5",
        cancelButtonColor: "#A32D2D",
        confirmButtonText: "Ya, Lanjutkan",
        cancelButtonText: "Batal",
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
        icon: "success",
        title: "Berhasil",
        text: "Skrining preeklampsia berhasil disimpan!",
        timer: 2000,
        showConfirmButton: false,
      });

      setIsEditing(false);
      const refreshed = await getSkriningByKehamilanId(kehamilan.id);
      if (refreshed && refreshed.length > 0) setSkrining(refreshed[0]);
    } catch (err) {
      console.error(err);

      if (err.response?.status === 409 || err.message?.includes("duplicate")) {
        Swal.fire({
          icon: "info",
          title: "Data Sudah Ada",
          text: "Skrining untuk kehamilan ini sudah ada. Silakan refresh halaman.",
          confirmButtonColor: "#185FA5",
        });
      } else {
        Swal.fire({
          icon: "error",
          title: "Gagal Menyimpan",
          text: err.response?.data?.message || err.message || "Terjadi kesalahan.",
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

    if (risikoSedang === 0 && risikoTinggi === 0 && !map && !protein) {
      return "TIDAK PERLU RUJUKAN";
    }

    if (risikoTinggi >= 1 || risikoSedang >= 2 || map || protein) {
      return "PERLU RUJUKAN";
    }
    return "TIDAK PERLU RUJUKAN";
  };

  const isRujukan = hitungRisiko() === "PERLU RUJUKAN";

  const handleRujukClick = (e) => {
    e.preventDefault();
    Swal.fire({
      title: "Konfirmasi Rujukan",
      text: `Ibu ini memiliki status risiko preeklampsia "${hitungRisiko()}". Lanjutkan ke form rujukan?`,
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#A32D2D",
      cancelButtonColor: "#6B7280",
      confirmButtonText: "Ya, Rujuk",
      cancelButtonText: "Batal",
      reverseButtons: true,
    }).then((result) => {
      if (result.isConfirmed) {
        navigate(`/data-ibu/${ibuId}/rujukan?kehamilan_id=${kehamilan.id}&source=preeklampsia`);
      }
    });
  };

  const CheckboxItem = ({ name, label, description }) => {
    const isChecked = form[name];
    return (
      <label className="flex items-start gap-3 p-3 rounded-lg border border-gray-200 hover:bg-gray-50 cursor-pointer transition font-sans">
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

  const ResultView = () => {
    if (!skrining) {
      return (
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-10 text-center font-sans">
          <div className="flex flex-col items-center gap-4">
            <div className="p-5 rounded-full" style={{ backgroundColor: "#EBF3FC" }}>
              <ClipboardList size={40} style={{ color: "#185FA5" }} />
            </div>
            <h3 className="text-lg font-bold text-gray-800">Tidak Ada Data Skrining Preeklampsia</h3>
            <p className="text-sm text-gray-500 max-w-sm">
              Tidak ada data skrining preeklampsia untuk kehamilan ini. Tambah data untuk memulai pemantauan risiko
              preeklampsia.
            </p>
            {canEdit ? (
              <button
                onClick={() => setIsEditing(true)}
                className="text-white px-6 py-2.5 rounded-full font-semibold flex items-center gap-2 text-sm transition hover:opacity-90"
                style={{ backgroundColor: "#185FA5" }}
              >
                <Plus size={16} /> Tambah Skrining Preeklampsia
              </button>
            ) : (
              <p className="text-xs text-gray-400 mt-1">
                {!isActive
                  ? "Kehamilan ini sudah selesai (Tidak Aktif), tidak dapat menambah data baru."
                  : "Hanya Bidan yang dapat menambah data Skrining Preeklampsia."}
              </p>
            )}
          </div>
        </div>
      );
    }

    const hasSelectedRisk = riskFactorKeys.some((key) => skrining[key] === true);

    // Daftar item per kategori
    const sedangItems = [
      { key: "anamnesis_multipara_pasangan_baru_sedang", label: "Multipara dengan pasangan baru", desc: "Pernah melahirkan dengan pasangan berbeda" },
      { key: "anamnesis_teknologi_reproduksi_berbantu_sedang", label: "Teknologi reproduksi berbantu", desc: "Kehamilan dengan IVF atau sejenisnya" },
      { key: "anamnesis_umur_diatas_35_tahun_sedang", label: "Umur ≥ 35 tahun", desc: "Usia ibu saat hamil 35 tahun atau lebih" },
      { key: "anamnesis_nulipara_sedang", label: "Nulipara", desc: "Belum pernah melahirkan sebelumnya" },
      { key: "anamnesis_jarak_kehamilan_diatas_10_tahun_sedang", label: "Jarak kehamilan > 10 tahun", desc: "Jarak dengan kehamilan terakhir lebih dari 10 tahun" },
      { key: "anamnesis_riwayat_preeklampsia_keluarga_sedang", label: "Riwayat keluarga preeklampsia", desc: "Ibu atau saudara perempuan pernah preeklampsia" },
      { key: "anamnesis_obesitas_imt_diatas_30_sedang", label: "Obesitas (IMT > 30)", desc: "Indeks Massa Tubuh sebelum hamil > 30" },
    ].filter((item) => skrining[item.key]);

    const tinggiItems = [
      { key: "anamnesis_riwayat_preeklampsia_sebelumnya_tinggi", label: "Riwayat preeklampsia sebelumnya", desc: "Pernah mengalami preeklampsia pada kehamilan sebelumnya" },
      { key: "anamnesis_kehamilan_multipel_tinggi", label: "Kehamilan multipel", desc: "Hamil kembar dua atau lebih" },
      { key: "anamnesis_diabetes_dalam_kehamilan_tinggi", label: "Diabetes dalam kehamilan", desc: "Diabetes gestasional atau diabetes melitus" },
      { key: "anamnesis_hipertensi_kronik_tinggi", label: "Hipertensi kronik", desc: "Tekanan darah tinggi sebelum hamil" },
      { key: "anamnesis_penyakit_ginjal_tinggi", label: "Penyakit ginjal", desc: "Riwayat penyakit ginjal kronis" },
      { key: "anamnesis_penyakit_autoimun_sle_tinggi", label: "Penyakit autoimun (SLE)", desc: "Lupus atau penyakit autoimun lainnya" },
      { key: "anamnesis_anti_phospholipid_syndrome_tinggi", label: "Anti phospholipid syndrome", desc: "Gangguan pembekuan darah autoimun" },
    ].filter((item) => skrining[item.key]);

    const fisikItems = [
      { key: "fisik_map_diatas_90_mmhg", label: "MAP > 90 mmHg", desc: "MAP = Mean Arterial Pressure (tekanan arteri rata-rata)" },
      { key: "fisik_proteinuria_urin_celup", label: "Proteinuria (urin celup > +1)", desc: "Protein dalam urine menandakan gangguan ginjal" },
    ].filter((item) => skrining[item.key]);

    return (
      <div className="space-y-6 font-sans">
        {/* Banner status risiko */}
        <div
          className={`p-5 rounded-2xl flex items-center justify-between shadow-sm border font-sans ${
            isRujukan
              ? "bg-[#A32D2D]/10 border-[#A32D2D]/30 text-[#A32D2D]"
              : "bg-[#3B6D11]/10 border-[#3B6D11]/30 text-[#3B6D11]"
          }`}
        >
          <div className="flex items-center gap-4">
            {isRujukan ? (
              <AlertTriangle size={36} className="text-[#A32D2D]" />
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

        {!hasSelectedRisk && (
          <div className="bg-gray-50 border border-gray-200 p-4 rounded-lg flex items-start gap-3 font-sans">
            <Info size={20} className="text-gray-400 mt-0.5 flex-shrink-0" />
            <div>
              <p className="text-gray-600 text-base">
                <span className="font-semibold">Informasi:</span> Belum ada faktor risiko yang dipilih. Status risiko
                otomatis menjadi <strong>"TIDAK PERLU RUJUKAN"</strong>.
              </p>
              <p className="text-sm text-gray-500 mt-1">
                Jika ada faktor risiko yang muncul di kemudian hari, Anda dapat mengubah skrining ini.
              </p>
            </div>
          </div>
        )}

        <div className="bg-white rounded-xl shadow-sm overflow-hidden font-sans">
          <div className="bg-[#185FA5] px-5 py-3">
            <div className="flex items-center gap-2">
              <Heart size={22} className="text-white" />
              <h3 className="text-xl font-bold text-white">Detail Skrining Preeklampsia</h3>
            </div>
          </div>
          <div className="p-5 space-y-6">
            {/* Risiko Sedang */}
            {sedangItems.length > 0 && (
              <div>
                <h4 className="font-semibold text-[#BA7517] text-lg flex items-center gap-2 mb-3">
                  <AlertCircle size={18} /> Risiko Sedang
                </h4>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                  {sedangItems.map((item) => (
                    <div
                      key={item.key}
                      className="p-3 rounded-lg border border-[#BA7517]/30 bg-[#FEF3CD]"
                    >
                      <span className="text-sm font-semibold text-gray-900">{item.label}</span>
                      {item.desc && <p className="text-xs text-gray-600 mt-0.5">{item.desc}</p>}
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Risiko Tinggi */}
            {tinggiItems.length > 0 && (
              <div>
                <h4 className="font-semibold text-[#A32D2D] text-lg flex items-center gap-2 mb-3">
                  <AlertTriangle size={18} /> Risiko Tinggi
                </h4>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                  {tinggiItems.map((item) => (
                    <div
                      key={item.key}
                      className="p-3 rounded-lg border border-[#A32D2D]/30 bg-[#FBE9E9]"
                    >
                      <span className="text-sm font-semibold text-gray-900">{item.label}</span>
                      {item.desc && <p className="text-xs text-gray-600 mt-0.5">{item.desc}</p>}
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Pemeriksaan Fisik */}
            {fisikItems.length > 0 && (
              <div>
                <h4 className="font-semibold text-[#0F6E56] text-lg mb-3">Pemeriksaan Fisik</h4>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                  {fisikItems.map((item) => (
                    <div
                      key={item.key}
                      className="p-3 rounded-lg border border-[#0F6E56]/30 bg-[#EDF7E6]"
                    >
                      <span className="text-sm font-semibold text-gray-900">{item.label}</span>
                      {item.desc && <p className="text-xs text-gray-600 mt-0.5">{item.desc}</p>}
                    </div>
                  ))}
                </div>
              </div>
            )}

            {skrining.kesimpulan_skrining_preeklampsia && (
              <div className="bg-blue-50 p-3 rounded-lg">
                <h4 className="font-semibold text-blue-900 text-base">Kesimpulan Klinis</h4>
                <p className="text-blue-800 text-base">{skrining.kesimpulan_skrining_preeklampsia}</p>
              </div>
            )}
          </div>
        </div>

        <div className="flex flex-wrap gap-3 justify-between">
          <button
    
          >
            {/* <ArrowLeft size={18} /> Kembali */}
          </button>
          <div className="flex flex-wrap gap-3">
            {canEdit && (
              <button
                onClick={() => setIsEditing(true)}
                className="bg-[#BA7517] text-white rounded-full px-5 py-2.5 flex items-center gap-2 text-base font-semibold hover:opacity-90 transition"
              >
                <Edit2 size={18} /> Ubah Skrining
              </button>
            )}
            {isRujukan && canEdit && (
              <button
                onClick={handleRujukClick}
                className="bg-[#A32D2D] hover:bg-[#A32D2D]/90 text-white rounded-full px-5 py-2.5 flex items-center gap-2 text-base font-semibold shadow-md hover:shadow-lg transition"
              >
                <AlertTriangle size={18} /> Rujuk Segera
              </button>
            )}
          </div>
        </div>
      </div>
    );
  };

  const FormView = () => {
    const hasSelectedRisk = hasRiskFactors();

    return (
      <form onSubmit={handleSubmit} className="space-y-8 font-sans">
        {/* Banner informasi */}
        <div className="bg-blue-50 border border-blue-200 p-4 rounded-lg flex items-start gap-3 font-sans">
          <Info size={20} className="text-blue-600 mt-0.5 flex-shrink-0" />
          <div>
            <p className="text-blue-700 text-base font-medium">ℹ️ Semua Faktor Risiko Bersifat Opsional</p>
            <p className="text-blue-600 text-sm mt-1">
              Anda dapat menyimpan skrining tanpa memilih faktor risiko apapun. Status risiko akan otomatis menjadi{" "}
              <strong>"TIDAK PERLU RUJUKAN"</strong>.
            </p>
            {!hasSelectedRisk && (
              <p className="text-blue-600 text-sm mt-2 font-medium">
                ⚠️ Saat ini belum ada faktor risiko yang dipilih.
              </p>
            )}
          </div>
        </div>

        {/* Risiko Sedang */}
        <div className="bg-white rounded-xl shadow-sm p-5 font-sans">
          <h3 className="font-bold text-base sm:text-lg md:text-[22px] text-[#BA7517] border-b pb-2 flex items-center gap-2">
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
        <div className="bg-white rounded-xl shadow-sm p-5 font-sans">
          <h3 className="font-bold text-base sm:text-lg md:text-[22px] text-[#A32D2D] border-b pb-2 flex items-center gap-2">
            <AlertTriangle size={20} /> Anamnesis - Risiko Tinggi
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

        {/* Kesimpulan (sebelum fisik) */}
        <div className="mt-4 font-sans">
          <label className="block font-semibold mb-2 text-sm text-gray-800">Kesimpulan Klinis (Opsional)</label>
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
        <div className="bg-white rounded-xl shadow-sm p-5 font-sans">
          <h3 className="font-bold text-base sm:text-lg md:text-[22px] text-[#0F6E56] border-b pb-2 flex items-center gap-2">
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
        </div>

        {canEdit && (
          <div className="flex justify-end gap-4">
            <button
              type="button"
              onClick={() => setIsEditing(false)}
              className="px-5 py-2.5 border border-[#185FA5] text-[#185FA5] rounded-full font-semibold text-base hover:bg-[#185FA5]/5 transition"
            >
              Batal
            </button>
            <button
              type="submit"
              disabled={saving}
              className="bg-[#3B6D11] text-white rounded-full px-6 py-2.5 flex items-center gap-2 text-base font-semibold hover:opacity-90 disabled:opacity-50 transition"
            >
              <Save size={18} /> {saving ? "Menyimpan..." : "Simpan"}
            </button>
          </div>
        )}
      </form>
    );
  };

  if (loading)
    return (
      <MainLayout>
        <div className="min-h-screen flex items-center justify-center bg-[#F7FAFB] font-sans">
          <div className="text-[#185FA5] text-lg">Memuat Data...</div>
        </div>
      </MainLayout>
    );
  if (!kehamilan)
    return (
      <MainLayout>
        <div className="min-h-screen flex items-center justify-center bg-[#F7FAFB] font-sans">
          <div className="text-[#A32D2D] text-lg">Kesalahan: Kehamilan tidak ditemukan</div>
        </div>
      </MainLayout>
    );

  return (
    <MainLayout>
      <div className="min-h-screen bg-[#F7FAFB] font-sans">
        <div className="max-w-5xl mx-auto p-5 space-y-6">
          <div className="flex items-center gap-4">
            <button
              onClick={() => navigate(-1)}
              className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full border border-[#185FA5] text-[#185FA5] text-sm font-semibold hover:bg-[#185FA5]/5 transition"
            >
              <ArrowLeft size={16} />
              <span>Kembali</span>
            </button>
            <div>
              <h1 className="text-lg sm:text-2xl md:text-[28px] font-bold text-gray-900">Skrining Preeklampsia</h1>
              <p className="text-sm text-gray-600 mt-1">Deteksi dini risiko preeklampsia pada ibu hamil berdasarkan faktor anamnesis dan pemeriksaan fisik</p>
            </div>
          </div>

          <div className="bg-[#E1F5EE] border-2 border-[#0F6E56]/20 rounded-xl p-4 flex items-start gap-3 font-sans">
            <ClipboardList size={20} className="text-[#0F6E56] mt-0.5 flex-shrink-0" />
            <div>
              <p className="font-semibold text-[#085041] text-sm">Skrining Trimester 2</p>
              <p className="text-[#085041]/80 text-sm mt-0.5">
                Halaman ini adalah pengisian skrining preeklampsia yang digunakan untuk keperluan data pemantauan Trimester
                2. Silakan lengkapi data skrining berikut sesuai dengan hasil pemeriksaan.
              </p>
            </div>
          </div>

          {!isActive && (
            <div className="bg-blue-50 border border-blue-200 p-3 rounded-lg text-blue-700 text-base flex items-center gap-2 font-sans">
              <EyeOff size={16} /> Kehamilan ini sudah selesai (Tidak Aktif). Data hanya dapat dilihat, tidak dapat diubah.
            </div>
          )}
          {!canEdit && isActive && (
            <div className="bg-blue-50 border border-blue-200 p-3 rounded-lg text-blue-700 text-base flex items-center gap-2 font-sans">
              <Eye size={16} /> Anda dalam mode baca (Dokter). Data hanya dapat dilihat, tidak dapat diubah.
            </div>
          )}

          {isEditing ? <FormView /> : <ResultView />}
        </div>
      </div>
    </MainLayout>
  );
}