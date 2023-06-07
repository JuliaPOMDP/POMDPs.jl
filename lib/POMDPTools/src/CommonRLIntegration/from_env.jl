abstract type AbstractRLEnvMDP{S, A} <: MDP{S, A} end
abstract type AbstractRLEnvPOMDP{S, A, O} <: POMDP{S, A, O} end

const AbstractRLEnvProblem = Union{AbstractRLEnvMDP, AbstractRLEnvPOMDP}

POMDPs.actions(m::AbstractRLEnvProblem) = RL.actions(m.env)
POMDPs.discount(m::AbstractRLEnvProblem) = m.discount

function with_temporary_state(f, env, s)
    old = AD.state(env)
    AD.setstate!(env, s)
    ret = f(env)
    AD.setstate!(env, old)
    return ret
end

function with_temporary_state(f, env)
    old = AD.state(env)
    ret = f(env)
    AD.setstate!(env, old)
    return ret
end

function POMDPs.actions(m::AbstractRLEnvProblem, s)
    with_temporary_state(m.env, s) do env
        return AD.valid_actions(env)
    end
end

function POMDPs.initialstate(m::AbstractRLEnvProblem)
    return ImplicitDistribution(m) do m, rng
        # currently ignores rng
        with_temporary_state(m.env) do env
            AD.reset!(env)
            return AD.state(env)
        end
    end
end

function POMDPs.isterminal(m::AbstractRLEnvProblem, s)
    with_temporary_state(m.env, s) do env
        return AD.terminated(env)
    end
end

struct RLEnvMDP{E, S, A} <: AbstractRLEnvMDP{S, A}
    env::E
    discount::Float64
end

"""
    RLEnvMDP(env; discount=1.0)

Create an `MDP` by wrapping a `CommonRLInterface.AbstractEnv`. `state` and `setstate!` from `CommonRLInterface` must be provided, and the `POMDPs` generative model functionality will be provided.
"""
function RLEnvMDP(env; discount=1.0)
    S = infer_statetype(env)
    if S == Any
        @warn("State type inferred for $(typeof(env)) by looking at the return type of state(env) was Any. This could cause significant performance degradation.")
    end
    return RLEnvMDP{typeof(env), S, eltype(AD.actions(env))}(env, discount)
end

function POMDPs.gen(m::RLEnvMDP, s, a, rng)
    # rng is not currently used
    with_temporary_state(m.env, s) do env
        r = AD.act!(m.env, a)
        sp = AD.state(m.env)
        return (sp=sp, r=r)
    end
end

"""
    RLEnvPOMDP(env; discount=1.0)

Create an `POMDP` by wrapping a `CommonRLInterface.AbstractEnv`. `state` and `setstate!` from `CommonRLInterface` must be provided, and the `POMDPs` generative model functionality will be provided.
"""
struct RLEnvPOMDP{E, S, A, O} <: AbstractRLEnvPOMDP{S, A, O}
    env::E
    discount::Float64
end

function RLEnvPOMDP(env; discount=1.0)
    S = infer_statetype(env)
    if S == Any
        @warn("State type inferred for $(typeof(env)) by looking at the return type of state(env) was Any. This could cause significant performance degradation.")
    end
    O = infer_obstype(env)
    if S == Any
        @warn("Observation type inferred for $(typeof(env)) by looking at the return type of observe(env) was Any. This could cause significant performance degradation.")
    end
    return RLEnvPOMDP{typeof(env), S, eltype(AD.actions(env)), O}(env, discount)
end


function POMDPs.gen(m::RLEnvPOMDP, s, a, rng)
    with_temporary_state(m.env, s) do env
        r = AD.act!(env, a)
        sp = AD.state(env)
        o = AD.observe(env)
        return (sp=sp, o=o, r=r)
    end
end

#####################
# Opaque: for when state and setstate! are not implemented
#####################

struct OpaqueRLEnvState
    age::BigInt
end

mutable struct OpaqueRLEnvMDP{E, A} <: AbstractRLEnvMDP{OpaqueRLEnvState, A}
    env::E
    age::BigInt
    discount::Float64
end

"""
    OpaqueRLEnvMDP(env; discount=1.0)

Wrap a `CommonRLInterface.AbstractEnv` in an `MDP` object. The state will be an `OpaqueRLEnvState` and only simulation will be supported.
"""
function OpaqueRLEnvMDP(env; discount::Float64=1.0)
    return OpaqueRLEnvMDP{typeof(env), eltype(AD.actions(env))}(env, 1, discount)
end

mutable struct OpaqueRLEnvPOMDP{E, A, O} <: AbstractRLEnvPOMDP{OpaqueRLEnvState, A, O}
    env::E
    age::BigInt
    discount::Float64
end

"""
    OpaqueRLEnvPOMDP(env; discount=1.0)

Wrap a `CommonRLInterface.AbstractEnv` in an `POMDP` object. The state will be an `OpaqueRLEnvState` and only simulation will be supported.
"""
function OpaqueRLEnvPOMDP(env, discount=1.0)
    return OpaqueRLEnvPOMDP{typeof(env), eltype(AD.actions(env)), typeof(AD.observe(env))}(env, 1, discount)
end

const OpaqueRLEnvProblem = Union{OpaqueRLEnvMDP, OpaqueRLEnvPOMDP}

function POMDPs.actions(m::OpaqueRLEnvProblem, s::OpaqueRLEnvState)
    if s.age == m.age
        return AD.valid_actions(m.env)
    else
        throw(OpaqueRLEnvStateError(m.env, m.age, s))
    end
end

function POMDPs.initialstate(m::OpaqueRLEnvProblem)
    return ImplicitDistribution(m) do m, rng
        AD.reset!(m.env)
        m.age += 1
        return OpaqueRLEnvState(m.age)
    end
end

function POMDPs.isterminal(m::OpaqueRLEnvProblem, s::OpaqueRLEnvState)
    if s.age != m.age
        throw(OpaqueRLEnvStateError(m.env, m.age, s))
    end
    return AD.terminated(m.env)
end


function POMDPs.gen(m::OpaqueRLEnvMDP, s::OpaqueRLEnvState, a, rng)
    if s.age == m.age
        r = AD.act!(m.env, a)
        m.age += 1
        return (sp=OpaqueRLEnvState(m.age), r=r)
    else
        throw(OpaqueRLEnvStateError(m.env, m.age, s))
    end
end

function POMDPs.gen(m::OpaqueRLEnvPOMDP, s::OpaqueRLEnvState, a, rng)
    if s.age == m.age
        r = AD.act!(m.env, a)
        o = AD.observe(m.env)
        m.age += 1
        return (sp=OpaqueRLEnvState(m.age), o=o, r=r)
    else
        throw(OpaqueRLEnvStateError(m.env, m.age, s))
    end
end

function Base.convert(::Type{POMDP}, env::RL.AbstractEnv)
     if RL.provided(RL.state, env)
        s = RL.state(env)
        if RL.provided(RL.setstate!, env, s)
            return RLEnvPOMDP(env)
        end
    end
    return OpaqueRLEnvPOMDP(env)
end

function Base.convert(::Type{MDP}, env::RL.AbstractEnv)
    if RL.provided(RL.state, env)
        s = RL.state(env)
        if RL.provided(RL.setstate!, env, s)
            return RLEnvMDP(env)
        end
    end
    return OpaqueRLEnvMDP(env)
end

Base.convert(E::Type{<:RL.AbstractEnv}, m::AbstractRLEnvProblem) = convert(E, m.env)
Base.convert(::Type{RL.AbstractEnv}, m::AbstractRLEnvProblem) = m.env

struct OpaqueRLEnvStateError <: Exception
    env
    env_age::BigInt
    s::OpaqueRLEnvState
end

function Base.showerror(io::IO, e::OpaqueRLEnvStateError)
    print(io, "OpaqueRLEnvStateError: ")
    print(io, """An attempt was made to interact with the environment encapsulated in an `OpaqueRLEnv(PO)MDP` at a particular state, but the environment had been stepped forward, so it may be in a different state.

              Enironment age: $(e.env_age)
              State age: $(e.s.age)
                
              Suggestions: provide `CommonRLInterface.state(::$(typeof(e.env)))` and `CommonRLInterface.setstate!(::$(typeof(e.env)), s)` so that the environment can be converted to a `RLEnv(PO)MDP` instead of an `OpaqueRLEnv(PO)MDP`.
              """)
end

function infer_statetype(env)
    try
        return only(Base.return_types(RL.state, Tuple{typeof(env)}))
    catch ex
        @warn("""Unable to infer state type for $(typeof(env)) because of the following error:

              $(sprint(showerror, ex))
              
              Falling back to Any.
              """)
        return Any
    end
end

function infer_obstype(env)
    try
        return only(Base.return_types(RL.observe, Tuple{typeof(env)}))
    catch ex
        @warn("""Unable to infer observation type for $(typeof(env)) because of the following error:

              $(sprint(showerror, ex))
              
              Falling back to Any.
              """)
        return Any
    end
end
