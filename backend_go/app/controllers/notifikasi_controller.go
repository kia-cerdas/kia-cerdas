package controllers

import (
	"monitoring-service/app/helpers"
	"monitoring-service/app/models"
	"net/http"

	"github.com/labstack/echo/v4"
)

func (c *Main) RunReminder(ctx echo.Context) error {

	err := c.usecases.ProcessReminder()
	if err != nil {
		return ctx.JSON(500, map[string]string{
			"message": err.Error(),
		})
	}

	return ctx.JSON(200, map[string]string{
		"message": "reminder executed",
	})
}
func (m *Main) TestFCM(
	c echo.Context,
) error {

	claimsValue :=
		c.Get("auth_claims")

	claims, ok :=
		claimsValue.(*models.AuthClaims)

	if !ok {

		return helpers.Response(
			c,
			http.StatusUnauthorized,
			[]string{
				"user tidak valid",
			},
		)
	}

	err :=
		m.usecases.
			SendTestFCM(
				uint(claims.UserID),
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
			"Notifikasi test berhasil dikirim",
		},
		nil,
		nil,
	)
}

func (m *Main) TestReminder(c echo.Context) error {

	err := m.usecases.ProcessReminder()
	if err != nil {
		return helpers.Response(
			c,
			http.StatusInternalServerError,
			[]string{err.Error()},
		)
	}

	return helpers.StandardResponse(
		c,
		http.StatusOK,
		[]string{"Reminder test dijalankan"},
		nil,
		nil,
	)
}

func (m *Main) TestPosyanduReminder(c echo.Context) error {
	err := m.usecases.ProcessPosyanduReminder()
	if err != nil {
		return helpers.Response(
			c,
			http.StatusInternalServerError,
			[]string{err.Error()},
		)
	}
	return helpers.StandardResponse(
		c,
		http.StatusOK,
		[]string{"Posyandu reminder test dijalankan"},
		nil,
		nil,
	)
}

// Reminder kontrol debug :
func (m *Main) TestKontrolReminder(c echo.Context) error {
	err := m.usecases.ProcessKontrolReminder()
	if err != nil {
		return helpers.Response(
			c,
			http.StatusInternalServerError,
			[]string{err.Error()},
		)
	}
	return helpers.StandardResponse(
		c,
		http.StatusOK,
		[]string{"Kontrol reminder test dijalankan"},
		nil,
		nil,
	)
}
