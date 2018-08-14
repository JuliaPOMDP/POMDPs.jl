using Test

using POMDPs
using Random
mutable struct A <: POMDP{Int,Bool,Bool} end
@test_throws MethodError n_states(A())
@test_throws MethodError state_index(A(), 1)

@test !@implemented discount(::A)
POMDPs.discount(::A) = 0.95
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

mutable struct D end
POMDPs.sampletype(::Type{D}) = Int
@test @implemented sampletype(::D)
@test sampletype(D()) == Int

struct E end
@test_throws MethodError sampletype(E)
@test_throws MethodError sampletype(E())

include("test_inferrence.jl")
include("test_requirements.jl")
include("test_generative.jl")
# include("test_tutorials.jl")
include("test_generative_backedges.jl")

let
    struct CI <: POMDP{Int,Int,Int} end
    struct CV <: POMDP{Vector{Float64},Vector{Float64},Vector{Float64}} end

    @test convert_s(Vector{Float32}, 1, CI()) == Float32[1.0]
    @test convert_s(state_type(CI), Float32[1.0], CI()) == 1
    @test convert_s(state_type(CV), Float32[2.0,3.0], CV()) == [2.0, 3.0]
    @test convert_s(Vector{Float32}, [2.0, 3.0], CV()) == Float32[2.0, 3.0]

    @test convert_a(Vector{Float32}, 1, CI()) == Float32[1.0]
    @test convert_a(state_type(CI), Float32[1.0], CI()) == 1
    @test convert_a(state_type(CV), Float32[2.0,3.0], CV()) == [2.0, 3.0]
    @test convert_a(Vector{Float32}, [2.0, 3.0], CV()) == Float32[2.0, 3.0]

    @test convert_o(Vector{Float32}, 1, CI()) == Float32[1.0]
    @test convert_o(state_type(CI), Float32[1.0], CI()) == 1
    @test convert_o(state_type(CV), Float32[2.0,3.0], CV()) == [2.0, 3.0]
    @test convert_o(Vector{Float32}, [2.0, 3.0], CV()) == Float32[2.0, 3.0]

end
