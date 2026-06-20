	package models

	import "time"

	type Kependudukan struct {
		IDKependudukan     int32      `gorm:"primaryKey;column:id;autoIncrement" json:"id"`
		RW                  string  `gorm:"column:rw;type:varchar(10)" json:"rw"`
		RT                  string  `gorm:"column:rt;type:varchar(10)" json:"rt"`
		Dusun               string  `gorm:"column:dusun;type:varchar(100)" json:"dusun"`
		Alamat              string  `gorm:"column:alamat;type:text" json:"alamat"`
		KodeKeluarga        string  `gorm:"column:kode_keluarga;type:varchar(50);index:idx_kode_keluarga" json:"kode_keluarga"`
		NamaKepalaKeluarga  string  `gorm:"column:nama_kepala_keluarga;type:varchar(255)" json:"nama_kepala_keluarga"`
		NIK                *string    `gorm:"column:nik;type:varchar(30);uniqueIndex" json:"nik,omitempty"`
		NamaAnggotaKeluarga string 	  `gorm:"column:nama_anggota_keluarga;type:varchar(255)" json:"nama_anggota_keluarga"`
		JenisKelamin       string     `gorm:"column:jenis_kelamin;type:text" json:"jenis_kelamin"`
		Hubungan            string  `gorm:"column:hubungan;type:varchar(50);index:idx_hubungan" json:"hubungan"`
		TempatLahir        string     `gorm:"column:tempat_lahir;type:text" json:"tempat_lahir"`
		TanggalLahir       time.Time  `gorm:"column:tanggal_lahir" json:"tanggal_lahir"`
		Status              string `gorm:"column:status;type:varchar(50)" json:"status"`
		Agama              string     `gorm:"column:agama;type:text" json:"agama"`
		GolonganDarah      string     `gorm:"column:golongan_darah;type:text" json:"golongan_darah"`
		Kewarganegaraan     string `gorm:"column:kewarganegaraan;type:varchar(20);default:'WNI'" json:"kewarganegaraan"`
		EtnisSuku           string `gorm:"column:etnis_suku;type:varchar(100)" json:"etnis_suku"`
		Pendidikan          string `gorm:"column:pendidikan;type:varchar(100)" json:"pendidikan"`
		Pekerjaan           string `gorm:"column:pekerjaan;type:varchar(100)" json:"pekerjaan"`
		Telepon   string `gorm:"column:telepon;type:varchar(20)" json:"telepon,omitempty"`		
		DesaID             *int32     `gorm:"column:desa_id" json:"desa_id,omitempty"`
		PosyanduID *int32 `gorm:"column:posyandu_id;index" json:"posyandu_id,omitempty"`
		Desa               *Desa      `gorm:"foreignKey:DesaID;references:ID" json:"desa,omitempty"`
		Posyandu      *Posyandu      `gorm:"foreignKey:PosyanduID;references:ID" json:"posyandu,omitempty"`
		CreatedAt          time.Time  `gorm:"column:created_at" json:"created_at"`
		UpdatedAt          time.Time  `gorm:"column:updated_at" json:"updated_at"`
		DeletedAt          *time.Time `gorm:"column:deleted_at" json:"deleted_at,omitempty"`
	}

	func (Kependudukan) TableName() string { return "penduduk" }
