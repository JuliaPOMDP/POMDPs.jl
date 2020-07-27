using Test
using POMDPs
using Random

let
    struct M <: POMDP{Int, Int, Char} end
    @test_throws MethodError @gen(:sp)(M(), 1, 1, MersenneTwister(4))
    POMDPs.transition(::M, ::Int, ::Int) = [1]
    @test @gen(:sp)(M(), 1, 1, MersenneTwister(4)) == 1
    @test_throws MethodError @gen(:sp,:o,:r)(M(), 1, 1, MersenneTwister(4))
    @test_throws MethodError @gen(:sp,:r)(M(), 1, 1, MersenneTwister(4))
    POMDPs.reward(::M, ::Int, ::Int, ::Int) = 0.0
    POMDPs.observation(::M, ::Int, ::Int, ::Int) = ['a']
    @test @gen(:sp,:r)(M(), 1, 1, MersenneTwister(4)) == (1, 0.0)
    @test @gen(:sp,:o,:r)(M(), 1, 1, MersenneTwister(4)) == (1, 'a', 0.0)

    @test_throws MethodError initialobs(M(), 1)
    POMDPs.initialobs(::M, ::Int) = ['a']
    @test rand(MersenneTwister(4), initialobs(M(), 1)) == 'a'
end
