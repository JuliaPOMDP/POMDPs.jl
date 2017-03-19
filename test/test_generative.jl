import POMDPs: transition, reward, initial_state_distribution
import POMDPs: generate_o

println("Warning expected:")
@test_throws MethodError initial_state(A(), Base.GLOBAL_RNG)
println("Warning expected:")
@test_throws MethodError generate_s(A(), 1, true, Base.GLOBAL_RNG)

type B <: POMDP{Int, Bool, Bool} end

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
