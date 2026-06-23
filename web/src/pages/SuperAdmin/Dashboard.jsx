import React, { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import {
  Activity, Building2, Home, MapPinned, ShieldCheck, ShieldPlus,
  Users, UserCheck, UserCog, Stethoscope, RefreshCw, AlertTriangle, Layers3,
} from "lucide-react";
import {
  ResponsiveContainer, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Cell,
} from "recharts";
import { listDesa } from "../../services/desa";
import { listSuperadminUsers } from "../../services/superadminUsers";
import { listPendudukForDropdown } from "../../services/superadminPenduduk";
import { getAllPuskesmas } from "../../services/puskesmas";
import { getAllPosyandu } from "../../services/posyandu";
import { listProvinsi, listKabupaten, listKecamatan } from "../../services/wilayah";

const normalizeRole = (role) => (role || "").toString().toLowerCase().replace(/[\s_-]/g, "");

const BAR_COLORS = ["#0891b2", "#059669", "#d97706", "#7c3aed", "#db2777", "#2563eb"];

export default function SuperAdminDashboard() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [data, setData] = useState({
    desa: [], users: [], penduduk: [], puskesmas: [], posyandu: [],
    provinsi: [], kabupaten: [], kecamatan: [],
  });

  const fetchAll = async () => {
    try {
      setLoading(true);
      setError("");
      const [desa, users, penduduk, puskesmas, posyandu, provinsi, kabupaten, kecamatan] =
        await Promise.all([
          listDesa().catch(() => []),
          listSuperadminUsers().catch(() => []),
          listPendudukForDropdown().catch(() => []),
          getAllPuskesmas().catch(() => []),
          getAllPosyandu().catch(() => []),
          listProvinsi().catch(() => []),
          listKabupaten().catch(() => []),
          listKecamatan().catch(() => []),
        ]);
      setData({
        desa: Array.isArray(desa) ? desa : [],
        users: Array.isArray(users) ? users : [],
        penduduk: Array.isArray(penduduk) ? penduduk : [],
        puskesmas: Array.isArray(puskesmas) ? puskesmas : [],
        posyandu: Array.isArray(posyandu) ? posyandu : [],
        provinsi: Array.isArray(provinsi) ? provinsi : [],
        kabupaten: Array.isArray(kabupaten) ? kabupaten : [],
        kecamatan: Array.isArray(kecamatan) ? kecamatan : [],
      });
    } catch (err) {
      setError(err?.message || "Gagal memuat data dashboard");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAll();
  }, []);

  // ── Hitung statistik dari data nyata ──
  const computed = useMemo(() => {
    const { desa, users, penduduk, puskesmas, posyandu, provinsi, kabupaten, kecamatan } = data;

    const desaAktif = desa.filter((d) => d.is_active).length;

    const gender = penduduk.reduce(
      (acc, p) => {
        const jk = (p.jenis_kelamin || "").toLowerCase();
        if (jk.startsWith("l")) acc.lakiLaki += 1;
        else if (jk.startsWith("p")) acc.perempuan += 1;
        return acc;
      },
      { lakiLaki: 0, perempuan: 0 }
    );

    // Hitung nakes per role dari daftar user
    const roleCount = users.reduce((acc, u) => {
      const r = normalizeRole(u.role);
      acc[r] = (acc[r] || 0) + 1;
      return acc;
    }, {});
    const bidan = roleCount["bidan"] || 0;
    const kader = roleCount["kader"] || 0;
    const adminDesa = (roleCount["admin"] || 0) + (roleCount["admindesa"] || 0);
    const dokter = roleCount["dokter"] || 0;
    const totalNakes = bidan + kader + adminDesa + dokter;

    // Penduduk per desa (untuk tabel & chart)
    const desaNameById = new Map(desa.map((d) => [String(d.id), d.nama_desa]));
    const pendudukPerDesa = {};
    penduduk.forEach((p) => {
      const id = String(p.desa_id ?? p.desa?.id ?? "");
      const nama = p.desa?.nama_desa || desaNameById.get(id) || "Tanpa Desa";
      pendudukPerDesa[nama] = (pendudukPerDesa[nama] || 0) + 1;
    });

    // Nakes per desa (pakai desa_name dari user list bila ada)
    const nakesPerDesa = {};
    users.forEach((u) => {
      const r = normalizeRole(u.role);
      if (!["bidan", "kader", "admin", "admindesa"].includes(r)) return;
      const nama = u.desa_name || u.desaName || "Tanpa Desa";
      nakesPerDesa[nama] = (nakesPerDesa[nama] || 0) + 1;
    });

    const perDesa = desa
      .map((d) => ({
        id: d.id,
        nama: d.nama_desa,
        kecamatan: d.kecamatan || "-",
        is_active: d.is_active,
        penduduk: pendudukPerDesa[d.nama_desa] || 0,
        nakes: nakesPerDesa[d.nama_desa] || 0,
      }))
      .sort((a, b) => b.penduduk - a.penduduk);

    const chartData = perDesa.slice(0, 8).map((d) => ({ nama: d.nama, penduduk: d.penduduk }));

    return {
      totalDesa: desa.length,
      desaAktif,
      desaNonaktif: desa.length - desaAktif,
      totalPenduduk: penduduk.length,
      gender,
      bidan, kader, adminDesa, dokter, totalNakes,
      totalPuskesmas: puskesmas.length,
      totalPosyandu: posyandu.length,
      totalProvinsi: provinsi.length,
      totalKabupaten: kabupaten.length,
      totalKecamatan: kecamatan.length,
      perDesa,
      chartData,
    };
  }, [data]);

  const statCards = [
    { label: "Total Desa", value: computed.totalDesa, hint: `${computed.desaAktif} aktif · ${computed.desaNonaktif} nonaktif`, icon: MapPinned, tone: "bg-cyan-50 text-cyan-700", to: "/superadmin/kelola-desa" },
    { label: "Total Penduduk", value: computed.totalPenduduk, hint: `${computed.gender.lakiLaki} L · ${computed.gender.perempuan} P`, icon: Users, tone: "bg-indigo-50 text-indigo-700", to: "/superadmin/kelola-penduduk" },
    { label: "Tenaga Kesehatan", value: computed.totalNakes, hint: `${computed.bidan} bidan · ${computed.kader} kader`, icon: ShieldPlus, tone: "bg-emerald-50 text-emerald-700", to: "/superadmin/kelola-nakes" },
    { label: "Puskesmas", value: computed.totalPuskesmas, hint: `${computed.totalPosyandu} posyandu`, icon: Building2, tone: "bg-amber-50 text-amber-700", to: "/superadmin/kelola-puskesmas" },
  ];

  const nakesBreakdown = [
    { label: "Bidan", value: computed.bidan, icon: Stethoscope, tone: "bg-violet-50 text-violet-700" },
    { label: "Kader", value: computed.kader, icon: UserCheck, tone: "bg-sky-50 text-sky-700" },
    { label: "Admin Desa", value: computed.adminDesa, icon: UserCog, tone: "bg-amber-50 text-amber-700" },
    { label: "Dokter", value: computed.dokter, icon: ShieldCheck, tone: "bg-emerald-50 text-emerald-700" },
  ];

  const wilayahRows = [
    { label: "Provinsi", value: computed.totalProvinsi, icon: MapPinned },
    { label: "Kabupaten", value: computed.totalKabupaten, icon: Building2 },
    { label: "Kecamatan", value: computed.totalKecamatan, icon: MapPinned },
    { label: "Desa", value: computed.totalDesa, icon: Home },
  ];

  if (loading) {
    return (
      <MainLayout>
        <div className="flex items-center justify-center min-h-[60vh]">
          <div className="flex flex-col items-center gap-3 text-slate-500">
            <RefreshCw size={32} className="animate-spin text-indigo-600" />
            <p className="text-sm font-medium">Memuat data dashboard...</p>
          </div>
        </div>
      </MainLayout>
    );
  }

  if (error) {
    return (
      <MainLayout>
        <div className="flex items-center justify-center min-h-[60vh]">
          <div className="text-center">
            <AlertTriangle size={40} className="mx-auto text-rose-400 mb-3" />
            <p className="text-rose-600 font-medium">{error}</p>
            <button onClick={fetchAll} className="mt-4 inline-flex items-center gap-2 rounded-xl bg-indigo-600 px-4 py-2 text-sm font-semibold text-white hover:bg-indigo-700">
              <RefreshCw size={16} /> Coba lagi
            </button>
          </div>
        </div>
      </MainLayout>
    );
  }

  return (
    <MainLayout>
      <div className="p-4 md:p-6 lg:p-8 space-y-6">
        {/* Header actions */}
        <div className="flex items-center justify-between gap-3">
          <p className="text-sm text-slate-500">Ringkasan data sistem secara menyeluruh.</p>
          <button onClick={fetchAll} className="inline-flex items-center gap-2 rounded-2xl border border-slate-200 px-4 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-50">
            <RefreshCw size={16} /> Refresh
          </button>
        </div>

        {/* Stat cards */}
        <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
          {statCards.map((item) => {
            const Icon = item.icon;
            return (
              <Link key={item.label} to={item.to} className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm hover:border-indigo-300 hover:shadow transition">
                <div className="flex items-start justify-between gap-3">
                  <div className="min-w-0">
                    <p className="text-sm text-slate-500">{item.label}</p>
                    <h3 className="mt-2 text-3xl font-bold text-slate-900">{item.value}</h3>
                  </div>
                  <div className={`flex h-11 w-11 flex-shrink-0 items-center justify-center rounded-xl ${item.tone}`}>
                    <Icon size={20} />
                  </div>
                </div>
                <p className="mt-3 text-xs text-slate-500">{item.hint}</p>
              </Link>
            );
          })}
        </section>

        {/* Nakes breakdown + Wilayah ringkas */}
        <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
          {nakesBreakdown.map((item) => {
            const Icon = item.icon;
            return (
              <div key={item.label} className="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
                <div className="flex items-center gap-3">
                  <div className={`flex h-10 w-10 items-center justify-center rounded-lg ${item.tone}`}>
                    <Icon size={18} />
                  </div>
                  <div>
                    <p className="text-xs text-slate-500">{item.label}</p>
                    <h4 className="text-xl font-bold text-slate-900">{item.value}</h4>
                  </div>
                </div>
              </div>
            );
          })}
        </section>

        <section className="grid gap-6 xl:grid-cols-[1.5fr_1fr]">
          {/* Chart penduduk per desa */}
          <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
            <div className="flex items-center justify-between mb-4">
              <div>
                <p className="text-sm font-semibold uppercase tracking-wider text-slate-400">Sebaran Penduduk</p>
                <h2 className="mt-1 text-lg font-bold text-slate-900">Penduduk per Desa (Top 8)</h2>
              </div>
              <Activity size={20} className="text-slate-300" />
            </div>
            {computed.chartData.length === 0 ? (
              <div className="py-16 text-center text-slate-400 text-sm">Belum ada data penduduk</div>
            ) : (
              <div style={{ width: "100%", height: 300 }}>
                <ResponsiveContainer>
                  <BarChart data={computed.chartData} margin={{ top: 8, right: 8, left: -16, bottom: 8 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
                    <XAxis dataKey="nama" tick={{ fontSize: 11, fill: "#64748b" }} interval={0} angle={-15} textAnchor="end" height={50} />
                    <YAxis tick={{ fontSize: 11, fill: "#64748b" }} allowDecimals={false} />
                    <Tooltip cursor={{ fill: "#f8fafc" }} />
                    <Bar dataKey="penduduk" radius={[6, 6, 0, 0]}>
                      {computed.chartData.map((_, i) => (
                        <Cell key={i} fill={BAR_COLORS[i % BAR_COLORS.length]} />
                      ))}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>
              </div>
            )}
          </div>

          {/* Ringkasan wilayah & fasilitas */}
          <div className="space-y-6">
            <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
              <div className="flex items-center gap-3 mb-4">
                <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-cyan-50 text-cyan-700">
                  <Layers3 size={20} />
                </div>
                <div>
                  <p className="text-sm text-slate-500">Master Wilayah</p>
                  <h3 className="text-lg font-bold text-slate-900">Hierarki Wilayah</h3>
                </div>
              </div>
              <div className="space-y-2.5">
                {wilayahRows.map((row) => {
                  const RowIcon = row.icon;
                  return (
                    <div key={row.label} className="flex items-center justify-between rounded-2xl bg-slate-50 px-4 py-2.5">
                      <span className="flex items-center gap-2 text-sm text-slate-600">
                        <RowIcon size={15} className="text-slate-400" /> {row.label}
                      </span>
                      <span className="text-sm font-bold text-slate-900">{row.value}</span>
                    </div>
                  );
                })}
              </div>
              <Link to="/superadmin/kelola-wilayah" className="mt-4 block text-center text-xs font-semibold text-indigo-600 hover:text-indigo-700">
                Kelola Wilayah →
              </Link>
            </div>

            <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
              <div className="flex items-center gap-3 mb-4">
                <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-emerald-50 text-emerald-700">
                  <Building2 size={20} />
                </div>
                <div>
                  <p className="text-sm text-slate-500">Fasilitas Kesehatan</p>
                  <h3 className="text-lg font-bold text-slate-900">Puskesmas & Posyandu</h3>
                </div>
              </div>
              <div className="grid grid-cols-2 gap-3">
                <Link to="/superadmin/kelola-puskesmas" className="rounded-2xl bg-slate-50 p-4 hover:bg-slate-100 transition">
                  <p className="text-xs text-slate-400">Puskesmas</p>
                  <p className="mt-1 text-2xl font-bold text-slate-900">{computed.totalPuskesmas}</p>
                </Link>
                <Link to="/superadmin/kelola-posyandu" className="rounded-2xl bg-slate-50 p-4 hover:bg-slate-100 transition">
                  <p className="text-xs text-slate-400">Posyandu</p>
                  <p className="mt-1 text-2xl font-bold text-slate-900">{computed.totalPosyandu}</p>
                </Link>
              </div>
            </div>
          </div>
        </section>

        {/* Tabel ringkasan per desa */}
        <section className="rounded-3xl border border-slate-200 bg-white shadow-sm overflow-hidden">
          <div className="flex items-center justify-between gap-4 px-6 py-4 border-b border-slate-100">
            <div>
              <p className="text-sm font-semibold uppercase tracking-wider text-slate-400">Ringkasan</p>
              <h2 className="mt-0.5 text-lg font-bold text-slate-900">Data per Desa</h2>
            </div>
            <Link to="/superadmin/kelola-desa" className="text-xs font-semibold text-indigo-600 hover:text-indigo-700">
              Lihat semua →
            </Link>
          </div>

          {computed.perDesa.length === 0 ? (
            <div className="p-10 text-center text-slate-400 text-sm">Belum ada data desa</div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-slate-50 text-left text-xs uppercase tracking-wider text-slate-500">
                  <tr>
                    <th className="px-6 py-3 font-semibold">Desa</th>
                    <th className="px-6 py-3 font-semibold">Kecamatan</th>
                    <th className="px-6 py-3 font-semibold text-center">Penduduk</th>
                    <th className="px-6 py-3 font-semibold text-center">Nakes</th>
                    <th className="px-6 py-3 font-semibold text-center">Status</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {computed.perDesa.map((d) => (
                    <tr key={d.id} className="hover:bg-slate-50/70 transition">
                      <td className="px-6 py-3">
                        <div className="flex items-center gap-2">
                          <Home size={15} className="text-slate-400" />
                          <span className="font-medium text-slate-800 text-sm">{d.nama}</span>
                        </div>
                      </td>
                      <td className="px-6 py-3 text-sm text-slate-600">{d.kecamatan}</td>
                      <td className="px-6 py-3 text-center text-sm font-semibold text-slate-800">{d.penduduk}</td>
                      <td className="px-6 py-3 text-center text-sm text-slate-600">{d.nakes}</td>
                      <td className="px-6 py-3 text-center">
                        <span className={`inline-flex rounded-full px-2.5 py-0.5 text-xs font-medium ${d.is_active ? "bg-emerald-50 text-emerald-700" : "bg-slate-100 text-slate-500"}`}>
                          {d.is_active ? "Aktif" : "Nonaktif"}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </section>
      </div>
    </MainLayout>
  );
}
