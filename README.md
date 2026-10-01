# NRS³ · Mandelstam–Tamm and Cramér–Rao

Two faces of one inequality, in Lean 4. **No quantum state becomes orthogonal to itself before
`πħ / (2ΔE)`** (Mandelstam–Tamm, sharp constant), and **no measurement extracts more information
about a phase than `4 Var H`** (quantum Cramér–Rao). Both come from Robertson's inequality with the
energy spread `ΔE`: one bounds how fast a state moves, the other how well that motion can be read.

**[▶ Try it: move the time and watch the phasors](https://naype888-cloud.github.io/nrs3-mandelstam-tamm-cramer-rao/)** ·
**[▶ Try it: turn the phase and watch δT and δP](https://naype888-cloud.github.io/nrs3-mandelstam-tamm-cramer-rao/cramer-rao.html)**

![NRS³ · Mandelstam–Tamm](docs/figures/mandelstam_tamm_sharp.png)

## Mandelstam–Tamm

| Statement | Lean |
|---|---|
| `‖A(t)‖ ≥ cos(ΔE t)` while `ΔE t ≤ π/2`, for every finite spectrum | `cos_le_norm_amplitude` |
| orthogonality forces `ΔE t ≥ π/2` | `orthogonality_time` |
| two equal branches meet it with equality: `π/2` is sharp | `norm_amplitude_half_eq_cos` |
| on `H_d = ℂ^d`: the Schrödinger evolution of a self-adjoint `H` has exactly this amplitude | `hasDerivAt_evolve`, `inner_evolve` |
| the bound on `ℂ^d` | `cos_le_norm_inner_evolve` |

`A(t) = ⟨ψ, e^{−iHt/ħ}ψ⟩` is the survival amplitude and `ΔE` the energy spread. It is the sum of
the arrows `p_k e^{−iE_k t}`; its tip never enters the disc of radius `cos(ΔE t)`:

![Phasors](docs/figures/mandelstam_tamm_phasors.png)

### In NRS³

On the NRS³ pair `T_d : P_d` the same inequality bounds the speed of `⟨P_d⟩` by the spread of
transport, and at the maximal-tension state the ratio is `1 / C_Nava(d)²`: equality only at
`d = 2, 3` (`GroupVelocity.mandelstamTamm`, `GroupVelocity.mtRatio_psiStar`, `D41` in the base
repository). Right panel of the figure; the values there are numerical.

### History

Mandelstam and Tamm (1945) derived the bound from Robertson's inequality for the energy and the
projector on the initial state. The proof here follows that route: `P = ‖A‖²` obeys
`P' ≥ −2ΔE √(P(1 − P))`, and a fencing argument against `cos²` gives the sharp constant.

## Cramér–Rao

![NRS³ · Cramér–Rao](docs/figures/cramer_rao_nrs3.png)

| Statement | Lean |
|---|---|
| `⟪δA, δB⟫ − ⟪δB, δA⟫ = ⟨[A, B]⟩` | `inner_dev_sub` |
| Robertson: `‖⟨[A, B]⟩‖² ≤ 4 Var A · Var B` | `robertson` |
| Cramér–Rao: `F_X = ‖⟨[H, X]⟩‖² / Var X ≤ F_Q = 4 Var H` | `fisher_le_qfi` |

For symmetric operators on any complex inner product space, in particular `ℂ^d`. `F_X` is the
error-propagation Fisher information of reading `θ` with `X` after `e^{−iθH}`; `F_Q = 4 Var H` is
the quantum Fisher information of a pure state, taken here as its definition.

### In NRS³

On NRS³ the parameter is imprinted by transport `T_d` and read with position `P_d`. At the
maximal-tension state the efficiency `F_P / F_Q` is `1 / C_Nava(d)²`: exactly `1` at `d = 2, 3`
and strictly below from `d = 4` on, towards `1/(π²/3 − 2) ≈ 0.775` (`GroupVelocity.cramerRao`,
`GroupVelocity.mtRatio_psiStar`, `D41` in the base repository). At `d = 4` it is
`5 / (99 − 42√5) ≈ 0.9833`.

### History

Helstrom (1967) and Braunstein–Caves (1994). The identity `d⟨X⟩/dθ = ⟨i[H, X]⟩` that turns
Robertson into an estimation bound is the Heisenberg equation; on `T_d : P_d` it is `D38` of the
base repository, and it is not re-proved here.

## Build

Lean 4 `v4.34.0`, Mathlib `v4.34.0`, nothing else.

```bash
lake exe cache get
lake build
lake env lean Verification/Axioms.lean   # only propext, Classical.choice, Quot.sound
```

Every file: no `sorry`, lines of at most 100 characters, English headers.

## The mosaic

- [NRS and NRS³ — the base theorem](https://github.com/naype888-cloud/nava-robertson-schrodinger)
- **[NRS³ · Mandelstam–Tamm and Cramér–Rao](https://github.com/naype888-cloud/nrs3-mandelstam-tamm-cramer-rao)** (this one)
- [NRS³ · Penrose](https://github.com/naype888-cloud/nrs3-penrose)
- [NRS³ · Pauli–Dirac](https://github.com/naype888-cloud/nrs3-pauli-dirac)
- [NRS³ · Poincaré](https://github.com/naype888-cloud/nrs3-poincare)
- [NRS³ · Defect and curvature](https://github.com/naype888-cloud/nrs3-defect-curvature)

## License

NRS Noncommercial License 1.0.0, see [`LICENSE`](LICENSE). Author: Eduardo Nava-Hernandez.
