let
    struct TigerPOMDPTestFixture <: POMDP{Bool, Int, Bool} end
    POMDPs.states(::TigerPOMDPTestFixture) = (true, false)
    POMDPs.stateindex(::TigerPOMDPTestFixture, s) = Int(s) + 1
    POMDPs.actions(m::TigerPOMDPTestFixture) = 0:2
    POMDPs.actionindex(m::TigerPOMDPTestFixture, s::Int) = s+1
    POMDPs.observations(::TigerPOMDPTestFixture) = (true, false)
    POMDPs.obsindex(::TigerPOMDPTestFixture, o) = Int(o) + 1

    pomdp = TigerPOMDPTestFixture()

    @test ordered_states(pomdp) == [false, true]
    @test ordered_observations(pomdp) == [false, true]
    @test ordered_actions(pomdp) == [0,1,2]
end

struct TM <: POMDP{Int, Int, Int} end
POMDPs.states(::TM) = [1,3]
POMDPs.stateindex(::TM, s::Int) = s

@test_throws ErrorException ordered_states(TM())
