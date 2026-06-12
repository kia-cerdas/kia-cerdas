import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import Swal from "sweetalert2";
import MainLayout from "../../components/Layout/MainLayout";
import { Line } from "react-chartjs-2";
import { Save, X } from "lucide-react";

import { getKehamilanByIbuId } from "../../services/kehamilan";
import { createGrafik, getGrafikChart } from "../../services/grafik";

export default function GrafikEvaluasi() {
  const { id } = useParams();

  const [kehamilan, setKehamilan] = useState(null);

  const [grafikTFU, setGrafikTFU] = useState([]);
  const [grafikDJJ, setGrafikDJJ] = useState([]);

  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [openModal, setOpenModal] = useState(false);

  const [form, setForm] = useState({
    tanggal_bulan_tahun: "",
    usia_gestasi_minggu: "",
    tinggi_fundus_uteri_cm: "",
    denyut_jantung_bayi_x_menit: "",
  });

  // =========================
  // FETCH DATA
  // =========================
  useEffect(() => {
    const fetchData = async () => {
      try {
        const kehamilanList = await getKehamilanByIbuId(id);

        if (kehamilanList.length > 0) {
          const aktif = kehamilanList[0];
          setKehamilan(aktif);

          const chart = await getGrafikChart(aktif.id);

          //  FIX UTAMA DI SINI
          setGrafikTFU(chart?.grafik_tfu || []);
          setGrafikDJJ(chart?.grafik_djj || []);
        } else {
          setGrafikTFU([]);
          setGrafikDJJ([]);
        }
      } catch (err) {
        console.error("FETCH ERROR:", err);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [id]);

  const handleChange = (e) =>
    setForm({ ...form, [e.target.name]: e.target.value });

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!kehamilan) return;

    setSaving(true);

    try {
      const payload = {
        kehamilan_id: kehamilan.id,
        tanggal_bulan_tahun: form.tanggal_bulan_tahun || null,
        usia_gestasi_minggu: Number(form.usia_gestasi_minggu),
        tinggi_fundus_uteri_cm: Number(form.tinggi_fundus_uteri_cm),
        denyut_jantung_bayi_x_menit: Number(form.denyut_jantung_bayi_x_menit),
      };

      await createGrafik(payload);

      setOpenModal(false);

      const chart = await getGrafikChart(kehamilan.id);

      // 🔥 FIX JUGA DI SINI
      setGrafikTFU(chart?.data?.grafik_tfu || []);
      setGrafikDJJ(chart?.data?.grafik_djj || []);
      await Swal.fire({
        icon: 'success',
        title: 'Berhasil',
        text: 'Data berhasil disimpan',
        timer: 1500,
        showConfirmButton: false
      });
    } catch (err) {
      console.error(err);
      Swal.fire('Error', 'Gagal menyimpan data', 'error');
    } finally {
      setSaving(false);
    }
  };

  // =========================
  // TFU CHART (KIA)
  // =========================
  const chartTFUData = {
    labels: grafikTFU.map((d) => `Usia ${d.usia} minggu`),

    datasets: [
      {
        label: "TFU (cm)",
        data: grafikTFU.map((d) => d.tfu),
        borderColor: "#2563eb",
        borderWidth: 3,
        pointRadius: 6,
        fill: false,
      },
      {
        label: "Normal",
        data: grafikTFU.map((d) => d.normal),
        borderColor: "#16a34a",
        borderWidth: 2,
        pointRadius: 0,
      },
      {
        label: "Upper",
        data: grafikTFU.map((d) => d.upper),
        borderColor: "#f59e0b",
        borderDash: [6, 4],
        pointRadius: 0,
      },
      {
        label: "Lower",
        data: grafikTFU.map((d) => d.lower),
        borderColor: "#ef4444",
        borderDash: [6, 4],
        pointRadius: 0,
      },
    ],
  };

  // =========================
  // DJJ CHART (KIA)
  // =========================
  const chartDJJData = {
    labels: grafikDJJ.map((d) => `Usia ${d.usia} minggu`),

    datasets: [
      {
        label: "DJJ (bpm)",
        data: grafikDJJ.map((d) => d.djj),
        borderColor: "#dc2626",
        borderWidth: 3,
        pointRadius: 6,
        fill: false,
      },
      {
        label: "Batas Bawah (110)",
        data: grafikDJJ.map(() => 110),
        borderColor: "#ef4444",
        borderDash: [6, 4],
        pointRadius: 0,
      },
      {
        label: "Batas Atas (160)",
        data: grafikDJJ.map(() => 160),
        borderColor: "#f59e0b",
        borderDash: [6, 4],
        pointRadius: 0,
      },
    ],
  };

  if (loading)
    return (
      <MainLayout>
        <div className="p-6">Memuat data...</div>
      </MainLayout>
    );

  return (
    <MainLayout>
      <div className="p-6 max-w-6xl mx-auto">

        <div className="flex justify-between mb-4">
          <div>
            <h1 className="text-2xl font-bold">
              Monitoring Kehamilan (TFU & DJJ)
            </h1>
            <p className="text-gray-500">
              Grafik KIA berbasis usia gestasi
            </p>
          </div>

          <button
            onClick={() => setOpenModal(true)}
            className="bg-indigo-600 text-white px-4 py-2 rounded-lg"
          >
            + Input Pemeriksaan
          </button>
        </div>

        {/* TFU */}
        <div className="bg-white p-4 rounded-xl shadow mb-6">
          <h2 className="font-semibold mb-2">📊 TFU</h2>
          <div className="h-80">
            <Line data={chartTFUData} />
          </div>
        </div>

        {/* DJJ */}
        <div className="bg-white p-4 rounded-xl shadow">
          <h2 className="font-semibold mb-2">❤️ DJJ</h2>
          <div className="h-80">
            <Line data={chartDJJData} />
          </div>
        </div>

      </div>

      {/* MODAL */}
      {openModal && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
          <div className="bg-white w-full max-w-lg p-6 rounded-xl relative">

            <button
              onClick={() => setOpenModal(false)}
              className="absolute right-4 top-4"
            >
              <X />
            </button>

            <form onSubmit={handleSubmit} className="space-y-3">

              <input type="date" name="tanggal_bulan_tahun"
                value={form.tanggal_bulan_tahun}
                onChange={handleChange}
                className="border p-2 w-full rounded"
              />

              <input type="number" name="usia_gestasi_minggu"
                placeholder="Usia"
                onChange={handleChange}
                className="border p-2 w-full rounded"
              />

              <input type="number" name="tinggi_fundus_uteri_cm"
                placeholder="TFU"
                onChange={handleChange}
                className="border p-2 w-full rounded"
              />

              <input type="number" name="denyut_jantung_bayi_x_menit"
                placeholder="DJJ"
                onChange={handleChange}
                className="border p-2 w-full rounded"
              />

              <button
                type="submit"
                disabled={saving}
                className="bg-indigo-600 text-white w-full py-2 rounded"
              >
                <Save size={18} />
                {saving ? "Menyimpan..." : "Simpan"}
              </button>
            </form>
          </div>
        </div>
      )}

    </MainLayout>
  );
}