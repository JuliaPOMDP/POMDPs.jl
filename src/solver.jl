
"""
Base type for an MDP/POMDP solver
"""
abstract type Solver end

"""
    solve(solver::Solver, problem::POMDP)

Solves the POMDP using method associated with solver, and returns a policy.
"""
function solve end
