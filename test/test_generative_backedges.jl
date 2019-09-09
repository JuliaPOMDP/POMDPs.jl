using Test
using POMDPs
using Random

let
    struct M <: POMDP{Int, Int, Char} end
    @test_throws DistributionNotImplemented gen(DBNVar(:sp), M(), 1, 1, MersenneTwister(4))
    POMDPs.transition(::M, ::Int, ::Int) = [1]
    @test gen(DBNVar(:sp), M(), 1, 1, MersenneTwister(4)) == 1
    @test_throws DistributionNotImplemented gen(DBNOut(:sp,:o,:r), M(), 1, 1, MersenneTwister(4))
    @test_throws DistributionNotImplemented gen(DBNOut(:sp,:r), M(), 1, 1, MersenneTwister(4))
    POMDPs.reward(::M, ::Int, ::Int, ::Int) = 0.0
    POMDPs.gen(::DBNVar{:o}, ::M, ::Int, ::Int, ::Int, ::AbstractRNG) = `a`
    @test gen(DBNOut(:sp,:r), M(), 1, 1, MersenneTwister(4)) == (1, 0.0)
    @test gen(DBNOut(:sp,:o,:r), M(), 1, 1, MersenneTwister(4)) == (1, `a`, 0.0)
end
