package controllers

import (
	"net/http"
	"strconv"

	"monitoring-service/app/constants"
	"monitoring-service/app/helpers"

	"github.com/labstack/echo/v4"
)

func (m *Main) GetJadwalImunisasiByAnakIDBidan(c echo.Context) error {

	anakIDParam := c.Param("anak_id")
	anakID, err := strconv.Atoi(anakIDParam)
	if err != nil || anakID <= 0 {
		return helpers.Response(c, http.StatusBadRequest, []string{"anak_id tidak valid"})
	}

	data, err := m.usecases.GetJadwalImunisasiByAnakIDBidan(int32(anakID))
	if err != nil {
		return helpers.Response(c, http.StatusInternalServerError, []string{err.Error()})
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}

func (m *Main) SetJadwalSelesaiBidan(c echo.Context) error {

	jadwalID, err := strconv.Atoi(c.Param("id"))
	if err != nil || jadwalID <= 0 {
		return helpers.Response(c, http.StatusBadRequest, []string{"id tidak valid"})
	}

	err = m.usecases.SetJadwalSelesaiBidan(uint(jadwalID))
	if err != nil {
		return helpers.Response(c, http.StatusInternalServerError, []string{err.Error()})
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{"jadwal berhasil diselesaikan"}, nil, nil)
}

func (m *Main) GetJadwalImunisasiByIDBidan(c echo.Context) error {

	jadwalID, err := strconv.Atoi(c.Param("id"))
	if err != nil || jadwalID <= 0 {
		return helpers.Response(c, http.StatusBadRequest, []string{"id tidak valid"})
	}

	data, err := m.usecases.GetJadwalImunisasiByJadwalIDBidan(uint(jadwalID))
	if err != nil {
		return helpers.Response(c, http.StatusInternalServerError, []string{err.Error()})
	}

	if data == nil {
		return helpers.Response(c, http.StatusNotFound, []string{"data tidak ditemukan"})
	}

	return helpers.StandardResponse(c, http.StatusOK, []string{constants.SUCCESS_RESPONSE_MESSAGE}, data, nil)
}
