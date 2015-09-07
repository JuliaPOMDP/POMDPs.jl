
abstract Solver

solve(solver::Solver, pomdp::POMDP, policy=nothing) = error("$(typeof(solver)) does not implement solve for model $(typeof(pomdp))")
