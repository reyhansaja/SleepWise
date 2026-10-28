import { useCallback, useEffect, useState } from "react";
import { api } from "./lib/api";
import { Alert, Card, Pill } from "./components/ui";
import UploadPanel from "./components/UploadPanel";
import TrainPanel from "./components/TrainPanel";
import ResultsPanel from "./components/ResultsPanel";
import RunsPanel from "./components/RunsPanel";

export default function App() {
  const [health, setHealth] = useState(null);
  const [healthError, setHealthError] = useState("");
  const [dataset, setDataset] = useState(null);
  const [result, setResult] = useState(null);
  const [runs, setRuns] = useState([]);
  const [busy, setBusy] = useState(false);
  const [promoteState, setPromoteState] = useState({ busy: "", ok: false, name: "" });
  const [token, setToken] = useState(() => localStorage.getItem("sleepwise.trainingToken") ?? "");
  const [notice, setNotice] = useState("");

  const refreshMeta = useCallback(async () => {
    try {
      const [h, r] = await Promise.all([api.health(), api.runs(10)]);
      setHealth(h);
      setRuns(r.data ?? []);
      setHealthError("");
    } catch (err) {
      setHealthError(err.message);
    }
  }, []);

  useEffect(() => {
    refreshMeta();
  }, [refreshMeta]);

  function onTokenChange(value) {
    setToken(value);
    localStorage.setItem("sleepwise.trainingToken", value);
  }

  async function handleTrained(metadata) {
    setResult(metadata);
    setPromoteState({ busy: "", ok: false, name: "" });
    await refreshMeta();
    requestAnimationFrame(() => document.getElementById("hasil")?.scrollIntoView({ behavior: "smooth" }));
  }

  async function handlePromote(runId, modelKey) {
    setPromoteState({ busy: modelKey, ok: false, name: "" });
    try {
      const payload = await api.promote(runId, modelKey, token);
      setPromoteState({ busy: "", ok: true, name: payload.model_name });
      await refreshMeta();
    } catch (err) {
      setPromoteState({ busy: "", ok: false, name: "" });
      throw err;
    }
  }

  async function openRun(runId) {
    setNotice("");
    try {
      const metadata = await api.run(runId);
      setResult(metadata);
      setDataset(null);
      requestAnimationFrame(() => document.getElementById("hasil")?.scrollIntoView({ behavior: "smooth" }));
    } catch (err) {
      setNotice(err.message);
    }
  }

  const dbState = health?.database === "up" ? "green" : "red";
  const modelState = health?.models?.length ? "green" : "amber";

  return (
    <div className="mx-auto max-w-6xl px-4 py-6 sm:px-6 sm:py-10">
      <header className="mb-6 flex flex-wrap items-start justify-between gap-4">
        <div>
          <div className="flex items-center gap-3">
            <span className="flex h-11 w-11 items-center justify-center rounded-xl bg-emerald-500/20 text-lg font-bold text-emerald-300 ring-1 ring-emerald-400/40">
              SW
            </span>
            <div>
              <h1 className="text-xl font-bold text-white sm:text-2xl">SleepWise · ML Training</h1>
              <p className="text-xs text-slate-400 sm:text-sm">
                Upload dataset → latih Decision Tree & Random Forest → bandingkan → aktifkan model.
              </p>
            </div>
          </div>
        </div>
        <div className="flex flex-wrap items-center gap-2">
          <Pill tone={dbState}>MySQL {health ? (health.database === "up" ? "up" : "down") : "…"}</Pill>
          <Pill tone={modelState}>model aktif: {health?.selected_model ?? "—"}</Pill>
          <Pill tone="slate">/api → 127.0.0.1:5000</Pill>
        </div>
      </header>

      {healthError && (
        <div className="mb-4">
          <Alert>
            Backend tidak dapat dihubungi: {healthError}. Jalankan{" "}
            <code className="rounded bg-black/30 px-1">python backend/app.py</code> lalu muat ulang halaman.
          </Alert>
        </div>
      )}
      {notice && <div className="mb-4"><Alert tone="amber">{notice}</Alert></div>}

      <div className="space-y-5">
        <UploadPanel dataset={dataset} onUploaded={setDataset} token={token} />
        <TrainPanel
          dataset={dataset}
          onTrained={handleTrained}
          token={token}
          busy={busy}
          setBusy={setBusy}
        />

        <div id="hasil">
          <ResultsPanel result={result} onPromote={handlePromote} promoteState={promoteState} />
        </div>

        <RunsPanel runs={runs} onOpen={openRun} activeRun={result?.run_id} />

        <Card title="Pengaturan" subtitle="Opsional. Token hanya perlu bila TRAINING_TOKEN diisi pada backend/.env.">
          <label className="block max-w-sm">
            <span className="mb-1 block text-xs font-medium text-slate-300">X-Training-Token</span>
            <input
              type="password"
              value={token}
              onChange={(e) => onTokenChange(e.target.value)}
              placeholder="kosongkan bila backend tidak memakai token"
              className="w-full rounded-xl border border-white/10 bg-slate-950/60 px-3 py-2 text-sm text-white outline-none focus:border-emerald-400"
            />
          </label>
          <p className="mt-3 text-[11px] text-slate-500">
            Prediksi adalah estimasi model machine learning, bukan diagnosis medis.
          </p>
        </Card>
      </div>

      <footer className="mt-8 text-center text-[11px] text-slate-600">
        SleepWise · Flask + scikit-learn + MySQL · React + Tailwind
      </footer>
    </div>
  );
}
