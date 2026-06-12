import React, { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { getPostLoginRoute, isAuthenticated } from "../services/auth";

const RootRoute = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = React.useState(true);

  useEffect(() => {
    // Berikan delay kecil untuk ensure routing logic berjalan
    const timer = setTimeout(() => {
      if (isAuthenticated()) {
        const targetRoute = getPostLoginRoute();
        navigate(targetRoute, { replace: true });
      } else {
        navigate("/login", { replace: true });
      }
      setLoading(false);
    }, 100);

    return () => clearTimeout(timer);
  }, [navigate]);

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-100">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-700 mb-4"></div>
          <p className="text-gray-600">Loading...</p>
        </div>
      </div>
    );
  }

  return null;
};

export default RootRoute;
