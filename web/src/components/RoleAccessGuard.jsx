import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import Swal from 'sweetalert2';
import { getCurrentUser, getUserRedirectRoute } from '../services/auth';

/**
 * Component untuk memvalidasi akses berdasarkan role
 * Jika user tidak memiliki akses, tampilkan SweetAlert dan redirect
 */
const RoleAccessGuard = ({ allowedRoles, children, featureName }) => {
  const navigate = useNavigate();
  const user = getCurrentUser();
  const userRole = user?.role?.toLowerCase();

  useEffect(() => {
    // Cek apakah user memiliki akses
    const hasAccess = allowedRoles.includes(userRole);

    if (!hasAccess) {
      // Tentukan nama role yang diizinkan dalam bahasa Indonesia
      let allowedRoleNames = allowedRoles.map(role => {
        switch(role) {
          case 'bidan_puskesmas': return 'Bidan Puskesmas';
          case 'dokter': return 'Dokter';
          case 'bidan': return 'Bidan';
          case 'admin': return 'Admin';
          case 'superadmin': return 'Super Admin';
          default: return role;
        }
      }).join(' atau ');

      // Tampilkan SweetAlert
      Swal.fire({
        icon: 'warning',
        title: 'Akses Ditolak',
        html: `<p><strong>${featureName || 'Fitur ini'}</strong> hanya dapat diakses oleh <strong>${allowedRoleNames}</strong>.</p>`,
        confirmButtonText: 'Kembali',
        confirmButtonColor: '#3b82f6',
        allowOutsideClick: false,
        allowEscapeKey: false,
      }).then(() => {
        // Redirect ke halaman dashboard sesuai role
        const redirectPath = getUserRedirectRoute(user);
        navigate(redirectPath, { replace: true });
      });
    }
  }, [userRole, allowedRoles, navigate, user, featureName]);

  // Cek apakah user memiliki akses
  const hasAccess = allowedRoles.includes(userRole);

  // Jika tidak punya akses, tampilkan loading sementara menunggu redirect
  if (!hasAccess) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Memvalidasi akses...</p>
        </div>
      </div>
    );
  }

  // Jika punya akses, render children
  return children;
};

export default RoleAccessGuard;
