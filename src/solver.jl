
"""
Base type for an MDP/POMDP solver
"""
abstract Solver

"""
    create_policy(solver::Solver, problem::POMDP)
    create_policy(solver::Solver, problem::MDP)

Creates a policy object (for preallocation purposes)
"""
@pomdp_func create_policy(solver::Solver, problem::Union{POMDP,MDP})

"""
    solve(solver::Solver, problem::POMDP, policy=create_policy(solver, problem))

Solves the POMDP using method associated with solver, and returns a policy. 
"""
@pomdp_func solve(solver::Solver, problem::Union{POMDP,MDP}, policy=create_policy(solver, problem))
