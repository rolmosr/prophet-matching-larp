import Std

/-! Finite upper-bound witness for independent edge weights, adversarial edge
order, and the expected offline optimum. Standalone Lean 4, no mathlib.
All expectations are scaled by the number of equiprobable elementary outcomes.
Weights and counts are naturals, so no floating-point arithmetic is involved. -/
namespace ProphetMatching

structure Edge where
  u : Nat
  v : Nat
  w : Nat
  hit : Nat
  miss : Nat
  deriving DecidableEq

abbrev Used := List Nat

def free (e : Edge) (s : Used) : Bool :=
  !(s.contains e.u || s.contains e.v)

def occupy (e : Edge) (s : Used) : Used := e.u :: e.v :: s

def mass : List Edge → Nat
  | [] => 1
  | e :: es => (e.hit + e.miss) * mass es

-- hit/(hit+miss) is the probability of w; otherwise the weight is zero.
-- A fixed policy can distinguish the two draws, even if both have value zero.
-- It sees only the prefix (encoded in reverse chronological order).
abbrev Policy := List Bool → Bool

def payoff (π : Policy) : List Edge → Used → List Bool → Nat
  | [], _, _ => 0
  | e :: es, s, h =>
    let branch := fun (b : Bool) (w : Nat) =>
      if free e s && π (b :: h) then
        w * mass es + payoff π es (occupy e s) (b :: h)
      else payoff π es s (b :: h)
    e.hit * branch true e.w + e.miss * branch false 0

-- Online Bellman recurrence: choose after this draw and before future draws.
def bellman : List Edge → Used → Nat
  | [], _ => 0
  | e :: es, s =>
    let skip := bellman es s
    let branch := fun w =>
      if free e s then max skip (w * mass es + bellman es (occupy e s))
      else skip
    e.hit * branch e.w + e.miss * branch 0

theorem policy_le (π : Policy) (es : List Edge) (s : Used) (h : List Bool) :
    payoff π es s h ≤ bellman es s := by
  induction es generalizing s h with
  | nil => exact Nat.le_refl _
  | cons e es ih =>
    simp only [payoff, bellman]
    apply Nat.add_le_add <;> apply Nat.mul_le_mul_left
    all_goals
      cases free e s <;> simp
      all_goals first
        | exact ih _ _
        | split
          · apply Nat.le_trans _ (Nat.le_max_right _ _)
            first | exact Nat.add_le_add_left (ih _ _) _ | exact ih _ _
          · exact Nat.le_trans (ih _ _) (Nat.le_max_left _ _)

-- Maximum feasible weight AFTER a complete realization: by considering
-- skip/take and occupying BOTH endpoints when taking an edge.
def maxMatching : List Edge → Used → Nat
  | [], _ => 0
  | e :: es, s =>
    let skip := maxMatching es s
    if free e s then max skip (e.w + maxMatching es (occupy e s)) else skip

-- Product expectation over independent draws. At each leaf all weights are
-- known. Enumerating matchings in reverse edge order yields the same maximum.
def offline : List Edge → List Edge → Nat
  | [], rev => maxMatching rev []
  | e :: es, rev =>
    e.hit * offline es (e :: rev) + e.miss * offline es ({e with w := 0} :: rev)

def witness : List Edge := [
  ⟨1,4,35,1,0⟩, ⟨0,3,44,1,0⟩, ⟨0,2,33,1,0⟩,
  ⟨0,5,60,3,1⟩, ⟨1,5,80,9,11⟩, ⟨1,3,80,1,3⟩, ⟨0,1,80000000,1,999999⟩]

def Valid (es : List Edge) : Prop :=
  (∀ e ∈ es, e.u < e.v ∧ 0 < e.hit + e.miss) ∧
  (es.map (fun e => (e.u,e.v))).Nodup

set_option maxRecDepth 8192
set_option maxHeartbeats 4000000

theorem witness_valid : Valid witness := by unfold Valid; decide
theorem witness_mass : mass witness = 320000000 := by decide
theorem witness_online : bellman witness [] = 25600000000 := by decide
theorem witness_offline : offline witness [] = 61762963837 := by decide

-- Even a different policy tailored to each instance must pass this test.
-- num/den denotes the proposed guarantee. For general independent weights,
-- universality implies the hypothesis here by restriction to Bernoulli edges.
theorem universal_upper (num den : Nat)
    (guarantee : ∀ es, Valid es → ∃ π : Policy,
      num * offline es [] ≤ den * payoff π es [] []) :
    61762963837 * num ≤ 25600000000 * den := by
  obtain ⟨π, hg⟩ := guarantee witness witness_valid
  have hb := Nat.le_trans hg (Nat.mul_le_mul_left den (policy_le π witness [] []))
  rw [witness_offline, witness_online, Nat.mul_comm num, Nat.mul_comm den] at hb
  omega

-- Fixing private coins gives a deterministic policy. This also verifies the
-- averaging step for any finite mixture with arbitrary natural multiplicities.
def mixture : List (Nat × Policy) → Nat
  | [] => 0
  | p :: ps => p.1 * payoff p.2 witness [] [] + mixture ps
def total : List (Nat × Policy) → Nat
  | [] => 0
  | p :: ps => p.1 + total ps

theorem mixture_upper (ps : List (Nat × Policy)) :
    mixture ps ≤ total ps * 25600000000 := by
  induction ps with
  | nil => decide
  | cons p ps ih =>
    have h := policy_le p.2 witness [] []
    rw [witness_online] at h
    simpa [mixture, total, Nat.add_mul] using
      Nat.add_le_add (Nat.mul_le_mul_left p.1 h) ih

-- Arbitrary private randomness: fix the random seed to obtain a pure policy.
-- The only properties needed from expectation over seeds are monotonicity and
-- its value on the constant function. The codomain can in particular be ℝ.
theorem private_coins_upper {Seed Value : Type} [LE Value]
    (policy : Seed → Policy) (expect : (Seed → Nat) → Value)
    (mono : ∀ f g : Seed → Nat, (∀ s, f s ≤ g s) → expect f ≤ expect g)
    (budget : Value) (normalized : expect (fun _ => 25600000000) = budget) :
    expect (fun s => payoff (policy s) witness [] []) ≤ budget := by
  rw [← normalized]
  apply mono
  intro s
  exact witness_online ▸ policy_le (policy s) witness [] []

theorem strict_improvement :
    25600000000 * 100000 < 41449 * 61762963837 ∧
    41449 * 1000000 < 418928 * 100000 := by decide

end ProphetMatching
