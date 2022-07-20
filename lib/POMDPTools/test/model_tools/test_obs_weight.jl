import POMDPModelTools: obs_weight
import POMDPs: observation

struct P <: POMDP{Nothing, Nothing, Nothing} end

POMDPs.observation(::P, ::Nothing) = Deterministic(nothing)
@test obs_weight(P(), nothing, nothing, nothing, nothing) == 1.0

#=
@test !@implemented obs_weight(::P, ::Nothing, ::Nothing, ::Nothing, ::Nothing)
@test !@implemented obs_weight(::P, ::Nothing, ::Nothing, ::Nothing)
@test !@implemented obs_weight(::P, ::Nothing, ::Nothing)

obs_weight(::P, ::Nothing, ::Nothing, ::Nothing) = 1.0

@test @implemented obs_weight(::P, ::Nothing, ::Nothing, ::Nothing)
@test @implemented obs_weight(::P, ::Nothing, ::Nothing, ::Nothing, ::Nothing)
@test !@implemented obs_weight(::P, ::Nothing, ::Nothing)
=#
