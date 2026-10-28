import { useRef, useState } from "react";
import { api } from "../lib/api";
import { Alert, Button, Card, Pill, Spinner } from "./ui";

export default function UploadPanel({ dataset, onUploaded, token }) {
  const inputRef = useRef(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  const [dragging, setDragging] = useState(false);

  async function handleFile(file) {
    if (!file) return;
    setError("");
    setBusy(true);
    try {
      const result = await api.upload(file, token);
      onUploaded(result);
    } catch (err) {
      setError(err.message);
    } finally {
      setBusy(false);
    }
  }

  return (
    <Card
      title="1 · Dataset"
      subtitle="Unggah CSV mentah SleepWise atau dataset lain dengan kolom target kategorikal."
      right={dataset ? <Pill tone="green">{dataset.rows} baris · {dataset.columns.length} kolom</Pill> : null}
    >
      <div
        onDragOver={(e) => {
          e.preventDefault();
          setDragging(true);
        }}
        onDragLeave={() => setDragging(false)}
        onDrop={(e) => {
          e.preventDefault();
          setDragging(false);
          handleFile(e.dataTransfer.files?.[0]);
        }}
        onClick={() => inputRef.current?.click()}
        className={`flex cursor-pointer flex-col items-center justify-center gap-2 rounded-xl border border-dashed px-4 py-8 text-center transition ${
          dragging ? "border-emerald-400 bg-emerald-400/10" : "border-white/15 bg-slate-950/30 hover:border-emerald-400/60"
        }`}
      >
        <span className="text-2xl">⬆️</span>
        <p className="text-sm font-medium text-white">Tarik file CSV ke sini atau klik untuk memilih</p>
        <p className="text-xs text-slate-400">Maksimal 10 MB · minimal 20 baris</p>
        <input
          ref={inputRef}
          type="file"
          accept=".csv,text/csv"
          className="hidden"
          onChange={(e) => handleFile(e.target.files?.[0])}
        />
      </div>

      {busy && <div className="mt-3"><Spinner label="Mengunggah & membaca CSV…" /></div>}
      {error && <div className="mt-3"><Alert>{error}</Alert></div>}

      {dataset && (
        <div className="mt-4 space-y-3">
          <div className="flex flex-wrap items-center gap-2">
            <Pill tone="blue">{dataset.dataset_filename}</Pill>
            <Pill tone={dataset.project_schema ? "green" : "amber"}>
              {dataset.project_schema ? "skema proyek · siap produksi" : "skema generik · tidak bisa diaktifkan"}
            </Pill>
            <Pill>id: {dataset.dataset_id}</Pill>
          </div>
          <div className="overflow-x-auto rounded-xl border border-white/10">
            <table className="min-w-full text-left text-xs">
              <thead className="bg-white/5 text-slate-300">
                <tr>
                  {dataset.columns.map((col) => (
                    <th key={col} className="whitespace-nowrap px-3 py-2 font-semibold">
                      {col}
                      {dataset.missing?.[col] > 0 && (
                        <span className="ml-1 text-amber-300">({dataset.missing[col]} kosong)</span>
                      )}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody className="divide-y divide-white/5 text-slate-400">
                {dataset.preview.map((row, i) => (
                  <tr key={i}>
                    {dataset.columns.map((col) => (
                      <td key={col} className="whitespace-nowrap px-3 py-1.5">
                        {row[col] ?? "—"}
                      </td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <p className="text-[11px] text-slate-500">Menampilkan 8 baris pertama.</p>
        </div>
      )}
    </Card>
  );
}
