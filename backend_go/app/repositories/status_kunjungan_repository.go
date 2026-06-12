package repositories

type StatusKunjunganCountJoin struct {
	StatusID        uint
	StatusKunjungan string
	JumlahKunjungan int64
}


func (m *Main) GetJumlahKunjunganByStatus() (
	[]StatusKunjunganCountJoin,
	error,
) {

	var result []StatusKunjunganCountJoin

	err := m.postgres.
		Table("status_kunjungan sk").
		Select(`
			sk.id AS status_id,
			sk.status_kunjungan,
			COUNT(ki.id) AS jumlah_kunjungan
		`).
		Joins(`
			LEFT JOIN kunjungan_imunisasi ki
			ON ki.id_status_kunjungan = sk.id
		`).
		Group(`
			sk.id,
			sk.status_kunjungan
		`).
		Order("sk.id ASC").
		Scan(&result).Error

	if err != nil {
		return nil, err
	}

	return result, nil
}