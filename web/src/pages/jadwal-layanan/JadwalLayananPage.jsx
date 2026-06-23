import { useEffect, useState, useCallback } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import {
  CalendarDays,
  CalendarClock,
  CalendarCheck,
  Plus,
  Clock,
  MapPin,
  Pencil,
  Trash2,
  RefreshCw,
  AlertCircle,
  CalendarOff,
  Syringe,
} from "lucide-react";
import {
  getJadwalLayananList,
  deleteJadwalLayanan,
} from "../../services/jadwalLayanan";
import { useNavigate } from "react-router-dom";
import Swal from "sweetalert2";

// ─── helpers ────────────────────────────────────────────────────────────────

function formatDateParts(d) {
  if (!d) return { day: "-", num: "-", mon: "-" };
  const dt = new Date(d);
  return {
    day: dt.toLocaleDateString("id-ID", { weekday: "short" }),
    num: dt.getDate(),
    mon: dt.toLocaleDateString("id-ID", { month: "short" }),
  };
}

function getDateKey(value) {
  if (!value) return "";
  if (typeof value === "string") {
    const m = value.match(/^(\d{4}-\d{2}-\d{2})/);
    if (m?.[1]) return m[1];
  }
  const d = new Date(value);
  if (Number.isNaN(d.getTime())) return "";
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
  const dateKey = getDateKey(tanggal);
  if (!dateKey) return false;
  return dateKey === getTodayKey();
}

function isUpcoming(tanggal) {
  const dateKey = getDateKey(tanggal);
  if (!dateKey) return false;
  return dateKey > getTodayKey();
}

function isPast(tanggal) {
  const dateKey = getDateKey(tanggal);
  if (!dateKey) return false;
  return dateKey < getTodayKey();
}

function normalizeTimeValue(value) {
  if (!value) return "";
  if (typeof value === "string") {
    if (/^\d{2}:\d{2}$/.test(value)) return value;
    const timeInIso = value.match(/T(\d{2}:\d{2})/);
    if (timeInIso?.[1]) return timeInIso[1];
    const timeOnly = value.match(/^(\d{2}:\d{2})(:\d{2})?$/);
    if (timeOnly?.[1]) return timeOnly[1];
  }
  return "";
}

function isDone(row) {
  if (!row || !row.tanggal) return false;
  const todayKey = getTodayKey();
  const dateKey = getDateKey(row.tanggal);
  const now = new Date();

  if (!dateKey) return false;
  if (dateKey < todayKey) return true;
  if (dateKey > todayKey) return false;

  const waktuSelesai = normalizeTimeValue(row.waktu_selesai);
  if (waktuSelesai) {
    const t = new Date(`${dateKey}T${waktuSelesai}`);
    if (Number.isNaN(t.getTime())) return false;
    return now > t;
  }
  return false;
}

const LAYANAN_COLORS = [
  { bg: "bg-blue-50", text: "text-blue-800" },
  { bg: "bg-emerald-50", text: "text-emerald-800" },
  { bg: "bg-violet-50", text: "text-violet-800" },
  { bg: "bg-amber-50", text: "text-amber-800" },
  { bg: "bg-rose-50", text: "text-rose-800" },
];

function getLayananColor(name = "") {
  let h = 0;
  for (let i = 0; i < name.length; i++) h += name.charCodeAt(i);
  return LAYANAN_COLORS[h % LAYANAN_COLORS.length];
}

function getStatusBadgeClass(status) {
  switch (status) {
    case "done":
      return "text-emerald-700 bg-emerald-50 border border-emerald-200";
    case "today":
      return "text-sky-700 bg-sky-50 border border-sky-200";
    case "upcoming":
      return "text-amber-700 bg-amber-50 border border-amber-200";
    default:
      return "text-slate-600 bg-slate-100 border border-slate-200";
  }
}

// ─── tab config ─────────────────────────────────────────────────────────────

const TABS = [
  {
    key: "today",
    label: "Hari Ini",
    sub: "Semua jadwal hari ini, termasuk yang selesai",
    Icon: CalendarDays,
    emptyTitle: "Belum ada jadwal hari ini",
    emptySub: "Tambahkan jadwal untuk sesi imunisasi hari ini.",
    showAddBtn: true,
    colors: {
      activeBg: "bg-blue-50",
      activeBorder: "border-blue-400",
      activeRing: "ring-blue-200",
      iconText: "text-blue-600",
      labelText: "text-blue-800",
      badgeBg: "bg-blue-600",
      badgeText: "text-blue-50",
      inactiveBg: "bg-blue-50/40",
      inactiveBorder: "border-blue-200",
      inactiveIcon: "text-blue-400",
      inactiveLabel: "text-blue-600",
      inactiveBadgeBg: "bg-blue-100",
      inactiveBadgeText: "text-blue-500",
    },
  },
  {
    key: "upcoming",
    label: "Akan Datang",
    sub: "Jadwal bulan ini & berikutnya",
    Icon: CalendarClock,
    emptyTitle: "Tidak ada jadwal mendatang",
    emptySub: "Jadwal baru yang ditambahkan akan muncul di sini.",
    showAddBtn: true,
    colors: {
      activeBg: "bg-amber-50",
      activeBorder: "border-amber-400",
      activeRing: "ring-amber-200",
      iconText: "text-amber-600",
      labelText: "text-amber-800",
      badgeBg: "bg-amber-500",
      badgeText: "text-amber-50",
      inactiveBg: "bg-amber-50/40",
      inactiveBorder: "border-amber-200",
      inactiveIcon: "text-amber-400",
      inactiveLabel: "text-amber-600",
      inactiveBadgeBg: "bg-amber-100",
      inactiveBadgeText: "text-amber-500",
    },
  },
  {
    key: "done",
    label: "Sudah Selesai",
    sub: "Riwayat layanan sebelum hari ini",
    Icon: CalendarCheck,
    emptyTitle: "Belum ada riwayat layanan",
    emptySub: "Jadwal yang sudah lewat akan tercatat di sini.",
    showAddBtn: false,
    colors: {
      activeBg: "bg-emerald-50",
      activeBorder: "border-emerald-400",
      activeRing: "ring-emerald-200",
      iconText: "text-emerald-600",
      labelText: "text-emerald-800",
      badgeBg: "bg-emerald-600",
      badgeText: "text-emerald-50",
      inactiveBg: "bg-emerald-50/40",
      inactiveBorder: "border-emerald-200",
      inactiveIcon: "text-emerald-400",
      inactiveLabel: "text-emerald-600",
      inactiveBadgeBg: "bg-emerald-100",
      inactiveBadgeText: "text-emerald-500",
    },
  },
];

// ─── sub-components ─────────────────────────────────────────────────────────

function TabButton({ tab, active, count, onClick }) {
  const { label, sub, Icon, colors } = tab;
  return (
    <button
      onClick={onClick}
      className={`flex flex-col items-start px-3 py-2 sm:px-4 sm:py-3 rounded-2xl border transition-all text-left flex-1 basis-0 min-w-0 ${
        active
          ? `${colors.activeBorder} ${colors.activeBg} ring-2 ring-offset-1 ${colors.activeRing}`
          : `${colors.inactiveBorder} ${colors.inactiveBg}`
      }`}
    >
      <div className="flex items-center gap-1.5 sm:gap-2">
        <Icon
          size={14}
          className={`flex-shrink-0 sm:w-4 sm:h-4 ${active ? colors.iconText : colors.inactiveIcon}`}
        />
        <span
          className={`text-xs sm:text-sm font-semibold ${
            active ? colors.labelText : colors.inactiveLabel
          }`}
        >
          {label}
        </span>
        <span
          className={`inline-flex items-center justify-center min-w-[18px] h-[18px] sm:min-w-[20px] sm:h-5 px-1 sm:px-1.5 rounded-full text-[10px] sm:text-xs font-semibold ${
            active
              ? `${colors.badgeBg} ${colors.badgeText}`
              : `${colors.inactiveBadgeBg} ${colors.inactiveBadgeText}`
          }`}
        >
          {count}
        </span>
      </div>
      <span className={`text-[10px] sm:text-xs mt-0.5 sm:mt-1 pl-[22px] sm:pl-6 ${active ? "text-slate-500" : "text-slate-400"}`}>{sub}</span>
    </button>
  );
}

function LoadingState() {
  return (
    <div className="flex flex-col items-center justify-center py-16 gap-3">
      <div className="w-8 h-8 rounded-full border-2 border-[#185FA5]/20 border-t-[#185FA5] animate-spin" />
      <p className="text-sm text-slate-500 font-medium">
        Memuat jadwal layanan...
      </p>
      <p className="text-xs text-slate-300">Mohon tunggu sebentar</p>
    </div>
  );
}

function EmptyState({ tab, onAdd }) {
  return (
    <div className="flex flex-col items-center justify-center py-16 gap-3">
      <div className="w-12 h-12 rounded-2xl bg-slate-100 flex items-center justify-center">
        <CalendarOff size={22} className="text-slate-300" />
      </div>
      <div className="text-center">
        <p className="text-sm font-semibold text-slate-600">{tab.emptyTitle}</p>
        <p className="text-xs text-slate-400 mt-1 max-w-[220px] mx-auto">
          {tab.emptySub}
        </p>
      </div>
      {tab.showAddBtn && (
        <button
          onClick={onAdd}
          className="flex items-center gap-2 mt-1 px-4 py-2 bg-[#185FA5] text-white text-xs font-semibold rounded-xl"
        >
          <Plus size={14} />
          Tambah Jadwal
        </button>
      )}
    </div>
  );
}

function ScheduleRow({ r, onEdit, onDelete, deleting }) {
  const { day, num, mon } = formatDateParts(r.tanggal);
  const color = getLayananColor(r.layanan);
  const done = isDone(r);
  const today = isToday(r.tanggal);
  const upcoming = !done && !today && isUpcoming(r.tanggal);
  const waktuMulai = normalizeTimeValue(r.waktu_mulai || r.waktu);
  const waktuSelesai = normalizeTimeValue(r.waktu_selesai);
  const dosisVaksins = r.dosis_vaksins || [];

  // Determine card styling based on status
  let cardBg = "bg-white";
  let cardBorder = "border-slate-200";
  
  if (today) {
    cardBg = "bg-blue-50";
    cardBorder = "border-blue-200";
  } else if (done) {
    cardBg = "bg-emerald-50";
    cardBorder = "border-emerald-200";
  } else if (upcoming) {
    cardBg = "bg-amber-50";
    cardBorder = "border-amber-200";
  }

  return (
    <div className={`flex items-start sm:items-center gap-2 sm:gap-3 px-3 sm:px-5 py-3 sm:py-4 rounded-xl border ${cardBorder} ${cardBg} shadow-sm mb-3 last:mb-0 transition-all hover:shadow-md`}>
      {/* Date box */}
      <div className="min-w-[48px] sm:min-w-[60px] text-center bg-slate-50 rounded-xl py-1.5 sm:py-2 px-1 border border-slate-100 shrink-0">
        <p className="text-[9px] sm:text-[10px] text-slate-400 capitalize">{day}</p>
        <p className="text-base sm:text-xl font-bold text-slate-800 leading-tight">{num}</p>
        <p className="text-[9px] sm:text-[10px] text-slate-400 capitalize">{mon}</p>
      </div>

      {/* Info */}
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-1.5 sm:gap-2 flex-wrap">
          <span
            className={`text-[10px] sm:text-xs font-semibold px-1.5 sm:px-2 py-0.5 rounded-lg ${color.bg} ${color.text}`}
          >
            {r.layanan || "-"}
          </span>
          {done ? (
            <span
              className={`text-[10px] sm:text-xs font-semibold px-1.5 sm:px-2 py-0.5 rounded-full ${getStatusBadgeClass(
                "done"
              )}`}
            >
              Selesai
            </span>
          ) : today ? (
            <span
              className={`inline-flex items-center gap-1 text-[10px] sm:text-xs font-semibold px-1.5 sm:px-2 py-0.5 rounded-full ${getStatusBadgeClass(
                "today"
              )}`}
            >
              <span className="w-1.5 h-1.5 rounded-full bg-sky-500" />
              Hari Ini
            </span>
          ) : upcoming ? (
            <span
              className={`inline-flex items-center gap-1 text-[10px] sm:text-xs font-semibold px-1.5 sm:px-2 py-0.5 rounded-full ${getStatusBadgeClass(
                "upcoming"
              )}`}
            >
              <span className="w-1.5 h-1.5 rounded-full bg-amber-500 animate-pulse" />
              Mendatang
            </span>
          ) : (
            <span className="text-[10px] sm:text-xs text-slate-600 bg-slate-100 px-1.5 sm:px-2 py-0.5 rounded-full border border-slate-200">
              Selesai
            </span>
          )}
        </div>

        {/* Dosis Vaksin chips */}
        {dosisVaksins.length > 0 && (
          <div className="flex items-center gap-1 sm:gap-1.5 mt-1 sm:mt-1.5 flex-wrap">
            <Syringe size={10} className="text-slate-400 flex-shrink-0" />
            {dosisVaksins.map(d => (
              <span
                key={d.id}
                className="text-[10px] sm:text-xs px-1 sm:px-1.5 py-0.5 bg-[#185FA5]/5 text-[#185FA5] rounded-full max-w-[130px] sm:max-w-none truncate"
              >
                {d.Vaksin?.nama} - {d.nama_dosis}
              </span>
            ))}
          </div>
        )}
        
        <div className="flex items-center gap-2 sm:gap-3 mt-1 sm:mt-1.5 text-[10px] sm:text-xs text-slate-400 flex-wrap">
          <span className="flex items-center gap-0.5 sm:gap-1">
            <Clock size={10} className="flex-shrink-0" />
            {waktuMulai || "-"}
            {waktuSelesai ? ` - ${waktuSelesai}` : ""}
          </span>
          {(r.posyandu?.nama || r.posyandu_id) && (
            <span className="flex items-center gap-0.5 sm:gap-1 max-w-[100px] sm:max-w-none">
              <MapPin size={10} className="flex-shrink-0" />
              <span className="truncate">{r.posyandu?.nama || `Posyandu #${r.posyandu_id}`}</span>
            </span>
          )}
        </div>
        {r.keterangan && (
          <p className="text-[10px] sm:text-xs text-slate-400 mt-1 line-clamp-1 italic">
            {r.keterangan}
          </p>
        )}
      </div>

      {/* Actions */}
      <div className="flex flex-col sm:flex-row items-center gap-0.5 sm:gap-1 shrink-0">
        <button
          onClick={() => onEdit(r.id)}
          className="p-1.5 sm:p-2 text-slate-400 hover:text-[#185FA5] hover:bg-[#185FA5]/10 rounded-lg transition-colors"
          title="Edit jadwal"
        >
          <Pencil size={14} />
        </button>
        <button
          onClick={() => onDelete(r.id)}
          disabled={deleting === r.id}
          className="p-1.5 sm:p-2 text-slate-400 hover:text-[#A32D2D] hover:bg-[#A32D2D]/10 rounded-lg transition-colors disabled:opacity-40"
          title="Hapus jadwal"
        >
          {deleting === r.id ? (
            <RefreshCw size={14} className="animate-spin" />
          ) : (
            <Trash2 size={14} />
          )}
        </button>
      </div>
    </div>
  );
}

// ─── main page ───────────────────────────────────────────────────────────────

export default function JadwalLayananPage() {
  const [allRows, setAllRows] = useState([]);
  const [loading, setLoading] = useState(false);
  const [tabLoading, setTabLoading] = useState(false);
  const [error, setError] = useState("");
  const [deleting, setDeleting] = useState(null);
  const [activeTab, setActiveTab] = useState("today");
  const navigate = useNavigate();

  const loadData = useCallback(async () => {
    setLoading(true);
    setError("");
    try {
      const data = await getJadwalLayananList();
      let rows = [];
      if (Array.isArray(data)) rows = data;
      else if (Array.isArray(data?.data)) rows = data.data;
      else if (Array.isArray(data?.items)) rows = data.items;
      else rows = [];

      rows = rows
        .map((r) => ({ ...r }))
        .sort((a, b) => {
          const dateA = getDateKey(a.tanggal) || "0000-00-00";
          const dateB = getDateKey(b.tanggal) || "0000-00-00";
          if (dateA !== dateB) return dateA.localeCompare(dateB);

          const timeA = normalizeTimeValue(a.waktu_mulai || a.waktu) || "00:00";
          const timeB = normalizeTimeValue(b.waktu_mulai || b.waktu) || "00:00";
          return timeA.localeCompare(timeB);
        });

      setAllRows(rows);
    } catch (err) {
      setError("Gagal memuat jadwal layanan. Periksa koneksi dan coba lagi.");
      
      // SweetAlert2 untuk error loading
      Swal.fire({
        icon: "error",
        title: "Gagal Memuat Data",
        text: "Tidak dapat memuat jadwal layanan. Silakan periksa koneksi internet Anda.",
        confirmButtonText: "OK",
        confirmButtonColor: "#185FA5",
        background: "#fff",
        backdrop: `rgba(0,0,0,0.4)`,
      });
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadData();
  }, [loadData]);

  const handleTabChange = (key) => {
    if (key === activeTab) return;
    setTabLoading(true);
    setActiveTab(key);
    setTimeout(() => setTabLoading(false), 350);
  };

  const handleDelete = async (id) => {
    // SweetAlert2 untuk konfirmasi delete
    const result = await Swal.fire({
      title: "Hapus Jadwal Layanan?",
      text: "Data yang sudah dihapus tidak dapat dikembalikan!",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#A32D2D",
      cancelButtonColor: "#6B7280",
      confirmButtonText: "Ya, Hapus!",
      cancelButtonText: "Batal",
      background: "#fff",
      backdrop: `rgba(0,0,0,0.4)`,
      customClass: {
        popup: "rounded-2xl",
        confirmButton: "rounded-xl px-5 py-2.5 font-semibold",
        cancelButton: "rounded-xl px-5 py-2.5 font-semibold",
      },
    });

    if (!result.isConfirmed) return;

    setDeleting(id);
    try {
      await deleteJadwalLayanan(id);
      setAllRows((prev) => prev.filter((r) => r.id !== id));
      
      // SweetAlert2 untuk sukses delete
      Swal.fire({
        icon: "success",
        title: "Berhasil Dihapus!",
        text: "Jadwal layanan telah dihapus dari sistem.",
        timer: 2000,
        showConfirmButton: false,
        background: "#fff",
        backdrop: `rgba(0,0,0,0.4)`,
        customClass: {
          popup: "rounded-2xl",
        },
      });
    } catch (err) {
      // SweetAlert2 untuk error delete
      Swal.fire({
        icon: "error",
        title: "Gagal Menghapus",
        text: "Terjadi kesalahan saat menghapus jadwal layanan. Silakan coba lagi.",
        confirmButtonText: "OK",
        confirmButtonColor: "#185FA5",
        background: "#fff",
        backdrop: `rgba(0,0,0,0.4)`,
        customClass: {
          popup: "rounded-2xl",
          confirmButton: "rounded-xl px-5 py-2.5 font-semibold",
        },
      });
    } finally {
      setDeleting(null);
    }
  };

  const todayRows = allRows.filter((r) => isToday(r.tanggal));
  const upcomingRows = allRows.filter(
    (r) => !isDone(r) && !isToday(r.tanggal) && isUpcoming(r.tanggal)
  );
  const doneRows = allRows.filter((r) => isPast(r.tanggal));

  const tabCounts = { today: todayRows.length, upcoming: upcomingRows.length, done: doneRows.length };
  const filteredRows = { today: todayRows, upcoming: upcomingRows, done: doneRows }[activeTab];
  const currentTab = TABS.find((t) => t.key === activeTab);

  return (
    <MainLayout>
      <div className="space-y-4 sm:space-y-5">
        {/* Tabs & Tombol Tambah Jadwal dalam satu baris */}
        <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-2 sm:gap-3">
          {/* Tab Buttons */}
          <div className="flex gap-2 sm:gap-3 flex-1">
            {TABS.map((tab) => (
              <TabButton
                key={tab.key}
                tab={tab}
                active={activeTab === tab.key}
                count={tabCounts[tab.key]}
                onClick={() => handleTabChange(tab.key)}
              />
            ))}
          </div>

          {/* Tombol Tambah Jadwal */}
          <button
            onClick={() => navigate("/jadwal-layanan/form")}
            className="flex items-center gap-1.5 sm:gap-2 px-3 py-2 sm:px-4 sm:py-2.5 bg-[#185FA5] hover:bg-[#0e4a84] text-white text-xs sm:text-sm font-semibold rounded-xl transition-colors shadow-sm justify-center whitespace-nowrap"
          >
            <Plus size={14} />
            Tambah Jadwal
          </button>
        </div>

        {/* Daftar jadwal */}
        <section className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
          {loading || tabLoading ? (
            <LoadingState />
          ) : error ? (
            <div className="flex flex-col items-center justify-center py-14 gap-3 px-4">
              <div className="w-12 h-12 rounded-full bg-red-50 flex items-center justify-center">
                <AlertCircle size={20} className="text-[#A32D2D]" />
              </div>
              <p className="text-sm text-[#A32D2D] font-medium text-center">{error}</p>
              <button
                onClick={loadData}
                className="flex items-center gap-2 px-4 py-2 text-sm text-[#185FA5] border border-[#185FA5]/30 rounded-lg hover:bg-[#185FA5]/5"
              >
                <RefreshCw size={13} />
                Coba Lagi
              </button>
            </div>
          ) : filteredRows.length === 0 ? (
            <EmptyState
              tab={currentTab}
              onAdd={() => navigate("/jadwal-layanan/form")}
            />
          ) : (
            <>
              <div className="p-3 sm:p-4">
                {filteredRows.map((r) => (
                  <ScheduleRow
                    key={r.id}
                    r={r}
                    onEdit={(id) => navigate(`/jadwal-layanan/form/${id}`)}
                    onDelete={handleDelete}
                    deleting={deleting}
                  />
                ))}
              </div>
              <div className="px-4 sm:px-5 py-3 border-t border-slate-100 bg-slate-50/50">
                <p className="text-[10px] sm:text-xs text-slate-400">
                  Menampilkan {filteredRows.length} jadwal • {currentTab.label}
                </p>
              </div>
            </>
          )}
        </section>
      </div>
    </MainLayout>
  );
}