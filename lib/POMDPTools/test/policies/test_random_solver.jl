let # broken because of updater(policy)
    problem = BabyPOMDP()

    solver = RandomSolver(rng=StableRNG(1))

    policy = solve(solver, problem)

    sim = RolloutSimulator(max_steps=10, rng=StableRNG(1))

    r = simulate(sim, problem, policy, updater(policy), initialstate(problem))

    @test isapprox(r, -26.688, atol=1e-3)
end
