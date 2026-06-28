package repositories

// ImunisasiSyncData adalah payload flat yang dikembalikan ke Flutter untuk
// disimpan ke SQLite lokal (offline-first imunisasi ibu).
type ImunisasiSyncData struct {
	Ibu                      []map[string]interface{} `json:"ibu"`
	Penduduk                 []map[string]interface{} `json:"penduduk"`
	Kehamilan                []map[string]interface{} `json:"kehamilan"`
	Anak                     []map[string]interface{} `json:"anak"`
	Posyandu                 []map[string]interface{} `json:"posyandu"`
	JadwalImunisasiAnak      []map[string]interface{} `json:"jadwal_imunisasi_anak"`
	RequestPerubahanImunisasi []map[string]interface{} `json:"request_perubahan_imunisasi"`
	StatusJadwal             []map[string]interface{} `json:"status_jadwal"`
	StatusRequest            []map[string]interface{} `json:"status_request"`
	Vaksin                   []map[string]interface{} `json:"vaksin"`
	DosisVaksin              []map[string]interface{} `json:"dosis_vaksin"`
}

func (r *Main) GetImunisasiSyncData(userID int32) (*ImunisasiSyncData, error) {
	result := &ImunisasiSyncData{}

	// 1. Ambil ibu_id dari pengguna
	var ibuID uint
	if err := r.postgres.Table("ibu i").
		Select("i.id").
		Joins("JOIN penduduk p ON p.id = i.penduduk_id").
		Joins("JOIN pengguna u ON u.penduduk_id = p.id").
		Where("u.id = ?", userID).
		Where("i.is_deleted IS NULL").
		Scan(&ibuID).Error; err != nil || ibuID == 0 {
		return result, err
	}

	// 2. Ibu
	result.Ibu = r.queryRows(`
		SELECT id, penduduk_id, suami_id, gravida, paritas, abortus,
		       created_at, updated_at
		FROM ibu WHERE id = ? AND is_deleted IS NULL`, ibuID)

	// 3. Kehamilan ibu ini
	kehamilanIDs := r.collectIDs("kehamilan", "id", "ibu_id = ?", ibuID)

	result.Kehamilan = r.queryRows(`
		SELECT id, ibu_id, gravida, paritas, abortus, hpht,
		       taksiran_persalinan, uk_kehamilan_saat_ini, status_kehamilan,
		       bb_awal, tb, imt_awal, created_at, updated_at, deleted_at
		FROM kehamilan WHERE ibu_id = ? AND deleted_at IS NULL`, ibuID)

	// 4. Anak dari kehamilan tersebut
	anakIDs := []uint{}
	if len(kehamilanIDs) > 0 {
		anakIDs = r.collectIDsIn("anak", "id", "kehamilan_id", kehamilanIDs)
		result.Anak = r.queryRowsIn(`
			SELECT id, kehamilan_id, penduduk_id, berat_lahir_kg, tinggi_lahir_cm,
			       anak_ke, lingkar_kepala_cm, nama_ibu, nama_ayah,
			       created_at, updated_at, deleted_at
			FROM anak WHERE kehamilan_id`, kehamilanIDs)
	}

	// 5. Penduduk: ibu sendiri + suami + semua anak
	pendudukIDs := r.collectPendudukIDs(userID, ibuID, anakIDs)
	if len(pendudukIDs) > 0 {
		result.Penduduk = r.queryRowsIn(`
			SELECT id, rw, rt, dusun, alamat, nik,
			       nama_anggota_keluarga, jenis_kelamin, tempat_lahir, tanggal_lahir,
			       telepon, desa_id, posyandu_id, created_at, updated_at, deleted_at
			FROM penduduk WHERE id`, pendudukIDs)
	}

	// 6. Posyandu penduduk ibu
	result.Posyandu = r.queryRows(`
		SELECT pos.id, pos.id_puskesmas, pos.nama, pos.alamat,
		       pos.created_at, pos.updated_at, pos.deleted_at
		FROM posyandu pos
		JOIN penduduk p ON p.posyandu_id = pos.id
		JOIN ibu i ON i.penduduk_id = p.id
		WHERE i.id = ? AND pos.deleted_at IS NULL
		LIMIT 1`, ibuID)

	// 7. Jadwal imunisasi anak
	if len(anakIDs) > 0 {
		jadwalIDs := r.collectIDsIn("jadwal_imunisasi_anak", "id", "id_anak", anakIDs)
		result.JadwalImunisasiAnak = r.queryRowsIn(`
			SELECT id, id_dosis_vaksin, id_anak, id_status_jadwal,
			       tanggal_estimasi, created_at, updated_at, deleted_at
			FROM jadwal_imunisasi_anak WHERE id`, jadwalIDs)

		// 8. Request perubahan untuk jadwal tsb
		if len(jadwalIDs) > 0 {
			result.RequestPerubahanImunisasi = r.queryRowsIn(`
				SELECT id, id_jadwal_imunisasi, id_status_request,
				       alasan, tanggal_sebelum, tanggal_baru,
				       created_at, updated_at, deleted_at
				FROM request_perubahan_imunisasi WHERE id_jadwal_imunisasi`, jadwalIDs)
		}
	}

	// 9. Master data (semua, bukan scoped ke user)
	result.StatusJadwal = r.queryRows(
		`SELECT id, nama_status, created_at, updated_at, deleted_at FROM status_jadwal WHERE deleted_at IS NULL`)
	result.StatusRequest = r.queryRows(
		`SELECT id, status_request, created_at, updated_at, deleted_at FROM status_request WHERE deleted_at IS NULL`)
	result.Vaksin = r.queryRows(
		`SELECT id, nama, deskripsi, efek_samping, created_at, updated_at, deleted_at FROM vaksin WHERE deleted_at IS NULL`)
	result.DosisVaksin = r.queryRows(
		`SELECT id, id_vaksin, nama_dosis, jumlah_dosis, created_at, updated_at, deleted_at FROM dosis_vaksin WHERE deleted_at IS NULL`)

	return result, nil
}

// ── helpers ──────────────────────────────────────────────────────────────────

func (r *Main) queryRows(query string, args ...interface{}) []map[string]interface{} {
	rows, err := r.postgres.Raw(query, args...).Rows()
	if err != nil || rows == nil {
		return []map[string]interface{}{}
	}
	defer rows.Close()

	cols, _ := rows.Columns()
	var result []map[string]interface{}
	for rows.Next() {
		vals := make([]interface{}, len(cols))
		ptrs := make([]interface{}, len(cols))
		for i := range vals {
			ptrs[i] = &vals[i]
		}
		if err := rows.Scan(ptrs...); err != nil {
			continue
		}
		row := map[string]interface{}{}
		for i, col := range cols {
			row[col] = vals[i]
		}
		result = append(result, row)
	}
	if result == nil {
		return []map[string]interface{}{}
	}
	return result
}

func (r *Main) queryRowsIn(baseQuery string, ids []uint) []map[string]interface{} {
	if len(ids) == 0 {
		return []map[string]interface{}{}
	}
	var rows []map[string]interface{}
	r.postgres.Raw(baseQuery+" IN ?", ids).Scan(&rows)
	if rows == nil {
		return []map[string]interface{}{}
	}
	return rows
}

func (r *Main) collectIDs(table, col, where string, arg interface{}) []uint {
	type row struct{ ID uint }
	var rows []row
	r.postgres.Raw("SELECT "+col+" AS id FROM "+table+" WHERE "+where, arg).Scan(&rows)
	ids := make([]uint, 0, len(rows))
	for _, r := range rows {
		ids = append(ids, r.ID)
	}
	return ids
}

func (r *Main) collectIDsIn(table, col, fkCol string, ids []uint) []uint {
	if len(ids) == 0 {
		return nil
	}
	type row struct{ ID uint }
	var rows []row
	r.postgres.Raw("SELECT "+col+" AS id FROM "+table+" WHERE "+fkCol+" IN ?", ids).Scan(&rows)
	result := make([]uint, 0, len(rows))
	for _, r := range rows {
		result = append(result, r.ID)
	}
	return result
}

func (r *Main) collectPendudukIDs(userID int32, ibuID uint, anakIDs []uint) []uint {
	ids := map[uint]struct{}{}

	// penduduk ibu
	var ibuPendudukID, suamiID uint
	r.postgres.Raw(`SELECT i.penduduk_id, COALESCE(i.suami_id,0) FROM ibu i WHERE i.id = ?`, ibuID).
		Row().Scan(&ibuPendudukID, &suamiID)
	if ibuPendudukID > 0 {
		ids[ibuPendudukID] = struct{}{}
	}
	if suamiID > 0 {
		ids[suamiID] = struct{}{}
	}

	// penduduk anak
	if len(anakIDs) > 0 {
		type row struct{ PendudukID uint }
		var rows []row
		r.postgres.Raw("SELECT penduduk_id FROM anak WHERE id IN ?", anakIDs).Scan(&rows)
		for _, r := range rows {
			if r.PendudukID > 0 {
				ids[r.PendudukID] = struct{}{}
			}
		}
	}

	result := make([]uint, 0, len(ids))
	for id := range ids {
		result = append(result, id)
	}
	return result
}

