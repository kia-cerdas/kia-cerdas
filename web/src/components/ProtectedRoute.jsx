// src/components/ProtectedRoute.jsx
import { Navigate } from "react-router-dom";
import { getCurrentUser, getUserRedirectRoute } from "../services/auth";

const ProtectedRoute = ({ children, allowedRoles = [] }) => {
  const user = getCurrentUser();
  
  if (!user) {
    return <Navigate to="/login" replace />;
  }
  
  if (allowedRoles.length > 0) {
    const userRole = user?.role?.toLowerCase();
    const isAllowed = allowedRoles.some(role => role.toLowerCase() === userRole);
    if (!isAllowed) {
      const redirectPath = getUserRedirectRoute(user);
      return <Navigate to={redirectPath} replace />;
    }
  }
  
  return children;
};

export default ProtectedRoute;