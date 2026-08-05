package helpers

import (
	"fmt"
	"net/smtp"
	"os"

	"github.com/joho/godotenv"
)

func SendOTPEmail(toEmail string, otp string) error {

	_ = godotenv.Load()

	// Ambil kredensial
	from := os.Getenv("SMTP_EMAIL")
	password := os.Getenv("SMTP_PASSWORD")

	// Pengecekan agar ketahuan kalau .env belum terbaca
	if from == "" || password == "" {
		return fmt.Errorf("gagal kirim email: SMTP_EMAIL atau SMTP_PASSWORD di .env kosong")
	}

	smtpHost := "smtp.gmail.com"
	smtpPort := "587"

	// Gmail mewajibkan header To dan From, serta menggunakan \r\n (CRLF)
	headers := "From: Generasi Sehat <" + from + ">\r\n" +
		"To: " + toEmail + "\r\n" +
		"Subject: Kode OTP Reset Password Generasi Sehat\r\n" +
		"MIME-version: 1.0;\r\n" +
		"Content-Type: text/html; charset=\"UTF-8\";\r\n\r\n"

	body := fmt.Sprintf(`
		<html>
		<body>
			<h2>Reset Password Generasi Sehat</h2>
			<p>Kode OTP Anda adalah: <b style="font-size: 24px;">%s</b></p>
			<p>Kode ini berlaku selama 5 menit. Jangan bagikan kode ini kepada siapapun.</p>
		</body>
		</html>
	`, otp)

	message := []byte(headers + body)
	auth := smtp.PlainAuth("", from, password, smtpHost)

	// Proses kirim email
	err := smtp.SendMail(smtpHost+":"+smtpPort, auth, from, []string{toEmail}, message)
	if err != nil {
		// Print langsung ke terminal biar kita tahu error aslinya dari Gmail apa
		fmt.Printf("SMTP Error: %v\n", err) 
		return err
	}

	return nil
}