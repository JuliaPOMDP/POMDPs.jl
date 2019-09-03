import POMDPs: transition, reward, initialstate_distribution
import POMDPs: gen

struct W <: POMDP{Int, Bool, Int} end
@test_throws MethodError initialstate(W(), Random.GLOBAL_RNG)
@test_throws MethodError gen(DBNVar(:sp), W(), 1, true, Random.GLOBAL_RNG)
@test_throws MethodError gen(DBNOut(:sp,:r), W(), 1, true, Random.GLOBAL_RNG)
@test_throws MethodError gen(DBNVar(:o), W(), 1, true, 2, Random.GLOBAL_RNG)
@test_throws MethodError gen(DBNOut(:sp,:o), W(), 1, true, Random.GLOBAL_RNG)
@test_throws MethodError gen(DBNOut(:sp,:o,:r), W(), 1, true, Random.GLOBAL_RNG)
@test_throws MethodError gen(DBNOut(:o,:r), W(), 1, true, 2, Random.GLOBAL_RNG)
POMDPs.gen(::W, ::Int, ::Bool, ::AbstractRNG) = nothing
@test_throws AssertionError gen(DBNOut(:sp), W(), 1, true, Random.GLOBAL_RNG)
@test_throws AssertionError gen(DBNOut(:sp,:r), W(), 1, true, Random.GLOBAL_RNG)
POMDPs.gen(::W, ::Int, ::Bool, ::AbstractRNG) = (useless=nothing,)
@test_throws MethodError gen(DBNVar(:sp), W(), 1, true, Random.GLOBAL_RNG)
@test_throws MethodError gen(DBNOut(:sp,:r), W(), 1, true, Random.GLOBAL_RNG)

struct B <: POMDP{Int, Bool, Bool} end

transition(b::B, s::Int, a::Bool) = Int[s+a]
@test implemented(gen, Tuple{DBNVar{:sp}, B, Int, Bool, MersenneTwister})
@test @inferred gen(DBNVar(:sp), B(), 1, false, Random.GLOBAL_RNG) == 1

@test mightbemissing(@implemented(gen(::DBNOut{(:sp,:o,:r)}, ::B, ::Int, ::Bool, ::MersenneTwister)))
@test_throws MethodError gen(DBNOut(:sp,:o,:r), B(), 1, false, Random.GLOBAL_RNG)

reward(b::B, s::Int, a::Bool, sp::Int) = -1.0
gen(::DBNVar{:o}, b::B, s::Int, a::Bool, sp::Int, rng::AbstractRNG) = sp
@test @inferred gen(DBNOut(:sp,:r), B(), 1, false, Random.GLOBAL_RNG) == (1, -1.0)

@test @implemented gen(::DBNVar{:o}, b::B, s::Int, a::Bool, sp::Int, rng::AbstractRNG)
@test mightbemissing(@implemented(gen(::DBNOut{(:sp,:o)}, b::B, s::Int, a::Bool, rng::MersenneTwister)))
@test mightbemissing(@implemented gen(::DBNOut{(:sp,:o,:r)}, b::B, s::Int, a::Bool, rng::MersenneTwister))
@test @inferred gen(DBNOut(:sp,:o,:r), B(), 1, true, Random.GLOBAL_RNG) == (2, 2, -1.0)

initialstate_distribution(b::B) = Int[1,2,3]
@test initialstate(B(), Random.GLOBAL_RNG) in initialstate_distribution(B())

mutable struct C <: POMDP{Nothing, Nothing, Nothing} end
gen(::DBNVar{:sp}, c::C, s::Nothing, a::Nothing, rng::AbstractRNG) = nothing
gen(::DBNVar{:o}, c::C, s::Nothing, a::Nothing, sp::Nothing, rng::AbstractRNG) = nothing
reward(c::C, s::Nothing, a::Nothing) = 0.0
@test mightbemissing(@implemented gen(::DBNOut{(:sp,:o,:r)}, ::C, ::Nothing, ::Nothing, ::MersenneTwister))
@test @inferred gen(DBNOut(:sp,:o,:r), C(), nothing, nothing, Random.GLOBAL_RNG) == (nothing, nothing, 0.0)

struct GD <: MDP{Int, Int} end
struct Deterministic{T}
    x::T
end
Base.rand(rng::AbstractRNG, d::Deterministic) = d.x
POMDPs.transition(::GD, s, a) = Deterministic(s + a)
@test @inferred(gen(DBNVar(:sp), GD(), 1, 1, Random.GLOBAL_RNG)) == 2
POMDPs.reward(::GD, s, a) = s + a
@test @inferred(gen(DBNVar(:r), GD(), 1, 1, 2, Random.GLOBAL_RNG)) == 2

struct GE <: MDP{Int, Int} end
@test_throws MethodError gen(DBNVar(:sp), GE(), 1, 1, Random.GLOBAL_RNG)
@test_throws MethodError gen(DBNOut(:sp,:r), GE(), 1, 1, Random.GLOBAL_RNG)
POMDPs.gen(::GE, s, a, ::AbstractRNG) = (sp=s+a, r=s^2)
@show gen(DBNOut(:sp), GE(), 1, 1, Random.GLOBAL_RNG)
@test @inferred gen(DBNOut(:sp), GE(), 1, 1, Random.GLOBAL_RNG) == 2
@test @inferred gen(DBNOut(:sp,:r), GE(), 1, 1, Random.GLOBAL_RNG) == (2, 1)
