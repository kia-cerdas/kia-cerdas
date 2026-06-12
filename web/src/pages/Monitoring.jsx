// src/pages/Monitoring.jsx
import React, { useEffect, useState } from "react";
import MainLayout from "../components/Layout/MainLayout";
import { getRekapWilayah, getDaftarRisikoTinggi, getPrioritasKunjungan } from "../services/monitoring";
import { MapPin, AlertTriangle, Calendar } from "lucide-react";

export default function Monitoring() {
  const [rekap, setRekap] = useState([]);
  const [risikoTinggi, setRisikoTinggi] = useState([]);
  const [prioritas, setPrioritas] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetch = async () => {
      try {
        const [r, rt, p] = await Promise.all([
          getRekapWilayah(),
          getDaftarRisikoTinggi(),
          getPrioritasKunjungan(),
        ]);
        setRekap(r);
        setRisikoTinggi(rt);
        setPrioritas(p);
      } catch (err) {
        console.error(err);
        // Mock data
        setRekap([
          { dusun: "Dusun Mawar", ibuHamil: 42, anak: 156, risikoTinggi: 12, cakupanImunisasi: 88.5 },
          { dusun: "Dusun Kenanga", ibuHamil: 35, anak: 124, risikoTinggi: 3, cakupanImunisasi: 96.2 },
        ]);
        setRisikoTinggi([
          { nama_ibu: "Anisa Nuraini", usia: 32, dusun: "Dusun III", status_kehamilan: "TRIMESTER 3" },
        ]);
        setPrioritas([
          { dusun: "Dusun Mawar", kasus: 12, priority: "High" },
          { dusun: "Dusun Kamboja", kasus: 8, priority: "High" },
        ]);
      } finally {
        setLoading(false);
      }
    };
    fetch();
  }, []);

  if (loading) return <MainLayout><div className="p-6">Memuat...</div></MainLayout>;

  return (
    <MainLayout>
      <div className="p-6">
        <h1 className="text-2xl font-bold mb-6">Monitoring Kesehatan</h1>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Rekap Wilayah */}
          <div className="bg-white rounded-xl shadow-sm p-4">
            <h2 className="text-lg font-semibold mb-4 flex items-center gap-2"><MapPin size={20} /> Rekap Wilayah</h2>
            <div className="overflow-x-auto">
              <table className="min-w-full">
                <thead className="bg-gray-50"><tr><th className="px-4 py-2 text-left">Dusun</th><th>Ibu Hamil</th><th>Anak</th><th>Risiko Tinggi</th><th>Imunisasi</th></tr></thead>
                <tbody>
                  {rekap.map((row, idx) => (
                    <tr key={idx} className="border-b"><td className="px-4 py-2">{row.dusun}</td><td>{row.ibuHamil}</td><td>{row.anak}</td><td>{row.risikoTinggi}</td><td>{row.cakupanImunisasi}%</td></tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>

          {/* Daftar Risiko Tinggi */}
          <div className="bg-white rounded-xl shadow-sm p-4">
            <h2 className="text-lg font-semibold mb-4 flex items-center gap-2"><AlertTriangle size={20} /> Ibu dengan Risiko Tinggi</h2>
            {risikoTinggi.length === 0 ? <p>Tidak ada data</p> : (
              <ul className="space-y-2">
                {risikoTinggi.map((ibu, idx) => (
                  <li key={idx} className="p-2 bg-red-50 rounded-lg">{ibu.nama_ibu} - {ibu.usia} th - {ibu.dusun}</li>
                ))}
              </ul>
            )}
          </div>

          {/* Prioritas Kunjungan */}
          <div className="lg:col-span-2 bg-white rounded-xl shadow-sm p-4">
            <h2 className="text-lg font-semibold mb-4 flex items-center gap-2"><Calendar size={20} /> Prioritas Kunjungan</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {prioritas.map((p, idx) => (
                <div key={idx} className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
                  <div><span className="font-medium">{p.dusun}</span><p className="text-sm text-gray-500">{p.kasus} Kasus Aktif</p></div>
                  <span className={`px-2 py-1 text-xs rounded-full ${p.priority === "High" ? "bg-red-100 text-red-800" : "bg-yellow-100 text-yellow-800"}`}>{p.priority}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </MainLayout>
  );
}