export function Card({ title, subtitle, right, children, className = "" }) {
  return (
    <section
      className={`rounded-2xl border border-white/10 bg-white/[0.04] p-4 shadow-[0_1px_0_0_rgba(255,255,255,0.05)_inset] backdrop-blur sm:p-6 ${className}`}
    >
      {(title || right) && (
        <header className="mb-4 flex flex-wrap items-start justify-between gap-3">
          <div>
            {title && <h2 className="text-base font-semibold text-white sm:text-lg">{title}</h2>}
            {subtitle && <p className="mt-1 text-xs text-slate-400 sm:text-sm">{subtitle}</p>}
          </div>
          {right}
        </header>
      )}
      {children}
    </section>
  );
}

const toneMap = {
  green: "bg-emerald-500/15 text-emerald-300 ring-emerald-400/30",
  blue: "bg-sky-500/15 text-sky-300 ring-sky-400/30",
  amber: "bg-amber-500/15 text-amber-300 ring-amber-400/30",
  red: "bg-rose-500/15 text-rose-300 ring-rose-400/30",
  slate: "bg-white/5 text-slate-300 ring-white/15",
};

export function Pill({ children, tone = "slate" }) {
  return (
    <span
      className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-[11px] font-medium ring-1 ring-inset ${toneMap[tone] ?? toneMap.slate}`}
    >
      {children}
    </span>
  );
}

export function Button({ children, variant = "primary", className = "", ...props }) {
  const styles = {
    primary:
      "bg-emerald-500 text-slate-950 hover:bg-emerald-400 disabled:bg-emerald-500/40 disabled:text-slate-900/60",
    ghost: "border border-white/15 text-slate-200 hover:bg-white/5 disabled:opacity-40",
    subtle: "bg-white/10 text-white hover:bg-white/15 disabled:opacity-40",
  };
  return (
    <button
      className={`inline-flex items-center justify-center gap-2 rounded-xl px-4 py-2.5 text-sm font-semibold transition disabled:cursor-not-allowed ${styles[variant]} ${className}`}
      {...props}
    >
      {children}
    </button>
  );
}

export function Stat({ label, value, hint, tone = "white" }) {
  const tones = { white: "text-white", green: "text-emerald-300", blue: "text-sky-300", amber: "text-amber-300" };
  return (
    <div className="rounded-xl border border-white/10 bg-slate-950/40 p-3 sm:p-4">
      <p className="text-[11px] uppercase tracking-wide text-slate-400">{label}</p>
      <p className={`mt-1 text-xl font-bold sm:text-2xl ${tones[tone] ?? tones.white}`}>{value}</p>
      {hint && <p className="mt-1 text-[11px] text-slate-500">{hint}</p>}
    </div>
  );
}

export function Spinner({ label = "Memproses…" }) {
  return (
    <span className="inline-flex items-center gap-2 text-sm text-slate-300">
      <span className="h-3.5 w-3.5 animate-spin rounded-full border-2 border-white/25 border-t-emerald-400" />
      {label}
    </span>
  );
}

export function Alert({ tone = "red", children }) {
  const tones = {
    red: "border-rose-500/40 bg-rose-500/10 text-rose-200",
    green: "border-emerald-500/40 bg-emerald-500/10 text-emerald-200",
    amber: "border-amber-500/40 bg-amber-500/10 text-amber-200",
  };
  return (
    <div className={`rounded-xl border px-4 py-3 text-sm ${tones[tone] ?? tones.red}`} role="alert">
      {children}
    </div>
  );
}
