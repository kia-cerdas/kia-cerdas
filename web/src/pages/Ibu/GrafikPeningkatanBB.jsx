import React, { useEffect, useState, useMemo } from "react";
import { useParams, useNavigate } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import {
  getGrafikBBByKehamilanId,
  createGrafikBB
} from "../../services/grafikBB";
import { Line } from "react-chartjs-2";
import { Save, ArrowLeft } from "lucide-react";
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  Filler
} from "chart.js";

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  Filler
);

export default function GrafikPeningkatanBB() {
  const { id } = useParams();
  const navigate = useNavigate();

  const [kehamilan, setKehamilan] = useState(null);
  const [grafikBBList, setGrafikBBList] = useState([]);
  const [loading, setLoading] = useState(true);

  // pagination
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 3;

  const [formBB, setFormBB] = useState({
    minggu_kehamilan: "",
    berat_badan: "",
    bb_pra_kehamilan_kg: "",
    kategori_imt_pra_kehamilan: "",
  });

  const [showModal, setShowModal] = useState(false);
  const [saving, setSaving] = useState(false);

  // ================= FETCH =================
  const fetchData = async () => {
    try {
      const kehamilanList = await getKehamilanByIbuId(id);
      if (kehamilanList.length > 0) {
        const aktif = kehamilanList[0];
        setKehamilan(aktif);

        const dataBB = await getGrafikBBByKehamilanId(aktif.id);
        if (dataBB) {
          setGrafikBBList(dataBB);

          setFormBB((prev) => ({
            ...prev,
            bb_pra_kehamilan_kg:
              aktif.bb_awal || dataBB[0]?.berat_badan,
            kategori_imt_pra_kehamilan:
              aktif.kategori_imt || "Normal",
          }));
        }
      }
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, [id]);

  // ================= CREATE =================
  const handleCreate = async (e) => {
    e.preventDefault();

    if (!formBB.minggu_kehamilan || !formBB.berat_badan) {
      alert("Field wajib diisi");
      return;
    }

    try {
      setSaving(true);

      const payload = {
        kehamilan_id: kehamilan.id,
        minggu_kehamilan: Number(formBB.minggu_kehamilan),
        berat_badan: parseFloat(formBB.berat_badan),
      };

      await createGrafikBB(payload);

      await fetchData();

      setFormBB((prev) => ({
        ...prev,
        minggu_kehamilan: "",
        berat_badan: "",
      }));

      setShowModal(false);
    } catch (err) {
      console.error(err);
      alert("Gagal menyimpan data");
    } finally {
      setSaving(false);
    }
  };

  // ================= MAP =================
  const metadataMap = useMemo(() => {
    const map = {};
    grafikBBList.forEach((item) => {
      map[item.minggu_kehamilan] = item;
    });
    return map;
  }, [grafikBBList]);

  // ================= IOM =================
  const getIOMBounds = (week, category, type) => {
    if (week < 12) return 0;

    const limits = {
      Underweight: { rateMin: 0.44, rateMax: 0.58 },
      Normal: { rateMin: 0.35, rateMax: 0.5 },
      Overweight: { rateMin: 0.23, rateMax: 0.33 },
      Obesitas: { rateMin: 0.17, rateMax: 0.27 },
    };

    const config = limits[category] || limits["Normal"];
    const progress = week - 12;

    return type === "min"
      ? progress * config.rateMin
      : progress * config.rateMax;
  };

  // ================= CHART =================
  const buildChartData = () => {
    const labels = Array.from({ length: 41 }, (_, i) => i);

    const baseline =
      formBB.bb_pra_kehamilan_kg ||
      grafikBBList[0]?.berat_badan ||
      0;

    const actual = labels.map((w) => {
      const entry = metadataMap[w];
      return entry ? entry.berat_badan - baseline : null;
    });

    const minBounds = labels.map((w) =>
      getIOMBounds(w, formBB.kategori_imt_pra_kehamilan, "min")
    );
    const maxBounds = labels.map((w) =>
      getIOMBounds(w, formBB.kategori_imt_pra_kehamilan, "max")
    );

    return {
      labels,
      datasets: [
        {
          label: "Peningkatan BB Ibu (kg)",
          data: actual,
          borderColor: "#10b981",
          borderWidth: 3,
          tension: 0.3,
          spanGaps: true,
          pointRadius: 5,
          pointHoverRadius: 7,
          pointBackgroundColor: (ctx) => {
            const item = metadataMap[ctx.dataIndex];
            if (!item) return "#ccc";
            if (item.status === "NORMAL") return "#10b981";
            if (item.status === "KURANG") return "#f59e0b";
            if (item.status === "BERLEBIH") return "#ef4444";
            return "#6b7280";
          },
        },
        {
          label: "Batas Atas",
          data: maxBounds,
          borderColor: "rgba(239,68,68,0.5)",
          borderDash: [5, 5],
          pointRadius: 0,
        },
        {
          label: "Batas Bawah",
          data: minBounds,
          borderColor: "rgba(245,158,11,0.5)",
          borderDash: [5, 5],
          pointRadius: 0,
        },
      ],
    };
  };

  // ================= PAGINATION =================
  const indexLast = currentPage * itemsPerPage;
  const currentData = grafikBBList.slice(
    indexLast - itemsPerPage,
    indexLast
  );
  const totalPages = Math.ceil(
    grafikBBList.length / itemsPerPage
  );

  if (loading) return <div className="p-6">Loading...</div>;

  return (
    <MainLayout>
      <div className="p-6 max-w-5xl mx-auto">

        {/* HEADER */}
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center gap-4">
            <button onClick={() => navigate(-1)}>
              <ArrowLeft />
            </button>
            <h1 className="text-2xl font-bold">
              Grafik Peningkatan Berat Badan
            </h1>
          </div>

          <button
            onClick={() => setShowModal(true)}
            className="bg-emerald-600 text-white px-4 py-2 rounded-lg"
          >
            + Tambah Data
          </button>
        </div>

        {/* GRAFIK */}
        <div className="bg-white p-6 rounded-xl border mb-6">
          <div className="h-100">
            <Line data={buildChartData()} />
          </div>
        </div>

        {/* RIWAYAT */}
        <div className="bg-white p-6 rounded-xl border mb-6">
          <h3 className="font-semibold mb-3">
            Riwayat Pemeriksaan
          </h3>

          {currentData.map((item) => (
            <div key={item.id} className="p-3 border rounded mb-2">
              <p className="font-medium">
                Minggu {item.minggu_kehamilan} - {item.status}
              </p>
              <p className="text-sm text-gray-600">
                {item.penjelasan_hasil_grafik}
              </p>
            </div>
          ))}

          <div className="flex justify-center gap-3 mt-4">
            <button
              disabled={currentPage === 1}
              onClick={() => setCurrentPage((p) => p - 1)}
              className="px-3 py-1 border rounded"
            >
              Prev
            </button>

            <span>
              {currentPage} / {totalPages}
            </span>

            <button
              disabled={currentPage === totalPages}
              onClick={() => setCurrentPage((p) => p + 1)}
              className="px-3 py-1 border rounded"
            >
              Next
            </button>
          </div>
        </div>

        {/* MODAL */}
        {showModal && (
          <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
            <div className="bg-white p-6 rounded-xl w-full max-w-md">
              <h3 className="font-semibold mb-4">
                Tambah Data
              </h3>

              <form onSubmit={handleCreate}>
                <input
                  type="number"
                  placeholder="Minggu"
                  className="border p-2 w-full mb-3 rounded"
                  value={formBB.minggu_kehamilan}
                  onChange={(e) =>
                    setFormBB({
                      ...formBB,
                      minggu_kehamilan: e.target.value,
                    })
                  }
                />

                <input
                  type="number"
                  placeholder="Berat badan"
                  className="border p-2 w-full mb-3 rounded"
                  value={formBB.berat_badan}
                  onChange={(e) =>
                    setFormBB({
                      ...formBB,
                      berat_badan: e.target.value,
                    })
                  }
                />

                <div className="flex justify-end gap-2">
                  <button
                    type="button"
                    onClick={() => setShowModal(false)}
                  >
                    Batal
                  </button>

                  <button className="bg-emerald-600 text-white px-3 py-1 rounded flex gap-2 items-center">
                    <Save size={16} />
                    {saving ? "..." : "Simpan"}
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}

      </div>
    </MainLayout>
  );
} 