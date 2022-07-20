struct RewardModelMDP1 <: MDP{Int, Int} end
POMDPs.reward(m::RewardModelMDP1, s, a) = s + a
rm = StateActionReward(RewardModelMDP1())
@test rm(1, 1) == 2

struct RewardModelMDP2 <: MDP{Int, Int} end
POMDPs.reward(m::RewardModelMDP2, s, a, sp) = s + a
POMDPs.transition(m::RewardModelMDP2, s, a) = Deterministic(s + a)
POMDPs.states(m::RewardModelMDP2) = 1:10
POMDPs.actions(m::RewardModelMDP2) = 1:10
POMDPs.stateindex(m::RewardModelMDP2, s) = s
POMDPs.actionindex(m::RewardModelMDP2, a) = a
rm = StateActionReward(RewardModelMDP2())
@test rm(1, 1) == 2

struct RewardModelPOMDP1 <: POMDP{Int, Int, Int} end
POMDPs.reward(m::RewardModelPOMDP1, s, a, sp, o) = s + a
POMDPs.transition(m::RewardModelPOMDP1, s, a) = Deterministic(s + a)
POMDPs.states(m::RewardModelPOMDP1) = 1:10
POMDPs.actions(m::RewardModelPOMDP1) = 1:10
POMDPs.observation(m::RewardModelPOMDP1, s, a, sp) = Deterministic(s + a + sp)
POMDPs.stateindex(m::RewardModelPOMDP1, s) = s
POMDPs.actionindex(m::RewardModelPOMDP1, a) = a
rm = StateActionReward(RewardModelPOMDP1())
@test rm(1, 1) == 2

m = BabyPOMDP()
rm = LazyCachedSAR(m)
for s in states(m)
    for a in actions(m)
        @test reward(m, s, a) == rm(s, a)
    end
end

m = SimpleGridWorld()
rm = LazyCachedSAR(m)
for s in states(m)
    for a in actions(m)
        @test reward(m, s, a) == rm(s, a)
    end
end
