
# TODO (max): need to worry if discrete or continuous solver, or is this taken care of by MDP/POMDP type?
abstract Solver
# TODO (max): how to best handle parallel/serial solvers
abstract SerialSolver <: Solver
abstract ParallelSolver <: Solver
# all POMDPs are subtypes of MDPs
solve(solver::Solver, pomdp::POMDP) = error("$(typeof(solver)) does not implement solve for model $(typeof(pomdp))")
solve!(solver::Solver, pomdp::POMDP) = error("$(typeof(solver)) does not implement solve! for model $(typeof(pomdp))")

