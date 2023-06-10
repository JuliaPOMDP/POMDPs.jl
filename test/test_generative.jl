import POMDPs: transition, observation, reward
import POMDPs: gen

struct Deterministic{T}
    x::T
end
Base.rand(rng::AbstractRNG, d::Deterministic) = d.x

struct W <: POMDP{Int, Bool, Int} end
@test_throws MethodError initialstate(W())
@test_throws MethodError initialobs(W(), 1)
try
    @gen(:sp)(W(), 1, true, Random.default_rng())
catch ex
    str = sprint(showerror, ex)
    @test occursin("transition", str)
end
@test_throws MethodError @gen(:sp,:r)(W(), 1, true, Random.default_rng())

@test_throws MethodError @gen(:sp,:o)(W(), 1, true, Random.default_rng())
@test_throws MethodError @gen(:sp,:o,:r)(W(), 1, true, Random.default_rng())
POMDPs.gen(::W, ::Int, ::Bool, ::AbstractRNG) = nothing
@test_throws AssertionError @gen(:sp)(W(), 1, true, Random.default_rng())
@test_throws AssertionError @gen(:sp,:r)(W(), 1, true, Random.default_rng())
POMDPs.gen(::W, ::Int, ::Bool, ::AbstractRNG) = (useless=nothing,)
@test_throws MethodError @gen(:sp,:r)(W(), 1, true, Random.default_rng())

transition(::W, s, a) = Deterministic(s)
@test_throws MethodError @gen(:o)(W(), 1, true, Random.default_rng())
try
    @gen(:o)(W(), 1, true, Random.default_rng())
catch ex
    str = sprint(showerror, ex)
    @test occursin("observation", str)
end

struct B <: POMDP{Int, Bool, Bool} end

transition(b::B, s::Int, a::Bool) = Deterministic(s+a)
@test @inferred_except_1_0(@gen(:sp)(B(), 1, false, Random.default_rng())) == 1

@test_throws MethodError @gen(:sp,:o,:r)(B(), 1, false, Random.default_rng())

reward(b::B, s::Int, a::Bool, sp::Int) = -1.0
observation(b::B, s::Int, a::Bool, sp::Int) = Deterministic(sp)
@test @inferred_except_1_0(@gen(:sp,:r)(B(), 1, false, Random.default_rng())) == (1, -1.0)

@test @inferred_except_1_0(@gen(:sp,:o,:r)(B(), 1, true, Random.default_rng())) == (2, 2, -1.0)

mutable struct C <: POMDP{Nothing, Nothing, Nothing} end
transition(c::C, s::Nothing, a::Nothing) = Deterministic(nothing)
observation(c::C, s::Nothing, a::Nothing, sp::Nothing) = Deterministic(nothing)
reward(c::C, s::Nothing, a::Nothing) = 0.0
@test @inferred_except_1_0(@gen(:sp,:o,:r)(C(), nothing, nothing, Random.default_rng())) == (nothing, nothing, 0.0)

struct GD <: MDP{Int, Int} end
POMDPs.transition(::GD, s, a) = Deterministic(s + a)
@test @inferred_except_1_0(@gen(:sp)(GD(), 1, 1, Random.default_rng())) == 2
POMDPs.reward(::GD, s, a) = s + a
@test @inferred_except_1_0(@gen(:r)(GD(), 1, 1, Random.default_rng())) == 2

struct GE <: MDP{Int, Int} end
@test_throws MethodError @gen(:sp)(GE(), 1, 1, Random.default_rng())
@test_throws MethodError @gen(:sp,:r)(GE(), 1, 1, Random.default_rng())
POMDPs.gen(::GE, s, a, ::AbstractRNG) = (sp=s+a, r=s^2)
@test @inferred_except_1_0(@gen(:sp)(GE(), 1, 1, Random.default_rng())) == 2
@test @inferred_except_1_0(@gen(:sp, :r)(GE(), 1, 1, Random.default_rng())) == (2, 1)
