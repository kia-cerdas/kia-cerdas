// src/pages/Dashboard.jsx
import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import MainLayout from "../components/Layout/MainLayout";
import { getIbuDashboard } from "../services/ibu";
import { getJadwalLayananList } from "../services/jadwalLayanan";
import {
  getKesehatanKelompok,
  getCakupanPemeriksaan,
  getPendudukByRisk,
} from "../services/dashboardService";
import { getCurrentUser } from "../services/auth";

// ==================== Ikon (lengkap + sesuai kategori umur) ====================
const icons = {
  home: <svg width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z" /><polyline points="9,22 9,12 15,12 15,22" /></svg>,
  users: <svg width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2" /><circle cx="9" cy="7" r="4" /><path d="M23 21v-2a4 4 0 00-3-3.87" /><path d="M16 3.13a4 4 0 010 7.75" /></svg>,
  growth: <svg width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><polyline points="23,6 13.5,15.5 8.5,10.5 1,18" /><polyline points="17,6 23,6 23,12" /></svg>,
  heart: <svg width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 000-7.78z" /></svg>,
  calendar: <svg width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2" /><line x1="16" y1="2" x2="16" y2="6" /><line x1="8" y1="2" x2="8" y2="6" /><line x1="3" y1="10" x2="21" y2="10" /></svg>,
  report: <svg width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z" /><polyline points="14,2 14,8 20,8" /><line x1="16" y1="13" x2="8" y2="13" /><line x1="16" y1="17" x2="8" y2="17" /><polyline points="10,9 9,9 8,9" /></svg>,
  preg: <svg width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10" /><path d="M12 8v4l3 3" /></svg>,
  baby: <svg width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><path d="M12 2a5 5 0 0 0-5 5c0 2.5 2 5 5 5s5-2.5 5-5a5 5 0 0 0-5-5z" /><path d="M7 13c-2 2-3 5-3 7h16c0-2-1-5-3-7" /><circle cx="9" cy="9" r="1" /><circle cx="15" cy="9" r="1" /></svg>,
  school: <svg width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><path d="M22 10v6M2 10l10-5 10 5-10 5-10-5z" /><path d="M6 10v4c0 1.5 3 3 6 3s6-1.5 6-3v-4" /></svg>,
  teen: <svg width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><path d="M12 2a3 3 0 0 0-3 3c0 1.5 1 2.5 2 3" /><path d="M17 15v-2c0-2-2-4-5-4s-5 2-5 4v2" /><circle cx="9" cy="9" r="1" /><circle cx="15" cy="9" r="1" /><path d="M7 19h10" /></svg>,
  adult: <svg width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><path d="M12 2a4 4 0 1 0 0 8 4 4 0 0 0 0-8z" /><path d="M20 22v-2a6 6 0 0 0-6-6h-4a6 6 0 0 0-6 6v2" /><rect x="16" y="8" width="4" height="8" rx="1" /><rect x="4" y="12" width="4" height="4" rx="1" /></svg>,
  elderly: <svg width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><path d="M12 2a3 3 0 1 0 0 6 3 3 0 0 0 0-6z" /><path d="M18 22v-2a4 4 0 0 0-4-4h-4a4 4 0 0 0-4 4v2" /><path d="M8 11l-2 3 2 1" /><path d="M16 11l2 3-2 1" /><path d="M12 14v4" /></svg>,
  imm: <svg width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 11-5.93-9.14" /><polyline points="22,4 12,14.01 9,11.01" /></svg>,
  sched: <svg width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2" /><line x1="16" y1="2" x2="16" y2="6" /><line x1="8" y1="2" x2="8" y2="6" /><line x1="3" y1="10" x2="21" y2="10" /></svg>,
  search: <svg width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><circle cx="11" cy="11" r="8" /><path d="M21 21l-4.35-4.35" /></svg>,
  sync: <svg width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><polyline points="23,4 23,10 17,10" /><polyline points="1,20 1,14 7,14" /><path d="M3.51 9a9 9 0 0114.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0020.49 15" /></svg>,
  warn: <svg width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z" /><line x1="12" y1="9" x2="12" y2="13" /><line x1="12" y1="17" x2="12.01" y2="17" /></svg>,
  chevronRight: <svg width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><polyline points="9,18 15,12 9,6" /></svg>,
  ambulance: <svg width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><path d="M5 13h4v4H5zm6 0h4v4h-4z" /><path d="M18 16h-3v-4h3a2 2 0 012 2v2a2 2 0 01-2 2z" /><path d="M6 16H4a2 2 0 01-2-2v-2a2 2 0 012-2h14" /><path d="M9 12V8a2 2 0 012-2h6a2 2 0 012 2v4" /><circle cx="7" cy="17" r="2" /><circle cx="17" cy="17" r="2" /></svg>,
  info: <svg width="14" height="14" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10" /><line x1="12" y1="16" x2="12" y2="12" /><line x1="12" y1="8" x2="12.01" y2="8" /></svg>,
};

// ==================== Helper functions ====================
function getDateKey(value) {
  if (!value) return "";
  const d = new Date(value);
  if (isNaN(d.getTime())) return "";
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, "0");
  const day = String(d.getDate()).padStart(2, "0");
  return `${y}-${m}-${day}`;
}
function getTodayKey() {
  const now = new Date();
  const y = now.getFullYear();
  const m = String(now.getMonth() + 1).padStart(2, "0");
  const day = String(now.getDate()).padStart(2, "0");
  return `${y}-${m}-${day}`;
}
function isToday(tanggal) {
  return getDateKey(tanggal) === getTodayKey();
}
function isDone(row) {
  if (!row || !row.tanggal) return false;
  const todayKey = getTodayKey();
  const dateKey = getDateKey(row.tanggal);
  if (!dateKey) return false;
  if (dateKey < todayKey) return true;
  if (dateKey > todayKey) return false;
  return false;
}
function normalizeRisk(risk) {
  if (!risk || risk.trim() === "") return "Belum Diperiksa";
  const upperRisk = risk.toUpperCase();
  if (upperRisk === "PERLU RUJUKAN" || upperRisk === "TINGGI") return "Tinggi";
  if (upperRisk === "PERLU TINDAKAN" || upperRisk === "SEDANG") return "Sedang";
  if (upperRisk === "NORMAL" || upperRisk === "RENDAH" || upperRisk === "RISIKO RENDAH") return "Normal";
  return "Belum Diperiksa";
}
function getFilterFromRisk(risk) {
  if (risk === "Tinggi") return "PERLU RUJUKAN";
  if (risk === "Sedang") return "PERLU TINDAKAN";
  return "NORMAL";
}

// ==================== Warna card berdasarkan risiko ====================
function getRiskCardStyle(risk) {
  switch (risk) {
    case "Tinggi":
      return {
        borderColor: "#ef4444",
        bgColor: "#fef2f2",
        hoverBg: "#fee2e2",
        iconBg: "#fee2e2",
        iconColor: "#ef4444"
      };
    case "Sedang":
      return {
        borderColor: "#f59e0b",
        bgColor: "#fffbeb",
        hoverBg: "#fef3c7",
        iconBg: "#fef3c7",
        iconColor: "#f59e0b"
      };
    case "Normal":
      return {
        borderColor: "#10b981",
        bgColor: "#ecfdf5",
        hoverBg: "#d1fae5",
        iconBg: "#d1fae5",
        iconColor: "#10b981"
      };
    default:
      return {
        borderColor: "#e2e8f0",
        bgColor: "#fff",
        hoverBg: "#f8fafc",
        iconBg: "#f1f5f9",
        iconColor: "#64748b"
      };
  }
}

// ==================== Komponen Kartu Ringkasan (dengan onClick) ====================
function RingkasanCard({
  label,
  total,
  sub1Value,
  sub2Value,
  persentase,
  icon,
  color,
  bgColor,
  sub1Label,
  sub2Label,
  cakupanLabel = "Cakupan",
  tooltipText = "Persentase sasaran yang telah menerima pelayanan",
  onClick
}) {
  return (
    <div
      onClick={onClick}
      style={{
        background: "#fff",
        borderRadius: 10,
        padding: "10px 8px",
        border: "1px solid #e2e8f0",
        textAlign: "center",
        boxShadow: "0 1px 2px rgba(0,0,0,0.02)",
        transition: "transform 0.1s ease",
        cursor: onClick ? "pointer" : "default",
        minWidth: "180px",
        height: "fit-content",
      }}
      onMouseEnter={(e) => { if (onClick) e.currentTarget.style.transform = "translateY(-2px)"; }}
      onMouseLeave={(e) => { if (onClick) e.currentTarget.style.transform = "translateY(0)"; }}
    >
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 6 }}>
        <div style={{ 
          fontSize: 11, 
          fontWeight: 600, 
          color: "#475569",
          whiteSpace: "nowrap",
          overflow: "hidden",
          textOverflow: "ellipsis",
          maxWidth: "calc(100% - 35px)"
        }}>
          {label}
        </div>
        <div style={{ width: 26, height: 26, background: bgColor, borderRadius: 6, display: "flex", alignItems: "center", justifyContent: "center", color: color, flexShrink: 0 }}>
          {icon}
        </div>
      </div>

      <div style={{ fontSize: 22, fontWeight: 800, color: "#0f172a", marginBottom: 6 }}>
        {total.toLocaleString()}
      </div>

      <div style={{ display: "flex", justifyContent: "space-between", fontSize: 9, marginBottom: 6, gap: 6 }}>
        <span style={{ color: "#10b981", fontWeight: 500, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>
          {sub1Label}: {sub1Value}
        </span>
        <span style={{ color: "#f97316", fontWeight: 500, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>
          {sub2Label}: {sub2Value}
        </span>
      </div>

      <div style={{ background: "#e2e8f0", borderRadius: 4, height: 4, overflow: "hidden", marginTop: 2, marginBottom: 4 }}>
        <div style={{ width: `${persentase}%`, background: "#10b981", height: 4, borderRadius: 4 }} />
      </div>

      <div style={{ 
        fontSize: 9, 
        color: "#64748b", 
        marginTop: 2, 
        display: "flex", 
        alignItems: "center", 
        justifyContent: "center", 
        gap: 4,
        whiteSpace: "nowrap"
      }}>
        <span>{cakupanLabel}: {persentase.toFixed(1)}%</span>
        {/* <span style={{ cursor: "help", borderBottom: "1px dotted #94a3b8" }} title={tooltipText}>
          {icons.info}
        </span> */}
      </div>
    </div>
  );
}

// ==================== Komponen Bar Chart ====================
function RiskBarChart({ data, onBarClick, activeRisk }) {
  const categories = [
    { label: "Risiko Tinggi", key: "Tinggi", color: "#ef4444", filter: "Tinggi" },
    { label: "Risiko Sedang", key: "Sedang", color: "#f59e0b", filter: "Sedang" },
    { label: "Risiko Rendah", key: "Normal", color: "#10b981", filter: "Normal" },
  ];
  const maxValue = Math.max(data.Tinggi || 0, data.Sedang || 0, data.Normal || 0, 1);
  const total = (data.Tinggi || 0) + (data.Sedang || 0) + (data.Normal || 0);
  return (
    <div style={{ display: "flex", gap: 24, alignItems: "flex-end", marginTop: 12, height: 280 }}>
      {categories.map((cat) => {
        const value = data[cat.key] || 0;
        const percent = (value / maxValue) * 100;
        const isActive = activeRisk === cat.filter;
        return (
          <div
            key={cat.key}
            onClick={() => onBarClick(cat.filter, cat.label)}
            style={{
              flex: 1,
              textAlign: "center",
              cursor: "pointer",
              transition: "transform 0.2s",
              transform: isActive ? "translateY(-4px)" : "none",
            }}
            onMouseEnter={(e) => (e.currentTarget.style.transform = "translateY(-4px)")}
            onMouseLeave={(e) => {
              if (!isActive) e.currentTarget.style.transform = "translateY(0)";
            }}
          >
            <div style={{ height: 200, display: "flex", flexDirection: "column", justifyContent: "flex-end" }}>
              <div
                style={{
                  height: `${percent}%`,
                  minHeight: 8,
                  backgroundColor: cat.color,
                  borderRadius: "6px 6px 0 0",
                  opacity: isActive ? 1 : 0.85,
                }}
              />
            </div>
            <div style={{ marginTop: 8, fontSize: 11, fontWeight: 600, color: "#1e293b" }}>{cat.label}</div>
            <div style={{ fontSize: 14, fontWeight: "bold", color: cat.color }}>{value}</div>
            <div style={{ fontSize: 10, color: "#64748b" }}>{total > 0 ? ((value / total) * 100).toFixed(0) : 0}%</div>
          </div>
        );
      })}
    </div>
  );
}

export default function Dashboard() {
  const navigate = useNavigate();
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showOnboarding, setShowOnboarding] = useState(false);
  const [todayScheduleCount, setTodayScheduleCount] = useState(0);

  // Data ibu hamil
  const [allIbuData, setAllIbuData] = useState([]);
  const [statsIbu, setStatsIbu] = useState({
    total_kehamilan: 0,
    kehamilan_aktif: 0,
    resiko_tinggi: 0,
    resiko_sedang: 0,
    resiko_normal: 0,
    per_dusun: [],
  });
  const [selectedRiskFilter, setSelectedRiskFilter] = useState("Tinggi");
  const [selectedRiskLabel, setSelectedRiskLabel] = useState("Risiko Tinggi");
  const [filteredIbuList, setFilteredIbuList] = useState([]);

  // State untuk interaksi desa (dusun)
  const [selectedDusun, setSelectedDusun] = useState(null);
  const [dusunIbuList, setDusunIbuList] = useState([]);

  // Data kelompok usia & cakupan
  const [kesehatanKelompok, setKesehatanKelompok] = useState(null);
  const [cakupan, setCakupan] = useState([]);
  const [selectedKategori, setSelectedKategori] = useState("ibu-hamil");
  const [activeRiskKelompok, setActiveRiskKelompok] = useState(null);
  const [activeRiskLabelKelompok, setActiveRiskLabelKelompok] = useState("");
  const [daftarKelompok, setDaftarKelompok] = useState([]);
  const [loadingDaftar, setLoadingDaftar] = useState(false);

  // Ambil data user dari localStorage
  useEffect(() => {
    const currentUser = getCurrentUser();
    setUser(currentUser);
  }, []);

  // Onboarding
  useEffect(() => {
    const hasSeen = localStorage.getItem("dashboard_onboarding_seen");
    if (!hasSeen) {
      setShowOnboarding(true);
      localStorage.setItem("dashboard_onboarding_seen", "true");
    }
  }, []);

  // Fetch ibu hamil
  useEffect(() => {
  const fetchIbu = async () => {
    try {
      setLoading(true);
      const response = await getIbuDashboard();

      // 🔧 FIX: Sesuaikan dengan struktur yang dikembalikan service (array langsung)
      let rawData = [];
      if (Array.isArray(response)) {
        rawData = response;
      } else if (response?.data && Array.isArray(response.data)) {
        rawData = response.data;
      } else if (response?.data?.data && Array.isArray(response.data.data)) {
        rawData = response.data.data;
      } else {
        console.error("Struktur response tidak dikenali:", response);
        rawData = [];
      }

      console.log("Data ibu hamil (Dashboard):", rawData); // cek di console
      setAllIbuData(rawData);

      const kehamilanList = rawData.filter((item) => item.kehamilan_id && item.kehamilan_id !== 0);
      const total_kehamilan = kehamilanList.length;
      const aktifList = kehamilanList.filter((item) => item.status_kehamilan?.includes("TRIMESTER"));
      const kehamilan_aktif = aktifList.length;

      const risikoTinggiList = kehamilanList.filter((item) => normalizeRisk(item.status_risiko) === "Tinggi");
      const risikoSedangList = kehamilanList.filter((item) => normalizeRisk(item.status_risiko) === "Sedang");
      const risikoNormalList = kehamilanList.filter((item) => normalizeRisk(item.status_risiko) === "Normal");

      const dusunMap = new Map();
      kehamilanList.forEach((item) => {
        const dusun = item.dusun && item.dusun.trim() ? item.dusun : "Tidak diketahui";
        dusunMap.set(dusun, (dusunMap.get(dusun) || 0) + 1);
      });
      const per_dusun = Array.from(dusunMap.entries()).map(([dusun, jumlah]) => ({ dusun, jumlah }));

      setStatsIbu({
        total_kehamilan,
        kehamilan_aktif,
        resiko_tinggi: risikoTinggiList.length,
        resiko_sedang: risikoSedangList.length,
        resiko_normal: risikoNormalList.length,
        per_dusun,
      });
    } catch (err) {
      console.error("Error fetchIbu:", err);
      setError("Gagal memuat data ibu hamil: " + (err.response?.data?.message || err.message));
    } finally {
      setLoading(false);
    }
  };
  fetchIbu();
}, []);

  // Filter daftar ibu berdasarkan risiko terpilih (untuk tampilan risiko)
  useEffect(() => {
    if (!allIbuData.length) return;
    const filtered = allIbuData
      .filter((item) => {
        if (!item.kehamilan_id || item.kehamilan_id === 0) return false;
        const normalized = normalizeRisk(item.status_risiko);
        return normalized === selectedRiskFilter;
      })
      .map((item) => ({
        nama: item.nama_anggota_keluarga,
        detail: `Dusun ${item.dusun}, usia kehamilan ${item.usia_kehamilan} minggu`,
        kehamilan_id: item.kehamilan_id,
        ibu_id: item.id_ibu,
        isRujukan: (item.status_risiko || "").toUpperCase() === "PERLU RUJUKAN",
      }));
    setFilteredIbuList(filtered);
  }, [allIbuData, selectedRiskFilter]);

  // Handler klik dusun (interaktivitas desa)
  const handleDusunClick = (dusunName) => {
    if (!allIbuData.length) return;
    const list = allIbuData
      .filter((item) => item.kehamilan_id && item.kehamilan_id !== 0 && item.dusun === dusunName)
      .map((item) => ({
        nama: item.nama_anggota_keluarga,
        detail: `Usia kehamilan ${item.usia_kehamilan} minggu, risiko ${normalizeRisk(item.status_risiko)}`,
        kehamilan_id: item.kehamilan_id,
        ibu_id: item.id_ibu,
        isRujukan: (item.status_risiko || "").toUpperCase() === "PERLU RUJUKAN",
        dusun: item.dusun,
      }));
    setSelectedDusun(dusunName);
    setDusunIbuList(list);
  };

  const handleBackToRisk = () => {
    setSelectedDusun(null);
    setDusunIbuList([]);
  };

  // Fetch jadwal hari ini
  useEffect(() => {
    const fetchSchedule = async () => {
      try {
        const data = await getJadwalLayananList();
        let rows = [];
        if (Array.isArray(data)) rows = data;
        else if (Array.isArray(data?.data)) rows = data.data;
        else if (Array.isArray(data?.items)) rows = data.items;
        const todayCount = rows.filter((r) => isToday(r.tanggal) && !isDone(r)).length;
        setTodayScheduleCount(todayCount);
      } catch (err) {
        console.error("Gagal ambil jadwal:", err);
      }
    };
    fetchSchedule();
  }, []);

  // Fetch kelompok usia & cakupan
  useEffect(() => {
    const fetchKelompok = async () => {
      try {
        const [resKesehatan, resCakupan] = await Promise.all([getKesehatanKelompok(), getCakupanPemeriksaan()]);
        setKesehatanKelompok(resKesehatan);
        setCakupan(Array.isArray(resCakupan) ? resCakupan : []);
      } catch (err) {
        console.error("Gagal memuat data kelompok usia:", err);
        setError("Gagal memuat data kelompok usia.");
      } finally {
        setLoading(false);
      }
    };
    fetchKelompok();
  }, []);

  // Handler klik batang grafik
  const handleBarClick = (riskFilter, riskLabel) => {
    setSelectedDusun(null);
    setDusunIbuList([]);
    if (selectedKategori === "ibu-hamil") {
      setSelectedRiskFilter(riskFilter);
      setSelectedRiskLabel(riskLabel);
    } else {
      setActiveRiskKelompok(riskFilter);
      setActiveRiskLabelKelompok(riskLabel);
      setLoadingDaftar(true);
      getPendudukByRisk(selectedKategori, riskFilter)
        .then((data) => setDaftarKelompok(data || []))
        .catch((err) => {
          console.error(err);
          setDaftarKelompok([]);
        })
        .finally(() => setLoadingDaftar(false));
    }
  };

  // ** Handler untuk klik kartu ringkasan **
  const handleCardClick = (kategoriKey) => {
    // Ubah kategori yang dipilih
    setSelectedKategori(kategoriKey);
    // Reset state terkait grafik dan daftar
    setActiveRiskKelompok(null);
    setDaftarKelompok([]);
    setSelectedRiskFilter("Tinggi");
    setSelectedRiskLabel("Risiko Tinggi");
    setSelectedDusun(null);
    setDusunIbuList([]);
  };

  // Data untuk grafik
  const getRiskData = () => {
    if (selectedKategori === "ibu-hamil") {
      return {
        Tinggi: statsIbu.resiko_tinggi,
        Sedang: statsIbu.resiko_sedang,
        Normal: statsIbu.resiko_normal,
      };
    } else {
      const data = kesehatanKelompok?.[selectedKategori] || { Tinggi: 0, Sedang: 0, Normal: 0 };
      return {
        Tinggi: data.Tinggi || data.tinggi || 0,
        Sedang: data.Sedang || data.sedang || 0,
        Normal: data.Normal || data.Rendah || data.normal || data.rendah || 0,
      };
    }
  };

  // Helper mengambil data cakupan untuk suatu kelompok
  const getCakupanByKelompok = (kelompokKey) => {
    return cakupan.find((c) => c.kelompok === kelompokKey) || null;
  };

  // Helper untuk mendapatkan total sasaran (untuk ringkasan di bawah grafik)
  const getTotalSasaran = () => {
    if (selectedKategori === "ibu-hamil") {
      return statsIbu.total_kehamilan;
    } else {
      const dataCakupan = getCakupanByKelompok(selectedKategori);
      return dataCakupan ? dataCakupan.total_sasaran : 0;
    }
  };

  const getCakupanPersen = () => {
    if (selectedKategori === "ibu-hamil") {
      return statsIbu.total_kehamilan > 0 ? (statsIbu.kehamilan_aktif / statsIbu.total_kehamilan) * 100 : 0;
    } else {
      const dataCakupan = getCakupanByKelompok(selectedKategori);
      return dataCakupan ? dataCakupan.persentase : 0;
    }
  };

  const getRisikoTinggiCount = () => {
    return getRiskData().Tinggi;
  };

  const getTotalRisiko = () => {
    const data = getRiskData();
    return (data.Tinggi || 0) + (data.Sedang || 0) + (data.Normal || 0);
  };

  // Data untuk 6 kartu ringkasan
  const kelompokList = [
    { key: "balita", label: "Balita (0-5 tahun)", color: "#d97706", tooltip: "Cakupan imunisasi & pemantauan tumbuh kembang balita" },
    { key: "anak", label: "Anak (6- 9 tahun)", color: "#0284c7", tooltip: "Pemeriksaan kesehatan anak usia sekolah" },
    { key: "remaja", label: "Remaja (10-18 tahun)", tooltip: "Kesehatan reproduksi & skrining remaja" },
    { key: "dewasa", label: "Dewasa (19-59 tahun)", tooltip: "Skrining PTM & pemeriksaan kesehatan umum" },
    { key: "lansia", label: "Lansia (60+ tahun)", tooltip: "Pemantauan penyakit kronis & kunjungan lansia" },
  ];

  // Kartu Ibu Hamil
  const totalKehamilan = statsIbu.total_kehamilan;
  const kehamilanAktif = statsIbu.kehamilan_aktif;
  const kehamilanNonAktif = totalKehamilan - kehamilanAktif;
  const persentaseKehamilanAktif = totalKehamilan > 0 ? (kehamilanAktif / totalKehamilan) * 100 : 0;

  const ibuHamilCard = {
    label: "Ibu Hamil",
    total: totalKehamilan,
    sub1Value: kehamilanAktif,
    sub2Value: kehamilanNonAktif,
    persentase: persentaseKehamilanAktif,
    sub1Label: "Aktif",
    sub2Label: "Non Aktif",
    cakupanLabel: "Cakupan Kehamilan Aktif",
    tooltipText: "Persentase kehamilan yang masih berjalan (trimester 1-3) dari total kehamilan tercatat",
    // icon: icons.preg,
    color: "#db2777",
    // bg: "#ffe4e6",
    kategoriKey: "ibu-hamil",   // tambahkan key
  };

  const kelompokCards = kelompokList.map((kel) => {
    const data = getCakupanByKelompok(kel.key);
    return {
      label: kel.label,
      total: data ? data.total_sasaran : 0,
      sub1Value: data ? data.sudah_diperiksa : 0,
      sub2Value: data ? data.belum_diperiksa : 0,
      persentase: data ? data.persentase : 0,
      sub1Label: "Terlayani",
      sub2Label: "Belum",
      cakupanLabel: "Cakupan Pelayanan",
      tooltipText: kel.tooltip,
      icon: kel.icon,
      color: kel.color,
      bg: kel.bg,
      kategoriKey: kel.key,
    };
  });

  const ringkasanCards = [ibuHamilCard, ...kelompokCards];

  if (loading) return <MainLayout><div style={{ textAlign: "center", padding: 40 }}>Memuat data dashboard...</div></MainLayout>;
  if (error) return <MainLayout><div style={{ textAlign: "center", padding: 40, color: "#ef4444" }}>{error}</div></MainLayout>;

  return (
    <MainLayout>
      {/* BANNER INFORMASI DESA */}
      {/* {user && (
        <div style={{
          margin: "12px 20px 0 20px",
          background: "#e0f2fe",
          borderRadius: 12,
          padding: "8px 16px",
          display: "flex",
          alignItems: "center",
          gap: 12,
          fontSize: 13,
          color: "#0c4a6e"
        }}>
          <span></span>
          <span>
            Menampilkan data untuk <strong>{user.desa_nama || 'Desa Anda'}</strong>
            {user.role === 'superadmin' && (
              <span style={{ marginLeft: 8, background: "#fef08a", padding: "2px 8px", borderRadius: 20 }}>
                Super Admin
              </span>
            )}
          </span>
        </div>
      )} */}

      <div style={{ background: "#f0f4f8", borderRadius: 14, border: "1px solid #e2e8f0", overflow: "hidden", position: "relative" }}>
        {showOnboarding && (
          <div style={{ position: "absolute", top: 20, right: 20, background: "white", border: "1px solid #cbd5e1", borderRadius: 12, padding: "16px", boxShadow: "0 10px 25px -5px rgba(0,0,0,0.1)", zIndex: 50, maxWidth: 280 }}>
            <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 8 }}><strong>✨ Panduan Singkat</strong><button onClick={() => setShowOnboarding(false)} style={{ background: "none", border: "none", fontSize: 18, cursor: "pointer" }}>×</button></div>
            <p style={{ fontSize: 13, marginBottom: 8 }}>• Klik batang grafik risiko untuk melihat daftar individu berdasarkan risiko.</p>
            <p style={{ fontSize: 13 }}>• Klik kartu ringkasan (Ibu Hamil, Balita, Anak, dll) untuk langsung berpindah kategori.</p>
            <p style={{ fontSize: 13, marginTop: 8 }}>• Klik nama individu untuk melihat detail pemeriksaan.</p>
          </div>
        )}

        <div style={{ padding: "16px 20px" }}>
          {/* Shortcut Card Jadwal Hari Ini */}
          <div style={{ marginBottom: 16, background: "linear-gradient(135deg, #185FA5 0%, #2c7cbf 100%)", borderRadius: 12, color: "white", padding: "16px 20px", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
            <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
              <div style={{ background: "rgba(255,255,255,0.2)", borderRadius: 12, padding: 8 }}>{icons.calendar}</div>
              <div>
                <div style={{ fontSize: 14, fontWeight: 500, opacity: 0.9 }}>Jadwal Layanan Imunisasi Hari Ini</div>
                <div style={{ fontSize: 28, fontWeight: "bold" }}>{todayScheduleCount} sesi</div>
                <div style={{ fontSize: 11, opacity: 0.7 }}>Klik tombol untuk kelola jadwal</div>
              </div>
            </div>
            <button onClick={() => navigate("/jadwal-layanan")} style={{ background: "white", color: "#185FA5", border: "none", borderRadius: 8, padding: "8px 16px", fontWeight: "bold", cursor: "pointer" }}>Lihat Jadwal →</button>
          </div>

          {/* KARTU RINGKASAN SATU BARIS (grid 6 kolom desktop / horizontal scroll mobile) - dengan onClick */}
          <div style={{ marginBottom: 20 }}>
            <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 8 }}>
              <h3 style={{ fontSize: 13, fontWeight: 600, color: "#334155" }}>Ringkasan Sasaran & Cakupan</h3>
            </div>
            <div className="overflow-x-auto pb-2">
              <div style={{ 
                display: "grid", 
                gridTemplateColumns: "repeat(6, minmax(180px, 1fr))", 
                gap: 12,
                minWidth: "min-content"
              }}>
                {ringkasanCards.map((card, idx) => (
                  <RingkasanCard
                    key={idx}
                    label={card.label}
                    total={card.total}
                    sub1Value={card.sub1Value}
                    sub2Value={card.sub2Value}
                    persentase={card.persentase}
                    sub1Label={card.sub1Label}
                    sub2Label={card.sub2Label}
                    cakupanLabel={card.cakupanLabel}
                    tooltipText={card.tooltipText}
                    icon={card.icon}
                    color={card.color}
                    bgColor={card.bg}
                    onClick={() => handleCardClick(card.kategoriKey)}
                  />
                ))}
              </div>
            </div>
          </div>

          {/* Layout Dua Kolom: Grafik (kiri) dan Daftar Nama (kanan) */}
          <div style={{ display: "grid", gridTemplateColumns: "minmax(0, 1fr) 360px", gap: 12, marginBottom: 12 }}>
            {/* Kiri: Dropdown + Grafik + Ringkasan Info */}
            <div style={{ background: "#fff", borderRadius: 10, padding: "16px", border: "1px solid #e2e8f0", display: "flex", flexDirection: "column" }}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 12, flexWrap: "wrap", gap: 8 }}>
                <h2 style={{ fontSize: 14, fontWeight: 700 }}>Status Risiko Kesehatan</h2>
                <select
                  value={selectedKategori}
                  onChange={(e) => {
                    setSelectedKategori(e.target.value);
                    setActiveRiskKelompok(null);
                    setDaftarKelompok([]);
                    setSelectedRiskFilter("Tinggi");
                    setSelectedRiskLabel("Risiko Tinggi");
                    setSelectedDusun(null);
                    setDusunIbuList([]);
                  }}
                  style={{ padding: "6px 12px", borderRadius: 8, border: "1px solid #cbd5e1", background: "white", fontSize: 13 }}
                >
                  <option value="ibu-hamil">Ibu Hamil</option>
                  {kelompokList.map((k) => (
                    <option key={k.key} value={k.key}>
                      {k.label}
                    </option>
                  ))}
                </select>
              </div>
              <div style={{ fontSize: 11, color: "#4b5563", marginBottom: 8, display: "flex", alignItems: "center", gap: 6, background: "#f1f5f9", padding: "6px 10px", borderRadius: 8 }}>
                {icons.info} <strong>Petunjuk:</strong> Klik salah satu batang (Tinggi/Sedang/Rendah) untuk melihat daftar individu yang masuk dalam kategori risiko tersebut.
              </div>
              <RiskBarChart data={getRiskData()} onBarClick={handleBarClick} activeRisk={selectedKategori === "ibu-hamil" ? selectedRiskFilter : activeRiskKelompok} />

              {/* ===== RINGKASAN INFORMASI DI BAWAH GRAFIK ===== */}
              <div style={{
                marginTop: 16,
                display: "flex",
                gap: 12,
                flexWrap: "wrap",
                justifyContent: "space-between",
                borderTop: "1px solid #e2e8f0",
                paddingTop: 12
              }}>
                {/* Total Sasaran */}
                <div style={{ flex: 1, background: "#f8fafc", borderRadius: 8, padding: "8px 12px", textAlign: "center" }}>
                  <div style={{ fontSize: 10, color: "#64748b" }}>Total Sasaran</div>
                  <div style={{ fontSize: 20, fontWeight: 700, color: "#0f172a" }}>
                    {getTotalSasaran().toLocaleString()}
                  </div>
                  <div style={{ fontSize: 9, color: "#94a3b8" }}>
                    {selectedKategori === "ibu-hamil" ? "kehamilan" : "penduduk"}
                  </div>
                </div>

                {/* Cakupan Pelayanan */}
                <div style={{ flex: 1, background: "#f8fafc", borderRadius: 8, padding: "8px 12px", textAlign: "center" }}>
                  <div style={{ fontSize: 10, color: "#64748b" }}>Cakupan Pelayanan</div>
                  <div style={{ fontSize: 20, fontWeight: 700, color: "#10b981" }}>
                    {getCakupanPersen().toFixed(0)}%
                  </div>
                  <div style={{ fontSize: 9, color: "#94a3b8" }}>
                    {selectedKategori === "ibu-hamil" ? "kehamilan aktif" : "sudah diperiksa"}
                  </div>
                </div>

                {/* Risiko Tinggi */}
                <div style={{ flex: 1, background: "#f8fafc", borderRadius: 8, padding: "8px 12px", textAlign: "center" }}>
                  <div style={{ fontSize: 10, color: "#64748b" }}>Risiko Tinggi</div>
                  <div style={{ fontSize: 20, fontWeight: 700, color: "#ef4444" }}>
                    {getRisikoTinggiCount()}
                  </div>
                  <div style={{ fontSize: 9, color: "#94a3b8" }}>
                    {getTotalRisiko() > 0 ? ((getRisikoTinggiCount() / getTotalRisiko()) * 100).toFixed(0) : 0}% dari total risiko
                  </div>
                </div>
              </div>

              {/* Penjelasan tambahan */}
              <div style={{ fontSize: 10, color: "#64748b", marginTop: 12, textAlign: "center", background: "#f1f5f9", padding: "6px", borderRadius: 6 }}>
                 Klik batang untuk melihat daftar individu. Warna batang menunjukkan tingkat risiko.
              </div>
            </div>

            {/* Kanan: Daftar Nama - dinamis antara risiko atau dusun */}
            <div style={{ background: "#fff", borderRadius: 10, padding: "14px 16px", border: "1px solid #e2e8f0", display: "flex", flexDirection: "column" }}>
              <div style={{ flexShrink: 0 }}>
                {selectedDusun && (
                  <div style={{ marginBottom: 8, textAlign: "right" }}>
                    <button
                      onClick={handleBackToRisk}
                      style={{ background: "#e2e8f0", border: "none", borderRadius: 20, padding: "4px 12px", fontSize: 11, fontWeight: 500, cursor: "pointer", display: "inline-flex", alignItems: "center", gap: 4 }}
                    >
                      ← Kembali ke Risiko
                    </button>
                  </div>
                )}
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 8, flexWrap: "wrap", gap: 8 }}>
                  <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
                    <h2 style={{ fontSize: 14, fontWeight: 700 }}>
                      {selectedDusun ? (
                        `Ibu Hamil di Dusun ${selectedDusun}`
                      ) : selectedKategori === "ibu-hamil" ? (
                        `Ibu dengan ${selectedRiskLabel}`
                      ) : (
                        `Daftar dengan Risiko ${activeRiskLabelKelompok || "-"} - ${kelompokList.find((k) => k.key === selectedKategori)?.label || selectedKategori}`
                      )}
                    </h2>
                    <span style={{ fontSize: 11, background: "#fef2f2", color: "#ef4444", padding: "2px 8px", borderRadius: 20, fontWeight: 600 }}>
                      {selectedDusun ? dusunIbuList.length : (selectedKategori === "ibu-hamil" ? filteredIbuList.length : daftarKelompok.length)} orang
                    </span>
                  </div>
                  {!selectedDusun && selectedKategori === "ibu-hamil" && (
                    <button
                      onClick={() => navigate(`/data-ibu?risiko=${encodeURIComponent(getFilterFromRisk(selectedRiskFilter))}`)}
                      style={{ background: "#3b82f6", border: "none", borderRadius: 20, padding: "4px 12px", fontSize: 12, fontWeight: 500, color: "white", cursor: "pointer", display: "flex", alignItems: "center", gap: 4 }}
                    >
                      Lihat Detail {icons.chevronRight}
                    </button>
                  )}
                </div>
                {!selectedDusun && (
                  <div style={{ fontSize: 11, marginBottom: 12, background: "#f8fafc", padding: "6px 10px", borderRadius: 8, color: "#334155" }}>
                     <strong>Informasi:</strong> Daftar ini akan muncul setelah Anda mengklik batang risiko pada grafik di sebelah kiri. Klik nama untuk melihat detail.
                  </div>
                )}
                {selectedDusun && (
                  <p style={{ fontSize: 11, marginBottom: 12, fontStyle: "italic", background: "#f8fafc", padding: "6px 10px", borderRadius: 8 }}>
                     Klik nama ibu untuk pemeriksaan. Tombol <strong>Rujuk</strong> untuk kasus perlu rujukan.
                  </p>
                )}
              </div>
              <div style={{ flex: 1, overflowY: "auto", maxHeight: 280 }}>
                <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
                  {/* Tampilan berdasarkan mode */}
                  {selectedDusun ? (
                    dusunIbuList.length > 0 ? (
                      dusunIbuList.map((r, idx) => {
                        const riskLevel = normalizeRisk(r.isRujukan ? "PERLU RUJUKAN" : "NORMAL");
                        const riskStyle = getRiskCardStyle(riskLevel);
                        return (
                          <div
                            key={idx}
                            onClick={() => navigate(`/data-ibu/${r.ibu_id}/pemeriksaan-rutin?kehamilan_id=${r.kehamilan_id}`)}
                            style={{
                              background: riskStyle.bgColor,
                              border: `1px solid ${riskStyle.borderColor}`,
                              borderRadius: 12,
                              padding: "12px 14px",
                              cursor: "pointer",
                              transition: "all 0.2s",
                              display: "flex",
                              alignItems: "center",
                              justifyContent: "space-between"
                            }}
                            onMouseEnter={(e) => {
                              e.currentTarget.style.backgroundColor = riskStyle.hoverBg;
                              e.currentTarget.style.transform = "translateY(-2px)";
                            }}
                            onMouseLeave={(e) => {
                              e.currentTarget.style.backgroundColor = riskStyle.bgColor;
                              e.currentTarget.style.transform = "translateY(0)";
                            }}
                          >
                            <div style={{ display: "flex", gap: 12, alignItems: "center", flex: 1 }}>
                              <div style={{ background: riskStyle.iconBg, borderRadius: 8, padding: 8, color: riskStyle.iconColor }}>
                                {icons.warn}
                              </div>
                              <div>
                                <div style={{ fontSize: 13, fontWeight: 700 }}>{r.nama}</div>
                                <div style={{ fontSize: 11, color: "#475569" }}>{r.detail}</div>
                              </div>
                            </div>
                            <div style={{ display: "flex", gap: 8, alignItems: "center" }}>
                              {r.isRujukan && (
                                <button
                                  onClick={(e) => {
                                    e.stopPropagation();
                                    navigate(`/data-ibu/${r.ibu_id}/rujukan?kehamilan_id=${r.kehamilan_id}`);
                                  }}
                                  style={{ background: "#dc2626", border: "none", borderRadius: 16, padding: "4px 10px", fontSize: 10, fontWeight: "bold", color: "white", cursor: "pointer", display: "flex", alignItems: "center", gap: 4 }}
                                >
                                  {icons.ambulance} Rujuk
                                </button>
                              )}
                              {icons.chevronRight}
                            </div>
                          </div>
                        );
                      })
                    ) : (
                      <div style={{ textAlign: "center", padding: 30, background: "#f8fafc", borderRadius: 12, color: "#94a3b8" }}>
                        Tidak ada ibu hamil di dusun {selectedDusun}
                      </div>
                    )
                  ) : selectedKategori === "ibu-hamil" ? (
                    filteredIbuList.length > 0 ? (
                      filteredIbuList.map((r, idx) => {
                        const riskStyle = getRiskCardStyle(selectedRiskFilter);
                        return (
                          <div
                            key={idx}
                            onClick={() => navigate(`/data-ibu/${r.ibu_id}/pemeriksaan-rutin?kehamilan_id=${r.kehamilan_id}`)}
                            style={{
                              background: riskStyle.bgColor,
                              border: `1px solid ${riskStyle.borderColor}`,
                              borderRadius: 12,
                              padding: "12px 14px",
                              cursor: "pointer",
                              transition: "all 0.2s",
                              display: "flex",
                              alignItems: "center",
                              justifyContent: "space-between"
                            }}
                            onMouseEnter={(e) => {
                              e.currentTarget.style.backgroundColor = riskStyle.hoverBg;
                              e.currentTarget.style.transform = "translateY(-2px)";
                            }}
                            onMouseLeave={(e) => {
                              e.currentTarget.style.backgroundColor = riskStyle.bgColor;
                              e.currentTarget.style.transform = "translateY(0)";
                            }}
                          >
                            <div style={{ display: "flex", gap: 12, alignItems: "center", flex: 1 }}>
                              <div style={{ background: riskStyle.iconBg, borderRadius: 8, padding: 8, color: riskStyle.iconColor }}>
                                {icons.warn}
                              </div>
                              <div>
                                <div style={{ fontSize: 13, fontWeight: 700 }}>{r.nama}</div>
                                <div style={{ fontSize: 11, color: "#475569" }}>{r.detail}</div>
                              </div>
                            </div>
                            <div style={{ display: "flex", gap: 8, alignItems: "center" }}>
                              {r.isRujukan && (
                                <button
                                  onClick={(e) => {
                                    e.stopPropagation();
                                    navigate(`/data-ibu/${r.ibu_id}/rujukan?kehamilan_id=${r.kehamilan_id}`);
                                  }}
                                  style={{ background: "#dc2626", border: "none", borderRadius: 16, padding: "4px 10px", fontSize: 10, fontWeight: "bold", color: "white", cursor: "pointer", display: "flex", alignItems: "center", gap: 4 }}
                                >
                                  {icons.ambulance} Rujuk
                                </button>
                              )}
                              {icons.chevronRight}
                            </div>
                          </div>
                        );
                      })
                    ) : (
                      <div style={{ textAlign: "center", padding: 30, background: "#f8fafc", borderRadius: 12, color: "#94a3b8" }}>
                        Tidak ada ibu dengan {selectedRiskLabel.toLowerCase()}
                      </div>
                    )
                  ) : loadingDaftar ? (
                    <div style={{ textAlign: "center", padding: 20 }}>Memuat...</div>
                  ) : daftarKelompok.length > 0 ? (
                    daftarKelompok.map((p, idx) => {
                      const riskStyle = getRiskCardStyle(activeRiskKelompok || "Normal");
                      return (
                        <div
                          key={idx}
                          onClick={() => navigate(`/data-penduduk/${p.id}`)}
                          style={{
                            background: riskStyle.bgColor,
                            border: `1px solid ${riskStyle.borderColor}`,
                            borderRadius: 12,
                            padding: "12px 14px",
                            cursor: "pointer",
                            transition: "all 0.2s",
                            display: "flex",
                            alignItems: "center",
                            justifyContent: "space-between"
                          }}
                          onMouseEnter={(e) => {
                            e.currentTarget.style.backgroundColor = riskStyle.hoverBg;
                            e.currentTarget.style.transform = "translateY(-2px)";
                          }}
                          onMouseLeave={(e) => {
                            e.currentTarget.style.backgroundColor = riskStyle.bgColor;
                            e.currentTarget.style.transform = "translateY(0)";
                          }}
                        >
                          <div>
                            <div style={{ fontWeight: 600 }}>
                              {p.nama_anggota_keluarga}
                              {p.nik && (
                                <span style={{ fontSize: 11, fontWeight: "normal", color: "#6c757d", marginLeft: 6 }}>
                                  ({p.nik})
                                </span>
                              )}
                            </div>
                            <div style={{ fontSize: 11, color: "#64748b" }}>
                              {p.dusun || "-"} · {p.usia} tahun
                            </div>
                          </div>
                          {icons.chevronRight}
                        </div>
                      );
                    })
                  ) : (
                    <div style={{ textAlign: "center", padding: 30, background: "#f8fafc", borderRadius: 12, color: "#94a3b8" }}>
                      Belum ada data. Klik batang pada grafik risiko terlebih dahulu.
                    </div>
                  )}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </MainLayout>
  );
}