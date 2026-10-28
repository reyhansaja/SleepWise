const BASE = "/api";

async function request(path, { method = "GET", body, formData, token } = {}) {
  const headers = {};
  if (body) headers["Content-Type"] = "application/json";
  if (token) headers["X-Training-Token"] = token;

  const res = await fetch(`${BASE}${path}`, {
    method,
    headers,
    body: formData ?? (body ? JSON.stringify(body) : undefined),
  });

  const text = await res.text();
  const data = text ? JSON.parse(text) : {};
  if (!res.ok) {
    const detail = data.details?.join(" · ") ?? data.error ?? res.statusText;
    throw new Error(detail || "Permintaan gagal");
  }
  return data;
}

export const api = {
  health: () => request("/health"),
  uploads: () => request("/ml/uploads"),
  upload: (file, token) => {
    const formData = new FormData();
    formData.append("file", file);
    return request("/ml/upload", { method: "POST", formData, token });
  },
  train: (payload, token) => request("/ml/train", { method: "POST", body: payload, token }),
  runs: (limit = 10) => request(`/ml/runs?limit=${limit}`),
  run: (runId) => request(`/ml/runs/${runId}`),
  promote: (runId, modelKey, token) =>
    request(`/ml/runs/${runId}/promote`, { method: "POST", body: { model_key: modelKey }, token }),
};

export const pct = (value, digits = 2) =>
  value === null || value === undefined ? "—" : `${(Number(value) * 100).toFixed(digits)}%`;
