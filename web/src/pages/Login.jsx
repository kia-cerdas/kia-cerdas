// src/pages/Login.jsx
import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { login, getCurrentUser, getUserRedirectRoute, isAuthenticated } from "../services/auth";
import Swal from "sweetalert2";

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
      const user = getCurrentUser();
      const targetRoute = getUserRedirectRoute(user);

      // Popup sukses
      await Swal.fire({
        icon: "success",
        title: "Login Berhasil!",
        text: `Selamat datang, ${user?.name || user?.email || "User"}!`,
        timer: 1500,
        showConfirmButton: false,
        timerProgressBar: true,
      });

      navigate(targetRoute, { replace: true });
    } catch (err) {
      const message = err.response?.data?.message || "Username/email atau password salah. Silakan coba lagi.";
      setError(message);

      // Popup gagal
      Swal.fire({
        icon: "error",
        title: "Login Gagal",
        text: message,
        confirmButtonColor: "#185FA5",
        confirmButtonText: "Coba Lagi",
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center px-4 bg-gray-100">
      <div className="bg-white p-8 rounded-2xl shadow-lg w-full max-w-md">
        <h2 className="text-3xl font-bold mb-2 text-center" style={{ color: "#185FA5" }}>Generasi Sehat</h2>
        <p className="text-gray-600 text-sm text-center mb-1">
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
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-[#185FA5]"
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
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-[#185FA5]"
              placeholder="Masukkan password"
              required
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-[#185FA5] text-white font-bold py-2 rounded-lg hover:bg-[#134E87] transition disabled:bg-gray-400"
          >
            {loading ? "Sedang Login..." : "Login"}
          </button>
        </form>
      </div>
    </div>
  );
};

export default Login;