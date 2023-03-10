using Test

using POMDPs
using Random

"""
Like @inferred, except ignored in julia v1.0
"""
macro inferred_except_1_0(expr)
    if VERSION >= v"1.1"
        return :(@inferred($expr))
    else
        return expr
    end
end

@testset "infer" begin
    include("test_inferrence.jl")
end

@testset "generative" begin
    include("test_generative.jl")
end

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

struct EA <: POMDP{Int, Int, Int} end
struct EB <: POMDP{Int, Int, Int} end

@testset "history" begin
    POMDPs.history(i::Int) = [(o=i,)]
    @test history(4)[end][:o] == 4
    @test currentobs(4) == 4
end
