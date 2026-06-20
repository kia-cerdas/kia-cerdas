package usecases

import (
	"crypto/rand"
	"encoding/hex"
	"errors"
	"strings"

	"monitoring-service/app/models"
	"monitoring-service/app/repositories"
	"monitoring-service/pkg/customerror"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type SuperadminCreateBidanUserRequest struct {
	PendudukID  int32  `json:"penduduk_id"`
	Name        string `json:"name"`
	Email       string `json:"email"`
	PhoneNumber string `json:"phone_number"`
	Password    string `json:"password"`
	DesaID      *int32 `json:"desa_id,omitempty"`
	NoSTR       string `json:"no_str"`
	NoSIPB      string `json:"no_sipb"`
}

type SuperadminCreateAdminDesaUserRequest struct {
	PendudukID  *int32 `json:"penduduk_id,omitempty"`
	Name        string `json:"name"`
	Email       string `json:"email"`
	PhoneNumber string `json:"phone_number"`
	Password    string `json:"password"`
	DesaID      *int32 `json:"desa_id,omitempty"`
}

type SuperadminCreateKaderUserRequest struct {
	PendudukID  int32  `json:"penduduk_id"`
	Name        string `json:"name"`
	Email       string `json:"email"`
	PhoneNumber string `json:"phone_number"`
	Password    string `json:"password"`
	DesaID      *int32 `json:"desa_id,omitempty"`
	PosyanduID  *int64 `json:"posyandu_id,omitempty"`
}

type SuperadminCreateUserRequest struct {
	PendudukID  *int64 `json:"penduduk_id,omitempty"`
	Name        string `json:"name"`
	Email       string `json:"email"`
	PhoneNumber string `json:"phone_number"`
	Password    string `json:"password"`
	RoleName    string `json:"role_name"`
	DesaID      *int32 `json:"desa_id,omitempty"`
}

type SuperadminUpdateUserRoleRequest struct {
	RoleName string `json:"role_name"`
}

type SuperadminResetPasswordRequest struct {
	Password string `json:"password"`
}

type SuperadminUserUsecase struct {
	repo *repositories.Main
}

type SuperadminUserActionResponse struct {
	User  *models.User  `json:"user"`
	Bidan *models.Bidan `json:"bidan,omitempty"`
	Kader *models.Kader `json:"kader,omitempty"`
}

func NewSuperadminUserUsecase(repo *repositories.Main) *SuperadminUserUsecase {
	return &SuperadminUserUsecase{repo: repo}
}

func (u *SuperadminUserUsecase) isNotFound(err error) bool {
	return err != nil && errors.Is(err, gorm.ErrRecordNotFound)
}

func (u *SuperadminUserUsecase) getPendudukDesaID(pendudukID int32) (*int32, error) {
	penduduk, err := u.repo.Kependudukan.FindByID(pendudukID)
	if err != nil {
		return nil, customerror.NewNotFoundError("penduduk tidak ditemukan")
	}
	if penduduk.DesaID == nil || *penduduk.DesaID == 0 {
		return nil, customerror.NewBadRequestError("penduduk belum memiliki desa_id")
	}
	if _, err := u.repo.Desa.GetByID(*penduduk.DesaID); err != nil {
		return nil, customerror.NewNotFoundError("desa pada data penduduk tidak ditemukan")
	}
	return penduduk.DesaID, nil
}

func (u *SuperadminUserUsecase) validateDesaConsistency(requestDesaID, actualDesaID *int32) error {
	if requestDesaID == nil {
		return nil
	}
	if *requestDesaID == 0 {
		return customerror.NewBadRequestError("desa_id tidak valid")
	}
	if _, err := u.repo.Desa.GetByID(*requestDesaID); err != nil {
		return customerror.NewNotFoundError("desa tidak ditemukan")
	}
	if actualDesaID != nil && *actualDesaID != *requestDesaID {
		return customerror.NewBadRequestError("desa_id harus sama dengan desa pada data penduduk")
	}
	return nil
}

func (u *SuperadminUserUsecase) validateBaseUserFields(name, email, phoneNumber, password string) (string, string, error) {
	name = strings.TrimSpace(name)
	email = strings.ToLower(strings.TrimSpace(email))
	phoneNumber = strings.TrimSpace(phoneNumber)
	password = strings.TrimSpace(password)

	if name == "" || email == "" || password == "" {
		return "", "", customerror.NewBadRequestError("name, email, dan password wajib diisi")
	}
	if len(password) < 8 {
		return "", "", customerror.NewBadRequestError("password minimal 8 karakter")
	}

	var normalizedPhone string
	var err error
	if phoneNumber != "" {
		normalizedPhone, err = normalizePhoneNumber(phoneNumber)
		if err != nil {
			return "", "", err
		}
	}

	return email, normalizedPhone, nil
}

func (u *SuperadminUserUsecase) preparePassword(password string) (string, error) {
	password = strings.TrimSpace(password)
	if password == "" {
		buf := make([]byte, 8)
		if _, err := rand.Read(buf); err != nil {
			return "", customerror.NewInternalServiceError("gagal membuat password sementara")
		}
		password = hex.EncodeToString(buf)
	}
	if len(password) < 8 {
		return "", customerror.NewBadRequestError("password minimal 8 karakter")
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return "", customerror.NewInternalServiceError("gagal memproses password")
	}

	return string(hashedPassword), nil
}

func (u *SuperadminUserUsecase) ListUsers(search, role, desa string) ([]repositories.UserListItem, error) {
	return u.repo.User.List(search, role, desa)
}

func (u *SuperadminUserUsecase) ListPenduduk(search string) ([]repositories.EligiblePendudukItem, error) {
	return u.repo.Kependudukan.ListAvailableForSuperadmin(search)
}

func (u *SuperadminUserUsecase) GetUser(id int32) (*models.User, error) {
	if id == 0 {
		return nil, customerror.NewBadRequestError("id user tidak valid")
	}
	user, err := u.repo.User.FindByID(id)
	if err != nil {
		return nil, customerror.NewNotFoundError("user tidak ditemukan")
	}
	return user, nil
}

func (u *SuperadminUserUsecase) CreateBidanUser(req *SuperadminCreateBidanUserRequest) (*SuperadminUserActionResponse, error) {
	if req == nil {
		return nil, customerror.NewBadRequestError("request tidak valid")
	}
	if req.PendudukID == 0 {
		return nil, customerror.NewBadRequestError("penduduk_id wajib diisi")
	}
	if strings.TrimSpace(req.NoSIPB) == "" {
		return nil, customerror.NewBadRequestError("no_sipb wajib diisi")
	}

	email, normalizedPhone, err := u.validateBaseUserFields(req.Name, req.Email, req.PhoneNumber, req.Password)
	if err != nil {
		return nil, err
	}
	penduduk, err := u.repo.Kependudukan.FindByID(req.PendudukID)
	if err != nil {
		return nil, customerror.NewNotFoundError("penduduk tidak ditemukan")
	}
	if normalizedPhone == "" && penduduk.Telepon != "" {
		normalizedPhone, err = normalizePhoneNumber(penduduk.Telepon)
		if err != nil {
			return nil, err
		}
	}
	if normalizedPhone == "" {
		return nil, customerror.NewBadRequestError("penduduk belum memiliki nomor telepon. Silakan lengkapi data kependudukan terlebih dahulu.")
	}
	pendudukDesaID := penduduk.DesaID
	if pendudukDesaID == nil || *pendudukDesaID == 0 {
		return nil, customerror.NewBadRequestError("penduduk belum memiliki desa_id")
	}
	if _, err := u.repo.Desa.GetByID(*pendudukDesaID); err != nil {
		return nil, customerror.NewNotFoundError("desa pada data penduduk tidak ditemukan")
	}
	if err := u.validateDesaConsistency(req.DesaID, pendudukDesaID); err != nil {
		return nil, err
	}

	if _, err := u.repo.Bidan.FindByPendudukID(req.PendudukID); err == nil {
		return nil, customerror.NewConflictError("penduduk sudah terdaftar sebagai bidan")
	} else if !u.isNotFound(err) {
		return nil, customerror.NewInternalServiceError("gagal memvalidasi data bidan")
	}
	if _, err := u.repo.Kader.FindByPendudukID(req.PendudukID); err == nil {
		return nil, customerror.NewConflictError("penduduk sudah terdaftar sebagai kader")
	} else if !u.isNotFound(err) {
		return nil, customerror.NewInternalServiceError("gagal memvalidasi data kader")
	}
	if _, err := u.repo.User.FindByPendudukID(int64(req.PendudukID)); err == nil {
		return nil, customerror.NewConflictError("penduduk sudah memiliki akun pengguna")
	} else if !u.isNotFound(err) {
		return nil, customerror.NewInternalServiceError("gagal memvalidasi akun pengguna")
	}
	if _, err := u.repo.User.FindByEmail(email); err == nil {
		return nil, customerror.NewConflictError("email sudah terdaftar")
	} else if !u.isNotFound(err) {
		return nil, customerror.NewInternalServiceError("gagal memvalidasi email")
	}
	if _, err := u.repo.User.FindByPhoneNumber(normalizedPhone); err == nil {
		return nil, customerror.NewConflictError("nomor hp sudah terdaftar")
	} else if !u.isNotFound(err) {
		return nil, customerror.NewInternalServiceError("gagal memvalidasi nomor hp")
	}

	role, err := u.repo.Role.FindByName("Bidan")
	if err != nil {
		return nil, customerror.NewNotFoundError("role bidan tidak ditemukan")
	}
	hashedPassword, err := u.preparePassword(req.Password)
	if err != nil {
		return nil, err
	}

	var createdUser models.User
	var createdBidan models.Bidan
	pendudukID64 := int64(req.PendudukID)
	err = u.repo.DB().Transaction(func(tx *gorm.DB) error {
		createdUser = models.User{
			Username:   strings.TrimSpace(req.Name),
			Email:      email,
			IsActive:   true,
			Password:   hashedPassword,
			RoleID:     role.ID,
			PendudukID: &pendudukID64,
		}
		if err := tx.Create(&createdUser).Error; err != nil {
			return err
		}
		if err := tx.Model(&models.Kependudukan{}).Where("id = ?", req.PendudukID).Update("telepon", normalizedPhone).Error; err != nil {
			return err
		}
		createdBidan = models.Bidan{
			PendudukID: req.PendudukID,
			NoSTR:      strings.TrimSpace(req.NoSTR),
			NoSIPB:     strings.TrimSpace(req.NoSIPB),
			Status:     "aktif",
		}
		if err := tx.Create(&createdBidan).Error; err != nil {
			return err
		}
		return nil
	})
	if err != nil {
		if strings.Contains(strings.ToLower(err.Error()), "unique") || strings.Contains(strings.ToLower(err.Error()), "duplicate") {
			return nil, customerror.NewConflictError("data bidan atau akun pengguna sudah terdaftar")
		}
		return nil, customerror.NewInternalServiceError("gagal membuat akun bidan: " + err.Error())
	}
	return &SuperadminUserActionResponse{User: &createdUser, Bidan: &createdBidan}, nil
}

func (u *SuperadminUserUsecase) CreateAdminDesaUser(req *SuperadminCreateAdminDesaUserRequest) (*models.User, error) {
	if req == nil {
		return nil, customerror.NewBadRequestError("request tidak valid")
	}
	if req.PendudukID == nil || *req.PendudukID == 0 {
		return nil, customerror.NewBadRequestError("penduduk_id wajib diisi agar desa mengikuti data kependudukan")
	}

	email, normalizedPhone, err := u.validateBaseUserFields(req.Name, req.Email, req.PhoneNumber, req.Password)
	if err != nil {
		return nil, err
	}
	penduduk, err := u.repo.Kependudukan.FindByID(*req.PendudukID)
	if err != nil {
		return nil, customerror.NewNotFoundError("penduduk tidak ditemukan")
	}
	// Jika nomor HP tidak diisi di request, ambil dari data penduduk
	if normalizedPhone == "" && penduduk.Telepon != "" {
		normalizedPhone, err = normalizePhoneNumber(penduduk.Telepon)
		if err != nil {
			// Jika normalisasi gagal, tetap lanjutkan (akan ter-handle di bawah)
			normalizedPhone = ""
		}
	}
	// Nomor HP wajib diisi (dari request atau dari penduduk)
	if normalizedPhone == "" {
		return nil, customerror.NewBadRequestError("nomor hp wajib diisi (isi di form atau lengkapi data kependudukan)")
	}
	pendudukDesaID := penduduk.DesaID
	if pendudukDesaID == nil || *pendudukDesaID == 0 {
		return nil, customerror.NewBadRequestError("penduduk belum memiliki desa_id")
	}
	if _, err := u.repo.Desa.GetByID(*pendudukDesaID); err != nil {
		return nil, customerror.NewNotFoundError("desa pada data penduduk tidak ditemukan")
	}
	if err := u.validateDesaConsistency(req.DesaID, pendudukDesaID); err != nil {
		return nil, err
	}

	pendudukID64 := int64(*req.PendudukID)
	pendudukID := &pendudukID64
	if _, err := u.repo.User.FindByEmail(email); err == nil {
		return nil, customerror.NewConflictError("email sudah terdaftar")
	} else if !u.isNotFound(err) {
		return nil, customerror.NewInternalServiceError("gagal memvalidasi email")
	}
	if _, err := u.repo.User.FindByPhoneNumber(normalizedPhone); err == nil {
		return nil, customerror.NewConflictError("nomor hp sudah terdaftar")
	} else if !u.isNotFound(err) {
		return nil, customerror.NewInternalServiceError("gagal memvalidasi nomor hp")
	}
	if _, err := u.repo.User.FindByPendudukID(*pendudukID); err == nil {
		return nil, customerror.NewConflictError("penduduk sudah memiliki akun pengguna")
	} else if !u.isNotFound(err) {
		return nil, customerror.NewInternalServiceError("gagal memvalidasi akun pengguna")
	}

	role, err := u.repo.Role.FindByName("Admin")
	if err != nil {
		role, err = u.repo.Role.FindByName("Admin_desa")
		if err != nil {
			return nil, customerror.NewNotFoundError("role admin tidak ditemukan")
		}
	}
	hashedPassword, err := u.preparePassword(req.Password)
	if err != nil {
		return nil, err
	}

	var user *models.User
	err = u.repo.DB().Transaction(func(tx *gorm.DB) error {
		user = &models.User{
			Username:   strings.TrimSpace(req.Name),
			Email:      email,
			IsActive:   true,
			Password:   hashedPassword,
			RoleID:     role.ID,
			PendudukID: pendudukID,
		}
		if err := tx.Create(user).Error; err != nil {
			return err
		}
		if pendudukID != nil {
			if err := tx.Model(&models.Kependudukan{}).Where("id = ?", *pendudukID).Update("telepon", normalizedPhone).Error; err != nil {
				return err
			}
		}
		return nil
	})
	if err != nil {
		if strings.Contains(strings.ToLower(err.Error()), "unique") || strings.Contains(strings.ToLower(err.Error()), "duplicate") {
			return nil, customerror.NewConflictError("data user sudah terdaftar")
		}
		return nil, customerror.NewInternalServiceError("gagal membuat akun admin desa")
	}
	return user, nil
}

func (u *SuperadminUserUsecase) CreateKaderUser(req *SuperadminCreateKaderUserRequest) (*SuperadminUserActionResponse, error) {
	if req == nil {
		return nil, customerror.NewBadRequestError("request tidak valid")
	}
	if req.PendudukID == 0 {
		return nil, customerror.NewBadRequestError("penduduk_id wajib diisi")
	}

	email, normalizedPhone, err := u.validateBaseUserFields(req.Name, req.Email, req.PhoneNumber, req.Password)
	if err != nil {
		return nil, err
	}
	penduduk, err := u.repo.Kependudukan.FindByID(req.PendudukID)
	if err != nil {
		return nil, customerror.NewNotFoundError("penduduk tidak ditemukan")
	}
	// Jika nomor HP tidak diisi di request, ambil dari data penduduk
	if normalizedPhone == "" && penduduk.Telepon != "" {
		normalizedPhone, err = normalizePhoneNumber(penduduk.Telepon)
		if err != nil {
			// Jika normalisasi gagal, tetap lanjutkan (akan ter-handle di bawah)
			normalizedPhone = ""
		}
	}
	// Nomor HP wajib diisi (dari request atau dari penduduk)
	if normalizedPhone == "" {
		return nil, customerror.NewBadRequestError("nomor hp wajib diisi (isi di form atau lengkapi data kependudukan)")
	}
	pendudukDesaID := penduduk.DesaID
	if pendudukDesaID == nil || *pendudukDesaID == 0 {
		return nil, customerror.NewBadRequestError("penduduk belum memiliki desa_id")
	}
	if _, err := u.repo.Desa.GetByID(*pendudukDesaID); err != nil {
		return nil, customerror.NewNotFoundError("desa pada data penduduk tidak ditemukan")
	}
	if err := u.validateDesaConsistency(req.DesaID, pendudukDesaID); err != nil {
		return nil, err
	}

	if _, err := u.repo.Bidan.FindByPendudukID(req.PendudukID); err == nil {
		return nil, customerror.NewConflictError("penduduk sudah terdaftar sebagai bidan")
	} else if !u.isNotFound(err) {
		return nil, customerror.NewInternalServiceError("gagal memvalidasi data bidan")
	}
	if _, err := u.repo.Kader.FindByPendudukID(req.PendudukID); err == nil {
		return nil, customerror.NewConflictError("penduduk sudah terdaftar sebagai kader")
	} else if !u.isNotFound(err) {
		return nil, customerror.NewInternalServiceError("gagal memvalidasi data kader")
	}
	if _, err := u.repo.User.FindByPendudukID(int64(req.PendudukID)); err == nil {
		return nil, customerror.NewConflictError("penduduk sudah memiliki akun pengguna")
	} else if !u.isNotFound(err) {
		return nil, customerror.NewInternalServiceError("gagal memvalidasi akun pengguna")
	}
	if _, err := u.repo.User.FindByEmail(email); err == nil {
		return nil, customerror.NewConflictError("email sudah terdaftar")
	} else if !u.isNotFound(err) {
		return nil, customerror.NewInternalServiceError("gagal memvalidasi email")
	}
	if _, err := u.repo.User.FindByPhoneNumber(normalizedPhone); err == nil {
		return nil, customerror.NewConflictError("nomor hp sudah terdaftar")
	} else if !u.isNotFound(err) {
		return nil, customerror.NewInternalServiceError("gagal memvalidasi nomor hp")
	}

	role, err := u.repo.Role.FindByName("Kader")
	if err != nil {
		return nil, customerror.NewNotFoundError("role kader tidak ditemukan")
	}
	hashedPassword, err := u.preparePassword(req.Password)
	if err != nil {
		return nil, err
	}

	pendudukID64 := int64(req.PendudukID)
	var createdUser models.User
	var createdKader models.Kader
	err = u.repo.DB().Transaction(func(tx *gorm.DB) error {
		createdUser = models.User{
			Username:   strings.TrimSpace(req.Name),
			Email:      email,
			IsActive:   true,
			Password:   hashedPassword,
			RoleID:     role.ID,
			PendudukID: &pendudukID64,
		}
		if err := tx.Create(&createdUser).Error; err != nil {
			return err
		}
		if err := tx.Model(&models.Kependudukan{}).Where("id = ?", req.PendudukID).Update("telepon", normalizedPhone).Error; err != nil {
			return err
		}
		createdKader = models.Kader{
			PendudukID: req.PendudukID,
			PosyanduID: req.PosyanduID,
			Status:     "aktif",
		}
		if err := tx.Create(&createdKader).Error; err != nil {
			return err
		}
		return nil
	})
	if err != nil {
		if strings.Contains(strings.ToLower(err.Error()), "unique") || strings.Contains(strings.ToLower(err.Error()), "duplicate") {
			return nil, customerror.NewConflictError("data kader atau akun pengguna sudah terdaftar")
		}
		return nil, customerror.NewInternalServiceError("gagal membuat akun kader: " + err.Error())
	}
	return &SuperadminUserActionResponse{User: &createdUser, Kader: &createdKader}, nil
}

func (u *SuperadminUserUsecase) CreateUser(req *SuperadminCreateUserRequest) (*models.User, error) {
	if req == nil {
		return nil, customerror.NewBadRequestError("request tidak valid")
	}
	roleName := strings.TrimSpace(req.RoleName)
	if roleName == "" {
		return nil, customerror.NewBadRequestError("role_name wajib diisi")
	}
	if normalizeKey(roleName) == "admin" || normalizeKey(roleName) == "admindesa" || normalizeKey(roleName) == "bidan" || normalizeKey(roleName) == "kader" || normalizeKey(roleName) == "superadmin" {
		return nil, customerror.NewBadRequestError("role admin, bidan, kader, dan superadmin diatur dari halaman kelola akun khusus")
	}

	email, normalizedPhone, err := u.validateBaseUserFields(req.Name, req.Email, req.PhoneNumber, req.Password)
	if err != nil {
		return nil, err
	}

	var pendudukID *int64
	var pendudukDesaID *int32
	if req.PendudukID != nil && *req.PendudukID > 0 {
		penduduk, err := u.repo.Kependudukan.FindByID(int32(*req.PendudukID))
		if err != nil {
			return nil, customerror.NewNotFoundError("penduduk tidak ditemukan")
		}
		// Jika nomor HP tidak diisi di request, ambil dari data penduduk
		if normalizedPhone == "" && penduduk.Telepon != "" {
			normalizedPhone, err = normalizePhoneNumber(penduduk.Telepon)
			if err != nil {
				// Jika normalisasi gagal, tetap lanjutkan (akan ter-handle di bawah)
				normalizedPhone = ""
			}
		}
		// Nomor HP wajib diisi (dari request atau dari penduduk)
		if normalizedPhone == "" {
			return nil, customerror.NewBadRequestError("nomor hp wajib diisi (isi di form atau lengkapi data kependudukan)")
		}
		pendudukDesaID = penduduk.DesaID
		if pendudukDesaID == nil || *pendudukDesaID == 0 {
			return nil, customerror.NewBadRequestError("penduduk belum memiliki desa_id")
		}
		if _, err := u.repo.Desa.GetByID(*pendudukDesaID); err != nil {
			return nil, customerror.NewNotFoundError("desa pada data penduduk tidak ditemukan")
		}
		pendudukID = req.PendudukID
	}
	if err := u.validateDesaConsistency(req.DesaID, pendudukDesaID); err != nil {
		return nil, err
	}

	if _, err := u.repo.User.FindByEmail(email); err == nil {
		return nil, customerror.NewConflictError("email sudah terdaftar")
	} else if !u.isNotFound(err) {
		return nil, customerror.NewInternalServiceError("gagal memvalidasi email")
	}
	if _, err := u.repo.User.FindByPhoneNumber(normalizedPhone); err == nil {
		return nil, customerror.NewConflictError("nomor hp sudah terdaftar")
	} else if !u.isNotFound(err) {
		return nil, customerror.NewInternalServiceError("gagal memvalidasi nomor hp")
	}
	if pendudukID != nil {
		if _, err := u.repo.User.FindByPendudukID(*pendudukID); err == nil {
			return nil, customerror.NewConflictError("penduduk sudah memiliki akun pengguna")
		} else if !u.isNotFound(err) {
			return nil, customerror.NewInternalServiceError("gagal memvalidasi akun pengguna")
		}
		if _, err := u.repo.Bidan.FindByPendudukID(int32(*pendudukID)); err == nil {
			return nil, customerror.NewConflictError("penduduk sudah terdaftar sebagai bidan")
		} else if !u.isNotFound(err) {
			return nil, customerror.NewInternalServiceError("gagal memvalidasi data bidan")
		}
		if _, err := u.repo.Kader.FindByPendudukID(int32(*pendudukID)); err == nil {
			return nil, customerror.NewConflictError("penduduk sudah terdaftar sebagai kader")
		} else if !u.isNotFound(err) {
			return nil, customerror.NewInternalServiceError("gagal memvalidasi data kader")
		}
	}

	role, err := u.repo.Role.FindByName(normalizeRoleName(roleName))
	if err != nil {
		return nil, customerror.NewNotFoundError("role tidak ditemukan")
	}
	hashedPassword, err := u.preparePassword(req.Password)
	if err != nil {
		return nil, err
	}

	var user *models.User
	err = u.repo.DB().Transaction(func(tx *gorm.DB) error {
		user = &models.User{
			Username:   strings.TrimSpace(req.Name),
			Email:      email,
			IsActive:   true,
			Password:   hashedPassword,
			RoleID:     role.ID,
			PendudukID: pendudukID,
		}
		if err := tx.Create(user).Error; err != nil {
			return err
		}
		if pendudukID != nil {
			if err := tx.Model(&models.Kependudukan{}).Where("id = ?", *pendudukID).Update("telepon", normalizedPhone).Error; err != nil {
				return err
			}
		}
		return nil
	})
	if err != nil {
		if strings.Contains(strings.ToLower(err.Error()), "unique") || strings.Contains(strings.ToLower(err.Error()), "duplicate") {
			return nil, customerror.NewConflictError("data user sudah terdaftar")
		}
		return nil, customerror.NewInternalServiceError("gagal membuat akun user")
	}
	return user, nil
}

func (u *SuperadminUserUsecase) ResetPassword(id int32, req *SuperadminResetPasswordRequest) (*models.User, error) {
	if id == 0 {
		return nil, customerror.NewBadRequestError("id user tidak valid")
	}
	if req == nil {
		return nil, customerror.NewBadRequestError("request tidak valid")
	}
	user, err := u.repo.User.FindByID(id)
	if err != nil {
		return nil, customerror.NewNotFoundError("user tidak ditemukan")
	}
	hashedPassword, err := u.preparePassword(req.Password)
	if err != nil {
		return nil, err
	}
	if err := u.repo.User.SetPassword(id, hashedPassword); err != nil {
		return nil, customerror.NewInternalServiceError("gagal memperbarui password")
	}
	user.Password = hashedPassword
	return user, nil
}

func (u *SuperadminUserUsecase) UpdateUserRole(id int32, req *SuperadminUpdateUserRoleRequest) (*models.User, error) {
	if id == 0 {
		return nil, customerror.NewBadRequestError("id user tidak valid")
	}
	if req == nil {
		return nil, customerror.NewBadRequestError("request tidak valid")
	}
	roleName := strings.TrimSpace(req.RoleName)
	if roleName == "" {
		return nil, customerror.NewBadRequestError("role_name wajib diisi")
	}
	normalizedRole := normalizeRoleName(roleName)
	if normalizedRole == "Admin" || normalizedRole == "Bidan" || normalizedRole == "Kader" || normalizedRole == "Superadmin" {
		return nil, customerror.NewBadRequestError("role admin, bidan, kader, dan superadmin diatur dari halaman kelola akun desa")
	}
	user, err := u.repo.User.FindByID(id)
	if err != nil {
		return nil, customerror.NewNotFoundError("user tidak ditemukan")
	}
	if strings.EqualFold(strings.TrimSpace(user.Role.Name), "Superadmin") {
		return nil, customerror.NewBadRequestError("akun superadmin tidak dapat diubah")
	}
	role, err := u.repo.Role.FindByName(normalizedRole)
	if err != nil {
		return nil, customerror.NewNotFoundError("role tidak ditemukan")
	}
	if err := u.repo.DB().Model(&models.User{}).Where("id = ?", id).Updates(map[string]interface{}{
		"role_id":    role.ID,
		"updated_at": gorm.Expr("NOW()"),
	}).Error; err != nil {
		return nil, customerror.NewInternalServiceError("gagal memperbarui role user")
	}
	user.Role = *role
	user.RoleID = role.ID
	return user, nil
}

func (u *SuperadminUserUsecase) DeactivateUser(id int32) (*models.User, error) {
	if id == 0 {
		return nil, customerror.NewBadRequestError("id user tidak valid")
	}
	user, err := u.repo.User.FindByID(id)
	if err != nil {
		return nil, customerror.NewNotFoundError("user tidak ditemukan")
	}
	if strings.EqualFold(strings.TrimSpace(user.Role.Name), "Superadmin") {
		return nil, customerror.NewBadRequestError("akun superadmin tidak dapat dinonaktifkan")
	}
	if err := u.repo.DB().Transaction(func(tx *gorm.DB) error {
		if err := tx.Model(&models.User{}).Where("id = ?", id).Updates(map[string]interface{}{
			"is_active":  false,
			"updated_at": gorm.Expr("NOW()"),
		}).Error; err != nil {
			return err
		}
		switch strings.TrimSpace(user.Role.Name) {
		case "Bidan":
			if user.PendudukID != nil {
				if err := tx.Model(&models.Bidan{}).Where("penduduk_id = ? AND deleted_at IS NULL", *user.PendudukID).Updates(map[string]interface{}{
					"status":     "nonaktif",
					"updated_at": gorm.Expr("NOW()"),
				}).Error; err != nil {
					return err
				}
			}
		case "Kader":
			if user.PendudukID != nil {
				if err := tx.Model(&models.Kader{}).Where("id_penduduk = ? AND deleted_at IS NULL", *user.PendudukID).Updates(map[string]interface{}{
					"status":     "nonaktif",
					"updated_at": gorm.Expr("NOW()"),
				}).Error; err != nil {
					return err
				}
			}
		}
		return nil
	}); err != nil {
		return nil, customerror.NewInternalServiceError("gagal menonaktifkan user")
	}
	user.IsActive = false
	return user, nil
}

func (u *SuperadminUserUsecase) ActivateUser(id int32) (*models.User, error) {
	if id == 0 {
		return nil, customerror.NewBadRequestError("id user tidak valid")
	}
	user, err := u.repo.User.FindByID(id)
	if err != nil {
		return nil, customerror.NewNotFoundError("user tidak ditemukan")
	}
	if strings.EqualFold(strings.TrimSpace(user.Role.Name), "Superadmin") {
		return nil, customerror.NewBadRequestError("akun superadmin tidak dapat diubah statusnya")
	}
	if err := u.repo.DB().Transaction(func(tx *gorm.DB) error {
		if err := tx.Model(&models.User{}).Where("id = ?", id).Updates(map[string]interface{}{
			"is_active":  true,
			"updated_at": gorm.Expr("NOW()"),
		}).Error; err != nil {
			return err
		}
		switch strings.TrimSpace(user.Role.Name) {
		case "Bidan":
			if user.PendudukID != nil {
				if err := tx.Model(&models.Bidan{}).Where("penduduk_id = ? AND deleted_at IS NULL", *user.PendudukID).Updates(map[string]interface{}{
					"status":     "aktif",
					"updated_at": gorm.Expr("NOW()"),
				}).Error; err != nil {
					return err
				}
			}
		case "Kader":
			if user.PendudukID != nil {
				if err := tx.Model(&models.Kader{}).Where("id_penduduk = ? AND deleted_at IS NULL", *user.PendudukID).Updates(map[string]interface{}{
					"status":     "aktif",
					"updated_at": gorm.Expr("NOW()"),
				}).Error; err != nil {
					return err
				}
			}
		}
		return nil
	}); err != nil {
		return nil, customerror.NewInternalServiceError("gagal mengaktifkan user")
	}
	user.IsActive = true
	return user, nil
}

// file: usecase/superadmin_user_usecase.go

// CreateIbuUser - Membuat akun dengan role IBU (khusus untuk Ibu)
func (u *SuperadminUserUsecase) CreateIbuUser(req *SuperadminCreateUserRequest) (*models.User, error) {
	if req == nil {
		return nil, customerror.NewBadRequestError("request tidak valid")
	}
	
	// Force role menjadi IBU (abaikan apapun yang dikirim dari request)
	req.RoleName = "Ibu"
	
	// Validasi: Penduduk ID wajib untuk akun Ibu
	if req.PendudukID == nil || *req.PendudukID == 0 {
		return nil, customerror.NewBadRequestError("penduduk_id wajib diisi untuk akun Ibu")
	}
	
	// Validasi nama
	if strings.TrimSpace(req.Name) == "" {
		return nil, customerror.NewBadRequestError("nama wajib diisi")
	}
	
	// Validasi email
	if strings.TrimSpace(req.Email) == "" {
		return nil, customerror.NewBadRequestError("email wajib diisi")
	}
	
	// Validasi password
	if req.Password == "" || len(req.Password) < 6 {
		return nil, customerror.NewBadRequestError("password wajib diisi minimal 6 karakter")
	}
	
	// Normalisasi email dan phone
	email := strings.ToLower(strings.TrimSpace(req.Email))
	var normalizedPhone string
	var err error
	if req.PhoneNumber != "" {
		normalizedPhone, err = normalizePhoneNumber(req.PhoneNumber)
		if err != nil {
			// Jika format tidak valid dari request, set kosong (akan coba ambil dari penduduk)
			normalizedPhone = ""
		}
	}
	
	// Cek apakah penduduk valid
	penduduk, err := u.repo.Kependudukan.FindByID(int32(*req.PendudukID))
	if err != nil {
		return nil, customerror.NewNotFoundError("penduduk tidak ditemukan")
	}
	
	// Jika nomor telepon dari request kosong, ambil dari data penduduk
	if normalizedPhone == "" && penduduk.Telepon != "" {
		normalizedPhone, err = normalizePhoneNumber(penduduk.Telepon)
		if err != nil {
			// Jika normalisasi gagal, tetap lanjutkan (akan ter-handle di bawah)
			normalizedPhone = ""
		}
	}
	
	// Validasi nomor telepon (wajib untuk akun Ibu)
	if normalizedPhone == "" {
		return nil, customerror.NewBadRequestError("nomor hp wajib diisi (isi di form atau lengkapi data kependudukan)")
	}
	
	// Cek desa penduduk
	pendudukDesaID := penduduk.DesaID
	if pendudukDesaID == nil || *pendudukDesaID == 0 {
		return nil, customerror.NewBadRequestError("penduduk belum memiliki desa_id")
	}
	
	if _, err := u.repo.Desa.GetByID(*pendudukDesaID); err != nil {
		return nil, customerror.NewNotFoundError("desa pada data penduduk tidak ditemukan")
	}
	
	// Validasi desa consistency (jika ada desa_id di request)
	if req.DesaID != nil && *req.DesaID != 0 {
		if *req.DesaID != *pendudukDesaID {
			return nil, customerror.NewBadRequestError("desa_id tidak sesuai dengan data penduduk")
		}
	}
	
	// Validasi email sudah terdaftar
	if _, err := u.repo.User.FindByEmail(email); err == nil {
		return nil, customerror.NewConflictError("email sudah terdaftar")
	} else if !u.isNotFound(err) {
		return nil, customerror.NewInternalServiceError("gagal memvalidasi email")
	}
	
	// Validasi nomor hp sudah terdaftar
	if _, err := u.repo.User.FindByPhoneNumber(normalizedPhone); err == nil {
		return nil, customerror.NewConflictError("nomor hp sudah terdaftar")
	} else if !u.isNotFound(err) {
		return nil, customerror.NewInternalServiceError("gagal memvalidasi nomor hp")
	}
	
	// Validasi penduduk sudah memiliki akun
	if _, err := u.repo.User.FindByPendudukID(*req.PendudukID); err == nil {
		return nil, customerror.NewConflictError("penduduk sudah memiliki akun pengguna")
	} else if !u.isNotFound(err) {
		return nil, customerror.NewInternalServiceError("gagal memvalidasi akun pengguna")
	}
	
	// Cari role IBU
	role, err := u.repo.Role.FindByName("Ibu")
	if err != nil {
		return nil, customerror.NewNotFoundError("role IBU tidak ditemukan. Silakan tambahkan role IBU terlebih dahulu ke database.")
	}
	
	// Hash password
	hashedPassword, err := u.preparePassword(req.Password)
	if err != nil {
		return nil, err
	}
	
	var user *models.User
	
	// Simpan ke database dengan transaction
	err = u.repo.DB().Transaction(func(tx *gorm.DB) error {
		user = &models.User{
			Username:   strings.TrimSpace(req.Name),
			Email:      email,
			IsActive:   true,
			Password:   hashedPassword,
			RoleID:     role.ID,
			PendudukID: req.PendudukID,
		}
		
		if err := tx.Create(user).Error; err != nil {
			return err
		}
		
		// Update nomor telepon penduduk jika berbeda
		if penduduk.Telepon != normalizedPhone {
			if err := tx.Model(&models.Kependudukan{}).Where("id = ?", *req.PendudukID).Update("telepon", normalizedPhone).Error; err != nil {
				return err
			}
		}
		
		return nil
	})
	
	if err != nil {
		if strings.Contains(strings.ToLower(err.Error()), "unique") || strings.Contains(strings.ToLower(err.Error()), "duplicate") {
			return nil, customerror.NewConflictError("data user sudah terdaftar")
		}
		return nil, customerror.NewInternalServiceError("gagal membuat akun ibu: " + err.Error())
	}
	
	return user, nil
}