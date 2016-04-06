
"""
Base type for an MDP/POMDP solver
"""
abstract Solver{S,A,O}

"""
    create_policy{S,A,O}(solver::Solver{S,A,O}, pomdp::POMDP{S,A,O})

Creates a policy object (for preallocation purposes)
"""
create_policy{S,A,O}(solver::Solver{S,A,O}, pomdp::POMDP{S,A,O}) = error("$(typeof(pomdp)) does not implement create_policy")

"""
    solve{S,A,O}(solver::Solver{S,A,O}, pomdp::POMDP{S,A,O}, policy=create_policy(solver, pomdp))

Solves the POMDP using method associated with solver, and returns a policy. 
"""
solve{S,A,O}(solver::Solver{S,A,O}, pomdp::POMDP{S,A,O}, policy=create_policy(solver, pomdp)) = error("$(typeof(solver)) does not implement solve for model $(typeof(pomdp))")
