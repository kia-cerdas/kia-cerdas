// src/components/Layout/Sidebar.jsx
import { useEffect, useMemo, useState } from "react";
import { NavLink, useLocation } from "react-router-dom";
import {
  getCurrentUser,
  getUserRedirectRoute,
  isSuperadminUser,
  isAdminUser,
  isBidanUser,
  isDokterUser,
  isBidanPuskesmasUser
} from "../../services/auth";
import {
  ChevronDown,
  LayoutGrid,
  Users,
  Baby,
  Activity,
  Calendar,
  BarChart3,
  Settings,
  UserCheck,
  UserPlus,
  BriefcaseMedical,
  ClipboardEdit,
  TableProperties,
  ClipboardList,
  ShieldPlus,
  CalendarClock,
  BookOpenCheck,
  History,
  Home,
  Building2,
} from "lucide-react";
import logo from "./LOGO.png";


const baseItemClass = (isActive) =>
  `flex items-center gap-2 px-3 py-2.5 rounded-lg transition-all duration-200 group ${isActive
    ? "bg-blue-50 text-blue-600 font-semibold"
    : "text-slate-500 hover:bg-gray-50 hover:text-slate-700"
  }`;

const Sidebar = () => {
  const user = getCurrentUser();
  const isSuperadmin = isSuperadminUser(user);
  const isAdmin = isAdminUser(user);
  const isBidan = isBidanUser(user);
  const isDokter = isDokterUser(user);
  const isBidanPuskesmas = isBidanPuskesmasUser(user);
  const location = useLocation();

  const dashboardPath = getUserRedirectRoute(user);
  const [isFamilyMenuOpen, setIsFamilyMenuOpen] = useState(false);

  const getDropdownOpenState = (pathname) => ({
    monitoring: pathname.startsWith("/monitoring") || pathname.startsWith("/pemantauan"),
    edukasiDigital: pathname.startsWith("/edukasi-digital"),
    kesehatanLingkungan: pathname.startsWith("/pencatatan/kesehatan-lingkungan"),
    mpasi: pathname.startsWith("/edukasi-digital/mpasi"),
    pencatatanKesehatan: pathname.startsWith("/pencatatan-kesehatan"),
    dashboardDokter: pathname.startsWith("/data-ibu") || pathname.startsWith("/daftar-rujukan"),
  });

  const [dropdownOpen, setDropdownOpen] = useState(() => getDropdownOpenState(location.pathname));

  useEffect(() => {
    setDropdownOpen(getDropdownOpenState(location.pathname));
  }, [location.pathname]);

  const toggleDropdown = (key) => {
    setDropdownOpen((prev) => ({ ...prev, [key]: !prev[key] }));
  };

  // Menu untuk bidan (lengkap)
  const bidanMenuItems = [
    { path: "/data-ibu", name: "Data Ibu Hamil", icon: Users, prefixMatch: true, extraMatchPaths: ["/daftar-rujukan"] },
    { path: "/daftar-anak", name: "Data Anak Balita", icon: Baby },
    // { path: "/kependudukan", name: "Manajemen KK", icon: UserCheck },
    // { path: "/monitoring", name: "Monitoring", icon: Activity },
    // {
    //   name: "Kesehatan Lingkungan",
    //   icon: ClipboardList,
    //   isDropdown: true,
    //   dropdownKey: "kesehatanLingkungan",
    //   children: [
    //     { path: "/pencatatan/kesehatan-lingkungan", name: "Data Pencatatan", icon: TableProperties },
    //     { path: "/pencatatan/kesehatan-lingkungan/kelola", name: "Kelola Pertanyaan", icon: ClipboardEdit },
    //   ],
    // },
    {
      name: "Pemantauan",
      icon: Activity,
      isDropdown: true,
      dropdownKey: "monitoring",
      children: [
        // { path: "/monitoring", name: "Rekap Wilayah", icon: BarChart3 },
        { path: "/pemantauan/lihat", name: "Data Pemantauan Anak", icon: TableProperties },
        { path: "/pemantauan/perkembangan", name: "Data Perawatan Anak", icon: TableProperties },
        { path: "/pemantauan/kelola-perkembangan", name: "Kelola Perawatan Anak", icon: ClipboardEdit },
        { path: "/pemantauan/kelola", name: "Kelola Pemantauan Anak", icon: ClipboardEdit },
      ],
    },
    {
      name: "Edukasi ",
      icon: BookOpenCheck,
      isDropdown: true,
      dropdownKey: "edukasiDigital",
      children: [
        { path: "/edukasi-digital/informasi-umum", name: "Informasi Umum", icon: ClipboardList },
        { path: "/edukasi-digital/trimester", name: "Edukasi Trimester", icon: ClipboardList },
        { path: "/edukasi-digital/tanda-melahirkan", name: "Tanda Melahirkan", icon: ClipboardList },
        { path: "/edukasi-digital/imd", name: "Edukasi IMD", icon: ClipboardList },
        { path: "/edukasi-digital/setelah-melahirkan", name: "Setelah Melahirkan", icon: ClipboardList },
        { path: "/edukasi-digital/menyusui-asi", name: "Menyusui & ASI", icon: ClipboardList },
        { path: "/edukasi-digital/pola-asuh", name: "Pola Asuh", icon: ClipboardList },
        { path: "/edukasi-digital/kesehatan-mental", name: "Kesehatan Mental", icon: ClipboardList },
        { path: "/edukasi-digital/perawatan-anak", name: "Perawatan Anak", icon: ClipboardList },
        {
          name: "MPASI",
          icon: ClipboardList,
          isDropdown: true,
          dropdownKey: "mpasi",
          children: [
            { path: "/edukasi-digital/mpasi", name: "Materi MPASI", icon: ClipboardList },
            { path: "/edukasi-digital/mpasi-aturan-porsi", name: "Aturan Porsi", icon: ClipboardList },
            { path: "/edukasi-digital/mpasi-jadwal-harian", name: "Jadwal Harian", icon: ClipboardList },
            { path: "/edukasi-digital/mpasi-resep", name: "Resep", icon: ClipboardList },
          ],
        },
      ],
    },
    { path: "/jadwal-layanan", name: "Jadwal Layanan", icon: Calendar },
    {
      name: "Pencatatan Kesehatan",
      icon: ClipboardList,            // gunakan ikon dari lucide-react (sudah diimport di atas)
      isDropdown: true,
      dropdownKey: "pencatatanKesehatan",   // unique key untuk dropdown
      children: [
        { path: "/pencatatan-kesehatan/anak", name: "Anak (5-9 tahun)", icon: Activity },
        { path: "/pencatatan-kesehatan/remaja", name: "Remaja (10-18 tahun)", icon: Activity },
        { path: "/pencatatan-kesehatan/dewasa", name: "Dewasa (19-59 tahun)", icon: Activity },
        { path: "/pencatatan-kesehatan/lansia", name: "Lansia (≥60 tahun)", icon: Activity },
      ],
    },
    { path: "/laporan", name: "Laporan", icon: BarChart3 },
    { path: "/perubahan-jadwal-imunisasi", name: "Perubahan Jadwal Imunisasi", icon: CalendarClock },
  ];

  // Menu untuk dokter (menampilkan semua fitur puskesmas)
  const dokterMenuItems = [
    { path: "/data-ibu", name: "Data Ibu Hamil", icon: Users, prefixMatch: true, extraMatchPaths: ["/daftar-rujukan"] },
    { path: "/laporan", name: "Laporan", icon: BarChart3 },
  ];

  // Menu admin dihapus karena keluarga dipindahkan ke superadmin
  const adminFamilyMenuItems = useMemo(
    () => [],
    []
  );

  const superadminMenuItems = useMemo(
    () => [
      { path: "/superadmin/dashboard", name: "Beranda", icon: LayoutGrid },
      { path: "/superadmin/manajemen-keluarga", name: "Manajemen KK", icon: UserCheck },
      { path: "/superadmin/akun-keluarga", name: "Buat Kartu Keluarga", icon: UserPlus },
      { path: "/superadmin/kelola-user", name: "Kelola Bidan&Kader&Admin desa", icon: ShieldPlus },
      { path: "/superadmin/kelola-user-per-desa", name: "Kelola Akun User Per Desa", icon: Users },
      { path: "/superadmin/kelola-desa", name: "Kelola Desa", icon: TableProperties },
      { path: "/superadmin/kelola-puskesmas", name: "Kelola Puskesmas", icon: Building2 },
      { path: "/superadmin/kelola-posyandu", name: "Kelola Posyandu", icon: Home },
      // { path: "/superadmin/audit-trail", name: "Audit Trail", icon: History },
      { path: "/superadmin/form-versi", name: "Kelola Form Versi", icon: BriefcaseMedical },
    ],
    []
  );

  // Menentukan menuItems berdasarkan role
  let menuItems = [];
  if (isSuperadmin) {
    menuItems = superadminMenuItems;
  } else if (isAdmin) {
    menuItems = [{ path: dashboardPath, name: "Beranda", icon: LayoutGrid }];
  } else if (isDokter) {
    menuItems = [
      { path: dashboardPath, name: "Beranda", icon: LayoutGrid },
      ...dokterMenuItems,
    ];
  } else if (isBidanPuskesmas) {
    // Menu khusus untuk bidan_puskesmas (akses ke dashboard puskesmas dan fiturnya)
    menuItems = [
      { path: dashboardPath, name: "Beranda", icon: LayoutGrid },
      ...bidanPuskesmasMenuItems,
    ];
  } else if (isBidan) {
    menuItems = [
      { path: dashboardPath, name: "Beranda", icon: LayoutGrid },
      ...bidanMenuItems,
    ];
  } else {
    menuItems = [{ path: dashboardPath, name: "Beranda", icon: LayoutGrid }];
  }

  const settingsMenu = { path: "/pengaturan", name: "Pengaturan", icon: Settings };

  const renderNavLink = (item, className = "text-sm") => {
    const hasExtraMatch = item.extraMatchPaths?.some((p) =>
      location.pathname.startsWith(p)
    ) ?? false;

    return (
      <NavLink
        key={item.path}
        to={item.path}
        end={!item.prefixMatch}
        className={({ isActive }) => `${baseItemClass(isActive || hasExtraMatch)} ${className}`}
      >
        {({ isActive }) => (
          <>
            <item.icon
              size={18}
              className={`flex-shrink-0 ${(isActive || hasExtraMatch) ? "text-blue-600" : "text-slate-400 group-hover:text-slate-600"}`}
            />
            <span className="truncate text-sm">{item.name}</span>
          </>
        )}
      </NavLink>
    );
  };

  const hasActiveDescendant = (item) => {
    if (!item?.children?.length) {
      return Boolean(item?.path && location.pathname.startsWith(item.path));
    }
    return item.children.some((child) => hasActiveDescendant(child));
  };

  const renderDropdown = (item, isNested = false) => {
    const isOpen = dropdownOpen[item.dropdownKey];
    const hasActiveChild = hasActiveDescendant(item);
    const childContainerClass = isNested
      ? "ml-3 pl-3 space-y-0.5 border-l border-slate-200"
      : "ml-3 pl-3 space-y-0.5 border-l border-slate-200";

    return (
      <div key={item.dropdownKey} className="space-y-0.5">
        <button
          type="button"
          onClick={() => toggleDropdown(item.dropdownKey)}
          className={`${baseItemClass(isOpen || hasActiveChild)} w-full ${isNested ? "text-sm px-3 py-2 rounded-lg" : ""}`}
        >
          <item.icon
            size={18}
            className={`flex-shrink-0 ${(isOpen || hasActiveChild) ? "text-blue-600" : "text-slate-400 group-hover:text-slate-600"}`}
          />
          <span className="flex-1 text-left truncate text-sm">{item.name}</span>
          <ChevronDown
            size={14}
            className={`flex-shrink-0 transition-transform duration-200 ${(isOpen || hasActiveChild) ? "rotate-180" : "rotate-0"}`}
          />
        </button>

        {(isOpen || hasActiveChild) && (
          <div className={childContainerClass}>
            {item.children.map((child) => (
              child.isDropdown
                ? renderDropdown(child, true)
                : renderNavLink(child, "text-sm px-3 py-2 rounded-lg")
            ))}
          </div>
        )}
      </div>
    );
  };

  return (
    <aside className="w-64 h-screen bg-white border-r border-gray-100 flex flex-col p-4">
      {/* Header Logo */}
      <div className="flex items-center gap-2.5 mb-6">
        <div className=" p-1.5 rounded-lg text-white shadow-lg shadow-blue-100 flex-shrink-0">
          <img src={logo} alt="Logo" className="w-6 h-6 object-contain" />
        </div>
        <div className="min-w-0">
          <h1 className="text-base font-bold text-slate-800 leading-tight">KIA Cerdas</h1>
          <p className="text-[11px] text-slate-400">
            Beranda {isDokter || isBidanPuskesmas ? "Puskesmas" : isBidan ? "Bidan" : "Admin"}
          </p>
        </div>
      </div>

      <p className="text-[9px] font-bold text-slate-400 uppercase tracking-wider mb-3 ml-1">
        Menu utama
      </p>

      {/* Navigasi */}
      <nav className="flex-1 space-y-0.5 overflow-y-auto pr-2 custom-scrollbar">
        {menuItems.map((item) =>
          item.isDropdown ? renderDropdown(item) : renderNavLink(item)
        )}

        {/* Menu admin dihapus */}

        {/* Menu Pengaturan untuk semua role */}
        {/* {renderNavLink(settingsMenu)} */}
      </nav>
    </aside>
  );
};

export default Sidebar;