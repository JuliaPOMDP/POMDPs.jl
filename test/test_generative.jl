import POMDPs: transition, observation, reward, initialstate_distribution
import POMDPs: gen

struct Deterministic{T}
    x::T
end
Base.rand(rng::AbstractRNG, d::Deterministic) = d.x

struct W <: POMDP{Int, Bool, Int} end
@test_throws MethodError initialstate(W())
@test_throws MethodError initialobs(W(), 1)
try
    @gen(:sp)(W(), 1, true, Random.GLOBAL_RNG)
catch ex
    str = sprint(showerror, ex)
    @test occursin("transition", str)
end
@test_throws MethodError @gen(:sp,:r)(W(), 1, true, Random.GLOBAL_RNG)

@test_throws MethodError @gen(:sp,:o)(W(), 1, true, Random.GLOBAL_RNG)
@test_throws MethodError @gen(:sp,:o,:r)(W(), 1, true, Random.GLOBAL_RNG)
POMDPs.gen(::W, ::Int, ::Bool, ::AbstractRNG) = nothing
@test_throws AssertionError @gen(:sp)(W(), 1, true, Random.GLOBAL_RNG)
@test_throws AssertionError @gen(:sp,:r)(W(), 1, true, Random.GLOBAL_RNG)
POMDPs.gen(::W, ::Int, ::Bool, ::AbstractRNG) = (useless=nothing,)
@test_throws MethodError @gen(:sp,:r)(W(), 1, true, Random.GLOBAL_RNG)

transition(::W, s, a) = Deterministic(s)
@test_throws MethodError @gen(:o)(W(), 1, true, Random.GLOBAL_RNG)
try
    @gen(:o)(W(), 1, true, Random.GLOBAL_RNG)
catch ex
    str = sprint(showerror, ex)
    @test occursin("observation", str)
end

struct B <: POMDP{Int, Bool, Bool} end

transition(b::B, s::Int, a::Bool) = Deterministic(s+a)
@test @inferred(@gen(:sp)(B(), 1, false, Random.GLOBAL_RNG)) == 1

@test_throws MethodError @gen(:sp,:o,:r)(B(), 1, false, Random.GLOBAL_RNG)

reward(b::B, s::Int, a::Bool, sp::Int) = -1.0
observation(b::B, s::Int, a::Bool, sp::Int) = Deterministic(sp)
@test @inferred(@gen(:sp,:r)(B(), 1, false, Random.GLOBAL_RNG)) == (1, -1.0)

@test @inferred(@gen(:sp,:o,:r)(B(), 1, true, Random.GLOBAL_RNG)) == (2, 2, -1.0)

mutable struct C <: POMDP{Nothing, Nothing, Nothing} end
transition(c::C, s::Nothing, a::Nothing) = Deterministic(nothing)
observation(c::C, s::Nothing, a::Nothing, sp::Nothing) = Deterministic(nothing)
reward(c::C, s::Nothing, a::Nothing) = 0.0
@test @inferred(@gen(:sp,:o,:r)(C(), nothing, nothing, Random.GLOBAL_RNG)) == (nothing, nothing, 0.0)

struct GD <: MDP{Int, Int} end
POMDPs.transition(::GD, s, a) = Deterministic(s + a)
@test @inferred(@gen(:sp)(GD(), 1, 1, Random.GLOBAL_RNG)) == 2
POMDPs.reward(::GD, s, a) = s + a
@test @inferred(@gen(:r)(GD(), 1, 1, Random.GLOBAL_RNG)) == 2

struct GE <: MDP{Int, Int} end
@test_throws MethodError @gen(:sp)(GE(), 1, 1, Random.GLOBAL_RNG)
@test_throws MethodError @gen(:sp,:r)(GE(), 1, 1, Random.GLOBAL_RNG)
POMDPs.gen(::GE, s, a, ::AbstractRNG) = (sp=s+a, r=s^2)
@test @inferred(@gen(:sp)(GE(), 1, 1, Random.GLOBAL_RNG)) == 2
@test @inferred(@gen(:sp, :r)(GE(), 1, 1, Random.GLOBAL_RNG)) == (2, 1)
