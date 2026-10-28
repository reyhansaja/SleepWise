import { useState } from "react";
import { api } from "../lib/api";
import { Alert, Button, Card, Pill, Spinner } from "./ui";

const DEFAULTS = {
  n_estimators: 200,
  max_depth: "",
  min_samples_leaf: 1,
  test_size: 0.2,
  folds: 5,
  random_state: 42,
};

const NUMBER_FIELDS = [
  { key: "n_estimators", label: "n_estimators (RF)", min: 10, max: 1000, step: 10, hint: "jumlah pohon" },
  { key: "max_depth", label: "max_depth", min: 1, max: 40, step: 1, hint: "kosong = tak terbatas" },
  { key: "min_samples_leaf", label: "min_samples_leaf", min: 1, max: 50, step: 1, hint: "minimal sampel per daun" },
  { key: "test_size", label: "test_size", min: 0.1, max: 0.4, step: 0.05, hint: "porsi data uji" },
  { key: "folds", label: "folds (CV)", min: 2, max: 10, step: 1, hint: "lipatan cross-validation" },
  { key: "random_state", label: "random_state", min: 0, max: 9999, step: 1, hint: "agar hasil dapat diulang" },
];

export default function TrainPanel({ dataset, onTrained, token, busy, setBusy }) {
  const [params, setParams] = useState(DEFAULTS);
  const [target, setTarget] = useState("");
  const [error, setError] = useState("");

  const derived = dataset?.project_schema;
  const targetValue = derived ? "Quality of Sleep" : target;

  async function submit(event) {
    event.preventDefault();
    if (!dataset) return;
    if (!derived && !target) {
      setError("Pilih kolom target terlebih dahulu.");
      return;
    }
    setError("");
    setBusy(true);
    try {
      const payload = {
        dataset_id: dataset.dataset_id,
        target_column: derived ? undefined : target,
        params: {
          ...params,
          max_depth: params.max_depth === "" ? null : Number(params.max_depth),
        },
      };
      onTrained(await api.train(payload, token));
    } catch (err) {
      setError(err.message);
    } finally {
      setBusy(false);
    }
  }

  return (
    <Card
      title="2 · Konfigurasi Training"
      subtitle="Kedua model memakai split, preprocessing, dan lipatan CV yang identik agar perbandingan adil."
      right={dataset ? <Pill tone="green">{derived ? "target otomatis" : "target manual"}</Pill> : null}
    >
      <form onSubmit={submit} className="space-y-4">
        <div className="grid gap-3 sm:grid-cols-2">
          <label className="block">
            <span className="mb-1 block text-xs font-medium text-slate-300">Kolom target</span>
            {derived ? (
              <input
                value="Quality of Sleep → Good / Average / Poor"
                readOnly
                className="w-full rounded-xl border border-white/10 bg-slate-950/60 px-3 py-2 text-sm text-slate-300"
              />
            ) : (
              <select
                value={target}
                onChange={(e) => setTarget(e.target.value)}
                className="w-full rounded-xl border border-white/10 bg-slate-950/60 px-3 py-2 text-sm text-white outline-none focus:border-emerald-400"
              >
                <option value="">— pilih kolom target —</option>
                {dataset?.columns.map((col) => (
                  <option key={col} value={col}>
                    {col}
                  </option>
                ))}
              </select>
            )}
          </label>

          <div className="rounded-xl border border-white/10 bg-slate-950/40 px-3 py-2 text-xs text-slate-400">
            <p className="font-medium text-slate-300">Alur training</p>
            <p className="mt-1">clean → split 80/20 stratify → ColumnTransformer → fit DT & RF → evaluasi test + CV</p>
          </div>
        </div>

        <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">
          {NUMBER_FIELDS.map((field) => (
            <label key={field.key} className="block">
              <span className="mb-1 block text-xs font-medium text-slate-300">{field.label}</span>
              <input
                type="number"
                min={field.min}
                max={field.max}
                step={field.step}
                value={params[field.key]}
                onChange={(e) => setParams((prev) => ({ ...prev, [field.key]: e.target.value }))}
                className="w-full rounded-xl border border-white/10 bg-slate-950/60 px-3 py-2 text-sm text-white outline-none focus:border-emerald-400"
              />
              <span className="mt-1 block text-[10px] text-slate-500">{field.hint}</span>
            </label>
          ))}
        </div>

        {error && <Alert>{error}</Alert>}

        <div className="flex flex-wrap items-center gap-3">
          <Button type="submit" disabled={!dataset || busy}>
            {busy ? "Melatih model…" : "Mulai Training"}
          </Button>
          {busy && <Spinner label="Random Forest & Decision Tree sedang dilatih" />}
          {!dataset && <span className="text-xs text-slate-500">Unggah dataset dulu.</span>}
        </div>
      </form>
    </Card>
  );
}
