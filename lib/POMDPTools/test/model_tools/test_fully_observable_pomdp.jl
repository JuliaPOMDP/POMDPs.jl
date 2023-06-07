let
    mdp = SimpleGridWorld()

    pomdp = FullyObservablePOMDP(mdp)

    @test observations(pomdp) == states(pomdp)
    @test statetype(pomdp) == obstype(pomdp)

    @test observations(pomdp) == states(pomdp)
    @test statetype(pomdp) == obstype(pomdp)
    
    s_po = rand(MersenneTwister(1), initialstate(pomdp))
    s_mdp = rand(MersenneTwister(1), initialstate(mdp))
    @test s_po == s_mdp
    @test stateindex(mdp, s_mdp) == stateindex(pomdp, s_po) == obsindex(pomdp, s_po)

    solver = ValueIterationSolver(max_iterations = 100)
    mdp_policy = solve(solver, mdp)
    pomdp_policy = solve(solver, UnderlyingMDP(pomdp))
    mdp_policy.util == pomdp_policy.util

    is = rand(MersenneTwister(3), initialstate(mdp))
    for (sp, o, r) in stepthrough(pomdp,
                               FunctionPolicy(o->:left),
                               PreviousObservationUpdater(),
                               is, is, "sp,o,r",
                               rng=MersenneTwister(2),
                               max_steps=10)
        @test sp == o
    end
end
