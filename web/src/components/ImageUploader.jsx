import React, { useRef, useState } from "react";
import { CloudUpload, X, Trash2, RefreshCw, AlertCircle, CheckCircle2 } from "lucide-react";

// ─── Konfigurasi upload ───────────────────────────────────────────────────────
// Menggunakan ImgBB API (gratis, tidak butuh backend)
// Daftarkan API key di: https://api.imgbb.com/
// Ganti dengan key Anda sendiri, atau biarkan menggunakan default free key
const IMGBB_API_KEY = import.meta.env.VITE_IMGBB_API_KEY || "23e25a0f6e3cd9dc3b5e5b74df1e9b3e";
const IMGBB_UPLOAD_URL = "https://api.imgbb.com/1/upload";

/**
 * Upload gambar ke ImgBB dan kembalikan URL publik.
 * Jika gagal (misal: offline/key invalid), fallback ke Base64 data URI.
 */
async function uploadImage(file) {
  // ── Coba ImgBB ──
  try {
    const formData = new FormData();
    formData.append("image", file);
    formData.append("key", IMGBB_API_KEY);

    const res = await fetch(`${IMGBB_UPLOAD_URL}`, {
      method: "POST",
      body: formData,
    });

    if (!res.ok) throw new Error(`ImgBB HTTP ${res.status}`);
    const json = await res.json();

    if (json?.success && json?.data?.url) {
      return { url: json.data.url, source: "imgbb" };
    }
    throw new Error("ImgBB: respons tidak valid");
  } catch (err) {
    // ── Fallback: Base64 ──
    // Gambar tersimpan sebagai data URI di database (cocok untuk ukuran kecil)
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = (e) => resolve({ url: e.target.result, source: "base64" });
      reader.onerror = () => reject(new Error("Gagal membaca file gambar."));
      reader.readAsDataURL(file);
    });
  }
}

// ─── Komponen ─────────────────────────────────────────────────────────────────
/**
 * ImageUploader
 *
 * Props:
 *  - value    : string  — URL gambar saat ini (dari form state)
 *  - onChange : (url: string) => void
 *  - label    : string  — label field
 *  - disabled : boolean
 */
export default function ImageUploader({
  value = "",
  onChange,
  fieldName = "gambar_url",
  label = "Pilih Gambar",
  disabled = false,
}) {
  const fileInputRef = useRef(null);
  const [uploading, setUploading] = useState(false);
  const [uploadError, setUploadError] = useState("");
  const [dragOver, setDragOver] = useState(false);

  const handleFile = async (file) => {
    if (!file) return;

    // Validasi tipe
    const allowed = ["image/jpeg", "image/jpg", "image/png", "image/webp", "image/gif"];
    if (!allowed.includes(file.type)) {
      setUploadError("Format tidak didukung. Gunakan JPG, PNG, WebP, atau GIF.");
      return;
    }
    // Validasi ukuran (maks 5 MB)
    if (file.size > 5 * 1024 * 1024) {
      setUploadError("Ukuran file terlalu besar. Maksimal 5 MB.");
      return;
    }

    setUploadError("");
    setUploading(true);

    try {
      const { url } = await uploadImage(file);
      onChange(url);
    } catch (err) {
      setUploadError(err.message || "Gagal memproses gambar. Coba lagi.");
    } finally {
      setUploading(false);
      if (fileInputRef.current) fileInputRef.current.value = "";
    }
  };

  const handleDrop = (e) => {
    e.preventDefault();
    setDragOver(false);
    if (disabled || uploading) return;
    const file = e.dataTransfer.files?.[0];
    if (file) handleFile(file);
  };

  const handleRemove = () => {
    onChange("");
    setUploadError("");
    if (fileInputRef.current) fileInputRef.current.value = "";
  };

  return (
    <div className="space-y-1.5">
      {/* Label */}
      <label className="block text-[14px] font-semibold text-slate-700">{label}</label>

      {/* Hidden file input */}
      <input
        ref={fileInputRef}
        type="file"
        accept="image/jpeg,image/jpg,image/png,image/webp,image/gif"
        className="hidden"
        disabled={disabled || uploading}
        onChange={(e) => handleFile(e.target.files?.[0])}
      />

      {value ? (
        /* ── State: Gambar sudah dipilih ── */
        <div className="rounded-2xl overflow-hidden border border-[#e2e8f0] bg-[#F7FAFB]">
          {/* Preview */}
          <div className="relative w-full h-52 bg-slate-100">
            <img
              src={value}
              alt="Preview"
              className="w-full h-full object-contain"
              onError={(e) => {
                e.target.style.display = "none";
              }}
            />
            {/* Badge sukses */}
            <div className="absolute top-3 left-3 flex items-center gap-1.5 px-2.5 py-1 bg-white/90 backdrop-blur-sm rounded-full shadow-sm border border-[#e2e8f0]">
              <CheckCircle2 size={13} className="text-emerald-500" />
              <span className="text-[11px] font-semibold text-slate-700">Gambar terpilih</span>
            </div>
          </div>

          {/* Footer actions */}
          <div className="flex items-center justify-between gap-3 px-4 py-3 bg-white border-t border-[#e2e8f0]">
            <p className="text-[11px] text-slate-400 truncate flex-1 min-w-0" title={value}>
              {/* Tampilkan nama file atau potongan URL */}
              {value.startsWith("data:")
                ? "Gambar tersimpan lokal"
                : value.split("/").pop()?.split("?")[0] || "gambar"}
            </p>
            <div className="flex items-center gap-2 flex-shrink-0">
              <button
                type="button"
                onClick={() => fileInputRef.current?.click()}
                disabled={disabled || uploading}
                className="inline-flex items-center gap-1.5 px-3 py-1.5 text-[12px] font-semibold text-[#185FA5] bg-[#185FA5]/10 hover:bg-[#185FA5]/20 rounded-lg transition-colors disabled:opacity-50"
              >
                <RefreshCw size={12} />
                Ganti
              </button>
              <button
                type="button"
                onClick={handleRemove}
                disabled={disabled}
                className="inline-flex items-center gap-1.5 px-3 py-1.5 text-[12px] font-semibold text-red-600 bg-red-50 hover:bg-red-100 rounded-lg transition-colors disabled:opacity-50"
              >
                <Trash2 size={12} />
                Hapus
              </button>
            </div>
          </div>
        </div>
      ) : (
        /* ── State: Drop zone ── */
        <div
          onDragOver={(e) => {
            e.preventDefault();
            if (!disabled && !uploading) setDragOver(true);
          }}
          onDragLeave={() => setDragOver(false)}
          onDrop={handleDrop}
          className={[
            "w-full rounded-2xl border-2 border-dashed transition-all duration-200",
            dragOver
              ? "border-[#185FA5] bg-[#185FA5]/5"
              : "border-[#d1d5db] bg-[#F7FAFB] hover:border-[#185FA5]/40 hover:bg-[#185FA5]/[0.03]",
            uploading ? "opacity-60 cursor-not-allowed" : "",
          ].join(" ")}
        >
          <div className="flex flex-col items-center justify-center gap-4 py-10 px-6">
            {uploading ? (
              /* Loading */
              <>
                <div className="w-14 h-14 rounded-full bg-[#185FA5]/10 flex items-center justify-center">
                  <RefreshCw size={26} className="text-[#185FA5] animate-spin" />
                </div>
                <div className="text-center">
                  <p className="text-[14px] font-semibold text-slate-700">Mengunggah gambar...</p>
                  <p className="text-[12px] text-slate-400 mt-0.5">Mohon tunggu sebentar</p>
                </div>
              </>
            ) : (
              /* Idle */
              <>
                {/* Cloud icon */}
                <div className={[
                  "w-14 h-14 rounded-full flex items-center justify-center transition-colors duration-200",
                  dragOver ? "bg-[#185FA5]/15" : "bg-[#185FA5]/10",
                ].join(" ")}>
                  <CloudUpload
                    size={28}
                    strokeWidth={1.75}
                    className="text-[#185FA5]"
                  />
                </div>

                {/* Teks */}
                <div className="text-center">
                  <p className="text-[14px] font-bold text-slate-800">
                    Tarik dan lepaskan file di sini
                  </p>
                  <p className="text-[13px] text-slate-500 mt-1">
                    Format yang didukung: JPG, PNG, WebP, GIF (Maks. 5MB)
                  </p>
                </div>

                {/* Tombol pilih file */}
                <button
                  type="button"
                  onClick={() => !disabled && fileInputRef.current?.click()}
                  disabled={disabled}
                  className="mt-1 px-6 py-2.5 rounded-xl border-2 border-[#d1d5db] bg-white text-[14px] font-semibold text-slate-700 hover:border-[#185FA5] hover:text-[#185FA5] hover:bg-[#185FA5]/5 transition-all duration-150 active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Pilih File dari Perangkat
                </button>
              </>
            )}
          </div>
        </div>
      )}

      {/* Error */}
      {uploadError && (
        <div className="flex items-center gap-2 text-[12px] text-red-600 bg-red-50 border border-red-100 rounded-xl px-3 py-2.5">
          <AlertCircle size={14} className="flex-shrink-0" />
          <span className="flex-1">{uploadError}</span>
          <button
            type="button"
            onClick={() => setUploadError("")}
            className="text-red-400 hover:text-red-600 flex-shrink-0"
          >
            <X size={13} />
          </button>
        </div>
      )}
    </div>
  );
}
