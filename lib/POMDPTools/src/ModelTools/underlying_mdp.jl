"""
    UnderlyingMDP(m::POMDP)

Transform `POMDP` `m` into an `MDP` where the states are fully observed.

    UnderlyingMDP(m::MDP)  

Return `m`
"""
struct UnderlyingMDP{P <: POMDP, S, A} <: MDP{S, A}
    pomdp::P
end

function UnderlyingMDP(pomdp::POMDP{S, A, O}) where {S,A,O}
    P = typeof(pomdp)
    return UnderlyingMDP{P,S,A}(pomdp)
end

UnderlyingMDP(m::MDP) = m

POMDPs.transition(mdp::UnderlyingMDP{P, S, A}, s::S, a::A) where {P,S,A}= transition(mdp.pomdp, s, a)
POMDPs.initialstate(m::UnderlyingMDP) = initialstate(m.pomdp)
POMDPs.states(mdp::UnderlyingMDP) = states(mdp.pomdp)
POMDPs.actions(mdp::UnderlyingMDP) = actions(mdp.pomdp)
POMDPs.reward(mdp::UnderlyingMDP{P, S, A}, s::S, a::A) where {P,S,A} = reward(mdp.pomdp, s, a)
POMDPs.reward(mdp::UnderlyingMDP{P, S, A}, s::S, a::A, sp::S) where {P,S,A} = reward(mdp.pomdp, s, a, sp)
POMDPs.isterminal(mdp ::UnderlyingMDP{P, S, A}, s::S) where {P,S,A} = isterminal(mdp.pomdp, s)
POMDPs.discount(mdp::UnderlyingMDP) = discount(mdp.pomdp)
POMDPs.stateindex(mdp::UnderlyingMDP{P, S, A}, s::S) where {P,S,A} = stateindex(mdp.pomdp, s)
POMDPs.stateindex(mdp::UnderlyingMDP{P, Int, A}, s::Int) where {P,A} = stateindex(mdp.pomdp, s) # fix ambiguity with src/convenience
POMDPs.stateindex(mdp::UnderlyingMDP{P, Bool, A}, s::Bool) where {P,A} = stateindex(mdp.pomdp, s)
POMDPs.actionindex(mdp::UnderlyingMDP{P, S, A}, a::A) where {P,S,A} = actionindex(mdp.pomdp, a)
POMDPs.actionindex(mdp::UnderlyingMDP{P,S, Int}, a::Int) where {P,S} = actionindex(mdp.pomdp, a)
POMDPs.actionindex(mdp::UnderlyingMDP{P,S, Bool}, a::Bool) where {P,S} = actionindex(mdp.pomdp, a)

POMDPs.gen(mdp::UnderlyingMDP, s, a, rng) = gen(mdp.pomdp, s, a, rng)

# deprecated in POMDPs.jl v0.9
POMDPs.initialstate_distribution(mdp::UnderlyingMDP) = initialstate_distribution(mdp.pomdp)
POMDPs.initialstate(mdp::UnderlyingMDP, rng::AbstractRNG) = initialstate(mdp.pomdp, rng)
