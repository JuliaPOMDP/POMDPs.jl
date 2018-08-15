using Test

using POMDPs

mutable struct X <: POMDP{Float64,Bool,Int} end
abstract type Z <: POMDP{Float64,Bool,Int} end
mutable struct Y <: Z end

@test_throws ErrorException statetype(Int)
@test_throws ErrorException actiontype(Int)
@test_throws ErrorException obstype(Int)

@test statetype(X) == Float64
@test statetype(Y) == Float64
@test actiontype(X) == Bool
@test actiontype(Y) == Bool
@test obstype(X) == Int
@test obstype(Y) == Int
