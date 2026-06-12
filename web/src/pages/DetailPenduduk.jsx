// src/pages/DetailPenduduk.jsx
import { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import MainLayout from "../components/Layout/MainLayout";
import api from "../services/api";

export default function DetailPenduduk() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [data, setData] = useState(null);
  const [error, setError] = useState(null);
  const [expandedId, setExpandedId] = useState(null);
  const [detailMap, setDetailMap] = useState({});
  const [loadingDetail, setLoadingDetail] = useState({});
  const [latestDetail, setLatestDetail] = useState(null);
  const [loadingLatest, setLoadingLatest] = useState(false);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const response = await api.get(`/tenaga-kesehatan/penduduk/${id}/riwayat-card`);
        const result = response.data?.data || response.data;
        setData(result);
        
        // Jika ada pemeriksaan terakhir, langsung ambil detailnya
        const riwayat = result?.riwayat || [];
        if (riwayat.length > 0) {
          const latestId = riwayat[0].id;
          await fetchLatestDetail(latestId);
        }
      } catch (err) {
        console.error(err);
        setError("Gagal memuat data penduduk");
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [id]);

  // Ambil detail pemeriksaan terakhir (langsung tanpa menunggu klik)
  const fetchLatestDetail = async (pemeriksaanId) => {
    setLoadingLatest(true);
    try {
      const response = await api.get(`/tenaga-kesehatan/pemeriksaan/${pemeriksaanId}`);
      const detail = response.data?.data || response.data;
      setLatestDetail(detail);
    } catch (err) {
      console.error("Gagal ambil detail terakhir:", err);
    } finally {
      setLoadingLatest(false);
    }
  };

  // Ambil detail pemeriksaan untuk riwayat (saat diklik)
  const fetchDetailPemeriksaan = async (pemeriksaanId) => {
    if (detailMap[pemeriksaanId]) return;
    
    setLoadingDetail(prev => ({ ...prev, [pemeriksaanId]: true }));
    try {
      const response = await api.get(`/tenaga-kesehatan/pemeriksaan/${pemeriksaanId}`);
      const detail = response.data?.data || response.data;
      setDetailMap(prev => ({ ...prev, [pemeriksaanId]: detail }));
    } catch (err) {
      console.error("Gagal ambil detail:", err);
      setDetailMap(prev => ({ ...prev, [pemeriksaanId]: { error: true } }));
    } finally {
      setLoadingDetail(prev => ({ ...prev, [pemeriksaanId]: false }));
    }
  };

  const toggleDetail = async (id) => {
    if (expandedId === id) {
      setExpandedId(null);
    } else {
      setExpandedId(id);
      await fetchDetailPemeriksaan(id);
    }
  };

  if (loading) return <MainLayout><div className="p-4 text-center">Memuat data...</div></MainLayout>;
  if (error) return <MainLayout><div className="p-4 text-center text-red-600">{error}</div></MainLayout>;
  if (!data) return <MainLayout><div className="p-4 text-center">Data tidak ditemukan</div></MainLayout>;

  const { data_diri, riwayat: rawRiwayat } = data;
  const riwayat = Array.isArray(rawRiwayat) ? rawRiwayat : [];
  const latest = riwayat.length > 0 ? riwayat[0] : null;

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

  const formatValue = (val) => {
    if (val === null || val === undefined) return '-';
    if (typeof val === 'boolean') return val ? 'Ya' : 'Tidak';
    if (typeof val === 'number') return val.toFixed(1).replace(/\.0$/, '');
    return val;
  };

  // Field yang umum untuk ditampilkan
  const detailFields = [
    { key: 'tekanan_darah', label: 'Tekanan Darah', unit: 'mmHg' },
    { key: 'tekanan_darah_sistole', label: 'Tekanan Darah Sistole', unit: 'mmHg' },
    { key: 'tekanan_darah_diastole', label: 'Tekanan Darah Diastole', unit: 'mmHg' },
    { key: 'gula_darah', label: 'Gula Darah', unit: 'mg/dL' },
    { key: 'gula_darah_puasa', label: 'Gula Darah Puasa', unit: 'mg/dL' },
    { key: 'kolesterol', label: 'Kolesterol', unit: 'mg/dL' },
    { key: 'kolesterol_total', label: 'Kolesterol Total', unit: 'mg/dL' },
    { key: 'asam_urat', label: 'Asam Urat', unit: 'mg/dL' },
    { key: 'kadar_hb', label: 'Kadar HB', unit: 'g/dL' },
    { key: 'hemoglobin', label: 'Hemoglobin', unit: 'g/dL' },
    { key: 'berat_badan', label: 'Berat Badan', unit: 'kg' },
    { key: 'tinggi_badan', label: 'Tinggi Badan', unit: 'cm' },
    { key: 'imt', label: 'IMT', unit: '' },
    { key: 'status_gizi', label: 'Status Gizi', unit: '' },
    { key: 'lingkar_perut', label: 'Lingkar Perut', unit: 'cm' },
    { key: 'lingkar_kepala', label: 'Lingkar Kepala', unit: 'cm' },
    { key: 'hasil_lila', label: 'Hasil LILA', unit: 'cm' },
    { key: 'status_bb_u', label: 'Status BB/U', unit: '' },
    { key: 'status_tb_u', label: 'Status TB/U', unit: '' },
    { key: 'status_imt_u', label: 'Status IMT/U', unit: '' },
    { key: 'status_bb_tb', label: 'Status BB/TB', unit: '' },
    { key: 'status_lk_u', label: 'Status LK/U', unit: '' },
    { key: 'jumlah_gigi', label: 'Jumlah Gigi', unit: '' },
    { key: 'gigi_berlubang', label: 'Gigi Berlubang', unit: '' },
    { key: 'status_plak', label: 'Status Plak Gigi', unit: '' },
    { key: 'resiko_gigi_berlubang', label: 'Resiko Gigi Berlubang', unit: '' },
    { key: 'masih_menyusui', label: 'Masih Menyusui (ASI)', unit: '' },
    { key: 'frekuensi_menyusui', label: 'Frekuensi Menyusui', unit: 'kali/hari' },
    { key: 'asi_perah', label: 'Diberikan ASI Perah', unit: '' },
    { key: 'jenis_pemberian_susu', label: 'Jenis Pemberian Susu', unit: '' },
    { key: 'menggunakan_formula', label: 'Menggunakan Formula', unit: '' },
    { key: 'alasan_formula', label: 'Alasan Susu Formula', unit: '' },
    { key: 'diberikan_mpasi', label: 'Diberikan MPASI', unit: '' },
    { key: 'usia_mulai_mpasi', label: 'Usia Mulai MPASI', unit: 'bulan' },
    { key: 'jumlah_makan_perporsi', label: 'Jumlah Makan MPASI', unit: '' },
    { key: 'frekuensi_makan_perhari', label: 'Frekuensi Makan MPASI', unit: '' },
    { key: 'obat_cacing', label: 'Pemberian Obat Cacing', unit: '' },
    { key: 'imunisasi_diberikan', label: 'Vaksin Imunisasi', unit: '' },
    { key: 'suhu', label: 'Suhu Tubuh', unit: '°C' },
    { key: 'status_pemantauan', label: 'Status Pemantauan', unit: '' },
    { key: 'riwayat_penyakit', label: 'Riwayat Penyakit', unit: '' },
    { key: 'status_kemandirian', label: 'Status Kemandirian', unit: '' },
    { key: 'riwayat_jatuh', label: 'Riwayat Jatuh', unit: '' },
  ];

  return (
    <MainLayout>
      <div className="max-w-6xl mx-auto p-4">
        <button
          onClick={() => navigate(-1)}
          className="mb-4 text-blue-600 hover:underline flex items-center gap-1"
        >
          ← Kembali
        </button>

        {/* Dua kolom: Data Diri (kiri) dan Pemeriksaan Terakhir (kanan) */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
          {/* Kiri: Data Diri */}
          <div className="bg-white rounded-xl shadow-md p-6">
            <h2 className="text-lg font-bold mb-4 border-b pb-2">Data Diri</h2>
            <div className="space-y-3">
              <div><div className="text-sm text-gray-500">Nama</div><div className="font-medium">{data_diri?.nama_lengkap || '-'}</div></div>
              <div><div className="text-sm text-gray-500">NIK</div><div className="font-medium">{data_diri?.nik || '-'}</div></div>
              <div><div className="text-sm text-gray-500">Tanggal Lahir</div><div className="font-medium">{formatDate(data_diri?.tanggal_lahir)}</div></div>
              <div><div className="text-sm text-gray-500">Jenis Kelamin</div><div className="font-medium">{data_diri?.jenis_kelamin || '-'}</div></div>
              <div><div className="text-sm text-gray-500">Dusun</div><div className="font-medium">{data_diri?.dusun || '-'}</div></div>
              <div><div className="text-sm text-gray-500">Usia</div><div className="font-medium">{data_diri?.usia !== undefined && data_diri?.usia !== null ? data_diri.usia : '-'} tahun</div></div>
              <div><div className="text-sm text-gray-500">Agama</div><div className="font-medium">{data_diri?.agama || '-'}</div></div>
              <div><div className="text-sm text-gray-500">Pekerjaan</div><div className="font-medium">{data_diri?.pekerjaan || '-'}</div></div>
            </div>
          </div>

          {/* Kanan: Pemeriksaan Terakhir - Langsung tampilkan detail */}
          <div className="bg-white rounded-xl shadow-md p-6">
            <h2 className="text-lg font-bold mb-4 border-b pb-2">Pemeriksaan Terakhir</h2>
            {!latest ? (
              <div className="text-center text-gray-500 py-8">Belum ada pemeriksaan.</div>
            ) : loadingLatest ? (
              <div className="text-center py-8 text-gray-500">Memuat detail pemeriksaan...</div>
            ) : latestDetail ? (
              <div className="space-y-4">
                {/* Informasi dasar */}
                <div className="grid grid-cols-2 gap-4 pb-3 border-b">
                  <div>
                    <div className="text-sm text-gray-500">Tanggal Pemeriksaan</div>
                    <div className="font-medium">{formatDate(latest.tanggal_pemeriksaan)}</div>
                  </div>
                  <div>
                    <div className="text-sm text-gray-500">Kategori</div>
                    <div className="font-medium">{latest.kategori || '-'}</div>
                  </div>
                  <div>
                    <div className="text-sm text-gray-500">Kategori Risiko</div>
                    <div className={`inline-block px-2 py-1 rounded-full text-xs font-medium ${getRiskBadge(latest.kategori_risiko)}`}>
                      {latest.kategori_risiko || 'Normal'}
                    </div>
                  </div>
                </div>

                {/* Detail Pemeriksaan */}
                <div>
                  <h3 className="font-semibold text-md mb-2 text-gray-700">Detail Pemeriksaan</h3>
                  <div className="grid grid-cols-2 gap-3 text-sm">
                    {detailFields.map((field) => {
                      const value = (latestDetail.jawaban && latestDetail.jawaban[field.key] !== undefined)
                        ? latestDetail.jawaban[field.key]
                        : latestDetail[field.key];
                      if (value === undefined || value === null || value === "") return null;
                      return (
                        <div key={field.key} className="flex justify-between items-center border-b py-1">
                          <span className="text-gray-600">{field.label}</span>
                          <span className="font-medium">
                            {formatValue(value)} {field.unit}
                          </span>
                        </div>
                      );
                    })}
                    
                    {/* Tampilkan jawaban lain yang tidak ada di daftar field */}
                    {latestDetail.jawaban && Object.entries(latestDetail.jawaban)
                      .filter(([key]) => !detailFields.some(f => f.key === key))
                      .map(([key, value]) => (
                        <div key={key} className="flex justify-between items-center border-b py-1 col-span-2">
                          <span className="text-gray-600">{key.replace(/_/g, ' ').toUpperCase()}</span>
                          <span className="font-medium">{formatValue(value)}</span>
                        </div>
                      ))
                    }
                  </div>
                </div>

                {/* Rekomendasi */}
                {(latestDetail.rekomendasi || latest.rekomendasi) && (
                  <div className="mt-3 pt-3 border-t">
                    <div className="text-sm text-gray-500">Rekomendasi</div>
                    <div className="font-medium text-blue-700">
                      {latestDetail.rekomendasi || latest.rekomendasi}
                    </div>
                  </div>
                )}

                {/* Catatan Khusus */}
                {latestDetail.catatan_khusus && (
                  <div className="mt-2">
                    <div className="text-sm text-gray-500">Catatan Khusus</div>
                    <div className="font-medium text-gray-700">{latestDetail.catatan_khusus}</div>
                  </div>
                )}
              </div>
            ) : (
              <div className="text-center py-8 text-gray-500">Tidak ada detail pemeriksaan</div>
            )}
          </div>
        </div>

        {/* Riwayat Pemeriksaan - Tetap dengan klik untuk detail */}
        {riwayat.length > 0 && (
          <div className="bg-white rounded-xl shadow-md p-6">
            <h2 className="text-lg font-bold mb-4 border-b pb-2">Riwayat Pemeriksaan</h2>
            <div className="space-y-3">
              {riwayat.map((item) => {
                const isLoading = loadingDetail[item.id];
                const detail = detailMap[item.id];
                return (
                  <div key={item.id} className="border rounded-lg overflow-hidden">
                    <button
                      onClick={() => toggleDetail(item.id)}
                      className="w-full text-left px-4 py-3 bg-gray-50 hover:bg-gray-100 flex justify-between items-center"
                    >
                      <div className="flex flex-wrap items-center gap-2">
                        <span className="font-medium">{formatDate(item.tanggal_pemeriksaan)}</span>
                        <span className="text-sm text-gray-500">({item.kategori || '-'})</span>
                        <span className={`inline-block px-2 py-0.5 rounded-full text-xs ${getRiskBadge(item.kategori_risiko)}`}>
                          {item.kategori_risiko || 'Normal'}
                        </span>
                      </div>
                      <svg className={`w-5 h-5 transform transition-transform ${expandedId === item.id ? 'rotate-180' : ''}`} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                      </svg>
                    </button>
                    
                    {expandedId === item.id && (
                      <div className="px-4 py-3 bg-white border-t">
                        {isLoading ? (
                          <div className="text-center text-gray-500">Memuat detail...</div>
                        ) : detail ? (
                          <div className="space-y-2">
                            {/* Detail dari jawaban */}
                            {detail.jawaban && Object.entries(detail.jawaban).length > 0 && (
                              <div className="grid grid-cols-2 gap-2 text-sm">
                                {Object.entries(detail.jawaban).map(([key, value]) => (
                                  <div key={key} className="flex justify-between">
                                    <span className="text-gray-600">{key.replace(/_/g, ' ')}</span>
                                    <span className="font-medium">{formatValue(value)}</span>
                                  </div>
                                ))}
                              </div>
                            )}
                            
                            {/* Rekomendasi */}
                            {(detail.rekomendasi || item.rekomendasi) && (
                              <div className="mt-2 pt-2 border-t text-blue-700">
                                <span className="font-medium">Rekomendasi:</span> {detail.rekomendasi || item.rekomendasi}
                              </div>
                            )}
                            
                            {/* Catatan */}
                            {detail.catatan_khusus && (
                              <div className="text-sm">
                                <span className="font-medium text-gray-600">Catatan:</span> {detail.catatan_khusus}
                              </div>
                            )}
                          </div>
                        ) : (
                          <div className="text-gray-500">Tidak ada detail tambahan</div>
                        )}
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          </div>
        )}
      </div>
    </MainLayout>
  );
}