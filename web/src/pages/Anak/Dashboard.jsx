import React, { useState, useEffect } from "react";
import { useParams, Link } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import { getAnakById } from "../../services/Anak";
import { getPertumbuhanChart } from "../../services/pertumbuhan";
import { getKeluhanByAnakId } from "../../services/keluhanAnak";
import GrowthChart from "../../components/Dashboard/GrowthChart";
import {
  ResponsiveContainer,
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
} from "recharts";

import {
  ChevronLeft, ArrowLeft, Baby, Ruler, Activity, Calendar, User,
  Plus, X, Apple, Syringe, TrendingUp, Smile, ChartLine, Stethoscope, ClipboardList, ArrowRight
} from "lucide-react";

export default function AnakDashboard() {
  const { id } = useParams();
  const [child, setChild] = useState(null);
  const [chartData, setChartData] = useState(null);
  const [keluhanList, setKeluhanList] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [activeChart, setActiveChart] = useState("bb_u"); // "bb_u" or "tb_u"

  useEffect(() => {
    let isMounted = true;
    const fetchDetailData = async () => {
      if (!id) return;
      try {
        setLoading(true);
        setError(null);
        const [resAnak, resChart, resKeluhan] = await Promise.all([
          getAnakById(id),
          getPertumbuhanChart(id).catch(err => {
            console.warn("Error fetching chart data:", err);
            return { data: null };
          }),
          getKeluhanByAnakId(id).catch(err => {
            console.warn("Error fetching complaints:", err);
            return { data: [] };
          })
        ]);

        if (isMounted) {
          const childData = resAnak.data || resAnak;
          // Guard: pastikan data valid minimal punya nama/id
          if (childData && (childData.nama || childData.id)) {
            setChild(childData);
          } else {
            throw new Error("Data tidak ditemukan");
          }
          const chartResponse = resChart.data || resChart;
          console.log("🔍 Chart API Response:", chartResponse);
          if (chartResponse?.riwayat?.length > 0) {
            console.log("📊 Sample record:", chartResponse.riwayat[0]);
            console.log("🎯 LILA values:", chartResponse.riwayat.map(r => ({ usia: r.usia_ukur_bulan, lila: r.hasil_lila, lk: r.lingkar_kepala })));
          }
          setChartData(chartResponse);
          setKeluhanList(resKeluhan?.data || []);
        }
      } catch (err) {
        if (isMounted) {
          console.error("Error fetching detail data:", err);
          setError("Gagal mengambil data detail anak.");
        }
      } finally {
        if (isMounted) {
          setLoading(false);
        }
      }
    };
    fetchDetailData();
    return () => { isMounted = false; };
  }, [id]);

  if (loading) return <MainLayout><div className="p-10 text-center font-medium text-gray-400">Memuat...</div></MainLayout>;
  if (error) return <MainLayout><div className="p-10 text-center text-red-500">{error}</div></MainLayout>;

  const baseGrowthData = chartData?.riwayat || child?.pertumbuhan || [];
  const growthData = [...baseGrowthData];

  // Jika tidak ada data ukur bulan 0 (saat lahir) tapi ada data lahir anak, tambahkan sebagai titik awal
  const hasMonthZero = growthData.some((r) => r.usia_ukur_bulan === 0);
  if (!hasMonthZero && child) {
    const hasBirthData = child.berat_lahir_kg || child.tinggi_lahir_cm || child.lingkar_kepala_cm;
    if (hasBirthData) {
      growthData.unshift({
        usia_ukur_bulan: 0,
        berat_badan: child.berat_lahir_kg || null,
        tinggi_badan: child.tinggi_lahir_cm || null,
        lingkar_kepala: child.lingkar_kepala_cm || null,
        hasil_lila: null,
        tgl_ukur: child.tanggal_lahir || "",
      });
    }
  }

  const lastGrowth = growthData.length > 0 ? growthData[growthData.length - 1] : null;
  const isLaki = child?.jenis_kelamin?.toLowerCase() === "laki-laki";
  const themeColor = isLaki ? "#3b82f6" : "#ec4899";

  const menuInput = [
    { title: "Kesehatan Bayi", subtitle: "(0 - 28 Hari)", icon: <Baby size={32} />, link: `/data-anak/neonatus/${id}` },
    { title: "Gizi & Obat Cacing", icon: <Apple size={32} />, link: `/data-anak/pelayanan-gizi/${id}` },
    { title: "Imunisasi", icon: <Syringe size={32} />, link: `/data-anak/pelayanan-Imunisasi/${id}` },
    { title: "Kesehatan Gigi", icon: <Smile size={32} />, link: `/data-anak/pelayanan-Gigi/${id}` },
    { title: "Pertumbuhan", icon: <Activity size={32} />, link: `/data-anak/pertumbuhan/${id}` },
    { title: "Tumbuh Kembang", icon: <TrendingUp size={32} />, link: `/data-anak/Tumbuh-kembang-Anak/${id}` },
  ];

  return (
    <MainLayout>
      <div className="p-4 md:p-8 bg-[#f8fafc] min-h-screen">

        {/* HEADER */}
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-6">
          <div>
            <Link
              to="/daftar-anak"
              className="inline-flex items-center gap-2 px-4 py-2 bg-[#185FA5] hover:bg-[#185FA5]/90 text-white rounded-xl font-semibold text-sm transition-all active:scale-95 shadow-sm mb-4 mt-2"
            >
              <ArrowLeft size={16} /> Kembali
            </Link>
            <h1 className="text-2xl font-bold text-gray-800 tracking-tight">{child.nama}</h1>
          </div>
          <button
            onClick={() => setIsModalOpen(true)}
            className="bg-[#185FA5] hover:bg-[#185FA5]/90 text-white px-5 py-2.5 rounded-xl flex items-center gap-2 text-sm font-semibold shadow-sm transition-all active:scale-95"
          >
            <Plus size={18} /> Input Data
          </button>
        </div>

        {/* INFO CARD: Data anak dalam satu card */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-5 mb-6">
          <h3 className="text-xs font-semibold text-gray-400 uppercase tracking-wide mb-4">Informasi Anak</h3>
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
            <StatCard icon={<Calendar size={18} />} label="Usia" value={child.usia_teks || "-"} />
            <StatCard icon={<User size={18} />} label="Nama Ibu" value={child.kehamilan?.ibu?.nama_ibu || "-"} />
            <StatCard icon={<Activity size={18} />} label="Berat Badan" value={lastGrowth?.berat_badan ? `${lastGrowth.berat_badan} kg` : "- kg"} />
            <StatCard icon={<Ruler size={18} />} label="Tinggi Badan" value={lastGrowth?.tinggi_badan ? `${lastGrowth.tinggi_badan} cm` : "- cm"} />
          </div>
        </div>

        {/* GRAFIK: Tampilkan 4 grafik kecil dalam tata letak seperti gambar pertama */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
          <ChartCard title="Grafik Berat Badan (kg)" dataKey="berat_badan" data={growthData} color={themeColor} />
          <ChartCard title="Grafik Tinggi Badan (cm)" dataKey="tinggi_badan" data={growthData} color="#8b5cf6" />
          <ChartCard title="Grafik LILA (cm)" dataKey="hasil_lila" data={growthData} color="#f59e0b" />
          <ChartCard title="Grafik Lingkar Kepala (cm)" dataKey="lingkar_kepala" data={growthData} color="#10b981" />
        </div>

        {/* RIWAYAT KELUHAN & CATATAN KUNJUNGAN */}
        <div className="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm mb-6">
          <div className="flex justify-between items-center mb-4">
            <div className="flex items-center gap-2">
              <Stethoscope className="text-blue-600 animate-pulse" size={24} />
              <h3 className="text-lg font-bold text-gray-800">Riwayat Keluhan & Catatan Kunjungan</h3>
            </div>
            <Link
              to={`/data-anak/keluhan/${id}`}
              className="text-xs font-bold text-blue-600 hover:text-blue-700 flex items-center gap-1 transition-colors"
            >
              Lihat Detail & Kelola <ArrowRight size={14} />
            </Link>
          </div>

          {keluhanList.length === 0 ? (
            <div className="py-8 text-center text-gray-400 italic text-sm">
              Belum ada catatan keluhan untuk anak ini.
            </div>
          ) : (
            <div className="space-y-4">
              {keluhanList.slice(0, 3).map((item, index) => (
                <div key={item.id || index} className="p-4 bg-slate-50/50 rounded-2xl border border-slate-100 flex flex-col md:flex-row justify-between gap-4 transition-all hover:bg-slate-50">
                  <div className="space-y-1 flex-1">
                    <div className="flex items-center gap-2">
                      <span className="text-[10px] font-bold text-slate-400 uppercase">
                        {item.tanggal ? new Date(item.tanggal).toLocaleDateString("id-ID", { day: 'numeric', month: 'long', year: 'numeric' }) : "-"}
                      </span>
                      <span className="text-[9px] px-2 py-0.5 bg-blue-50 text-blue-600 rounded-md font-bold uppercase">
                        Pemeriksa: {item.pemeriksa || "Petugas"}
                      </span>
                    </div>
                    <div>
                      <span className="text-[10px] text-slate-400 font-bold uppercase block mt-1">Keluhan / Gejala:</span>
                      <p className="text-sm font-bold text-slate-800 leading-relaxed">
                        {item.keluhan || "-"}
                      </p>
                    </div>
                  </div>
                  {item.tindakan && (
                    <div className="md:w-1/2 bg-white p-3 rounded-xl border border-slate-100 flex flex-col justify-center">
                      <span className="text-[9px] text-slate-400 font-bold uppercase block mb-1">Tindakan / Saran:</span>
                      <p className="text-xs text-blue-600 font-bold leading-relaxed bg-blue-50/30 px-3 py-2 rounded-lg border border-blue-50">
                        {item.tindakan || "-"}
                      </p>
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}
        </div>

        {/* MODAL: Versi Ringkas (Compact) */}
        {isModalOpen && (
          <div className="fixed inset-0 z-[999] flex items-center justify-center p-6">
            {/* Overlay */}
            <div
              className="absolute inset-0 bg-black/20 backdrop-blur-[2px]"
              onClick={() => setIsModalOpen(false)}
            ></div>

            {/* Container Modal */}
            <div className="relative bg-[#F3F4F6] w-full max-w-lg rounded-[40px] p-8 shadow-2xl animate-in fade-in zoom-in duration-200">

              {/* Tombol Close (Opsional, di gambar tidak ada tapi bagus untuk UX) */}
              <button
                onClick={() => setIsModalOpen(false)}
                className="absolute -top-0 -right-0    z-[1000] bg-white text-gray-800 p-2 rounded-full shadow-lg border border-gray-100 hover:bg-gray-50 transition-all active:scale-90"
              >
                <X size={20} strokeWidth={3} />
              </button>

              {/* Grid Menu */}
              <div className="grid grid-cols-2 gap-5">
                {menuInput.map((item, idx) => (
                  <Link
                    key={idx}
                    to={item.link}
                    className={`
              relative bg-white p-6 rounded-[28px] flex flex-col items-center text-center justify-center gap-3 
              transition-all duration-200 group shadow-sm hover:shadow-md active:scale-95
              ${item.active ? 'border-[3px] border-blue-400' : 'border-[3px] border-transparent'}
            `}
                  >
                    {/* Icon Box */}
                    <div className="text-blue-600 transition-transform group-hover:scale-110">
                      {item.icon}
                    </div>

                    {/* Text Box */}
                    <div className="flex flex-col items-center">
                      <span className="text-[15px] font-bold text-gray-900 leading-tight">
                        {item.title}
                      </span>
                      {item.subtitle && (
                        <span className="text-[14px] font-bold text-gray-900 mt-1">
                          {item.subtitle}
                        </span>
                      )}
                    </div>
                  </Link>
                ))}
              </div>
            </div>
          </div>
        )}
      </div>
    </MainLayout>
  );
}

function StatCard({ icon, label, value, color }) {
  const colors = {
    orange: "bg-orange-50 text-orange-500",
    blue: "bg-blue-50 text-blue-500",
    green: "bg-green-50 text-green-500",
    purple: "bg-blue-50 text-blue-500",
  };
  return (
    <div className="bg-white p-3.5 rounded-xl border border-gray-100 flex items-center gap-3">
      <div className={`p-2 rounded-lg ${colors[color]}`}>{icon}</div>
      <div className="overflow-hidden">
        <p className="text-[10px] font-bold text-gray-400 uppercase tracking-tight">{label}</p>
        <p className="text-sm font-bold text-gray-800 truncate">{value}</p>
      </div>
    </div>
  );
}

function ChartCard({ title, dataKey, data = [], color = "#3b82f6" }) {
  const chartData = (data || [])
    .map((r) => ({
      name: `${r.usia_ukur_bulan} bln`,
      value: r && r[dataKey] !== null && r[dataKey] !== undefined ? Number(r[dataKey]) : null,
    }))
    .filter(d => d.value !== null && !isNaN(d.value));

  const hasData = chartData.length > 0;

  if (!hasData && dataKey !== "berat_badan" && dataKey !== "tinggi_badan") {
    console.log(`📉 No data for ${dataKey}:`, {
      totalRecords: data.length,
      sampleValues: data.slice(0, 3).map(r => r[dataKey])
    });
  }

  return (
    <div className="bg-white p-4 rounded-2xl border border-gray-100 shadow-sm h-[260px]">
      <div className="flex items-center justify-between mb-3">
        <h4 className="font-bold text-gray-700">{title}</h4>
        <div className="text-xs text-gray-400">Standar Permenkes 2/2020</div>
      </div>
      <div className="h-[180px]">
        {hasData ? (
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={chartData} margin={{ top: 5, right: 12, left: 0, bottom: 5 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" vertical={false} />
              <XAxis dataKey="name" tick={{ fontSize: 10 }} />
              <YAxis tick={{ fontSize: 10 }} />
              <Tooltip />
              <Line type="monotone" dataKey="value" stroke={color} strokeWidth={3} dot={{ r: 4 }} activeDot={{ r: 6 }} connectNulls />
            </LineChart>
          </ResponsiveContainer>
        ) : (
          <div className="h-full flex items-center justify-center text-gray-300 font-medium italic">Belum ada data untuk ditampilkan</div>
        )}
      </div>
    </div>
  );
}