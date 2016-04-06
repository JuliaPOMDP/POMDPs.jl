"""
Provides a basic interface for working with MDPs/POMDPs
"""
POMDPs

#################################################################
####################### Problem Model ###########################
#################################################################


"""
Base type for state, action and observation spaces.
    
    T: type that parametarizes the space (state, action, or observation)
"""
AbstractSpace


"""
    states{S,A,O}(pomdp::POMDP{S,A,O})
    
Returns the complete state space of a POMDP. 
"""
states


"""
    actions{S,A,O}(pomdp::POMDP{S,A,O})

Returns the entire action space of a POMDP.
"""
actions{S,A,O}(pomdp::POMDP{S,A,O})


"""
    actions{S,A,O}(pomdp::POMDP{S,A,O}, state::S, aspace::AbstractSpace{A})

Modifies aspace to the action space accessible from the given state and returns it.
"""
actions{S,A,O}(pomdp::POMDP{S,A,O}, state::S, aspace::AbstractSpace{A})


"""
    actions{S,A,O}(pomdp::POMDP{S,A,O}, belief::Belief{S}, aspace::AbstractSpace{A})

Modifies aspace to the action space accessible from the states with nonzero belief and returns it.
"""
actions{S,A,O}(pomdp::POMDP{S,A,O}, belief::Belief{S}, aspace::AbstractSpace{A})


"""
    observations{S,A,O}(pomdp::POMDP{S,A,O})

Returns the entire observation space.
"""
observations{S,A,O}(pomdp::POMDP{S,A,O})

"""
    observations{S,A,O}(pomdp::POMDP{S,A,O}, state::S, obs::AbstractSpace{O}=observations(pomdp))

Modifies ospace to the observation space accessible from the given state and returns it.
"""
observations{S,A,O}(pomdp::POMDP{S,A,O}, state::S, obs::AbstractSpace{O}=observations(pomdp))


"""
    reward{S,A,O}(pomdp::POMDP{S,A,O}, state::S, action::A, statep::S)

Returns the immediate reward for the s-a-s' triple
"""
reward{S,A,O}(pomdp::POMDP{S,A,O}, state::S, action::A, statep::S)


"""
    reward{S,A,O}(pomdp::POMDP{S,A,O}, state::S, action::A)

Returns the immediate reward for the s-a pair
"""
reward{S,A,O}(pomdp::POMDP{S,A,O}, state::S, action::A)


"""
    transition{S,A,O}(pomdp::POMDP{S,A,O}, state::S, action::A,
distribution::AbstractDistribution{S}=create_transition_distribution(pomdp))

Returns the transition distribution from the current state-action pair
"""
transition{S,A,O}(pomdp::POMDP{S,A,O}, state::S, action::A,
distribution::AbstractDistribution{S}=create_transition_distribution(pomdp))


"""
    observation{S,A,O}(pomdp::POMDP{S,A,O}, state::S, action::A, statep::S, distribution::AbstractDistribution{O}=create_observation_distribution(pomdp))

Returns the observation distribution for the s-a-s' tuple (state, action, and next state)
"""
observation{S,A,O}(pomdp::POMDP{S,A,O}, state::S, action::A, statep::S, distribution::AbstractDistribution{O}=create_observation_distribution(pomdp))

"""
    observation{S,A,O}(pomdp::POMDP{S,A,O}, state::S, action::A, distribution::AbstractDistribution{O}=create_observation_distribution(pomdp))

Modifies distribution to the observation distribution for the s-a-s' tuple (state, action, and next state) and returns it
"""
observation{S,A,O}(pomdp::POMDP{S,A,O}, state::S, action::A, distribution::AbstractDistribution{O}=create_observation_distribution(pomdp))


"""
    isterminal{S,A,O}(pomdp::POMDP{S,A,O}, state::S)

Checks if state s is terminal
"""
isterminal{S,A,O}(pomdp::POMDP{S,A,O}, state::S)


"""
    isterminal_obs{S,A,O}(pomdp::POMDP{S,A,O}, observation::O)
Checks if an observation is terminal.
"""
isterminal_obs{S,A,O}(pomdp::POMDP{S,A,O}, observation::O)


"""
    n_states{S,A,O}(pomdp::POMDP{S,A,O})

Returns the number of states in `pomdp`. Used for discrete models only.
"""
n_states{S,A,O}(pomdp::POMDP{S,A,O})

"""
    n_actions{S,A,O}(pomdp::POMDP{S,A,O})

Returns the number of actions in `pomdp`. Used for discrete models only.
"""
n_actions{S,A,O}(pomdp::POMDP{S,A,O})

"""
    n_observations{S,A,O}(pomdp::POMDP{S,A,O})

Returns the number of actions in `pomdp`. Used for discrete models only.
"""
n_observations{S,A,O}(pomdp::POMDP{S,A,O})

"""
    state_index{S,A,O}(pomdp::POMDP{S,A,O}, s::S)

Returns the integer index of state `s`. Used for discrete models only.
"""
state_index{S,A,O}(pomdp::POMDP{S,A,O}, s::S)

"""
    action_index{S,A,O}(pomdp::POMDP{S,A,O}, a::A)

Returns the integer index of action `a`. Used for discrete models only.
"""
action_index{S,A,O}(pomdp::POMDP{S,A,O}, a::A)

"""
    obs_index{S,A,O}(pomdp::POMDP{S,A,O}, o::O)

Returns the integer index of observation `o`. Used for discrete models only.
"""
obs_index{S,A,O}(pomdp::POMDP{S,A,O}, o::O)

#################################################################
####################### Distributions ###########################
#################################################################

"""
Abstract type for a probability distribution.

    T: type over which distribution is over (state, action, or observation)
"""
AbstractDistribution

"""
    rand{T}(rng::AbstractRNG, d::AbstractDistribution{T}, sample::T)

Fill sample with a random element from distribution d. The sample can be a state, action or observation.
"""
rand{T}(rng::AbstractRNG, d::AbstractDistribution{T}, sample::T)


"""
    rand{T}(rng::AbstractRNG, d::AbstractSpace{T}, state::T)

Fill sample with a random element from space d. The sample can be a state, action or observation.
"""
rand{T}(rng::AbstractRNG, d::AbstractSpace{T}, state::T)

"""
    pdf{T}(d::AbstractDistribution{T}, x::T)

Value of probability distribution function at x
"""
pdf{T}(d::AbstractDistribution{T}, x::T)


"""
    create_transition_distribution{S,A,O}(pomdp::POMDP{S,A,O})

Creates a transition distribution for model `pomdp`. This
could be a custom type, array, or any other sensible container.
The transition distirubtion is over states.
"""
create_transition_distribution{S,A,O}(pomdp::POMDP{S,A,O})

"""
    create_observation_distribution{S,A,O}(pomdp::POMDP{S,A,O})

Creates an observation distribution for model `pomdp`. This
could be a custom type, array, or any other sensible container.
The observation distirubtion is over observations.
"""
create_observation_distribution{S,A,O}(pomdp::POMDP{S,A,O})


#################################################################
##################### Solvers and Policies ######################
#################################################################

"""
Base type for an MDP/POMDP solver
"""
Solver

