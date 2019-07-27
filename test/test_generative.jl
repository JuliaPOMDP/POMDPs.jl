import POMDPs: transition, reward, initialstate_distribution
import POMDPs: gen

struct W <: POMDP{Int, Bool, Int} end
println("Warning expected:")
@test_throws MethodError initialstate(W(), Random.GLOBAL_RNG)
println("Warning expected:")
@test_throws MethodError gen(Return(:sp), W(), 1, true, Random.GLOBAL_RNG)
println("Warning expected:")
@test_throws MethodError gen(Return(:sp,:r), W(), 1, true, Random.GLOBAL_RNG)
println("Warning expected:")
@test_throws MethodError gen(Return(:o), W(), 1, true, 2, Random.GLOBAL_RNG)
println("Warning expected:")
@test_throws MethodError gen(Return(:sp,:o), W(), 1, true, Random.GLOBAL_RNG)
println("Warning expected:")
@test_throws MethodError gen(Return(:sp,:o,:r), W(), 1, true, Random.GLOBAL_RNG)
println("Warning expected:")
@test_throws MethodError gen(Return(:o,:r), W(), 1, true, 2, Random.GLOBAL_RNG)
POMDPs.gen(::W, ::Int, ::Bool, ::AbstractRNG) = nothing
@test_throws AssertionError gen(Return(:sp), W(), 1, true, Random.GLOBAL_RNG)
@test_throws AssertionError gen(Return(:sp,:r), W(), 1, true, Random.GLOBAL_RNG)
POMDPs.gen(::W, ::Int, ::Bool, ::AbstractRNG) = (useless=nothing,)
println("Warning expected:")
@test_throws MethodError gen(Return(:sp), W(), 1, true, Random.GLOBAL_RNG)
println("Warning expected:")
@test_throws MethodError gen(Return(:sp,:r), W(), 1, true, Random.GLOBAL_RNG)


struct B <: POMDP{Int, Bool, Bool} end

transition(b::B, s::Int, a::Bool) = Int[s+a]
@test implemented(gen, Tuple{Return{:sp}, B, Int, Bool, MersenneTwister})
@test gen(Return(:sp), B(), 1, false, Random.GLOBAL_RNG) == 1

@test !@implemented gen(::Return{(:sp,:o,:r)}, ::B, ::Int, ::Bool, ::MersenneTwister)
@test_throws MethodError gen(Return(:sp,:o,:r), B(), 1, false, Random.GLOBAL_RNG)

reward(b::B, s::Int, a::Bool, sp::Int) = -1.0
gen(::Return{:o}, b::B, s::Int, a::Bool, sp::Int, rng::AbstractRNG) = sp
@test gen(Return(:sp,:r), B(), 1, false, Random.GLOBAL_RNG) == (1, -1.0)

@test @implemented gen(::Return{:o}, b::B, s::Int, a::Bool, sp::Int, rng::AbstractRNG)
@test @implemented gen(::Return{(:sp,:o)}, b::B, s::Int, a::Bool, rng::MersenneTwister)
@test @implemented gen(::Return{(:sp,:o,:r)}, b::B, s::Int, a::Bool, rng::MersenneTwister)
@test gen(Return(:sp,:o,:r), B(), 1, true, Random.GLOBAL_RNG) == (2, 2, -1.0) # should throw sor error

initialstate_distribution(b::B) = Int[1,2,3]
@test initialstate(B(), Random.GLOBAL_RNG) in initialstate_distribution(B())

mutable struct C <: POMDP{Nothing, Nothing, Nothing} end
gen(::Return{:sp}, c::C, s::Nothing, a::Nothing, rng::AbstractRNG) = nothing
gen(::Return{:o}, c::C, s::Nothing, a::Nothing, sp::Nothing, rng::AbstractRNG) = nothing
reward(c::C, s::Nothing, a::Nothing) = 0.0
@test @implemented gen(::Return{(:sp,:o,:r)}, ::C, ::Nothing, ::Nothing, ::MersenneTwister)
@test gen(Return(:sp,:o,:r), C(), nothing, nothing, Random.GLOBAL_RNG) == (nothing, nothing, 0.0)
