// src/pages/DetailPenduduk.jsx
import { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import MainLayout from "../components/Layout/MainLayout";
import api from "../services/api";

// Komponen modal untuk detail pemeriksaan (bisa dipisah ke file sendiri)
function DetailPemeriksaanModal({ data, onClose }) {
  if (!data) return null;

  const { jawaban, ...detail } = data;

  const formatValue = (value) => {
    if (typeof value === 'boolean') return value ? 'Ya' : 'Tidak';
    if (value === null || value === undefined) return '-';
    if (typeof value === 'number') return value.toFixed(1).replace(/\.0$/, '');
    return value;
  };

  const formatKey = (key) => {
    return key.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-xl max-w-4xl w-full max-h-[90vh] overflow-y-auto">
        <div className="sticky top-0 bg-white border-b p-4 flex justify-between items-center">
          <div>
            <h2 className="text-xl font-bold">Detail Pemeriksaan</h2>
            <p className="text-gray-500 text-sm">{detail.nama_penduduk} • {detail.kelompok}</p>
          </div>
          <button onClick={onClose} className="text-gray-400 text-2xl hover:text-gray-600">&times;</button>
        </div>

        <div className="p-6 space-y-6">
          {/* Informasi umum */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 bg-gray-50 p-4 rounded-lg">
            <div><span className="font-medium">Tanggal Pemeriksaan:</span> {new Date(detail.tanggal_pemeriksaan).toLocaleDateString('id-ID')}</div>
            <div><span className="font-medium">Versi Form:</span> {detail.versi_form || '-'}</div>
            <div>
              <span className="font-medium">Kategori Risiko:</span>
              <span className={`ml-2 px-2 py-0.5 rounded-full text-xs ${
                detail.kategori_risiko === 'Tinggi' ? 'bg-red-100 text-red-700' :
                detail.kategori_risiko === 'Sedang' ? 'bg-yellow-100 text-yellow-700' : 'bg-green-100 text-green-700'
              }`}>{detail.kategori_risiko || 'Normal'}</span>
            </div>
            <div><span className="font-medium">Rekomendasi:</span> {detail.rekomendasi || '-'}</div>
          </div>

          {/* Jawaban Pemeriksaan */}
          <div>
            <h3 className="text-lg font-semibold mb-3 border-b pb-1">Jawaban Pemeriksaan</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              {jawaban && Object.keys(jawaban).length > 0 ? (
                Object.entries(jawaban).map(([key, value]) => (
                  <div key={key} className="flex justify-between items-center border-b py-1">
                    <span className="text-gray-600 text-sm">{formatKey(key)}</span>
                    <span className="font-medium text-sm">{formatValue(value)}</span>
                  </div>
                ))
              ) : (
                <div className="text-gray-500 italic">Tidak ada data jawaban</div>
              )}
            </div>
          </div>
        </div>

        <div className="border-t p-4 flex justify-end">
          <button onClick={onClose} className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">Tutup</button>
        </div>
      </div>
    </div>
  );
}

export default function DetailPenduduk() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [dataDiri, setDataDiri] = useState(null);
  const [riwayat, setRiwayat] = useState([]);
  const [error, setError] = useState(null);
  
  // State untuk modal detail pemeriksaan
  const [modalOpen, setModalOpen] = useState(false);
  const [selectedPemeriksaan, setSelectedPemeriksaan] = useState(null);
  const [loadingDetail, setLoadingDetail] = useState(false);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        // Ambil data diri (jika ada endpoint)
        try {
          const resDiri = await api.get(`/tenaga-kesehatan/penduduk/${id}`);
          setDataDiri(resDiri.data.data || resDiri.data);
        } catch (err) {
          console.warn("Gagal ambil data diri", err);
        }

        // Ambil riwayat (array)
        const resRiwayat = await api.get(`/tenaga-kesehatan/penduduk/${id}/riwayat`);
        const riwayatData = Array.isArray(resRiwayat.data) ? resRiwayat.data : [];
        setRiwayat(riwayatData);
      } catch (err) {
        console.error(err);
        setError("Gagal memuat data penduduk");
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [id]);

  const handleDetailClick = async (pemeriksaanId) => {
    setLoadingDetail(true);
    try {
      const response = await api.get(`/tenaga-kesehatan/pemeriksaan/${pemeriksaanId}`);
      setSelectedPemeriksaan(response.data.data);
      setModalOpen(true);
    } catch (err) {
      console.error(err);
      alert("Gagal memuat detail pemeriksaan");
    } finally {
      setLoadingDetail(false);
    }
  };

  const formatDate = (dateStr) => {
    if (!dateStr) return "-";
    return new Date(dateStr).toLocaleDateString("id-ID", {
      year: "numeric",
      month: "long",
      day: "numeric",
    });
  };

  const getRiskBadge = (risiko) => {
    if (!risiko) return "bg-gray-100 text-gray-700";
    const r = risiko.toLowerCase();
    if (r === "tinggi") return "bg-red-100 text-red-700";
    if (r === "sedang") return "bg-yellow-100 text-yellow-700";
    return "bg-green-100 text-green-700";
  };

  if (loading) return <MainLayout><div className="p-4 text-center">Memuat data...</div></MainLayout>;
  if (error) return <MainLayout><div className="p-4 text-center text-red-600">{error}</div></MainLayout>;

  // Urutkan riwayat dari terbaru ke terlama
  const sortedRiwayat = [...riwayat].sort(
    (a, b) => new Date(b.tanggal_pemeriksaan) - new Date(a.tanggal_pemeriksaan)
  );

  return (
    <MainLayout>
      <div className="max-w-6xl mx-auto p-4">
        <button onClick={() => navigate(-1)} className="mb-4 text-blue-600 hover:underline">← Kembali</button>

        {/* Data Diri */}
        {dataDiri && (
          <div className="bg-white rounded-xl shadow-md p-6 mb-6">
            <h2 className="text-lg font-bold mb-4 border-b pb-2">Data Diri</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              <div><span className="text-gray-500">Nama:</span> {dataDiri.nama_lengkap || "-"}</div>
              <div><span className="text-gray-500">NIK:</span> {dataDiri.nik || "-"}</div>
              <div><span className="text-gray-500">Tanggal Lahir:</span> {dataDiri.tanggal_lahir ? formatDate(dataDiri.tanggal_lahir) : "-"}</div>
              <div><span className="text-gray-500">Jenis Kelamin:</span> {dataDiri.jenis_kelamin || "-"}</div>
              <div><span className="text-gray-500">Dusun:</span> {dataDiri.dusun || "-"}</div>
              <div><span className="text-gray-500">Usia:</span> {dataDiri.usia || "-"} tahun</div>
            </div>
          </div>
        )}

        {/* Riwayat Pemeriksaan */}
        <div className="bg-white rounded-xl shadow-md p-6">
          <h2 className="text-lg font-bold mb-4 border-b pb-2">Riwayat Pemeriksaan</h2>
          {sortedRiwayat.length === 0 ? (
            <div className="text-center text-gray-500 py-8">Belum ada pemeriksaan.</div>
          ) : (
            <div className="space-y-3">
              {sortedRiwayat.map((item) => (
                <div key={item.id} className="border rounded-lg p-4 hover:bg-gray-50 transition cursor-pointer" onClick={() => handleDetailClick(item.id)}>
                  <div className="flex justify-between items-center">
                    <div className="flex flex-wrap items-center gap-2">
                      <span className="font-medium">{formatDate(item.tanggal_pemeriksaan)}</span>
                      <span className="text-sm text-gray-500">({item.kelompok})</span>
                      <span className={`inline-block px-2 py-0.5 rounded-full text-xs ${getRiskBadge(item.kategori_risiko)}`}>
                        {item.kategori_risiko || "Normal"}
                      </span>
                    </div>
                    <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                    </svg>
                  </div>
                  {item.rekomendasi && (
                    <div className="mt-2 text-sm text-blue-700 truncate">
                      <span className="font-medium">Rekomendasi:</span> {item.rekomendasi}
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Modal Detail Pemeriksaan */}
      {modalOpen && (
        <DetailPemeriksaanModal
          data={selectedPemeriksaan}
          onClose={() => {
            setModalOpen(false);
            setSelectedPemeriksaan(null);
          }}
        />
      )}
      {loadingDetail && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white p-4 rounded-lg">Memuat detail...</div>
        </div>
      )}
    </MainLayout>
  );
}