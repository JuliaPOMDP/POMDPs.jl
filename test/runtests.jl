using Test

using POMDPs
using Random

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

@testset "deprecated" begin
    
    POMDPs.add_registry()
    
    @test !@implemented transition(::EA, ::Int, ::Int)
    POMDPs.transition(::EA, ::Int, ::Int) = [0]
    @test @implemented transition(::EA, ::Int, ::Int)

    @POMDP_require solve(a::Int, b::Int) begin
        @req transition(::EA, ::Int, ::Int)
    end
    @POMDP_requirements Int begin end
    @requirements_info Int
    a = 1
    b = 2
    @get_requirements solve(a, b)
    @show_requirements solve(a, b)
    @warn_requirements solve(a, b)

    @test_throws ErrorException @req
    @test_throws ErrorException @subreq

    @test gen(DDNOut(:sp), EA(), 1, 1, MersenneTwister(3)) == 0
    @test_throws MethodError @gen(:sp,:o)(EA(), 1, true, MersenneTwister(4))

    POMDPs.initialstate(::EA) = [1,2,3]
    @test (@test_deprecated initialstate_distribution(EA())) == initialstate(EA())
    @test (@test_deprecated initialstate(EA(), Random.GLOBAL_RNG)) in initialstate(EA())

    @test_throws MethodError initialstate(EB())
    POMDPs.initialstate_distribution(m::EB) = [1]
    @test initialstate(EB()) == [1]
end
