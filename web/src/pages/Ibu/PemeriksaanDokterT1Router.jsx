import React, { useEffect, useState } from "react";
import { useParams, useNavigate, Routes, Route } from "react-router-dom";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import { getDokterT1CompleteByKehamilanId } from "../../services/pemeriksaanDokter";
import PemeriksaanDokterT1Detail from "./PemeriksaanDokterT1CompleteDetail";
import PemeriksaanDokterT1Form from "./PemeriksaanDokterT1Form";

export default function PemeriksaanDokterT1Router() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [hasData, setHasData] = useState(false);

  useEffect(() => {
    const checkData = async () => {
      try {
        const kehamilanList = await getKehamilanByIbuId(id);
        if (kehamilanList.length === 0) {
          setHasData(false);
          setLoading(false);
          return;
        }
        const aktif = kehamilanList[0];
        const res = await getDokterT1CompleteByKehamilanId(aktif.id);
        setHasData(!!(res && res.dokter));
      } catch (err) {
        console.error(err);
        setHasData(false);
      } finally {
        setLoading(false);
      }
    };
    checkData();
  }, [id]);

  if (loading) return null; // atau loading spinner

  // Jika data sudah ada, redirect ke halaman detail
  if (hasData) {
    // Gunakan Navigate component atau window.location, tapi lebih baik gunakan Navigate
    // Karena di dalam Router, kita bisa return <Navigate />
    return <Navigate to={`/data-ibu/${id}/pemeriksaan-dokter-t1-complete/detail`} replace />;
  }

  // Jika belum ada, tampilkan form create
  return <PemeriksaanDokterT1Form />;
}