// src/services/formVersion.js
import api from "./api";

// ==================== FORM VERSI ====================
export const getFormVersions = async (kelompok) => {
  const response = await api.get("/superadmin/form-versi", { params: { kelompok } });
  return response.data; // array of FormVersionResponse
};

export const createFormVersion = async (payload) => {
  const response = await api.post("/superadmin/form-versi", payload);
  return response.data; // created version object
};

export const activateFormVersion = async (id) => {
  const response = await api.post(`/superadmin/form-versi/${id}/activate`);
  return response.data;
};

export const deactivateFormVersion = async (id) => {
  const response = await api.post(`/superadmin/form-versi/${id}/deactivate`);
  return response.data;
};

export const duplicateFormVersion = async (id, payload) => {
  const response = await api.post(`/superadmin/form-versi/${id}/duplicate`, payload);
  return response.data;
};

export const getVersionDetail = async (id) => {
  const response = await api.get(`/superadmin/form-versi/${id}`);
  return response.data; // { versi: {...}, pertanyaan: [...], aturan: [...] }
};

// ==================== PERTANYAAN ====================
export const addQuestion = async (versiId, payload) => {
  const response = await api.post(`/superadmin/form-versi/${versiId}/questions`, payload);
  return response.data;
};

export const updateQuestion = async (questionId, payload) => {
  const response = await api.put(`/superadmin/questions/${questionId}`, payload);
  return response.data;
};

export const deleteQuestion = async (questionId) => {
  const response = await api.delete(`/superadmin/questions/${questionId}`);
  return response.data;
};

// ==================== ATURAN RISIKO ====================
export const addRiskRule = async (versiId, payload) => {
  const response = await api.post(`/superadmin/form-versi/${versiId}/risk-rules`, payload);
  return response.data;
};

export const updateRiskRule = async (ruleId, payload) => {
  const response = await api.put(`/superadmin/risk-rules/${ruleId}`, payload);
  return response.data;
};

export const deleteRiskRule = async (ruleId) => {
  const response = await api.delete(`/superadmin/risk-rules/${ruleId}`);
  return response.data;
};