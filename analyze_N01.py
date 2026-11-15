"""Tri-gate vs planar: Vt, DIBL, SS, Id at equal overdrive, gm. Usage: python analyze_N01.py <attempt>
Vt: gate voltage at constant current 1 mA/mm of width (tri: fin width W; planar: per um). DIBL = (Vt_lo - Vt_hi)/(7-0.5) in mV/V.
SS: minimum over the range where Id > 1e-6 mA/mm (below that, currents are not trustworthy). Ion: Id at Vt + 2 V. gm: max over sweep."""
from pathlib import Path
import sys, re, json
import numpy as np
A = Path(__file__).resolve().parent / (sys.argv[1] if len(sys.argv) > 1 else 'phaseN01')
C = json.loads((A / 'CASES.json').read_text()); SP = C['SPACE']
def load(f):
    s = f.read_text(); n = re.findall(r'"([^"]+)"', s.split('datasets', 1)[1].split(']', 1)[0])
    a = np.array(s.split('Data {', 1)[1].rsplit('}', 1)[0].split(), float).reshape(-1, len(n)); return {k: a[:, i] for i, k in enumerate(n)}
def vat(x, y, th):
    k = np.where((y[:-1] < th) & (y[1:] >= th))[0]
    return float(np.interp(np.log10(th), np.log10(y[k[0]:k[0] + 2]), x[k[0]:k[0] + 2])) if len(k) else None
M = {}
for c, (t3, tox, W, LG, Vd, voff) in C['cases'].items():
    f = A / 'results' / c / 'idvg_lin_current.plt'
    if not f.exists(): continue
    d = load(f); vg = d['gate OuterVoltage']; i = np.abs(d['drain TotalCurrent']); wn = 1.0 if W is None else W / 2
    x, o = np.unique(vg, return_index=True); J = i[o] / wn * 1e6; fp = 1.0 if W is None else wn / ((W + SP) / 2)
    vt = vat(x, J, 1.0); g = J > 1e-6; lg = np.log10(J[g]); ss = np.abs(np.gradient(x[g], lg)) * 1e3
    gm = np.gradient(J, x)
    M[c] = dict(W=W, LG=LG, Vd=Vd, Vg_end=float(x.min()), Vt=vt, SS=float(np.min(ss)) if g.sum() > 3 else None,
                Ion=float(np.interp(vt + 2, x, J)) if vt is not None else None, fp=fp, gm=float(np.max(np.abs(gm))), floor=float(J.min()))
(A / 'METRICS_N01.json').write_text(json.dumps(M, indent=1))
print(f"{'case':20}{'Vg end':>7}{'Vt':>8}{'SS':>7}{'Ion(Vt+2)':>11}{'per footp':>10}{'gm max':>8}{'floor':>10}")
for c, r in M.items():
    f = lambda k, p: format(r[k], p) if r.get(k) is not None else '-'
    print(f"{c:20}{r['Vg_end']:7.2f}{f('Vt','8.2f')}{f('SS','7.0f')}{f('Ion','11.1f')}{(r['Ion'] or 0)*r['fp']:10.1f}{r['gm']:8.1f}{r['floor']:10.1e}")
print('\nDIBL (mV/V) = (Vt at Vd 0.5 - Vt at Vd 7) / 6.5')
for dev in ['planar', 'tri']:
    for L in ['L1000', 'L0500', 'L0250']:
        a, b = M.get(f'{dev}_{L}_lo'), M.get(f'{dev}_{L}_hi')
        if a and b and a['Vt'] is not None and b['Vt'] is not None:
            print(f'  {dev:7}{L}: Vt lo {a["Vt"]:.3f}, hi {b["Vt"]:.3f}, DIBL {(a["Vt"] - b["Vt"]) / 6.5 * 1e3:.0f} mV/V, SS lo {a["SS"]:.0f} hi {b["SS"]:.0f}')
