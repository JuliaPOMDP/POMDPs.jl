using POMDPModels
using Test

let
    problem = BabyPOMDP()
    solver = RandomSolver(rng=Random.MersenneTwister(1))
    policy = solve(solver, problem)
    sim = RolloutSimulator(max_steps=10, rng=Random.MersenneTwister(1))
    if VERSION >= v"1.2"
        r1 = @inferred simulate(sim, problem, policy, updater(policy), initialstate(problem))
    else
        r1 = simulate(sim, problem, policy, updater(policy), initialstate(problem))
    end

    @test isapprox(r1, -27.27829, atol=1e-3)

    if VERSION >= v"1.2"
        @test @inferred(simulate(sim, problem, policy, true)) isa Float64
    else
        r1 = simulate(sim, problem, policy, true) isa Float64
    end

    sim = RolloutSimulator(max_steps=10, rng=Random.MersenneTwister(1))
    if VERSION >= v"1.2"
        dummy = @inferred simulate(sim, problem, policy, updater(policy), nothing, true)
    else
        dummy = simulate(sim, problem, policy, updater(policy), nothing, true)
    end

    problem = LegacyGridWorld()
    solver = RandomSolver(rng=Random.MersenneTwister(1))
    policy = solve(solver, problem)
    sim = RolloutSimulator(max_steps=10, rng=Random.MersenneTwister(1))
    if VERSION >= v"1.2"
        r2 = @inferred simulate(sim, problem, policy, initialstate(problem, sim.rng))
    else
        r2 = simulate(sim, problem, policy, initialstate(problem, sim.rng))
    end

    problem = LegacyGridWorld()
    solver = RandomSolver(rng=Random.MersenneTwister(2))
    policy = solve(solver, problem)
    sim = RolloutSimulator(Random.MersenneTwister(2), 10) # new constructor
    if VERSION >= v"1.2"
        r2 = @inferred simulate(sim, problem, policy, rand(sim.rng, initialstate(problem)))
    else
        r2 = simulate(sim, problem, policy, rand(sim.rng, initialstate(problem)))
    end

    @test isapprox(r2, 0.0, atol=1e-3)

    problem = SimpleGridWorld()
    solver = RandomSolver(rng=Random.MersenneTwister(2))
    policy = solve(solver, problem)
    sim = RolloutSimulator(Random.MersenneTwister(2), 10) # new constructor
    if VERSION >= v"1.2"
        @test @inferred(simulate(sim, problem, policy, [1,1])) isa Float64
    else
        @test simulate(sim, problem, policy, [1,1]) isa Float64
    end
end
