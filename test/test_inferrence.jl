using Test

using POMDPs

mutable struct X <: POMDP{Float64,Bool,Int} end
abstract type Z <: POMDP{Float64,Bool,Int} end
mutable struct Y <: Z end

@test_throws ErrorException state_type(Int)
@test_throws ErrorException action_type(Int)
@test_throws ErrorException obs_type(Int)

@test state_type(X) == Float64
@test state_type(Y) == Float64
@test action_type(X) == Bool
@test action_type(Y) == Bool
@test obs_type(X) == Int
@test obs_type(Y) == Int
