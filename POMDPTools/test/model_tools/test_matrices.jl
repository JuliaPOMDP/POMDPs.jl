for m in [BabyPOMDP(), SimpleGridWorld()]
    ts = transition_matrices(m)
    for a in actions(m)
        @test a in keys(ts)
        t = ts[a]
        @test t isa AbstractMatrix
        for i in size(t, 1)
            @test sum(t[i, :]) ≈ 1.0
        end
    end

    rs = reward_vectors(m)
    for a in actions(m)
        @test a in keys(rs)
        r = rs[a]
        @test r isa AbstractVector
        @test r == POMDPModelTools.policy_reward_vector(m, FunctionPolicy(s->a))
    end
end
