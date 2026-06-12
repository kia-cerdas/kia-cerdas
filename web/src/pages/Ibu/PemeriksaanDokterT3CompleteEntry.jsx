import React, { useEffect, useState } from "react";
import { useParams, Navigate, useNavigate } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import { getDokterT3CompleteByKehamilanId } from "../../services/pemeriksaanDokter";
import { getCurrentUser, isDokterUser } from "../../services/auth";
import { Loader2, Lock } from "lucide-react";

export default function PemeriksaanDokterT3CompleteEntry() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [checking, setChecking] = useState(true);
  const [hasData, setHasData] = useState(false);
  const [noAccess, setNoAccess] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    const checkData = async () => {
      try {
        const kehamilanList = await getKehamilanByIbuId(id);
        if (!kehamilanList || kehamilanList.length === 0) {
          setError("Data kehamilan tidak ditemukan.");
          setChecking(false);
          return;
        }
        const aktif = kehamilanList[0];
        const res = await getDokterT3CompleteByKehamilanId(aktif.id);
        const dataExists = Boolean(res && res.dokter);
        setHasData(dataExists);

        const isDokter = isDokterUser(getCurrentUser());
        if (!dataExists && !isDokter) {
          setNoAccess(true);
        }
      } catch (err) {
        console.error(err);
        setError("Gagal memeriksa data.");
      } finally {
        setChecking(false);
      }
    };
    checkData();
  }, [id]);

  if (checking) {
    return (
      <MainLayout>
        <div className="p-6 text-center flex items-center justify-center">
          <Loader2 className="animate-spin mr-2" /> Memeriksa data...
        </div>
      </MainLayout>
    );
  }

  if (error) {
    return (
      <MainLayout>
        <div className="p-6 text-center text-red-600">{error}</div>
      </MainLayout>
    );
  }

  if (noAccess) {
    return (
      <MainLayout>
        <div className="p-6 max-w-2xl mx-auto mt-10">
          <div className="bg-blue-50 border border-blue-200 rounded-2xl p-8 text-center">
            <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <Lock size={32} className="text-blue-500" />
            </div>
            <h2 className="text-xl font-bold text-blue-700 mb-2">
              Belum Ada Data Pemeriksaan
            </h2>
            <p className="text-gray-600 mb-6 text-sm">
              Hanya dokter yang dapat menambahkan data pemeriksaan dokter
              trimester 3. Silakan hubungi dokter untuk pengisian data.
            </p>
            <button
              onClick={() => navigate(`/data-ibu/${id}`)}
              className="bg-blue-600 text-white px-6 py-2 rounded-lg text-sm font-medium hover:bg-blue-700 transition"
            >
              Kembali
            </button>
          </div>
        </div>
      </MainLayout>
    );
  }

  if (hasData) {
    return <Navigate to={`/data-ibu/${id}/pemeriksaan-dokter-t3-complete/detail`} replace />;
  }

  return <Navigate to={`/data-ibu/${id}/pemeriksaan-dokter-t3-complete/form`} replace />;
}
