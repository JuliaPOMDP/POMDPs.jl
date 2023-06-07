import POMDPs:
    transition,
    observation,
    initialstate,
    updater,
    states,
    actions,
    observations

struct TestPOMDP <: POMDP{Bool, Bool, Bool} end
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
    POMDPs.states(::SupportMismatchPOMDP) = (1,)
    POMDPs.actions(::SupportMismatchPOMDP) = (1,)
    POMDPs.observations(::SupportMismatchPOMDP) = (1,)
    POMDPs.initialstate(::SupportMismatchPOMDP) = Deterministic(2)
    POMDPs.transition(::SupportMismatchPOMDP, s, a) = SparseCat([1, 2], [1.0, 0.1]) # important that the sum of probs for states(m) sums to 1 to exercise the correct error.
    POMDPs.observation(::SupportMismatchPOMDP, a, sp) = SparseCat([1, 2], [1.0, 0.1])
    @test !has_consistent_transition_distributions(SupportMismatchPOMDP())
    @test !has_consistent_observation_distributions(SupportMismatchPOMDP())
    @test !has_consistent_distributions(SupportMismatchPOMDP())
end

@testset "tolerance" begin
    struct ToleranceTestPOMDP <: POMDP{Int, Int, Int} end
    POMDPs.states(::ToleranceTestPOMDP) = 1:2
    POMDPs.actions(::ToleranceTestPOMDP) = (1,)
    POMDPs.observations(::ToleranceTestPOMDP) = 1:2
    POMDPs.initialstate(::ToleranceTestPOMDP) = Deterministic(1)
    POMDPs.transition(::ToleranceTestPOMDP, s, a) = SparseCat(1:2, [1.0, 0.001])
    POMDPs.observation(::ToleranceTestPOMDP, a, sp) = SparseCat(1:2, [1.0, 0.001])
    @test !has_consistent_transition_distributions(ToleranceTestPOMDP())
    @test !has_consistent_observation_distributions(ToleranceTestPOMDP())
    @test !has_consistent_distributions(ToleranceTestPOMDP())
    @test has_consistent_transition_distributions(ToleranceTestPOMDP(), atol=1e-3)
    @test has_consistent_observation_distributions(ToleranceTestPOMDP(), atol=1e-3)
    @test has_consistent_distributions(ToleranceTestPOMDP(), atol=1e-3)
end
