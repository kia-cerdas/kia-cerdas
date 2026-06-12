import React, { useState, useEffect } from "react";
import { useParams, Link } from "react-router-dom";
import MainLayout from "../../../components/Layout/MainLayout";
import { ChevronLeft, ClipboardList, Info } from "lucide-react";
import { getAnakById } from "../../../services/Anak";
import {
  getRentangUsia,
  getKategoriByRentang,
  getPemantauanHistory,
  savePemantauanAnak
} from "../../../services/pemantauanAnak";
import LembarPemantauanTable from "../../../components/Pemantauan/LembarPemantauanTable";

export default function PemantauanAnakPage() {
  const { id } = useParams();
  const [child, setChild] = useState(null);
  const [rentangList, setRentangList] = useState([]);
  const [selectedRentangId, setSelectedRentangId] = useState("");
  const [kategoriList, setKategoriList] = useState([]);
  const [history, setHistory] = useState([]);
  const [loading, setLoading] = useState(true);
  const [loadingTable, setLoadingTable] = useState(false);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [resAnak, resRentang] = await Promise.all([
          getAnakById(id),
          getRentangUsia()
        ]);
        setChild(resAnak.data || resAnak);
        setRentangList(resRentang || []);

        // Auto select first rentang or appropriate one
        if (resRentang.length > 0) {
          setSelectedRentangId(String(resRentang[0].id));
        }
      } catch (err) {
        console.error("Error fetching data:", err);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [id]);

  useEffect(() => {
    if (!selectedRentangId) return;

    const fetchTableData = async () => {
      setLoadingTable(true);
      try {
        const [resKat, resHist] = await Promise.all([
          getKategoriByRentang(selectedRentangId),
          getPemantauanHistory(id, selectedRentangId)
        ]);
        setKategoriList(resKat || []);
        setHistory(resHist || []);
      } catch (err) {
        console.error("Error fetching table data:", err);
      } finally {
        setLoadingTable(false);
      }
    };
    fetchTableData();
  }, [id, selectedRentangId]);

  const handleSaveCell = async (week, kategoriId, value) => {
    try {
      // Prepare payload. We need to send ALL details for that week if we follow the generic backend logic,
      // but the current backend Save logic creates or updates a whole record for a period.
      // So we find existing record for that week and update just this symptom.

      const existingRecord = history.find(r => r.periode_waktu === week);
      const currentDetails = existingRecord?.detail_gejala || [];

      let updatedDetails = [];
      const index = currentDetails.findIndex(d => d.kategori_tanda_sakit_id === kategoriId);

      if (index > -1) {
        updatedDetails = [...currentDetails];
        updatedDetails[index] = { ...updatedDetails[index], is_terjadi: value };
      } else {
        updatedDetails = [...currentDetails, { kategori_tanda_sakit_id: kategoriId, is_terjadi: value }];
      }

      // Format for backend request
      const payload = {
        anak_id: Number(id),
        rentang_usia_id: Number(selectedRentangId),
        periode_waktu: week,
        tanggal_periksa: new Date().toISOString().split('T')[0],
        nama_pemeriksa: "Bidan/Kader", // Should be from auth context ideally
        detail_gejala: updatedDetails.map(d => ({
          kategori_tanda_sakit_id: d.kategori_tanda_sakit_id,
          is_terjadi: d.is_terjadi
        }))
      };

      await savePemantauanAnak(payload);

      // Refresh history
      const newHistory = await getPemantauanHistory(id, selectedRentangId);
      setHistory(newHistory || []);
    } catch (err) {
      alert("Gagal menyimpan data: " + (err.response?.data?.message || err.message));
    }
  };

  if (loading) return <MainLayout><div className="p-10 text-center font-medium text-gray-400">Memuat...</div></MainLayout>;

  return (
    <MainLayout>
      <div className="p-4 md:p-8 bg-[#f8fafc] min-h-screen space-y-6">
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
          <div>
            <Link to={`/data-anak/dashboard/${id}`} className="flex items-center gap-1.5 text-xs text-gray-400 hover:text-indigo-600 mb-1 transition-all">
              <ChevronLeft size={14} /> Kembali ke Dashboard
            </Link>
            <h1 className="text-2xl font-bold text-gray-800 tracking-tight">Lembar Pemantauan</h1>
            <p className="text-sm text-gray-500">Pemantauan kondisi kesehatan {child.nama}</p>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
          <div className="lg:col-span-1 space-y-6">
            <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
              <h2 className="text-sm font-bold text-gray-800 mb-4 flex items-center gap-2">
                <ClipboardList size={18} className="text-blue-500" /> Pilih Rentang Usia
              </h2>
              <div className="space-y-2">
                {rentangList.map((rentang) => (
                  <button
                    key={rentang.id}
                    onClick={() => setSelectedRentangId(String(rentang.id))}
                    className={`w-full text-left px-4 py-3 rounded-xl text-sm font-medium transition-all ${selectedRentangId === String(rentang.id)
                      ? "bg-blue-600 text-white shadow-md shadow-blue-100"
                      : "bg-gray-50 text-gray-600 hover:bg-gray-100"
                      }`}
                  >
                    {rentang.nama_rentang}
                  </button>
                ))}
              </div>
            </div>

            <div className="bg-amber-50 p-6 rounded-2xl border border-amber-100">
              <h3 className="text-sm font-bold text-amber-800 mb-2 flex items-center gap-2">
                <Info size={18} /> Petunjuk
              </h3>
              <ul className="text-xs text-amber-700 space-y-2 list-disc pl-4">
                <li>Cek kondisi anak setiap minggu.</li>
                <li>Beri tanda centang (✔) jika kondisi di bawah ini ditemukan.</li>
                <li>Segera bawa ke Puskesmas/RS jika ditemukan tanda bahaya.</li>
                <li>Lembar ini diisi oleh Ibu di rumah dan diverifikasi oleh Nakes saat kunjungan.</li>
              </ul>
            </div>
          </div>

          <div className="lg:col-span-3">
            <LembarPemantauanTable
              rentangUsia={rentangList.find(r => String(r.id) === selectedRentangId)}
              kategoriList={kategoriList}
              history={history}
              onSaveCell={handleSaveCell}
              isLoading={loadingTable}
            />
          </div>
        </div>
      </div>
    </MainLayout>
  );
}
