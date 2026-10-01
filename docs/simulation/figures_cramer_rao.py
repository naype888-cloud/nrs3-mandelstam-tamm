"""Figure for the quantum Cramér–Rao bound and its NRS³ instance (numpy, matplotlib).

Writes docs/figures/cramer_rao_nrs3.png.

Left: on T_d : P_d the parameter is imprinted by e^{−iθT_d} and read with P_d; at the
maximal-tension state the efficiency F_P / F_Q equals 1/C_Nava(d)²: 1 at d = 2, 3, below 1 from
d = 4 on, towards 1/C∞² = 1/(π²/3 − 2) (Lean: D41 in nava-robertson-schrodinger; values here
numerical). Right: random states of d = 4 under the Lean bound F_X ≤ F_Q (numerical).

Run:  python3 docs/simulation/figures_cramer_rao.py
"""

import matplotlib.pyplot as plt
import numpy as np

from nrs3_ratio import C_INF_SQ, ops, ratio
from style import BLUE, INK, INK2, MUTED, ORANGE, OUT, SURFACE


def fig_cramer_rao():
    fig, (ax, bx) = plt.subplots(1, 2, figsize=(11.6, 4.6), dpi=150,
                                 gridspec_kw={"width_ratios": [1.25, 1]})
    ds = np.arange(2, 41)
    r = np.array([ratio(d) for d in ds])
    ax.axhline(1, color=INK2, lw=1.4)
    ax.axhline(1 / C_INF_SQ, color=MUTED, lw=1, ls="--")
    ax.text(40, 1 / C_INF_SQ - 0.012, "1/C∞² = 1/(π²/3 − 2) ≈ 0.775", ha="right", va="top",
            color=INK2, fontsize=9.5)
    ax.plot(ds[ds >= 4], r[ds >= 4], "o", color=BLUE, mec=SURFACE, mew=1, ms=5.5,
            label="d ≥ 4: the algebraic quantum, F_P < F_Q")
    ax.plot([2, 3], r[:2], "o", color=ORANGE, mec=SURFACE, mew=1.3, ms=8,
            label="d = 2, 3: Cramér–Rao saturated")
    ax.set_ylim(0.74, 1.03)
    ax.set_xlabel("sites per axis  d")
    ax.set_ylabel("efficiency  F_P / F_Q  at ψ*")
    ax.legend(loc="center right", fontsize=9)
    ax.set_title("NRS³: the efficiency is 1/C_Nava(d)²", loc="left", fontsize=11.5)

    rng = np.random.default_rng(4)
    t, p = ops(4)
    fx, fq = [], []
    for _ in range(4000):
        z = rng.normal(size=4) + 1j * rng.normal(size=4)
        z /= np.linalg.norm(z)
        m = lambda x: (z.conj() @ x @ z)
        c = abs(m(t @ p - p @ t)) ** 2
        vt, vp = (m(t @ t) - m(t) ** 2).real, (m(p @ p) - m(p) ** 2).real
        fx.append(c / vp)
        fq.append(4 * vt)
    fx, fq = np.array(fx), np.array(fq)
    bx.scatter(fq, fx, s=4, color=BLUE, alpha=0.25, lw=0, label="random states, d = 4")
    lim = fq.max() * 1.05
    bx.plot([0, lim], [0, lim], color=ORANGE, lw=1.8, ls="--", label="F_X = F_Q (Lean bound)")
    bx.set_xlim(0, lim)
    bx.set_ylim(0, lim)
    bx.set_xlabel("quantum Fisher information  F_Q = 4 Var T")
    bx.set_ylabel("error-propagation  F_P")
    bx.legend(loc="upper left", fontsize=9)
    bx.set_title("No state beats F_Q", loc="left", fontsize=11.5)

    fig.suptitle("Quantum Cramér–Rao on NRS³", x=0.01, ha="left", fontsize=13, color=INK)
    fig.tight_layout()
    fig.savefig(OUT / "cramer_rao_nrs3.png", facecolor=SURFACE)
    plt.close(fig)


if __name__ == "__main__":
    fig_cramer_rao()
