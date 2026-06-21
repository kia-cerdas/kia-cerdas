// src/pages/Login.jsx
import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { login, getCurrentUser, getUserRedirectRoute, isAuthenticated } from "../services/auth";

const Login = () => {
  const navigate = useNavigate();
  const [identifier, setIdentifier] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  // Redirect jika sudah authenticated
  useEffect(() => {
    if (isAuthenticated()) {
      const user = getCurrentUser();
      const targetRoute = getUserRedirectRoute(user);
      navigate(targetRoute, { replace: true });
    }
  }, [navigate]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError("");
    try {
      await login(identifier, password);
      const user = getCurrentUser(); // ambil dari localStorage
      const targetRoute = getUserRedirectRoute(user);
      navigate(targetRoute, { replace: true });
    } catch (err) {
      setError(err.response?.data?.message || "Login gagal");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-slate-50 px-4 font-['Outfit',_sans-serif]">
      <div className="bg-white p-8 rounded-2xl shadow-xl border border-slate-100 w-full max-w-md">
        <div className="flex flex-col items-center mb-6">
          <h2 className="text-3xl font-bold text-blue-700 mb-2 text-center">Generasi Sehat</h2>
          <p className="text-slate-500 text-sm text-center">
            Sistem Informasi Kesehatan Ibu dan Anak
          </p>
        </div>

        {error && (
          <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit}>
          <div className="mb-4">
            <label htmlFor="identifier" className="block text-gray-700 font-semibold mb-2">
              Username / Email
            </label>
            <input
              type="text"
              id="identifier"
              value={identifier}
              onChange={(e) => setIdentifier(e.target.value)}
              className="w-full px-4 py-2.5 border border-slate-200 rounded-xl focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition-all duration-200 placeholder:text-slate-400"
              placeholder="Masukkan username atau email"
              required
            />
          </div>

          <div className="mb-6">
            <label htmlFor="password" className="block text-slate-700 font-semibold mb-2">
              Password
            </label>
            <input
              type="password"
              id="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full px-4 py-2.5 border border-slate-200 rounded-xl focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition-all duration-200 placeholder:text-slate-400"
              placeholder="Masukkan password"
              required
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-blue-600 text-white font-bold py-3 rounded-xl hover:bg-blue-700 transition shadow-lg shadow-blue-100 hover:shadow-xl active:scale-[0.98] disabled:bg-slate-300 disabled:shadow-none duration-150"
          >
            {loading ? "Sedang Login..." : "Login"}
          </button>
        </form>
      </div>
    </div>
  );
};

export default Login;