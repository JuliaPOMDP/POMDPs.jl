import POMDPs: transition, reward, initial_state_distribution
import POMDPs: generate_sr, generate_o

struct W <: POMDP{Int, Bool, Int} end
println("Warning expected:")
@test_throws MethodError initial_state(W(), Base.GLOBAL_RNG)
println("Warning expected:")
@test_throws MethodError generate_s(W(), 1, true, Base.GLOBAL_RNG)
println("Warning expected:")
@test_throws MethodError generate_sr(W(), 1, true, Base.GLOBAL_RNG)
println("Warning expected:")
@test_throws MethodError generate_o(W(), 1, true, 2, Base.GLOBAL_RNG)
println("Warning expected:")
@test_throws MethodError generate_so(W(), 1, true, Base.GLOBAL_RNG)
println("Warning expected:")
@test_throws MethodError generate_sor(W(), 1, true, Base.GLOBAL_RNG)
println("Warning expected:")
@test_throws MethodError generate_or(W(), 1, true, 2, Base.GLOBAL_RNG)


mutable struct B <: POMDP{Int, Bool, Bool} end

transition(b::B, s::Int, a::Bool) = Int[s+a]
@test implemented(generate_s, Tuple{B, Int, Bool, MersenneTwister})
@test generate_s(B(), 1, false, Base.GLOBAL_RNG) == 1

@test !@implemented generate_sor(::B, ::Int, ::Bool, ::MersenneTwister)
# @test_throws MethodError generate_sor(B(), 1, false, Base.GLOBAL_RNG)

reward(b::B, s::Int, a::Bool, sp::Int) = -1.0
@test generate_sr(B(), 1, false, Base.GLOBAL_RNG) == (1, -1.0)

generate_o(b::B, s::Int, a::Bool, sp::Int, rng::AbstractRNG) = sp
@test @implemented generate_o(b::B, s::Int, a::Bool, sp::Int, rng::AbstractRNG)
@test @implemented generate_so(b::B, s::Int, a::Bool, rng::MersenneTwister)
@test @implemented generate_sor(b::B, s::Int, a::Bool, rng::MersenneTwister)
@test generate_sor(B(), 1, true, Base.GLOBAL_RNG) == (2, 2, -1.0) # should throw sor error

initial_state_distribution(b::B) = Int[1,2,3]
@test initial_state(B(), Base.GLOBAL_RNG) in initial_state_distribution(B())


mutable struct C <: POMDP{Void, Void, Void} end
generate_sr(c::C, s::Void, a::Void, rng::AbstractRNG) = nothing, 0.0
generate_o(c::C, s::Void, a::Void, sp::Void, rng::AbstractRNG) = nothing
@test @implemented generate_sor(::C, ::Void, ::Void, ::MersenneTwister)
@test generate_sor(C(), nothing, nothing, Base.GLOBAL_RNG) == (nothing, nothing, 0.0)
