package controllers

import (
    "net/http"
    "strconv"
    "monitoring-service/app/models"
    "monitoring-service/app/usecases"
    "github.com/labstack/echo/v4"
)

type FormController struct {
    formUsecase usecases.FormUsecase
}

func NewFormController(fu usecases.FormUsecase) *FormController {
    return &FormController{formUsecase: fu}
}

// CreateFormVersion godoc
// @Summary      Create new form version
// @Tags         Admin Form
// @Accept       json
// @Produce      json
// @Param        request body models.CreateFormVersionRequest true "Request body"
// @Success      201 {object} models.FormVersionResponse
// @Router       /api/admin/form-versi [post]
func (c *FormController) CreateFormVersion(ctx echo.Context) error {
    var req models.CreateFormVersionRequest
    if err := ctx.Bind(&req); err != nil {
        return ctx.JSON(http.StatusBadRequest, map[string]string{"error": err.Error()})
    }
    resp, err := c.formUsecase.CreateFormVersion(ctx.Request().Context(), &req)
    if err != nil {
        return ctx.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
    }
    return ctx.JSON(http.StatusCreated, resp)
}

// ActivateFormVersion godoc
// @Summary      Activate a form version (deactivates others in same kelompok)
// @Tags         Admin Form
// @Param        id path int true "Form Version ID"
// @Success      200 {object} map[string]string
// @Router       /api/admin/form-versi/{id}/activate [post]
func (c *FormController) ActivateFormVersion(ctx echo.Context) error {
    id, err := strconv.ParseUint(ctx.Param("id"), 10, 32)
    if err != nil {
        return ctx.JSON(http.StatusBadRequest, map[string]string{"error": "invalid id"})
    }
    if err := c.formUsecase.ActivateFormVersion(ctx.Request().Context(), uint(id)); err != nil {
        return ctx.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
    }
    return ctx.JSON(http.StatusOK, map[string]string{"message": "version activated"})
}

// DeactivateFormVersion godoc
// @Summary      Deactivate a form version
// @Tags         Admin Form
// @Param        id path int true "Form Version ID"
// @Success      200 {object} map[string]string
// @Router       /api/admin/form-versi/{id}/deactivate [post]
func (c *FormController) DeactivateFormVersion(ctx echo.Context) error {
    id, err := strconv.ParseUint(ctx.Param("id"), 10, 32)
    if err != nil {
        return ctx.JSON(http.StatusBadRequest, map[string]string{"error": "invalid id"})
    }
    if err := c.formUsecase.DeactivateFormVersion(ctx.Request().Context(), uint(id)); err != nil {
        return ctx.JSON(http.StatusBadRequest, map[string]string{"error": err.Error()})
    }
    return ctx.JSON(http.StatusOK, map[string]string{"message": "version deactivated"})
}

// DuplicateFormVersion godoc
// @Summary      Duplicate a form version to a new year
// @Tags         Admin Form
// @Param        id path int true "Source Form Version ID"
// @Param        request body models.DuplicateFormVersionRequest true "Request body"
// @Success      201 {object} models.FormVersionResponse
// @Router       /api/admin/form-versi/{id}/duplicate [post]
func (c *FormController) DuplicateFormVersion(ctx echo.Context) error {
    id, err := strconv.ParseUint(ctx.Param("id"), 10, 32)
    if err != nil {
        return ctx.JSON(http.StatusBadRequest, map[string]string{"error": "invalid id"})
    }
    var req models.DuplicateFormVersionRequest
    if err := ctx.Bind(&req); err != nil {
        return ctx.JSON(http.StatusBadRequest, map[string]string{"error": err.Error()})
    }
    resp, err := c.formUsecase.DuplicateFormVersion(ctx.Request().Context(), uint(id), &req)
    if err != nil {
        return ctx.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
    }
    return ctx.JSON(http.StatusCreated, resp)
}

// GetFormVersions godoc
// @Summary      Get all form versions by kelompok
// @Tags         Admin Form
// @Param        kelompok query string true "anak, remaja, dewasa, lansia"
// @Success      200 {array} models.FormVersionResponse
// @Router       /api/admin/form-versi [get]
func (c *FormController) GetFormVersions(ctx echo.Context) error {
    kelompok := ctx.QueryParam("kelompok")
    if kelompok == "" {
        return ctx.JSON(http.StatusBadRequest, map[string]string{"error": "kelompok required"})
    }
    resp, err := c.formUsecase.GetFormVersionsByKelompok(ctx.Request().Context(), kelompok)
    if err != nil {
        return ctx.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
    }
    return ctx.JSON(http.StatusOK, resp)
}

// GetVersionDetail godoc
// @Summary      Get full detail of a form version (questions + risk rules)
// @Tags         Admin Form
// @Param        id path int true "Form Version ID"
// @Success      200 {object} map[string]interface{}
// @Router       /api/admin/form-versi/{id} [get]
func (c *FormController) GetVersionDetail(ctx echo.Context) error {
    id, err := strconv.ParseUint(ctx.Param("id"), 10, 32)
    if err != nil {
        return ctx.JSON(http.StatusBadRequest, map[string]string{"error": "invalid id"})
    }
    versi, questions, rules, err := c.formUsecase.GetVersionDetail(ctx.Request().Context(), uint(id))
    if err != nil {
        return ctx.JSON(http.StatusNotFound, map[string]string{"error": err.Error()})
    }
    return ctx.JSON(http.StatusOK, map[string]interface{}{
        "versi":      versi,
        "pertanyaan": questions,
        "aturan":     rules,
    })
}

// AddQuestion godoc
// @Summary      Add a new question to a form version
// @Tags         Admin Form
// @Param        versiId path int true "Form Version ID"
// @Param        request body models.AddQuestionRequest true "Request body"
// @Success      201 {object} models.QuestionResponse
// @Router       /api/admin/form-versi/{versiId}/questions [post]
func (c *FormController) AddQuestion(ctx echo.Context) error {
    versiID, err := strconv.ParseUint(ctx.Param("versiId"), 10, 32)
    if err != nil {
        return ctx.JSON(http.StatusBadRequest, map[string]string{"error": "invalid versi id"})
    }
    var req models.AddQuestionRequest
    if err := ctx.Bind(&req); err != nil {
        return ctx.JSON(http.StatusBadRequest, map[string]string{"error": err.Error()})
    }
    resp, err := c.formUsecase.AddQuestion(ctx.Request().Context(), uint(versiID), &req)
    if err != nil {
        return ctx.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
    }
    return ctx.JSON(http.StatusCreated, resp)
}

// UpdateQuestion godoc
// @Summary      Update an existing question
// @Tags         Admin Form
// @Param        id path int true "Question ID"
// @Param        request body models.UpdateQuestionRequest true "Request body"
// @Success      200 {object} map[string]string
// @Router       /api/admin/questions/{id} [put]
func (c *FormController) UpdateQuestion(ctx echo.Context) error {
    id, err := strconv.ParseUint(ctx.Param("id"), 10, 32)
    if err != nil {
        return ctx.JSON(http.StatusBadRequest, map[string]string{"error": "invalid id"})
    }
    var req models.UpdateQuestionRequest
    if err := ctx.Bind(&req); err != nil {
        return ctx.JSON(http.StatusBadRequest, map[string]string{"error": err.Error()})
    }
    if err := c.formUsecase.UpdateQuestion(ctx.Request().Context(), uint(id), &req); err != nil {
        return ctx.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
    }
    return ctx.JSON(http.StatusOK, map[string]string{"message": "question updated"})
}

// DeleteQuestion godoc
// @Summary      Delete a question
// @Tags         Admin Form
// @Param        id path int true "Question ID"
// @Success      200 {object} map[string]string
// @Router       /api/admin/questions/{id} [delete]
func (c *FormController) DeleteQuestion(ctx echo.Context) error {
    id, err := strconv.ParseUint(ctx.Param("id"), 10, 32)
    if err != nil {
        return ctx.JSON(http.StatusBadRequest, map[string]string{"error": "invalid id"})
    }
    if err := c.formUsecase.DeleteQuestion(ctx.Request().Context(), uint(id)); err != nil {
        return ctx.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
    }
    return ctx.JSON(http.StatusOK, map[string]string{"message": "question deleted"})
}

// AddRiskRule godoc
// @Summary      Add a new risk rule to a form version
// @Tags         Admin Form
// @Param        versiId path int true "Form Version ID"
// @Param        request body models.AddRiskRuleRequest true "Request body"
// @Success      201 {object} models.RiskRuleResponse
// @Router       /api/admin/form-versi/{versiId}/risk-rules [post]
func (c *FormController) AddRiskRule(ctx echo.Context) error {
    versiID, err := strconv.ParseUint(ctx.Param("versiId"), 10, 32)
    if err != nil {
        return ctx.JSON(http.StatusBadRequest, map[string]string{"error": "invalid versi id"})
    }
    var req models.AddRiskRuleRequest
    if err := ctx.Bind(&req); err != nil {
        return ctx.JSON(http.StatusBadRequest, map[string]string{"error": err.Error()})
    }
    resp, err := c.formUsecase.AddRiskRule(ctx.Request().Context(), uint(versiID), &req)
    if err != nil {
        return ctx.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
    }
    return ctx.JSON(http.StatusCreated, resp)
}

// UpdateRiskRule godoc
// @Summary      Update an existing risk rule
// @Tags         Admin Form
// @Param        id path int true "Risk Rule ID"
// @Param        request body models.UpdateRiskRuleRequest true "Request body"
// @Success      200 {object} map[string]string
// @Router       /api/admin/risk-rules/{id} [put]
func (c *FormController) UpdateRiskRule(ctx echo.Context) error {
    id, err := strconv.ParseUint(ctx.Param("id"), 10, 32)
    if err != nil {
        return ctx.JSON(http.StatusBadRequest, map[string]string{"error": "invalid id"})
    }
    var req models.UpdateRiskRuleRequest
    if err := ctx.Bind(&req); err != nil {
        return ctx.JSON(http.StatusBadRequest, map[string]string{"error": err.Error()})
    }
    if err := c.formUsecase.UpdateRiskRule(ctx.Request().Context(), uint(id), &req); err != nil {
        return ctx.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
    }
    return ctx.JSON(http.StatusOK, map[string]string{"message": "risk rule updated"})
}

// DeleteRiskRule godoc
// @Summary      Delete a risk rule
// @Tags         Admin Form
// @Param        id path int true "Risk Rule ID"
// @Success      200 {object} map[string]string
// @Router       /api/admin/risk-rules/{id} [delete]
func (c *FormController) DeleteRiskRule(ctx echo.Context) error {
    id, err := strconv.ParseUint(ctx.Param("id"), 10, 32)
    if err != nil {
        return ctx.JSON(http.StatusBadRequest, map[string]string{"error": "invalid id"})
    }
    if err := c.formUsecase.DeleteRiskRule(ctx.Request().Context(), uint(id)); err != nil {
        return ctx.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
    }
    return ctx.JSON(http.StatusOK, map[string]string{"message": "risk rule deleted"})
}