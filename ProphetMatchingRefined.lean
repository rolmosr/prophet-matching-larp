import ProphetMatchingWitness

namespace ProphetMatching.Refined

-- Weights are scaled by 887110.  The last edge hits with probability 10^-14.
def edges : List Edge := [
  ⟨1, 4, 402201, 1, 0⟩, ⟨0, 3, 484909, 1, 0⟩,
  ⟨0, 2, 366408, 1, 0⟩, ⟨0, 5, 670320, 484909, 185411⟩,
  ⟨1, 5, 887110, 603, 727⟩, ⟨1, 3, 887110, 163, 504⟩,
  ⟨0, 1, 88711000000000000000, 1, 99999999999999⟩]

set_option maxRecDepth 8192
set_option maxHeartbeats 4000000

theorem edges_valid : Valid edges := by unfold Valid; decide
theorem online_value : bellman edges [] = 52751781043567200000000000000000 := by decide
theorem offline_value : offline edges [] = 127411700717342348500803262241049 := by decide

theorem universal_upper (num den : Nat)
    (guarantee : ∀ es, Valid es → ∃ π : Policy,
      num * offline es [] ≤ den * payoff π es [] []) :
    14156855635260260944533695804561 * num ≤
      5861309004840800000000000000000 * den := by
  obtain ⟨π, hg⟩ := guarantee edges edges_valid
  have hb := Nat.le_trans hg (Nat.mul_le_mul_left den (policy_le π edges [] []))
  rw [offline_value, online_value, Nat.mul_comm num, Nat.mul_comm den] at hb
  omega

theorem comparison :
    5861309004840800000000000000000 * 1000000000000 <
      414026190269 * 14156855635260260944533695804561 ∧
    414026190269 * 1169 < 484 * 1000000000000 := by decide

end ProphetMatching.Refined
