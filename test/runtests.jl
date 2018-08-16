using Test

using POMDPs
using Random

mutable struct A <: POMDP{Int,Bool,Bool} end
@testset "implement" begin

    @test_throws MethodError n_states(A())
    @test_throws MethodError stateindex(A(), 1)

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
end

mutable struct D end
POMDPs.sampletype(::Type{D}) = Int
struct E end
@testset "sampletype" begin
    @test @implemented sampletype(::D)
    @test sampletype(D()) == Int

    @test_throws MethodError sampletype(E)
    @test_throws MethodError sampletype(E())
end

@testset "infer" begin
    include("test_inferrence.jl")
end

@testset "require" begin
    include("test_requirements.jl")
end

@testset "generative" begin
    include("test_generative.jl")
end

# include("test_tutorials.jl")

@testset "genback" begin
    include("test_generative_backedges.jl")
end

struct CI <: POMDP{Int,Int,Int} end
struct CV <: POMDP{Vector{Float64},Vector{Float64},Vector{Float64}} end

@testset "convert" begin
    @test convert_s(Vector{Float32}, 1, CI()) == Float32[1.0]
    @test convert_s(statetype(CI), Float32[1.0], CI()) == 1
    @test convert_s(statetype(CV), Float32[2.0,3.0], CV()) == [2.0, 3.0]
    @test convert_s(Vector{Float32}, [2.0, 3.0], CV()) == Float32[2.0, 3.0]

    @test convert_a(Vector{Float32}, 1, CI()) == Float32[1.0]
    @test convert_a(statetype(CI), Float32[1.0], CI()) == 1
    @test convert_a(statetype(CV), Float32[2.0,3.0], CV()) == [2.0, 3.0]
    @test convert_a(Vector{Float32}, [2.0, 3.0], CV()) == Float32[2.0, 3.0]

    @test convert_o(Vector{Float32}, 1, CI()) == Float32[1.0]
    @test convert_o(statetype(CI), Float32[1.0], CI()) == 1
    @test convert_o(statetype(CV), Float32[2.0,3.0], CV()) == [2.0, 3.0]
    @test convert_o(Vector{Float32}, [2.0, 3.0], CV()) == Float32[2.0, 3.0]
end
