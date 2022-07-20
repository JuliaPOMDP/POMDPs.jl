### StochasticPolicy ###
# maintained by @etotheipluspi

"""
   StochasticPolicy{D, RNG <: AbstractRNG}

Represents a stochastic policy. Action are sampled from an arbitrary distribution.

Constructor:

    `StochasticPolicy(distribution; rng=Random.GLOBAL_RNG)`

# Fields 
- `distribution::D`
- `rng::RNG` a random number generator
""" 
mutable struct StochasticPolicy{D, RNG <: AbstractRNG} <: Policy
    distribution::D
    rng::RNG
end
# The constructor below should be used to create the policy so that the action space is initialized correctly
StochasticPolicy(distribution; rng=Random.GLOBAL_RNG) = StochasticPolicy(distribution, rng)

## policy execution ##
function action(policy::StochasticPolicy, s)
    return rand(policy.rng, policy.distribution)
end

## convenience functions ##
updater(policy::StochasticPolicy) = VoidUpdater() # since the stochastic policy does not depend on the belief

# Samples actions uniformly
UniformRandomPolicy(problem, rng=Random.GLOBAL_RNG) = StochasticPolicy(actions(problem), rng)

"""
    CategoricalTabularPolicy

represents a stochastic policy sampling an action from a categorical distribution with weights given by a `ValuePolicy`

constructor:

`CategoricalTabularPolicy(mdp::Union{POMDP,MDP}; rng=Random.GLOBAL_RNG)`

# Fields
- `stochastic::StochasticPolicy`
- `value::ValuePolicy`
"""
mutable struct CategoricalTabularPolicy <: Policy
    stochastic::StochasticPolicy
    value::ValuePolicy
end
function CategoricalTabularPolicy(mdp::Union{POMDP,MDP}; rng=Random.GLOBAL_RNG)
    CategoricalTabularPolicy(StochasticPolicy(Weights(zeros(length(actions((mdp))))), rng), ValuePolicy(mdp))
end

function action(policy::CategoricalTabularPolicy, s)
    policy.stochastic.distribution = Weights(policy.value.value_table[stateindex(policy.value.mdp, s),:])
    return policy.value.act[sample(policy.stochastic.rng, policy.stochastic.distribution)]
end
