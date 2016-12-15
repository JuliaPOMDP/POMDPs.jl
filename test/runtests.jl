using Base.Test

using POMDPs
type A <: POMDP{Int,Bool,Bool} end
@test_throws MethodError n_states(A())
@test_throws MethodError state_index(A(), 1)

@test @implemented discount(::A)
@test !@implemented reward(::A,::Int,::Bool,::Int)
@test !@implemented reward(::A,::Int,::Bool)
POMDPs.reward(::A,::Int,::Bool) = -1.0
@test @implemented reward(::A,::Int,::Bool,::Int)
@test @implemented reward(::A,::Int,::Bool)

include("test_requirements.jl")
include("test_inferrence.jl")
