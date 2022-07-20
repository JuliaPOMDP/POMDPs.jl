"""
    FullyObservablePOMDP(mdp)

Turn `MDP` `mdp` into a `POMDP` where the observations are the states of the MDP.
"""
struct FullyObservablePOMDP{M,S,A} <: POMDP{S,A,S}
    mdp::M
end

function FullyObservablePOMDP(m::MDP)
    return FullyObservablePOMDP{typeof(m), statetype(m), actiontype(m)}(m)
end

mdptype(::Type{FullyObservablePOMDP{M,S,A}}) where {M,S,A} = M

POMDPs.observations(pomdp::FullyObservablePOMDP) = states(pomdp.mdp)
POMDPs.obsindex(pomdp::FullyObservablePOMDP{S, A}, o::S) where {S, A} = stateindex(pomdp.mdp, o)

POMDPs.convert_o(T::Type{V}, o, pomdp::FullyObservablePOMDP) where {V<:AbstractArray} = convert_s(T, s, pomdp.mdp)
POMDPs.convert_o(T::Type{S}, vec::V, pomdp::FullyObservablePOMDP) where {S,V<:AbstractArray} = convert_s(T, vec, pomdp.mdp)

function POMDPs.observation(pomdp::FullyObservablePOMDP, a, sp)
    return Deterministic(sp)
end

function POMDPs.observation(pomdp::FullyObservablePOMDP, s, a, sp)
    return Deterministic(sp)
end

# inherit other function from the MDP type

POMDPs.states(pomdp::FullyObservablePOMDP) = states(pomdp.mdp)
POMDPs.actions(pomdp::FullyObservablePOMDP) = actions(pomdp.mdp)
POMDPs.transition(pomdp::FullyObservablePOMDP, s, a) = transition(pomdp.mdp, s, a)
POMDPs.isterminal(pomdp::FullyObservablePOMDP, s) = isterminal(pomdp.mdp, s)
POMDPs.discount(pomdp::FullyObservablePOMDP) = discount(pomdp.mdp)
POMDPs.stateindex(pomdp::FullyObservablePOMDP, s) = stateindex(pomdp.mdp, s)
POMDPs.actionindex(pomdp::FullyObservablePOMDP, a) = actionindex(pomdp.mdp, a)
POMDPs.convert_s(T::Type{V}, s, pomdp::FullyObservablePOMDP) where V<:AbstractArray = convert_s(T, s, pomdp.mdp)
POMDPs.convert_s(T::Type{S}, vec::V, pomdp::FullyObservablePOMDP) where {S,V<:AbstractArray} = convert_s(T, vec, pomdp.mdp)
POMDPs.convert_a(T::Type{V}, a, pomdp::FullyObservablePOMDP) where V<:AbstractArray = convert_a(T, a, pomdp.mdp)
POMDPs.convert_a(T::Type{A}, vec::V, pomdp::FullyObservablePOMDP) where {A,V<:AbstractArray} = convert_a(T, vec, pomdp.mdp)
POMDPs.reward(pomdp::FullyObservablePOMDP, s, a) = reward(pomdp.mdp, s, a)
POMDPs.initialstate(m::FullyObservablePOMDP) = initialstate(m.mdp)
POMDPs.initialobs(m::FullyObservablePOMDP, s) = Deterministic(s)
