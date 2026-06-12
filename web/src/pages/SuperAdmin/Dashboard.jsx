import React from "react";
import MainLayout from "../../components/Layout/MainLayout";
import { Activity, AlertTriangle, Building2, Layers3, MapPinned, ShieldCheck, TrendingUp } from "lucide-react";

const dummyDesa = [
  { name: "Desa Sukamaju", status: "Aktif", ibu: 124, anak: 88, aktivitas: "14 menit lalu" },
  { name: "Desa Harapan Jaya", status: "Aktif", ibu: 97, anak: 63, aktivitas: "42 menit lalu" },
  { name: "Desa Mekarsari", status: "Perlu perhatian", ibu: 56, anak: 41, aktivitas: "1 jam lalu" },
];

const stats = [
  { label: "Total Desa", value: "12", hint: "+2 bulan ini", icon: MapPinned, tone: "bg-cyan-50 text-cyan-700" },
  { label: "Aktivitas Hari Ini", value: "48", hint: "Semua modul", icon: Activity, tone: "bg-emerald-50 text-emerald-700" },
  { label: "Desa Aktif", value: "10", hint: "2 nonaktif", icon: ShieldCheck, tone: "bg-amber-50 text-amber-700" },
  { label: "Peringatan", value: "3", hint: "Butuh tindak lanjut", icon: AlertTriangle, tone: "bg-rose-50 text-rose-700" },
];

const activityFeed = [
  "Monitoring desa Mekarsari diperbarui oleh kader.",
  "Ringkasan data ibu di Desa Harapan Jaya berhasil disinkronkan.",
  "Pengecekan status akses superadmin dilakukan 5 menit lalu.",
];

export default function SuperAdminDashboard() {
  return (
    <MainLayout>
      <div className="p-8 space-y-8">
        <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
          {stats.map((item) => {
            const Icon = item.icon;
            return (
              <div key={item.label} className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <p className="text-sm text-slate-500">{item.label}</p>
                    <h3 className="mt-2 text-3xl font-bold text-slate-900">{item.value}</h3>
                  </div>
                  <div className={`flex h-11 w-11 items-center justify-center rounded-xl ${item.tone}`}>
                    <Icon size={20} />
                  </div>
                </div>
                <p className="mt-3 text-sm text-slate-500">{item.hint}</p>
              </div>
            );
          })}
        </section>

        <section className="grid gap-6 xl:grid-cols-[1.4fr_0.9fr]">
          <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
            <div className="flex items-center justify-between gap-4 mb-5">
              <div>
                <p className="text-sm font-semibold uppercase tracking-[0.2em] text-slate-400">Ringkasan per desa</p>
                {/* <h2 className="mt-1 text-2xl font-bold text-slate-900">Konten dummy untuk dashboard superadmin</h2> */}
              </div>
              <div className="rounded-2xl bg-slate-100 px-4 py-2 text-sm font-medium text-slate-600">
                Placeholder frontend
              </div>
            </div>

            <div className="space-y-4">
              {dummyDesa.map((desa) => (
                <div key={desa.name} className="rounded-2xl border border-slate-200 p-4 hover:border-slate-300 transition">
                  <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
                    <div>
                      <div className="flex items-center gap-2">
                        <Building2 size={18} className="text-slate-500" />
                        <h3 className="font-semibold text-slate-900">{desa.name}</h3>
                      </div>
                      <p className="mt-1 text-sm text-slate-500">Aktivitas terakhir: {desa.aktivitas}</p>
                    </div>
                    <span className={`inline-flex w-fit items-center rounded-full px-3 py-1 text-sm font-medium ${desa.status === "Aktif" ? "bg-emerald-50 text-emerald-700" : "bg-amber-50 text-amber-700"}`}>
                      {desa.status}
                    </span>
                  </div>

                  <div className="mt-4 grid grid-cols-2 gap-3 sm:grid-cols-3">
                    <div className="rounded-xl bg-slate-50 p-3">
                      <p className="text-xs text-slate-400">Ibu</p>
                      <p className="mt-1 text-lg font-bold text-slate-900">{desa.ibu}</p>
                    </div>
                    <div className="rounded-xl bg-slate-50 p-3">
                      <p className="text-xs text-slate-400">Anak</p>
                      <p className="mt-1 text-lg font-bold text-slate-900">{desa.anak}</p>
                    </div>
                    <div className="rounded-xl bg-slate-50 p-3 col-span-2 sm:col-span-1">
                      <p className="text-xs text-slate-400">Status</p>
                      <p className="mt-1 text-lg font-bold text-slate-900">Stabil</p>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div className="space-y-6">
            <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
              <div className="flex items-center gap-3">
                <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-cyan-50 text-cyan-700">
                  <TrendingUp size={22} />
                </div>
                <div>
                  <p className="text-sm text-slate-500">Statistik keseluruhan</p>
                  <h3 className="text-lg font-bold text-slate-900">Overview </h3>
                </div>
              </div>

              <div className="mt-5 space-y-3">
                {[
                  ["Kunjungan hari ini", "18"],
                  ["Pelaporan masuk", "9"],
                  ["Aktivitas tertinggi", "Desa Sukamaju"],
                ].map(([label, value]) => (
                  <div key={label} className="flex items-center justify-between rounded-2xl bg-slate-50 px-4 py-3">
                    <span className="text-sm text-slate-500">{label}</span>
                    <span className="text-sm font-semibold text-slate-900">{value}</span>
                  </div>
                ))}
              </div>
            </div>

            <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
              <div className="flex items-center gap-3 mb-4">
                <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-emerald-50 text-emerald-700">
                  <Layers3 size={22} />
                </div>
                <div>
                  <p className="text-sm text-slate-500">Monitoring aktivitas</p>
                  <h3 className="text-lg font-bold text-slate-900">Aktivitas terbaru</h3>
                </div>
              </div>

              <div className="space-y-3">
                {activityFeed.map((item, index) => (
                  <div key={item} className="rounded-2xl border border-slate-100 bg-slate-50 p-4">
                    <p className="text-sm font-medium text-slate-800">{item}</p>
                    <p className="mt-1 text-xs text-slate-500">Event #{index + 1}   </p>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </section>
      </div>
    </MainLayout>
  );
}