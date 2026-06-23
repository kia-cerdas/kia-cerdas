import React from "react";
import LembarPerawatanAnak from "./pages/penanda-perkembangan-anak/LembarPerawatanAnak";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";

import Dashboard from "./pages/Dashboard";
import Login from "./pages/Login";
import RootRoute from "./routes/RootRoute";
import PrivateRoute from "./routes/Private-routes";
import RencanaPersalinanForm from './pages/Ibu/RencanaPersalinanForm';
import RencanaPersalinanDetail from './pages/Ibu/RencanaPersalinanDetail';
import RencanaPersalinanRedirect from './pages/Ibu/RencanaPersalinanRedirect';
import AdminRoute from "./routes/AdminRoute";
import { getPostLoginRoute, isAuthenticated } from "./services/auth";

// ─── Public Pages (tanpa login) ───────────────────────────────────────────────
import LandingPage from "./pages/public/LandingPage";
import PublicEdukasiList from "./pages/public/PublicEdukasiList";
import PublicEdukasiDetail from "./pages/public/PublicEdukasiDetail";

// Data Ibu
import IbuList from "./pages/Ibu/IbuList";
import IbuDetail from "./pages/Ibu/IbuDetail";
import IbuEdit from "./pages/Ibu/IbuEdit";
import SkriningPreeklampsia from "./pages/Ibu/SkriningPreeklampsia";
import SkriningDMG from "./pages/Ibu/SkriningDMG";
import PemeriksaanFisik from "./pages/Ibu/PemeriksaanFisik";
import GrafikEvaluasiKehamilan from "./pages/Ibu/GrafikEvaluasiKehamilan";
import GrafikPeningkatanBB from "./pages/Ibu/GrafikPeningkatanBB";
import RencanaPersalinan from "./pages/Ibu/RencanaPersalinan";
import PelayananNifas from "./pages/Ibu/PelayananNifas";
import EvaluasiKesehatanIbu from "./pages/Ibu/EvaluasiKesehatanIbu";
import CatatanPelayanan from "./pages/Ibu/CatatanPelayanan";
import RujukanPage from "./pages/Ibu/Rujukan";
import PelayananPersalinan from "./pages/Ibu/PelayananPersalinan";
import PemeriksaanKehamilanList from "./pages/Ibu/PemeriksaanKehamilanList";
import PemeriksaanKehamilanForm from "./pages/Ibu/PemeriksaanKehamilanForm";
import RujukanDashboard from "./pages/Ibu/RujukanDashboard";
import SkriningDashboard from "./pages/Ibu/SkriningDashboard";
import SkriningDashboardList from "./pages/Ibu/SkriningDashboardList";
import RujukanDisplay from "./pages/Ibu/RujukanDisplay";

// Data Anak
import AnakListNakes from "./pages/Anak";
import CreateAnak from "./pages/Anak/create";
import EditAnak from "./pages/Anak/edit";
import DetailAnak from "./pages/Anak/detail";

// Monitoring & Laporan
import Monitoring from "./pages/Monitoring";
import Laporan from "./pages/Laporan";
import LaporanIbuPreview from "./pages/previewlaporanibu";
import LaporanBalitaPreview from "./pages/previewlaporanbalita";
import LaporanAnakPreview from "./pages/previewlaporananak";
import LaporanRemajaPreview from "./pages/previewlaporanremaja";
import LaporanDewasaPreview from "./pages/previewlaporandewasa";
import LaporanLansiaPreview from "./pages/previewlaporanlansia";
import IbuCreate from "./pages/Ibu/IbuCreate";

// Kependudukan
import KependudukanList from "./pages/Kependudukan/KependudukanList";
import KependudukanCreate from "./pages/Kependudukan/KependudukanCreate";
import KependudukanEdit from "./pages/Kependudukan/KependudukanEdit";

// Anak Dashboard & Pelayanan
import AnakDashboard from "./pages/Anak/Dashboard";
import PelayananGiziIndex from "./pages/Pelayanan-Gizi-Anak/index";
import NeonatusIndex from "./pages/Kesehatan-Neonatus/NeonatusIndex";
import PelayananGiziCreate from "./pages/Pelayanan-Gizi-Anak/create";

// Pemeriksaan Dokter Complete T1
import PemeriksaanDokterT1CompleteEntry from "./pages/Ibu/PemeriksaanDokterT1CompleteEntry";
import PemeriksaanDokterT1CompleteDetail from "./pages/Ibu/PemeriksaanDokterT1CompleteDetail";
import PemeriksaanDokterT1Complete from "./pages/Ibu/PemeriksaanDokterT1Complete";

// Pemeriksaan Dokter Complete T3
import PemeriksaanDokterT3CompleteEntry from "./pages/Ibu/PemeriksaanDokterT3CompleteEntry";
import PemeriksaanDokterT3CompleteDetail from "./pages/Ibu/PemeriksaanDokterT3CompleteDetail";
import PemeriksaanDokterT3Complete from "./pages/Ibu/PemeriksaanDokterT3Complete";

//Dokter
import ProtectedRoute from "./components/ProtectedRoute";
import RoleAccessGuard from "./components/RoleAccessGuard";


// Puskesmas
import DashboardPuskesmas from "./pages/Puskesmas/DashboardPuskesmas";
import KelolaVaksin from "./pages/Puskesmas/KelolaVaksin";
// import PelayananGiziIndex from "./pages/Pelayanan-Gizi-Anak/index";
// import PelayananGiziCreate from "./pages/Pelayanan-Gizi-Anak/create";
import PelayananVitaminIndex from "./pages/Pelayanan-Vitamin-Anak/index";
import PelayananVitaminCreate from "./pages/Pelayanan-Vitamin-Anak/create";
import PelayananImunisasiIndex from "./pages/Pelayanan-Imunisasi-Anak/index";
import PelayananGigiIndex from "./pages/PelayananGigi/index";
import TumbuhKembangAnak from "./pages/SDIDTK/index";
// import NeonatusIndex from "./pages/Kesehatan-Neonatus/NeonatusIndex";

// Pemantauan
import KelolaPemantauan from "./pages/Pemantauan-anak/KelolaPemantauan";
import LihatDataPemantauan from "./pages/Pemantauan-anak/LihatDataPemantauan";

// Pencatatan
// import KesehatanLingkunganCatatanPage from "./pages/Pencatatan/KesehatanLingkunganCatatan";
import InformasiUmumPage from "./pages/edukasi-digital/InformasiUmumPage";
import InformasiUmumFormPage from "./pages/edukasi-digital/InformasiUmumFormPage";
import TrimesterPage from "./pages/edukasi-digital/TrimesterPage";
import TrimesterFormPage from "./pages/edukasi-digital/TrimesterFormPage";
import TandaMelahirkanPage from "./pages/edukasi-digital/TandaMelahirkanPage";
import TandaMelahirkanFormPage from "./pages/edukasi-digital/TandaMelahirkanFormPage";
import ImdPage from "./pages/edukasi-digital/ImdPage";
import ImdFormPage from "./pages/edukasi-digital/ImdFormPage";
import SetelahMelahirkanPage from "./pages/edukasi-digital/SetelahMelahirkanPage";
import SetelahMelahirkanFormPage from "./pages/edukasi-digital/SetelahMelahirkanFormPage";
import MenyusuiAsiPage from "./pages/edukasi-digital/MenyusuiAsiPage";
import MenyusuiAsiFormPage from "./pages/edukasi-digital/MenyusuiAsiFormPage";
import PolaAsuhPage from "./pages/edukasi-digital/PolaAsuhPage";
import PolaAsuhFormPage from "./pages/edukasi-digital/PolaAsuhFormPage";
import KesehatanMentalPage from "./pages/edukasi-digital/KesehatanMentalPage";
import KesehatanMentalFormPage from "./pages/edukasi-digital/KesehatanMentalFormPage";
import PerawatanAnakPage from "./pages/edukasi-digital/PerawatanAnakPage";
import PerawatanAnakFormPage from "./pages/edukasi-digital/PerawatanAnakFormPage";
import MpasiPage from "./pages/edukasi-digital/MpasiPage";
import MpasiFormPage from "./pages/edukasi-digital/MpasiFormPage";
import MpasiAturanPorsiPage from "./pages/edukasi-digital/MpasiAturanPorsiPage";
import MpasiAturanPorsiFormPage from "./pages/edukasi-digital/MpasiAturanPorsiFormPage";
import MpasiJadwalHarianPage from "./pages/edukasi-digital/MpasiJadwalHarianPage";
import MpasiJadwalHarianFormPage from "./pages/edukasi-digital/MpasiJadwalHarianFormPage";
import MpasiResepPage from "./pages/edukasi-digital/MpasiResepPage";
import MpasiResepFormPage from "./pages/edukasi-digital/MpasiResepFormPage";
import JadwalLayananPage from "./pages/jadwal-layanan/JadwalLayananPage";
import JadwalLayananForm from "./pages/jadwal-layanan/JadwalLayananForm";
import KeluhanAnak from "./pages/Anak/Keluhan/KeluhanAnak";
import PemantauanAnakPage from "./pages/Pemantauan-anak/PemantauanAnakPage";

import LihatDataPerkembangan from "./pages/penanda-perkembangan-anak/LihatDataPerkembangan";
import KelolaPerkembangan from "./pages/penanda-perkembangan-anak/KelolaPerkembangan";
// import KelolaLingkungan from "./pages/KesehatanLingkungan/KelolaLingkungan";
// import DataLingkungan from "./pages/KesehatanLingkungan/DataLingkungan";
// import DetailLembarLingkungan from "./pages/KesehatanLingkungan/DetailLembarLingkungan";
import PertumbuhanIndex from "./pages/Pertumbuhan/index";

// Manajemen Bidan Kader
import SuperAdminDashboard from "./pages/SuperAdmin/Dashboard";
// import AuditTrail from "./pages/SuperAdmin/AuditTrail";
import KelolaDesa from "./pages/SuperAdmin/KelolaDesa";
import KelolaWilayah from "./pages/SuperAdmin/KelolaWilayah";
import KelolaNakes from "./pages/SuperAdmin/Kelola Nakes";
import KelolaUser from "./pages/SuperAdmin/Kelola User";
import KelolaPuskesmas from "./pages/SuperAdmin/KelolaPuskesmas";
import KelolaPosyandu from "./pages/SuperAdmin/KelolaPosyandu";
import KelolaPenduduk from "./pages/SuperAdmin/KelolaPenduduk";
import RequestPerubahanImunisasiPage from "./pages/RequestPerubahanImunisasi";

// Detail penduduk
import DetailPenduduk from "./pages/DetailPenduduk";
import PencatatanKesehatan from "./pages/PencatatanKesehatan";
import PencatatanKesehatanKategori from "./pages/PencatatanKesehatanKategori";
import AdminFormVersions from "./pages/SuperAdmin/AdminFormVersions";

const HomeRedirect = () => {
  if (!isAuthenticated()) {
    return <Navigate to="/login" replace />;
  }
  return <Navigate to={getPostLoginRoute()} replace />;
};

function App() {
  return (
    <BrowserRouter>
      <Routes>
        {/* ── PUBLIC (tanpa login) ── */}
        <Route path="/" element={<LandingPage />} />
        <Route path="/edukasi-publik/:category" element={<PublicEdukasiList />} />
        <Route path="/edukasi-publik/:category/:id" element={<PublicEdukasiDetail />} />

        {/* Login */}
        <Route path="/login" element={<Login />} />

        {/* PROTECTED */}
        <Route element={<PrivateRoute />}>
          <Route path="/dashboard/bidan" element={<Dashboard />} />

          {/* Kependudukan */}
          <Route path="/kependudukan" element={<KependudukanList />} />
          <Route path="/kependudukan/create" element={<KependudukanCreate />} />
          <Route path="/kependudukan/edit/:id" element={<KependudukanEdit />} />


          {/* Data Ibu */}
          <Route path="/data-ibu/create" element={<IbuCreate />} />
          <Route path="/data-ibu" element={<IbuList />} />
          <Route path="/data-ibu/:id" element={<IbuDetail />} />
          <Route path="/data-ibu/:id/edit" element={<IbuEdit />} />
          {/* <Route path="/data-ibu/:id/rencana-persalinan" element={<RencanaPersalinanRedirect />} /> */}
          <Route path="/data-ibu/:id/rencana-persalinan/form" element={<RencanaPersalinanForm />} />
          <Route path="/data-ibu/:id/rencana-persalinan/detail" element={<RencanaPersalinanDetail />} />

          {/* Pemeriksaan Dokter T1 Complete */}
          <Route path="/data-ibu/:id/pemeriksaan-dokter-t1-complete" element={<PemeriksaanDokterT1CompleteEntry />} />
          <Route path="/data-ibu/:id/pemeriksaan-dokter-t1-complete/detail" element={<PemeriksaanDokterT1CompleteDetail />} />
          <Route path="/data-ibu/:id/pemeriksaan-dokter-t1-complete/form" element={<PemeriksaanDokterT1Complete />} />

          {/* Pemeriksaan Dokter T3 Complete */}
          <Route path="/data-ibu/:id/pemeriksaan-dokter-t3-complete" element={<PemeriksaanDokterT3CompleteEntry />} />
          <Route path="/data-ibu/:id/pemeriksaan-dokter-t3-complete/detail" element={<PemeriksaanDokterT3CompleteDetail />} />
          <Route path="/data-ibu/:id/pemeriksaan-dokter-t3-complete/form" element={<PemeriksaanDokterT3Complete />} />

          {/* Ibu Lainnya */}
          <Route path="/data-ibu/:id/skrining-preeklampsia" element={<SkriningPreeklampsia />} />
          <Route path="/data-ibu/:id/Skrining-Diabetes-Melitus-Gestasional" element={<SkriningDMG />} />
          <Route path="/data-ibu/:id/skrining-dashboard" element={<SkriningDashboard />} />
          <Route path="/data-ibu/:id/pemeriksaan-fisik" element={<PemeriksaanFisik />} />
          <Route path="/data-ibu/:id/grafik-evaluasi" element={<GrafikEvaluasiKehamilan />} />
          <Route path="/data-ibu/:id/grafik-bb" element={<GrafikPeningkatanBB />} />
          <Route path="/data-ibu/:id/rencana-persalinan" element={<RencanaPersalinan />} />
          <Route path="/data-ibu/:id/pelayanan-nifas" element={<PelayananNifas />} />
          <Route path="/data-ibu/:id/evaluasi-kesehatan" element={<EvaluasiKesehatanIbu />} />
          <Route path="/data-ibu/:id/catatan-pelayanan" element={<CatatanPelayanan />} />
          <Route path="/data-ibu/:id/rujukan" element={<RujukanPage />} />
          <Route path="/data-ibu/:id/rujukan-display" element={<RujukanDisplay />} />
          <Route path="/data-ibu/:id/pelayanan-persalinan" element={<PelayananPersalinan />} />
          <Route path="/data-ibu/:id/pemeriksaan-rutin" element={<PemeriksaanKehamilanList />} />
          <Route path="/data-ibu/:id/pemeriksaan-rutin/:periksaId" element={<PemeriksaanKehamilanForm />} />
          <Route path="/daftar-rujukan" element={<RujukanDashboard />} />
          <Route path="/daftar-skrining" element={<SkriningDashboardList />} />

          {/* Data Anak */}
          <Route path="/daftar-anak" element={<AnakListNakes />} />
          <Route
            path="/data-anak/create"
            element={
              <ProtectedRoute allowedRoles={["bidan"]}>
                <CreateAnak />
              </ProtectedRoute>
            }
          />
          <Route
            path="/data-anak/edit/:id"
            element={
              <ProtectedRoute allowedRoles={["bidan"]}>
                <EditAnak />
              </ProtectedRoute>
            }
          />
          <Route path="/data-anak/:id" element={<DetailAnak />} />

          {/* Monitoring & Laporan */}
          <Route path="/monitoring" element={<Monitoring />} />
          <Route path="/laporan" element={<Laporan />} />
          <Route path="/laporan/ibu/preview" element={<LaporanIbuPreview />} />
          <Route path="/laporan/balita/preview" element={<LaporanBalitaPreview />} />
          <Route path="/laporan/anak/preview" element={<LaporanAnakPreview />} />
          <Route path="/laporan/remaja/preview" element={<LaporanRemajaPreview />} />
          <Route path="/laporan/dewasa/preview" element={<LaporanDewasaPreview />} />
          <Route path="/laporan/lansia/preview" element={<LaporanLansiaPreview />} />
        </Route>

        {/* ADMIN ROUTES */}
        <Route element={<AdminRoute />}>
          <Route path="/dashboard/admin" element={<Dashboard />} />
        </Route>

        <Route path="/superadmin/dashboard" element={<ProtectedRoute allowedRoles={["superadmin"]}><SuperAdminDashboard /></ProtectedRoute>} />
        {/* <Route path="/superadmin/audit-trail" element={<ProtectedRoute allowedRoles={["superadmin"]}><AuditTrail /></ProtectedRoute>} /> */}
        <Route path="/superadmin/kelola-nakes" element={<ProtectedRoute allowedRoles={["superadmin"]}><KelolaNakes /></ProtectedRoute>} />
        <Route path="/superadmin/kelola-user" element={<ProtectedRoute allowedRoles={["superadmin"]}><KelolaUser /></ProtectedRoute>} />
        <Route path="/superadmin/kelola-wilayah" element={<ProtectedRoute allowedRoles={["superadmin"]}><KelolaWilayah /></ProtectedRoute>} />
        <Route path="/superadmin/kelola-desa" element={<ProtectedRoute allowedRoles={["superadmin"]}><KelolaDesa /></ProtectedRoute>} />
        <Route path="/superadmin/kelola-puskesmas" element={<ProtectedRoute allowedRoles={["superadmin"]}><KelolaPuskesmas /></ProtectedRoute>} />
        <Route path="/superadmin/kelola-posyandu" element={<ProtectedRoute allowedRoles={["superadmin"]}><KelolaPosyandu /></ProtectedRoute>} />
        <Route path="/superadmin/kelola-penduduk" element={<ProtectedRoute allowedRoles={["superadmin"]}><KelolaPenduduk /></ProtectedRoute>} />
        <Route path="/superadmin/users" element={<Navigate to="/superadmin/kelola-nakes" replace />} />
        <Route path="/superadmin/desa" element={<Navigate to="/superadmin/kelola-desa" replace />} />

        {/* ── RUTE ANAK (tanpa auth wrapper) ── */}
        <Route path="/data-anak/dashboard/:id" element={<AnakDashboard />} />
        <Route path="/data-anak/pertumbuhan/:id" element={<PertumbuhanIndex />} />
        <Route path="/data-anak/neonatus/:id" element={<NeonatusIndex />} />
        <Route path="/data-anak/pelayanan-gizi/:id" element={<PelayananGiziIndex />} />
        <Route
          path="/data-anak/pelayanan-gizi/:id/create"
          element={
            <ProtectedRoute allowedRoles={["bidan"]}>
              <PelayananGiziCreate />
            </ProtectedRoute>
          }
        />
        <Route path="/data-anak/pelayanan-vitamin/:id" element={<PelayananVitaminIndex />} />
        <Route
          path="/data-anak/pelayanan-vitamin/:id/create"
          element={
            <ProtectedRoute allowedRoles={["bidan"]}>
              <PelayananVitaminCreate />
            </ProtectedRoute>
          }
        />
        <Route path="/data-anak/pelayanan-Imunisasi/:id" element={<PelayananImunisasiIndex />} />
        <Route path="/data-anak/pelayanan-Gigi/:id" element={<PelayananGigiIndex />} />
        <Route path="/data-anak/Tumbuh-kembang-Anak/:id" element={<TumbuhKembangAnak />} />
        <Route path="/data-anak/keluhan/:id" element={<KeluhanAnak />} />
        <Route path="/data-anak/pemantauan/:id" element={<PemantauanAnakPage />} />
        <Route path="/data-anak/perawatan/:id" element={<LembarPerawatanAnak />} />


        {/* ── PEMANTAUAN & PERKEMBANGAN ── */}
        <Route path="/pemantauan/lihat" element={<LihatDataPemantauan />} />
        <Route path="/pemantauan/perkembangan" element={<LihatDataPerkembangan />} />
        <Route path="/pemantauan/kelola-perkembangan" element={<KelolaPerkembangan />} />
        <Route path="/pemantauan/kelola" element={<KelolaPemantauan />} />

        {/* ── EDUKASI DIGITAL ── */}
        <Route path="/edukasi-digital/informasi-umum" element={<InformasiUmumPage />} />
        <Route path="/edukasi-digital/informasi-umum/form" element={<InformasiUmumFormPage />} />
        <Route path="/edukasi-digital/informasi-umum/form/:id" element={<InformasiUmumFormPage />} />
        <Route path="/edukasi-digital/trimester" element={<TrimesterPage />} />
        <Route path="/edukasi-digital/trimester/form" element={<TrimesterFormPage />} />
        <Route path="/edukasi-digital/trimester/form/:id" element={<TrimesterFormPage />} />
        <Route path="/edukasi-digital/tanda-melahirkan" element={<TandaMelahirkanPage />} />
        <Route path="/edukasi-digital/tanda-melahirkan/form" element={<TandaMelahirkanFormPage />} />
        <Route path="/edukasi-digital/tanda-melahirkan/form/:id" element={<TandaMelahirkanFormPage />} />
        <Route path="/edukasi-digital/imd" element={<ImdPage />} />
        <Route path="/edukasi-digital/imd/form" element={<ImdFormPage />} />
        <Route path="/edukasi-digital/imd/form/:id" element={<ImdFormPage />} />
        <Route path="/edukasi-digital/setelah-melahirkan" element={<SetelahMelahirkanPage />} />
        <Route path="/edukasi-digital/setelah-melahirkan/form" element={<SetelahMelahirkanFormPage />} />
        <Route path="/edukasi-digital/setelah-melahirkan/form/:id" element={<SetelahMelahirkanFormPage />} />
        <Route path="/edukasi-digital/menyusui-asi" element={<MenyusuiAsiPage />} />
        <Route path="/edukasi-digital/menyusui-asi/form" element={<MenyusuiAsiFormPage />} />
        <Route path="/edukasi-digital/menyusui-asi/form/:id" element={<MenyusuiAsiFormPage />} />
        <Route path="/edukasi-digital/pola-asuh" element={<PolaAsuhPage />} />
        <Route path="/edukasi-digital/pola-asuh/form" element={<PolaAsuhFormPage />} />
        <Route path="/edukasi-digital/pola-asuh/form/:id" element={<PolaAsuhFormPage />} />
        <Route path="/edukasi-digital/kesehatan-mental" element={<KesehatanMentalPage />} />
        <Route path="/edukasi-digital/kesehatan-mental/form" element={<KesehatanMentalFormPage />} />
        <Route path="/edukasi-digital/kesehatan-mental/form/:id" element={<KesehatanMentalFormPage />} />
        <Route path="/edukasi-digital/perawatan-anak" element={<PerawatanAnakPage />} />
        <Route path="/edukasi-digital/perawatan-anak/form" element={<PerawatanAnakFormPage />} />
        <Route path="/edukasi-digital/perawatan-anak/form/:id" element={<PerawatanAnakFormPage />} />
        <Route path="/edukasi-digital/mpasi" element={<MpasiPage />} />
        <Route path="/edukasi-digital/mpasi/form" element={<MpasiFormPage />} />
        <Route path="/edukasi-digital/mpasi/form/:id" element={<MpasiFormPage />} />

        {/* MPASI Sub-modules */}
        <Route path="/edukasi-digital/mpasi-aturan-porsi" element={<MpasiAturanPorsiPage />} />
        <Route path="/edukasi-digital/mpasi-aturan-porsi/form" element={<MpasiAturanPorsiFormPage />} />
        <Route path="/edukasi-digital/mpasi-aturan-porsi/form/:id" element={<MpasiAturanPorsiFormPage />} />

        <Route path="/edukasi-digital/mpasi-jadwal-harian" element={<MpasiJadwalHarianPage />} />
        <Route path="/edukasi-digital/mpasi-jadwal-harian/form" element={<MpasiJadwalHarianFormPage />} />
        <Route path="/edukasi-digital/mpasi-jadwal-harian/form/:id" element={<MpasiJadwalHarianFormPage />} />
        <Route path="/jadwal-layanan" element={<JadwalLayananPage />} />
        <Route path="/jadwal-layanan/form" element={<JadwalLayananForm />} />
        <Route path="/jadwal-layanan/form/:id" element={<JadwalLayananForm />} />

        <Route path="/edukasi-digital/mpasi-resep" element={<MpasiResepPage />} />
        <Route path="/edukasi-digital/mpasi-resep/form" element={<MpasiResepFormPage />} />
        <Route path="/edukasi-digital/mpasi-resep/form/:id" element={<MpasiResepFormPage />} />

        {/* ── PUSKESMAS (Bidan Puskesmas & Dokter) ── */}
        <Route
          path="/dashboard/puskesmas"
          element={
            <ProtectedRoute allowedRoles={["bidan_puskesmas", "dokter"]}>
              <DashboardPuskesmas />
            </ProtectedRoute>
          }
        />
        <Route
          path="/puskesmas/kelola-vaksin"
          element={
            <ProtectedRoute allowedRoles={["bidan_puskesmas", "dokter"]}>
              <RoleAccessGuard allowedRoles={["bidan_puskesmas"]} featureName="Kelola Vaksin">
                <KelolaVaksin />
              </RoleAccessGuard>
            </ProtectedRoute>
          }
        />
        <Route
          path="/puskesmas/dashboard-dokter"
          element={
            <ProtectedRoute allowedRoles={["bidan_puskesmas", "dokter"]}>
              <RoleAccessGuard allowedRoles={["dokter"]} featureName="Dashboard Dokter">
                <Dashboard />
              </RoleAccessGuard>
            </ProtectedRoute>
          }
        />

        {/* ── DEFAULT ── */}
        <Route path="/dashboard" element={<RootRoute />} />
        <Route path="*" element={<RootRoute />} />
        <Route path="/data-penduduk/:id" element={<DetailPenduduk />} />
        <Route path="/pencatatan-kesehatan" element={<PencatatanKesehatan />} />
        <Route path="/pencatatan-kesehatan/:kategori" element={<PencatatanKesehatanKategori />} />
        <Route path="/perubahan-jadwal-imunisasi" element={<RequestPerubahanImunisasiPage />} />
        <Route path="/superadmin/form-versi" element={<AdminFormVersions />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
