import csv
import json
import re
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np

ROOT = Path(__file__).resolve().parent

def load_curve(path):
    text = path.read_text()
    names = re.findall(r'"([^"]+)"', text.split('datasets', 1)[1].split(']', 1)[0])
    rows = np.fromstring(text.split('Data {', 1)[1].rsplit('}', 1)[0], sep=' ')
    return dict(zip(names, rows.reshape(-1, len(names)).T))

def main():
    fig, (cal, dc) = plt.subplots(1, 2, figsize=(11.2, 4.7), layout='constrained')
    fig.patch.set_facecolor('white')
    with (ROOT / 'calibration/digitize/nch_fig4_idvd.csv').open() as handle:
        measured = list(csv.DictReader(handle))
    for gate, color in zip(range(5), ['#0c477c', '#087d78', '#8460a5', '#bc661d', '#646c78']):
        curve = load_curve(ROOT / f'calibration/fitC/results/hemt/famg{gate}_fam_current.plt')
        points = [row for row in measured if float(row['Vgs_V']) == -gate][::18]
        voltage = curve['drain OuterVoltage']
        sweep = slice(0, np.argmax(voltage) + 1)
        cal.plot(voltage[sweep], abs(curve['drain TotalCurrent'][sweep])*1e6,
                 color=color, label=f'{-gate} V')
        cal.scatter([float(row['Vds_V']) for row in points],
                    [float(row['Id_mA_mm']) for row in points],
                    facecolors='white', edgecolors=color, s=15)
    cal.set(title='Planar calibration', xlabel='Drain voltage (V)', ylabel='Drain current (mA/mm)')
    cal.legend(title='Gate voltage', fontsize=8, loc='upper left')
    cases = json.loads((ROOT / 'phaseN01/METRICS_N01.json').read_text())
    for device, color in [('planar', '#bc661d'), ('tri', '#0c477c')]:
        for bias, style in [('lo', '--'), ('hi', '-')]:
            name = f'{device}_L0250_{bias}'
            case = cases[name]
            curve = load_curve(ROOT / f'phaseN01/results/{name}/idvg_lin_current.plt')
            width = 1 if case['W'] is None else case['W']/2
            current = abs(curve['drain TotalCurrent'])*1e6/width
            mask = current > 1e-6
            label = 'Planar' if device == 'planar' else 'Tri-gate'
            dc.semilogy(curve['gate OuterVoltage'][mask], current[mask], style, color=color,
                        label=f"{label}, {case['Vd']:g} V")
    dc.axhline(1, color='#666666', ls=':', lw=0.9)
    dc.set(title='250 nm transfer characteristics', xlabel='Gate voltage (V)',
           ylabel='Drain current (mA/mm)', ylim=(1e-6, 500))
    dc.legend(title='Device and drain bias', fontsize=8, loc='lower right')
    for ax in (cal, dc):
        ax.grid(alpha=0.2)
        ax.set_axisbelow(True)
    fig.savefig(ROOT / 'figures/dc_results.png', dpi=180)

if __name__ == '__main__':
    main()
