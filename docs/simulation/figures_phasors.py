"""Phasor picture of Mandelstam–Tamm, the static version of docs/index.html (numpy, matplotlib).

Writes docs/figures/mandelstam_tamm_phasors.png.

A(t) = ∑ p_k e^{−iE_k t} is the sum of the arrows p_k e^{−iE_k t}, tip to tail (ΔE = 1,
⟨E⟩ = 0). Lean: the tip never enters the disc of radius cos(ΔE t) before π/2
(cos_le_norm_amplitude); two equal branches stay on its rim (norm_amplitude_half_eq_cos).
The random spectrum is numerical.

Run:  python3 docs/simulation/figures_phasors.py
"""

import matplotlib.pyplot as plt
import numpy as np

from style import BLUE, GRID, INK, INK2, MUTED, ORANGE, OUT, SURFACE


def normalise(p, e):
    p = np.asarray(p, float) / np.sum(p)
    e = np.asarray(e, float)
    m = p @ e
    return p, (e - m) / np.sqrt(p @ (e - m) ** 2)


def panel(ax, p, e, t):
    ax.add_patch(plt.Circle((0, 0), 1, fill=False, color=GRID, lw=1))
    if t < np.pi / 2:
        ax.add_patch(plt.Circle((0, 0), np.cos(t), color=ORANGE, alpha=0.13, lw=0))
        ax.add_patch(plt.Circle((0, 0), np.cos(t), fill=False, color=ORANGE, lw=1.2, ls="--"))
    z = 0j
    for pk, ek in zip(p, e):
        w = pk * np.exp(-1j * ek * t)
        ax.annotate("", (z.real + w.real, z.imag + w.imag), (z.real, z.imag),
                    arrowprops=dict(arrowstyle="-|>", color=MUTED, lw=1.1, mutation_scale=8))
        z += w
    ax.annotate("", (z.real, z.imag), (0, 0),
                arrowprops=dict(arrowstyle="-|>", color=BLUE, lw=2.2, mutation_scale=12))
    ax.set_xlim(-1.08, 1.08)
    ax.set_ylim(-1.08, 1.08)
    ax.set_aspect("equal")
    ax.set_axis_off()
    floor = np.cos(t) if t < np.pi / 2 else 0.0
    ax.text(0, -1.22, f"‖A‖ = {abs(z):.3f}   floor = {floor:.3f}", ha="center", fontsize=9.5,
            color=INK2)


def fig_phasors():
    ts = [0.5, 1.0, 1.4, np.pi / 2]
    rng = np.random.default_rng(7)
    rows = [("two equal branches: on the rim", normalise([1, 1], [-1, 1])),
            ("random spectrum: strictly outside",
             normalise(rng.exponential(size=7), rng.normal(size=7)))]
    fig, axes = plt.subplots(2, 4, figsize=(12.4, 6.6), dpi=150)
    for r, (name, (p, e)) in enumerate(rows):
        for c, t in enumerate(ts):
            panel(axes[r, c], p, e, t)
            if r == 0:
                lab = "π/2" if c == 3 else f"{t:.1f}"
                axes[r, c].set_title(f"ΔE·t = {lab}", fontsize=11.5, color=INK)
        axes[r, 0].text(-1.3, 0, name, rotation=90, va="center", ha="center", fontsize=10.5,
                        color=INK2)
    fig.suptitle("Mandelstam–Tamm: the tip of A(t) never enters the disc of radius cos(ΔE·t)",
                 x=0.01, ha="left", fontsize=13, color=INK)
    fig.text(0.01, 0.01, "grey: the arrows p_k e^(−iE_k t), tip to tail; blue: their sum A(t); "
             "orange: the forbidden disc (Lean: cos_le_norm_amplitude). Interactive: "
             "docs/index.html", fontsize=8.8, color=MUTED)
    fig.tight_layout(rect=(0.02, 0.03, 1, 0.95))
    fig.savefig(OUT / "mandelstam_tamm_phasors.png", facecolor=SURFACE)
    plt.close(fig)


if __name__ == "__main__":
    fig_phasors()
