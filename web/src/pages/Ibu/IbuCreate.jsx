// src/pages/Ibu/IbuCreate.jsx

import React, { useState, useEffect, useMemo } from "react";
import { useNavigate } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import { createIbu, getIbuByPendudukId } from "../../services/ibu";
import { createKehamilan } from "../../services/kehamilan";
import { getPerempuanList, getLakiList } from "../../services/kependudukan";
import {
  ArrowLeft,
  ArrowRight,
  Loader2,
  CheckCircle2,
  Baby,
  Users,
  Info,
  Mail,
  Lock,
  Eye,
  EyeOff,
} from "lucide-react";
import { createIbuUser } from "../../services/auth";
import Swal from "sweetalert2";

export default function IbuCreate() {
  const navigate = useNavigate();

  const [loading, setLoading] = useState(false);
  const [pendudukList, setPendudukList] = useState([]);
  const [step, setStep] = useState(1);
  const [createdIbu, setCreatedIbu] = useState(null);
  const [errorMessage, setErrorMessage] = useState("");
  const [errors, setErrors] = useState({});
  const [checkingIbu, setCheckingIbu] = useState(false);
  const [ibuExists, setIbuExists] = useState(false);

  const today = new Date().toISOString().split("T")[0];
  const [creatingAccount, setCreatingAccount] = useState(false);
  const [accountCreated, setAccountCreated] = useState(false);
  const [accountInfo, setAccountInfo] = useState(null);

  // ========== STATE UNTUK SHOW/HIDE PASSWORD ==========
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);

  // ========== STATE UNTUK AUTOCOMPLETE SEARCH ==========
  const [searchQuery, setSearchQuery] = useState("");
  const [showAutocomplete, setShowAutocomplete] = useState(false);

  // Form data ibu (muncul jika belum terdaftar)
  const [formIbu, setFormIbu] = useState({
    id_kependudukan: "",
    id_suami: "",
    gravida: "",
    paritas: "",
    abortus: "",
  });

  // ========== FORM AKUN (EMAIL & PASSWORD) ==========
  const [formAkun, setFormAkun] = useState({
    email: "",
    password: "",
    confirmPassword: "",
  });

  // Form kehamilan
  const [formKehamilan, setFormKehamilan] = useState({
    hpht: "",
    taksiran_persalinan: "",
    jarak_kehamilan_sebelumnya: "",
    bb_awal: "",
    tb: "",
  });

  // Fetch penduduk PEREMPUAN
  const fetchIbuList = async () => {
    try {
      const data = await getPerempuanList();
      return Array.isArray(data) ? data : [];
    } catch (err) {
      console.error("Error fetching ibu list:", err);
      return [];
    }
  };

  // Fetch penduduk LAKI-LAKI
  const fetchSuamiList = async () => {
    try {
      const data = await getLakiList();
      return Array.isArray(data) ? data : [];
    } catch (err) {
      console.error("Error fetching suami list:", err);
      return [];
    }
  };

  // Fetch semua penduduk
  const fetchPenduduk = async () => {
    try {
      setLoading(true);
      const [perempuanData, lakiData] = await Promise.all([
        fetchIbuList(),
        fetchSuamiList(),
      ]);

      setPendudukList([...perempuanData, ...lakiData]);
    } catch (err) {
      console.error(err);
      setErrorMessage("Gagal mengambil data penduduk.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchPenduduk();
  }, []);

  const ibuList = useMemo(() => {
    return pendudukList.filter((item) => {
      const gender = item.jenis_kelamin || "";
      const hubungan = item.hubungan || "";
      return (
        (gender === "Perempuan" || gender === "P") &&
        (hubungan === "Istri" || hubungan === "Ibu")
      );
    });
  }, [pendudukList]);

  const suamiList = useMemo(() => {
    return pendudukList.filter((item) => {
      const gender = item.jenis_kelamin || "";
      const hubungan = item.hubungan || "";
      return (
        (gender === "Laki-laki" || gender === "L") &&
        (hubungan === "Kepala Keluarga" ||
          hubungan === "Ayah" ||
          hubungan === "Suami")
      );
    });
  }, [pendudukList]);

  // Filter ibu list based on search query
  const filteredIbuList = useMemo(() => {
    if (!searchQuery.trim()) return ibuList;
    const query = searchQuery.toLowerCase();
    return ibuList.filter(
      (ibu) =>
        ibu.nama_anggota_keluarga.toLowerCase().includes(query) ||
        ibu.nik.includes(query),
    );
  }, [ibuList, searchQuery]);

  // Cek apakah penduduk sudah terdaftar sebagai ibu
  const checkIbuExists = async (pendudukId) => {
    if (!pendudukId) {
      setCreatedIbu(null);
      setIbuExists(false);
      return;
    }

    setCheckingIbu(true);
    setErrorMessage("");
    try {
      const data = await getIbuByPendudukId(pendudukId);
      if (data && data.id_ibu) {
        setCreatedIbu(data);
        setIbuExists(true);
        setStep(2);
      } else {
        setCreatedIbu(null);
        setIbuExists(false);
      }
    } catch (err) {
      console.error(err);
      setCreatedIbu(null);
      setIbuExists(false);
    } finally {
      setCheckingIbu(false);
    }
  };

  useEffect(() => {
    if (formIbu.id_kependudukan) {
      checkIbuExists(formIbu.id_kependudukan);
    } else {
      setCreatedIbu(null);
      setIbuExists(false);
    }
    setErrorMessage("");
  }, [formIbu.id_kependudukan]);

  // ========== AUTO FILL SUAMI BERDASARKAN KODE_KELUARGA ==========
  useEffect(() => {
    if (!formIbu.id_kependudukan) {
      setFormIbu((prev) => ({ ...prev, id_suami: "" }));
      return;
    }

    // Cari data ibu yang dipilih berdasarkan ID
    const selectedIbu = pendudukList.find(
      (kk) => String(kk.id) === formIbu.id_kependudukan,
    );

    if (!selectedIbu) {
      setFormIbu((prev) => ({ ...prev, id_suami: "" }));
      return;
    }

    // Ambil kode_keluarga dari ibu yang dipilih
    const kodeKeluarga = selectedIbu.kode_keluarga;

    if (!kodeKeluarga) {
      setFormIbu((prev) => ({ ...prev, id_suami: "" }));
      return;
    }

    // Cari suami dengan kode_keluarga yang sama dan hubungan = "Kepala Keluarga"
    const suamiFound = pendudukList.find((item) => {
      const itemKodeKeluarga = item.kode_keluarga || "";
      const itemHubungan = item.hubungan || "";
      const itemGender = item.jenis_kelamin || "";

      return (
        itemKodeKeluarga === kodeKeluarga &&
        (itemHubungan === "Kepala Keluarga" ||
          itemHubungan === "Suami" ||
          itemHubungan === "Ayah") &&
        (itemGender === "Laki-laki" || itemGender === "L")
      );
    });

    if (suamiFound) {
      setFormIbu((prev) => ({
        ...prev,
        id_suami: String(suamiFound.id),
      }));
    } else {
      setFormIbu((prev) => ({ ...prev, id_suami: "not_found" }));
    }
  }, [formIbu.id_kependudukan, pendudukList]);

  // Handle perubahan form ibu
  const handleChangeIbu = (e) => {
    const { name, value } = e.target;
    setFormIbu((prev) => ({ ...prev, [name]: value }));
    if (errorMessage) setErrorMessage("");
  };

  // Handle search input change
  const handleSearchChange = (e) => {
    const value = e.target.value;
    setSearchQuery(value);
    setShowAutocomplete(true);
    // Reset formIbu.id_kependudukan when search is cleared
    if (!value.trim()) {
      setFormIbu((prev) => ({ ...prev, id_kependudukan: "" }));
    }
  };

  // Handle selection from autocomplete
  const handleSelectIbu = (ibu) => {
    const idPenduduk = String(ibu.id);
    setFormIbu((prev) => ({ ...prev, id_kependudukan: idPenduduk }));
    setSearchQuery(ibu.nama_anggota_keluarga || "");
    setShowAutocomplete(false);

    // Reset suami terlebih dahulu
    setFormIbu((prev) => ({ ...prev, id_suami: "" }));

    // Cari suami berdasarkan kode_keluarga
    const kodeKeluarga = ibu.kode_keluarga;
    if (kodeKeluarga) {
      const suamiFound = pendudukList.find((item) => {
        const itemKodeKeluarga = item.kode_keluarga || "";
        const itemHubungan = item.hubungan || "";
        const itemGender = item.jenis_kelamin || "";

        return (
          itemKodeKeluarga === kodeKeluarga &&
          (itemHubungan === "Kepala Keluarga" ||
            itemHubungan === "Suami" ||
            itemHubungan === "Ayah") &&
          (itemGender === "Laki-laki" || itemGender === "L")
        );
      });

      if (suamiFound) {
        setFormIbu((prev) => ({
          ...prev,
          id_suami: String(suamiFound.id),
        }));
      } else {
        setFormIbu((prev) => ({ ...prev, id_suami: "not_found" }));
      }
    }
  };

  // Handle click outside to close autocomplete
  const handleClickOutside = (e) => {
    if (!e.target.closest(".autocomplete-container")) {
      setShowAutocomplete(false);
    }
  };

  useEffect(() => {
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  // Handle perubahan form akun
  const handleChangeAkun = (e) => {
    const { name, value } = e.target;
    setFormAkun((prev) => ({ ...prev, [name]: value }));
    if (errorMessage) setErrorMessage("");
    // Hapus error saat user mengetik
    if (errors[name]) {
      setErrors((prev) => ({ ...prev, [name]: "" }));
    }
  };

  // Handle perubahan form kehamilan
  const handleChangeKehamilan = (e) => {
    const { name, value } = e.target;
    setFormKehamilan((prev) => ({ ...prev, [name]: value }));
    setErrors((prev) => ({ ...prev, [name]: "" }));
  };

  // Auto HPL
  useEffect(() => {
    if (formKehamilan.hpht) {
      const hpht = new Date(formKehamilan.hpht);
      const hpl = new Date(hpht);
      hpl.setDate(hpl.getDate() + 7);
      hpl.setMonth(hpl.getMonth() + 9);
      setFormKehamilan((prev) => ({
        ...prev,
        taksiran_persalinan: hpl.toISOString().split("T")[0],
      }));
    }
  }, [formKehamilan.hpht]);

  // ========== VALIDASI FORM AKUN ==========
  const validateAkunForm = () => {
    const newErrors = {};

    if (!formAkun.email || formAkun.email.trim() === "") {
      newErrors.email = "Email wajib diisi";
    } else if (!/\S+@\S+\.\S+/.test(formAkun.email)) {
      newErrors.email = "Format email tidak valid";
    }

    if (!formAkun.password || formAkun.password.trim() === "") {
      newErrors.password = "Password wajib diisi";
    } else if (formAkun.password.length < 6) {
      newErrors.password = "Password minimal 6 karakter";
    }

    if (formAkun.password !== formAkun.confirmPassword) {
      newErrors.confirmPassword = "Konfirmasi password tidak sesuai";
    }

    return newErrors;
  };

  // ========== FUNGSI UNTUK MEMBUAT AKUN IBU ==========
  const createUserAccount = async (pendudukId, nama, phoneNumber) => {
    setCreatingAccount(true);
    try {
      // Validasi nomor telepon harus diisi
      if (!phoneNumber || phoneNumber.trim() === "") {
        setErrorMessage(
          "Penduduk belum memiliki nomor telepon. Silakan lengkapi data kependudukan terlebih dahulu.",
        );
        setCreatingAccount(false);
        return false;
      }

      const payload = {
        penduduk_id: pendudukId,
        name: nama,
        email: formAkun.email,
        phone_number: phoneNumber,
        password: formAkun.password,
      };

      console.log("Membuat akun Ibu dengan payload:", payload);

      // Panggil endpoint untuk membuat akun Ibu
      const response = await createIbuUser(payload);
      console.log("Akun Ibu berhasil dibuat:", response);

      setAccountCreated(true);
      setAccountInfo({
        email: formAkun.email,
        password: formAkun.password,
        phone: phoneNumber,
      });
      return true;
    } catch (err) {
      console.error("Gagal membuat akun Ibu:", err);
      const errorMsg = err.response?.data?.message || err.message || "";

      if (
        errorMsg.includes("sudah terdaftar") ||
        errorMsg.includes("already exists") ||
        errorMsg.includes("email sudah terdaftar")
      ) {
        setErrorMessage("Email sudah terdaftar. Silakan gunakan email lain.");
        setErrors((prev) => ({ ...prev, email: "Email sudah terdaftar" }));
      } else {
        setErrorMessage("Gagal membuat akun: " + errorMsg);
      }
      return false;
    } finally {
      setCreatingAccount(false);
    }
  };

  // Submit data ibu (untuk kasus belum terdaftar)
  const handleSubmitIbu = async (e) => {
    e.preventDefault();

    if (!formIbu.id_kependudukan) {
      setErrorMessage("Silakan pilih data penduduk terlebih dahulu.");
      return;
    }

    // Validasi form akun
    const akunErrors = validateAkunForm();
    if (Object.keys(akunErrors).length > 0) {
      setErrors(akunErrors);

      // Show alert with list of errors
      const errorList = Object.entries(akunErrors)
        .map(([field, message]) => `• ${message}`)
        .join("\n");

      Swal.fire({
        icon: "warning",
        title: "Data Akun Belum Lengkap",
        html: `<div class="text-left" style="white-space: pre-line;">${errorList}</div>`,
        confirmButtonColor: "#185FA5",
      });

      // Scroll to first error field
      const firstErrorField = Object.keys(akunErrors)[0];
      const errorElement = document.querySelector(
        `[name="${firstErrorField}"]`,
      );
      if (errorElement) {
        errorElement.scrollIntoView({ behavior: "smooth", block: "center" });
        errorElement.focus();
      }
      return;
    }

    setLoading(true);
    try {
      const ibu = await createIbu({
        id_kependudukan: Number(formIbu.id_kependudukan),
       id_suami: formIbu.id_suami && formIbu.id_suami !== "not_found" ? Number(formIbu.id_suami) : null,
        gravida: Number(formIbu.gravida) || 0,
        paritas: Number(formIbu.paritas) || 0,
        abortus: Number(formIbu.abortus) || 0,
      });
      setCreatedIbu(ibu);

      // 2. Buat Akun User untuk Ibu
      const selectedPenduduk = ibuList.find(
        (kk) => String(kk.id) === formIbu.id_kependudukan
      );

      if (selectedPenduduk) {
        const accountSuccess = await createUserAccount(
          Number(formIbu.id_kependudukan),
          selectedPenduduk.nama_anggota_keluarga,
          selectedPenduduk.telepon || "",
        );

        if (!accountSuccess) {
          setLoading(false);
          return;
        }
      }

      setStep(2);
    } catch (err) {
      console.error(err);
      const msg =
        err.response?.data?.message ||
        err.message ||
        "Gagal menambahkan data ibu";
      setErrorMessage(msg);
    } finally {
      setLoading(false);
    }
  };

  // Submit kehamilan
  const handleSubmitKehamilan = async (e) => {
    e.preventDefault();

    let newErrors = {};
    if (!formKehamilan.hpht) {
      newErrors.hpht = "Silakan pilih tanggal HPHT terlebih dahulu";
    } else if (formKehamilan.hpht > today) {
      newErrors.hpht = "Tanggal HPHT tidak boleh melebihi hari ini";
    }
    if (!formKehamilan.bb_awal) {
      newErrors.bb_awal = "Berat badan wajib diisi";
    } else if (parseFloat(formKehamilan.bb_awal) <= 0) {
      newErrors.bb_awal = "Berat badan harus lebih dari 0 kg";
    }
    if (!formKehamilan.tb) {
      newErrors.tb = "Tinggi badan wajib diisi";
    } else if (parseFloat(formKehamilan.tb) <= 0) {
      newErrors.tb = "Tinggi badan harus lebih dari 0 cm";
    }

    setErrors(newErrors);
    if (Object.keys(newErrors).length > 0) {
      // Show alert with list of errors
      const errorList = Object.entries(newErrors)
        .map(([field, message]) => `• ${message}`)
        .join("\n");

      Swal.fire({
        icon: "warning",
        title: "Data Belum Lengkap",
        html: `<div class="text-left" style="white-space: pre-line;">${errorList}</div>`,
        confirmButtonColor: "#185FA5",
      });

      // Scroll to first error field
      const firstErrorField = Object.keys(newErrors)[0];
      const errorElement = document.querySelector(
        `[name="${firstErrorField}"]`,
      );
      if (errorElement) {
        errorElement.scrollIntoView({ behavior: "smooth", block: "center" });
        errorElement.focus();
      }
      return;
    }

    if (!createdIbu) {
      setErrorMessage("Data ibu belum tersedia. Silakan ulangi proses.");
      return;
    }

    setLoading(true);
    try {
      const ibuId = createdIbu.id_ibu || createdIbu.id;
      await createKehamilan({
        ibu_id: Number(ibuId),
        hpht: formKehamilan.hpht,
        taksiran_persalinan: formKehamilan.taksiran_persalinan,
        jarak_kehamilan_sebelumnya:
          parseInt(formKehamilan.jarak_kehamilan_sebelumnya) || 0,
        bb_awal: parseFloat(formKehamilan.bb_awal),
        tb: parseFloat(formKehamilan.tb),
      });
      setStep(3);
      setTimeout(() => {
        navigate(`/data-ibu/${ibuId}`);
      }, 2000);
    } catch (err) {
      console.error(err);
      const msg =
        err.response?.data?.message ||
        err.message ||
        "Gagal menyimpan data kehamilan";
      setErrorMessage(msg);
    } finally {
      setLoading(false);
    }
  };

  const steps = [
    { num: 1, label: "Data Ibu & Akun", icon: Users },
    { num: 2, label: "Data Kehamilan", icon: Baby },
    { num: 3, label: "Selesai", icon: CheckCircle2 },
  ];

  return (
    <MainLayout>
      <div className="p-6 max-w-3xl mx-auto">
        <div className="flex items-center gap-4 mb-8">
          <button
            onClick={() => navigate(-1)}
            className="p-2 hover:bg-gray-100 rounded-full transition"
          >
            <ArrowLeft size={20} />
          </button>
          <h1 className="text-2xl font-bold">Tambah Data Ibu Baru</h1>
        </div>

        {/* Stepper */}
        <div className="flex items-center justify-center mb-10">
          {steps.map((s, idx) => {
            const Icon = s.icon;
            const isActive = step === s.num;
            const isDone = step > s.num;
            return (
              <React.Fragment key={s.num}>
                <div className="flex flex-col items-center">
                  <div
                    className={`w-12 h-12 rounded-full flex items-center justify-center ${
                      isDone
                        ? "bg-green-500 text-white"
                        : isActive
                          ? "bg-indigo-600 text-white"
                          : "bg-gray-100 text-gray-400"
                    }`}
                  >
                    {isDone ? <CheckCircle2 size={22} /> : <Icon size={20} />}
                  </div>
                  <span
                    className={`text-xs mt-2 ${isActive ? "text-indigo-600" : isDone ? "text-green-600" : "text-gray-400"}`}
                  >
                    {s.label}
                  </span>
                </div>
                {idx < steps.length - 1 && (
                  <div
                    className={`flex-1 h-1 mx-3 ${step > s.num ? "bg-green-400" : "bg-gray-200"}`}
                  />
                )}
              </React.Fragment>
            );
          })}
        </div>

        {/* Info pembuatan akun */}
        {step === 1 && accountCreated && !creatingAccount && (
          <div className="mb-4 p-3 bg-green-50 border border-green-200 rounded-lg">
            <div className="flex items-start gap-2">
              <CheckCircle2 size={18} className="text-green-600 mt-0.5" />
              <div>
                <p className="text-sm font-medium text-green-800">
                  ✅ Akun untuk login ibu telah dibuat!
                </p>
                {accountInfo && (
                  <div className="mt-2 text-xs text-green-700 space-y-1">
                    <p>
                      <strong>Email:</strong> {accountInfo.email}
                    </p>
                    <p>
                      <strong>Password:</strong> {accountInfo.password}
                    </p>
                    {accountInfo.phone && (
                      <p>
                        <strong>No. Telepon:</strong> {accountInfo.phone}
                      </p>
                    )}
                  </div>
                )}
              </div>
            </div>
          </div>
        )}

        {creatingAccount && (
          <div className="mb-4 p-3 bg-blue-50 border border-blue-200 rounded-lg flex items-center gap-2">
            <Loader2 size={16} className="animate-spin text-blue-600" />
            <span className="text-sm text-blue-700">
              Membuat akun untuk ibu...
            </span>
          </div>
        )}

        {errorMessage && (
          <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg text-red-700">
            {errorMessage}
          </div>
        )}

        {/* STEP 1 - Pilih penduduk & form data ibu & form akun */}
        {step === 1 && (
          <form onSubmit={handleSubmitIbu}>
            <div className="bg-white rounded-2xl p-6 shadow-sm">
              {/* Pilih Penduduk */}
              <h3 className="font-semibold mb-4">Pilih Penduduk Perempuan</h3>
              <div className="autocomplete-container relative">
                <input
                  type="text"
                  value={searchQuery}
                  onChange={handleSearchChange}
                  onFocus={() => setShowAutocomplete(true)}
                  placeholder="Cari nama ibu atau NIK..."
                  className="w-full border rounded-xl p-3 focus:ring-2 focus:ring-indigo-500"
                  required
                />
                {showAutocomplete && (
                  <div className="absolute z-10 w-full mt-1 bg-white border border-gray-300 rounded-xl shadow-lg max-h-60 overflow-y-auto">
                    {filteredIbuList.length === 0 ? (
                      <div className="p-3 text-gray-500 text-sm">
                        Tidak ada hasil ditemukan
                      </div>
                    ) : (
                      filteredIbuList.map((kk) => {
                        const idPenduduk = kk.id;
                        const nama = kk.nama_anggota_keluarga || "Tidak ada nama";
                        const nik = kk.nik || "-";
                        const telepon = kk.telepon || "";
                        const kodeKeluarga = kk.kode_keluarga || "-";
                        const hubungan = kk.hubungan || "-";
                        return (
                          <div
                            key={idPenduduk}
                            onClick={() => handleSelectIbu(kk)}
                            className="p-3 hover:bg-indigo-50 cursor-pointer border-b border-gray-100 last:border-b-0"
                          >
                            <div className="font-medium">
                              {kk.nama_anggota_keluarga}
                            </div>
                            <div className="text-sm text-gray-500">
                              NIK: {kk.nik}{" "}
                              {kk.telepon
                                ? `— NO.HP: ${kk.telepon}`
                                : "— No HP kosong"}
                            </div>
                          </div>
                        );
                      })
                    )}
                  </div>
                )}
              </div>
              {checkingIbu && (
                <div className="flex items-center gap-2 mt-2 text-sm text-gray-500">
                  <Loader2 size={14} className="animate-spin" /> Mengecek data
                  ibu...
                </div>
              )}

              {/* Jika ibu sudah terdaftar */}
              {ibuExists && !checkingIbu && (
                <div className="mt-4 p-3 bg-blue-50 rounded-lg flex items-center gap-2 text-blue-700">
                  <Info size={18} />
                  <span>
                    Ibu sudah terdaftar. Silakan lanjut ke data kehamilan.
                  </span>
                </div>
              )}

              {/* Form data ibu (muncul hanya jika ibu belum terdaftar) */}
              {!ibuExists && !checkingIbu && formIbu.id_kependudukan && (
                <>
                  <div className="mt-4 p-3 border border-green-500 bg-green-50 rounded-lg">
                    <p>
                      <strong>Nama:</strong>{" "}
                      {
                        ibuList.find(
                          (kk) =>
                            String(kk.id_kependudukan ?? kk.id) ===
                            formIbu.id_kependudukan,
                        )?.nama_anggota_keluarga
                      }
                    </p>
                    <p>
                      <strong>NIK:</strong>{" "}
                      {
                        ibuList.find(
                          (kk) =>
                            String(kk.id_kependudukan ?? kk.id) ===
                            formIbu.id_kependudukan,
                        )?.nik
                      }
                    </p>
                    <p>
                      <strong>No. Telepon:</strong>{" "}
                      {ibuList.find(
                        (kk) =>
                          String(kk.id_kependudukan ?? kk.id) ===
                          formIbu.id_kependudukan,
                      )?.telepon || (
                        <span className="text-red-500">
                          Belum diisi - wajib diisi di data penduduk
                        </span>
                      )}
                    </p>
                  </div>

                  <div className="mt-4">
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Suami
                      {formIbu.id_suami && formIbu.id_suami !== "not_found" && (
                        <span className="ml-2 text-xs text-green-600 font-normal"></span>
                      )}
                    </label>

                    {formIbu.id_suami === "not_found" ? (
                      // Tampilkan keterangan, bukan dropdown
                      <div className="w-full border border-yellow-500 bg-yellow-50 rounded-xl p-3 flex items-center gap-2">
                        <span className="text-gray-600 text-sm">
                          Kepala Keluarga belum terdaftar di data penduduk
                        </span>
                      </div>
                    ) : (
                      <select
                        name="id_suami"
                        value={formIbu.id_suami}
                        onChange={handleChangeIbu}
                        disabled={!!formIbu.id_suami}
                        className={`w-full border rounded-xl p-3 ${
                          formIbu.id_suami
                            ? "bg-gray-100 text-black opacity-100 cursor-not-allowed appearance-none pointer-events-none"
                            : ""
                        }`}
                      >
                        <option value="">-- Tidak ada suami / pilih --</option>
                        {suamiList.map((suami) => {
                          const idPenduduk = suami.id_kependudukan ?? suami.id;
                          return (
                            <option key={idPenduduk} value={String(idPenduduk)}>
                              {suami.nama_kepala_keluarga} — NIK: {suami.nik}
                            </option>
                          );
                        })}
                      </select>
                    )}
                  </div>

                  <div className="grid grid-cols-3 gap-4 mt-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700">
                        Gravida
                      </label>
                      <input
                        type="number"
                        name="gravida"
                        min="0"
                        value={formIbu.gravida}
                        onChange={handleChangeIbu}
                        className="w-full border rounded-xl p-3 mt-1"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700">
                        Paritas
                      </label>
                      <input
                        type="number"
                        name="paritas"
                        min="0"
                        value={formIbu.paritas}
                        onChange={handleChangeIbu}
                        className="w-full border rounded-xl p-3 mt-1"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700">
                        Abortus
                      </label>
                      <input
                        type="number"
                        name="abortus"
                        min="0"
                        value={formIbu.abortus}
                        onChange={handleChangeIbu}
                        className="w-full border rounded-xl p-3 mt-1"
                      />
                    </div>
                  </div>

                  {/* ========== FORM AKUN (EMAIL & PASSWORD) ========== */}
                  <div className="mt-6 pt-4 border-t border-gray-200">
                    <h3 className="font-semibold text-gray-800 mb-4 flex items-center gap-2">
                      <Mail size={18} className="text-indigo-500" />
                      Informasi Akun Login Ibu
                    </h3>
                    <p className="text-xs text-gray-500 mb-4">
                      Isi email dan password untuk akun login ibu. Data ini akan
                      digunakan ibu untuk mengakses aplikasi.
                    </p>

                    <div className="space-y-4">
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Email <span className="text-red-500">*</span>
                        </label>
                        <div className="relative">
                          <Mail
                            size={18}
                            className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"
                          />
                          <input
                            type="email"
                            name="email"
                            value={formAkun.email}
                            onChange={handleChangeAkun}
                            placeholder="contoh: ibu@example.com"
                            className={`w-full border rounded-xl pl-10 pr-3 py-3 focus:ring-2 focus:ring-indigo-500 ${
                              errors.email
                                ? "border-red-500"
                                : "border-gray-300"
                            }`}
                            required
                          />
                        </div>
                        {errors.email && (
                          <p className="text-red-500 text-xs mt-1">
                            {errors.email}
                          </p>
                        )}
                      </div>

                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Password <span className="text-red-500">*</span>
                        </label>
                        <div className="relative">
                          <Lock
                            size={18}
                            className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"
                          />
                          <input
                            type={showPassword ? "text" : "password"}
                            name="password"
                            value={formAkun.password}
                            onChange={handleChangeAkun}
                            placeholder="Minimal 6 karakter"
                            className={`w-full border rounded-xl pl-10 pr-10 py-3 focus:ring-2 focus:ring-indigo-500 ${
                              errors.password
                                ? "border-red-500"
                                : "border-gray-300"
                            }`}
                            required
                          />
                          <button
                            type="button"
                            onClick={() => setShowPassword(!showPassword)}
                            className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                          >
                            {showPassword ? (
                              <EyeOff size={18} />
                            ) : (
                              <Eye size={18} />
                            )}
                          </button>
                        </div>
                        {errors.password && (
                          <p className="text-red-500 text-xs mt-1">
                            {errors.password}
                          </p>
                        )}
                      </div>

                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Konfirmasi Password{" "}
                          <span className="text-red-500">*</span>
                        </label>
                        <div className="relative">
                          <Lock
                            size={18}
                            className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"
                          />
                          <input
                            type={showConfirmPassword ? "text" : "password"}
                            name="confirmPassword"
                            value={formAkun.confirmPassword}
                            onChange={handleChangeAkun}
                            placeholder="Ulangi password"
                            className={`w-full border rounded-xl pl-10 pr-10 py-3 focus:ring-2 focus:ring-indigo-500 ${
                              errors.confirmPassword
                                ? "border-red-500"
                                : "border-gray-300"
                            }`}
                            required
                          />
                          <button
                            type="button"
                            onClick={() =>
                              setShowConfirmPassword(!showConfirmPassword)
                            }
                            className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                          >
                            {showConfirmPassword ? (
                              <EyeOff size={18} />
                            ) : (
                              <Eye size={18} />
                            )}
                          </button>
                        </div>
                        {errors.confirmPassword && (
                          <p className="text-red-500 text-xs mt-1">
                            {errors.confirmPassword}
                          </p>
                        )}
                      </div>
                    </div>
                  </div>
                </>
              )}

              {!formIbu.id_kependudukan && (
                <p className="text-gray-400 text-sm mt-2">
                  Silakan pilih penduduk terlebih dahulu
                </p>
              )}
            </div>

            {/* Tombol submit */}
            {!ibuExists && formIbu.id_kependudukan && !checkingIbu && (
              <div className="flex justify-end mt-6">
                <button
                  type="submit"
                  disabled={loading || creatingAccount}
                  className="bg-indigo-600 text-white px-6 py-2 rounded-xl flex items-center gap-2 hover:bg-indigo-700 transition disabled:opacity-50"
                >
                  {loading || creatingAccount ? (
                    <Loader2 className="animate-spin" />
                  ) : (
                    <ArrowRight />
                  )}
                  {loading
                    ? "Menyimpan..."
                    : creatingAccount
                      ? "Membuat Akun..."
                      : "Simpan & Lanjut"}
                </button>
              </div>
            )}

            {/* Jika ibu sudah terdaftar */}
            {ibuExists && !checkingIbu && (
              <div className="flex justify-end mt-6">
                <button
                  type="button"
                  onClick={() => setStep(2)}
                  className="bg-indigo-600 text-white px-6 py-2 rounded-xl flex items-center gap-2 hover:bg-indigo-700 transition"
                >
                  Lanjut ke Data Kehamilan <ArrowRight size={18} />
                </button>
              </div>
            )}
          </form>
        )}

        {/* STEP 2 - Form Kehamilan */}
        {step === 2 && (
          <form onSubmit={handleSubmitKehamilan}>
            <div className="bg-white rounded-2xl p-6 shadow-sm">
              <h3 className="font-semibold mb-4">Data Kehamilan</h3>
              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  HPHT
                </label>
                <input
                  type="date"
                  name="hpht"
                  value={formKehamilan.hpht}
                  onChange={handleChangeKehamilan}
                  max={today}
                  className="w-full border rounded-xl p-3"
                  required
                />
                {errors.hpht && (
                  <p className="text-red-500 text-sm mt-1">{errors.hpht}</p>
                )}
              </div>
              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Taksiran Persalinan (HPL)
                </label>
                <input
                  type="date"
                  value={formKehamilan.taksiran_persalinan}
                  disabled
                  className="w-full border rounded-xl p-3 bg-gray-50"
                />
              </div>
              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Jarak Kehamilan Sebelumnya (bulan)
                </label>
                <input
                  type="number"
                  name="jarak_kehamilan_sebelumnya"
                  min="0"
                  value={formKehamilan.jarak_kehamilan_sebelumnya}
                  onChange={handleChangeKehamilan}
                  className="w-full border rounded-xl p-3"
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Berat Badan Awal (kg)
                  </label>
                  <input
                    type="number"
                    name="bb_awal"
                    step="0.1"
                    value={formKehamilan.bb_awal}
                    onChange={handleChangeKehamilan}
                    className="w-full border rounded-xl p-3"
                    required
                  />
                  {errors.bb_awal && (
                    <p className="text-red-500 text-sm mt-1">
                      {errors.bb_awal}
                    </p>
                  )}
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Tinggi Badan (cm)
                  </label>
                  <input
                    type="number"
                    name="tb"
                    step="0.1"
                    value={formKehamilan.tb}
                    onChange={handleChangeKehamilan}
                    className="w-full border rounded-xl p-3"
                    required
                  />
                  {errors.tb && (
                    <p className="text-red-500 text-sm mt-1">{errors.tb}</p>
                  )}
                </div>
              </div>
            </div>
            <div className="flex justify-between mt-6">
              <button
                type="button"
                onClick={() => setStep(1)}
                className="px-6 py-2 border rounded-xl hover:bg-gray-50"
              >
                Kembali
              </button>
              <button
                type="submit"
                disabled={loading}
                className="bg-indigo-600 text-white px-6 py-2 rounded-xl flex items-center gap-2"
              >
                {loading ? (
                  <Loader2 className="animate-spin" />
                ) : (
                  <CheckCircle2 size={18} />
                )}
                {loading ? "Menyimpan..." : "Selesai"}
              </button>
            </div>
          </form>
        )}

        {/* STEP 3 - Selesai */}
        {step === 3 && (
          <div className="bg-white rounded-2xl p-6 shadow-sm text-center">
            <CheckCircle2 className="w-16 h-16 text-green-500 mx-auto mb-4" />
            <h3 className="text-xl font-bold mb-2">Data Berhasil Disimpan!</h3>
            <p className="text-gray-600">
              Data ibu dan kehamilan telah berhasil disimpan.
            </p>
            {accountInfo && (
              <div className="mt-4 p-4 bg-green-50 rounded-lg text-left">
                <p className="font-semibold text-green-800 mb-2">
                  📋 Informasi Akun Login Ibu:
                </p>
                <div className="space-y-2 text-sm">
                  <div className="grid grid-cols-3 gap-2">
                    <span className="font-medium text-green-700">Email:</span>
                    <span className="col-span-2 text-gray-700 font-mono break-all">
                      {accountInfo.email}
                    </span>
                  </div>
                  <div className="grid grid-cols-3 gap-2">
                    <span className="font-medium text-green-700">
                      Password:
                    </span>
                    <span className="col-span-2 text-gray-700 font-mono">
                      {accountInfo.password}
                    </span>
                  </div>
                  {accountInfo.phone && (
                    <div className="grid grid-cols-3 gap-2">
                      <span className="font-medium text-green-700">
                        No. Telepon:
                      </span>
                      <span className="col-span-2 text-gray-700">
                        {accountInfo.phone}
                      </span>
                    </div>
                  )}
                </div>
                <div className="mt-3 p-2 bg-yellow-50 rounded border border-yellow-200">
                  <p className="text-xs text-yellow-700">
                    ⚠️ <strong>Catatan Penting:</strong> Simpan informasi ini
                    dengan aman dan berikan kepada ibu untuk login ke aplikasi.
                  </p>
                </div>
              </div>
            )}
            <p className="text-gray-400 text-xs mt-4">
              Mengalihkan ke halaman detail ibu dalam 2 detik...
            </p>
          </div>
        )}
      </div>
    </MainLayout>
  );
}
