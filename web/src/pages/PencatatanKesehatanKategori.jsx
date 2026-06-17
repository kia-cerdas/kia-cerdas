import { useState, useEffect } from 'react';
import { useParams, useNavigate } from "react-router-dom";
import MainLayout from "../components/Layout/MainLayout";
import api from "../services/api";
import { getActiveForm, savePemeriksaan, getRiwayatPemeriksaan } from "../services/pemeriksaan";
import {
  Plus, Search, Eye, ArrowLeft,
  User, AlertCircle, CheckCircle,
  Heart, Droplet, Thermometer, Activity, RefreshCw, Loader2,
  FileText, X, Calendar, BarChart3, Scale, Lightbulb
} from 'lucide-react';
import Swal from "sweetalert2";

const categories = {
  anak: { name: "Anak",  color: "blue", range: "5-9 tahun", bgGradient: "from-blue-500 to-blue-600" },
  remaja: { name: "Remaja",  color: "green", range: "10-18 tahun", bgGradient: "from-green-500 to-green-600" },
  dewasa: { name: "Dewasa",  color: "purple", range: "19-59 tahun", bgGradient: "from-purple-500 to-purple-600" },
  lansia: { name: "Lansia",  color: "orange", range: "≥60 tahun", bgGradient: "from-orange-500 to-orange-600" }
};

// Validasi umum untuk semua kategori
const validations = {
  // Validasi berat badan (kg) - minimal 25 kg (anak minimal), maksimal 200 kg
  berat_badan: (value) => {
    const num = Number(value);
    if (isNaN(num) || num === null || num === undefined) return "Berat badan harus diisi";
    if (num <= 0) return "Berat badan harus lebih dari 0 kg";
    if (num < 10) return "Berat badan terlalu rendah (minimal 10 kg)";
    if (num > 250) return "Berat badan terlalu tinggi (maksimal 250 kg)";
    if (num < 25) return "Berat badan di bawah 25 kg, periksa kembali";
    return null;
  },
  
  // Validasi tinggi badan (cm) - minimal 70 cm (bayi/balita), maksimal 220 cm
  tinggi_badan: (value) => {
    const num = Number(value);
    if (isNaN(num) || num === null || num === undefined) return "Tinggi badan harus diisi";
    if (num <= 0) return "Tinggi badan harus lebih dari 0 cm";
    if (num < 50) return "Tinggi badan terlalu pendek (minimal 50 cm)";
    if (num > 250) return "Tinggi badan terlalu tinggi (maksimal 250 cm)";
    if (num < 70) return "Tinggi badan di bawah 70 cm, periksa kembali";
    if (num > 220) return "Tinggi badan di atas 220 cm, periksa kembali";
    return null;
  },
  
  // Validasi IMT (dihitung otomatis)
  imt: (value) => {
    const num = Number(value);
    if (isNaN(num)) return null;
    if (num < 10) return "IMT terlalu rendah, periksa data berat/tinggi";
    if (num > 50) return "IMT terlalu tinggi, periksa data berat/tinggi";
    if (num < 14) return "IMT rendah (underweight)";
    if (num > 30) return "IMT tinggi (obesitas)";
    if (num > 25) return "IMT di atas normal (overweight)";
    if (num < 18.5) return "IMT di bawah normal (underweight)";
    return null;
  },
  
  // Validasi tekanan darah sistolik (umum)
  tekanan_darah_sistolik: (value) => {
    const num = Number(value);
    if (isNaN(num)) return "Tekanan darah harus diisi";
    if (num < 70) return "Tekanan darah terlalu rendah (hipotensi berat)";
    if (num > 220) return "Tekanan darah terlalu tinggi (hipertensi berat)";
    if (num < 90) return "Tekanan darah rendah (hipotensi)";
    if (num > 140) return "Tekanan darah tinggi (hipertensi)";
    if (num > 160) return "Tekanan darah sangat tinggi, waspada";
    return null;
  },
  
  // Validasi tekanan darah diastolik (umum)
  tekanan_darah_diastolik: (value) => {
    const num = Number(value);
    if (isNaN(num)) return "Tekanan darah harus diisi";
    if (num < 40) return "Tekanan darah diastolik terlalu rendah";
    if (num > 130) return "Tekanan darah diastolik terlalu tinggi";
    if (num < 60) return "Tekanan darah diastolik rendah";
    if (num > 90) return "Tekanan darah diastolik tinggi";
    return null;
  },
  
  // Validasi gula darah (mg/dL) - umum
  gula_darah: (value) => {
    const num = Number(value);
    if (isNaN(num)) return "Gula darah harus diisi";
    if (num < 40) return "Gula darah terlalu rendah (hipoglikemia berat) - segera makan!";
    if (num > 500) return "Gula darah terlalu tinggi (hiperglikemia berat) - segera ke dokter!";
    if (num < 70) return "Gula darah rendah (hipoglikemia) - segera makan makanan manis";
    if (num > 200) return "Gula darah tinggi (hiperglikemia) - kontrol gula darah";
    if (num > 140) return "Gula darah di atas normal - waspada diabetes";
    if (num < 80) return "Gula darah rendah - perlu makan ringan";
    return null;
  },
  
  // Validasi gula darah puasa (khusus)
  gula_darah_puasa: (value) => {
    const num = Number(value);
    if (isNaN(num)) return "Gula darah puasa harus diisi";
    if (num < 60) return "Gula darah puasa terlalu rendah";
    if (num > 200) return "Gula darah puasa terlalu tinggi";
    if (num > 126) return "Gula darah puasa tinggi (prediabetes/diabetes)";
    if (num < 70) return "Gula darah puasa rendah";
    return null;
  },
  
  // Validasi gula darah 2 jam post prandial (setelah makan)
  gula_darah_2jam: (value) => {
    const num = Number(value);
    if (isNaN(num)) return "Gula darah 2 jam harus diisi";
    if (num > 250) return "Gula darah 2 jam terlalu tinggi";
    if (num > 200) return "Gula darah 2 jam tinggi - risiko diabetes";
    if (num > 140) return "Gula darah 2 jam di atas normal";
    return null;
  },
  
  // Validasi suhu tubuh (°C)
  suhu: (value) => {
    const num = Number(value);
    if (isNaN(num)) return "Suhu tubuh harus diisi";
    if (num < 32) return "Suhu terlalu rendah (hipotermia berat) - darurat!";
    if (num > 42) return "Suhu terlalu tinggi (hipertermia berat) - darurat!";
    if (num < 35) return "Suhu rendah (hipotermia) - hangatkan tubuh";
    if (num > 38.5) return "Demam tinggi - segera konsultasi dokter";
    if (num > 37.5) return "Demam ringan - perbanyak minum air putih";
    if (num < 36) return "Suhu di bawah normal";
    return null;
  },
  
  // Validasi kolesterol (mg/dL)
  kolesterol: (value) => {
    const num = Number(value);
    if (isNaN(num)) return "Kolesterol harus diisi";
    if (num < 50) return "Kolesterol terlalu rendah";
    if (num > 400) return "Kolesterol terlalu tinggi - risiko penyakit jantung";
    if (num > 240) return "Kolesterol tinggi - perlu kontrol pola makan";
    if (num > 200) return "Kolesterol di atas normal";
    if (num < 120) return "Kolesterol rendah";
    return null;
  },
  
  // Validasi denyut nadi (per menit)
  denyut_nadi: (value) => {
    const num = Number(value);
    if (isNaN(num)) return "Denyut nadi harus diisi";
    if (num < 40) return "Denyut nadi terlalu lambat (bradikardia berat)";
    if (num > 150) return "Denyut nadi terlalu cepat (takikardia berat)";
    if (num < 60) return "Denyut nadi lambat (bradikardia)";
    if (num > 100) return "Denyut nadi cepat (takikardia)";
    if (num > 120) return "Denyut nadi sangat cepat - waspada";
    return null;
  },
  
  // Validasi lingkar perut (cm)
  lingkar_perut: (value) => {
    const num = Number(value);
    if (isNaN(num)) return null;
    if (num < 50) return "Lingkar perut terlalu kecil";
    if (num > 150) return "Lingkar perut terlalu besar";
    if (num > 90) return "Lingkar perut berlebih - risiko metabolik";
    if (num > 80) return "Lingkar perut melebihi batas normal";
    return null;
  },
  
  // Validasi usia (tahun)
  usia: (value) => {
    const num = Number(value);
    if (isNaN(num)) return "Usia harus diisi";
    if (num < 0) return "Usia tidak boleh negatif";
    if (num < 1) return "Usia minimal 1 tahun";
    if (num > 120) return "Usia maksimal 120 tahun";
    return null;
  },
  
  // Validasi generik untuk angka positif
  positive_number: (value, fieldName) => {
    const num = Number(value);
    if (isNaN(num)) return `${fieldName} harus berupa angka`;
    if (num <= 0) return `${fieldName} harus lebih dari 0`;
    if (num < 0) return `${fieldName} tidak boleh negatif`;
    return null;
  },
  
  // Validasi hemoglobin (gr/dL)
  hemoglobin: (value) => {
    const num = Number(value);
    if (isNaN(num)) return "Hemoglobin harus diisi";
    if (num < 4) return "Hemoglobin terlalu rendah - anemia berat!";
    if (num > 20) return "Hemoglobin terlalu tinggi - waspada";
    if (num < 10) return "Hemoglobin rendah (anemia) - perlu suplemen zat besi";
    if (num < 12) return "Hemoglobin di bawah normal";
    return null;
  },
  
  // Validasi asam urat (mg/dL)
  asam_urat: (value) => {
    const num = Number(value);
    if (isNaN(num)) return "Asam urat harus diisi";
    if (num < 2) return "Asam urat terlalu rendah";
    if (num > 12) return "Asam urat terlalu tinggi - risiko gout";
    if (num > 7) return "Asam urat tinggi - hindari jeroan dan kacang-kacangan";
    if (num > 8.5) return "Asam urat sangat tinggi - konsultasi dokter";
    return null;
  }
};

export default function PencatatanKesehatanKategori() {
  const { kategori = "anak" } = useParams();
  const navigate = useNavigate();
  const cat = categories[kategori] || categories.anak;

  const [patients, setPatients] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [search, setSearch] = useState("");
  const [refreshing, setRefreshing] = useState(false);

  const [modal, setModal] = useState(null);
  const [selectedPatient, setSelectedPatient] = useState(null);
  const [allHistories, setAllHistories] = useState([]);
  const [loadingHistory, setLoadingHistory] = useState(false);

  const [dynamicQuestions, setDynamicQuestions] = useState([]);
  const [dynamicFormData, setDynamicFormData] = useState({});
  const [loadingForm, setLoadingForm] = useState(false);
  const [activeFormVersion, setActiveFormVersion] = useState(null);
  const [submitting, setSubmitting] = useState(false);
  const [fieldErrors, setFieldErrors] = useState({});
  const [fieldWarnings, setFieldWarnings] = useState({});

  // State untuk modal hasil pemeriksaan
  const [resultModal, setResultModal] = useState(false);
  const [resultData, setResultData] = useState({ kategori_risiko: "", rekomendasi: "" });

  // State untuk modal detail pemeriksaan
  const [detailModal, setDetailModal] = useState(false);
  const [detailData, setDetailData] = useState(null);
  const [loadingDetail, setLoadingDetail] = useState(false);

  // Fetch daftar pasien dari backend
  const fetchDataFromAPI = async () => {
    try {
      setLoading(true);
      const response = await api.get(`/tenaga-kesehatan/pencatatan/${kategori}`);
      let dataPenduduk = [];
      if (response.data && response.data.data && Array.isArray(response.data.data)) {
        dataPenduduk = response.data.data;
      } else if (response.data && Array.isArray(response.data)) {
        dataPenduduk = response.data;
      }
      
      const formatted = dataPenduduk.map(p => ({
        id: p.id_kependudukan,
        nama_lengkap: p.nama_lengkap,
        nik: p.nik,
        usia: p.umur_sekarang,
        dusun: p.dusun,
        kategori_risiko: p.pemeriksaan_terakhir?.KategoriRisiko || "Belum Diperiksa",
        dapat_ditambahkan: p.dapat_ditambahkan,
        pemeriksaan_terakhir: p.pemeriksaan_terakhir ? {
          id: p.pemeriksaan_terakhir.ID,
          penduduk_id: p.pemeriksaan_terakhir.PendudukID,
          kelompok: p.pemeriksaan_terakhir.Kelompok,
          tanggal: p.pemeriksaan_terakhir.TanggalPemeriksaan,
          kategori_risiko: p.pemeriksaan_terakhir.KategoriRisiko,
          rekomendasi: p.pemeriksaan_terakhir.Rekomendasi,
          tekanan_darah: p.pemeriksaan_terakhir.TekananDarah,
          gula_darah: p.pemeriksaan_terakhir.GulaDarah,
          suhu: p.pemeriksaan_terakhir.Suhu,
          berat_badan: p.pemeriksaan_terakhir.BeratBadan,
          tinggi_badan: p.pemeriksaan_terakhir.TinggiBadan,
          imt: p.pemeriksaan_terakhir.IMT,
          status_gizi: p.pemeriksaan_terakhir.StatusGizi,
          status_pemantauan: p.pemeriksaan_terakhir.StatusPemantauan,
          riwayat_penyakit: p.pemeriksaan_terakhir.RiwayatPenyakit,
          catatan_khusus: p.pemeriksaan_terakhir.CatatanKhusus
        } : null
      }));
      setPatients(formatted);
    } catch (err) {
      console.error(err);
      setError(err.response?.data?.message || err.message || "Gagal memuat data");
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  // Fetch riwayat pemeriksaan
  const fetchHistories = async (patientId) => {
    setLoadingHistory(true);
    try {
      const response = await getRiwayatPemeriksaan(patientId, kategori);
      return response || [];
    } catch (err) {
      console.error(err);
      Swal.fire({
        icon: "error",
        title: "Gagal Memuat Riwayat",
        text: "Gagal memuat riwayat pemeriksaan",
        confirmButtonColor: "#185FA5",
      });
      return [];
    } finally {
      setLoadingHistory(false);
    }
  };

  // Fetch detail pemeriksaan
  const fetchDetailPemeriksaan = async (pemeriksaanId) => {
    setLoadingDetail(true);
    try {
      const response = await api.get(`/tenaga-kesehatan/pemeriksaan/${pemeriksaanId}`);
      return response.data;
    } catch (err) {
      console.error(err);
      Swal.fire({
        icon: "error",
        title: "Gagal Memuat Detail",
        text: "Gagal memuat detail pemeriksaan",
        confirmButtonColor: "#185FA5",
      });
      return null;
    } finally {
      setLoadingDetail(false);
    }
  };

  const handleShowHistory = async (patient) => {
    setSelectedPatient(patient);
    const histories = await fetchHistories(patient.id);
    setAllHistories(histories);
    setModal("history");
  };

  const handleShowDetail = async (pemeriksaanId) => {
    const data = await fetchDetailPemeriksaan(pemeriksaanId);
    if (data) {
      setDetailData(data);
      setDetailModal(true);
    }
  };

  // Buka modal pemeriksaan dengan form dinamis
  const openCheckupModal = async (patient) => {
    setSelectedPatient(patient);
    setLoadingForm(true);
    setFieldErrors({});
    setFieldWarnings({});
    try {
      const activeForm = await getActiveForm(kategori);
      setActiveFormVersion(activeForm.versi);
      const questions = activeForm.pertanyaan || [];
      setDynamicQuestions(questions);
      const initial = {};
      questions.forEach(q => {
        if (q.tipe === "boolean") {
          initial[q.key] = undefined;
        } else if (q.tipe === "angka") {
          initial[q.key] = undefined;
        } else {
          initial[q.key] = "";
        }
      });
      setDynamicFormData(initial);
      setModal("checkup");
    } catch (err) {
      console.error(err);
      Swal.fire({
        icon: "error",
        title: "Gagal Memuat Form",
        text: "Gagal memuat form pemeriksaan. Pastikan superadmin sudah mengaktifkan versi form untuk kategori ini.",
        confirmButtonColor: "#185FA5",
      });
    } finally {
      setLoadingForm(false);
    }
  };

  // Validasi field berdasarkan tipe dan key
  const validateField = (key, value, tipe) => {
    if (tipe !== "angka") return { error: null, warning: null };
    
    const numValue = Number(value);
    if (isNaN(numValue) && value !== undefined && value !== "") {
      return { error: "Harus berupa angka", warning: null };
    }
    if (value === undefined || value === "" || value === null) {
      return { error: null, warning: null };
    }
    
    let error = null;
    
    // Pilih fungsi validasi berdasarkan key
    switch(key) {
      case "berat_badan":
      case "berat":
      case "bb":
        error = validations.berat_badan(value);
        break;
      case "tinggi_badan":
      case "tinggi":
      case "tb":
        error = validations.tinggi_badan(value);
        break;
      case "imt":
      case "bmi":
        error = validations.imt(value);
        break;
      case "tekanan_darah_sistolik":
      case "tekanan_darah_sistole":
      case "td_sistolik":
      case "sistolik":
        error = validations.tekanan_darah_sistolik(value);
        break;
      case "tekanan_darah_diastolik":
      case "tekanan_darah_diastole":
      case "td_diastolik":
      case "diastolik":
        error = validations.tekanan_darah_diastolik(value);
        break;
      case "gula_darah":
      case "gds":
      case "gula_darah_sewaktu":
        error = validations.gula_darah(value);
        break;
      case "gula_darah_puasa":
      case "gdp":
        error = validations.gula_darah_puasa(value);
        break;
      case "gula_darah_2jam":
      case "gd2pp":
        error = validations.gula_darah_2jam(value);
        break;
      case "suhu":
      case "suhu_tubuh":
        error = validations.suhu(value);
        break;
      case "kolesterol":
      case "kolesterol_total":
        error = validations.kolesterol(value);
        break;
      case "denyut_nadi":
      case "nadi":
      case "heart_rate":
        error = validations.denyut_nadi(value);
        break;
      case "lingkar_perut":
      case "lingkar_pinggang":
      case "waist":
        error = validations.lingkar_perut(value);
        break;
      case "usia":
      case "umur":
        error = validations.usia(value);
        break;
      case "hemoglobin":
      case "hb":
        error = validations.hemoglobin(value);
        break;
      case "asam_urat":
      case "uric_acid":
        error = validations.asam_urat(value);
        break;
      default:
        if (key.includes("jumlah") || key.includes("frekuensi") || key.includes("kali")) {
          error = validations.positive_number(value, key.replace(/_/g, ' '));
        }
        break;
    }
    
    // Pisahkan error dan warning
    if (error && (error.includes("rendah") || error.includes("tinggi") || error.includes("di atas") || error.includes("di bawah"))) {
      return { error: null, warning: error };
    }
    return { error: error, warning: null };
  };

  // Handler perubahan nilai dengan konversi tipe dan validasi
  const handleDynamicChange = (key, value, tipe) => {
    let finalValue = value;
    if (tipe === "angka") {
      finalValue = value === "" ? undefined : Number(value);
    } else if (tipe === "boolean") {
      finalValue = value;
    }
    
    // Validasi field
    const { error, warning } = validateField(key, value, tipe);
    setFieldErrors(prev => ({
      ...prev,
      [key]: error
    }));
    setFieldWarnings(prev => ({
      ...prev,
      [key]: warning
    }));
    
    setDynamicFormData(prev => {
      const newData = { ...prev, [key]: finalValue };
      
      // Hitung IMT jika berat_badan atau tinggi_badan berubah
      if ((key === "berat_badan" || key === "berat" || key === "bb") || 
          (key === "tinggi_badan" || key === "tinggi" || key === "tb")) {
        
        const berat = (key === "berat_badan" || key === "berat" || key === "bb") 
          ? finalValue 
          : (prev.berat_badan || prev.berat || prev.bb);
        const tinggi = (key === "tinggi_badan" || key === "tinggi" || key === "tb") 
          ? finalValue 
          : (prev.tinggi_badan || prev.tinggi || prev.tb);
        
        if (berat && tinggi && tinggi > 0) {
          const imt = berat / ((tinggi / 100) * (tinggi / 100));
          const imtValue = parseFloat(imt.toFixed(1));
          newData.imt = imtValue;
          
          // Validasi IMT
          const imtValidation = validations.imt(imtValue);
          if (imtValidation) {
            if (imtValidation.includes("rendah") || imtValidation.includes("tinggi")) {
              setFieldWarnings(prevW => ({ ...prevW, imt: imtValidation }));
              setFieldErrors(prevE => {
                const { imt, ...rest } = prevE;
                return rest;
              });
            } else {
              setFieldErrors(prevE => ({ ...prevE, imt: imtValidation }));
              setFieldWarnings(prevW => {
                const { imt, ...rest } = prevW;
                return rest;
              });
            }
          }
        } else {
          newData.imt = undefined;
        }
      }
      
      return newData;
    });
  };

  // Validasi semua field wajib
  const validateAllFields = () => {
    const errors = {};
    
    for (let q of dynamicQuestions) {
      if (q.wajib) {
        const val = dynamicFormData[q.key];
        if (val === undefined || val === null || val === "") {
          errors[q.key] = `${q.label} wajib diisi`;
        } else if (q.tipe === "boolean" && typeof val !== "boolean") {
          errors[q.key] = `${q.label} wajib dipilih`;
        } else if (q.tipe === "angka" && isNaN(val)) {
          errors[q.key] = `${q.label} harus berupa angka`;
        }
      }
      
      // Cek error validasi spesifik (yang bukan warning)
      const specificError = fieldErrors[q.key];
      if (specificError) {
        errors[q.key] = specificError;
      }
    }
    
    setFieldErrors(prev => ({ ...prev, ...errors }));
    return Object.keys(errors).length === 0;
  };

  // Simpan pemeriksaan
  const handleSaveDynamicCheckup = async (e) => {
    e.preventDefault();
    if (!selectedPatient) return;
    
    // Validasi semua field
    if (!validateAllFields()) {
      const errorMessages = Object.values(fieldErrors);
      Swal.fire({
        icon: "warning",
        title: "Data Belum Lengkap",
        html: `Mohon perbaiki data berikut:<br>${errorMessages.map(msg => `- ${msg}`).join('<br>')}`,
        confirmButtonColor: "#185FA5",
      });
      return;
    }
    
    // Tampilkan warning jika ada
    const warnings = Object.values(fieldWarnings).filter(w => w);
    if (warnings.length > 0) {
      const confirmMessage = `PERHATIAN!\n\nBeberapa data berada di luar batas normal:\n${warnings.map(w => `- ${w}`).join('\n')}\n\nApakah Anda tetap ingin menyimpan?`;
      if (!window.confirm(confirmMessage)) {
        return;
      }
    }
    
    setSubmitting(true);
    try {
      const payload = {
        penduduk_id: selectedPatient.id,
        kelompok: kategori,
        tanggal: new Date().toISOString().split('T')[0],
        data: dynamicFormData
      };
      const response = await savePemeriksaan(payload);
      setResultData({
        kategori_risiko: response.kategori_risiko || "Normal",
        rekomendasi: response.rekomendasi || "Tidak ada rekomendasi"
      });
      setResultModal(true);
      setModal(null);
      fetchDataFromAPI();
    } catch (err) {
      console.error(err);
      Swal.fire({
        icon: "error",
        title: "Gagal Menyimpan",
        text: err.response?.data?.error || "Gagal menyimpan pemeriksaan",
        confirmButtonColor: "#185FA5",
      });
    } finally {
      setSubmitting(false);
    }
  };

  // Render input field berdasarkan tipe dengan validasi
  const renderDynamicField = (q) => {
    const value = dynamicFormData[q.key];
    const isImt = q.key === "imt" || q.key === "bmi";
    const error = fieldErrors[q.key];
    const warning = fieldWarnings[q.key];
    const hasError = !!error;
    const hasWarning = !!warning && !hasError;

    // Tentukan batas min/max berdasarkan key
    let minValue = undefined;
    let maxValue = undefined;
    let stepValue = "any";
    
    if (q.key === "suhu" || q.key === "suhu_tubuh") {
      minValue = 32;
      maxValue = 42;
      stepValue = 0.1;
    } else if (q.key === "berat_badan" || q.key === "berat" || q.key === "bb") {
      minValue = 5;
      maxValue = 250;
    } else if (q.key === "tinggi_badan" || q.key === "tinggi" || q.key === "tb") {
      minValue = 50;
      maxValue = 250;
    } else if (q.key === "tekanan_darah_sistolik" || q.key === "tekanan_darah_diastolik" ||
               q.key === "td_sistolik" || q.key === "td_diastolik") {
      minValue = 30;
      maxValue = 250;
    } else if (q.key === "gula_darah" || q.key === "gds" || q.key === "gula_darah_puasa") {
      minValue = 30;
      maxValue = 600;
    } else if (q.key === "denyut_nadi" || q.key === "nadi") {
      minValue = 30;
      maxValue = 200;
    }

    switch (q.tipe) {
      case "angka":
        return (
          <div>
            <input
              type="number"
              step={stepValue}
              value={value === undefined ? "" : value}
              onChange={(e) => !isImt && handleDynamicChange(q.key, e.target.value, q.tipe)}
              className={`w-full p-2 border rounded-lg focus:ring-2 focus:ring-blue-500 transition-colors
                ${hasError ? 'border-red-500 bg-red-50' : hasWarning ? 'border-yellow-500 bg-yellow-50' : 'border-gray-300'}
                ${isImt ? 'bg-gray-100' : ''}`}
              required={q.wajib && !isImt}
              disabled={isImt}
              readOnly={isImt}
              placeholder={isImt ? "Akan dihitung otomatis" : ""}
              min={minValue}
              max={maxValue}
            />
            {hasError && (
              <p className="text-red-500 text-xs mt-1 flex items-center gap-1">
                <AlertCircle size={12} /> {error}
              </p>
            )}
            {hasWarning && !hasError && (
              <p className="text-yellow-600 text-xs mt-1 flex items-center gap-1">
                <AlertCircle size={12} /> {warning}
              </p>
            )}
            {/* Informasi nilai normal */}
            {!hasError && !hasWarning && q.key === "tekanan_darah_sistolik" && value && (
              <p className="text-green-600 text-xs mt-1">Tekanan darah normal (90-140 mmHg)</p>
            )}
            {!hasError && !hasWarning && q.key === "gula_darah" && value && value >= 70 && value <= 140 && (
              <p className="text-green-600 text-xs mt-1">Gula darah normal (70-140 mg/dL)</p>
            )}
            {!hasError && !hasWarning && q.key === "suhu" && value && value >= 36 && value <= 37.5 && (
              <p className="text-green-600 text-xs mt-1">Suhu tubuh normal</p>
            )}
          </div>
        );
      case "teks":
        return (
          <div>
            <input
              type="text"
              value={value || ""}
              onChange={(e) => handleDynamicChange(q.key, e.target.value, q.tipe)}
              className={`w-full p-2 border rounded-lg focus:ring-2 focus:ring-blue-500
                ${hasError ? 'border-red-500 bg-red-50' : 'border-gray-300'}`}
              required={q.wajib}
            />
            {hasError && <p className="text-red-500 text-xs mt-1">{error}</p>}
          </div>
        );
      case "boolean":
        return (
          <div>
            <div className="flex items-center gap-4">
              <label className="inline-flex items-center">
                <input
                  type="radio"
                  name={q.key}
                  checked={value === true}
                  onChange={() => {
                    handleDynamicChange(q.key, true, q.tipe);
                    setFieldErrors(prev => {
                      const { [q.key]: _, ...rest } = prev;
                      return rest;
                    });
                  }}
                  className="mr-1"
                  required={q.wajib}
                /> Ya
              </label>
              <label className="inline-flex items-center">
                <input
                  type="radio"
                  name={q.key}
                  checked={value === false}
                  onChange={() => {
                    handleDynamicChange(q.key, false, q.tipe);
                    setFieldErrors(prev => {
                      const { [q.key]: _, ...rest } = prev;
                      return rest;
                    });
                  }}
                  className="mr-1"
                  required={q.wajib}
                /> Tidak
              </label>
            </div>
            {hasError && <p className="text-red-500 text-xs mt-1">{error}</p>}
          </div>
        );
      case "pilihan":
        let options = q.opsi || [];
        if (options.length > 0 && typeof options[0] === 'object') {
          options = options.map(opt => opt.label);
        }
        return (
          <div>
            <select
              value={value || ""}
              onChange={(e) => {
                handleDynamicChange(q.key, e.target.value, q.tipe);
                setFieldErrors(prev => {
                  const { [q.key]: _, ...rest } = prev;
                  return rest;
                });
              }}
              className={`w-full p-2 border rounded-lg focus:ring-2 focus:ring-blue-500
                ${hasError ? 'border-red-500 bg-red-50' : 'border-gray-300'}`}
              required={q.wajib}
            >
              <option value="">Pilih...</option>
              {options.map(opt => <option key={opt} value={opt}>{opt}</option>)}
            </select>
            {hasError && <p className="text-red-500 text-xs mt-1">{error}</p>}
          </div>
        );
      case "tanggal":
        return (
          <div>
            <input
              type="date"
              value={value || ""}
              onChange={(e) => handleDynamicChange(q.key, e.target.value, q.tipe)}
              className={`w-full p-2 border rounded-lg focus:ring-2 focus:ring-blue-500
                ${hasError ? 'border-red-500 bg-red-50' : 'border-gray-300'}`}
              required={q.wajib}
            />
            {hasError && <p className="text-red-500 text-xs mt-1">{error}</p>}
          </div>
        );
      default:
        return (
          <div>
            <input
              type="text"
              value={value || ""}
              onChange={(e) => handleDynamicChange(q.key, e.target.value, q.tipe)}
              className={`w-full p-2 border rounded-lg focus:ring-2 focus:ring-blue-500
                ${hasError ? 'border-red-500 bg-red-50' : 'border-gray-300'}`}
              required={q.wajib}
            />
            {hasError && <p className="text-red-500 text-xs mt-1">{error}</p>}
          </div>
        );
    }
  };

  // Filter pasien berdasarkan search
  const filteredPatients = patients.filter(p =>
    p.nama_lengkap?.toLowerCase().includes(search.toLowerCase()) ||
    (p.nik || "").includes(search)
  );

  // Helper status kesehatan
  const getHealthStatus = (patient) => {
    const risiko = patient.kategori_risiko;
    if (risiko === "Normal") return { text: "Normal", color: "bg-green-100 text-green-800", icon: CheckCircle };
    if (risiko === "Sedang") return { text: "Risiko Sedang", color: "bg-yellow-100 text-yellow-800", icon: AlertCircle };
    if (risiko === "Tinggi") return { text: "Risiko Tinggi", color: "bg-red-100 text-red-800", icon: AlertCircle };
    return { text: "Belum Diperiksa", color: "bg-gray-100 text-gray-500", icon: AlertCircle };
  };

  // Statistik risiko
  const getStatsByRisiko = () => {
    const normal = patients.filter(p => p.kategori_risiko === "Normal").length;
    const sedang = patients.filter(p => p.kategori_risiko === "Sedang").length;
    const tinggi = patients.filter(p => p.kategori_risiko === "Tinggi").length;
    const belum = patients.filter(p => !p.kategori_risiko || p.kategori_risiko === "Belum Diperiksa").length;
    return { normal, sedang, tinggi, belum, total: patients.length };
  };
  const stats = getStatsByRisiko();

  const getColorClass = (color, type) => {
    const colors = {
      blue: { bg: "bg-blue-600", text: "text-blue-600", border: "border-blue-200", light: "bg-blue-50" },
      green: { bg: "bg-green-600", text: "text-green-600", border: "border-green-200", light: "bg-green-50" },
      purple: { bg: "bg-purple-600", text: "text-purple-600", border: "border-purple-200", light: "bg-purple-50" },
      orange: { bg: "bg-orange-600", text: "text-orange-600", border: "border-orange-200", light: "bg-orange-50" }
    };
    return colors[color]?.[type] || colors.blue[type];
  };

  useEffect(() => {
    fetchDataFromAPI();
  }, [kategori]);

  if (loading) return <MainLayout><div className="p-6 text-center">Memuat data...</div></MainLayout>;

  return (
    <MainLayout>
      <div className="min-h-screen bg-gray-50">
        <div className="max-w-7xl mx-auto p-6">
          {/* Header */}
          <div className="flex justify-between items-center mb-6">
            <div className="flex items-center gap-3">
              <button onClick={() => navigate("/dashboard")} className="p-2 hover:bg-gray-200 rounded-lg">
                <ArrowLeft size={20} />
              </button>
              <div className={`p-3 rounded-xl ${getColorClass(cat.color, "light")}`}>
                <span className="text-2xl">{cat.emoji}</span>
              </div>
              <div>
                <h1 className="text-2xl font-bold text-gray-900">Daftar {cat.name}</h1>
                <p className="text-gray-500 text-sm">Rentang usia: {cat.range}</p>
              </div>
            </div>
            <button onClick={() => { setRefreshing(true); fetchDataFromAPI(); }} disabled={refreshing} className="bg-gray-500 text-white px-4 py-2 rounded-lg flex items-center gap-2 hover:bg-gray-600">
              <RefreshCw size={18} className={refreshing ? "animate-spin" : ""} /> Refresh
            </button>
          </div>

          {/* Search */}
          <div className="mb-4 relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={18} />
            <input type="text" placeholder="Cari nama atau NIK..." value={search} onChange={(e) => setSearch(e.target.value)} className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500" />
          </div>

          {/* Stats */}
          <div className="grid grid-cols-4 gap-3 mb-6">
            <div className="bg-white p-3 rounded-lg shadow-sm border-l-4 border-blue-500">
              <p className="text-2xl font-bold">{stats.total}</p>
              <p className="text-sm text-gray-500">Total Pasien</p>
            </div>
            <div className="bg-white p-3 rounded-lg shadow-sm border-l-4 border-green-500">
              <p className="text-2xl font-bold text-green-600">{stats.normal}</p>
              <p className="text-sm text-gray-500">Risiko Normal</p>
            </div>
            <div className="bg-white p-3 rounded-lg shadow-sm border-l-4 border-yellow-500">
              <p className="text-2xl font-bold text-yellow-600">{stats.sedang}</p>
              <p className="text-sm text-gray-500">Risiko Sedang</p>
            </div>
            <div className="bg-white p-3 rounded-lg shadow-sm border-l-4 border-red-500">
              <p className="text-2xl font-bold text-red-600">{stats.tinggi}</p>
              <p className="text-sm text-gray-500">Risiko Tinggi</p>
            </div>
          </div>

          {error && (
            <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-6 text-center">
              <AlertCircle size={24} className="text-red-500 mx-auto mb-2" />
              <p className="text-red-600">{error}</p>
              <button onClick={fetchDataFromAPI} className="mt-2 text-red-600 underline">Coba lagi</button>
            </div>
          )}

          {/* Daftar Pasien */}
          {filteredPatients.length === 0 ? (
            <div className="bg-white rounded-lg shadow-sm p-12 text-center">
              <User size={48} className="mx-auto mb-3 text-gray-400" />
              <p className="text-gray-500">Belum ada data pasien untuk kategori {cat.name}</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {filteredPatients.map(patient => {
                const status = getHealthStatus(patient);
                const StatusIcon = status.icon;
                const latest = patient.pemeriksaan_terakhir;
                const dapatDitambahkan = patient.dapat_ditambahkan;
                return (
                  <div key={patient.id} className="bg-white rounded-xl shadow-md overflow-hidden hover:shadow-lg transition">
                    <div className={`bg-gradient-to-r ${cat.bgGradient} p-4 text-white`}>
                      <div className="flex justify-between items-start">
                        <div>
                          <h3 className="font-bold text-lg">{patient.nama_lengkap}</h3>
                          <p className="text-sm opacity-90">{patient.usia} tahun</p>
                          {patient.dusun && <p className="text-xs opacity-75 mt-1"> {patient.dusun}</p>}
                        </div>
                        <div className={`flex items-center gap-1 px-2 py-1 rounded-full text-xs ${status.color} bg-white`}>
                          <StatusIcon size={12} /> {status.text}
                        </div>
                      </div>
                    </div>
                    <div className="p-4">
                      {patient.nik && <div className="flex items-center gap-1 text-sm text-gray-600 mb-1"><span className="font-medium">NIK:</span> {patient.nik}</div>}
                      <div className="mb-3 p-2 rounded-lg text-center text-sm font-medium"
                        style={{
                          backgroundColor: patient.kategori_risiko === "Tinggi" ? "#fee2e2" :
                                          patient.kategori_risiko === "Sedang" ? "#fef3c7" :
                                          patient.kategori_risiko === "Normal" ? "#dcfce7" : "#f3f4f6",
                          color: patient.kategori_risiko === "Tinggi" ? "#dc2626" :
                                 patient.kategori_risiko === "Sedang" ? "#d97706" :
                                 patient.kategori_risiko === "Normal" ? "#16a34a" : "#6b7280"
                        }}>
                        {patient.kategori_risiko === "Tinggi" && <AlertCircle size={14} className="inline mr-1" />}
                        {patient.kategori_risiko === "Sedang" && <AlertCircle size={14} className="inline mr-1" />}
                        {patient.kategori_risiko === "Normal" && <CheckCircle size={14} className="inline mr-1" />}
                        Status Risiko: {patient.kategori_risiko || "Belum Diperiksa"}
                      </div>
                      {latest ? (
                        <div className="bg-gray-50 p-3 rounded-lg text-sm mb-4">
                          <div className="flex items-center gap-1 text-gray-500 mb-2">
                            <Calendar size={12} className="inline" /> Pemeriksaan Terakhir: {new Date(latest.tanggal).toLocaleDateString("id-ID")}
                          </div>
                          <div className="flex gap-3 flex-wrap">
                            {latest.tekanan_darah && <div><Heart size={12} className="inline text-red-500" /> {latest.tekanan_darah}</div>}
                            {latest.gula_darah && <div><Droplet size={12} className="inline text-blue-500" /> {latest.gula_darah} mg/dL</div>}
                            {latest.suhu && <div><Thermometer size={12} className="inline text-orange-500" /> {latest.suhu}°C</div>}
                            {latest.berat_badan && latest.tinggi_badan && <div><Activity size={12} className="inline text-green-600" /> BB: {latest.berat_badan} kg / TB: {latest.tinggi_badan} cm</div>}
                            {latest.imt && <div><BarChart3 size={12} className="inline text-purple-500" /> IMT: {latest.imt.toFixed(1)}</div>}
                          </div>
                        </div>
                      ) : (
                        <div className="bg-yellow-50 p-3 rounded-lg text-center text-sm text-yellow-700 mb-4">
                          <AlertCircle size={14} className="inline mr-1" /> Belum ada pemeriksaan
                        </div>
                      )}
                      <div className="flex gap-2">
                        <button onClick={() => handleShowHistory(patient)} className="flex-1 bg-blue-100 text-blue-700 py-2 rounded-lg text-sm hover:bg-blue-200 flex items-center justify-center gap-1">
                          <Eye size={14} /> Riwayat
                        </button>
                        {dapatDitambahkan ? (
                          <button onClick={() => openCheckupModal(patient)} className="flex-1 bg-green-100 text-green-700 py-2 rounded-lg text-sm hover:bg-green-200 flex items-center justify-center gap-1">
                            <Plus size={14} /> Periksa
                          </button>
                        ) : (
                          <button disabled className="flex-1 bg-gray-100 text-gray-400 py-2 rounded-lg text-sm cursor-not-allowed">
                            <Plus size={14} /> Tidak Aktif
                          </button>
                        )}
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}

          {/* Modal Riwayat */}
          {modal === "history" && selectedPatient && (
            <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
              <div className="bg-white rounded-lg max-w-3xl w-full max-h-[80vh] overflow-y-auto">
                <div className="sticky top-0 bg-white border-b p-4 flex justify-between items-center">
                  <div>
                    <h2 className="text-xl font-bold">Riwayat Pemeriksaan</h2>
                    <p className="text-gray-500 text-sm">{selectedPatient.nama_lengkap} • {cat.name}</p>
                  </div>
                  <button onClick={() => setModal(null)} className="text-gray-400 text-2xl hover:text-gray-600">&times;</button>
                </div>
                <div className="p-5">
                  {loadingHistory ? (
                    <div className="text-center py-8"><Loader2 className="animate-spin mx-auto text-blue-600" size={32} /><p className="mt-2">Memuat riwayat...</p></div>
                  ) : allHistories.length === 0 ? (
                    <div className="text-center py-8 text-gray-500">Belum ada riwayat pemeriksaan</div>
                  ) : (
                    <div className="space-y-4">
                      {allHistories.map((exam, idx) => (
                        <div key={exam.id || idx} className="border rounded-lg p-3 hover:bg-gray-50">
                          <div className="font-medium">
                            {new Date(exam.tanggal_pemeriksaan).toLocaleDateString("id-ID", {
                              weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'
                            })}
                          </div>
                          <div className="grid grid-cols-2 gap-2 text-sm mt-2">
                            {exam.tekanan_darah && <div><Heart size={12} className="inline text-red-500" /> TD: {exam.tekanan_darah}</div>}
                            {exam.gula_darah && <div><Droplet size={12} className="inline text-blue-500" /> GDS: {exam.gula_darah} mg/dL</div>}
                            {exam.kolesterol && <div><FileText size={12} className="inline text-red-600" /> Kolesterol: {exam.kolesterol} mg/dL</div>}
                            {exam.berat_badan && exam.tinggi_badan && <div><Scale size={12} className="inline text-gray-600" /> BB: {exam.berat_badan} kg / TB: {exam.tinggi_badan} cm</div>}
                            {exam.imt && <div><BarChart3 size={12} className="inline text-purple-500" /> IMT: {typeof exam.imt === 'number' ? exam.imt.toFixed(1) : exam.imt}</div>}
                            {exam.kategori_risiko && <div><AlertCircle size={12} className="inline text-yellow-500" /> Risiko: {exam.kategori_risiko}</div>}
                            {exam.rekomendasi && <div><Lightbulb size={12} className="inline text-yellow-600" /> Rekomendasi: {exam.rekomendasi}</div>}
                          </div>
                          {exam.riwayat_penyakit && <div className="text-sm mt-2"><span className="font-medium">Riwayat:</span> {exam.riwayat_penyakit}</div>}
                          {exam.catatan_khusus && <div className="text-sm mt-1"><span className="font-medium">Catatan:</span> {exam.catatan_khusus}</div>}
                          
                          <button 
                            onClick={() => handleShowDetail(exam.id)} 
                            className="mt-3 text-sm text-blue-600 hover:text-blue-800 flex items-center gap-1"
                          >
                            <FileText size={14} /> Lihat Detail Lengkap
                          </button>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </div>
            </div>
          )}

          {/* Modal Detail Pemeriksaan */}
          {detailModal && detailData && (
            <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
              <div className="bg-white rounded-lg max-w-2xl w-full max-h-[85vh] overflow-y-auto">
                <div className="sticky top-0 bg-white border-b p-4 flex justify-between items-center">
                  <div>
                    <h2 className="text-xl font-bold">Detail Pemeriksaan</h2>
                    <p className="text-gray-500 text-sm">
                      {detailData.nama_penduduk} • {detailData.kelompok} •{' '}
                      {new Date(detailData.tanggal_pemeriksaan).toLocaleDateString("id-ID")}
                    </p>
                  </div>
                  <button onClick={() => setDetailModal(false)} className="text-gray-400 hover:text-gray-600">
                    <X size={24} />
                  </button>
                </div>
                <div className="p-5">
                  {loadingDetail ? (
                    <div className="text-center py-8">
                      <Loader2 className="animate-spin mx-auto text-blue-600" size={32} />
                      <p className="mt-2">Memuat detail...</p>
                    </div>
                  ) : (
                    <div className="space-y-4">
                      <div className="bg-gray-50 p-4 rounded-lg">
                        <h3 className="font-semibold text-lg mb-2">Hasil Pemeriksaan</h3>
                        <div className="grid grid-cols-2 gap-3">
                          <div>
                            <span className="text-gray-500 text-sm">Versi Form</span>
                            <p className="font-medium">{detailData.versi_form || "-"}</p>
                          </div>
                          <div>
                            <span className="text-gray-500 text-sm">Kategori Risiko</span>
                            <p className={`font-bold ${
                              detailData.kategori_risiko === "Tinggi" ? "text-red-600" :
                              detailData.kategori_risiko === "Sedang" ? "text-yellow-600" :
                              detailData.kategori_risiko === "Normal" ? "text-green-600" :
                              "text-gray-600"
                            }`}>
                              {detailData.kategori_risiko || "-"}
                            </p>
                          </div>
                        </div>
                      </div>

                      {detailData.jawaban && Object.keys(detailData.jawaban).length > 0 && (
                        <div className="border rounded-lg p-4">
                          <h3 className="font-semibold text-lg mb-3">Data Pemeriksaan</h3>
                          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                            {Object.entries(detailData.jawaban).map(([key, value]) => (
                              <div key={key} className="border-b pb-2">
                                <span className="text-gray-500 text-xs uppercase block">{key.replace(/_/g, ' ')}</span>
                                <p className="font-medium">
                                  {typeof value === 'boolean' ? (value ? 'Ya' : 'Tidak') : 
                                   typeof value === 'number' ? value.toLocaleString() : 
                                   value || '-'}
                                </p>
                              </div>
                            ))}
                          </div>
                        </div>
                      )}

                      {detailData.rekomendasi && (
                        <div className="bg-blue-50 p-4 rounded-lg">
                          <h3 className="font-semibold text-blue-800 mb-2">Rekomendasi</h3>
                          <p className="text-blue-700">{detailData.rekomendasi}</p>
                        </div>
                      )}
                    </div>
                  )}
                </div>
              </div>
            </div>
          )}

          {/* Modal Pemeriksaan Dinamis */}
          {modal === "checkup" && selectedPatient && (
            <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
              <div className="bg-white rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto">
                <div className="sticky top-0 bg-white border-b p-4 flex justify-between items-center">
                  <div>
                    <h2 className="text-xl font-bold">Pemeriksaan {cat.name}</h2>
                    <p className="text-gray-500 text-sm">{selectedPatient.nama_lengkap}</p>
                    {activeFormVersion && <p className="text-xs text-gray-400">Menggunakan form: {activeFormVersion.nama} (Tahun {activeFormVersion.tahun})</p>}
                  </div>
                  <button onClick={() => setModal(null)} className="text-gray-400 text-2xl hover:text-gray-600">&times;</button>
                </div>
                {loadingForm ? (
                  <div className="p-8 text-center"><Loader2 className="animate-spin mx-auto text-blue-600" size={32} /><p className="mt-2">Memuat form...</p></div>
                ) : (
                  <form onSubmit={handleSaveDynamicCheckup} className="p-5 space-y-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Tanggal Pemeriksaan *</label>
                      <input type="date" value={new Date().toISOString().split('T')[0]} className="w-full p-2 border border-gray-300 rounded-lg bg-gray-100" disabled required />
                    </div>
                    {dynamicQuestions.map(q => (
                      <div key={q.id} className="flex flex-col gap-1">
                        <label className="font-medium text-gray-800">
                          {q.label} {q.satuan && `(${q.satuan})`} {q.wajib && <span className="text-red-500">*</span>}
                        </label>
                        {renderDynamicField(q)}
                        {/* Informasi nilai normal */}
                        {q.key === "berat_badan" && (
                          <p className="text-xs text-blue-600 mt-0.5 flex items-center gap-1">
                            <Lightbulb size={10} className="inline" /> Nilai normal: 25-200 kg
                          </p>
                        )}
                        {q.key === "tinggi_badan" && (
                          <p className="text-xs text-blue-600 mt-0.5 flex items-center gap-1">
                            <Lightbulb size={10} className="inline" /> Nilai normal: 70-220 cm
                          </p>
                        )}
                        {q.key === "tekanan_darah_sistolik" && (
                          <p className="text-xs text-blue-600 mt-0.5 flex items-center gap-1">
                            <Lightbulb size={10} className="inline" /> Nilai normal: 90-140 mmHg
                          </p>
                        )}
                        {q.key === "gula_darah" && (
                          <p className="text-xs text-blue-600 mt-0.5 flex items-center gap-1">
                            <Lightbulb size={10} className="inline" /> Gula darah normal: 70-140 mg/dL (puasa: 70-100 mg/dL)
                          </p>
                        )}
                        {q.key === "suhu" && (
                          <p className="text-xs text-blue-600 mt-0.5 flex items-center gap-1">
                            <Lightbulb size={10} className="inline" /> Suhu normal: 36-37.5°C
                          </p>
                        )}
                      </div>
                    ))}
                    <div className="flex gap-3 pt-3">
                      <button type="submit" disabled={submitting} className="flex-1 bg-green-600 text-white py-2 rounded-lg hover:bg-green-700 disabled:opacity-50 flex items-center justify-center gap-2">
                        {submitting ? <Loader2 className="animate-spin" size={18} /> : null}
                        {submitting ? 'Menyimpan...' : 'Simpan Pemeriksaan'}
                      </button>
                      <button type="button" onClick={() => setModal(null)} className="flex-1 bg-gray-200 text-gray-800 py-2 rounded-lg hover:bg-gray-300">Batal</button>
                    </div>
                  </form>
                )}
              </div>
            </div>
          )}

          {/* Modal Hasil Pemeriksaan */}
          {resultModal && (
            <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
              <div className="bg-white rounded-lg max-w-md w-full p-6 shadow-xl">
                <div className="text-center">
                  <div className={`mx-auto w-16 h-16 rounded-full flex items-center justify-center text-2xl
                    ${resultData.kategori_risiko === "Tinggi" ? "bg-red-100 text-red-600" :
                      resultData.kategori_risiko === "Sedang" ? "bg-yellow-100 text-yellow-600" :
                      resultData.kategori_risiko === "Normal" ? "bg-green-100 text-green-600" :
                      "bg-gray-100 text-gray-600"}`}>
                    {resultData.kategori_risiko === "Tinggi" ? <AlertCircle size={32} /> :
                     resultData.kategori_risiko === "Sedang" ? <AlertCircle size={32} /> :
                     resultData.kategori_risiko === "Normal" ? <CheckCircle size={32} /> : <AlertCircle size={32} />}
                  </div>
                  <h3 className="text-xl font-bold mt-4">Pemeriksaan Selesai</h3>
                  <div className="mt-4 p-3 rounded-lg bg-gray-50">
                    <p className="text-sm text-gray-600">Tingkat Risiko</p>
                    <p className={`text-2xl font-bold
                      ${resultData.kategori_risiko === "Tinggi" ? "text-red-600" :
                        resultData.kategori_risiko === "Sedang" ? "text-yellow-600" :
                        resultData.kategori_risiko === "Normal" ? "text-green-600" :
                        "text-gray-600"}`}>
                      {resultData.kategori_risiko}
                    </p>
                  </div>
                  <div className="mt-3 p-3 rounded-lg bg-blue-50">
                    <p className="text-sm text-gray-600">Rekomendasi</p>
                    <p className="text-md font-medium text-blue-800">{resultData.rekomendasi}</p>
                  </div>
                  <button
                    onClick={() => setResultModal(false)}
                    className="mt-6 w-full bg-green-600 text-white py-2 rounded-lg hover:bg-green-700"
                  >
                    Tutup
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </MainLayout>
  );
}