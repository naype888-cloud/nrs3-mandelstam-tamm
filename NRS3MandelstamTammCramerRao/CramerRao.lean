/-
Copyright (c) 2026 Eduardo Nava-Hernandez. All rights reserved.
Released under the NRS Noncommercial License 1.0.0 as described in the file LICENSE.
Authors: Eduardo Nava-Hernandez
-/
module

public import Mathlib.Analysis.InnerProductSpace.Symmetric

/-!
# The quantum Cramér–Rao bound for pure states

A pure state `ψ` imprinted with a parameter `θ` by `e^{−iθH}` is estimated through an observable
`X`. Error propagation gives the Fisher information `F_X = |⟨[H, X]⟩|² / Var X`, since
`d⟨X⟩/dθ = ⟨i[H, X]⟩`; the quantum Fisher information of a pure state is `F_Q = 4 Var H`.
Robertson's inequality `|⟨[H, X]⟩|² ≤ 4 Var H · Var X` is exactly `F_X ≤ F_Q`.

Everything holds for symmetric operators on any complex inner product space, in particular on
`H_d = ℂ^d`. On the path pair `T_d : P_d` of NRS³ the ratio `F_X / F_Q` at the maximal-tension
state is `1 / C_Nava(d)²`, equal to `1` only at `d = 2, 3` (`GroupVelocity.cramerRao`,
`GroupVelocity.mtRatio_psiStar`, repository `nava-robertson-schrodinger`, `D41`).

## Main results

- `CramerRao.inner_dev_sub` : `⟪δA, δB⟫ − ⟪δB, δA⟫ = ⟨[A, B]⟩` for the deviations `δA = (A − ⟨A⟩)ψ`.
- `CramerRao.robertson` : `‖⟨[A, B]⟩‖² ≤ 4 Var A · Var B`.
- `CramerRao.fisher_le_qfi` : the quantum Cramér–Rao bound `F_X ≤ F_Q`.
-/

@[expose] public noncomputable section

namespace CramerRao

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

/-- The expectation `⟨A⟩ = Re ⟪ψ, Aψ⟫`. -/
def expect (A : E →ₗ[ℂ] E) (ψ : E) : ℝ := (inner ℂ ψ (A ψ)).re

/-- The deviation `δA = (A − ⟨A⟩) ψ`. -/
def dev (A : E →ₗ[ℂ] E) (ψ : E) : E := A ψ - (expect A ψ : ℂ) • ψ

/-- The variance `Var A = ‖δA‖²`. -/
def var (A : E →ₗ[ℂ] E) (ψ : E) : ℝ := ‖dev A ψ‖ ^ 2

/-- The commutator expectation `⟨[A, B]⟩ = ⟪ψ, ABψ⟫ − ⟪ψ, BAψ⟫`. -/
def commExpect (A B : E →ₗ[ℂ] E) (ψ : E) : ℂ := inner ℂ ψ (A (B ψ)) - inner ℂ ψ (B (A ψ))

variable {A B : E →ₗ[ℂ] E} {ψ : E}

theorem inner_self_map (hA : A.IsSymmetric) (ψ : E) : inner ℂ ψ (A ψ) = (expect A ψ : ℂ) := by
  have h : (starRingEnd ℂ) (inner ℂ ψ (A ψ)) = inner ℂ ψ (A ψ) := by
    rw [inner_conj_symm, hA]
  exact (Complex.conj_eq_iff_re.mp h).symm

theorem inner_dev_sub (hA : A.IsSymmetric) (hB : B.IsSymmetric) (hψ : ‖ψ‖ = 1) :
    inner ℂ (dev A ψ) (dev B ψ) - inner ℂ (dev B ψ) (dev A ψ) = commExpect A B ψ := by
  have h1 : inner ℂ ψ ψ = (1 : ℂ) := by rw [inner_self_eq_norm_sq_to_K, hψ]; simp
  have hA' : inner ℂ (A ψ) ψ = (expect A ψ : ℂ) := by rw [hA, inner_self_map hA]
  have hB' : inner ℂ (B ψ) ψ = (expect B ψ : ℂ) := by rw [hB, inner_self_map hB]
  simp only [dev, commExpect, inner_sub_left, inner_sub_right, inner_smul_left,
    inner_smul_right, Complex.conj_ofReal, h1, hA', hB', inner_self_map hA, inner_self_map hB,
    hA ψ (B ψ), hB ψ (A ψ)]
  ring

/-- **Robertson**: `‖⟨[A, B]⟩‖² ≤ 4 Var A · Var B`. -/
theorem robertson (hA : A.IsSymmetric) (hB : B.IsSymmetric) (hψ : ‖ψ‖ = 1) :
    ‖commExpect A B ψ‖ ^ 2 ≤ 4 * var A ψ * var B ψ := by
  set z := inner ℂ (dev A ψ) (dev B ψ)
  have hz : ‖commExpect A B ψ‖ ≤ 2 * (‖dev A ψ‖ * ‖dev B ψ‖) := by
    rw [← inner_dev_sub hA hB hψ, ← inner_conj_symm (dev B ψ) (dev A ψ)]
    calc ‖z - (starRingEnd ℂ) z‖ ≤ ‖z‖ + ‖(starRingEnd ℂ) z‖ := norm_sub_le _ _
      _ = 2 * ‖z‖ := by rw [Complex.norm_conj]; ring
      _ ≤ 2 * (‖dev A ψ‖ * ‖dev B ψ‖) := by gcongr; exact norm_inner_le_norm _ _
  have h0 := norm_nonneg (commExpect A B ψ)
  calc ‖commExpect A B ψ‖ ^ 2 ≤ (2 * (‖dev A ψ‖ * ‖dev B ψ‖)) ^ 2 := by gcongr
    _ = 4 * var A ψ * var B ψ := by rw [var, var]; ring

/-- The error-propagation Fisher information `F_X = ‖⟨[H, X]⟩‖² / Var X`. -/
def fisher (H X : E →ₗ[ℂ] E) (ψ : E) : ℝ := ‖commExpect H X ψ‖ ^ 2 / var X ψ

/-- The quantum Fisher information of a pure state, `F_Q = 4 Var H`. -/
def qfi (H : E →ₗ[ℂ] E) (ψ : E) : ℝ := 4 * var H ψ

/-- **The quantum Cramér–Rao bound**: `F_X ≤ F_Q`. -/
theorem fisher_le_qfi {H X : E →ₗ[ℂ] E} (hH : H.IsSymmetric) (hX : X.IsSymmetric)
    (hψ : ‖ψ‖ = 1) : fisher H X ψ ≤ qfi H ψ := by
  rcases (sq_nonneg ‖dev X ψ‖).eq_or_lt with h | h
  · rw [fisher, var, ← h, div_zero, qfi, var]; positivity
  · rw [fisher, div_le_iff₀ (by rwa [var]), qfi]
    exact robertson hH hX hψ

end CramerRao
