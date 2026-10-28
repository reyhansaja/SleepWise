import { useState } from "react";
import { api, pct } from "../lib/api";
import { Alert, Button, Card, Pill, Stat } from "./ui";

function ConfusionMatrix({ model }) {
  const labels = model.test.report ? Object.keys(model.test.report).filter((k) => !["accuracy", "macro avg", "weighted avg"].includes(k)) : [];
  const matrix = model.test.confusion_matrix;
  const max = Math.max(...matrix.flat(), 1);

  return (
    <div className="overflow-x-auto">
      <table className="min-w-full text-center text-xs">
        <thead>
          <tr className="text-slate-400">
            <th className="px-2 py-1 text-left font-medium">aktual ↓ / prediksi →</th>
            {labels.map((l) => (
              <th key={l} className="px-2 py-1 font-medium">{l}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {matrix.map((row, i) => (
            <tr key={labels[i]}>
              <th className="px-2 py-1 text-left font-medium text-slate-300">{labels[i]}</th>
              {row.map((value, j) => {
                const intensity = value / max;
                const correct = i === j;
                return (
                  <td key={j} className="px-1 py-1">
                    <span
                      className={`inline-flex h-9 w-9 items-center justify-center rounded-lg text-xs font-semibold ${
                        correct ? "text-emerald-100" : "text-rose-100"
                      }`}
                      style={{
                        backgroundColor: correct
                          ? `rgba(16,185,129,${0.15 + intensity * 0.6})`
                          : `rgba(244,63,94,${0.08 + intensity * 0.55})`,
                      }}
                    >
                      {value}
                    </span>
                  </td>
                );
              })}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function ModelBlock({ model, isSelected, onPromote, promoting, canPromote }) {
  const cv = model.cv;
  return (
    <div className={`rounded-2xl border p-4 ${isSelected ? "border-emerald-400/50 bg-emerald-400/[0.06]" : "border-white/10 bg-slate-950/30"}`}>
      <div className="mb-3 flex flex-wrap items-center justify-between gap-2">
        <div className="flex items-center gap-2">
          <h3 className="text-sm font-semibold text-white">{model.model_name}</h3>
          {isSelected && <Pill tone="green">terpilih</Pill>}
        </div>
        <Pill tone="slate">{model.duration_ms} ms</Pill>
      </div>

      <div className="grid grid-cols-2 gap-2 sm:grid-cols-4">
        <Stat label="CV F1 (w)" value={pct(cv.f1_weighted_mean)} hint={`± ${pct(cv.f1_weighted_std)}`} tone="green" />
        <Stat label="Test acc" value={pct(model.test.accuracy)} tone="blue" />
        <Stat label="Test F1 (w)" value={pct(model.test.f1_weighted)} />
        <Stat label="Test F1 (macro)" value={pct(model.test.f1_macro)} tone="amber" />
      </div>

      <div className="mt-4 grid gap-4 lg:grid-cols-2">
        <div>
          <p className="mb-2 text-xs font-semibold uppercase tracking-wide text-slate-400">Confusion matrix</p>
          <ConfusionMatrix model={model} />
        </div>
        <div>
          <p className="mb-2 text-xs font-semibold uppercase tracking-wide text-slate-400">Per kelas</p>
          <table className="min-w-full text-left text-xs">
            <thead className="text-slate-400">
              <tr>
                <th className="py-1 pr-2 font-medium">kelas</th>
                <th className="py-1 pr-2 font-medium">prec</th>
                <th className="py-1 pr-2 font-medium">recall</th>
                <th className="py-1 pr-2 font-medium">f1</th>
                <th className="py-1 font-medium">support</th>
              </tr>
            </thead>
            <tbody className="text-slate-300">
              {Object.entries(model.test.report ?? {})
                .filter(([k]) => !["accuracy", "macro avg", "weighted avg"].includes(k))
                .map(([label, row]) => (
                  <tr key={label} className="border-t border-white/5">
                    <td className="py-1 pr-2">{label}</td>
                    <td className="py-1 pr-2">{pct(row.precision, 1)}</td>
                    <td className="py-1 pr-2">{pct(row.recall, 1)}</td>
                    <td className="py-1 pr-2">{pct(row["f1-score"], 1)}</td>
                    <td className="py-1">{row.support}</td>
                  </tr>
                ))}
            </tbody>
          </table>
        </div>
      </div>

      {model.feature_importance?.length > 0 && (
        <div className="mt-4">
          <p className="mb-2 text-xs font-semibold uppercase tracking-wide text-slate-400">Feature importance</p>
          <div className="space-y-1.5">
            {model.feature_importance.map((item) => (
              <div key={item.feature} className="flex items-center gap-2 text-xs">
                <span className="w-40 shrink-0 truncate text-slate-300">{item.feature}</span>
                <span className="h-2 flex-1 overflow-hidden rounded-full bg-white/10">
                  <span
                    className="block h-full rounded-full bg-emerald-400/80"
                    style={{ width: `${Math.min(100, item.importance * 300)}%` }}
                  />
                </span>
                <span className="w-12 text-right text-slate-400">{(item.importance * 100).toFixed(1)}%</span>
              </div>
            ))}
          </div>
        </div>
      )}

      <div className="mt-4 flex flex-wrap items-center gap-2">
        <Button
          variant="subtle"
          onClick={() => onPromote(model.model_key)}
          disabled={promoting || !canPromote}
        >
          {promoting ? "Mengaktifkan…" : `Aktifkan ${model.model_name}`}
        </Button>
        {!canPromote && (
          <span className="text-[11px] text-amber-300">
            Tidak bisa diaktifkan: dataset tanpa skema proyek.
          </span>
        )}
      </div>
    </div>
  );
}

export default function ResultsPanel({ result, onPromote, promoteState }) {
  const [error, setError] = useState("");
  if (!result) return null;

  const models = Object.values(result.models);
  const split = result.split;

  async function promote(modelKey) {
    setError("");
    try {
      await onPromote(result.run_id, modelKey);
    } catch (err) {
      setError(err.message);
    }
  }

  return (
    <Card
      title="3 · Hasil Training"
      subtitle={`Run ${result.run_id} · target ${result.target_column} · ${result.rows} baris data bersih`}
      right={<Pill tone={result.servable ? "green" : "amber"}>{result.servable ? "bisa diaktifkan" : "hanya eksperimen"}</Pill>}
    >
      <div className="mb-4 grid grid-cols-2 gap-2 sm:grid-cols-4">
        <Stat label="Train / test" value={`${split.train_rows} / ${split.test_rows}`} />
        <Stat label="Kelas" value={result.classes.length} hint={result.classes.join(" · ")} />
        <Stat label="Model terbaik" value={result.models[result.selected_model].model_name} tone="green" />
        <Stat label="Total waktu" value={`${result.duration_ms} ms`} />
      </div>

      {error && <div className="mb-4"><Alert>{error}</Alert></div>}
      {promoteState.ok && (
        <div className="mb-4"><Alert tone="green">Model {promoteState.name} aktif. Endpoint /api/predictions kini memakainya.</Alert></div>
      )}

      <div className="space-y-4">
        {models.map((model) => (
          <ModelBlock
            key={model.model_key}
            model={model}
            isSelected={result.selected_model === model.model_key}
            onPromote={promote}
            promoting={promoteState.busy === model.model_key}
            canPromote={result.servable}
          />
        ))}
      </div>

      <p className="mt-4 text-[11px] leading-relaxed text-slate-500">
        Catatan: CV F1 dipakai untuk memilih model; skor test set hanya dilaporkan. Skor sempurna pada
        dataset kecil tidak menjamin performa pada data baru, dan kelas dengan support rendah membuat
        F1 macro lebih sensitif daripada accuracy.
      </p>
    </Card>
  );
}
