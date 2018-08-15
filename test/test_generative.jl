import POMDPs: transition, reward, initialstate_distribution
import POMDPs: generate_sr, generate_o

struct W <: POMDP{Int, Bool, Int} end
println("Warning expected:")
@test_throws MethodError initialstate(W(), Random.GLOBAL_RNG)
println("Warning expected:")
@test_throws MethodError generate_s(W(), 1, true, Random.GLOBAL_RNG)
println("Warning expected:")
@test_throws MethodError generate_sr(W(), 1, true, Random.GLOBAL_RNG)
println("Warning expected:")
@test_throws MethodError generate_o(W(), 1, true, 2, Random.GLOBAL_RNG)
println("Warning expected:")
@test_throws MethodError generate_so(W(), 1, true, Random.GLOBAL_RNG)
println("Warning expected:")
@test_throws MethodError generate_sor(W(), 1, true, Random.GLOBAL_RNG)
println("Warning expected:")
@test_throws MethodError generate_or(W(), 1, true, 2, Random.GLOBAL_RNG)


mutable struct B <: POMDP{Int, Bool, Bool} end

transition(b::B, s::Int, a::Bool) = Int[s+a]
@test implemented(generate_s, Tuple{B, Int, Bool, MersenneTwister})
@test generate_s(B(), 1, false, Random.GLOBAL_RNG) == 1

@test !@implemented generate_sor(::B, ::Int, ::Bool, ::MersenneTwister)
# @test_throws MethodError generate_sor(B(), 1, false, Random.GLOBAL_RNG)

reward(b::B, s::Int, a::Bool, sp::Int) = -1.0
@test generate_sr(B(), 1, false, Random.GLOBAL_RNG) == (1, -1.0)

generate_o(b::B, s::Int, a::Bool, sp::Int, rng::AbstractRNG) = sp
@test @implemented generate_o(b::B, s::Int, a::Bool, sp::Int, rng::AbstractRNG)
@test @implemented generate_so(b::B, s::Int, a::Bool, rng::MersenneTwister)
@test @implemented generate_sor(b::B, s::Int, a::Bool, rng::MersenneTwister)
@test generate_sor(B(), 1, true, Random.GLOBAL_RNG) == (2, 2, -1.0) # should throw sor error

initialstate_distribution(b::B) = Int[1,2,3]
@test initialstate(B(), Random.GLOBAL_RNG) in initialstate_distribution(B())


mutable struct C <: POMDP{Nothing, Nothing, Nothing} end
generate_sr(c::C, s::Nothing, a::Nothing, rng::AbstractRNG) = nothing, 0.0
generate_o(c::C, s::Nothing, a::Nothing, sp::Nothing, rng::AbstractRNG) = nothing
@test @implemented generate_sor(::C, ::Nothing, ::Nothing, ::MersenneTwister)
@test generate_sor(C(), nothing, nothing, Random.GLOBAL_RNG) == (nothing, nothing, 0.0)
