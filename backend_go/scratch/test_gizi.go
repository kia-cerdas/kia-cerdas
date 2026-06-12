package main

// import (
// 	"encoding/json"
// 	"fmt"
// 	"log"
// 	"time"

// 	"gorm.io/datatypes"
// 	"gorm.io/driver/postgres"
// 	"gorm.io/gorm"
// )

// type KunjunganGizi struct {
// 	ID                 int32          `gorm:"primaryKey;autoIncrement"`
// 	AnakID             int32          `gorm:"not null;index"`
// 	Bulanke            int            `gorm:"not null;column:bulanke"`
// 	Tanggal            time.Time      `gorm:"not null"`
// 	TenagaKesehatanID  int32          `gorm:"not null;index"`
// 	Lokasi             string         `gorm:"not null"`
// 	ASI                *ASI           `gorm:"foreignKey:KunjunganGiziID;constraint:OnDelete:CASCADE"`
// 	MPASI              *MPASI         `gorm:"foreignKey:KunjunganGiziID;constraint:OnDelete:CASCADE"`
// 	ObatCacing         *bool          `gorm:"column:obat_cacing;type:bool"`
// 	JenisPemberianSusu string         `gorm:"column:jenis_pemberian_susu;type:varchar(30)"`
// 	MasihMenyusui      *bool          `gorm:"column:masih_menyusui;type:bool"`
// 	MenggunakanFormula *bool          `gorm:"column:menggunakan_formula;type:bool"`
// 	AlasanFormula      string         `gorm:"column:alasan_formula;type:text"`
// 	UsiaMulaiMpasi     *int           `gorm:"column:usia_mulai_mpasi;type:integer"`
// 	CreatedAt          time.Time
// 	UpdatedAt          time.Time
// }

// func (KunjunganGizi) TableName() string {
// 	return "kunjungan_gizi"
// }

// type ASI struct {
// 	ID                int32          `gorm:"primaryKey;autoIncrement"`
// 	KunjunganGiziID   int32          `gorm:"uniqueIndex;not null;index"`
// 	FrekuensiMenyusui int32          `gorm:"not null"`
// 	PosisiMenyusui    string
// 	ASIPerah          string         `gorm:"column:asi_perah;not null"`
// 	CreatedAt         time.Time
// 	UpdatedAt         time.Time
// }

// func (ASI) TableName() string {
// 	return "Pelayanan_Asi"
// }

// type MPASI struct {
// 	ID                  int32          `gorm:"primaryKey;autoIncrement"`
// 	KunjunganGiziID     int32          `gorm:"uniqueIndex;not null;index"`
// 	DiberikanMPASI      bool           `gorm:"column:diberikan_mp_asi;type:bool;not null"`
// 	VariasiMPASI        datatypes.JSON `gorm:"column:variasi_mpasi"`
// 	JumlahmakanPerporsi string         `gorm:"column:jumlahmakan_perporsi"`
// 	FrekuensiMakan      string         `gorm:"column:frekuensi_makan"`
// 	CreatedAt           time.Time
// 	UpdatedAt           time.Time
// }

// func (MPASI) TableName() string {
// 	return "mp_asi"
// }

// func main() {
// 	dsn := "postgresql://postgres.vnwpsqadeavtsesrvuii:L*j9BcYkRXE4rq@@aws-1-ap-south-1.pooler.supabase.com:6543/postgres"
// 	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
// 	if err != nil {
// 		log.Fatalf("Failed to connect database: %v", err)
// 	}
// 	fmt.Println("Connected to database!")

// 	now := time.Now()
// 	t := true
// 	variasiJSON, _ := json.Marshal([]string{"nasi"})

// 	kunj := KunjunganGizi{
// 		AnakID:             1,
// 		Bulanke:            1,
// 		TenagaKesehatanID:  1,
// 		Tanggal:            now,
// 		Lokasi:             "Puskesmas",
// 		MasihMenyusui:      &t,
// 		CreatedAt:          now,
// 		UpdatedAt:          now,
// 		ASI: &ASI{
// 			FrekuensiMenyusui: 8,
// 			PosisiMenyusui:    "baik",
// 			ASIPerah:          "tidak",
// 			CreatedAt:         now,
// 			UpdatedAt:         now,
// 		},
// 		MPASI: &MPASI{
// 			DiberikanMPASI:      true,
// 			VariasiMPASI:        datatypes.JSON(variasiJSON),
// 			JumlahmakanPerporsi: "1 mangkuk",
// 			FrekuensiMakan:      "3x",
// 			CreatedAt:           now,
// 			UpdatedAt:           now,
// 		},
// 	}

// 	tx := db.Begin()
// 	err = tx.Create(&kunj).Error
// 	if err != nil {
// 		fmt.Printf("DB CREATE ERROR: %v\n", err)
// 		tx.Rollback()
// 	} else {
// 		fmt.Printf("DB CREATE SUCCESS! ID: %d\n", kunj.ID)
// 		tx.Commit()
// 		// Clean up
// 		db.Delete(&kunj)
// 	}
// }
