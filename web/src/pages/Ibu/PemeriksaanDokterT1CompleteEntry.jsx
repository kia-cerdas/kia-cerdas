import React, { useEffect, useState } from "react";
import { useParams, Navigate } from "react-router-dom";
import MainLayout from "../../components/Layout/MainLayout";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import { getDokterT1CompleteByKehamilanId } from "../../services/pemeriksaanDokter";
import { Loader2 } from "lucide-react";

export default function PemeriksaanDokterT1CompleteEntry() {
  const { id } = useParams();
  const [checking, setChecking] = useState(true);
  const [hasData, setHasData] = useState(false);
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
        const res = await getDokterT1CompleteByKehamilanId(aktif.id);
        if (res && res.dokter) {
          setHasData(true);
        } else {
          setHasData(false);
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

  if (hasData) {
    return <Navigate to={`/data-ibu/${id}/pemeriksaan-dokter-t1-complete/detail`} replace />;
  } else {
    return <Navigate to={`/data-ibu/${id}/pemeriksaan-dokter-t1-complete/form`} replace />;
  }
}