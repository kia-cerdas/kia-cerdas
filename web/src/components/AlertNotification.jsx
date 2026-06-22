import React from "react";
import { Check, X } from "lucide-react";

export default function AlertNotification({ notification, onClose, onRetry }) {
  if (!notification) return null;

  const isSuccess = notification.type === "success";

  const handleClose = () => {
    if (!isSuccess && onRetry) {
      onRetry();
    } else {
      onClose();
    }
  };

  // If there's an API/DB error code, show it as the main description, otherwise use message
  const rawMessage = (!isSuccess && notification.code) 
    ? notification.code 
    : notification.message;

  // Capitalize first letter of the message
  const displayMessage = rawMessage
    ? rawMessage.charAt(0).toUpperCase() + rawMessage.slice(1)
    : "";

  return (
    <div className="fixed inset-0 z-[200] flex items-center justify-center bg-black/40 backdrop-blur-[1px] p-4 animate-swal-backdrop">
      {/* Modal Card container */}
      <div className="bg-white rounded-[1.25rem] w-full max-w-[400px] shadow-[0_10px_30px_rgba(0,0,0,0.15)] p-8 flex flex-col items-center text-center animate-swal-show">
        
        {/* Large Circular Icon Badge */}
        <div className="mb-6 flex justify-center">
          {isSuccess ? (
            <div className="w-[84px] h-[84px] rounded-full border-4 border-[#a5dc86]/40 flex items-center justify-center text-[#a5dc86]">
              <Check size={42} strokeWidth={4} />
            </div>
          ) : (
            <div className="w-[84px] h-[84px] rounded-full border-4 border-[#f27474]/40 flex items-center justify-center text-[#f27474]">
              <X size={42} strokeWidth={4} />
            </div>
          )}
        </div>

        {/* Dynamic Title */}
        <h3 className="text-[1.75rem] font-semibold text-[#595959] leading-tight mb-4 select-none">
          {isSuccess ? (notification.title || "Berhasil") : (notification.title || "Gagal Menyimpan")}
        </h3>

        {/* Message Description */}
        <div className="text-base text-[#545454] leading-relaxed mb-6 font-normal break-words max-h-[200px] overflow-y-auto w-full px-2">
          {displayMessage}
        </div>

        {/* Centralised OK Button */}
        <button
          onClick={handleClose}
          className="bg-[#7066e0] hover:bg-[#5f55cb] active:bg-[#4d45ad] text-white font-medium text-base px-7 py-2 rounded-[5px] transition-all outline-none border border-transparent shadow-[0_0_0_3px_rgba(112,102,224,0.25)] focus:shadow-[0_0_0_4px_rgba(112,102,224,0.4)]"
        >
          OK
        </button>

      </div>
    </div>
  );
}

