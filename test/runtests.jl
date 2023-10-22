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
    @test convert_s(statetype(CI()), Float32[1.0], CI()) == 1
    @test convert_s(statetype(CV()), Float32[2.0,3.0], CV()) == [2.0, 3.0]
    @test convert_s(Vector{Float32}, [2.0, 3.0], CV()) == Float32[2.0, 3.0]
    @test convert_s(Any, 1, CI()) == 1
    @test convert_s(Any, [1.], CV()) == [1.]
    @test convert_s(statetype(CI()), 1.0, CI()) == 1
    @test convert_s(statetype(CV()), Float32[1.0], CV()) == [1.]

    @test convert_a(Vector{Float32}, 1, CI()) == Float32[1.0]
    @test convert_a(actiontype(CI()), Float32[1.0], CI()) == 1
    @test convert_a(actiontype(CV()), Float32[2.0,3.0], CV()) == [2.0, 3.0]
    @test convert_a(Vector{Float32}, [2.0, 3.0], CV()) == Float32[2.0, 3.0]
    @test convert_a(Any, 1, CI()) == 1
    @test convert_a(Any, [1.], CV()) == [1.]
    @test convert_a(actiontype(CI()), 1.0, CI()) == 1
    @test convert_a(actiontype(CV()), Float32[1.0], CV()) == [1.]


    @test convert_o(Vector{Float32}, 1, CI()) == Float32[1.0]
    @test convert_o(obstype(CI()), Float32[1.0], CI()) == 1
    @test convert_o(obstype(CV()), Float32[2.0,3.0], CV()) == [2.0, 3.0]
    @test convert_o(Vector{Float32}, [2.0, 3.0], CV()) == Float32[2.0, 3.0]
    @test convert_o(Any, 1, CI()) == 1
    @test convert_o(Any, [1.], CV()) == [1.]
    @test convert_o(obstype(CI()), 1.0, CI()) == 1
    @test convert_o(obstype(CV()), Float32[1.0], CV()) == [1.]
end

struct EA <: POMDP{Int, Int, Int} end
struct EB <: POMDP{Int, Int, Int} end

@testset "history" begin
    POMDPs.history(i::Int) = [(o=i,)]
    @test history(4)[end][:o] == 4
    @test currentobs(4) == 4
end

@testset "Issues" begin
    @testset "POMDPModels Issue #97" begin
        struct ModelsIssue97POMDP <: POMDP{Bool, Bool, Bool} end
        m = ModelsIssue97POMDP()
        @test convert_o(Bool, [1.], m) == true
        @test convert_s(Bool, [1.], m) == true
    end
end
