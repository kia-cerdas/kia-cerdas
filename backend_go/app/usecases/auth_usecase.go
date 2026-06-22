package usecases

import (
	"fmt"
	"net/mail"
	"regexp"
	"strings"
	"time"

	"monitoring-service/app/models"
	"monitoring-service/pkg/customerror"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

type roleDestination struct {
	TargetApp     string
	RedirectRoute string
}

var roleDestinations = map[string]roleDestination{
	"Admin":            {TargetApp: "website", RedirectRoute: "/dashboard/admin"},
	"Superadmin":       {TargetApp: "website", RedirectRoute: "/superadmin/desa"},
	"Dokter":           {TargetApp: "website", RedirectRoute: "/dashboard/puskesmas"},
	"Tenaga-kesehatan": {TargetApp: "website", RedirectRoute: "/dashboard/tenaga-kesehatan"},
	"Kader":            {TargetApp: "mobile", RedirectRoute: "/mobile/home-kader"},
	"Bidan":            {TargetApp: "mobile", RedirectRoute: "/mobile/home-bidan"},
	"Bidan_puskesmas":  {TargetApp: "website", RedirectRoute: "/dashboard/puskesmas"},
	"Ibu":              {TargetApp: "mobile", RedirectRoute: "/mobile/home-orangtua"},
}

var roleAliases = map[string]string{
	"admin":           "Admin",
	"dokter":          "Dokter",
	"tenagakesehatan":  "Tenaga-kesehatan",
	"tenaga-kesehatan": "Tenaga-kesehatan",
	"tenaga kesehatan": "Tenaga-kesehatan",
	"kader":           "Kader",
	"bidan":           "Bidan",
	"bidanpuskesmas":  "Bidan_puskesmas",
	"bidan_puskesmas": "Bidan_puskesmas",
	"superadmin":      "Superadmin",
	"orangtua":        "Orangtua",
	"orang tua":       "Orangtua",
	"orang-tua":       "Orangtua",
	"Ibu":             "Orangtua",
}

var phonePattern = regexp.MustCompile(`^\+62[0-9]{8,13}$`)

func normalizeKey(raw string) string {
	raw = strings.TrimSpace(strings.ToLower(raw))
	raw = strings.ReplaceAll(raw, "-", "")
	raw = strings.ReplaceAll(raw, "_", "")
	raw = strings.ReplaceAll(raw, " ", "")
	return raw
}

func normalizeRoleName(roleName string) string {
	roleName = strings.TrimSpace(roleName)
	if roleName == "" {
		return ""
	}

	if canonical, ok := roleAliases[normalizeKey(roleName)]; ok {
		return canonical
	}

	return roleName
}

func roleRedirect(roleName string) (roleDestination, bool) {
	destination, ok := roleDestinations[roleName]
	return destination, ok
}

func isEmail(input string) bool {
	_, err := mail.ParseAddress(input)
	return err == nil
}

func normalizePhoneNumber(input string) (string, error) {
	phone := strings.TrimSpace(input)
	if phone == "" {
		return "", customerror.NewBadRequestError("nomor hp wajib diisi")
	}

	phone = strings.ReplaceAll(phone, " ", "")
	phone = strings.ReplaceAll(phone, "-", "")
	phone = strings.ReplaceAll(phone, "(", "")
	phone = strings.ReplaceAll(phone, ")", "")

	switch {
	case strings.HasPrefix(phone, "+62"):
		// already normalized
	case strings.HasPrefix(phone, "62"):
		phone = "+" + phone
	case strings.HasPrefix(phone, "08"):
		phone = "+62" + phone[1:]
	case strings.HasPrefix(phone, "8"):
		phone = "+62" + phone
	default:
		return "", customerror.NewBadRequestError("format nomor hp tidak valid")
	}

	if !phonePattern.MatchString(phone) {
		return "", customerror.NewBadRequestError("format nomor hp tidak valid")
	}

	return phone, nil
}

func validateRegisterInput(req *models.RegisterRequest) error {
	if req.Name == "" || req.Email == "" || req.PhoneNumber == "" || req.Password == "" || req.RoleName == "" {
		return customerror.NewBadRequestError("name, email, phone_number, password, dan role_name wajib diisi")
	}

	if len(req.Name) < 3 {
		return customerror.NewBadRequestError("name minimal 3 karakter")
	}

	if _, err := mail.ParseAddress(req.Email); err != nil {
		return customerror.NewBadRequestError("format email tidak valid")
	}

	if len(req.Password) < 8 {
		return customerror.NewBadRequestError("password minimal 8 karakter")
	}

	return nil
}

func (m *Main) buildAccessToken(user *models.User, destination roleDestination, posyanduID *int32) (tokenString string, expiresIn int64, err error) {
	now := time.Now()
	expiry := now.Add(time.Duration(m.config.JWTAccessTokenMins) * time.Minute)

	phoneNumber := ""
	if user.PendudukID != nil {
		if penduduk, err := m.repository.Kependudukan.FindByID(int32(*user.PendudukID)); err == nil && penduduk != nil {
			phoneNumber = penduduk.Telepon
		}
	}

	claims := models.AuthClaims{
		UserID:        user.ID,
		Email:         user.Email,
		PhoneNumber:   phoneNumber,
		Role:          user.Role.Name,
		TargetApp:     destination.TargetApp,
		RedirectRoute: destination.RedirectRoute,
		// DesaID:        desaID,
		PosyanduID:    posyanduID, 
		RegisteredClaims: jwt.RegisteredClaims{
			Subject:   fmt.Sprintf("%d", user.ID),
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(expiry),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err = token.SignedString([]byte(m.config.JWTSecret))
	if err != nil {
		return "", 0, err
	}

	return tokenString, int64(time.Until(expiry).Seconds()), nil
}

func (m *Main) Register(req *models.RegisterRequest) error {
	if req == nil {
		return customerror.NewBadRequestError("request tidak valid")
	}

	req.Name = strings.TrimSpace(req.Name)
	req.Email = strings.TrimSpace(strings.ToLower(req.Email))
	req.PhoneNumber = strings.TrimSpace(req.PhoneNumber)
	req.RoleName = normalizeRoleName(req.RoleName)

	if err := validateRegisterInput(req); err != nil {
		return err
	}

	normalizedPhoneNumber, err := normalizePhoneNumber(req.PhoneNumber)
	if err != nil {
		return err
	}
	req.PhoneNumber = normalizedPhoneNumber

	if _, err := m.repository.GetUserByEmail(req.Email); err == nil {
		return customerror.NewBadRequestError("email sudah terdaftar")
	} else {
		if _, ok := err.(customerror.NotFoundError); !ok {
			return err
		}
	}

	if _, err := m.repository.GetUserByPhoneNumber(req.PhoneNumber); err == nil {
		return customerror.NewBadRequestError("nomor hp sudah terdaftar")
	} else {
		if _, ok := err.(customerror.NotFoundError); !ok {
			return err
		}
	}

	role, err := m.repository.GetRoleByName(req.RoleName)
	if err != nil {
		return err
	}

	var pendudukID *int64

	if req.PendudukID != nil {
		penduduk, err := m.repository.Kependudukan.FindByID(int32(*req.PendudukID))
		if err != nil {
			return customerror.NewBadRequestError("penduduk tidak ditemukan")
		}

		if req.PhoneNumber != "" {
			penduduk.Telepon = req.PhoneNumber
			if err := m.repository.Kependudukan.Update(penduduk); err != nil {
				return customerror.NewInternalServiceError("gagal memperbarui nomor telepon penduduk")
			}
		}

		id := int64(penduduk.IDKependudukan)
		pendudukID = &id
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return customerror.NewInternalServiceError("gagal memproses password")
	}

	user := &models.User{
		Username:   req.Name,
		Email:      req.Email,
		IsActive:   true,
		Password:   string(hashedPassword),
		RoleID:     role.ID,
		PendudukID: pendudukID,
	}

	if err := m.repository.CreateUser(user); err != nil {
		if strings.Contains(strings.ToLower(err.Error()), "duplicate") || strings.Contains(strings.ToLower(err.Error()), "unique") {
			if strings.Contains(strings.ToLower(err.Error()), "phone") {
				return customerror.NewBadRequestError("nomor hp sudah terdaftar")
			}
			return customerror.NewBadRequestError("email sudah terdaftar")
		}
		return err
	}

	return nil
}
func (m *Main) Login(req *models.LoginRequest) (*models.LoginResponse, error) {
	if req == nil {
		return nil, customerror.NewBadRequestError("request tidak valid")
	}

	identifier := strings.TrimSpace(req.Identifier)
	if identifier == "" {
		identifier = strings.TrimSpace(req.Email)
	}

	if identifier == "" || req.Password == "" {
		return nil, customerror.NewBadRequestError("identifier/email dan password wajib diisi")
	}

	var user *models.User
	var err error
	switch {
	case isEmail(identifier):
		// Identifier berupa email
		user, err = m.repository.GetUserByEmail(strings.ToLower(identifier))
	default:
		// Coba sebagai username (kolom `nama`) terlebih dahulu.
		user, err = m.repository.GetUserByUsername(identifier)
		if err != nil {
			if _, ok := err.(customerror.NotFoundError); ok {
				// Username tidak ditemukan: jika identifier berformat nomor hp, coba sebagai nomor hp.
				if normalizedPhoneNumber, nErr := normalizePhoneNumber(identifier); nErr == nil {
					user, err = m.repository.GetUserByPhoneNumber(normalizedPhoneNumber)
				}
			}
		}
	}

	if err != nil {
		if _, ok := err.(customerror.NotFoundError); ok {
			return nil, customerror.NewBadRequestError("username/email/nomor hp atau password salah")
		}
		return nil, err
	}

	if !user.IsActive {
		return nil, customerror.NewBadRequestError("akun dinonaktifkan")
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		return nil, customerror.NewBadRequestError("username/email/nomor hp atau password salah")
	}

	canonicalRoleName := normalizeRoleName(user.Role.Name)

	// =============================================
	// AMBIL POSYANDU_ID HANYA UNTUK BIDAN
	// =============================================
	var posyanduID *int32
	var posyanduNama string
	var phoneNumber string

	 if user.PendudukID != nil {
        pendudukID := int32(*user.PendudukID)
        
        // Ambil phone number dari penduduk
        penduduk, err := m.repository.Kependudukan.FindByID(pendudukID)
        if err == nil && penduduk != nil {
            phoneNumber = penduduk.Telepon
        }

        switch canonicalRoleName {
        case "Bidan":
            //  Cari bidan
            bidan, bErr := m.repository.Bidan.FindByPendudukID(pendudukID)
            if bErr != nil {
                return nil, customerror.NewBadRequestError("data bidan tidak ditemukan")
            }
            if bidan == nil {
                return nil, customerror.NewBadRequestError("data bidan tidak ditemukan")
            }
            if strings.ToLower(strings.TrimSpace(bidan.Status)) != "aktif" {
                return nil, customerror.NewBadRequestError("akun bidan nonaktif")
            }
            
            //  AMBIL POSYANDU_ID DARI BIDAN
            if bidan.PosyanduID != nil {
                posyanduID = bidan.PosyanduID
                // Ambil nama posyandu
                if bidan.Posyandu != nil {
                    posyanduNama = bidan.Posyandu.Nama
                }
            } else {
                //  Logging jika posyandu_id di bidan NULL
                fmt.Printf("⚠️ Bidan dengan penduduk_id %d tidak memiliki posyandu_id\n", pendudukID)
            }

        case "Kader":
            //  Cari kader
            kader, kErr := m.repository.Kader.FindByPendudukID(pendudukID)
            if kErr != nil {
                return nil, customerror.NewBadRequestError("data kader tidak ditemukan")
            }
            if kader == nil {
                return nil, customerror.NewBadRequestError("data kader tidak ditemukan")
            }
            if strings.ToLower(strings.TrimSpace(kader.Status)) != "aktif" {
                return nil, customerror.NewBadRequestError("akun kader nonaktif")
            }
            
            //  AMBIL POSYANDU_ID DARI KADER
            if kader.PosyanduID != nil {
                // Konversi jika tipe data berbeda
                id := int32(*kader.PosyanduID)
                posyanduID = &id
                if kader.Posyandu != nil {
                    posyanduNama = kader.Posyandu.Nama
                }
            } else {
                fmt.Printf("⚠️ Kader dengan penduduk_id %d tidak memiliki posyandu_id\n", pendudukID)
            }
        }
    }


	destination, ok := roleRedirect(canonicalRoleName)
	if !ok {
		return nil, customerror.NewInternalServiceError("role belum memiliki mapping target aplikasi")
	}
	user.Role.Name = canonicalRoleName

	// ========== AMBIL DESA ==========
	var desaID *int32
	var desaNama string
	if user.PendudukID != nil {
		penduduk, err := m.repository.Kependudukan.FindByID(int32(*user.PendudukID))
		if err == nil && penduduk != nil && penduduk.DesaID != nil {
			desaID = penduduk.DesaID
			desa, err := m.repository.Desa.FindByID(*penduduk.DesaID)
			if err == nil && desa != nil {
				desaNama = desa.NamaDesa
			}
		}
	}

	// =============================================
	// BUILD TOKEN DENGAN POSYANDU_ID
	// =============================================
	accessToken, expiresIn, err := m.buildAccessToken(user, destination, posyanduID)
	if err != nil {
		return nil, customerror.NewInternalServiceError("gagal membuat access token")
	}

	// =============================================
	// RESPONSE
	// =============================================
	res := &models.LoginResponse{
		AccessToken:   accessToken,
		TokenType:     "Bearer",
		ExpiresIn:     expiresIn,
		UserID:        user.ID,
		Name:          user.Username,
		Email:         user.Email,
		PhoneNumber:   phoneNumber,
		Role:          user.Role.Name,
		TargetApp:     destination.TargetApp,
		RedirectRoute: destination.RedirectRoute,
		DesaID:        desaID,
		DesaNama:      desaNama,
		PosyanduID:    posyanduID,   
		PosyanduNama:  posyanduNama, 
	}

	return res, nil
}
// func (m *Main) Login(req *models.LoginRequest) (*models.LoginResponse, error) {
// 	if req == nil {
// 		return nil, customerror.NewBadRequestError("request tidak valid")
// 	}

// 	identifier := strings.TrimSpace(req.Identifier)
// 	if identifier == "" {
// 		identifier = strings.TrimSpace(req.Email)
// 	}

// 	if identifier == "" || req.Password == "" {
// 		return nil, customerror.NewBadRequestError("identifier/email dan password wajib diisi")
// 	}

// 	var user *models.User
// 	var err error
// 	if isEmail(identifier) {
// 		user, err = m.repository.GetUserByEmail(strings.ToLower(identifier))
// 	} else {
// 		normalizedPhoneNumber, nErr := normalizePhoneNumber(identifier)
// 		if nErr != nil {
// 			return nil, customerror.NewBadRequestError("identifier harus email atau nomor hp valid")
// 		}
// 		user, err = m.repository.GetUserByPhoneNumber(normalizedPhoneNumber)
// 	}

// 	if err != nil {
// 		if _, ok := err.(customerror.NotFoundError); ok {
// 			return nil, customerror.NewBadRequestError("email/nomor hp atau password salah")
// 		}
// 		return nil, err
// 	}

// 	if !user.IsActive {
// 		return nil, customerror.NewBadRequestError("akun dinonaktifkan")
// 	}

// 	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
// 		return nil, customerror.NewBadRequestError("email/nomor hp atau password salah")
// 	}

// 	canonicalRoleName := normalizeRoleName(user.Role.Name)

// 	// =============================================
// 	// AMBIL POSYANDU_ID BERDASARKAN ROLE
// 	// =============================================
// 	var posyanduID *int32
// 	var posyanduNama string
// 	var phoneNumber string

// 	if user.PendudukID != nil {
// 		// Ambil phone number dari penduduk
// 		penduduk, err := m.repository.Kependudukan.FindByID(int32(*user.PendudukID))
// 		if err == nil && penduduk != nil {
// 			phoneNumber = penduduk.Telepon
// 		}

// 		switch canonicalRoleName {
// 		case "Bidan":
// 			bidan, bErr := m.repository.Bidan.FindByPendudukID(int32(*user.PendudukID))
// 			if bErr != nil {
// 				return nil, customerror.NewBadRequestError("data bidan tidak ditemukan")
// 			}
// 			if strings.ToLower(strings.TrimSpace(bidan.Status)) != "aktif" {
// 				return nil, customerror.NewBadRequestError("akun bidan nonaktif")
// 			}
// 			// POSYANDU_ID DARI BIDAN (tempat bertugas)
// 			if bidan.PosyanduID != nil {
// 				posyanduID = bidan.PosyanduID
// 				posyandu, pErr := m.repository.Posyandu.FindByID(*bidan.PosyanduID)
// 				if pErr == nil && posyandu != nil {
// 					posyanduNama = posyandu.Nama
// 				}
// 			}

// 		case "Kader":
// 			kader, kErr := m.repository.Kader.FindByPendudukID(int32(*user.PendudukID))
// 			if kErr != nil {
// 				return nil, customerror.NewBadRequestError("data kader tidak ditemukan")
// 			}
// 			if strings.ToLower(strings.TrimSpace(kader.Status)) != "aktif" {
// 				return nil, customerror.NewBadRequestError("akun kader nonaktif")
// 			}
// 			// POSYANDU_ID DARI KADER
// 			if kader.PosyanduID != nil {
// 				posyanduID = kader.PosyanduID
// 				posyandu, pErr := m.repository.Posyandu.FindByID(*kader.PosyanduID)
// 				if pErr == nil && posyandu != nil {
// 					posyanduNama = posyandu.Nama
// 				}
// 			}
// 		}
// 	}

// 	destination, ok := roleRedirect(canonicalRoleName)
// 	if !ok {
// 		return nil, customerror.NewInternalServiceError("role belum memiliki mapping target aplikasi")
// 	}
// 	user.Role.Name = canonicalRoleName

// 	// ========== AMBIL DESA ==========
// 	var desaID *int32
// 	var desaNama string
// 	if user.PendudukID != nil {
// 		penduduk, err := m.repository.Kependudukan.FindByID(int32(*user.PendudukID))
// 		if err == nil && penduduk != nil && penduduk.DesaID != nil {
// 			desaID = penduduk.DesaID
// 			desa, err := m.repository.Desa.FindByID(*penduduk.DesaID)
// 			if err == nil && desa != nil {
// 				desaNama = desa.NamaDesa
// 			}
// 		}
// 	}

// 	// =============================================
// 	// BUILD TOKEN DENGAN POSYANDU_ID
// 	// =============================================
// 	accessToken, expiresIn, err := m.buildAccessToken(user, destination, posyanduID)
// 	if err != nil {
// 		return nil, customerror.NewInternalServiceError("gagal membuat access token")
// 	}

// 	// =============================================
// 	// RESPONSE - LENGKAPI SEMUA FIELD
// 	// =============================================
// 	res := &models.LoginResponse{
// 		AccessToken:   accessToken,
// 		TokenType:     "Bearer",
// 		ExpiresIn:     expiresIn,
// 		UserID:        user.ID,
// 		Name:          user.Name,
// 		Email:         user.Email,
// 		PhoneNumber:   phoneNumber,              
// 		Role:          user.Role.Name,
// 		TargetApp:     destination.TargetApp,
// 		RedirectRoute: destination.RedirectRoute,
// 		DesaID:        desaID,
// 		DesaNama:      desaNama,
// 		PosyanduID:    posyanduID,
// 		PosyanduNama:  posyanduNama,
// 	}

// 	return res, nil
// }