import HeadComplexity.Results.ThresholdDegree
import HeadComplexity.Extensions.SymmetricMaximal

set_option linter.style.header false

/-!
# Fork extension: threshold degree of symmetric functions (EXT-005, closes ARCH-006).

Paper Theorem 5 (arXiv:2610.25341) states, for a symmetric Boolean function `f`
with Hamming-weight profile `F`,

  `H*(f) = deg±(f) = C(F)`.

Upstream proves `H*(f) = C(F)` as `HStar_symmetricFn` (Lean "Theorem 12"). This
file adds the remaining equality `deg±(f) = C(F)`, `thresholdDeg_symmetricFn`, and
packages the three-way statement as `HStar_thresholdDeg_signChanges_symmetricFn`.

The proof generalizes upstream `thresholdDeg_parity` from the parity profile to an
arbitrary profile, using only upstream lemmas:

* upper bound: `symmetricFn_computable` (a `C(F)`-head computation) and
  `signReprDegLe_of_computableWithHeadsN` (heads give a sign-representing
  polynomial of the same degree bound), then `Nat.find_min'`;
* lower bound: `Nat.find_spec` and `signChanges_le_of_ThresholdDegLE`
  (the Aspnes et al. direction, via symmetrization and univariate root counting).

No upstream definition or proof is changed.
-/

namespace HeadComplexity.Ext

/-- Every symmetric function has a sign-representing polynomial of degree at most
its profile's sign-change count. -/
theorem ThresholdDegLE_symmetricFn (n : ℕ) (F : ℕ → Bool) :
    ThresholdDegLE (n := n) (symmetricFn F) (signChanges n F) :=
  signReprDegLe_of_computableWithHeadsN (symmetricFn_computable F n)

/-- **EXT-005 (paper Theorem 5, middle equality).** The threshold degree of a
symmetric Boolean function equals the number of sign changes of its profile:
`deg±(f) = C(F)`. Holds for every `n`, including `n = 0`. -/
theorem thresholdDeg_symmetricFn (n : ℕ) (F : ℕ → Bool) :
    thresholdDeg (n := n) (symmetricFn F) = signChanges n F := by
  classical
  have hex : ∃ d, ThresholdDegLE (n := n) (symmetricFn F) d :=
    ⟨_, ThresholdDegLE_symmetricFn n F⟩
  rw [thresholdDeg, dif_pos hex]
  exact le_antisymm (Nat.find_min' hex (ThresholdDegLE_symmetricFn n F))
    (signChanges_le_of_ThresholdDegLE (Nat.find_spec hex))

/-- **EXT-005 (head form).** For symmetric functions, head complexity equals
threshold degree. -/
theorem HStar_eq_thresholdDeg_symmetricFn (n : ℕ) (F : ℕ → Bool) :
    HStar n (symmetricFn F) = thresholdDeg (n := n) (symmetricFn F) := by
  rw [HStar_symmetricFn, thresholdDeg_symmetricFn]

/-- **EXT-005 (paper Theorem 5, full statement).**
`H*(f) = deg±(f) = C(F)` for every symmetric Boolean function `f = symmetricFn F`. -/
theorem HStar_thresholdDeg_signChanges_symmetricFn (n : ℕ) (F : ℕ → Bool) :
    HStar n (symmetricFn F) = thresholdDeg (n := n) (symmetricFn F) ∧
      thresholdDeg (n := n) (symmetricFn F) = signChanges n F :=
  ⟨HStar_eq_thresholdDeg_symmetricFn n F, thresholdDeg_symmetricFn n F⟩

/-! ## Required cases, as corollaries -/

/-- `n = 0`: every symmetric function on the zero-bit cube has threshold degree `0`. -/
theorem thresholdDeg_symmetricFn_zero (F : ℕ → Bool) :
    thresholdDeg (n := 0) (symmetricFn F) = 0 := by
  rw [thresholdDeg_symmetricFn, signChanges_zero]

/-- On one bit the sign-change count is `1` exactly when the two profile values differ. -/
theorem signChanges_one (F : ℕ → Bool) :
    signChanges 1 F = if F 0 = F 1 then 0 else 1 := by
  unfold signChanges
  by_cases h : F 0 = F 1 <;> simp [Finset.range_one, Finset.filter_singleton, h]

/-- `n = 1`: a symmetric function of one bit has threshold degree `0` if constant
and `1` otherwise. -/
theorem thresholdDeg_symmetricFn_one (F : ℕ → Bool) :
    thresholdDeg (n := 1) (symmetricFn F) = if F 0 = F 1 then 0 else 1 := by
  rw [thresholdDeg_symmetricFn, signChanges_one]

/-- Constant symmetric functions have threshold degree `0`, for every `n`. -/
theorem thresholdDeg_symmetricFn_const (n : ℕ) (b : Bool) :
    thresholdDeg (n := n) (symmetricFn fun _ => b) = 0 := by
  rw [thresholdDeg_symmetricFn]
  unfold signChanges
  simp

/-- Parity has threshold degree `n`, recovered as a corollary of EXT-005
(upstream proves the same fact directly as `thresholdDeg_parity`). -/
theorem thresholdDeg_parity_of_symmetricFn (n : ℕ) : thresholdDeg (PARITY n) = n := by
  rw [PARITY_eq_symmetricFn, thresholdDeg_symmetricFn, signChanges_parity]

/-- The complement of parity has threshold degree `n`. -/
theorem thresholdDeg_not_parity (n : ℕ) :
    thresholdDeg (fun bits : Fin n → Bool => !PARITY n bits) = n := by
  rw [PARITY_eq_symmetricFn, not_symmetricFn, thresholdDeg_symmetricFn, signChanges_not,
    signChanges_parity]

end HeadComplexity.Ext
