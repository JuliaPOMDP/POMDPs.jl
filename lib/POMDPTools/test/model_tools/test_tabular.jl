function test_transition(pb1::Union{MDP, POMDP}, pb2::Union{SparseTabularMDP, SparseTabularPOMDP})
    @testset "transition" begin
        for s in states(pb1)
            si = stateindex(pb1, s)
            for a in actions(pb1)
                ai = actionindex(pb1, a)
                td1 = transition(pb1, s, a)
                td2 = transition(pb2, si, ai)
                for (sp, p) in weighted_iterator(td1)
                    spi = stateindex(pb1, sp)
                    @test pdf(td2, spi) == p
                end
            end
        end
    end
end

function test_reward(pb1::Union{MDP, POMDP}, pb2::Union{SparseTabularMDP, SparseTabularPOMDP})
    @testset "reward" begin
        for s in states(pb1)
            si = stateindex(pb1, s)
            for a in actions(pb1)
                ai = actionindex(pb1, a)
                if isterminal(pb1, s)
                    @test reward(pb2, si, ai) == 0.0
                else
                    td = transition(pb1, s, a)
                    r_pb1 = 0.0
                    for (sp, p) in weighted_iterator(td)
                        if p > 0.0
                            r_pb1 += p*reward(pb1, s, a, sp)
                        end
                    end
                    @test r_pb1 ≈ reward(pb2, si, ai)
                end
            end
        end
    end
end

function test_observation(pb1::POMDP, pb2::SparseTabularPOMDP)
    @testset "transitions" begin
        for s in states(pb1)
            for a in actions(pb1)
                od1 = observation(pb1, a, s)
                si = stateindex(pb1, s)
                ai = actionindex(pb1, a)
                od2 = observation(pb2, ai, si)
                for (o, p) in weighted_iterator(od1)
                    oi = obsindex(pb1, o)
                    @test pdf(od2, oi) == p
                end
            end
        end
    end
end


## MDP 

@testset "Random MDP" begin

mdp = RandomMDP(100, 4, 0.95)

@test_skip @show_requirements SparseTabularMDP(mdp)

smdp = SparseTabularMDP(mdp)

smdp2 = SparseTabularMDP(smdp)

@test smdp2.T == smdp.T
@test smdp2.R == smdp.R
@test smdp2.discount == smdp.discount

smdp3 = SparseTabularMDP(smdp, reward = zeros(length(states(mdp)), length(actions(mdp))))
@test smdp3.T == smdp.T
@test smdp3.R != smdp.R
smdp3 = SparseTabularMDP(smdp, transition = [sparse(1:length(states(mdp)), 1:length(states(mdp)), 1.0) for a in 1:length(actions(mdp))])
@test smdp3.T != smdp.T
@test smdp3.R == smdp.R
smdp3 = SparseTabularMDP(smdp, discount = 0.5)
@test smdp3.discount != smdp.discount

@test size(transition_matrix(smdp, 1)) == (length(states(smdp)), length(states(smdp)))
@test length(reward_vector(smdp, 1)) == length(states(smdp))

gw = SimpleGridWorld()
sparsegw = SparseTabularMDP(gw)
@test isterminal(sparsegw, 101)
@inferred actions(sparsegw, 101)
@test actions(sparsegw, 101) == collect(actions(sparsegw))

end


## POMDP 

function test_pomdp(pomdp::POMDP)
    @test_skip @show_requirements SparseTabularPOMDP(pomdp)

    rand_mdp = RandomMDP(100, 4, 0.95)

    spomdp = SparseTabularPOMDP(pomdp)

    @testset "generic" begin
        spomdp2 = SparseTabularPOMDP(spomdp)

        @test spomdp2.T == spomdp.T
        @test spomdp2.R == spomdp.R
        @test spomdp2.O == spomdp.O
        @test spomdp2.discount == spomdp.discount

        spomdp3 = SparseTabularPOMDP(spomdp, reward = zeros(length(states(rand_mdp)), length(actions(rand_mdp))))
        @test spomdp3.T == spomdp.T
        @test spomdp3.R != spomdp.R
        spomdp3 = SparseTabularPOMDP(spomdp, transition = [sparse(1:length(states(rand_mdp)), 1:length(states(rand_mdp)), 1.0) for a in 1:length(actions(rand_mdp))])
        @test spomdp3.T != spomdp.T
        @test spomdp3.R == spomdp.R
        spomdp3 = SparseTabularPOMDP(spomdp, discount = 0.5)
        @test spomdp3.discount != spomdp.discount
        @test size(observation_matrix(spomdp, 1)) == (length(states(spomdp)), length(observations(spomdp)))
        @show size(observation_matrix(spomdp, 1)) == (length(states(spomdp)), length(observations(spomdp)))
        @test observation_matrices(spomdp) == spomdp2.O
        @test transition_matrices(spomdp) == spomdp2.T
        @test reward_matrix(spomdp) == spomdp2.R

        @test length(states(pomdp)) == length(states(spomdp))
        @test length(actions(pomdp)) == length(actions(spomdp))
        @test length(observations(pomdp)) == length(observations(spomdp))
        @test statetype(spomdp) == Int64
        @test actiontype(spomdp) == Int64
        @test obstype(spomdp) == Int64
        @test discount(spomdp) == discount(pomdp)
        @test length(spomdp.terminal_states) == length([s for s in states(pomdp) if isterminal(pomdp, s)])
    end

    test_transition(pomdp, spomdp)
    test_reward(pomdp, spomdp)
    test_observation(pomdp, spomdp)
end

@testset "Tiger POMDP" begin
    test_pomdp(TigerPOMDP())
end
@testset "TMaze POMDP" begin
    test_pomdp(TMaze())
end
