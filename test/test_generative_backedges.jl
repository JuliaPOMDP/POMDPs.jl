using Test
using POMDPs
using Random

let
    struct M <: POMDP{Int, Int, Char} end
    @test_throws MethodError generate_s(M(), 1, 1, MersenneTwister(4))
    POMDPs.transition(::M, ::Int, ::Int) = [1]
    @test generate_s(M(), 1, 1, MersenneTwister(4)) == 1
    @test_throws MethodError generate_sor(M(), 1, 1, MersenneTwister(4))
    @test_throws MethodError generate_sr(M(), 1, 1, MersenneTwister(4))
    POMDPs.reward(::M, ::Int, ::Int, ::Int) = 0.0
    @test generate_sr(M(), 1, 1, MersenneTwister(4)) == (1, 0.0)
    @test_throws MethodError generate_sor(M(), 1, 1, MersenneTwister(4))
    POMDPs.generate_o(::M, ::Int, ::Int, ::Int, ::AbstractRNG) = `a`
    @test generate_sor(M(), 1, 1, MersenneTwister(4)) == (1, `a`, 0.0)
end
