package models

import "github.com/golang-jwt/jwt/v5"

type RegisterRequest struct {
	Name        string `json:"name"`
	Email       string `json:"email"`
	PhoneNumber string `json:"phone_number"`
	Password    string `json:"password"`
	RoleName    string `json:"role_name"`
	PendudukID  *int64 `json:"penduduk_id"`
}

type LoginRequest struct {
	Identifier string `json:"identifier"`
	Email      string `json:"email,omitempty"`
	Password   string `json:"password"`
	FcmToken   string `json:"fcm_token"`
}


type LoginResponse struct {
	AccessToken   string `json:"access_token"`
	TokenType     string `json:"token_type"`
	ExpiresIn     int64  `json:"expires_in"`
	UserID        int32  `json:"user_id"`
	Name          string `json:"name"`
	Email         string `json:"email"`
	PhoneNumber   string `json:"phone_number"`
	Role          string `json:"role"`
	TargetApp     string `json:"target_app"`
	RedirectRoute string `json:"redirect_route"`
	DesaID        *int32 `json:"desa_id,omitempty"`   // <-- tambah
    DesaNama      string `json:"desa_nama,omitempty"`
}

type MeResponse struct {
	UserID        int32  `json:"user_id"`
	Email         string `json:"email"`
	PhoneNumber   string `json:"phone_number"`
	Role          string `json:"role"`
	TargetApp     string `json:"target_app"`
	RedirectRoute string `json:"redirect_route"`
}

type AuthClaims struct {
	UserID        int32  `json:"user_id"`
	Email         string `json:"email"`
	PhoneNumber   string `json:"phone_number"`
	Role          string `json:"role"`
	TargetApp     string `json:"target_app"`
	RedirectRoute string `json:"redirect_route"`
	 DesaID        *int32 `json:"desa_id,omitempty"` // tambahkan
	jwt.RegisteredClaims
}
