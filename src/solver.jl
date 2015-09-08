
abstract Solver

create_policy(solver::Solver, pomdp::POMDP) = error("$(typeof(pomdp)) does not implement create_policy")
solve(solver::Solver, pomdp::POMDP, policy=create_policy(solver, pomdp)) = error("$(typeof(solver)) does not implement solve for model $(typeof(pomdp))")
