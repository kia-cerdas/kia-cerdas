// src/components/Dashboard/PrioritasList.jsx
import React from "react";

const getPriorityColor = (priority) => {
  if (priority === "High") return "text-red-600 bg-red-100";
  if (priority === "Med") return "text-yellow-600 bg-yellow-100";
  if (priority === "Low") return "text-green-600 bg-green-100";
  return "text-gray-600 bg-gray-100";
};

const PrioritasList = ({ data }) => {
  return (
    <div className="bg-white rounded-lg shadow">
      <div className="px-4 py-3 border-b border-gray-200 flex justify-between items-center">
        <h3 className="text-lg font-medium text-gray-800">Daftar Prioritas Kunjungan</h3>
        <button className="text-indigo-600 text-sm hover:underline">Lihat Semua</button>
      </div>
      <div className="divide-y divide-gray-100">
        {data.map((item, idx) => (
          <div key={idx} className="px-4 py-3 flex justify-between items-center">
            <div>
              <p className="font-medium text-gray-800">{item.dusun}</p>
              <p className="text-xs text-gray-500">{item.kasus} Kasus Aktif</p>
            </div>
            <span className={`px-2 py-1 text-xs rounded-full ${getPriorityColor(item.priority)}`}>
              {item.priority}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
};

export default PrioritasList;