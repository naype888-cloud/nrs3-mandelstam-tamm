"""Figure for Mandelstam–Tamm with the sharp constant π/2 and its NRS³ instance.

Writes docs/figures/mandelstam_tamm_sharp.png.

Left: survival amplitudes |A(t)| against ΔE·t (ħ = 1) for random finite spectra (numerical)
and two equal branches (exact), above the Lean bound cos(ΔE t) up to π/2; the weaker bound
1 − (ΔE t)²/2 is shown for comparison. Right: on T_d : P_d the Mandelstam–Tamm ratio
⟨K⟩² / (4 Var T · Var P) at the maximal-tension state is 1/C_Nava(d)² (Lean, D41 in
nava-robertson-schrodinger; values here numerical).

Run:  python3 docs/simulation/figures_mandelstam_tamm.py
"""

import matplotlib.pyplot as plt
import numpy as np

from nrs3_ratio import C_INF_SQ, ratio
from style import BLUE, INK, INK2, MUTED, ORANGE, OUT, SURFACE


def survival(p, e, s):
    sigma = np.sqrt(p @ (e - p @ e) ** 2)
    return np.abs(np.exp(-1j * np.outer(s / sigma, e)) @ p)


def fig_mandelstam_tamm():
    fig, (ax, bx) = plt.subplots(1, 2, figsize=(11.8, 4.7), dpi=150,
                                 gridspec_kw={"width_ratios": [1.2, 1]})
    rng = np.random.default_rng(1945)
    s = np.linspace(0, 2.6, 600)
    for i in range(16):
        n = rng.integers(3, 30)
        p = rng.dirichlet(np.ones(n))
        e = rng.normal(size=n)
        ax.plot(s, survival(p, e, s), color=MUTED, lw=0.8, alpha=0.55,
                label="random spectra (numerical)" if i == 0 else None)
    ax.plot(s, np.abs(np.cos(s)), color=BLUE, lw=2.2, label="two equal branches: |cos ΔE t|")
    m = s <= np.pi / 2
    ax.plot(s[m], np.cos(s[m]), color=ORANGE, lw=2, ls="--", label="Lean bound cos(ΔE t)")
    b = s <= np.sqrt(2)
    ax.plot(s[b], 1 - s[b] ** 2 / 2, color=INK2, lw=1, ls=":", label="weaker 1 − (ΔE t)²/2")
    ax.axvline(np.pi / 2, color=ORANGE, lw=0.9)
    ax.text(np.pi / 2 + 0.04, 0.9, "orthogonal no\nearlier than\nπħ/(2ΔE)", color=INK2,
            fontsize=9.5, va="top")
    ax.set_xlim(0, 2.6)
    ax.set_ylim(0, 1.32)
    ax.set_xlabel("ΔE · t / ħ")
    ax.set_ylabel("survival amplitude  ‖A(t)‖")
    ax.legend(loc="upper right", fontsize=8.6, ncol=2, framealpha=0.95)
    ax.set_title("The sharp speed limit π/2 (saturated by two branches)", loc="left",
                 fontsize=11.5)

    ds = np.arange(2, 41)
    r = np.array([ratio(d) for d in ds])
    bx.axhline(1, color=INK2, lw=1.4)
    bx.axhline(1 / C_INF_SQ, color=MUTED, lw=1, ls="--")
    bx.text(40, 1 / C_INF_SQ - 0.012, "1/C∞² ≈ 0.775", ha="right", va="top", color=INK2,
            fontsize=9.5)
    bx.plot(ds[ds >= 4], r[ds >= 4], "o", color=BLUE, mec=SURFACE, mew=1, ms=5,
            label="d ≥ 4: strict")
    bx.plot([2, 3], r[:2], "o", color=ORANGE, mec=SURFACE, mew=1.3, ms=8,
            label="d = 2, 3: saturated")
    bx.set_ylim(0.74, 1.03)
    bx.set_xlabel("sites per axis  d")
    bx.set_ylabel("⟨K⟩² / (4 Var T · Var P)  at ψ*")
    bx.legend(loc="center right", fontsize=9)
    bx.set_title("NRS³: the ratio is 1/C_Nava(d)²", loc="left", fontsize=11.5)

    fig.suptitle("Mandelstam–Tamm 1945 on H_d = ℂ^d and on NRS³", x=0.01, ha="left",
                 fontsize=13, color=INK)
    fig.tight_layout()
    fig.savefig(OUT / "mandelstam_tamm_sharp.png", facecolor=SURFACE)
    plt.close(fig)


if __name__ == "__main__":
    fig_mandelstam_tamm()
