# A test for solvers
# Maintained by @zsunberg

mutable struct TestSimulator
    rng::AbstractRNG
    max_steps::Int
end

function simulate(sim::TestSimulator, pomdp::POMDP, policy::Policy, updater::Updater, initial_distribution::Any)

    s = rand(sim.rng, initial_distribution)
    b = initialize_belief(updater, initial_distribution)

    disc = 1.0
    r_total = 0.0

    step = 1

    while !isterminal(pomdp, s) && step <= sim.max_steps # TODO also check for terminal observation
        a = action(policy, b)

        (sp, o, r) = @gen(:sp, :o, :r)(pomdp, s, a, sim.rng)

        r_total += disc*r

        b = update(updater, b, a, o)

        disc *= discount(pomdp)
        s = sp
        step += 1
    end

    return r_total
end

function simulate(sim::TestSimulator, mdp::MDP, policy::Policy, s)

    disc = 1.0
    r_total = 0.0

    step = 1

    while !isterminal(mdp, s) && step <= sim.max_steps # TODO also check for terminal observation
        a = action(policy, s)

        (sp, r) = @gen(:sp, :r)(mdp, s, a, sim.rng)

        r_total += disc*r

        disc *= discount(mdp)
        s = sp
        step += 1
    end

    return r_total
end


"""
    test_solver(solver::Solver, problem::POMDP)
    test_solver(solver::Solver, problem::MDP)

Use the solver to solve the specified problem, then run a simulation.

This is designed to illustrate how solvers are expected to function. All solvers should be able to complete this standard test with the simple models in the POMDPModels package.

Note that this does NOT test the optimality of the solution, but is only a smoke test to see if the solver interacts with POMDP models as expected.

To run this with a solver called YourSolver, run
```
using POMDPToolbox
using POMDPModels

solver = YourSolver(# initialize with parameters #)
test_solver(solver, BabyPOMDP())
```
"""
function test_solver(solver::Solver, problem::POMDP; max_steps=10, updater=nothing)

    policy = solve(solver, problem)
    if updater==nothing
        updater = POMDPs.updater(policy)
    end

    sim = TestSimulator(MersenneTwister(1), max_steps)

    simulate(sim, problem, policy, updater, initialstate(problem))
end

function test_solver(solver::Solver, problem::MDP; max_steps=10)

    policy = solve(solver, problem)

    sim = TestSimulator(MersenneTwister(1), max_steps)

    simulate(sim, problem, policy, rand(MersenneTwister(0), initialstate(problem)))
end
