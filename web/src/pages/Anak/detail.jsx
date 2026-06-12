import React, { useEffect, useState } from "react";
import MainLayout from "../../components/Layout/MainLayout";
import { useParams } from "react-router-dom";
import { getAnakById } from "../../services/Anak";

export default function DetailAnak() {
  const { id } = useParams();
  const [data, setData] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      const res = await getAnakById(id);
      setData(res.data);
    };

    fetchData();
  }, [id]);

  if (!data) return <div>Loading...</div>;

  return (
    <MainLayout>
      <h1>Detail Anak</h1>

      <p>Nama: {data.nama}</p>
      <p>JK: {data.jenis_kelamin}</p>
      <p>Ibu: {data.kehamilan?.ibu?.nama_ibu}</p>
      <p>Tanggal lahir: {data.tanggal_lahir}</p>
      <p>Berat: {data.berat_lahir_kg}</p>
    </MainLayout>
  );
}