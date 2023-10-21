const RL = CommonRLInterface

abstract type AbstractPOMDPsCommonRLEnv <: RL.AbstractEnv end

RL.actions(env::AbstractPOMDPsCommonRLEnv) = actions(env.m)
RL.terminated(env::AbstractPOMDPsCommonRLEnv) = isterminal(env.m, env.s)

mutable struct MDPCommonRLEnv{RLO, M<:MDP, S} <: AbstractPOMDPsCommonRLEnv
    m::M
    s::S
end

"""
    MDPCommonRLEnv(m, [s])
    MDPCommonRLEnv{RLO}(m, [s])

Create a CommonRLInterface environment from MDP m; optionally specify the state 's'.

The `RLO` parameter can be used to specify a type to convert the observation to. By default, this is `AbstractArray`. Use `Any` to disable conversion.
"""
MDPCommonRLEnv{RLO}(m, s=rand(initialstate(m))) where {RLO} = MDPCommonRLEnv{RLO, typeof(m), statetype(m)}(m, s)
MDPCommonRLEnv(m, s=rand(initialstate(m))) = MDPCommonRLEnv{AbstractArray}(m, s)

function RL.reset!(env::MDPCommonRLEnv)
    env.s = rand(initialstate(env.m))
    return nothing
end

function RL.act!(env::MDPCommonRLEnv, a)
    sp, r = @gen(:sp, :r)(env.m, env.s, a)
    env.s = sp
    return r
end

RL.observe(env::MDPCommonRLEnv{RLO}) where {RLO} = convert_s(RLO, env.s, env.m)

RL.clone(env::MDPCommonRLEnv{RLO}) where {RLO} = MDPCommonRLEnv{RLO}(env.m, env.s)
RL.render(env::MDPCommonRLEnv) = render(env.m, (sp=env.s,))
RL.state(env::MDPCommonRLEnv{RLO}) where {RLO} = convert_s(RLO, env.s, env.m)
RL.valid_actions(env::MDPCommonRLEnv) = actions(env.m, env.s)

RL.observations(env::MDPCommonRLEnv{RLO}) where {RLO} = (convert_s(RLO, s, env.m) for s in states(env.m)) # should really be some kind of lazy map that handles uncountably infinite spaces
RL.provided(::typeof(RL.observations), ::Type{<:Tuple{MDPCommonRLEnv{<:Any, M, <:Any}}}) where {M} = static_hasmethod(states, Tuple{<:M})

function RL.setstate!(env::MDPCommonRLEnv{<:Any, <:Any, S}, s) where S
    env.s = convert_s(S, s, env.m)
    return nothing
end

mutable struct POMDPCommonRLEnv{RLO, RLS, M<:POMDP, S, O} <: AbstractPOMDPsCommonRLEnv
    m::M
    s::S
    o::O
end

"""
    POMDPCommonRLEnv(m, [s], [o])
    POMDPCommonRLEnv{RLO}(m, [s], [o])

Create a CommonRLInterface environment from POMDP m; optionally specify the state 's' and observation 'o'.

The `RLO` and `RLS` parameters can be used to specify types to convert the observation and state to. By default, this is `AbstractArray`. Use `Any` to disable conversion.
"""
POMDPCommonRLEnv{RLO,RLS}(m, s=rand(initialstate(m)), o=rand(initialobs(m, s))) where {RLO,RLS} = POMDPCommonRLEnv{RLO,RLS,typeof(m),statetype(m),obstype(m)}(m, s, o)
POMDPCommonRLEnv{RLO}(m, s=rand(initialstate(m)), o=rand(initialobs(m, s))) where {RLO} = POMDPCommonRLEnv{RLO,AbstractArray,typeof(m),statetype(m),obstype(m)}(m, s, o)
POMDPCommonRLEnv(m, s=rand(initialstate(m)), o=rand(initialobs(m, s))) = POMDPCommonRLEnv{AbstractArray,AbstractArray}(m, s, o)

function RL.reset!(env::POMDPCommonRLEnv)
    env.s = rand(initialstate(env.m))
    env.o = rand(initialobs(env.m, env.s))
    return nothing
end

function RL.act!(env::POMDPCommonRLEnv, a)
    sp, o, r = @gen(:sp, :o, :r)(env.m, env.s, a)
    env.s = sp
    env.o = o
    return r
end

RL.observe(env::POMDPCommonRLEnv{RLO}) where {RLO} = convert_o(RLO, env.o, env.m)

RL.clone(env::POMDPCommonRLEnv{RLO,RLS}) where {RLO,RLS} = POMDPCommonRLEnv{RLO,RLS}(env.m, env.s, env.o)
RL.render(env::POMDPCommonRLEnv) = render(env.m, (sp=env.s, o=env.o))
RL.state(env::POMDPCommonRLEnv{RLO,RLS}) where {RLO,RLS} = convert_s(RLS, env.s, env.m)
RL.valid_actions(env::POMDPCommonRLEnv) = actions(env.m, env.s)

RL.observations(env::POMDPCommonRLEnv{RLO}) where {RLO} = (convert_o(RLO, o, env.m) for o in observations(env.m)) # should really be some kind of lazy map that handles uncountably infinite spaces
RL.provided(::typeof(RL.observations), ::Type{<:Tuple{POMDPCommonRLEnv{<:Any,<:Any,M,<:Any,<:Any}}}) where {M} = static_hasmethod(observations, Tuple{<:M})

function RL.setstate!(env::POMDPCommonRLEnv{<:Any,<:Any,<:Any,S}, s) where {S}
    env.s = convert_s(S, s, env.m)
    env.o = rand(initialobs(env.m, env.s))
    return nothing
end

Base.convert(::Type{RL.AbstractEnv}, m::POMDP) = POMDPCommonRLEnv(m)
Base.convert(::Type{RL.AbstractEnv}, m::MDP) = MDPCommonRLEnv(m)

POMDPsCommonRLEnv(m::POMDP, s) = POMDPCommonRLEnv(m, s)
POMDPsCommonRLEnv(m::MDP, s) = MDPCommonRLEnv(m, s)

Base.convert(::Type{MDP}, env::MDPCommonRLEnv) = env.m
Base.convert(::Type{POMDP}, env::POMDPCommonRLEnv) = env.m
