import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { getKehamilanByIbuId } from "../../services/kehamilan";
import { getRencanaByKehamilanId } from "../../services/persalinan";
import MainLayout from "../../components/Layout/MainLayout";

export default function RencanaPersalinanRedirect() {
  const { id } = useParams(); // id ibu
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const checkAndRedirect = async () => {
      try {
        if (!id) {
          navigate("/dashboard");
          return;
        }
        const kehamilanList = await getKehamilanByIbuId(id);
        if (!kehamilanList.length) {
          navigate(`/data-ibu/${id}/rencana-persalinan/form`);
          return;
        }
        const kehamilan = kehamilanList[0];
        const rencanaData = await getRencanaByKehamilanId(kehamilan.id);
        if (rencanaData && rencanaData.length > 0) {
          const rencanaId = rencanaData[0].id_rencana_persalinan || rencanaData[0].id;
          if (rencanaId) {
            navigate(`/data-ibu/${id}/rencana-persalinan/detail?id=${rencanaId}`);
          } else {
            navigate(`/data-ibu/${id}/rencana-persalinan/form`);
          }
        } else {
          navigate(`/data-ibu/${id}/rencana-persalinan/form`);
        }
      } catch (err) {
        console.error(err);
        navigate(`/data-ibu/${id}/rencana-persalinan/form`);
      } finally {
        setLoading(false);
      }
    };
    checkAndRedirect();
  }, [id, navigate]);

  if (loading) {
    return (
      <MainLayout>
        <div className="p-6 text-center">Memeriksa data...</div>
      </MainLayout>
    );
  }
  return null;
}