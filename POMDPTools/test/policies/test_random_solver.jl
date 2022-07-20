let
    problem = BabyPOMDP()

    solver = RandomSolver(rng=MersenneTwister(1))

    policy = solve(solver, problem)

    sim = RolloutSimulator(max_steps=10, rng=MersenneTwister(1))

    r = simulate(sim, problem, policy, updater(policy), initialstate_distribution(problem))

    @test isapprox(r, -27.27829, atol=1e-3)
end
