// src/pages/Ibu/SkriningDMGestasional.jsx
import React, { useEffect, useState } from "react";
import { useParams, useNavigate, useSearchParams } from "react-router-dom";
import Swal from "sweetalert2";
import MainLayout from "../../components/Layout/MainLayout";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import {
  getSkriningDMByKehamilanId,
  createSkriningDM,
  updateSkriningDM,
} from "../../services/rujukanService";
import { getCurrentUser, isDokterUser } from "../../services/auth";
import {
  Save,
  ArrowLeft,
  Loader2,
  Edit,
  Plus,
  X,
  Eye,
  EyeOff,
  AlertCircle,
} from "lucide-react";

export default function SkriningDMGestasional() {
  const { id: ibuId } = useParams();
  const [searchParams] = useSearchParams();
  const kehamilanId = searchParams.get("kehamilan_id");
  const navigate = useNavigate();

  const user = getCurrentUser();
  const isDokter = isDokterUser(user);

  const [kehamilan, setKehamilan] = useState(null);
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [showForm, setShowForm] = useState(false);
  const [isActive, setIsActive] = useState(true);
  const [errors, setErrors] = useState({});

  const canEdit = isDokter && isActive;
  // Tambahkan di bagian state declarations
  const [usiaKehamilanSaatIni, setUsiaKehamilanSaatIni] = useState(0);
  const [isLateSkrining, setIsLateSkrining] = useState(false);
  const [isEarlySkrining, setIsEarlySkrining] = useState(false);

  // Fungsi untuk menghitung usia kehamilan dari HPHT
  const hitungUsiaKehamilanDariHPHT = (hpht, tanggalPeriksa = null) => {
    if (!hpht) return null;

    let hphtDate = new Date(hpht);
    if (isNaN(hphtDate.getTime())) {
      const parts = String(hpht).split("T")[0].split("-");
      if (parts.length === 3)
        hphtDate = new Date(parts[0], parts[1] - 1, parts[2]);
    }
    if (isNaN(hphtDate.getTime())) return null;

    let periksaDate = tanggalPeriksa ? new Date(tanggalPeriksa) : new Date();
    if (isNaN(periksaDate.getTime())) periksaDate = new Date();

    const diffDays = Math.floor(
      (periksaDate - hphtDate) / (1000 * 60 * 60 * 24),
    );
    if (diffDays < 0) return { minggu: 0, hari: 0, display: "0 minggu 0 hari" };

    const minggu = Math.floor(diffDays / 7);
    const hari = diffDays % 7;
    return { minggu, hari, display: `${minggu} minggu ${hari} hari` };
  };

  // Cek status skrining berdasarkan usia
  const getSkriningStatus = (usiaMinggu) => {
    if (usiaMinggu < 24) {
      return {
        type: "early",
        message:
          "⚠️ Peringatan: Usia kehamilan masih terlalu dini untuk skrining DM Gestasional (ideal: 24-28 minggu). Hasil skrining mungkin belum akurat.",
      };
    } else if (usiaMinggu > 28) {
      return {
        type: "late",
        message:
          "⚠️ Peringatan: Usia kehamilan sudah melewati waktu ideal skrining DM Gestasional (ideal: 24-28 minggu). Segera konsultasikan hasil dengan dokter.",
      };
    } else {
      return {
        type: "optimal",
        message: "✅ Waktu skrining optimal (24-28 minggu).",
      };
    }
  };
  const [form, setForm] = useState({
    gula_darah_puasa_hasil: "",
    gula_darah_puasa_rencana_tindak_lanjut: "",
    gula_darah_2_jam_post_prandial_hasil: "",
    gula_darah_2_jam_post_prandial_rencana_tindak_lanjut: "",
  });

  // Validasi form: hanya field hasil yang wajib diisi (harus angka, tidak negatif)
  const validateForm = () => {
    const newErrors = {};
    if (
      !form.gula_darah_puasa_hasil ||
      form.gula_darah_puasa_hasil.trim() === ""
    ) {
      newErrors.gula_darah_puasa_hasil = "Hasil gula darah puasa wajib diisi";
    } else if (isNaN(parseFloat(form.gula_darah_puasa_hasil))) {
      newErrors.gula_darah_puasa_hasil = "Hasil harus berupa angka";
    } else if (parseFloat(form.gula_darah_puasa_hasil) < 0) {
      newErrors.gula_darah_puasa_hasil = "Hasil tidak boleh negatif";
    }

    if (
      !form.gula_darah_2_jam_post_prandial_hasil ||
      form.gula_darah_2_jam_post_prandial_hasil.trim() === ""
    ) {
      newErrors.gula_darah_2_jam_post_prandial_hasil =
        "Hasil gula darah 2 jam post prandial wajib diisi";
    } else if (isNaN(parseFloat(form.gula_darah_2_jam_post_prandial_hasil))) {
      newErrors.gula_darah_2_jam_post_prandial_hasil =
        "Hasil harus berupa angka";
    } else if (parseFloat(form.gula_darah_2_jam_post_prandial_hasil) < 0) {
      newErrors.gula_darah_2_jam_post_prandial_hasil =
        "Hasil tidak boleh negatif";
    }

    // Rencana tindak lanjut boleh kosong, tidak divalidasi

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const fetchData = async () => {
    try {
      setLoading(true);
      const kehamilanList = await getKehamilanByIbuId(ibuId);
      if (!kehamilanList.length) {
        Swal.fire({
          icon: "info",
          title: "Informasi",
          text: "Ibu belum memiliki data kehamilan.",
          confirmButtonColor: "#4f46e5",
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
      setIsActive(targetKehamilan.status_kehamilan !== "NON-AKTIF");

      // HITUNG USIA KEHAMILAN
      let usiaMinggu = targetKehamilan.uk_kehamilan_saat_ini;

      if (!usiaMinggu && targetKehamilan.hpht) {
        const usia = hitungUsiaKehamilanDariHPHT(targetKehamilan.hpht);
        usiaMinggu = usia?.minggu || 0;
      }
      setUsiaKehamilanSaatIni(usiaMinggu);

      // SET STATUS SKRINING
      setIsEarlySkrining(usiaMinggu < 24);
      setIsLateSkrining(usiaMinggu > 28);

      const result = await getSkriningDMByKehamilanId(targetKehamilan.id);
      if (result && result.length > 0) {
        const d = result[0];
        setData(d);
        setForm({
          gula_darah_puasa_hasil: d.gula_darah_puasa_hasil?.toString() || "",
          gula_darah_puasa_rencana_tindak_lanjut:
            d.gula_darah_puasa_rencana_tindak_lanjut || "",
          gula_darah_2_jam_post_prandial_hasil:
            d.gula_darah_2_jam_post_prandial_hasil?.toString() || "",
          gula_darah_2_jam_post_prandial_rencana_tindak_lanjut:
            d.gula_darah_2_jam_post_prandial_rencana_tindak_lanjut || "",
        });
      } else {
        setData(null);
        setForm({
          gula_darah_puasa_hasil: "",
          gula_darah_puasa_rencana_tindak_lanjut: "",
          gula_darah_2_jam_post_prandial_hasil: "",
          gula_darah_2_jam_post_prandial_rencana_tindak_lanjut: "",
        });
      }
    } catch (err) {
      console.error(err);
      Swal.fire({
        icon: "error",
        title: "Gagal Memuat Data",
        text: "Terjadi kesalahan saat mengambil data skrining DM.",
      });
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, [ibuId, kehamilanId, navigate]);

  const handleChange = (e) => {
    if (!canEdit) return;
    const { name, value } = e.target;
    setForm({ ...form, [name]: value });
    // Hapus error field yang sedang diedit
    if (errors[name]) {
      setErrors({ ...errors, [name]: "" });
    }
  };

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
    // TAMPILKAN PERINGATAN SEBELUM MENYIMPAN (TAPI TETAP BISA SIMPAN)
    if (isEarlySkrining || isLateSkrining) {
      const result = await Swal.fire({
        icon: isEarlySkrining ? "warning" : "error",
        title: isEarlySkrining
          ? "Konfirmasi Penyimpanan"
          : "Peringatan Skrining Terlambat",
        html: isEarlySkrining
          ? `Usia kehamilan saat ini: <strong>${usiaKehamilanSaatIni} minggu</strong><br/><br/>
           Skrining DM Gestasional idealnya dilakukan pada usia <strong>24-28 minggu</strong>.<br/><br/>
           Hasil yang disimpan sekarang mungkin belum akurat.<br/><br/>
           <strong>Apakah Anda tetap ingin menyimpan data?</strong>`
          : `Usia kehamilan saat ini: <strong>${usiaKehamilanSaatIni} minggu</strong><br/><br/>
           Waktu ideal skrining DM Gestasional adalah <strong>24-28 minggu</strong>.<br/><br/>
           Anda akan menyimpan skrining yang sudah <strong>terlambat</strong>.<br/><br/>
           <strong>Apakah Anda tetap ingin melanjutkan?</strong>`,
        showCancelButton: true,
        confirmButtonText: "Tetap Simpan",
        cancelButtonText: "Batal",
        confirmButtonColor: "#185FA5",
        cancelButtonColor: "#d33",
      });

      if (!result.isConfirmed) {
        return;
      }
    }
    if (!kehamilan) {
      Swal.fire({
        icon: "error",
        title: "Data Tidak Ditemukan",
        text: "Data kehamilan tidak ditemukan.",
      });
      return;
    }

    // Validasi sebelum submit
    if (!validateForm()) {
      Swal.fire({
        icon: "warning",
        title: "Data Belum Lengkap",
        text: "Harap isi semua hasil pemeriksaan (nilai gula darah) dengan benar.",
        confirmButtonColor: "#185FA5",
      });
      return;
    }

    setSaving(true);
    try {
      const payload = {
        kehamilan_id: kehamilan.id,
        gula_darah_puasa_hasil: form.gula_darah_puasa_hasil,
        gula_darah_puasa_rencana_tindak_lanjut:
          form.gula_darah_puasa_rencana_tindak_lanjut,
        gula_darah_2_jam_post_prandial_hasil:
          form.gula_darah_2_jam_post_prandial_hasil,
        gula_darah_2_jam_post_prandial_rencana_tindak_lanjut:
          form.gula_darah_2_jam_post_prandial_rencana_tindak_lanjut,
      };

      if (data) {
        await updateSkriningDM(data.id_skrining_dm, payload);
      } else {
        await createSkriningDM(payload);
      }
      if (isLateSkrining) {
        await Swal.fire({
          icon: "success",
          title: "Data Tersimpan",
          html: "Skrining DM Gestasional berhasil disimpan.<br/><br/>⚠️ <strong>Catatan Penting:</strong> Skrining ini dilakukan setelah melewati masa optimal (24-28 minggu). Segera konsultasikan hasil dengan dokter kandungan untuk penanganan lebih lanjut.",
          confirmButtonColor: "#185FA5",
        });
      } else if (isEarlySkrining) {
        await Swal.fire({
          icon: "success",
          title: "Data Tersimpan",
          html: "Skrining DM Gestasional berhasil disimpan.<br/><br/>⚠️ <strong>Catatan Penting:</strong> Skrining ini dilakukan pada usia kehamilan yang masih dini. Pertimbangkan untuk mengulang skrining pada usia 24-28 minggu.",
          confirmButtonColor: "#185FA5",
        });
      } else {
        await Swal.fire({
          icon: "success",
          title: "Berhasil",
          text: "Skrining DM Gestasional berhasil disimpan.",
          timer: 2000,
          showConfirmButton: false,
        });
      }

      await fetchData();
      setShowForm(false);
      setErrors({});
    } catch (err) {
      console.error(err);
      Swal.fire({
        icon: "error",
        title: "Error",
        text: "Gagal menyimpan data skrining DM. Silakan coba lagi.",
      });
    } finally {
      setSaving(false);
    }
  };

  const handleEdit = () => {
    if (!canEdit) {
      Swal.fire({
        icon: "error",
        title: "Akses Ditolak",
        text: "Anda tidak memiliki izin untuk mengubah data.",
      });
      return;
    }
    // TAMPILKAN PERINGATAN TAPI TETAP LANJUTKAN
    if (isEarlySkrining) {
      Swal.fire({
        icon: "warning",
        title: "Usia Kehamilan Terlalu Dini",
        html: `Usia kehamilan saat ini: <strong>${usiaKehamilanSaatIni} minggu</strong><br/><br/>
             Skrining DM Gestasional idealnya dilakukan pada usia kehamilan <strong>24-28 minggu</strong>.<br/><br/>
             Hasil skrining yang direkam saat usia dini mungkin belum akurat.<br/><br/>
             <strong>Apakah Anda tetap ingin mengedit?</strong>`,
        showCancelButton: true,
        confirmButtonText: "Tetap Lanjutkan",
        cancelButtonText: "Batal",
        confirmButtonColor: "#185FA5",
        cancelButtonColor: "#d33",
      }).then((result) => {
        if (result.isConfirmed) {
          setShowForm(true);
          setErrors({});
        }
      });
      return;
    }

    if (isLateSkrining) {
      Swal.fire({
        icon: "error",
        title: "Sudah Melewati Waktu Skrining Optimal",
        html: `Usia kehamilan saat ini: <strong>${usiaKehamilanSaatIni} minggu</strong><br/><br/>
             Skrining DM Gestasional seharusnya dilakukan pada usia <strong>24-28 minggu</strong>.<br/><br/>
             Data yang diedit sekarang sudah melewati masa skrining optimal.<br/><br/>
             <strong>Apakah Anda tetap ingin melanjutkan?</strong>`,
        showCancelButton: true,
        confirmButtonText: "Tetap Lanjutkan",
        cancelButtonText: "Batal",
        confirmButtonColor: "#d33",
        cancelButtonColor: "#185FA5",
      }).then((result) => {
        if (result.isConfirmed) {
          setShowForm(true);
          setErrors({});
        }
      });
      return;
    }
    setShowForm(true);
    setErrors({});
  };

  const handleAdd = () => {
    if (!canEdit) {
      Swal.fire({
        icon: "error",
        title: "Akses Ditolak",
        text: "Anda tidak memiliki izin untuk menambah data.",
      });
      return;
    }

    // TAMPILKAN PERINGATAN TAPI TETAP LANJUTKAN
    if (isEarlySkrining) {
      Swal.fire({
        icon: "warning",
        title: "Usia Kehamilan Terlalu Dini",
        html: `Usia kehamilan saat ini: <strong>${usiaKehamilanSaatIni} minggu</strong><br/><br/>
             Skrining DM Gestasional idealnya dilakukan pada usia kehamilan <strong>24-28 minggu</strong>.<br/><br/>
             Hasil skrining saat ini mungkin belum akurat.<br/><br/>
             <strong>Apakah Anda tetap ingin melanjutkan?</strong>`,
        showCancelButton: true,
        confirmButtonText: "Tetap Lanjutkan",
        cancelButtonText: "Batal",
        confirmButtonColor: "#185FA5",
        cancelButtonColor: "#d33",
      }).then((result) => {
        if (result.isConfirmed) {
          setShowForm(true);
          setErrors({});
        }
      });
      return;
    }

    if (isLateSkrining) {
      Swal.fire({
        icon: "error",
        title: "Sudah Melewati Waktu Skrining Optimal",
        html: `Usia kehamilan saat ini: <strong>${usiaKehamilanSaatIni} minggu</strong><br/><br/>
             Waktu ideal skrining DM Gestasional adalah <strong>24-28 minggu</strong>.<br/><br/>
             Skrining yang dilakukan sekarang sudah terlambat dan mungkin mempengaruhi rencana penanganan.<br/><br/>
             <strong>Apakah Anda tetap ingin melanjutkan?</strong>`,
        showCancelButton: true,
        confirmButtonText: "Tetap Lanjutkan",
        cancelButtonText: "Batal",
        confirmButtonColor: "#d33",
        cancelButtonColor: "#185FA5",
      }).then((result) => {
        if (result.isConfirmed) {
          setShowForm(true);
          setErrors({});
        }
      });
      return;
    }
    setShowForm(true);
    setErrors({});
  };

  const handleCancelForm = () => {
    setShowForm(false);
    setErrors({});
  };

  // Fungsi untuk menentukan status risiko
  const getStatusGDP = (nilai) => {
    if (!nilai) return null;
    const val = parseFloat(nilai);
    if (val < 92) return { text: "Normal", color: "#3B6D11", bg: "#E1F5EE" };
    if (val >= 92 && val < 126)
      return {
        text: "Gangguan Glukosa Puasa (Perlu Pantau)",
        color: "#BA7517",
        bg: "#FAEEDA",
      };
    return { text: "Diabetes (Rujuk)", color: "#A32D2D", bg: "#FCEBEB" };
  };

  const getStatus2Jam = (nilai) => {
    if (!nilai) return null;
    const val = parseFloat(nilai);
    if (val < 153) return { text: "Normal", color: "#3B6D11", bg: "#E1F5EE" };
    if (val >= 153 && val < 200)
      return {
        text: "Gangguan Toleransi Glukosa (Perlu Pantau)",
        color: "#BA7517",
        bg: "#FAEEDA",
      };
    return {
      text: "Diabetes Gestasional (Rujuk)",
      color: "#A32D2D",
      bg: "#FCEBEB",
    };
  };

  if (loading)
    return (
      <MainLayout>
        <div className="min-h-screen bg-[#F7FAFB] flex items-center justify-center">
          <div className="text-[#185FA5] text-base">Memuat data...</div>
        </div>
      </MainLayout>
    );

  return (
    <MainLayout>
      <div className="min-h-screen bg-[#F7FAFB]">
        <div className="max-w-5xl mx-auto p-5 space-y-6">
          {/* Header */}
          <div className="flex items-center gap-4">
            <button
              onClick={() => navigate(-1)}
              className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full border border-[#185FA5] text-[#185FA5] text-sm font-semibold hover:bg-[#185FA5]/5 transition"
            >
              <ArrowLeft size={16} />
              <span>Kembali</span>
            </button>
            <h1 className="text-[28px] font-bold text-gray-900">
              Skrining DM Gestasional
            </h1>
          </div>

          {/* Banner peringatan usia kehamilan */}
          {kehamilan && (isEarlySkrining || isLateSkrining) && !showForm && (
            <div
              className={`p-4 rounded-lg ${
                isEarlySkrining
                  ? "bg-yellow-50 border-l-4 border-yellow-500"
                  : "bg-red-50 border-l-4 border-red-500"
              }`}
            >
              <div className="flex items-start gap-3">
                <div className="flex-shrink-0">
                  {isEarlySkrining ? (
                    <AlertCircle size={20} className="text-yellow-600" />
                  ) : (
                    <AlertCircle size={20} className="text-red-600" />
                  )}
                </div>
                <div className="flex-1">
                  <p className="text-sm font-semibold text-gray-800">
                    {isEarlySkrining
                      ? "Peringatan: Usia Kehamilan Terlalu Dini"
                      : "Peringatan: Sudah Melewati Waktu Skrining Optimal"}
                  </p>
                  <p className="text-sm text-gray-600 mt-1">
                    {isEarlySkrining ? (
                      <>
                        Usia kehamilan saat ini:{" "}
                        <strong>{usiaKehamilanSaatIni} minggu</strong>.
                        Skrining DM Gestasional idealnya dilakukan pada usia
                        kehamilan <strong>24-28 minggu</strong>. Hasil
                        skrining saat ini mungkin belum akurat.
                      </>
                    ) : (
                      <>
                        Usia kehamilan saat ini:{" "}
                        <strong>{usiaKehamilanSaatIni} minggu</strong>. Waktu
                        ideal skrining DM Gestasional adalah{" "}
                        <strong>24-28 minggu</strong>. Skrining yang dilakukan
                        sekarang sudah terlambat. Segera konsultasikan hasil
                        dengan dokter.
                      </>
                    )}
                  </p>
                </div>
              </div>
            </div>
          )}
          {/* Banner peringatan status kehamilan dan hak akses */}
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

          {/* Jika belum ada data dan form tidak aktif */}
          {!data && !showForm && (
            <div className="bg-white rounded-xl shadow-sm p-8 text-center">
              <div className="flex flex-col items-center gap-4">
                <div className="p-4 bg-[#185FA5]/10 rounded-full">
                  <Save size={48} className="text-[#185FA5]" />
                </div>
                <h3 className="text-[22px] font-semibold text-[#185FA5]">
                  Belum Ada Data Skrining DM Gestasional
                </h3>
                <p className="text-gray-500 text-base max-w-md">
                  Silakan lakukan skrining diabetes melitus gestasional (DMG)
                  untuk ibu hamil ini.
                </p>
                {canEdit && (
                  <button
                    onClick={handleAdd}
                    className="bg-[#185FA5] text-white rounded-lg px-5 py-2.5 font-semibold flex items-center gap-2 text-base"
                  >
                    <Plus size={18} /> Buat Skrining DM
                  </button>
                )}
                {!canEdit && !isActive && (
                  <p className="text-gray-400 text-sm mt-2">
                    Kehamilan sudah selesai (NON-AKTIF), tidak dapat menambahkan
                    data baru.
                  </p>
                )}
              </div>
            </div>
          )}

          {/* Jika sudah ada data dan form tidak aktif */}
          {data && !showForm && (
            <div className="bg-white rounded-xl shadow-sm p-5">
              <div className="flex justify-between items-center mb-4">
                <h2 className="text-[22px] font-semibold text-[#185FA5]">
                  Hasil Skrining DM Gestasional
                </h2>
                {canEdit && (
                  <button
                    onClick={handleEdit}
                    className="border border-[#185FA5] text-[#185FA5] rounded-lg px-4 py-1.5 flex items-center gap-1 text-base font-semibold hover:bg-[#185FA5]/5"
                  >
                    <Edit size={16} /> Edit Data
                  </button>
                )}
              </div>
              <div className="space-y-5">
                {/* GDP */}
                <div className="border-b pb-4">
                  <div className="flex flex-wrap justify-between items-start gap-2">
                    <div>
                      <h3 className="font-semibold text-base text-gray-800">
                        1. Gula Darah Puasa (GDP)
                      </h3>
                      <p className="text-gray-500 text-sm">
                        Nilai normal: &lt; 92 mg/dL
                      </p>
                    </div>
                    {getStatusGDP(data.gula_darah_puasa_hasil) && (
                      <span
                        className="px-3 py-1 rounded-full text-sm font-semibold"
                        style={{
                          backgroundColor: getStatusGDP(
                            data.gula_darah_puasa_hasil,
                          ).bg,
                          color: getStatusGDP(data.gula_darah_puasa_hasil)
                            .color,
                        }}
                      >
                        {getStatusGDP(data.gula_darah_puasa_hasil).text}
                      </span>
                    )}
                  </div>
                  <div className="mt-2 grid grid-cols-1 md:grid-cols-2 gap-3 text-base">
                    <div>
                      <span className="font-semibold">Hasil:</span>{" "}
                      {data.gula_darah_puasa_hasil
                        ? `${data.gula_darah_puasa_hasil} mg/dL`
                        : "-"}
                    </div>
                    <div>
                      <span className="font-semibold">
                        Rencana Tindak Lanjut:
                      </span>{" "}
                      {data.gula_darah_puasa_rencana_tindak_lanjut || "-"}
                    </div>
                  </div>
                </div>
                {/* 2 jam post prandial */}
                <div>
                  <div className="flex flex-wrap justify-between items-start gap-2">
                    <div>
                      <h3 className="font-semibold text-base text-gray-800">
                        2. Gula Darah 2 Jam Post Prandial (TTGO 75g)
                      </h3>
                      <p className="text-gray-500 text-sm">
                        Nilai normal: &lt; 153 mg/dL
                      </p>
                    </div>
                    {getStatus2Jam(
                      data.gula_darah_2_jam_post_prandial_hasil,
                    ) && (
                      <span
                        className="px-3 py-1 rounded-full text-sm font-semibold"
                        style={{
                          backgroundColor: getStatus2Jam(
                            data.gula_darah_2_jam_post_prandial_hasil,
                          ).bg,
                          color: getStatus2Jam(
                            data.gula_darah_2_jam_post_prandial_hasil,
                          ).color,
                        }}
                      >
                        {
                          getStatus2Jam(
                            data.gula_darah_2_jam_post_prandial_hasil,
                          ).text
                        }
                      </span>
                    )}
                  </div>
                  <div className="mt-2 grid grid-cols-1 md:grid-cols-2 gap-3 text-base">
                    <div>
                      <span className="font-semibold">Hasil:</span>{" "}
                      {data.gula_darah_2_jam_post_prandial_hasil
                        ? `${data.gula_darah_2_jam_post_prandial_hasil} mg/dL`
                        : "-"}
                    </div>
                    <div>
                      <span className="font-semibold">
                        Rencana Tindak Lanjut:
                      </span>{" "}
                      {data.gula_darah_2_jam_post_prandial_rencana_tindak_lanjut ||
                        "-"}
                    </div>
                  </div>
                </div>
              </div>
              <div className="mt-4 text-sm text-gray-400 border-t pt-3">
                Terakhir diperbarui:{" "}
                {data.updated_at
                  ? new Date(data.updated_at).toLocaleString()
                  : "Belum diperbarui"}
              </div>
            </div>
          )}

          {/* Form input (create / edit) dengan validasi */}
          {showForm && (
            <form
              onSubmit={handleSubmit}
              className="bg-white rounded-xl shadow-sm p-5 space-y-6"
            >
              <div className="flex justify-between items-center">
                <h2 className="text-[22px] font-semibold text-[#185FA5]">
                  {data ? "Edit Skrining DM" : "Buat Skrining DM Baru"}
                </h2>
                <button
                  type="button"
                  onClick={handleCancelForm}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <X size={20} />
                </button>
              </div>

              {/* Banner peringatan di dalam form */}
              {(isEarlySkrining || isLateSkrining) && (
                <div
                  className={`p-4 rounded-lg ${
                    isEarlySkrining
                      ? "bg-yellow-50 border border-yellow-200"
                      : "bg-red-50 border border-red-200"
                  }`}
                >
                  <div className="flex items-start gap-3">
                    <div className="flex-shrink-0">
                      {isEarlySkrining ? (
                        <AlertCircle size={18} className="text-yellow-600" />
                      ) : (
                        <AlertCircle size={18} className="text-red-600" />
                      )}
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-800">
                        {isEarlySkrining
                          ? "⚠️ Peringatan: Usia kehamilan masih terlalu dini untuk skrining DM Gestasional"
                          : "⚠️ Peringatan: Usia kehamilan sudah melewati waktu skrining optimal (24-28 minggu)"}
                      </p>
                      <p className="text-xs text-gray-600 mt-1">
                        {isEarlySkrining
                          ? "Hasil pemeriksaan yang dilakukan saat ini mungkin belum mencerminkan kondisi sebenarnya. Pertimbangkan untuk mengulang skrining pada usia kehamilan 24-28 minggu."
                          : "Skrining yang terlambat dapat mempengaruhi rencana penanganan. Segera konsultasikan hasil dengan dokter kandungan."}
                      </p>
                    </div>
                  </div>
                </div>
              )}
              {/* ========== SAMPAI SINI ========== */}

              <div className="bg-[#185FA5]/10 p-4 rounded-lg">
                <h2 className="text-lg font-semibold text-[#185FA5] mb-1">
                  Test Toleransi Glukosa Oral (TTGO)
                </h2>
                <p className="text-sm text-gray-700">
                  Pemeriksaan untuk mendeteksi Diabetes Melitus Gestasional
                  (DMG). Dilakukan umumnya pada usia kehamilan 24-28 minggu atau
                  jika terdapat faktor risiko (misal: riwayat keluarga DM,
                  obesitas, riwayat melahirkan bayi besar &gt;4000 gram, atau
                  riwayat abortus berulang).
                </p>
              </div>

              <div className="space-y-6">
                {/* Gula Darah Puasa */}
                <div>
                  <h3 className="font-semibold text-base text-gray-800 mb-3">
                    1. Gula Darah Puasa (GDP)
                  </h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Hasil (mg/dL) <span className="text-red-500">*</span>
                      </label>
                      <input
                        type="text"
                        inputMode="numeric"
                        name="gula_darah_puasa_hasil"
                        value={form.gula_darah_puasa_hasil}
                        onChange={handleChange}
                        disabled={!canEdit}
                        className={`w-full border ${errors.gula_darah_puasa_hasil ? "border-red-500" : "border-gray-300"} rounded-lg px-3 py-2 text-base focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] disabled:bg-gray-100`}
                        placeholder="Contoh: 90"
                      />
                      {errors.gula_darah_puasa_hasil && (
                        <p className="text-red-500 text-sm mt-1 flex items-center gap-1">
                          <AlertCircle size={14} />{" "}
                          {errors.gula_darah_puasa_hasil}
                        </p>
                      )}
                      <p className="text-sm text-gray-500 mt-1">
                        Nilai normal: &lt; 92 mg/dL
                      </p>
                    </div>
                    <div>
                      <label className="block text-base font-medium mb-1">
                        Rencana Tindak Lanjut (opsional)
                      </label>
                      <input
                        type="text"
                        name="gula_darah_puasa_rencana_tindak_lanjut"
                        value={form.gula_darah_puasa_rencana_tindak_lanjut}
                        onChange={handleChange}
                        disabled={!canEdit}
                        className="w-full border border-gray-300 rounded-lg px-3 py-2 text-base focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] disabled:bg-gray-100"
                        placeholder="Contoh: Konseling gizi, ulang pemeriksaan"
                      />
                    </div>
                  </div>
                </div>

                {/* Gula Darah 2 jam post prandial */}
                <div className="border-t pt-4">
                  <h3 className="font-semibold text-base text-gray-800 mb-3">
                    2. Gula Darah 2 Jam Post Prandial (TTGO 75g)
                  </h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-base font-medium mb-1">
                        Hasil (mg/dL) <span className="text-red-500">*</span>
                      </label>
                      <input
                        type="text"
                        inputMode="numeric"
                        name="gula_darah_2_jam_post_prandial_hasil"
                        value={form.gula_darah_2_jam_post_prandial_hasil}
                        onChange={handleChange}
                        disabled={!canEdit}
                        className={`w-full border ${errors.gula_darah_2_jam_post_prandial_hasil ? "border-red-500" : "border-gray-300"} rounded-lg px-3 py-2 text-base focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] disabled:bg-gray-100`}
                        placeholder="Contoh: 140"
                      />
                      {errors.gula_darah_2_jam_post_prandial_hasil && (
                        <p className="text-red-500 text-sm mt-1 flex items-center gap-1">
                          <AlertCircle size={14} />{" "}
                          {errors.gula_darah_2_jam_post_prandial_hasil}
                        </p>
                      )}
                      <p className="text-sm text-gray-500 mt-1">
                        Nilai normal: &lt; 153 mg/dL
                      </p>
                    </div>
                    <div>
                      <label className="block text-base font-medium mb-1">
                        Rencana Tindak Lanjut (opsional)
                      </label>
                      <input
                        type="text"
                        name="gula_darah_2_jam_post_prandial_rencana_tindak_lanjut"
                        value={
                          form.gula_darah_2_jam_post_prandial_rencana_tindak_lanjut
                        }
                        onChange={handleChange}
                        disabled={!canEdit}
                        className="w-full border border-gray-300 rounded-lg px-3 py-2 text-base focus:border-[#185FA5] focus:ring-1 focus:ring-[#185FA5] disabled:bg-gray-100"
                        placeholder="Contoh: Rujuk ke endokrin, terapi insulin"
                      />
                    </div>
                  </div>
                </div>
              </div>

              {canEdit && (
                <div className="flex gap-4 justify-end pt-4 border-t">
                  <button
                    type="button"
                    onClick={handleCancelForm}
                    className="px-5 py-2.5 border border-[#185FA5] text-[#185FA5] rounded-lg font-semibold text-base"
                  >
                    Batal
                  </button>
                  <button
                    type="submit"
                    disabled={saving}
                    className="bg-[#185FA5] text-white px-6 py-2.5 rounded-lg flex items-center gap-2 text-base font-semibold hover:bg-[#185FA5]/90"
                  >
                    {saving ? (
                      <Loader2 className="animate-spin" size={18} />
                    ) : (
                      <Save size={18} />
                    )}
                    {saving ? "Menyimpan..." : "Simpan Skrining DM"}
                  </button>
                </div>
              )}
            </form>
          )}
        </div>
      </div>
    </MainLayout>
  );
}
