using Test
using POMDPs
using Random

let
    struct M <: POMDP{Int, Int, Char} end
    @test_throws MethodError gen(Return(:sp), M(), 1, 1, MersenneTwister(4))
    POMDPs.transition(::M, ::Int, ::Int) = [1]
    @test gen(Return(:sp), M(), 1, 1, MersenneTwister(4)) == 1
    @test_throws MethodError gen(Return(:sp,:o,:r), M(), 1, 1, MersenneTwister(4))
    @test_throws MethodError gen(Return(:sp,:r), M(), 1, 1, MersenneTwister(4))
    POMDPs.reward(::M, ::Int, ::Int, ::Int) = 0.0
    POMDPs.gen(::Return{:o}, ::M, ::Int, ::Int, ::Int, ::AbstractRNG) = `a`
    @test gen(Return(:sp,:r), M(), 1, 1, MersenneTwister(4)) == (1, 0.0)
    @test gen(Return(:sp,:o,:r), M(), 1, 1, MersenneTwister(4)) == (1, `a`, 0.0)
end
