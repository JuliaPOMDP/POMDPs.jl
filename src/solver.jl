
abstract Solver

solve(solver::Solver, pomdp::POMDP) = error("$(typeof(solver)) does not implement solve for model $(typeof(pomdp))")
solve!(policy, solver::Solver, pomdp::POMDP) = error("$(typeof(solver)) does not implement solve! for model $(typeof(pomdp))")

