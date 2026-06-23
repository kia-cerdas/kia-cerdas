package controllers

import (
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/labstack/echo/v4"
)

// UploadImage menerima file gambar via multipart/form-data,
// menyimpannya ke folder static/uploads/, dan mengembalikan URL-nya.
func UploadImage(c echo.Context) error {
	// Ambil file dari form field "image"
	file, err := c.FormFile("image")
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": "File tidak ditemukan. Gunakan field 'image'."})
	}

	// Validasi tipe file
	ext := strings.ToLower(filepath.Ext(file.Filename))
	allowed := map[string]bool{".jpg": true, ".jpeg": true, ".png": true, ".webp": true, ".gif": true}
	if !allowed[ext] {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": "Tipe file tidak didukung. Gunakan jpg, jpeg, png, webp, atau gif."})
	}

	// Validasi ukuran file (maks 5 MB)
	const maxSize = 5 * 1024 * 1024
	if file.Size > maxSize {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": "Ukuran file terlalu besar. Maksimal 5 MB."})
	}

	// Buat folder jika belum ada
	uploadDir := "static/uploads"
	if err := os.MkdirAll(uploadDir, os.ModePerm); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": "Gagal membuat direktori upload."})
	}

	// Buat nama file unik berdasarkan timestamp
	timestamp := time.Now().UnixNano()
	filename := fmt.Sprintf("%d%s", timestamp, ext)
	savePath := filepath.Join(uploadDir, filename)

	// Buka file sumber
	src, err := file.Open()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": "Gagal membuka file."})
	}
	defer src.Close()

	// Simpan ke disk
	dst, err := os.Create(savePath)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": "Gagal menyimpan file."})
	}
	defer dst.Close()

	buf := make([]byte, 32*1024)
	for {
		n, readErr := src.Read(buf)
		if n > 0 {
			if _, writeErr := dst.Write(buf[:n]); writeErr != nil {
				return c.JSON(http.StatusInternalServerError, echo.Map{"error": "Gagal menulis file."})
			}
		}
		if readErr != nil {
			break
		}
	}

	// Bangun URL publik
	scheme := "http"
	if c.Request().TLS != nil {
		scheme = "https"
	}
	host := c.Request().Host
	imageURL := fmt.Sprintf("%s://%s/static/uploads/%s", scheme, host, filename)

	return c.JSON(http.StatusOK, echo.Map{
		"url":      imageURL,
		"filename": filename,
		"message":  "Gambar berhasil diunggah.",
	})
}
