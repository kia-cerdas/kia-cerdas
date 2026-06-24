import { useState, useEffect } from "react";
import Header from "./Header";
import Sidebar from "./Sidebar";
import Breadcrumb from "../Breadcrumb";

export default function MainLayout({ children }) {
  // Default: sidebar terbuka di desktop, tertutup di mobile
  const [isSidebarOpen, setIsSidebarOpen] = useState(() => {
    if (typeof window !== 'undefined') {
      const isCurrentlyDesktop = window.innerWidth >= 768;
      
      // Cek localStorage untuk preferensi user
      const savedState = localStorage.getItem('sidebarOpen');
      
      // Jika ada saved state, gunakan itu TAPI sesuaikan dengan ukuran layar saat ini
      if (savedState !== null) {
        const savedValue = savedState === 'true';
        // Jika di mobile, paksa closed meskipun saved state true
        if (!isCurrentlyDesktop) {
          return false;
        }
        return savedValue;
      }
      
      // Default: terbuka di desktop, tertutup di mobile
      return isCurrentlyDesktop;
    }
    return true;
  });

  // Track apakah sedang di desktop atau mobile
  const [isDesktop, setIsDesktop] = useState(() => {
    if (typeof window !== 'undefined') {
      return window.innerWidth >= 768;
    }
    return true;
  });

  // Simpan preferensi sidebar ke localStorage
  useEffect(() => {
    localStorage.setItem('sidebarOpen', isSidebarOpen.toString());
  }, [isSidebarOpen]);

  // Monitor window resize untuk mendeteksi desktop/mobile
  useEffect(() => {
    const handleResize = () => {
      setIsDesktop(window.innerWidth >= 768);
    };

    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  return (
    <div className="flex h-screen overflow-hidden">
      {/* Overlay backdrop untuk mobile saat sidebar terbuka */}
      {isSidebarOpen && !isDesktop && (
        <div
          className="fixed inset-0 bg-black/40 z-40 md:hidden"
          onClick={() => setIsSidebarOpen(false)}
        />
      )}

      {/* Sidebar */}
      <Sidebar isOpen={isSidebarOpen} onClose={() => setIsSidebarOpen(false)} />

      {/* Content */}
      <div
        className="flex-1 flex flex-col overflow-hidden transition-all duration-300"
        style={{
          marginLeft: isDesktop && isSidebarOpen ? '256px' : '0',
        }}
      >
        <Header
          onToggleSidebar={() => setIsSidebarOpen(!isSidebarOpen)}
          isSidebarOpen={isSidebarOpen}
        />

        <Breadcrumb />

        <main className="flex-1 overflow-y-auto px-4 pb-4 pt-2 md:px-8 md:pb-8 md:pt-3 custom-scrollbar">
          <div className="max-w-7xl mx-auto">
            {children}
          </div>
        </main>
      </div>
    </div>
  );
}