import { pct } from "../lib/api";
import { Card, Pill } from "./ui";

export default function RunsPanel({ runs, onOpen, activeRun }) {
  return (
    <Card title="Riwayat Training" subtitle="Tersimpan di MySQL (tabel training_runs).">
      {runs.length === 0 ? (
        <p className="text-sm text-slate-400">Belum ada run. Latih model pertama Anda di atas.</p>
      ) : (
        <div className="overflow-x-auto rounded-xl border border-white/10">
          <table className="min-w-full text-left text-xs">
            <thead className="bg-white/5 text-slate-300">
              <tr>
                <th className="px-3 py-2 font-semibold">waktu</th>
                <th className="px-3 py-2 font-semibold">run</th>
                <th className="px-3 py-2 font-semibold">dataset</th>
                <th className="px-3 py-2 font-semibold">model</th>
                <th className="px-3 py-2 font-semibold">acc</th>
                <th className="px-3 py-2 font-semibold">F1 (w)</th>
                <th className="px-3 py-2 font-semibold">CV F1</th>
                <th className="px-3 py-2" />
              </tr>
            </thead>
            <tbody className="divide-y divide-white/5 text-slate-400">
              {runs.map((run) => (
                <tr key={`${run.run_id}-${run.model_key}`} className={activeRun === run.run_id ? "bg-emerald-400/5" : ""}>
                  <td className="whitespace-nowrap px-3 py-2">{String(run.created_at).slice(0, 19).replace("T", " ")}</td>
                  <td className="whitespace-nowrap px-3 py-2 font-mono text-[11px] text-slate-300">{run.run_id}</td>
                  <td className="whitespace-nowrap px-3 py-2">
                    {run.dataset_filename}
                    <span className="ml-1 text-slate-600">({run.dataset_rows})</span>
                  </td>
                  <td className="whitespace-nowrap px-3 py-2">{run.model_name}</td>
                  <td className="px-3 py-2">{pct(run.accuracy, 1)}</td>
                  <td className="px-3 py-2">{pct(run.f1_weighted, 1)}</td>
                  <td className="px-3 py-2">{pct(run.cv_f1_weighted, 1)}</td>
                  <td className="px-3 py-2 text-right">
                    <button
                      onClick={() => onOpen(run.run_id)}
                      className="rounded-lg border border-white/15 px-2 py-1 text-[11px] text-slate-200 hover:bg-white/5"
                    >
                      detail
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
      <div className="mt-3 flex flex-wrap gap-2">
        <Pill tone="blue">model aktif: dipilih lewat tombol “Aktifkan”</Pill>
        <Pill tone="slate">artefak: ml/models/runs/&lt;run_id&gt;/*.joblib</Pill>
      </div>
    </Card>
  );
}
