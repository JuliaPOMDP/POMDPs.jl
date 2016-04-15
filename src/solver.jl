
"""
Base type for an MDP/POMDP solver
"""
abstract Solver

"""
    create_policy{S,A,O}(solver::Solver, pomdp::POMDP{S,A,O})

Creates a policy object (for preallocation purposes)
"""
@pomdp_func create_policy{S,A,O}(solver::Solver, pomdp::POMDP{S,A,O})

"""
    solve{S,A,O}(solver::Solver, pomdp::POMDP{S,A,O}, policy=create_policy(solver, pomdp))

Solves the POMDP using method associated with solver, and returns a policy. 
"""
@pomdp_func solve{S,A,O}(solver::Solver, pomdp::POMDP{S,A,O}, policy=create_policy(solver, pomdp))
