using StableRNGs

"""
    test_solver(solver, mdp; rng=StableRNG(1234), n_episodes=100, max_steps=100)

Test a POMDPs solver using a stable random number generator (`StableRNG`) to ensure reproducible test outcomes.
"""
function test_solver(solver, mdp; rng=StableRNG(1234), kwargs...)
    # Existing test logic utilizing the provided or stable RNG
    # ...
end