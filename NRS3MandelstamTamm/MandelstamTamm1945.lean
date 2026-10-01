/-
Copyright (c) 2026 Eduardo Nava-Hernandez. All rights reserved.
Released under the NRS Noncommercial License 1.0.0 as described in the file LICENSE.
Authors: Eduardo Nava-Hernandez
-/
module

public import Mathlib.Analysis.InnerProductSpace.Calculus
public import Mathlib.Analysis.Calculus.MeanValue
public import Mathlib.Analysis.SpecialFunctions.Trigonometric.Deriv
public import Mathlib.Analysis.SpecialFunctions.ExpDeriv
public import Mathlib.Analysis.SpecialFunctions.Complex.Circle
public import Mathlib.Analysis.MeanInequalities
public import Mathlib.Analysis.InnerProductSpace.Spectrum

/-!
# Mandelstam–Tamm 1945 — the quantum speed limit with its sharp constant `π/2`

For weights `p_k` on energies `E_k` (the spectral form of a finite-dimensional state, `ħ = 1`),
the survival amplitude is `A(t) = ∑ p_k e^{−i E_k t}` and the energy spread is
`ΔE = √(∑ p_k (E_k − ⟨E⟩)²)`. Mandelstam and Tamm: `‖A(t)‖ ≥ cos (ΔE t)` while
`ΔE t ≤ π/2`, so no state becomes orthogonal before `π / (2 ΔE)`.

The probability `P = ‖A‖²` obeys `P' ≥ −2 ΔE √(P (1 − P))`, Robertson's inequality for the
energy and the projector on the initial state written as one weighted Cauchy–Schwarz. Fencing
`P` from below by `cos² ((ΔE + η)(t + η))` and letting `η → 0⁺` gives the bound. Two equal
branches attain it (`Penrose1996.twoBranch_orthogonal`), so `π/2` is sharp.

## Main results

- `MandelstamTamm1945.neg_le_inner_deriv` : `⟪A, A'⟫ ≥ −ΔE ‖A‖ √(1 − ‖A‖²)`.
- `MandelstamTamm1945.cos_le_norm_amplitude` : `cos (ΔE t) ≤ ‖A(t)‖` for `0 ≤ ΔE t ≤ π/2`.
- `MandelstamTamm1945.orthogonality_time` : `A(t) = 0` with `t ≥ 0` forces `π/2 ≤ ΔE t`.
- `MandelstamTamm1945.hasDerivAt_evolve`, `inner_evolve` : on `H_d = ℂ^d`, the Schrödinger
  evolution of a self-adjoint `H` has exactly this amplitude, `p_k = ‖⟨v_k, ψ⟩‖²`.
- `MandelstamTamm1945.cos_le_norm_inner_evolve` : the bound on `ℂ^d`.
-/

@[expose] public noncomputable section

namespace MandelstamTamm1945

open Real Filter Topology Set

variable {n : ℕ} (p E : Fin n → ℝ)

/-- The phase `e^{−i E_k t}`. -/
def phase (k : Fin n) (t : ℝ) : ℂ := Complex.exp (↑(-(E k * t)) * Complex.I)

/-- The survival amplitude `A(t) = ∑ p_k e^{−i E_k t}`. -/
def amplitude (t : ℝ) : ℂ := ∑ k, p k • phase E k t

/-- The mean energy `⟨E⟩`. -/
def mean : ℝ := ∑ k, p k * E k

/-- The energy spread `ΔE = √(∑ p_k (E_k − ⟨E⟩)²)`. -/
def spread : ℝ := √(∑ k, p k * (E k - mean p E) ^ 2)

/-- The derivative `A'(t) = ∑ p_k (−i E_k) e^{−i E_k t}`. -/
def amplitude' (t : ℝ) : ℂ := ∑ k, p k • (phase E k t * (↑(-E k) * Complex.I))

theorem norm_phase (k : Fin n) (t : ℝ) : ‖phase E k t‖ = 1 := Complex.norm_exp_ofReal_mul_I _

theorem hasDerivAt_phase (k : Fin n) (t : ℝ) :
    HasDerivAt (phase E k) (phase E k t * (↑(-E k) * Complex.I)) t := by
  have h := ((((hasDerivAt_id t).const_mul (E k)).neg.ofReal_comp).mul_const Complex.I).cexp
  convert h using 1
  · funext s; simp [phase]
  · simp [phase]

theorem hasDerivAt_amplitude (t : ℝ) : HasDerivAt (amplitude p E) (amplitude' p E t) t :=
  HasDerivAt.fun_sum fun k _ => (hasDerivAt_phase E k t).const_smul (p k)

variable {p E}

/-- **Robertson for the energy and the initial projector**, in spectral form. -/
theorem neg_le_inner_deriv (hp : ∀ k, 0 ≤ p k) (h1 : ∑ k, p k = 1) (t : ℝ) :
    -(spread p E * (‖amplitude p E t‖ * √(1 - ‖amplitude p E t‖ ^ 2)))
      ≤ inner ℝ (amplitude p E t) (amplitude' p E t) := by
  set A := amplitude p E t
  set m := mean p E
  set e := fun k => phase E k t
  set X := ∑ k, p k • ((e k - A) * (↑(-(E k - m)) * Complex.I))
  have hc : ∑ k, p k * (E k - m) = 0 := by
    simp only [mul_sub, Finset.sum_sub_distrib, ← Finset.sum_mul, h1, one_mul, m, mean]; ring
  have hsplit : amplitude' p E t = X + A * (↑(-m) * Complex.I) := by
    have h0 : ∑ k, p k • (A * (↑(-(E k - m)) * Complex.I)) = 0 := by
      have : ∑ k, p k • (A * (↑(-(E k - m)) * Complex.I))
          = -(A * Complex.I) * ↑(∑ k, p k * (E k - m)) := by
        rw [Complex.ofReal_sum, Finset.mul_sum]
        exact Finset.sum_congr rfl fun k _ => by rw [Complex.real_smul]; push_cast; ring
      rw [this, hc]; simp
    have hm : A * (↑(-m) * Complex.I) = ∑ k, p k • (e k * (↑(-m) * Complex.I)) := by
      simp_rw [A, amplitude, Finset.sum_mul, smul_mul_assoc]; rfl
    have hs : amplitude' p E t = X + ∑ k, p k • (A * (↑(-(E k - m)) * Complex.I))
        + ∑ k, p k • (e k * (↑(-m) * Complex.I)) := by
      simp only [amplitude', X, ← Finset.sum_add_distrib]
      exact Finset.sum_congr rfl fun k _ => by simp only [Complex.real_smul, e]; push_cast; ring
    rw [hs, h0, add_zero, ← hm]
  have hperp : inner ℝ A (A * (↑(-m) * Complex.I)) = 0 := by
    rw [Complex.inner]
    simp only [Complex.mul_re, Complex.mul_im, Complex.conj_re, Complex.conj_im,
      Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    ring
  have hsq : ∑ k, p k * ‖e k - A‖ ^ 2 = 1 - ‖A‖ ^ 2 := by
    have hn (k : Fin n) : ‖e k - A‖ ^ 2 = 1 - 2 * inner ℝ (e k) A + ‖A‖ ^ 2 := by
      rw [norm_sub_sq_real, show ‖e k‖ = 1 from norm_phase E k t, one_pow]
    have hi : ∑ k, p k * inner ℝ (e k) A = ‖A‖ ^ 2 := by
      rw [← real_inner_self_eq_norm_sq]
      simp_rw [← real_inner_smul_left, ← sum_inner]
      rfl
    simp_rw [hn, mul_add, mul_sub, Finset.sum_add_distrib, Finset.sum_sub_distrib, mul_one,
      ← Finset.sum_mul, h1, mul_left_comm _ (2 : ℝ), ← Finset.mul_sum, hi]
    ring
  have hX : ‖X‖ ≤ spread p E * √(1 - ‖A‖ ^ 2) := by
    calc ‖X‖ ≤ ∑ k, (√(p k) * |E k - m|) * (√(p k) * ‖e k - A‖) := by
          refine (norm_sum_le _ _).trans (Finset.sum_le_sum fun k _ => ?_)
          rw [norm_smul, norm_mul, norm_mul, Complex.norm_I, mul_one, Complex.norm_real,
            Real.norm_of_nonneg (hp k), Real.norm_eq_abs, abs_neg]
          rw [mul_mul_mul_comm, Real.mul_self_sqrt (hp k), mul_comm |E k - m|]
      _ ≤ √(∑ k, (√(p k) * |E k - m|) ^ 2) * √(∑ k, (√(p k) * ‖e k - A‖) ^ 2) :=
          Real.sum_mul_le_sqrt_mul_sqrt _ _ _
      _ = spread p E * √(1 - ‖A‖ ^ 2) := by
          simp_rw [mul_pow, Real.sq_sqrt (hp _), sq_abs, hsq]; rfl
  rw [hsplit, inner_add_right, hperp, add_zero]
  calc -(spread p E * (‖A‖ * √(1 - ‖A‖ ^ 2))) ≤ -(‖A‖ * ‖X‖) := by
        nlinarith [norm_nonneg A]
    _ ≤ inner ℝ A X := neg_le_of_abs_le (abs_real_inner_le_norm A X)

/-- **Mandelstam–Tamm**: `cos (ΔE t) ≤ ‖A(t)‖` for `0 ≤ t` and `ΔE t ≤ π/2`. -/
theorem cos_le_norm_amplitude (hp : ∀ k, 0 ≤ p k) (h1 : ∑ k, p k = 1) {t : ℝ} (ht0 : 0 ≤ t)
    (ht : spread p E * t ≤ π / 2) : cos (spread p E * t) ≤ ‖amplitude p E t‖ := by
  set σ := spread p E with hσdef
  have hσ : 0 ≤ σ := Real.sqrt_nonneg _
  rcases ht.eq_or_lt with he | ht
  · rw [he, cos_pi_div_two]; exact norm_nonneg _
  set P := fun s => ‖amplitude p E s‖ ^ 2
  have hP (s : ℝ) : HasDerivAt P (2 * inner ℝ (amplitude p E s) (amplitude' p E s)) s :=
    (hasDerivAt_amplitude p E s).norm_sq
  have hP0 : P 0 = 1 := by
    simp only [P, amplitude, phase, mul_zero, neg_zero, Complex.ofReal_zero, zero_mul,
      Complex.exp_zero, ← Finset.sum_smul, h1, one_smul, norm_one, one_pow]
  -- the fence `cos² ((σ + η)(s + η)) ≤ P s` while `(σ + η)(s + η) < π/2`
  have fence (η : ℝ) (hη : 0 < η) (s : ℝ) (hs0 : 0 ≤ s) (hs : (σ + η) * (s + η) < π / 2) :
      cos ((σ + η) * (s + η)) ^ 2 ≤ P s := by
    have hc (x : ℝ) : HasDerivAt (fun x => cos ((σ + η) * (x + η)) ^ 2)
        (2 * cos ((σ + η) * (x + η)) * (-sin ((σ + η) * (x + η)) * (σ + η))) x := by
      have h := (((hasDerivAt_id x).add_const η).const_mul (σ + η)).cos
      convert h.mul h using 1
      · funext y; simp [sq]
      · simp; ring
    refine image_le_of_deriv_right_lt_deriv_boundary (a := 0) (b := s)
      (fun x _ => (hc x).continuousAt.continuousWithinAt) (fun x _ => (hc x).hasDerivWithinAt)
      (by rw [hP0]; exact cos_sq_le_one _) hP ?_ ⟨hs0, le_rfl⟩
    rintro x ⟨hx0, hxs⟩ hx
    set θ := (σ + η) * (x + η)
    have hθ0 : 0 < θ := by positivity
    have hθ : θ < π / 2 :=
      lt_of_le_of_lt (mul_le_mul_of_nonneg_left (by linarith) (by positivity)) hs
    have hcos : 0 < cos θ := cos_pos_of_mem_Ioo ⟨by linarith, hθ⟩
    have hsin : 0 < sin θ := sin_pos_of_pos_of_lt_pi hθ0 (by linarith)
    have hA : ‖amplitude p E x‖ = cos θ := by
      have := congrArg Real.sqrt hx
      rwa [Real.sqrt_sq hcos.le, Real.sqrt_sq (norm_nonneg _), eq_comm] at this
    have h1A : √(1 - ‖amplitude p E x‖ ^ 2) = sin θ := by
      rw [hA, ← sin_sq, Real.sqrt_sq hsin.le]
    have := neg_le_inner_deriv (E := E) hp h1 x
    rw [h1A, hA, ← hσdef] at this
    nlinarith [mul_pos hcos hsin]
  have hcont : Continuous fun η : ℝ => (σ + η) * (t + η) := by fun_prop
  have hev : ∀ᶠ η in 𝓝[>] (0 : ℝ), cos ((σ + η) * (t + η)) ^ 2 ≤ P t := by
    have h := (hcont.tendsto 0).eventually (gt_mem_nhds (by simpa using ht))
    filter_upwards [nhdsWithin_le_nhds h, self_mem_nhdsWithin] with η hη (hη0 : 0 < η)
    exact fence η hη0 t ht0 hη
  have hlim : Tendsto (fun η : ℝ => cos ((σ + η) * (t + η)) ^ 2) (𝓝[>] 0)
      (𝓝 (cos (σ * t) ^ 2)) := by
    have : Continuous fun η : ℝ => cos ((σ + η) * (t + η)) ^ 2 := by fun_prop
    simpa using (this.tendsto 0).mono_left nhdsWithin_le_nhds
  have hsq := le_of_tendsto hlim hev
  exact (abs_le_of_sq_le_sq' hsq (norm_nonneg _)).2

/-- **The orthogonality time**: `A(t) = 0` with `t ≥ 0` forces `π/2 ≤ ΔE t`. -/
theorem orthogonality_time (hp : ∀ k, 0 ≤ p k) (h1 : ∑ k, p k = 1) {t : ℝ} (ht0 : 0 ≤ t)
    (h0 : amplitude p E t = 0) : π / 2 ≤ spread p E * t := by
  by_contra h
  replace h := not_le.mp h
  have := cos_le_norm_amplitude hp h1 ht0 h.le
  rw [h0, norm_zero] at this
  have hnn : 0 ≤ spread p E * t := mul_nonneg (Real.sqrt_nonneg _) ht0
  have : 0 < cos (spread p E * t) := cos_pos_of_mem_Ioo ⟨by linarith [pi_pos], h⟩
  linarith

/-! ## On `H_d = ℂ^d` -/

section Hilbert

variable {d : ℕ} {H : EuclideanSpace ℂ (Fin d) →ₗ[ℂ] EuclideanSpace ℂ (Fin d)}
  (hH : H.IsSymmetric)

/-- The eigenbasis `v_k` of `H`. -/
abbrev basis := hH.eigenvectorBasis finrank_euclideanSpace_fin

/-- The eigenvalues `E_k` of `H`. -/
abbrev energy := hH.eigenvalues finrank_euclideanSpace_fin

/-- The Schrödinger evolution `ψ(t) = ∑ e^{−i E_k t} ⟨v_k, ψ⟩ v_k`. -/
def evolve (ψ : EuclideanSpace ℂ (Fin d)) (t : ℝ) : EuclideanSpace ℂ (Fin d) :=
  ∑ k, (phase (energy hH) k t * inner ℂ (basis hH k) ψ) • basis hH k

/-- `ψ(t)` solves `i ψ' = H ψ`. -/
theorem hasDerivAt_evolve (ψ : EuclideanSpace ℂ (Fin d)) (t : ℝ) :
    HasDerivAt (evolve hH ψ) (-Complex.I • H (evolve hH ψ t)) t := by
  have h := HasDerivAt.fun_sum fun k (_ : k ∈ Finset.univ) =>
    ((hasDerivAt_phase (energy hH) k t).mul_const (inner ℂ (basis hH k) ψ)).smul_const
      (basis hH k)
  convert h using 1
  · rfl
  simp only [evolve, map_sum, map_smul, hH.apply_eigenvectorBasis, Finset.smul_sum, smul_smul]
  exact Finset.sum_congr rfl fun k _ => by congr 1; push_cast; ring_nf; rfl

/-- The survival amplitude `⟨ψ, ψ(t)⟩` has weights `p_k = ‖⟨v_k, ψ⟩‖²` on the `E_k`. -/
theorem inner_evolve (ψ : EuclideanSpace ℂ (Fin d)) (t : ℝ) :
    inner ℂ ψ (evolve hH ψ t)
      = amplitude (fun k => ‖inner ℂ (basis hH k) ψ‖ ^ 2) (energy hH) t := by
  simp only [evolve, amplitude, inner_sum, inner_smul_right, Complex.real_smul]
  refine Finset.sum_congr rfl fun k _ => ?_
  rw [← inner_conj_symm, mul_assoc, Complex.conj_mul', mul_comm, Complex.norm_conj]
  push_cast; ring

theorem sum_weights {ψ : EuclideanSpace ℂ (Fin d)} (hψ : ‖ψ‖ = 1) :
    ∑ k, ‖inner ℂ (basis hH k) ψ‖ ^ 2 = 1 := by
  rw [(basis hH).sum_sq_norm_inner_right, hψ, one_pow]

/-- **Mandelstam–Tamm on `ℂ^d`**: `cos (ΔE t) ≤ ‖⟨ψ, ψ(t)⟩‖` for `0 ≤ ΔE t ≤ π/2`. -/
theorem cos_le_norm_inner_evolve {ψ : EuclideanSpace ℂ (Fin d)} (hψ : ‖ψ‖ = 1) {t : ℝ}
    (ht0 : 0 ≤ t)
    (ht : spread (fun k => ‖inner ℂ (basis hH k) ψ‖ ^ 2) (energy hH) * t ≤ π / 2) :
    cos (spread (fun k => ‖inner ℂ (basis hH k) ψ‖ ^ 2) (energy hH) * t)
      ≤ ‖inner ℂ ψ (evolve hH ψ t)‖ := by
  rw [inner_evolve]
  exact cos_le_norm_amplitude (fun _ => sq_nonneg _) (sum_weights hH hψ) ht0 ht

end Hilbert

end MandelstamTamm1945
