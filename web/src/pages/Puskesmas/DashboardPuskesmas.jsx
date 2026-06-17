import React, { useEffect, useState, useCallback } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import { getCurrentUser, isDokterUser } from "../../services/auth";
import { getPuskesmasDashboard } from "../../services/puskesmasDashboard";
import {
  Building2,
  Users,
  Baby,
  HeartPulse,
  Activity,
  TrendingUp,
  AlertTriangle,
  MapPin,
  CalendarDays,
  Syringe,
  ShieldCheck,
  Stethoscope,
  RefreshCw,
} from "lucide-react";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from "recharts";

/* ─── helper: colour by coverage % ─── */
const coverageColor = (pct) => {
  if (pct >= 80) return { bar: "bg-emerald-500", text: "text-emerald-700", bg: "bg-emerald-50" };
  if (pct >= 60) return { bar: "bg-amber-500", text: "text-amber-700", bg: "bg-amber-50" };
  return { bar: "bg-red-500", text: "text-red-700", bg: "bg-red-50" };
};

const statusBadge = (status) => {
  const map = {
    Baik: "bg-emerald-100 text-emerald-700",
    "Perlu Ditingkatkan": "bg-amber-100 text-amber-700",
    Intervensi: "bg-red-100 text-red-700",
  };
  return map[status] || "bg-gray-100 text-gray-600";
};

const prioritasBadge = (p) => {
  if (p === "Tinggi") return "bg-red-100 text-red-700 border-red-200";
  return "bg-amber-100 text-amber-700 border-amber-200";
};

const tipeIcon = (tipe) => {
  switch (tipe) {
    case "kehamilan_risiko":
      return <HeartPulse className="w-4 h-4 text-rose-500" />;
    case "stunting":
      return <Baby className="w-4 h-4 text-orange-500" />;
    case "rujukan":
      return <AlertTriangle className="w-4 h-4 text-blue-500" />;
    default:
      return <Activity className="w-4 h-4 text-gray-500" />;
  }
};

/* ═══════════════════════════════════════════ */
/*                MAIN COMPONENT               */
/* ═══════════════════════════════════════════ */
const DashboardPuskesmas = () => {
  const [user, setUser] = useState(null);
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const fetchData = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const result = await getPuskesmasDashboard();
      setData(result);
    } catch (err) {
      console.error("Gagal memuat dashboard puskesmas:", err);
      setError("Gagal memuat data dashboard. Pastikan server backend berjalan.");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    setUser(getCurrentUser());
    fetchData();
  }, [fetchData]);

  const isDokter = isDokterUser(user);

  /* ─── Loading / Error states ─── */
  if (loading) {
    return (
      <MainLayout>
        <div className="flex items-center justify-center h-[60vh]">
          <div className="text-center">
            <RefreshCw className="w-8 h-8 animate-spin text-blue-600 mx-auto mb-3" />
            <p className="text-gray-500 text-sm">Memuat data dashboard...</p>
          </div>
        </div>
      </MainLayout>
    );
  }

  if (error) {
    return (
      <MainLayout>
        <div className="flex items-center justify-center h-[60vh]">
          <div className="bg-white rounded-xl shadow-sm border border-red-200 p-8 max-w-md text-center">
            <AlertTriangle className="w-10 h-10 text-red-500 mx-auto mb-3" />
            <h3 className="font-semibold text-gray-800 mb-1">Gagal Memuat Data</h3>
            <p className="text-gray-500 text-sm mb-4">{error}</p>
            <button
              onClick={fetchData}
              className="px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors"
            >
              Coba Lagi
            </button>
          </div>
        </div>
      </MainLayout>
    );
  }

  const overall = data?.overall || {};
  const desaList = data?.desa_list || [];
  const trenBulanan = data?.tren_bulanan || [];
  const kasusPrioritas = data?.kasus_prioritas || [];

  /* ─── chart data ─── */
  const chartData = trenBulanan.map((t) => ({
    bulan: t.bulan,
    "Kasus Baru": t.kasus_baru_masuk,
    "Rujukan": t.rujukan_ditangani,
  }));

  return (
    <MainLayout>
      <div className="p-6 bg-gray-50 min-h-screen">
        {/* ═══════ HEADER ═══════ */}
        <div className="mb-6 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
          <div className="flex items-center gap-3">
            <div className="p-3 rounded-xl bg-blue-100 text-blue-700">
              <Building2 className="w-7 h-7" />
            </div>
            <div>
              <h1 className="text-2xl font-bold text-gray-800">
                Pemantauan Wilayah Kecamatan
              </h1>
              <p className="text-gray-500 text-sm flex items-center gap-1">
                <MapPin className="w-3.5 h-3.5" />
                {data?.kecamatan || "Semua Kecamatan"}
                <span className="mx-1.5 text-gray-300">|</span>
                <CalendarDays className="w-3.5 h-3.5" />
                {data?.periode || "Periode saat ini"}
              </p>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <span className="text-xs text-gray-400">
              Login sebagai:{" "}
              <span className="font-medium text-gray-600">
                {user?.nama || user?.name || user?.role || "User"}
              </span>
              {!isDokter ? " (Bidan Puskesmas)" : " (Dokter)"}
            </span>
            <button
              onClick={fetchData}
              className="p-2 rounded-lg hover:bg-gray-200 transition-colors"
              title="Refresh data"
            >
              <RefreshCw className="w-4 h-4 text-gray-500" />
            </button>
          </div>
        </div>

        {/* ═══════ KPI CARDS ═══════ */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5 mb-8">
          {/* Total Sasaran Aktif */}
          <KPICard
            icon={<Users className="w-6 h-6 text-blue-600" />}
            iconBg="bg-blue-100"
            label="Total Sasaran Aktif"
            value={overall.total_sasaran_aktif ?? 0}
            sub="Ibu & Anak"
            subColor="text-blue-600"
          />
          {/* Cakupan Layanan Rata-rata */}
          <KPICard
            icon={<ShieldCheck className="w-6 h-6 text-emerald-600" />}
            iconBg="bg-emerald-100"
            label="Cakupan Layanan"
            value={`${(overall.cakupan_layanan_rata_rata ?? 0).toFixed(1)}%`}
            sub={
              (overall.cakupan_layanan_rata_rata ?? 0) >= 80
                ? "Mencapai Target"
                : "Perlu Peningkatan"
            }
            subColor={
              (overall.cakupan_layanan_rata_rata ?? 0) >= 80
                ? "text-emerald-600"
                : "text-amber-600"
            }
          />
          {/* Desa Perlu Intervensi */}
          <KPICard
            icon={<AlertTriangle className="w-6 h-6 text-red-600" />}
            iconBg="bg-red-100"
            label="Desa Perlu Intervensi"
            value={overall.desa_perlu_intervensi ?? 0}
            sub="Cakupan < 60%"
            subColor="text-red-500"
          />
          {/* Kasus Rujukan Aktif */}
          <KPICard
            icon={<Activity className="w-6 h-6 text-orange-600" />}
            iconBg="bg-orange-100"
            label="Kasus Rujukan Aktif"
            value={overall.kasus_rujukan_aktif ?? 0}
            sub="Perhatian"
            subColor="text-orange-600"
          />
        </div>

        {/* ═══════ DUA KOLOM: Performa Desa + Statistik Keseluruhan ═══════ */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
          {/* ── Performa per Desa ── */}
          <div className="lg:col-span-2 bg-white rounded-xl shadow-sm border border-gray-100 p-5">
            <h2 className="text-lg font-semibold text-gray-800 mb-4 flex items-center gap-2">
              <TrendingUp className="w-5 h-5 text-blue-600" />
              Performa per Desa — Bulan Ini
            </h2>

            {desaList.length === 0 ? (
              <EmptyState text="Belum ada data desa aktif yang dipantau." />
            ) : (
              <div className="space-y-5">
                {desaList.map((desa) => {
                  const c = coverageColor(desa.cakupan_layanan);
                  return (
                    <div key={desa.desa_id}>
                      {/* Nama desa & bidan */}
                      <div className="flex items-center justify-between mb-1.5">
                        <div>
                          <span className="font-medium text-gray-800">
                            Desa {desa.nama_desa}
                          </span>
                          <span className="text-xs text-gray-400 ml-2">
                            {desa.total_bidan} bidan aktif
                          </span>
                        </div>
                        <span
                          className={`text-xs font-semibold px-2.5 py-0.5 rounded-full ${statusBadge(desa.status_cakupan)}`}
                        >
                          {desa.status_cakupan}
                        </span>
                      </div>

                      {/* Bar */}
                      <div className="flex items-center gap-3">
                        <div className="flex-1 h-3 bg-gray-100 rounded-full overflow-hidden">
                          <div
                            className={`h-full rounded-full transition-all duration-500 ${c.bar}`}
                            style={{ width: `${Math.min(desa.cakupan_layanan, 100)}%` }}
                          />
                        </div>
                        <span className={`text-sm font-bold min-w-[3.2rem] text-right ${c.text}`}>
                          {desa.cakupan_layanan.toFixed(1)}%
                        </span>
                      </div>

                      {/* Sub-stats */}
                      <div className="flex gap-4 mt-1.5 text-xs text-gray-500">
                        <span>Penduduk: <b>{desa.total_penduduk}</b></span>
                        <span>Ibu: <b>{desa.total_ibu}</b></span>
                        <span>Hamil: <b>{desa.total_ibu_hamil}</b></span>
                        <span>Anak: <b>{desa.total_anak}</b></span>
                        <span>Balita: <b>{desa.total_balita}</b></span>
                        <span>Rujukan: <b>{desa.total_rujukan}</b></span>
                        {desa.stunting_risk > 0 && (
                          <span className="text-orange-600">
                            Stunting Risk: <b>{desa.stunting_risk}</b>
                          </span>
                        )}
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>

          {/* ── Statistik Keseluruhan ── */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
            <h2 className="text-lg font-semibold text-gray-800 mb-4 flex items-center gap-2">
              <Building2 className="w-5 h-5 text-purple-600" />
              Statistik Keseluruhan
            </h2>

            <div className="space-y-4">
              <StatRow icon={<Users className="w-4 h-4" />} label="Total Penduduk" value={overall.total_penduduk ?? 0} />
              <StatRow icon={<Users className="w-4 h-4" />} label="Total Ibu" value={overall.total_ibu ?? 0} />
              <StatRow icon={<HeartPulse className="w-4 h-4" />} label="Ibu Hamil Aktif" value={overall.total_ibu_hamil ?? 0} />
              <StatRow icon={<Baby className="w-4 h-4" />} label="Total Anak" value={overall.total_anak ?? 0} />
              <StatRow icon={<Baby className="w-4 h-4" />} label="Total Balita" value={overall.total_balita ?? 0} />
              <StatRow icon={<Activity className="w-4 h-4" />} label="Sasaran Aktif (Ibu+Anak)" value={overall.total_sasaran_aktif ?? 0} />
              <StatRow icon={<AlertTriangle className="w-4 h-4" />} label="Rujukan Aktif" value={overall.kasus_rujukan_aktif ?? 0} />

              <div className="pt-3 border-t border-gray-100">
                <p className="text-xs text-gray-400 mb-2">Distribusi Cakupan</p>
                <div className="flex items-center gap-2">
                  <div className="flex-1 h-4 bg-gray-100 rounded-full overflow-hidden flex">
                    {desaList.map((d, i) => {
                      const total = desaList.reduce((s, x) => s + x.total_penduduk, 0) || 1;
                      const w = (d.total_penduduk / total) * 100;
                      const c = coverageColor(d.cakupan_layanan);
                      return (
                        <div
                          key={d.desa_id}
                          className={`h-full ${c.bar}`}
                          style={{ width: `${w}%` }}
                          title={`${d.nama_desa}: ${d.cakupan_layanan.toFixed(1)}%`}
                        />
                      );
                    })}
                  </div>
                </div>
                <div className="flex gap-3 mt-2 text-xs text-gray-500">
                  {desaList.map((d) => (
                    <span key={d.desa_id} className="flex items-center gap-1">
                      <span
                        className={`inline-block w-2.5 h-2.5 rounded-full ${coverageColor(d.cakupan_layanan).bar}`}
                      />
                      {d.nama_desa}
                    </span>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* ═══════ DUA KOLOM: Tren Bulanan + Kasus Prioritas ═══════ */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
          {/* ── Tren Kasus & Rujukan ── */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
            <h2 className="text-lg font-semibold text-gray-800 mb-4 flex items-center gap-2">
              <TrendingUp className="w-5 h-5 text-emerald-600" />
              Tren Kasus & Rujukan
              <span className="text-xs font-normal text-gray-400 ml-auto">6 Bulan Terakhir</span>
            </h2>

            {chartData.length === 0 ? (
              <EmptyState text="Belum ada data tren bulanan." />
            ) : (
              <ResponsiveContainer width="100%" height={280}>
                <LineChart data={chartData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                  <XAxis dataKey="bulan" tick={{ fontSize: 12 }} />
                  <YAxis tick={{ fontSize: 12 }} allowDecimals={false} />
                  <Tooltip />
                  <Legend />
                  <Line
                    type="monotone"
                    dataKey="Kasus Baru"
                    stroke="#f97316"
                    strokeWidth={2}
                    dot={{ r: 4 }}
                    activeDot={{ r: 6 }}
                  />
                  <Line
                    type="monotone"
                    dataKey="Rujukan"
                    stroke="#22c55e"
                    strokeWidth={2}
                    dot={{ r: 4 }}
                    activeDot={{ r: 6 }}
                  />
                </LineChart>
              </ResponsiveContainer>
            )}
          </div>

          {/* ── Kasus Prioritas ── */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
            <h2 className="text-lg font-semibold text-gray-800 mb-4 flex items-center gap-2">
              <AlertTriangle className="w-5 h-5 text-red-500" />
              Kasus Rujukan & Prioritas
            </h2>

            {kasusPrioritas.length === 0 ? (
              <EmptyState text="Tidak ada kasus prioritas saat ini." />
            ) : (
              <div className="space-y-3 max-h-[310px] overflow-y-auto pr-1">
                {kasusPrioritas.map((kasus, idx) => (
                  <div
                    key={`${kasus.tipe}-${kasus.id}-${idx}`}
                    className="border border-gray-100 rounded-lg p-3.5 hover:shadow-sm transition-shadow"
                  >
                    <div className="flex items-start gap-3">
                      <div className="mt-0.5">{tipeIcon(kasus.tipe)}</div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2 mb-0.5">
                          <span className="font-medium text-gray-800 text-sm truncate">
                            {kasus.nama}
                          </span>
                          <span
                            className={`text-[10px] font-semibold px-2 py-0.5 rounded-full border ${prioritasBadge(kasus.prioritas)}`}
                          >
                            {kasus.prioritas}
                          </span>
                        </div>
                        <p className="text-xs text-gray-500 mb-1">{kasus.deskripsi}</p>
                        <div className="flex items-center gap-2 text-xs text-gray-400">
                          <MapPin className="w-3 h-3" />
                          {kasus.desa}
                          <span className="ml-auto text-gray-500 font-medium">
                            {kasus.status}
                          </span>
                        </div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* ═══════ QUICK ACCESS ═══════ */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-4">
          <QuickAccessCard
            icon={<Syringe className="w-5 h-5 text-blue-600" />}
            title="Manajemen Vaksin & Dosis"
            desc="Kelola data vaksin dan dosis vaksin untuk pelayanan imunisasi."
            href="/puskesmas/kelola-vaksin"
            btnLabel="Kelola Vaksin"
            btnColor="bg-blue-600 hover:bg-blue-700"
          />
          <QuickAccessCard
            icon={<Stethoscope className="w-5 h-5 text-green-600" />}
            title="Dashboard Dokter"
            desc="Lihat jadwal pemeriksaan, pasien terbaru, dan data rujukan."
            href="/puskesmas/dashboard-dokter"
            btnLabel="Buka Dashboard Dokter"
            btnColor="bg-green-600 hover:bg-green-700"
          />
        </div>

        {/* Footer */}
        <p className="text-xs text-gray-400 text-center mt-6">
          Data diambil dari sistem manajemen kesehatan desa dan puskesmas.
          {data?.kecamatan || "Semua Kecamatan"} — {data?.periode || ""}.
        </p>
      </div>
    </MainLayout>
  );
};

/* ═══════════════════════════════════════════ */
/*              SUB-COMPONENTS                 */
/* ═══════════════════════════════════════════ */

const KPICard = ({ icon, iconBg, label, value, sub, subColor }) => (
  <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
    <div className="flex justify-between items-start">
      <div>
        <p className="text-gray-500 text-sm font-medium">{label}</p>
        <p className="text-2xl font-bold text-gray-800 mt-1">{value}</p>
        {sub && <p className={`text-xs mt-1 ${subColor || "text-gray-400"}`}>{sub}</p>}
      </div>
      <div className={`p-3 rounded-lg ${iconBg}`}>{icon}</div>
    </div>
  </div>
);

const StatRow = ({ icon, label, value }) => (
  <div className="flex items-center justify-between">
    <div className="flex items-center gap-2 text-gray-600 text-sm">
      <span className="text-gray-400">{icon}</span>
      {label}
    </div>
    <span className="font-semibold text-gray-800">{value}</span>
  </div>
);

const QuickAccessCard = ({ icon, title, desc, href, btnLabel, btnColor }) => (
  <div className="bg-white rounded-xl shadow-sm p-5 border border-gray-100">
    <h2 className="text-lg font-semibold text-gray-800 mb-2 flex items-center gap-2">
      {icon} {title}
    </h2>
    <p className="text-gray-500 text-sm mb-4">{desc}</p>
    <a
      href={href}
      className={`inline-flex items-center gap-2 px-4 py-2 text-white rounded-lg text-sm font-medium transition-colors ${btnColor}`}
    >
      {btnLabel}
    </a>
  </div>
);

const EmptyState = ({ text }) => (
  <div className="flex items-center justify-center py-10 text-gray-400 text-sm">
    <p>{text}</p>
  </div>
);

export default DashboardPuskesmas;
