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
    <div className="min-h-screen flex items-center justify-center px-4 bg-background">
      <div className="bg-white p-8 rounded-2xl shadow-lg w-full max-w-md">
        <h2 className="text-3xl font-bold mb-2 text-center text-primary">Generasi Sehat</h2>
        <p className="text-gray-600 text-sm text-center mb-1">
          Sistem Informasi Kesehatan Ibu dan Anak
        </p>
        

        {error && (
          <div className="bg-danger/10 border border-danger/30 text-danger px-4 py-3 rounded-lg mb-4">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-5">
          <div>
            <label htmlFor="identifier" className="block text-gray-700 font-semibold mb-2">
              Username / Email
            </label>
            <input
              type="text"
              id="identifier"
              value={identifier}
              onChange={(e) => setIdentifier(e.target.value)}
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-primary focus:ring-2 focus:ring-primary/20 transition"
              placeholder="Masukkan username atau email"
              required
            />
          </div>

          <div>
            <label htmlFor="password" className="block text-gray-700 font-semibold mb-2">
              Password
            </label>
            <input
              type="password"
              id="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-primary focus:ring-2 focus:ring-primary/20 transition"
              placeholder="Masukkan password"
              required
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-primary text-white font-bold py-3 rounded-lg hover:bg-primary/90 transition disabled:bg-gray-400 disabled:cursor-not-allowed"
          >
            {loading ? "Sedang Masuk..." : "Masuk"}
          </button>
        </form>
      </div>
    </div>
  );
};

export default Login;