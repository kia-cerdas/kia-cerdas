import React, { useEffect, useState, useMemo } from "react";
import { useParams } from "react-router-dom";
import Swal from "sweetalert2";
import MainLayout from "../../components/Layout/MainLayout";
import { Line } from "react-chartjs-2";
import { Save, X, Activity, AlertTriangle, CheckCircle, Info } from "lucide-react";
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Tooltip,
  Legend,
  Filler, // Diperlukan untuk warna area pada grafik
} from "chart.js";

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Tooltip,
  Legend,
  Filler
);

import { getKehamilanByIbuId } from "../../services/kehamilan";
import { createGrafik, getGrafikChart } from "../../services/grafik";

export default function GrafikEvaluasi() {
  const { id } = useParams();

  const [kehamilan, setKehamilan] = useState(null);
  const [grafikTFU, setGrafikTFU] = useState([]);
  const [grafikDJJ, setGrafikDJJ] = useState([]);
  const [grafikTD, setGrafikTD] = useState([]); // State untuk Tekanan Darah
  const [penjelasan, setPenjelasan] = useState("");
  const [riskLevel, setRiskLevel] = useState("");

  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [openModal, setOpenModal] = useState(false);

  const today = new Date().toISOString().split("T")[0];
  const [form, setForm] = useState({
    tanggal_bulan_tahun: today,
    tinggi_fundus_uteri_cm: "",
    denyut_jantung_bayi_x_menit: "",
    tekanan_darah_sistole: "",
    tekanan_darah_diastole: "",
    nadi_per_menit: "",
    gerakan_bayi: "aktif", // Default aktif
    urin_protein: "negatif",
    urin_reduksi: "negatif",
    hemoglobin: "",
    tablet_tambah_darah: "",
    kalsium: "tidak",
    aspirin: "tidak",
  });

  // =========================
  // FETCH DATA
  // =========================
  const fetchData = async () => {
    try {
      const kehamilanList = await getKehamilanByIbuId(id);

      if (kehamilanList.length > 0) {
        const aktif = kehamilanList[0];
        setKehamilan(aktif);

        const res = await getGrafikChart(aktif.id);
        const data = res?.data || res;

        setGrafikTFU(data?.grafik_tfu || []);
        setGrafikDJJ(data?.grafik_djj || []);
        setGrafikTD(data?.grafik_tekanan_darah || []);
        setPenjelasan(data?.penjelasan || "");
        setRiskLevel(data?.kategori_risiko || "");
      }
    } catch (err) {
      console.error("FETCH ERROR:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, [id]);

  // =========================
  // HANDLE FORM
  // =========================
  const handleChange = (e) =>
    setForm({ ...form, [e.target.name]: e.target.value });

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!kehamilan) return;

    setSaving(true);
    try {
      const payload = {
        kehamilan_id: kehamilan.id,
        tanggal_bulan_tahun: form.tanggal_bulan_tahun,
        tinggi_fundus_uteri_cm: Number(form.tinggi_fundus_uteri_cm),
        denyut_jantung_bayi_x_menit: Number(form.denyut_jantung_bayi_x_menit),
        tekanan_darah_sistole: Number(form.tekanan_darah_sistole),
        tekanan_darah_diastole: Number(form.tekanan_darah_diastole),
        nadi_per_menit: Number(form.nadi_per_menit),
        gerakan_bayi: form.gerakan_bayi,
        urin_protein: form.urin_protein,
        urin_reduksi: form.urin_reduksi,
        hemoglobin: Number(form.hemoglobin),
        tablet_tambah_darah: Number(form.tablet_tambah_darah),
        kalsium: form.kalsium,
        aspirin: form.aspirin,
      };

      await createGrafik(payload);
      await Swal.fire({
        icon: 'success',
        title: 'Berhasil',
        text: 'Data pemeriksaan berhasil disimpan',
        timer: 1500,
        showConfirmButton: false
      });
      setOpenModal(false);
      fetchData(); // Reload all charts and explanation
    } catch (err) {
      console.error(err);
      Swal.fire('Error', 'Gagal menyimpan data: ' + (err.response?.data?.message || err.message), 'error');
    } finally {
      setSaving(false);
    }
  };

  // =========================
  // CHART DATA CONFIG
  // =========================
  const chartTFUData = useMemo(() => ({
    labels: grafikTFU.map((d) => `${d.usia} mgg`),
    datasets: [
      {
        label: "TFU Aktual",
        data: grafikTFU.map((d) => d.tfu),
        borderColor: "#4f46e5",
        backgroundColor: "#4f46e5",
        borderWidth: 3,
        pointRadius: 6,
      },
      {
        label: "Batas Atas",
        data: grafikTFU.map((d) => d.upper),
        borderColor: "rgba(220,38,38,0.5)",
        borderDash: [5, 5],
        pointRadius: 0,
        fill: false,
      },
      {
        label: "Batas Bawah",
        data: grafikTFU.map((d) => d.lower),
        borderColor: "rgba(220,38,38,0.5)",
        borderDash: [5, 5],
        pointRadius: 0,
        fill: "-1",
        backgroundColor: "rgba(220,38,38,0.05)",
      },
    ],
  }), [grafikTFU]);

  const chartDJJData = useMemo(() => ({
    labels: grafikDJJ.map((d) => `${d.usia} mgg`),
    datasets: [
      {
        label: "DJJ Aktual",
        data: grafikDJJ.map((d) => d.djj),
        borderColor: "#06b6d4",
        backgroundColor: "#06b6d4",
        borderWidth: 3,
        pointRadius: 6,
      },
      {
        label: "Zona Normal (110-160)",
        data: grafikDJJ.map(() => 160),
        borderColor: "transparent",
        pointRadius: 0,
        fill: true,
        backgroundColor: "rgba(34,197,94,0.1)",
      },
      {
        label: "Lower Limit",
        data: grafikDJJ.map(() => 110),
        borderColor: "rgba(220,38,38,0.3)",
        borderDash: [2, 2],
        pointRadius: 0,
      },
    ],
  }), [grafikDJJ]);

  const chartTDData = useMemo(() => ({
    labels: grafikTD.map((d) => `${d.usia} mgg`),
    datasets: [
      {
        label: "Sistole Aktual",
        data: grafikTD.map((d) => d.sistole),
        borderColor: "#4f46e5", // Indigo
        borderWidth: 3,
        pointRadius: 5,
        tension: 0.2,
      },
      {
        label: "Diastole Aktual",
        data: grafikTD.map((d) => d.diastole),
        borderColor: "#06b6d4", // Cyan
        borderWidth: 3,
        pointRadius: 5,
        tension: 0.2,
      },
      // --- GARIS BATAS MERAH (130/80) ---
      {
        label: "Batas Sistole (130)",
        data: grafikTD.map(() => 130),
        borderColor: "#ef4444", // Merah
        borderDash: [5, 5],    // Garis putus-putus
        borderWidth: 2,
        pointRadius: 0,        // Tidak perlu titik
        fill: false,
      },
      {
        label: "Batas Diastole (80)",
        data: grafikTD.map(() => 80),
        borderColor: "#f87171", // Merah terang
        borderDash: [5, 5],
        borderWidth: 2,
        pointRadius: 0,
        fill: false,
      },
    ],
  }), [grafikTD]);

  const getRiskStyles = () => {
    switch (riskLevel?.toLowerCase()) {
      case "tinggi": return "bg-red-50 border-red-200 text-red-700";
      case "sedang": return "bg-yellow-50 border-yellow-200 text-yellow-700";
      default: return "bg-green-50 border-green-200 text-green-700";
    }
  };
  const usiaGestasiOtomatis = useMemo(() => {
    // Pastikan data HPHT dari backend sudah ada dan tanggal di form sudah dipilih
    if (!kehamilan?.hpht || !form.tanggal_bulan_tahun) return 0;

    const tglHPHT = new Date(kehamilan.hpht);
    const tglPeriksa = new Date(form.tanggal_bulan_tahun);

    // Hitung selisih dalam milidetik, lalu ubah ke hari
    const diffInMs = tglPeriksa - tglHPHT;
    const diffInDays = Math.floor(diffInMs / (1000 * 60 * 60 * 24));

    // Bagi 7 untuk mendapatkan jumlah minggu
    const minggu = Math.floor(diffInDays / 7);

    return minggu > 0 ? minggu : 0;
  }, [form.tanggal_bulan_tahun, kehamilan?.hpht]);

  if (loading) return <MainLayout><div className="p-6">Memuat data...</div></MainLayout>;

  return (
    <MainLayout>
      <div className="p-6 max-w-6xl mx-auto space-y-6">

        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold text-gray-800">Grafik Evaluasi Kehamilan</h1>
            <p className="text-gray-500">Pemantauan TFU, DJJ, dan Tekanan Darah</p>
          </div>
          <button
            onClick={() => setOpenModal(true)}
            className="bg-indigo-600 hover:bg-indigo-700 text-white px-5 py-2.5 rounded-xl shadow-lg transition flex items-center gap-2"
          >
            <Activity size={18} /> + Input Pemeriksaan
          </button>
        </div>

        {/* STATUS & PENJELASAN */}
        {penjelasan && (
          <div className={`p-5 rounded-2xl border-2 flex gap-4 items-start ${getRiskStyles()}`}>
            {riskLevel?.toLowerCase() === "tinggi" ? <AlertTriangle className="flex-shrink-0" /> : <CheckCircle className="flex-shrink-0" />}
            <div>
              <h3 className="font-bold text-lg uppercase tracking-tight">Kategori Risiko: {riskLevel}</h3>
              <p className="mt-1 leading-relaxed">{penjelasan}</p>
            </div>
          </div>
        )}

        {/* GRAPHS GRID */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
            <h2 className="font-bold text-gray-700 mb-4">Grafik Tinggi Fundus Uteri (cm)</h2>
            <div className="h-72">
              <Line data={chartTFUData} options={{ responsive: true, maintainAspectRatio: false }} />
            </div>
          </div>

          <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
            <h2 className="font-bold text-gray-700 mb-4">Grafik Denyut Jantung Janin (bpm)</h2>
            <div className="h-72">
              <Line data={chartDJJData} options={{ responsive: true, maintainAspectRatio: false }} />
            </div>
          </div>

          <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 lg:col-span-2">
            <h2 className="font-bold text-gray-700 mb-4">Grafik Tren Tekanan Darah (mmHg)</h2>
            <div className="h-72">
              <Line
                data={chartTDData}
                options={{
                  responsive: true,
                  maintainAspectRatio: false,
                  scales: {
                    y: {
                      min: 60,  // Batas bawah grafik sesuai Buku KIA
                      max: 180, // Batas atas grafik sesuai Buku KIA
                      ticks: {
                        stepSize: 10
                      }
                    }
                  },
                  plugins: {
                    legend: {
                      position: 'bottom',
                      labels: { boxWidth: 12, usePointStyle: true }
                    }
                  }
                }}
              />
            </div>
          </div>
        </div>
      </div>


      {/* MODAL INPUT - VERSI COMPACT & WIDE */}
    {openModal && (
  <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
    {/* Backdrop */}
    <div
      className="fixed inset-0 bg-black/50 backdrop-blur-sm"
      onClick={() => setOpenModal(false)}
    ></div>

    <div className="relative w-full max-w-3xl bg-white rounded-2xl shadow-2xl border border-gray-100 overflow-hidden">

      {/* HEADER */}
      <div className="px-6 py-4 border-b flex justify-between items-center bg-gradient-to-r from-indigo-50 to-white">
        <div>
          <h3 className="text-lg font-semibold text-gray-800">
            Pemeriksaan Ibu & Janin
          </h3>
          <p className="text-xs text-gray-500">
            Input data berdasarkan pemeriksaan terbaru
          </p>
        </div>
        <button
          onClick={() => setOpenModal(false)}
          className="text-gray-400 hover:text-red-500"
        >
          <X size={22} />
        </button>
      </div>

      <form onSubmit={handleSubmit}>
        <div className="p-6 space-y-6">

          {/* ================= DATA DASAR ================= */}
          <div>
            <h4 className="text-sm font-semibold text-gray-700 mb-3">
              Data Dasar
            </h4>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <input
                type="date"
                name="tanggal_bulan_tahun"
                value={form.tanggal_bulan_tahun}
                onChange={handleChange}
                className="input"
                required
              />

              <div className="flex items-center justify-between bg-indigo-50 border border-indigo-100 rounded-xl px-4 py-3">
                <span className="text-indigo-700 font-bold">
                  {usiaGestasiOtomatis} Minggu
                </span>
                <span className="text-[10px] text-indigo-500 font-semibold">
                  Otomatis
                </span>
              </div>

              <input
                type="number"
                name="tekanan_darah_sistole"
                placeholder="Sistole (120)"
                onChange={handleChange}
                className="input"
                required
              />

              <input
                type="number"
                name="tekanan_darah_diastole"
                placeholder="Diastole (80)"
                onChange={handleChange}
                className="input"
                required
              />

              <input
                type="number"
                name="nadi_per_menit"
                placeholder="Nadi (80)"
                onChange={handleChange}
                className="input"
              />
            </div>
          </div>

          {/* ================= JANIN ================= */}
          <div className="bg-indigo-50/40 border border-indigo-100 rounded-xl p-4">
            <h4 className="text-sm font-semibold text-indigo-700 mb-3">
              Kondisi Janin
            </h4>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <input
                type="number"
                step="0.1"
                name="tinggi_fundus_uteri_cm"
                placeholder="TFU (cm)"
                onChange={handleChange}
                className="input"
                required
              />

              <input
                type="number"
                name="denyut_jantung_bayi_x_menit"
                placeholder="DJJ (140)"
                onChange={handleChange}
                className="input"
                required
              />

              <select
                name="gerakan_bayi"
                onChange={handleChange}
                className="input"
              >
                <option value="aktif">Gerakan Aktif</option>
                <option value="kurang">Gerakan Kurang</option>
              </select>
            </div>
          </div>

          {/* ================= LAB ================= */}
          <div>
            <h4 className="text-sm font-semibold text-gray-700 mb-3">
              Laboratorium & Suplemen
            </h4>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <input
                type="number"
                step="0.1"
                name="hemoglobin"
                placeholder="Hb (11.0)"
                onChange={handleChange}
                className="input"
              />

              <select
                name="urin_protein"
                onChange={handleChange}
                className="input"
              >
                <option value="negatif">Protein (-)</option>
                <option value="positif">Protein (+)</option>
              </select>

              <input
                type="number"
                name="tablet_tambah_darah"
                placeholder="Tablet Fe"
                onChange={handleChange}
                className="input"
              />

              <select
                name="kalsium"
                onChange={handleChange}
                className="input"
              >
                <option value="tidak">Kalsium Tidak</option>
                <option value="ya">Kalsium Ya</option>
              </select>

              <select
                name="aspirin"
                onChange={handleChange}
                className="input md:col-span-2"
              >
                <option value="tidak">Tanpa Aspirin</option>
                <option value="ya">Dengan Aspirin</option>
              </select>
            </div>
          </div>
        </div>

        {/* FOOTER */}
        <div className="px-6 py-4 bg-gray-50 flex justify-between items-center border-t">
          <span className="text-xs text-gray-400 italic">
            * Sesuaikan dengan buku KIA
          </span>

          <div className="flex gap-2">
            <button
              type="button"
              onClick={() => setOpenModal(false)}
              className="px-4 py-2 text-sm text-gray-500 hover:text-gray-700"
            >
              Batal
            </button>

            <button
              type="submit"
              disabled={saving}
              className="bg-indigo-600 hover:bg-indigo-700 text-white px-6 py-2 rounded-xl text-sm font-semibold shadow"
            >
              {saving ? "Menyimpan..." : "Simpan"}
            </button>
          </div>
        </div>
      </form>
    </div>
  </div>
)}  
    </MainLayout>
  );
}