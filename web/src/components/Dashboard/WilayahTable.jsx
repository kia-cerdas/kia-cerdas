// src/components/Dashboard/WilayahTable.jsx
import React from "react";

const getStatusBadge = (status) => {
  if (status === "Risiko Tinggi") return "bg-red-100 text-red-800";
  if (status === "Waspada (Med)") return "bg-yellow-100 text-yellow-800";
  if (status === "Aman (Low)") return "bg-green-100 text-green-800";
  return "bg-gray-100 text-gray-800";
};

const WilayahTable = ({ data }) => {
  return (
    <div className="bg-white rounded-lg shadow overflow-hidden">
      <div className="px-4 py-3 border-b border-gray-200">
        <h3 className="text-lg font-medium text-gray-800">Data per Wilayah</h3>
      </div>
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Dusun Name</th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Ibu Hamil</th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Anak</th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Risiko Tinggi</th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Cakupan Imunisasi</th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200">
            {data.map((row, idx) => (
              <tr key={idx} className="hover:bg-gray-50">
                <td className="px-4 py-3 text-sm font-medium text-gray-900">{row.dusun}</td>
                <td className="px-4 py-3 text-sm text-gray-600">{row.ibuHamil}</td>
                <td className="px-4 py-3 text-sm text-gray-600">{row.anak}</td>
                <td className="px-4 py-3 text-sm text-gray-600">{row.risikoTinggi}</td>
                <td className="px-4 py-3 text-sm text-gray-600">{row.cakupanImunisasi}%</td>
                <td className="px-4 py-3">
                  <span className={`px-2 py-1 text-xs rounded-full ${getStatusBadge(row.status)}`}>
                    {row.status}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default WilayahTable;