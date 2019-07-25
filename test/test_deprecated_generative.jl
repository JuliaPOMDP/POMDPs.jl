struct DW <: POMDP{Int, Bool, Int} end
println("Warning expected:")
@test_throws MethodError generate_s(DW(), 1, true, Random.GLOBAL_RNG)
println("Warning expected:")
@test_throws MethodError generate_sr(DW(), 1, true, Random.GLOBAL_RNG)
println("Warning expected:")
@test_throws MethodError generate_o(DW(), 1, true, 2, Random.GLOBAL_RNG)
println("Warning expected:")
@test_throws MethodError generate_so(DW(), 1, true, Random.GLOBAL_RNG)
println("Warning expected:")
@test_throws MethodError generate_sor(DW(), 1, true, Random.GLOBAL_RNG)
println("Warning expected:")
@test_throws MethodError generate_or(DW(), 1, true, 2, Random.GLOBAL_RNG)


struct DB <: POMDP{Int, Bool, Bool} end

POMDPs.transition(b::DB, s::Int, a::Bool) = Int[s+a]
@test implemented(generate_s, Tuple{DB, Int, Bool, MersenneTwister})
@test generate_s(DB(), 1, false, Random.GLOBAL_RNG) == 1

@test !@implemented generate_sor(::DB, ::Int, ::Bool, ::MersenneTwister)
# don't run this test because it will compile gen(::Val{:o},...) and I don't want to deal with the backedges
# @test_throws MethodError generate_sor(DB(), 1, false, Random.GLOBAL_RNG)

POMDPs.reward(b::DB, s::Int, a::Bool, sp::Int) = -1.0
POMDPs.generate_o(b::DB, s::Int, a::Bool, sp::Int, rng::AbstractRNG) = sp
@test @implemented generate_o(b::DB, s::Int, a::Bool, sp::Int, rng::MersenneTwister)
@test generate_sr(DB(), 1, false, Random.GLOBAL_RNG) == (1, -1.0)
@test @implemented generate_so(b::DB, s::Int, a::Bool, rng::MersenneTwister)
@test @implemented generate_sor(b::DB, s::Int, a::Bool, rng::MersenneTwister)
@test generate_sor(DB(), 1, true, Random.GLOBAL_RNG) == (2, 2, -1.0)

## This will no longer work
# struct DC <: POMDP{Nothing, Nothing, Nothing} end
# POMDPs.generate_sr(c::DC, s::Nothing, a::Nothing, rng::AbstractRNG) = nothing, 0.0
# POMDPs.generate_o(c::DC, s::Nothing, a::Nothing, sp::Nothing, rng::AbstractRNG) = nothing
# @test @implemented generate_sor(::DC, ::Nothing, ::Nothing, ::MersenneTwister)
# @test generate_sor(DC(), nothing, nothing, Random.GLOBAL_RNG) == (nothing, nothing, 0.0)
