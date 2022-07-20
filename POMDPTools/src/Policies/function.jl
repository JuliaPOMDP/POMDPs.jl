# FunctionPolicy
# A policy represented by a function
# maintained by @zsunberg

"""
FunctionPolicy

Policy `p=FunctionPolicy(f)` returns `f(x)` when `action(p, x)` is called.
"""
struct FunctionPolicy{F<:Function} <: Policy
    f::F
end

"""
FunctionSolver

Solver for a FunctionPolicy.
"""
mutable struct FunctionSolver{F<:Function} <: Solver
    f::F
end

solve(s::FunctionSolver, mdp::Union{MDP,POMDP}) = FunctionPolicy(s.f)

action(p::FunctionPolicy, x) = p.f(x)

updater(p::FunctionPolicy) = PreviousObservationUpdater()
