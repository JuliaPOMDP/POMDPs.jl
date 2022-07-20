let
    pomdp = TigerPOMDP()

    mdp = UnderlyingMDP(pomdp)

    @test states(mdp) == states(pomdp)
    s_mdp = rand(MersenneTwister(1), initialstate_distribution(mdp))
    s_pomdp = rand(MersenneTwister(1), initialstate_distribution(pomdp))

    @test s_mdp == s_pomdp

    solver = ValueIterationSolver(max_iterations = 100)
    @test_skip begin
        mdp_policy = solve(solver, mdp)
        pomdp_policy = solve(solver, UnderlyingMDP(pomdp))
        mdp_policy.util == pomdp_policy.util
    end

    actionindex(mdp, 1)

    for (sp, r) in stepthrough(mdp, FunctionPolicy(o->1), "sp,r", rng=MersenneTwister(2), max_steps=10)
        @test sp isa statetype(pomdp)
    end

    # test mdp passthrough
    m = SimpleGridWorld()
    @test UnderlyingMDP(m) === m
end
