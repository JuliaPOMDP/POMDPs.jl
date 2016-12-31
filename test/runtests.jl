include("build.jl")
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

@test !@implemented observation(::A,::Int,::Bool,::Int)
@test !@implemented observation(::A,::Bool,::Int)
POMDPs.observation(::A,::Bool,::Int) = [true, false]
@test @implemented observation(::A,::Int,::Bool,::Int)
@test @implemented observation(::A,::Bool,::Int)

include("test_inferrence.jl")
include("test_requirements.jl")
