// src/components/Dashboard/StatsCard.jsx
import React from "react";

const StatsCard = ({ title, value, target, color = "indigo", icon: Icon, suffix = "" }) => {
  const bgColor = `bg-${color}-50`;
  const textColor = `text-${color}-600`;
  const borderColor = `border-${color}-200`;

  return (
    <div className={`bg-white rounded-lg shadow p-4 border-l-4 ${borderColor}`}>
      <div className="flex justify-between items-start">
        <div>
          <p className="text-gray-500 text-sm">{title}</p>
          <p className="text-2xl font-bold mt-1">
            {value}
            {suffix && <span className="text-sm font-normal text-gray-500 ml-1">{suffix}</span>}
          </p>
          {target && (
            <p className="text-xs text-gray-400 mt-1">Target {target}%</p>
          )}
        </div>
        {Icon && (
          <div className={`p-2 rounded-full ${bgColor} ${textColor}`}>
            <Icon size={24} />
          </div>
        )}
      </div>
    </div>
  );
};

export default StatsCard;