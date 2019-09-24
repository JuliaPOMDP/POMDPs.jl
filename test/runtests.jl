using Test

using POMDPs
using Random

POMDPs.logger_context(::Test.TestLogger) = IOContext(stderr)

mightbemissing(x) = ismissing(x) || x

# using Logging
# global_logger(ConsoleLogger(stderr, Logging.Debug))

mutable struct A <: POMDP{Int,Bool,Bool} end
@testset "implement" begin

    @test_throws MethodError length(states(A()))
    @test_throws MethodError stateindex(A(), 1)

    @test !@implemented transition(::A, ::Int, ::Bool)
    POMDPs.transition(::A, s, a) = [s+a]
    @test @implemented transition(::A, ::Int, ::Bool)

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

@testset "infer" begin
    include("test_inferrence.jl")
end

@testset "require" begin
    include("test_requirements.jl")
end

@testset "generative" begin
    include("test_generative.jl")
end

@testset "genback" begin
    include("test_generative_backedges.jl")
end

@testset "ddn_struct" begin
    include("test_ddn_struct.jl")
end

@testset "gendep" begin
    include("test_deprecated_generative.jl")
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
@testset "error" begin
    @test_throws MethodError transition(EA(), 1, 2)
    @test_throws DistributionNotImplemented gen(DDNOut(:sp), EA(), 1, 2, Random.GLOBAL_RNG)
end

@testset "history" begin
    POMDPs.history(i::Int) = [(o=i,)]
    @test history(4)[end][:o] == 4
    @test currentobs(4) == 4
end

POMDPs.add_registry()
