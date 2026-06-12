import React, { useEffect, useState, useCallback } from "react";
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
  },
  {
    key: "upcoming",
    label: "Akan Datang",
    sub: "Jadwal bulan ini & berikutnya",
    Icon: CalendarClock,
    emptyTitle: "Tidak ada jadwal mendatang",
    emptySub: "Jadwal baru yang ditambahkan akan muncul di sini.",
    showAddBtn: true,
  },
  {
    key: "done",
    label: "Sudah Selesai",
    sub: "Riwayat layanan sebelum hari ini",
    Icon: CalendarCheck,
    emptyTitle: "Belum ada riwayat layanan",
    emptySub: "Jadwal yang sudah lewat akan tercatat di sini.",
    showAddBtn: false,
  },
];

// ─── sub-components ─────────────────────────────────────────────────────────

function TabButton({ tab, active, count, onClick }) {
  const { label, sub, Icon } = tab;
  return (
    <button
      onClick={onClick}
      className={`flex flex-col items-start px-4 py-3 rounded-2xl border transition-all text-left ${
        active
          ? "border-[#185FA5] bg-[#E6F1FB]"
          : "border-slate-200 bg-white hover:bg-slate-50"
      }`}
    >
      <div className="flex items-center gap-2">
        <Icon
          size={16}
          className={active ? "text-[#185FA5]" : "text-slate-400"}
        />
        <span
          className={`text-sm font-semibold ${
            active ? "text-[#0C447C]" : "text-slate-700"
          }`}
        >
          {label}
        </span>
        <span
          className={`inline-flex items-center justify-center min-w-[20px] h-5 px-1.5 rounded-full text-xs font-semibold ${
            active
              ? "bg-[#185FA5] text-[#E6F1FB]"
              : "bg-slate-100 text-slate-500"
          }`}
        >
          {count}
        </span>
      </div>
      <span className="text-xs text-slate-400 mt-1 pl-6">{sub}</span>
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

  return (
    <div className="flex items-center gap-3 px-5 py-4 border-b border-slate-50 last:border-0 hover:bg-slate-50/60 transition-colors">
      {/* Date box */}
      <div className="min-w-[60px] text-center bg-slate-50 rounded-xl py-2 px-1 border border-slate-100 shrink-0">
        <p className="text-[10px] text-slate-400 capitalize">{day}</p>
        <p className="text-xl font-bold text-slate-800 leading-tight">{num}</p>
        <p className="text-[10px] text-slate-400 capitalize">{mon}</p>
      </div>

      {/* Info */}
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2 flex-wrap">
          <span
            className={`text-xs font-semibold px-2 py-0.5 rounded-lg ${color.bg} ${color.text}`}
          >
            {r.layanan || "-"}
          </span>
          {done ? (
            <span
              className={`text-xs font-semibold px-2 py-0.5 rounded-full ${getStatusBadgeClass(
                "done"
              )}`}
            >
              Selesai
            </span>
          ) : today ? (
            <span
              className={`inline-flex items-center gap-1 text-xs font-semibold px-2 py-0.5 rounded-full ${getStatusBadgeClass(
                "today"
              )}`}
            >
              <span className="w-1.5 h-1.5 rounded-full bg-sky-500" />
              Hari Ini
            </span>
          ) : upcoming ? (
            <span
              className={`inline-flex items-center gap-1 text-xs font-semibold px-2 py-0.5 rounded-full ${getStatusBadgeClass(
                "upcoming"
              )}`}
            >
              <span className="w-1.5 h-1.5 rounded-full bg-amber-500 animate-pulse" />
              Mendatang
            </span>
          ) : (
            <span className="text-xs text-slate-600 bg-slate-100 px-2 py-0.5 rounded-full border border-slate-200">
              Selesai
            </span>
          )}
        </div>

        {/* Dosis Vaksin chips */}
        {dosisVaksins.length > 0 && (
          <div className="flex items-center gap-1.5 mt-1.5 flex-wrap">
            <Syringe size={11} className="text-slate-400" />
            {dosisVaksins.map(d => (
              <span
                key={d.id}
                className="text-xs px-1.5 py-0.5 bg-[#185FA5]/5 text-[#185FA5] rounded-full"
              >
                {d.Vaksin?.nama} - {d.nama_dosis}
              </span>
            ))}
          </div>
        )}
        
        <div className="flex items-center gap-3 mt-1.5 text-xs text-slate-400 flex-wrap">
          <span className="flex items-center gap-1">
            <Clock size={11} />
            {waktuMulai || "-"}
            {waktuSelesai ? ` - ${waktuSelesai}` : ""}
          </span>
          {(r.posyandu?.nama || r.posyandu_id) && (
            <span className="flex items-center gap-1">
              <MapPin size={11} />
              {r.posyandu?.nama || `Posyandu #${r.posyandu_id}`}
            </span>
          )}
        </div>
        {r.keterangan && (
          <p className="text-xs text-slate-400 mt-1 line-clamp-1 italic">
            {r.keterangan}
          </p>
        )}
      </div>

      {/* Actions */}
      <div className="flex items-center gap-1 shrink-0">
        <button
          onClick={() => onEdit(r.id)}
          className="p-2 text-slate-400 hover:text-[#185FA5] hover:bg-[#185FA5]/10 rounded-lg transition-colors"
          title="Edit jadwal"
        >
          <Pencil size={14} />
        </button>
        <button
          onClick={() => onDelete(r.id)}
          disabled={deleting === r.id}
          className="p-2 text-slate-400 hover:text-[#A32D2D] hover:bg-[#A32D2D]/10 rounded-lg transition-colors disabled:opacity-40"
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
    } catch {
      setError("Gagal memuat jadwal layanan. Periksa koneksi dan coba lagi.");
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
    if (!window.confirm("Hapus jadwal layanan ini?")) return;
    setDeleting(id);
    try {
      await deleteJadwalLayanan(id);
      setAllRows((prev) => prev.filter((r) => r.id !== id));
    } catch {
      alert("Gagal menghapus jadwal layanan.");
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
      <div className="space-y-5">
        {/* Header */}
        <section className="bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-sm">
          <div className="flex items-center justify-between px-6 py-5">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-[#185FA5]/10 flex items-center justify-center">
                <CalendarDays size={20} className="text-[#185FA5]" />
              </div>
              <div>
                <div className="flex items-center gap-2 flex-wrap">
                  <h1 className="text-xl font-bold text-slate-800 leading-tight">
                    Jadwal Layanan Imunisasi
                  </h1>
                </div>
                <p className="text-sm text-slate-400 mt-0.5">
                  Kelola sesi posyandu — Dashboard Bidan
                </p>
              </div>
            </div>
            <button
              onClick={() => navigate("/jadwal-layanan/form")}
              className="flex items-center gap-2 px-4 py-2.5 bg-[#185FA5] hover:bg-[#0e4a84] text-white text-sm font-semibold rounded-xl transition-colors"
            >
              <Plus size={16} />
              Tambah Jadwal
            </button>
          </div>

          {/* Stats bar */}
          {!loading && allRows.length > 0 && (
            <div className="grid grid-cols-3 divide-x divide-slate-100 border-t border-slate-100">
              <div className="px-6 py-3 text-center">
                <p className="text-2xl font-bold text-slate-800">{allRows.length}</p>
                <p className="text-xs text-slate-400 mt-0.5">Total jadwal</p>
              </div>
              <div className="px-6 py-3 text-center">
                <p className="text-2xl font-bold text-[#185FA5]">{tabCounts.today}</p>
                <p className="text-xs text-slate-400 mt-0.5">Jadwal hari ini</p>
              </div>
              <div className="px-6 py-3 text-center">
                <p className="text-2xl font-bold text-slate-500">{tabCounts.upcoming}</p>
                <p className="text-xs text-slate-400 mt-0.5">Akan datang</p>
              </div>
            </div>
          )}
        </section>

        {/* Tabs */}
        <div className="flex gap-3 flex-wrap">
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

        {/* Daftar jadwal */}
        <section className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
          {loading || tabLoading ? (
            <LoadingState />
          ) : error ? (
            <div className="flex flex-col items-center justify-center py-14 gap-3">
              <div className="w-12 h-12 rounded-full bg-red-50 flex items-center justify-center">
                <AlertCircle size={20} className="text-[#A32D2D]" />
              </div>
              <p className="text-sm text-[#A32D2D] font-medium">{error}</p>
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
              <div>
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
              <div className="px-5 py-3 border-t border-slate-100 bg-slate-50/50">
                <p className="text-xs text-slate-400">
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