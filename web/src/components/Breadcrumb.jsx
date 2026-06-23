import React from "react";
import { Link, useLocation } from "react-router-dom";
import { ChevronRight, Home } from "lucide-react";

const Breadcrumb = () => {
  const location = useLocation();
  const pathSegments = location.pathname.split("/").filter(Boolean);

  // Mapping dari path ke label yang lebih user-friendly
  const breadcrumbLabels = {
    // Dashboard & Main
    dashboard: "Beranda",
    admin: "Admin",
    dokter: "Dokter",
    superadmin: "Superadmin",

    // Data Management
    "data-ibu": "Data Ibu hamil",
    "data-anak": "Data Balita",
    kependudukan: "Kependudukan",
    "daftar-anak": "Data Balita",
    "daftar-rujukan": "Daftar Rujukan",
    "daftar-skrining": "Daftar Skrining",
    "manajemen-posyandu": "Manajemen Posyandu",
    "manajemen-bidan": "Manajemen Bidan",
    "manajemen-kader": "Manajemen Kader",

    // Ibu - Skrining & Pemeriksaan
    skrining: "Skrining",
    "skrining-preeklampsia": "Skrining Preeklampsia",
    "skrining-dashboard": "Beranda Skrining",
    "Skrining-Diabetes-Melitus-Gestasional": "Skrining Diabetes Melitus Gestasional",
    "pemeriksaan-fisik": "Pemeriksaan Fisik",
    "pemeriksaan-rutin": "Pemantauan Antenatal Care",
    "pemeriksaan-dokter-t1-complete": "Trimester 1",
    "pemeriksaan-dokter-t3-complete": "Trimester 3",

    // Ibu - Grafik & Evaluasi
    "grafik-evaluasi": "Grafik Evaluasi Kehamilan",
    "grafik-bb": "Grafik Peningkatan BB",
    "evaluasi-kesehatan": "Evaluasi Kesehatan",

    // Ibu - Persalinan & Nifas
    "rencana-persalinan": "Rencana Persalinan",
    "pelayanan-persalinan": "Pelayanan Persalinan",
    "pelayanan-nifas": "Pelayanan Nifas",

    // Ibu - Lainnya
    "catatan-pelayanan": "Catatan Pelayanan",
    rujukan: "Rujukan",
    "rujukan-display": "Rujukan",

    // Anak - Pertumbuhan & Kesehatan
    pertumbuhan: "Pertumbuhan",
    neonatus: "Kesehatan Neonatus",
    "pelayanan-gizi": "Pelayanan Gizi",
    "pelayanan-vitamin": "Pelayanan Vitamin",
    "pelayanan-Imunisasi": "Pelayanan Imunisasi",
    "pelayanan-Gigi": "Pelayanan Gigi",
    "Tumbuh-kembang-Anak": "Tumbuh Kembang Anak",
    keluhan: "Keluhan",
    pemantauan: "Pemantauan",
    perawatan: "Lembar Perawatan",
    lila: "LILA",
    perkembangan: "Perkembangan", // Dipindahkan & label disesuaikan

    // Pencatatan & Monitoring
    pencatatan: "Pencatatan",
    "kesehatan-lingkungan": "Kesehatan Lingkungan",
    monitoring: "Monitoring",
    lihat: "Lihat Data",
    kelola: "Kelola",
    "kelola-perkembangan": "Kelola Perawatan",

    // Edukasi Digital
    "edukasi-digital": "Edukasi",
    "informasi-umum": "Informasi Umum",
    trimester: "Trimester",
    "tanda-melahirkan": "Tanda Melahirkan",
    imd: "IMD (Inisiasi Menyusu Dini)",
    "setelah-melahirkan": "Setelah Melahirkan",
    "menyusui-asi": "Menyusui ASI",
    nifas: "Nifas",
    "pola-asuh": "Pola Asuh",
    "kesehatan-mental": "Kesehatan Mental",
    "perawatan-anak": "Perawatan Anak",
    mpasi: "MPASI",
    "mpasi-aturan-porsi": "MPASI",
    "mpasi-jadwal-harian": "MPASI",
    "mpasi-resep": "MPASI",

    // Admin
    "kelola-desa": "Kelola Desa",

    // Actions
    create: "Tambah Baru",
    edit: "Edit",
    detail: "Detail",
    form: "Form",
    laporan: "Laporan",

    // General
    "tenaga-kesehatan": "Tenaga Kesehatan",
    "jadwal-layanan": "Jadwal Layanan Posyandu",
    "perubahan-jadwal-imunisasi": "Perubahan Jadwal Imunisasi",

    // Additional categories & sub-pages
    anak: "Anak",
    remaja: "Remaja",
    dewasa: "Dewasa",
    lansia: "Lansia",
    preview: "Preview",
    // "audit-trail": "Audit Trail",
    "kelola-user": "Kelola User",
    "kelola-nakes": "Kelola Nakes",
    "kelola-puskesmas": "Kelola Puskesmas",
    "kelola-posyandu": "Kelola Posyandu",
    "kelola-penduduk": "Kelola Penduduk",
    "form-versi": "Kelola Form Versi",
    "kelola-vaksin": "Kelola Vaksin",
  };

  // Build breadcrumb items
  const breadcrumbItems = [];

  // Tambah Home
  breadcrumbItems.push({
    label: "Beranda",
    path: "/dashboard",
    icon: true,
  });

  // Build path incrementally
  let currentPath = "";

  // Segments to skip entirely (role prefixes, not meaningful in breadcrumb)
  const skipSegments = ["superadmin"];

  // Check if this is a preview page (/laporan/{type}/preview)
  const isPreviewPage = pathSegments.includes("preview") && pathSegments.length >= 3 && pathSegments[0] === "laporan";

  pathSegments.forEach((segment, index) => {
    currentPath += "/" + segment;

    // Skip role-prefix segments
    if (skipSegments.includes(segment)) return;
    
    // Special handling for preview pages: combine type + preview into one breadcrumb item
    if (isPreviewPage && segment !== "laporan" && segment !== "preview") {
      // This is the "ibu" or "balita" segment - skip it as we'll combine it with "preview"
      return;
    }

    // Check if segment is an ID (UUID or numeric ID)
    const isId = /^[0-9a-f-]{36}$|^\d+$/.test(segment);

    if (!isId) {
      // Kontekstual: "form" tampilkan sebagai "Tambah" atau "Ubah" tergantung apakah ada ID setelahnya
      let label;
      if (segment === "form") {
        const nextSegment = pathSegments[index + 1];
        const hasId = nextSegment && /^[0-9a-f-]{36}$|^\d+$/.test(nextSegment);
      
        label = hasId ? "Ubah Konten" : "Tambah Konten";
      } else if (isPreviewPage && segment === "preview") {
        // Combine with previous type (ibu/balita) to make "Preview Ibu" or "Preview Balita"
        const typeSegment = pathSegments[pathSegments.indexOf("preview") - 1];
        const typeLabel = breadcrumbLabels[typeSegment] || formatLabel(typeSegment);
      
        label = `Preview ${typeLabel}`;
      
        label = hasId ? "Ubah Konten" : "Form Tambah Jadwal Posyandu";

      } else {
        label = breadcrumbLabels[segment] || formatLabel(segment);
      }
      const itemPath = getBreadcrumbPath(location.pathname, segment, currentPath);
      breadcrumbItems.push({
        label,
        path: itemPath,
        segment,
      });
    }
  });

  // Jangan tampilkan breadcrumb jika hanya ada home atau di dashboard
  if (
    breadcrumbItems.length <= 1 ||
    location.pathname === "/dashboard" ||
    location.pathname === "/superadmin/dashboard" ||
    location.pathname === "/dashboard/bidan" ||
    location.pathname === "/dashboard/admin" ||
    location.pathname === "/dashboard/dokter"
  ) {
    return null;
  }

  return (
    <nav
      className="flex items-center gap-2 py-3 px-4 md:px-8 bg-gradient-to-r from-gray-50 to-white border-b border-gray-200 text-sm shadow-sm"
      aria-label="Breadcrumb"
    >
      {breadcrumbItems.map((item, index) => (
        <div key={index} className="flex items-center gap-2">
          {index > 0 && (
            <ChevronRight className="w-4 h-4 text-gray-300" aria-hidden="true" />
          )}

          {item.icon ? (
            <Link
              to={item.path}
              className="flex items-center gap-1 text-indigo-600 hover:text-indigo-700 font-medium transition-colors duration-200"
              title="Kembali ke Beranda"
            >
              <Home className="w-4 h-4" />
              <span className="hidden sm:inline">{item.label}</span>
              <span className="sm:hidden">Beranda</span>
            </Link>
          ) : index === breadcrumbItems.length - 1 ? (
            // Last item (current page) - tidak bisa di-klik
            <span className="text-gray-700 font-medium truncate" aria-current="page">
              {item.label}
            </span>
          ) : (
            // Middle items - bisa di-klik
            <Link
              to={item.path}
              className="text-indigo-600 hover:text-indigo-700 transition-colors duration-200 truncate"
              title={item.label}
            >
              {item.label}
            </Link>
          )}
        </div>
      ))}
    </nav>
  );
};

// Helper function untuk format label dari path segment
function formatLabel(segment) {
  return segment
    .split("-")
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
    .join(" ");
}

function getBreadcrumbPath(pathname, segment, currentPath) {
  // 1. Root-level segments redirect mapping
  if (segment === "superadmin") {
    return "/superadmin/dashboard";
  }
  if (segment === "data-penduduk") {
    return "/kependudukan";
  }
  if (segment === "data-anak") {
    return "/daftar-anak";
  }
  if (segment === "pemantauan") {
    return "/pemantauan/lihat";
  }
  if (segment === "pencatatan") {
    return "/pencatatan/kesehatan-lingkungan";
  }
  if (segment === "edukasi-digital") {
    return "/edukasi-digital/informasi-umum";
  }
  if (["mpasi", "mpasi-aturan-porsi", "mpasi-jadwal-harian", "mpasi-resep"].includes(segment)) {
    return "/edukasi-digital/mpasi";
  }

  // 2. Child/toddler paths with IDs: /data-anak/CATEGORY/ID/...
  // Extract category and child ID from pathname
  const childMatch = pathname.match(/^\/data-anak\/([^/]+)\/([0-9a-f-]{36}|\d+)/);
  if (childMatch) {
    const childCategory = childMatch[1];
    const childId = childMatch[2];

    // If the segment is the childCategory (e.g. pertumbuhan, pelayanan-gizi),
    // append the child ID to construct a valid route.
    if (segment === childCategory) {
      return `/data-anak/${childCategory}/${childId}`;
    }
  }

  // 3. Fallback to valid endpoints for other invalid intermediate segments
  if (segment === "detail" && pathname.startsWith("/pencatatan/kesehatan-lingkungan")) {
    return "/pencatatan/kesehatan-lingkungan";
  }
  if (segment === "edit" && pathname.startsWith("/data-anak/lila")) {
    // Extract child ID
    const lilaMatch = pathname.match(/^\/data-anak\/lila\/([0-9a-f-]{36}|\d+)/);
    if (lilaMatch) {
      return `/data-anak/lila/${lilaMatch[1]}`;
    }
  }

  return currentPath;
}

export default Breadcrumb;