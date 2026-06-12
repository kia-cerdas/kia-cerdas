package controllers

import (
	"monitoring-service/app/constants"
	"monitoring-service/app/helpers"
	"monitoring-service/app/models"
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"
)

func (m *Main) GetAllRequestPerubahanJadwal(
	c echo.Context,
) error {

	data, err :=
		m.usecases.
			GetAllRequestPerubahanJadwal()

	if err != nil {

		return helpers.Response(
			c,
			http.StatusInternalServerError,
			[]string{
				err.Error(),
			},
		)
	}

	return helpers.StandardResponse(
		c,
		http.StatusOK,
		[]string{
			constants.SUCCESS_RESPONSE_MESSAGE,
		},
		data,
		nil,
	)
}

func (m *Main) RequestPerubahanJadwal(
	c echo.Context,
) error {

	jadwalID, err :=
		strconv.Atoi(
			c.Param("id"),
		)

	if err != nil {

		return helpers.Response(
			c,
			400,
			[]string{"id tidak valid"},
		)
	}

	var req models.RequestPerubahanJadwalRequest

	if err := c.Bind(&req); err != nil {

		return helpers.Response(
			c,
			400,
			[]string{"request tidak valid"},
		)
	}

	claims :=
		c.Get("auth_claims").(*models.AuthClaims)

	err =
		m.usecases.
			RequestPerubahanJadwal(
				claims.UserID,
				uint(jadwalID),
				req.TanggalBaru,
				req.Alasan,
			)

	if err != nil {

		return helpers.Response(
			c,
			500,
			[]string{err.Error()},
		)
	}

	return helpers.StandardResponse(
		c,
		200,
		[]string{"request berhasil dibuat"},
		nil,
		nil,
	)
}

func (m *Main) ApproveRequestPerubahanJadwal(
	c echo.Context,
) error {

	requestID, err :=
		strconv.Atoi(
			c.Param("id"),
		)

	if err != nil {

		return helpers.Response(
			c,
			http.StatusBadRequest,
			[]string{
				"id request tidak valid",
			},
		)
	}

	err =
		m.usecases.
			ApproveRequestPerubahanJadwal(
				int32(requestID),
			)

	if err != nil {

		return helpers.Response(
			c,
			http.StatusInternalServerError,
			[]string{
				err.Error(),
			},
		)
	}

	return helpers.StandardResponse(
		c,
		http.StatusOK,
		[]string{
			"request berhasil disetujui",
		},
		nil,
		nil,
	)
}

func (m *Main) RejectRequestPerubahanJadwal(
	c echo.Context,
) error {

	requestID, err :=
		strconv.Atoi(
			c.Param("id"),
		)

	if err != nil {

		return helpers.Response(
			c,
			http.StatusBadRequest,
			[]string{
				"id request tidak valid",
			},
		)
	}

	err =
		m.usecases.
			RejectRequestPerubahanJadwal(
				int32(requestID),
			)

	if err != nil {

		return helpers.Response(
			c,
			http.StatusInternalServerError,
			[]string{
				err.Error(),
			},
		)
	}

	return helpers.StandardResponse(
		c,
		http.StatusOK,
		[]string{
			"request berhasil ditolak",
		},
		nil,
		nil,
	)
}
