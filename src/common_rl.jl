const RL = CommonRLInterface

abstract type AbstractPOMDPsCommonRLEnv <: RL.AbstractMarkovEnv end

RL.actions(env::AbstractPOMDPsCommonRLEnv) = actions(env.m)
RL.terminated(env::AbstractPOMDPsCommonRLEnv) = isterminal(env.m, env.s)

mutable struct MDPCommonRLEnv{M<:MDP, S, RO} <: AbstractPOMDPsCommonRLEnv
    m::M
    s::S
    rl_obstype::Type{RO}
end

function Base.convert(::Type{RL.AbstractMarkovEnv}, m::MDP)
    s = rand(initialstate(m))
    return MDPCommonRLEnv(m, s, AbstractArray)
end
Base.convert(::Type{RL.AbstractEnv}, m::MDP) = convert(RL.AbstractMarkovEnv, m)

function RL.reset!(env::MDPCommonRLEnv)
    env.s = rand(initialstate(env.m))
    return nothing
end

function RL.act!(env::MDPCommonRLEnv, a)
    sp, r = @gen(:sp, :r)(env.m, env.s, a)
    env.s = sp
    return r
end

RL.observe(env::MDPCommonRLEnv) = convert_s(env.rl_obstype, env.s, env.m)

RL.@provide RL.clone(env::MDPCommonRLEnv) = MDPCommonRLEnv(env.m, env.s, env.rl_obstype)
# Below will need to be moved to POMDPModelTools or POMDPModelTools will need to be moved to POMDPs
# RL.@provide RL.render(env::MDPCommonRLEnv) = render(env.m, (sp=env.s,))
RL.@provide RL.state(env::MDPCommonRLEnv) = convert_s(env.rl_obstype, env.s, env.m)
RL.@provide RL.valid_actions(env::MDPCommonRLEnv) = actions(env.m, env.s)
RL.@provide RL.observations(env::MDPCommonRLEnv) = (convert_s(env.rl_obstype, s, env.m) for s in states(env.m))


# # When @provide supports where syntax, it should be this:
# RL.@provide function RL.setstate!(env::MDPCommonRLEnv{<:Any, S}, s) where S
#     env.s = convert_s(S, s, env.m)
#     return nothing
# end
RL.provided(::typeof(RL.setstate!), ::Type{Tuple{<:MDPCommonRLEnv, <:Any}}) = true
function RL.setstate!(env::MDPCommonRLEnv{<:Any, S}, s) where S
    env.s = convert_s(S, s, env.m)
    return nothing
end

#=
mutable struct POMDPCommonRLEnv{M<:POMDP, S, O} <: AbstractPOMDPsCommonRLEnv
    m::M
    s::S
    o::O
end

function convert(::Type{RL.AbstractMarkovEnv}, m::POMDP)
    
end




struct CommonRLMDP{S, A} <: MDP{S, A}
    env::E
end


function convert(::Type{MDP}, ::AbstractEnv)

end

struct CommonRLPOMDP{E, S, A, O} <: POMDP{S, A, O}
    env::E
end

function convert(::Type{POMDP}, ::AbstractEnv)

end
=#
