using Base.Test

using POMDPs
type A <: POMDP{Int,Bool,Bool} end
@test_throws MethodError n_states(A())
@test_throws MethodError state_index(A(), 1)

include("test_requirements.jl")
