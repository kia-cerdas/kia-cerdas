import Header from "./Header";
import Sidebar from "./Sidebar";
import Breadcrumb from "../Breadcrumb";

export default function MainLayout({ children }) {
  return (
    <div className="flex h-screen">
      {/* Sidebar */}
      <Sidebar />

      {/* Content */}
      <div className="flex-1 flex flex-col">
        <Header />

        {/* Breadcrumb Navigation */}
        <Breadcrumb />

        {/* Main Content - Hanya area ini yang bisa scroll kebawah */}
        <main className="flex-1 overflow-y-auto px-4 pb-4 pt-2 md:px-8 md:pb-8 md:pt-3 custom-scrollbar">
          {/* Container agar konten tidak terlalu lebar di layar ultra-wide */}
          <div className="max-w-7xl mx-auto">
            {children}
          </div>
        </main>
      </div>
    </div>
  );
}