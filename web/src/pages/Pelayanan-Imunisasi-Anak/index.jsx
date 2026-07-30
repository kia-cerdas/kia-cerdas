import React, { useState, useEffect } from "react";
import { useParams, Link } from "react-router-dom";
import {
  Save,
  Syringe,
  CheckSquare,
  Square,
  Calendar,
  CheckCircle2,
  RefreshCw,
  X,
  ArrowLeft,
  AlertTriangle,
  XCircle,
  CalendarClock,
  Lock,
  Clock,
} from "lucide-react";
import Swal from "sweetalert2";
import MainLayout from "../../components/Layout/MainLayout";
import {
  getImunisasiByAnakId,
  setJadwalSelesai,
  setPencatatanSelesai,
  createPelayananImunisasi,
  getAturanVaksinAnak,
  getPencatatanByAnakId,
  batalParafImunisasi,
} from "../../services/imunisasiBidanService";
import { getJadwalLayananList } from "../../services/jadwalLayanan";

const MONTHS = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 18, 23, "23-59"];

// Extract numeric start from a month value (e.g. '23-59' → 23, 18 → 18)
const getMonthStart = (m) => {
  if (typeof m === "number") return m;
  return parseInt(String(m).split("-")[0]);
};

// ══════════════════════════════════════════════════
// MAIN COMPONENT
// ══════════════════════════════════════════════════
const PelayananImunisasi = () => {
  const { id } = useParams();

  // ─── STATE ─────────────────────────────────────
  const [jadwalList, setJadwalList] = useState([]);
  const [dataAnak, setDataAnak] = useState(null);
  const [aturanVaksin, setAturanVaksin] = useState([]);
  const [pencatatanList, setPencatatanList] = useState([]);
  const [jadwalLayananList, setJadwalLayananList] = useState([]);
  const [jadwalLayananToday, setJadwalLayananToday] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [refreshKey, setRefreshKey] = useState(0);
  const [formData, setFormData] = useState({
    selectedJadwalIds: [],
    batches: {},
    catatan: "",
    tanggal: new Date().toISOString().split("T")[0],
  });

  // ─── DATA FETCHING ─────────────────────────────
  const fetchData = async () => {
    try {
      setLoading(true);
      setError(null);

      const res = await getImunisasiByAnakId(id);
      if (Array.isArray(res) && res.length > 0) {
        setDataAnak(res[0]);
        setJadwalList(res[0].jadwal || []);
      } else {
        setDataAnak(null);
        setJadwalList([]);
      }

      try {
        const resAturan = await getAturanVaksinAnak();
        const aturanList = Array.isArray(resAturan) ? resAturan : [];
        setAturanVaksin(aturanList);
        console.log(
          "[DEBUG] Aturan Vaksin loaded:",
          aturanList.length,
          "items",
        );
        if (aturanList.length > 0) {
          console.log("[DEBUG] Sample aturan:", aturanList[0]);
        }
      } catch {
        setAturanVaksin([]);
      }

      try {
        const resPencatatan = await getPencatatanByAnakId(id);
        const list = Array.isArray(resPencatatan) ? resPencatatan : [];
        setPencatatanList(list);
        console.log("[DEBUG] Pencatatan data:", list.length, "records");
        console.log(
          "[DEBUG] Pencatatan sample FULL:",
          JSON.stringify(list[0], null, 2),
        );
        if (list.length > 0) {
          console.log("[DEBUG] Bidan petugas:", list[0]?.bidan_petugas);
          console.log("[DEBUG] id_bidan_petugas:", list[0]?.id_bidan_petugas);
        }
      } catch {
        setPencatatanList([]);
        console.log("[DEBUG] Pencatatan fetch failed");
      }

      // Fetch jadwal layanan
      try {
        const resJadwalLayanan = await getJadwalLayananList();
        const jadwalLayananData = Array.isArray(resJadwalLayanan)
          ? resJadwalLayanan
          : [];
        setJadwalLayananList(jadwalLayananData);

        console.log("[DEBUG] All jadwal layanan:", jadwalLayananData);

        // Find today's schedule with better date parsing
        const today = new Date();
        today.setHours(0, 0, 0, 0); // Reset time to midnight
        const todayStr = today.toISOString().split("T")[0]; // YYYY-MM-DD format

        console.log("[DEBUG] Today date string:", todayStr);

        const todaySchedule = jadwalLayananData.find((jl) => {
          if (!jl.tanggal) {
            console.log("[DEBUG] Jadwal tanpa tanggal:", jl);
            return false;
          }

          // Parse schedule date - handle both ISO string and date-only format
          const scheduleDate = new Date(jl.tanggal);
          scheduleDate.setHours(0, 0, 0, 0); // Reset time
          const scheduleDateStr = scheduleDate.toISOString().split("T")[0];

          console.log("[DEBUG] Comparing:", {
            id: jl.id,
            layanan: jl.layanan,
            scheduleDateStr,
            todayStr,
            match: scheduleDateStr === todayStr,
            rawTanggal: jl.tanggal,
            dosisVaksinIds: jl.dosis_vaksin_ids,
          });

          return scheduleDateStr === todayStr;
        });

        setJadwalLayananToday(todaySchedule);
        console.log("[DEBUG] ✅ Jadwal layanan hari ini FOUND:", todaySchedule);

        if (todaySchedule) {
          console.log(
            "[DEBUG] Dosis vaksin IDs di jadwal:",
            todaySchedule.dosis_vaksin_ids,
          );
          console.log(
            "[DEBUG] Dosis vaksins detail:",
            todaySchedule.dosis_vaksins,
          );
        } else {
          console.log("[DEBUG] ❌ Tidak ada jadwal untuk hari ini");
        }
      } catch (err) {
        console.error("[DEBUG] Failed to fetch jadwal layanan:", err);
        setJadwalLayananList([]);
        setJadwalLayananToday(null);
      }
    } catch (err) {
      setError(err.message || "Gagal memuat data");
      setJadwalList([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (id) fetchData();
    else setError("ID Anak tidak ditemukan");
  }, [id]);

  // ─── HELPERS ───────────────────────────────────
  // Group jadwal by nama_dosis → each group = 1 table row (from API data)
  // Track firstId to preserve database ordering
  const groupedJadwal = React.useMemo(() => {
    const map = {};
    for (const j of jadwalList) {
      if (!j?.nama_dosis) continue;
      const key = j.nama_dosis;
      if (!map[key])
        map[key] = {
          items: [],
          done: null,
          dosisVaksinId: j.dosis_vaksin_id,
          firstId: j.jadwal_id,
        };
      map[key].items.push(j);
      if (j.status_id === 6) map[key].done = j;
      if (j.jadwal_id < map[key].firstId) map[key].firstId = j.jadwal_id;
    }
    return map;
  }, [jadwalList]);

  // Find aturan vaksin by dosis_vaksin_id
  const findAturanByDosisId = (dosisVaksinId) => {
    if (!dosisVaksinId || !aturanVaksin.length) return null;
    return (
      aturanVaksin.find((a) => a.dosis_vaksin_id === dosisVaksinId) || null
    );
  };

  // Calculate which month column a vaccine belongs to.
  // Maps to the nearest available MONTHS column (0-12, 18, 23, 23-59).
  const getJadwalBulan = (tanggalEstimasi, dosisVaksinId) => {
    const aturan = findAturanByDosisId(dosisVaksinId);
    if (
      aturan &&
      aturan.min_usia_hari !== undefined &&
      aturan.min_usia_hari !== null
    ) {
      const bulan = Math.floor(aturan.min_usia_hari / 30);
      // Map to nearest MONTHS column
      const monthCols = MONTHS.map(getMonthStart);
      let closest = monthCols[monthCols.length - 1];
      for (const col of monthCols) {
        if (col <= bulan) closest = col;
      }
      return closest;
    }
    // Fallback: date-based calculation
    if (!dataAnak?.tanggal_lahir || !tanggalEstimasi) return null;
    const lahir = new Date(dataAnak.tanggal_lahir);
    const estimasi = new Date(tanggalEstimasi);
    if (isNaN(lahir.getTime()) || isNaN(estimasi.getTime())) return null;
    const diff =
      (estimasi.getFullYear() - lahir.getFullYear()) * 12 +
      (estimasi.getMonth() - lahir.getMonth());
    const monthCols = MONTHS.map(getMonthStart);
    let closest = monthCols[monthCols.length - 1];
    for (const col of monthCols) {
      if (col <= diff) closest = col;
    }
    return closest;
  };

  // Find pencatatan record by jadwal_imunisasi_anak ID
  const findPencatatanByJadwalId = (jadwalId) => {
    if (!jadwalId || !pencatatanList.length) return null;
    const target = Number(jadwalId);
    return (
      pencatatanList.find(
        (p) => Number(p.id_jadwal_imunisasi_anak) === target && p.is_selesai,
      ) || null
    );
  };

  // Get cell content for each month column
  const getCellContent = (group, monthValue) => {
    const doneItem = group.done;
    if (doneItem) {
      const doneBulan = getJadwalBulan(
        doneItem.tanggal_estimasi,
        group.dosisVaksinId,
      );
      const monthStart = getMonthStart(monthValue);

      // Look up pencatatan_imunisasi for the actual tanggal_pemberian
      const pencatatan = findPencatatanByJadwalId(doneItem.jadwal_id);
      const displayDate =
        pencatatan?.tanggal_pemberian || doneItem.tanggal_estimasi;

      // Range column like '23-59'
      if (typeof monthValue === "string" && monthValue.includes("-")) {
        const [, endStr] = monthValue.split("-");
        const monthEnd = parseInt(endStr);
        if (doneBulan >= monthStart && doneBulan <= monthEnd) {
          return { show: "done", date: formatTanggal(displayDate) };
        }
      } else {
        if (doneBulan === monthStart) {
          return { show: "done", date: formatTanggal(displayDate) };
        }
      }
    }
    return { show: "empty" };
  };

  // Pola warna untuk setiap vaksin sesuai Buku KIA 2024
  // Berdasarkan gambar DETAIL yang diberikan user - PERSIS seperti buku KIA
  const getVaccineColorPattern = (namaDosis) => {
    // Normalisasi nama vaksin
    const vaksinName = namaDosis?.toLowerCase() || "";
    
    // Format: { bulan: warna } dimana warna: 'gray' | 'white' | 'orange' | 'pink'
    
    // ========== VAKSIN 1: Hepatitis B (<24 Jam) / HB-0 ==========
    // Gambar 1: Putih di 0, abu-abu sisanya
    if (vaksinName.includes("hb") && (vaksinName.includes("0") || vaksinName.includes("24"))) {
      return {
        0: "white",
        1: "gray", 2: "gray", 3: "gray", 4: "gray", 5: "gray", 
        6: "gray", 7: "gray", 8: "gray", 9: "gray", 10: "gray",
        11: "gray", 12: "gray", 18: "gray", 23: "gray", "23-59": "gray"
      };
    }
    
    // ========== VAKSIN 2: BCG ==========
    // Abu 0, putih 1, orange 2-11, abu 12+
    if (vaksinName.includes("bcg")) {
      return {
        0: "gray",
        1: "white",
        2: "orange", 3: "orange", 4: "orange", 5: "orange", 6: "orange",
        7: "orange", 8: "orange", 9: "orange", 10: "orange", 11: "orange",
        12: "gray", 18: "gray", 23: "gray", "23-59": "gray"
      };
    }
    
    // ========== VAKSIN 3: Polio tetes OPV-1 ==========
    // Abu 0, putih 1, orange 2-11, pink 12+
    if ((vaksinName.includes("polio") || vaksinName.includes("opv")) && vaksinName.includes("1")) {
      return {
        0: "gray",
        1: "white",
        2: "orange", 3: "orange", 4: "orange", 5: "orange", 6: "orange",
        7: "orange", 8: "orange", 9: "orange", 10: "orange", 11: "orange",
        12: "pink", 18: "pink", 23: "pink", "23-59": "pink"
      };
    }
    
    // ========== VAKSIN 4: DPT-HB-Hib-1 ==========
    // Abu 0-1, putih 2, orange 3-11, pink 12+
    if (vaksinName.includes("dpt") && vaksinName.includes("hib") && vaksinName.includes("1")) {
      return {
        0: "gray", 1: "gray",
        2: "white",
        3: "orange", 4: "orange", 5: "orange", 6: "orange", 7: "orange",
        8: "orange", 9: "orange", 10: "orange", 11: "orange",
        12: "pink", 18: "pink", 23: "pink", "23-59": "pink"
      };
    }
    
    // ========== VAKSIN 5: Polio Tetes OPV-2 ==========
    // Sama seperti DPT-HB-Hib-1
    if ((vaksinName.includes("polio") || vaksinName.includes("opv")) && vaksinName.includes("2")) {
      return {
        0: "gray", 1: "gray",
        2: "white",
        3: "orange", 4: "orange", 5: "orange", 6: "orange", 7: "orange",
        8: "orange", 9: "orange", 10: "orange", 11: "orange",
        12: "pink", 18: "pink", 23: "pink", "23-59": "pink"
      };
    }
    
    // ========== VAKSIN 6: DPT-HB-Hib-2 ==========
    // Abu 0-2, putih 3, orange 4-11, pink 12+
    if (vaksinName.includes("dpt") && vaksinName.includes("hib") && vaksinName.includes("2")) {
      return {
        0: "gray", 1: "gray", 2: "gray",
        3: "white",
        4: "orange", 5: "orange", 6: "orange", 7: "orange", 8: "orange",
        9: "orange", 10: "orange", 11: "orange",
        12: "pink", 18: "pink", 23: "pink", "23-59": "pink"
      };
    }
    
    // ========== VAKSIN 7: Polio Tetes OPV-3 ==========
    // Sama seperti DPT-HB-Hib-2
    if ((vaksinName.includes("polio") || vaksinName.includes("opv")) && vaksinName.includes("3")) {
      return {
        0: "gray", 1: "gray", 2: "gray",
        3: "white",
        4: "orange", 5: "orange", 6: "orange", 7: "orange", 8: "orange",
        9: "orange", 10: "orange", 11: "orange",
        12: "pink", 18: "pink", 23: "pink", "23-59": "pink"
      };
    }
    
    // ========== VAKSIN 8: DPT-HB-Hib-3 ==========
    // Abu 0-3, putih 4, orange 5-11, pink 12+
    if (vaksinName.includes("dpt") && vaksinName.includes("hib") && vaksinName.includes("3")) {
      return {
        0: "gray", 1: "gray", 2: "gray", 3: "gray",
        4: "white",
        5: "orange", 6: "orange", 7: "orange", 8: "orange", 9: "orange",
        10: "orange", 11: "orange",
        12: "pink", 18: "pink", 23: "pink", "23-59": "pink"
      };
    }
    
    // ========== VAKSIN 9: Polio Tetes OPV-4 ==========
    // Sama seperti DPT-HB-Hib-3
    if ((vaksinName.includes("polio") || vaksinName.includes("opv")) && vaksinName.includes("4")) {
      return {
        0: "gray", 1: "gray", 2: "gray", 3: "gray",
        4: "white",
        5: "orange", 6: "orange", 7: "orange", 8: "orange", 9: "orange",
        10: "orange", 11: "orange",
        12: "pink", 18: "pink", 23: "pink", "23-59": "pink"
      };
    }
    
    // ========== VAKSIN 10: Polio Suntik (IPV) ==========
    // Abu 0-3, putih 4, orange 5-11, pink 12+
    if (vaksinName.includes("ipv") || (vaksinName.includes("polio") && vaksinName.includes("suntik"))) {
      return {
        0: "gray", 1: "gray", 2: "gray", 3: "gray",
        4: "white",
        5: "orange", 6: "orange", 7: "orange", 8: "orange", 9: "orange",
        10: "orange", 11: "orange",
        12: "pink", 18: "pink", 23: "pink", "23-59": "pink"
      };
    }
    
    // ========== VAKSIN 11: MR / Campak-Rubella ==========
    // Abu 0-8, putih 9, orange 10-11, pink 12+
    if ((vaksinName.includes("mr") || vaksinName.includes("campak") || vaksinName.includes("rubella")) 
        && !vaksinName.includes("booster") && !vaksinName.includes("lanjutan")) {
      return {
        0: "gray", 1: "gray", 2: "gray", 3: "gray", 4: "gray", 5: "gray",
        6: "gray", 7: "gray", 8: "gray",
        9: "white",
        10: "orange", 11: "orange",
        12: "pink", 18: "pink", 23: "pink", "23-59": "pink"
      };
    }
    
    // ========== VAKSIN 12: DPT-HB-Hib Booster / Lanjutan ==========
    // Gambar 8: Abu 0-17, putih 18, orange 23, pink 23-59
    if ((vaksinName.includes("booster") || vaksinName.includes("lanjutan")) 
        && (vaksinName.includes("dpt") || vaksinName.includes("hib"))) {
      return {
        0: "gray", 1: "gray", 2: "gray", 3: "gray", 4: "gray", 5: "gray",
        6: "gray", 7: "gray", 8: "gray", 9: "gray", 10: "gray", 11: "gray",
        12: "gray",
        18: "white",
        23: "orange", "23-59": "pink"
      };
    }
    
    // ========== VAKSIN 13: Campak-Rubella (MR) Booster / Lanjutan ==========
    // Gambar 8: Abu 0-17, putih 18, orange 23, pink 23-59
    if ((vaksinName.includes("booster") || vaksinName.includes("lanjutan")) 
        && (vaksinName.includes("mr") || vaksinName.includes("campak") || vaksinName.includes("rubella"))) {
      return {
        0: "gray", 1: "gray", 2: "gray", 3: "gray", 4: "gray", 5: "gray",
        6: "gray", 7: "gray", 8: "gray", 9: "gray", 10: "gray", 11: "gray",
        12: "gray",
        18: "white",
        23: "orange", "23-59": "pink"
      };
    }
    
    // Default: semua abu-abu (jika vaksin tidak dikenali)
    return {
      0: "gray", 1: "gray", 2: "gray", 3: "gray", 4: "gray", 5: "gray",
      6: "gray", 7: "gray", 8: "gray", 9: "gray", 10: "gray", 11: "gray",
      12: "gray", 18: "gray", 23: "gray", "23-59": "gray"
    };
  };

  // Get cell color based on vaccine pattern from KIA 2024
  const getCellColor = (namaDosis, monthValue, doneBulan) => {
    // Completed dose → green
    if (doneBulan !== null) {
      const monthStart = getMonthStart(monthValue);
      const monthEnd =
        typeof monthValue === "string" && monthValue.includes("-")
          ? parseInt(monthValue.split("-")[1])
          : monthStart;
      
      if (doneBulan >= monthStart && doneBulan <= monthEnd) {
        return { className: "bg-green-100 border-green-300", style: null };
      }
    }

    // Get color pattern for this vaccine
    const pattern = getVaccineColorPattern(namaDosis);
    const monthKey = String(monthValue);
    const colorType = pattern[monthKey] || "gray";

    // Return appropriate color
    switch (colorType) {
      case "white":
        return { className: "bg-white border-gray-400", style: null };
      case "orange":
        return {
          className: "",
          style: { backgroundColor: "#FED7AA", borderColor: "#FB923C" },
        };
      case "pink":
        return {
          className: "",
          style: { backgroundColor: "#FBCFE8", borderColor: "#EC4899" },
        };
      case "gray":
      default:
        return {
          className: "",
          style: { backgroundColor: "#D3D3D3", borderColor: "#A9A9A9" },
        };
    }
  };

  const formatTanggal = (dateString) => {
    if (!dateString) return "-";
    const d = new Date(dateString);
    if (isNaN(d.getTime()) || d.getFullYear() < 1900) return "-";
    return d.toLocaleDateString("id-ID", {
      day: "2-digit",
      month: "2-digit",
      year: "2-digit",
    });
  };

  // All unfinished jadwal for modal
  const jadwalBelumSelesai = jadwalList.filter((j) => j.status_id !== 6);

  // All available (unfinished) jadwal for the modal — no longer filtered by jadwal layanan
  const allAvailableJadwal = React.useMemo(() => {
    return jadwalList.filter((j) => j.status_id !== 6);
  }, [jadwalList]);

  // Legacy: filter jadwal based on selected jadwal layanan (kept for reference)
  const availableJadwalToday = React.useMemo(() => {
    if (!jadwalLayananToday) return allAvailableJadwal;

    let allowedDosisIds = [];
    if (
      jadwalLayananToday.dosis_vaksins &&
      Array.isArray(jadwalLayananToday.dosis_vaksins)
    ) {
      allowedDosisIds = jadwalLayananToday.dosis_vaksins.map((dv) => dv.id);
    } else if (
      jadwalLayananToday.DosisVaksins &&
      Array.isArray(jadwalLayananToday.DosisVaksins)
    ) {
      allowedDosisIds = jadwalLayananToday.DosisVaksins.map((dv) => dv.id);
    }

    if (allowedDosisIds.length === 0) return allAvailableJadwal;

    const filtered = jadwalList.filter(
      (j) => j.status_id !== 6 && allowedDosisIds.includes(j.dosis_vaksin_id),
    );
    return filtered.length > 0 ? filtered : allAvailableJadwal;
  }, [jadwalLayananToday, jadwalList, allAvailableJadwal]);

  // Calculate child's current age in days
  const getUmurAnakHariIni = () => {
    if (!dataAnak?.tanggal_lahir) return null;
    const lahir = new Date(dataAnak.tanggal_lahir);
    const sekarang = new Date();
    const diffMs = sekarang - lahir;
    const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));
    return diffDays;
  };

  // Check if child's age is appropriate for this vaccine dose
  const isUsiaCukup = (dosisVaksinId) => {
    const umurHari = getUmurAnakHariIni();
    if (umurHari === null) return false;

    const aturan = findAturanByDosisId(dosisVaksinId);
    if (!aturan || aturan.min_usia_hari == null) return true; // no age restriction

    // Child must be at least min_usia_hari old
    return umurHari >= aturan.min_usia_hari;
  };

  // Check if child's age is beyond max allowed age for this vaccine
  const isUsiaTerlambat = (dosisVaksinId) => {
    const umurHari = getUmurAnakHariIni();
    if (umurHari === null) return false;

    const aturan = findAturanByDosisId(dosisVaksinId);
    if (!aturan || !aturan.max_usia_hari) return false; // no max age limit

    return umurHari > aturan.max_usia_hari;
  };

  // Check if a jadwal item's prerequisite dose has been completed
  const isPreviousDoseComplete = (dosisVaksinId) => {
    if (!aturanVaksin.length || !dosisVaksinId) return true; // no aturan = no restriction
    const aturan = aturanVaksin.find(
      (a) => a.dosis_vaksin_id === dosisVaksinId,
    );
    if (!aturan || !aturan.dosis_sebelum_id) return true; // no prerequisite
    // Check if the required previous dose is completed in jadwalList
    return jadwalList.some(
      (j) => j.dosis_vaksin_id === aturan.dosis_sebelum_id && j.status_id === 6,
    );
  };

  // Get prerequisite dose name for display
  const getPreviousDoseName = (dosisVaksinId) => {
    if (!aturanVaksin.length || !dosisVaksinId) return "";
    const aturan = aturanVaksin.find(
      (a) => a.dosis_vaksin_id === dosisVaksinId,
    );
    if (!aturan || !aturan.dosis_sebelum_id) return "";
    const prevAturan = aturanVaksin.find(
      (a) => a.dosis_vaksin_id === aturan.dosis_sebelum_id,
    );
    if (prevAturan?.dosis_vaksin) return prevAturan.dosis_vaksin.nama_dosis;
    // Fallback: find name from jadwalList
    const prevJadwal = jadwalList.find(
      (j) => j.dosis_vaksin_id === aturan.dosis_sebelum_id,
    );
    return prevJadwal?.nama_dosis || `Dosis ID ${aturan.dosis_sebelum_id}`;
  };

  // Cancel paraf handler
  const handleBatalParaf = async (jadwalId, namaDosis) => {
    const result = await Swal.fire({
      icon: "warning",
      title: "Batalkan Paraf?",
      html: `Apakah Anda yakin ingin membatalkan paraf <b>${namaDosis}</b>?<br/><small class="text-gray-500">Data pencatatan akan dihapus dan jadwal akan dikembalikan ke status belum selesai.</small>`,
      showCancelButton: true,
      confirmButtonText: "Ya, Batalkan",
      cancelButtonText: "Tidak",
      confirmButtonColor: "#ef4444",
      cancelButtonColor: "#6b7280",
      reverseButtons: true,
    });

    if (!result.isConfirmed) return;

    try {
      await batalParafImunisasi(jadwalId);
      await fetchData();
      setRefreshKey((prev) => prev + 1);
      Swal.fire({
        icon: "success",
        title: "Berhasil!",
        text: `Paraf ${namaDosis} berhasil dibatalkan.`,
        confirmButtonColor: "#10b981",
        timer: 3000,
        timerProgressBar: true,
      });
    } catch (err) {
      Swal.fire({
        icon: "error",
        title: "Gagal Membatalkan",
        text:
          err.response?.data?.message?.join(", ") ||
          err.message ||
          "Terjadi kesalahan",
        confirmButtonColor: "#ef4444",
      });
    }
  };

  // ─── MODAL HANDLERS ────────────────────────────
  const handleToggleJadwal = (jadwalId) => {
    setFormData((prev) => ({
      ...prev,
      selectedJadwalIds: prev.selectedJadwalIds.includes(jadwalId)
        ? prev.selectedJadwalIds.filter((x) => x !== jadwalId)
        : [...prev.selectedJadwalIds, jadwalId],
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (formData.selectedJadwalIds.length === 0) {
      Swal.fire({
        icon: "warning",
        title: "Peringatan",
        text: "Pilih minimal 1 vaksin!",
        confirmButtonColor: "#2563eb",
      });
      return;
    }

    // Konfirmasi sebelum menyimpan paraf
    const selectedVaccineNames = formData.selectedJadwalIds
      .map((id) => {
        const jadwal = jadwalList.find((j) => j.jadwal_id === id);
        return jadwal?.nama_dosis;
      })
      .filter(Boolean);

    const result = await Swal.fire({
      icon: "question",
      title: "Konfirmasi Paraf Imunisasi",
      html: `
        <div class="text-left">
          <p class="mb-3 text-gray-700">Apakah Anda yakin vaksin berikut <b>sudah diberikan</b> kepada anak?</p>
          <div class="bg-blue-50 border-l-4 border-blue-500 p-3 rounded mb-3">
            <ul class="list-disc list-inside space-y-1">
              ${selectedVaccineNames.map((name) => `<li class="font-semibold text-blue-900">${name}</li>`).join("")}
            </ul>
          </div>
          <p class="text-sm text-gray-600 mt-2">
            <span class="text-amber-600 font-semibold">⚠️ Peringatan:</span> Paraf akan disimpan dan data akan tercatat dalam sistem.
          </p>
        </div>
      `,
      showCancelButton: true,
      confirmButtonText: "✓ Ya, Sudah Vaksin",
      cancelButtonText: "✕ Belum",
      confirmButtonColor: "#10b981",
      cancelButtonColor: "#6b7280",
      reverseButtons: true,
      width: "500px",
    });

    if (!result.isConfirmed) return;

    try {
      setIsSubmitting(true);
      for (const jadwalId of formData.selectedJadwalIds) {
        const jadwal = jadwalList.find((j) => j.jadwal_id === jadwalId);
        if (!jadwal) continue;

        // 1. Create pencatatan imunisasi record (new table)
        let pencatatanId = null;
        try {
          const result = await createPelayananImunisasi({
            id_jadwal_imunisasi_anak: jadwalId,
            tanggal_pemberian: formData.tanggal,
            nomor_batch: formData.batches[jadwalId] || "",
            catatan: formData.catatan || "",
          });
          pencatatanId = result?.id;
        } catch (err) {
          console.error("Gagal simpan pencatatan:", err.message);
        }

        // 2. Mark pencatatan as selesai (new table)
        if (pencatatanId) {
          try {
            await setPencatatanSelesai(pencatatanId);
          } catch (err) {
            console.error("Gagal set pencatatan selesai:", err.message);
          }
        }

        // 3. Mark jadwal as selesai (existing endpoint)
        await setJadwalSelesai(jadwalId);
      }

      setIsModalOpen(false);
      setFormData({
        selectedJadwalIds: [],
        batches: {},
        catatan: "",
        tanggal: new Date().toISOString().split("T")[0],
      });
      await fetchData();
      setRefreshKey((prev) => prev + 1);
      Swal.fire({
        icon: "success",
        title: "Berhasil!",
        text: `Berhasil menyimpan ${formData.selectedJadwalIds.length} paraf imunisasi!`,
        confirmButtonColor: "#10b981",
        timer: 3000,
        timerProgressBar: true,
      });
    } catch (err) {
      Swal.fire({
        icon: "error",
        title: "Gagal Menyimpan",
        text: err.message || "Terjadi kesalahan saat menyimpan data",
        confirmButtonColor: "#ef4444",
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  // ─── LOADING ───────────────────────────────────
  if (loading) {
    return (
      <MainLayout>
        <div className="flex items-center justify-center min-h-screen">
          <div className="flex flex-col items-center gap-3">
            <RefreshCw size={36} className="animate-spin text-blue-600" />
            <p className="text-sm text-gray-500 font-medium">
              Memuat data imunisasi...
            </p>
          </div>
        </div>
      </MainLayout>
    );
  }

  // ─── ERROR ─────────────────────────────────────
  if (error) {
    return (
      <MainLayout>
        <div className="flex items-center justify-center min-h-screen">
          <div className="text-center">
            <AlertTriangle size={48} className="mx-auto text-red-400 mb-4" />
            <p className="text-red-600 font-medium">{error}</p>
            <button
              onClick={fetchData}
              className="mt-4 text-blue-600 underline text-sm"
            >
              Coba lagi
            </button>
          </div>
        </div>
      </MainLayout>
    );
  }

  // ─── RENDER ────────────────────────────────────
  return (
    <MainLayout>
      <div className="p-3 sm:p-4 md:p-6 bg-gray-50 min-h-screen">
        <div className="max-w-7xl mx-auto">
          {/* ═══════════ HEADER ═══════════ */}
          <div className="mb-4">
            <Link
              to={`/data-anak/dashboard/${id}`}
              className="inline-flex items-center gap-2 text-gray-500 hover:text-blue-600 text-sm mb-3 transition-colors"
            >
              <ArrowLeft size={16} /> Kembali
            </Link>

            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
              <div className="space-y-0.5">
                {dataAnak && (
                  <>
                    <p className="text-gray-700 font-semibold text-sm sm:text-base">
                      {dataAnak.nama_anak}
                    </p>
                    <p className="text-gray-500 text-xs sm:text-sm">
                      Lahir {formatTanggal(dataAnak.tanggal_lahir)}
                    </p>
                    {(() => {
                      const umurHari = getUmurAnakHariIni();
                      if (umurHari !== null) {
                        const umurBulan = Math.floor(umurHari / 30);
                        const sisaHari = umurHari % 30;
                        return (
                          <p className="text-blue-600 text-xs sm:text-sm font-semibold">
                            Umur saat ini: {umurBulan} bulan {sisaHari} hari
                          </p>
                        );
                      }
                      return null;
                    })()}
                  </>
                )}
              </div>

              <button
                onClick={() => {
                  if (allAvailableJadwal.length === 0) {
                    Swal.fire({
                      icon: "info",
                      title: "Tidak Ada Vaksin yang Tersedia",
                      html: "Semua vaksin sudah selesai diparaf untuk anak ini.",
                      confirmButtonColor: "#2563eb",
                    });
                    return;
                  }
                  setIsModalOpen(true);
                }}
                disabled={allAvailableJadwal.length === 0}
                className="flex items-center justify-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2.5 rounded-xl font-bold text-sm shadow-md transition-all active:scale-95 disabled:bg-gray-300 disabled:cursor-not-allowed w-full sm:w-auto"
              >
                <Syringe size={16} /> PARAF IMUNISASI
              </button>
            </div>
          </div>

          {/* Hint scroll — hanya tampil di mobile */}
          <p className="hidden max-[640px]:flex text-xs text-gray-400 text-center mb-2 items-center justify-center gap-1">
            <span>←</span> Geser untuk melihat semua kolom <span>→</span>
          </p>

          {/* ═══════════ TABEL IMUNISASI KIA ═══════════ */}
          <div
            key={refreshKey}
            className="bg-white shadow-xl border border-gray-300 rounded overflow-hidden mb-4"
          >
            <div
              className="overflow-x-auto"
              tabIndex={0}
              role="region"
              aria-label="Tabel jadwal imunisasi anak"
            >
              <table
                className="w-full border-collapse text-[11px]"
                style={{ minWidth: "680px" }}
              >
                <thead>
                  {/* Row 1: Jenis Vaksin | Bulan */}
                  <tr className="bg-gray-800 text-white">
                    <th
                      rowSpan={2}
                      className="border border-gray-500 p-2 text-center font-bold text-[11px] uppercase sticky left-0 bg-gray-800 z-10"
                      style={{ width: "160px", minWidth: "120px" }}
                    >
                      Jenis Vaksin
                    </th>
                    <th
                      colSpan={MONTHS.length}
                      className="border border-gray-500 p-1.5 text-center font-bold text-[11px] uppercase tracking-wider"
                    >
                      Bulan
                    </th>
                  </tr>
                  {/* Row 2: Month numbers (0, 1, 2, ..., 23-59) */}
                  <tr className="bg-gray-700 text-white">
                    {MONTHS.map((m, i) => (
                      <th
                        key={i}
                        className="border border-gray-500 p-1 text-center font-bold text-[9px]"
                        style={{ width: `${Math.floor(100 / MONTHS.length)}%` }}
                      >
                        {m}
                      </th>
                    ))}
                  </tr>
                  {/* Row 3: Umur | Tanggal Pemberian dan Paraf Petugas */}
                  <tr className="bg-gray-200 text-gray-800">
                    <th className="border border-gray-500 p-2 text-center font-bold text-[11px] uppercase sticky left-0 bg-gray-200 z-10">
                      Umur
                    </th>
                    <th
                      colSpan={MONTHS.length}
                      className="border border-gray-500 p-2 text-center font-bold text-[11px] uppercase"
                    >
                      Tanggal Pemberian dan Paraf Petugas
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {Object.entries(groupedJadwal)
                    .sort(([, a], [, b]) => (a.firstId || 0) - (b.firstId || 0))
                    .map(([namaDosis, group], vIdx) => {
                      const doneItem = group.done;
                      const dosisVaksinId = group.dosisVaksinId;
                      const doneBulan = doneItem
                        ? getJadwalBulan(
                            doneItem.tanggal_estimasi,
                            dosisVaksinId,
                          )
                        : null;

                      return (
                        <tr
                          key={namaDosis}
                          className={`hover:bg-blue-50 transition-colors ${
                            vIdx % 2 === 0 ? "bg-white" : "bg-gray-50/50"
                          }`}
                        >
                          {/* Vaccine Name Cell - sticky left so it stays visible on mobile scroll */}
                          <td
                            className={`border border-gray-300 p-2 font-semibold text-gray-700 text-[10px] leading-tight sticky left-0 z-10 ${
                              vIdx % 2 === 0 ? "bg-white" : "bg-gray-50"
                            }`}
                          >
                            <span>{namaDosis}</span>
                          </td>

                          {/* Month Cells */}
                          {MONTHS.map((m, mIdx) => {
                            const monthValue = m;
                            const { className: colorClass, style: colorStyle } =
                              getCellColor(namaDosis, monthValue, doneBulan);
                            const cell = getCellContent(group, monthValue);

                            return (
                              <td
                                key={mIdx}
                                className={`border border-gray-300 text-center p-0 overflow-hidden ${colorClass}`}
                                style={colorStyle}
                              >
                                {cell.show === "done" ? (
                                  <div className="flex flex-col items-center justify-center py-0.5 px-0.5 w-full">
                                    <span className="text-green-700 font-bold text-xs leading-none">
                                      ✓
                                    </span>
                                    <span className="text-green-600 font-medium text-[7px] leading-none mt-0.5 truncate w-full text-center">
                                      {cell.date}
                                    </span>
                                  </div>
                                ) : null}
                              </td>
                            );
                          })}
                        </tr>
                      );
                    })}
                </tbody>
              </table>
            </div>
          </div>

          {/* ═══════════ LEGENDA WARNA ═══════════ */}
          <div className="bg-white p-4 rounded-xl border border-gray-200 shadow-sm mb-6">
            <h3 className="text-sm font-bold text-gray-800 mb-3 flex items-center gap-2">
              <span className="w-1 h-4 bg-blue-600 rounded"></span>
              Keterangan Warna Usia Pemberian Imunisasi
            </h3>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-3 text-xs">
              <div className="flex items-center gap-2.5">
                <div className="w-8 h-6 bg-white border-2 border-gray-400 rounded flex-shrink-0 shadow-sm" />
                <span className="text-gray-700 font-medium">
                  Usia Tepat Pemberian Imunisasi
                </span>
              </div>

              <div className="flex items-center gap-2.5">
                <div
                  className="w-8 h-6 rounded flex-shrink-0 border-2 shadow-sm"
                  style={{ backgroundColor: "#FED7AA", borderColor: "#FB923C" }}
                />
                <span className="text-gray-700 font-medium">
                  Usia yang masih diperbolehkan untuk melengkapi Imunisasi Bayi dan Baduta (Bawah Dua Tahun)
                </span>
              </div>

              <div className="flex items-center gap-2.5">
                <div
                  className="w-8 h-6 rounded flex-shrink-0 border-2 shadow-sm"
                  style={{ backgroundColor: "#FBCFE8", borderColor: "#EC4899" }}
                />
                <span className="text-gray-700 font-medium">
                  Usia Pemberian Imunisasi bayi dan baduta yang belum lengkap (Imunisasi Kejar)
                </span>
              </div>

              <div className="flex items-center gap-2.5">
                <div
                  className="w-8 h-6 rounded flex-shrink-0 border-2 shadow-sm"
                  style={{ backgroundColor: "#D3D3D3", borderColor: "#A9A9A9" }}
                />
                <span className="text-gray-700 font-medium">
                  Usia yang tidak diperbolehkan untuk pemberian Imunisasi
                </span>
              </div>

              <div className="flex items-center gap-2.5">
                <div className="w-8 h-6 bg-green-100 border-2 border-green-300 rounded flex items-center justify-center flex-shrink-0 shadow-sm">
                  <span className="text-green-700 font-bold text-xs">✓</span>
                </div>
                <span className="text-gray-700 font-medium">
                  Imunisasi telah diberikan
                </span>
              </div>
            </div>
          </div>

          {/* ═══════════ TABEL CATATAN IMUNISASI ═══════════ */}
          {pencatatanList.filter((p) => p.is_selesai).length > 0 && (
            <div className="bg-white shadow-xl border border-gray-300 rounded-xl overflow-hidden">
              <div className="bg-gradient-to-r from-blue-600 to-blue-700 p-4 border-b border-blue-800">
                <h2 className="text-white font-bold text-lg flex items-center gap-2">
                  <Syringe size={20} />
                  Riwayat Catatan Imunisasi
                </h2>
                <p className="text-blue-100 text-xs mt-1">
                  Riwayat pemberian imunisasi yang telah dilakukan
                </p>
              </div>

              {/* Desktop table */}
              <div
                className="hidden sm:block overflow-x-auto"
                tabIndex={0}
                role="region"
                aria-label="Tabel paraf imunisasi anak"
              >
                <table className="w-full">
                  <thead>
                    <tr className="bg-gray-100 border-b border-gray-300">
                      <th className="px-4 py-3 text-left text-xs font-bold text-gray-700 uppercase tracking-wider">
                        No
                      </th>
                      <th className="px-4 py-3 text-left text-xs font-bold text-gray-700 uppercase tracking-wider">
                        Jenis Vaksin
                      </th>
                      <th className="px-4 py-3 text-left text-xs font-bold text-gray-700 uppercase tracking-wider">
                        Tanggal Pemberian
                      </th>
                      <th className="px-4 py-3 text-left text-xs font-bold text-gray-700 uppercase tracking-wider">
                        No. Batch
                      </th>
                      <th className="px-4 py-3 text-left text-xs font-bold text-gray-700 uppercase tracking-wider">
                        Nama Bidan/Petugas
                      </th>
                      <th className="px-4 py-3 text-left text-xs font-bold text-gray-700 uppercase tracking-wider">
                        Catatan
                      </th>
                      <th className="px-4 py-3 text-center text-xs font-bold text-gray-700 uppercase tracking-wider">
                        Aksi
                      </th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-200">
                    {pencatatanList
                      .filter((p) => p.is_selesai)
                      .sort(
                        (a, b) =>
                          new Date(a.tanggal_pemberian) -
                          new Date(b.tanggal_pemberian),
                      )
                      .map((pencatatan, index) => {
                        const namaDosis =
                          pencatatan.jadwal_imunisasi_anak?.dosis_vaksin
                            ?.nama_dosis || "-";
                        const namaBidan =
                          pencatatan.bidan_petugas?.name || "Tidak tersedia";
                        return (
                          <tr
                            key={pencatatan.id}
                            className="hover:bg-blue-50 transition-colors"
                          >
                            <td className="px-4 py-3 text-sm text-gray-700 font-medium">
                              {index + 1}
                            </td>
                            <td className="px-4 py-3 text-sm text-gray-900 font-semibold">
                              {namaDosis}
                            </td>
                            <td className="px-4 py-3 text-sm text-gray-700">
                              {formatTanggal(pencatatan.tanggal_pemberian)}
                            </td>
                            <td className="px-4 py-3 text-sm text-gray-700">
                              {pencatatan.nomor_batch || "-"}
                            </td>
                            <td className="px-4 py-3 text-sm text-gray-900">
                              <div className="flex items-center gap-2">
                                <div className="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center flex-shrink-0">
                                  <span className="text-blue-700 font-bold text-xs">
                                    {namaBidan.charAt(0).toUpperCase()}
                                  </span>
                                </div>
                                <span className="font-medium">{namaBidan}</span>
                              </div>
                            </td>
                            <td className="px-4 py-3 text-sm text-gray-600">
                              {pencatatan.catatan || "-"}
                            </td>
                            <td className="px-4 py-3 text-center">
                              <button
                                onClick={() =>
                                  handleBatalParaf(
                                    pencatatan.id_jadwal_imunisasi_anak,
                                    namaDosis,
                                  )
                                }
                                className="inline-flex items-center gap-1.5 bg-red-50 hover:bg-red-100 text-red-600 hover:text-red-700 border border-red-200 hover:border-red-300 px-3 py-1.5 rounded-lg text-xs font-semibold transition-all active:scale-95"
                                title="Batalkan paraf imunisasi"
                              >
                                <XCircle size={14} />
                                <span>Batalkan Paraf</span>
                              </button>
                            </td>
                          </tr>
                        );
                      })}
                  </tbody>
                </table>
              </div>

              {/* Mobile cards */}
              <div className="sm:hidden divide-y divide-gray-200">
                {pencatatanList
                  .filter((p) => p.is_selesai)
                  .sort(
                    (a, b) =>
                      new Date(a.tanggal_pemberian) -
                      new Date(b.tanggal_pemberian),
                  )
                  .map((pencatatan, index) => {
                    const namaDosis =
                      pencatatan.jadwal_imunisasi_anak?.dosis_vaksin
                        ?.nama_dosis || "-";
                    const namaBidan =
                      pencatatan.bidan_petugas?.name || "Tidak tersedia";
                    return (
                      <div key={pencatatan.id} className="p-4 space-y-3">
                        <div className="flex items-start justify-between gap-2">
                          <div className="flex items-center gap-2">
                            <span className="w-6 h-6 rounded-full bg-blue-600 text-white text-xs font-bold flex items-center justify-center flex-shrink-0">
                              {index + 1}
                            </span>
                            <span className="font-bold text-sm text-gray-900">
                              {namaDosis}
                            </span>
                          </div>
                          <span className="text-xs text-gray-500 font-medium whitespace-nowrap">
                            {formatTanggal(pencatatan.tanggal_pemberian)}
                          </span>
                        </div>

                        <div className="grid grid-cols-2 gap-2 text-xs">
                          <div>
                            <span className="text-gray-400 font-semibold uppercase tracking-wide text-[10px]">
                              No. Batch
                            </span>
                            <p className="text-gray-700 mt-0.5">
                              {pencatatan.nomor_batch || "-"}
                            </p>
                          </div>
                          <div>
                            <span className="text-gray-400 font-semibold uppercase tracking-wide text-[10px]">
                              Petugas
                            </span>
                            <div className="flex items-center gap-1.5 mt-0.5">
                              <div className="w-5 h-5 rounded-full bg-blue-100 flex items-center justify-center flex-shrink-0">
                                <span className="text-blue-700 font-bold text-[10px]">
                                  {namaBidan.charAt(0).toUpperCase()}
                                </span>
                              </div>
                              <span className="text-gray-700 truncate">
                                {namaBidan}
                              </span>
                            </div>
                          </div>
                          {pencatatan.catatan && (
                            <div className="col-span-2">
                              <span className="text-gray-400 font-semibold uppercase tracking-wide text-[10px]">
                                Catatan
                              </span>
                              <p className="text-gray-600 mt-0.5">
                                {pencatatan.catatan}
                              </p>
                            </div>
                          )}
                        </div>

                        <button
                          onClick={() =>
                            handleBatalParaf(
                              pencatatan.id_jadwal_imunisasi_anak,
                              namaDosis,
                            )
                          }
                          className="w-full inline-flex items-center justify-center gap-1.5 bg-red-50 hover:bg-red-100 text-red-600 border border-red-200 px-3 py-2 rounded-lg text-xs font-semibold transition-all active:scale-95"
                        >
                          <XCircle size={14} />
                          Batalkan Paraf
                        </button>
                      </div>
                    );
                  })}
              </div>

              {pencatatanList.filter((p) => p.is_selesai).length === 0 && (
                <div className="p-8 text-center text-gray-500">
                  <Syringe size={48} className="mx-auto mb-3 text-gray-300" />
                  <p className="font-medium">Belum ada catatan imunisasi</p>
                  <p className="text-xs mt-1">
                    Catatan akan muncul setelah melakukan paraf imunisasi
                  </p>
                </div>
              )}
            </div>
          )}
        </div>
      </div>

      {/* ═══════════ MODAL PARAF IMUNISASI ═══════════ */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/60 backdrop-blur-sm sm:p-4">
          <div className="bg-white rounded-t-2xl sm:rounded-2xl w-full sm:max-w-lg max-h-[92vh] sm:max-h-[85vh] overflow-hidden shadow-2xl border-t-4 border-blue-600 flex flex-col">
            {/* Modal Header */}
            <div className="bg-gray-800 px-4 py-3 text-white flex justify-between items-center flex-shrink-0">
              <span className="flex items-center gap-2 font-bold text-sm uppercase tracking-wider">
                <Syringe size={18} className="text-blue-400" /> Paraf Imunisasi
              </span>
              <button
                onClick={() => setIsModalOpen(false)}
                aria-label="Tutup dialog"
                className="hover:rotate-90 transition-transform"
              >
                <X size={20} aria-hidden="true" />
              </button>
            </div>

            {/* Tanggal Pemberian - Fixed at top */}
            <div className="px-5 pt-4 pb-3 bg-blue-50 border-b border-blue-100 flex-shrink-0">
              <label
                className="text-gray-600 mb-1.5 block text-xs font-bold uppercase tracking-wider"
              >
                Tanggal Pemberian
              </label>
              <div className="flex items-center gap-2 bg-white border-2 border-blue-200 rounded-lg px-3 py-2 focus-within:border-blue-500 transition-colors">
                <Calendar size={18} className="text-blue-500" />
                <input
                  type="date"
                  aria-label="Tanggal Pemberian"
                  className="w-full outline-none font-bold text-sm bg-transparent text-black"
                  style={{ colorScheme: "light" }}
                  value={formData.tanggal}
                  onChange={(e) =>
                    setFormData({ ...formData, tanggal: e.target.value })
                  }
                  max={new Date().toISOString().split("T")[0]}
                  required
                />
              </div>
              <p className="text-xs text-blue-600 mt-1.5 font-medium">
                📅 Pilih tanggal pemberian imunisasi
              </p>
            </div>

            {/* Modal Form - Scrollable */}
            <form
              onSubmit={handleSubmit}
              className="flex-1 flex flex-col overflow-hidden"
            >
              <div className="flex-1 overflow-y-auto p-5 space-y-3.5">
                {/* Vaccine Selection */}
                <div className="bg-gray-50 p-3.5 rounded-xl border border-gray-200">
                  <div className="flex justify-between items-center mb-2.5">
                    <label className="text-gray-400 text-[10px] font-bold uppercase tracking-widest">
                      Vaksin yang Belum Diberikan:
                    </label>
                    <span className="text-[10px] text-gray-500">
                      {allAvailableJadwal.length} tersedia
                    </span>
                  </div>

                  {/* Empty State Messages */}
                  {allAvailableJadwal.length === 0 && (
                    <div className="text-center py-6">
                      <AlertTriangle
                        size={32}
                        className="text-amber-400 mx-auto mb-2"
                      />
                      <p className="text-sm text-gray-600 font-medium">
                        Tidak ada vaksin tersedia
                      </p>
                      <p className="text-xs text-gray-500 mt-1">
                        Semua vaksin untuk anak ini sudah diberikan.
                      </p>
                    </div>
                  )}

                  <div
                    tabindex="0"
                    role="region"
                    aria-label="Daftar Imunisasi"
                    class="space-y-2 max-h-60 sm:max-h-52 overflow-y-auto pr-1.5 focus:outline-none focus:ring-2 focus:ring-blue-500 rounded"
                  >
                    {allAvailableJadwal.map((jadwal) => {
                      const isSelected = formData.selectedJadwalIds.includes(
                        jadwal.jadwal_id,
                      );
                      const prevDoseOk = isPreviousDoseComplete(
                        jadwal.dosis_vaksin_id,
                      );
                      const prevDoseName = !prevDoseOk
                        ? getPreviousDoseName(jadwal.dosis_vaksin_id)
                        : "";
                      const usiaCukup = isUsiaCukup(jadwal.dosis_vaksin_id);
                      const usiaTerlambat = isUsiaTerlambat(
                        jadwal.dosis_vaksin_id,
                      );
                      const canBeSelected = prevDoseOk && usiaCukup;

                      // Get minimum age requirement
                      const aturan = findAturanByDosisId(
                        jadwal.dosis_vaksin_id,
                      );
                      const minUsiaBulan = aturan?.min_usia_hari
                        ? Math.floor(aturan.min_usia_hari / 30)
                        : 0;

                      // Determine icon and color based on condition
                      let StatusIcon = XCircle;
                      let iconColor = "text-gray-400";
                      let reasonText = "";

                      if (!prevDoseOk) {
                        StatusIcon = Lock;
                        iconColor = "text-red-500";
                        reasonText = `Memerlukan ${prevDoseName} selesai terlebih dahulu`;
                      } else if (!usiaCukup) {
                        StatusIcon = Clock;
                        iconColor = "text-amber-500";
                        reasonText = `Anak belum mencapai usia minimal ${minUsiaBulan} bulan`;
                      } else if (usiaTerlambat) {
                        StatusIcon = AlertTriangle;
                        iconColor = "text-orange-500";
                        reasonText = "Terlambat dari jadwal ideal";
                      }

                      return (
                        <div key={jadwal.jadwal_id} className="space-y-2">
                          <div
                            onClick={() => {
                              if (!canBeSelected) {
                                if (!prevDoseOk) {
                                  Swal.fire({
                                    icon: "warning",
                                    title: "Belum Bisa Diberikan",
                                    html: `<div class="text-left"><p class="mb-2"><b>${jadwal.nama_dosis}</b> memerlukan dosis <b>${prevDoseName}</b> diselesaikan terlebih dahulu.</p><p class="text-sm text-gray-600">📋 Dosis harus diberikan secara berurutan untuk memastikan kekebalan yang optimal.</p></div>`,
                                    confirmButtonColor: "#2563eb",
                                    confirmButtonText: "Mengerti",
                                  });
                                } else if (!usiaCukup) {
                                  Swal.fire({
                                    icon: "info",
                                    title: "Anak Belum Cukup Umur",
                                    html: `<div class="text-left"><p class="mb-2"><b>${jadwal.nama_dosis}</b> dapat diberikan minimal pada usia <b>${minUsiaBulan} bulan</b>.</p><p class="text-sm text-gray-600">⏰ Anak ini belum mencapai usia minimal untuk vaksin tersebut.</p></div>`,
                                    confirmButtonColor: "#2563eb",
                                    confirmButtonText: "Mengerti",
                                  });
                                }
                                return;
                              }
                              handleToggleJadwal(jadwal.jadwal_id);
                            }}
                            className={`flex items-center justify-between gap-3 p-2.5 rounded-lg border-2 transition-all cursor-pointer ${
                              !canBeSelected
                                ? "bg-gray-50 border-gray-200 text-gray-500 cursor-not-allowed"
                                : isSelected
                                  ? "bg-blue-600 text-white border-blue-600 shadow-md"
                                  : "bg-white border-gray-200 text-gray-700 hover:border-blue-300 hover:shadow-sm"
                            }`}
                          >
                            <div className="flex items-center gap-3 flex-1">
                              {!canBeSelected ? (
                                <StatusIcon
                                  size={20}
                                  className={`${iconColor} flex-shrink-0`}
                                />
                              ) : isSelected ? (
                                <CheckSquare
                                  size={20}
                                  className="flex-shrink-0"
                                />
                              ) : (
                                <Square size={20} className="flex-shrink-0" />
                              )}
                              <div className="flex flex-col flex-1">
                                <span className="text-sm font-semibold">
                                  {jadwal.nama_dosis}
                                </span>
                                {!canBeSelected && reasonText && (
                                  <span
                                    className={`text-[10px] mt-0.5 flex items-start gap-1 ${
                                      !prevDoseOk
                                        ? "text-red-600"
                                        : "text-amber-600"
                                    }`}
                                  >
                                    <span className="font-bold">●</span>
                                    <span>{reasonText}</span>
                                  </span>
                                )}
                                {canBeSelected && usiaTerlambat && (
                                  <span className="text-[10px] text-orange-600 mt-0.5 flex items-center gap-1">
                                    <AlertTriangle size={12} />
                                    <span>{reasonText}</span>
                                  </span>
                                )}
                              </div>
                            </div>
                            {canBeSelected && (
                              <CheckCircle2
                                size={18}
                                className={`flex-shrink-0 ${isSelected ? "text-white" : "text-gray-300"}`}
                              />
                            )}
                          </div>

                          {isSelected && (
                            <div className="pl-8 pr-2">
                              <input
                                type="text"
                                placeholder="No. Batch Vaksin (opsional)"
                                className="w-full text-xs border-2 border-blue-200 rounded-lg px-2.5 py-1.5 outline-none focus:border-blue-400 bg-blue-50/30"
                                value={formData.batches[jadwal.jadwal_id] || ""}
                                onChange={(e) =>
                                  setFormData((prev) => ({
                                    ...prev,
                                    batches: {
                                      ...prev.batches,
                                      [jadwal.jadwal_id]: e.target.value,
                                    },
                                  }))
                                }
                                onClick={(e) => e.stopPropagation()}
                              />
                            </div>
                          )}
                        </div>
                      );
                    })}
                  </div>
                </div>

                {/* Catatan */}
                <div>
                  <label className="text-gray-500 mb-1 block text-xs font-bold uppercase tracking-wider">
                    Catatan Umum
                  </label>
                  <textarea
                    className="w-full border-2 border-gray-200 p-2 outline-none text-xs focus:border-blue-600 rounded-lg resize-none"
                    placeholder="Catatan tambahan (opsional)..."
                    rows="2"
                    value={formData.catatan}
                    onChange={(e) =>
                      setFormData({ ...formData, catatan: e.target.value })
                    }
                  />
                </div>
              </div>

              {/* Submit Button - Fixed at bottom, always visible */}
              <div className="px-5 py-3.5 border-t border-gray-100 bg-white flex-shrink-0">
                <button
                  disabled={
                    isSubmitting || formData.selectedJadwalIds.length === 0
                  }
                  type="submit"
                  className="w-full bg-blue-600 text-white py-3 rounded-xl hover:bg-blue-700 flex justify-center items-center gap-3 transition-all font-bold text-sm uppercase tracking-wider disabled:bg-gray-300 shadow-lg disabled:shadow-none"
                >
                  {isSubmitting ? (
                    <>
                      <RefreshCw size={18} className="animate-spin" />{" "}
                      MEMPROSES...
                    </>
                  ) : (
                    <>
                      <Save size={18} /> SIMPAN (
                      {formData.selectedJadwalIds.length}) PARAF
                    </>
                  )}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </MainLayout>
  );
};

export default PelayananImunisasi;
