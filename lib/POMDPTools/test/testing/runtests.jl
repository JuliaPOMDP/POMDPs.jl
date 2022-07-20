using Test
using POMDPs
using POMDPTesting
using POMDPModelTools

import POMDPs:
    transition,
    observation,
    initialstate,
    updater,
    states,
    actions,
    observations

struct TestPOMDP <: POMDP{Bool, Bool, Bool} end
updater(problem::TestPOMDP) = DiscreteUpdater(problem)
initialstate(::TestPOMDP) = BoolDistribution(0.0)
transition(p::TestPOMDP, s, a) = BoolDistribution(0.5)
observation(p::TestPOMDP, a, sp) = BoolDistribution(0.5)
states(p::TestPOMDP) = (true, false)
actions(p::TestPOMDP) = (true, false)
observations(p::TestPOMDP) = (true, false)

@testset "model" begin
    m = TestPOMDP()
    @test has_consistent_initial_distribution(m)
    @test has_consistent_transition_distributions(m)
    @test has_consistent_observation_distributions(m)
    @test has_consistent_distributions(m)
end

@testset "old model" begin
    probability_check(TestPOMDP())
end

@testset "support mismatch" begin
    struct SupportMismatchPOMDP <: POMDP{Int, Int, Int} end
    POMDPs.states(::SupportMismatchPOMDP) = 1:2
    POMDPs.actions(::SupportMismatchPOMDP) = 1:2
    POMDPs.observations(::SupportMismatchPOMDP) = 1:2
    POMDPs.initialstate(::SupportMismatchPOMDP) = Deterministic(3)
    POMDPs.transition(::SupportMismatchPOMDP, s, a) = SparseCat([1, 2, 3], [1.0, 0.0, 0.1])
    POMDPs.observation(::SupportMismatchPOMDP, s, a, sp) = SparseCat([1, 2, 3], [1.0, 0.0, 0.1])
    @test !has_consistent_transition_distributions(SupportMismatchPOMDP())
    @test !has_consistent_observation_distributions(SupportMismatchPOMDP())
    @test !has_consistent_distributions(SupportMismatchPOMDP())
end
