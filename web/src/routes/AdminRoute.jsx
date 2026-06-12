import { Outlet, Navigate } from "react-router-dom";
import { isAuthenticated, getCurrentUser, isAdminUser } from "../services/auth";

const AdminRoute = () => {
  if (!isAuthenticated()) {
    return <Navigate to="/login" replace />;
  }

  const user = getCurrentUser();
  if (!isAdminUser(user)) {
    return <Navigate to="/dashboard" replace />;
  }

  return <Outlet />;
};

export default AdminRoute;
