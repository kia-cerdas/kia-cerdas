// Helper format tampilan (display-only). Nilai asli tidak diubah —
// hanya output yang dikelompokkan agar mudah dibaca. Jangan pakai untuk
// nilai yang dikirim ke backend.

// Pisahkan string menjadi kelompok berukuran `size`, dipisah tanda hubung "-".
const chunk = (value, size = 4) => {
  const str = String(value ?? "").trim();
  if (!str) return "";
  // Hanya kelompokkan bagian digit; jika ada karakter non-digit, kembalikan apa adanya.
  if (!/^\d+$/.test(str)) return str;
  return str.match(new RegExp(`.{1,${size}}`, "g")).join("-");
};

// NIK 16 digit -> "1234 5678 9012 3456"
export const formatNik = (nik) => {
  const str = String(nik ?? "").trim();
  if (!str) return "-";
  return chunk(str, 4);
};

// Kode Keluarga -> dikelompokkan per 4 digit bila berupa angka,
// selain itu ditampilkan apa adanya.
export const formatKodeKeluarga = (kode) => {
  const str = String(kode ?? "").trim();
  if (!str) return "-";
  return chunk(str, 4);
};
