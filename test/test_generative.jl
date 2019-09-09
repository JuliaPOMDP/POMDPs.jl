import POMDPs: transition, reward, initialstate_distribution
import POMDPs: gen

struct W <: POMDP{Int, Bool, Int} end
@test_throws MethodError initialstate(W(), Random.GLOBAL_RNG)
@test_throws DistributionNotImplemented gen(DDNNode(:sp), W(), 1, true, Random.GLOBAL_RNG)
@test_throws DistributionNotImplemented gen(DDNOut(:sp,:r), W(), 1, true, Random.GLOBAL_RNG)
@test_throws DistributionNotImplemented gen(DDNNode(:o), W(), 1, true, 2, Random.GLOBAL_RNG)
@test_throws DistributionNotImplemented gen(DDNOut(:sp,:o), W(), 1, true, Random.GLOBAL_RNG)
@test_throws DistributionNotImplemented gen(DDNOut(:sp,:o,:r), W(), 1, true, Random.GLOBAL_RNG)
POMDPs.gen(::W, ::Int, ::Bool, ::AbstractRNG) = nothing
@test_throws AssertionError gen(DDNOut(:sp), W(), 1, true, Random.GLOBAL_RNG)
@test_throws AssertionError gen(DDNOut(:sp,:r), W(), 1, true, Random.GLOBAL_RNG)
POMDPs.gen(::W, ::Int, ::Bool, ::AbstractRNG) = (useless=nothing,)
@test_throws DistributionNotImplemented gen(DDNNode(:sp), W(), 1, true, Random.GLOBAL_RNG)
@test_throws DistributionNotImplemented gen(DDNOut(:sp,:r), W(), 1, true, Random.GLOBAL_RNG)

struct B <: POMDP{Int, Bool, Bool} end

transition(b::B, s::Int, a::Bool) = Int[s+a]
@test implemented(gen, Tuple{DDNNode{:sp}, B, Int, Bool, MersenneTwister})
@test @inferred gen(DDNNode(:sp), B(), 1, false, Random.GLOBAL_RNG) == 1

@test mightbemissing(@implemented(gen(::DDNOut{(:sp,:o,:r)}, ::B, ::Int, ::Bool, ::MersenneTwister)))
@test_throws DistributionNotImplemented gen(DDNOut(:sp,:o,:r), B(), 1, false, Random.GLOBAL_RNG)

reward(b::B, s::Int, a::Bool, sp::Int) = -1.0
gen(::DDNNode{:o}, b::B, s::Int, a::Bool, sp::Int, rng::AbstractRNG) = sp
@test @inferred gen(DDNOut(:sp,:r), B(), 1, false, Random.GLOBAL_RNG) == (1, -1.0)

@test @implemented gen(::DDNNode{:o}, b::B, s::Int, a::Bool, sp::Int, rng::AbstractRNG)
@test mightbemissing(@implemented(gen(::DDNOut{(:sp,:o)}, b::B, s::Int, a::Bool, rng::MersenneTwister)))
@test mightbemissing(@implemented gen(::DDNOut{(:sp,:o,:r)}, b::B, s::Int, a::Bool, rng::MersenneTwister))
@test @inferred gen(DDNOut(:sp,:o,:r), B(), 1, true, Random.GLOBAL_RNG) == (2, 2, -1.0)

initialstate_distribution(b::B) = Int[1,2,3]
@test initialstate(B(), Random.GLOBAL_RNG) in initialstate_distribution(B())

mutable struct C <: POMDP{Nothing, Nothing, Nothing} end
gen(::DDNNode{:sp}, c::C, s::Nothing, a::Nothing, rng::AbstractRNG) = nothing
gen(::DDNNode{:o}, c::C, s::Nothing, a::Nothing, sp::Nothing, rng::AbstractRNG) = nothing
reward(c::C, s::Nothing, a::Nothing) = 0.0
@test mightbemissing(@implemented gen(::DDNOut{(:sp,:o,:r)}, ::C, ::Nothing, ::Nothing, ::MersenneTwister))
@test @inferred gen(DDNOut(:sp,:o,:r), C(), nothing, nothing, Random.GLOBAL_RNG) == (nothing, nothing, 0.0)

struct GD <: MDP{Int, Int} end
struct Deterministic{T}
    x::T
end
Base.rand(rng::AbstractRNG, d::Deterministic) = d.x
POMDPs.transition(::GD, s, a) = Deterministic(s + a)
@test @inferred(gen(DDNNode(:sp), GD(), 1, 1, Random.GLOBAL_RNG)) == 2
POMDPs.reward(::GD, s, a) = s + a
@test @inferred(gen(DDNNode(:r), GD(), 1, 1, 2, Random.GLOBAL_RNG)) == 2

struct GE <: MDP{Int, Int} end
@test_throws DistributionNotImplemented gen(DDNNode(:sp), GE(), 1, 1, Random.GLOBAL_RNG)
@test_throws DistributionNotImplemented gen(DDNOut(:sp,:r), GE(), 1, 1, Random.GLOBAL_RNG)
POMDPs.gen(::GE, s, a, ::AbstractRNG) = (sp=s+a, r=s^2)
@show gen(DDNOut(:sp), GE(), 1, 1, Random.GLOBAL_RNG)
@test @inferred gen(DDNOut(:sp), GE(), 1, 1, Random.GLOBAL_RNG) == 2
@test @inferred gen(DDNOut(:sp,:r), GE(), 1, 1, Random.GLOBAL_RNG) == (2, 1)
