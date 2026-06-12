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
    <div className="min-h-screen flex items-center justify-center bg-gray-100 px-4">
      <div className="bg-white p-8 rounded-lg shadow-md w-full max-w-md">
        <h2 className="text-3xl font-bold text-indigo-700 mb-2 text-center">KIA Cerdas</h2>
        <p className="text-gray-600 text-sm text-center mb-6">
          Sistem Informasi Kesehatan Ibu dan Anak
        </p>

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
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-500"
              placeholder="Masukkan username atau email"
              required
            />
          </div>

          <div className="mb-6">
            <label htmlFor="password" className="block text-gray-700 font-semibold mb-2">
              Password
            </label>
            <input
              type="password"
              id="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-500"
              placeholder="Masukkan password"
              required
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-indigo-700 text-white font-bold py-2 rounded-lg hover:bg-indigo-800 transition disabled:bg-gray-400"
          >
            {loading ? "Sedang Login..." : "Login"}
          </button>
        </form>
      </div>
    </div>
  );
};

export default Login;