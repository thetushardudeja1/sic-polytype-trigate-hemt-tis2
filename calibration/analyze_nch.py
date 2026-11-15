"""n-channel model vs digitized measured Fig. 4 (APL 124, 120601). Usage: python analyze_nch.py <attempt>"""
import re, csv, sys, json
import numpy as np
from pathlib import Path
A = Path(sys.argv[1]) / 'results' / 'hemt'
def load(f):
    s = f.read_text(); n = re.findall(r'"([^"]+)"', s.split('datasets', 1)[1].split(']', 1)[0])
    a = np.array(s.split('Data {', 1)[1].rsplit('}', 1)[0].split(), float).reshape(-1, len(n)); return {k: a[:, i] for i, k in enumerate(n)}
M = list(csv.DictReader(open('digitize/nch_fig4_idvd.csv')))
out = {}; I7 = {}; Im7 = {}; E = []
print('Vgs   Vd_end  sim@1V meas@1V | sim@4V meas@4V | sim@7V meas@7V | RMS')
for v in [0, -1, -2, -3, -4]:
    f = A / f'famg{abs(v)}_fam_current.plt'
    if not f.exists(): print(v, 'missing'); continue
    d = load(f); vd = d['drain OuterVoltage']; i = np.abs(d['drain TotalCurrent']) * 1e6; o = np.argsort(vd); vd, i = vd[o], i[o]
    m = np.array(sorted((float(r['Vds_V']), float(r['Id_mA_mm'])) for r in M if float(r['Vgs_V']) == v))
    k = (m[:, 0] <= vd.max()); e = np.interp(m[k, 0], vd, i) - m[k, 1]; E.append(e); rms = float(np.sqrt(np.mean(e ** 2)))
    g = lambda x, X, Y: float(np.interp(x, X, Y))
    print(f'{v:4d}  {vd.max():5.2f}  {g(1,vd,i):6.2f} {g(1,m[:,0],m[:,1]):6.2f} | {g(4,vd,i):6.2f} {g(4,m[:,0],m[:,1]):6.2f} | {g(7,vd,i):6.2f} {g(7,m[:,0],m[:,1]):6.2f} | {rms:5.2f}')
    I7[v] = g(7, vd, i); Im7[v] = g(7, m[:, 0], m[:, 1]); out[v] = dict(rms=rms, vd_end=float(vd.max()))
if E: print('family RMS %.2f mA/mm over %d curves' % (np.sqrt(np.mean(np.concatenate(E) ** 2)), len(E)))
if 0 in I7 and -3 in I7:
    print('Vth (paper method, Id(0),Id(-3) at 7 V): sim %.2f, meas %.2f;  gm(0,-1): sim %.2f, meas %.2f' % (-3 * I7[0] / (I7[0] - I7[-3]), -3 * Im7[0] / (Im7[0] - Im7[-3]), I7[0] - I7.get(-1, np.nan), Im7[0] - Im7[-1]))
(A.parent / 'NCH_METRICS.json').write_text(json.dumps(dict(curves={str(k): v for k, v in out.items()}, I7_sim={str(k): v for k, v in I7.items()}, I7_meas={str(k): v for k, v in Im7.items()}), indent=1))
