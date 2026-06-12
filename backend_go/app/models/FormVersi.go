	package models

	import "time"

	type FormVersi struct {
		ID         uint   `gorm:"primaryKey"`
		Kelompok   string `gorm:"type:varchar(20);not null;index"` // anak, remaja, dewasa, lansia
		Tahun      int    `gorm:"not null"`
		Nama       string `gorm:"size:100"`
		Aktif      bool   `gorm:"default:false;index"` // hanya satu true per kelompok
		Keterangan string
		CreatedAt  time.Time
		Pertanyaan   []FormPertanyaan  `gorm:"foreignKey:FormVersiID;references:ID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	AturanRisiko []FormAturanRisiko `gorm:"foreignKey:FormVersiID;references:ID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	}

	type FormVersionResponse struct {
		ID         uint   `json:"id"`
		Kelompok   string `json:"kelompok"`
		Tahun      int    `json:"tahun"`
		Nama       string `json:"nama"`
		Aktif      bool   `json:"aktif"`
		Keterangan string `json:"keterangan"`
	}	