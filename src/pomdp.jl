# POMDP model functions
"""
Abstract base type for a partially observable Markov decision process.

    S: state type
    A: action type
    O: observation type
"""
abstract POMDP{S,A,O}

"""
Abstract base type for a fully observable Markov decision process.

    S: state type
    A: action type
"""
abstract MDP{S,A} <: POMDP{S,A,S}

"""
Abstract type for a probability distribution.

    T: type over which distribution is over (state, action, or observation)
"""
abstract AbstractDistribution{T}

"""
    n_states{S,A,O}(pomdp::POMDP{S,A,O})

Returns the number of states in `pomdp`. Used for discrete models only.
"""
@pomdp_func n_states{S,A,O}(pomdp::POMDP{S,A,O})

"""
    n_actions{S,A,O}(pomdp::POMDP{S,A,O})

Returns the number of actions in `pomdp`. Used for discrete models only.
"""
@pomdp_func n_actions{S,A,O}(pomdp::POMDP{S,A,O})

"""
    n_observations{S,A,O}(pomdp::POMDP{S,A,O})

Returns the number of actions in `pomdp`. Used for discrete models only.
"""
@pomdp_func n_observations{S,A,O}(pomdp::POMDP{S,A,O})

"""
    discount{S,A,O}(pomdp::POMDP{S,A,O})

Return the discount factor for the problem.
"""
@pomdp_func discount(pomdp::POMDP)

"""
    transition{S,A,O}(pomdp::POMDP{S,A,O}, state::S, action::A,
distribution::AbstractDistribution{S}=create_transition_distribution(pomdp))

Returns the transition distribution from the current state-action pair
"""
@pomdp_func transition{S,A,O}(pomdp::POMDP{S,A,O}, state::S, action::A, distribution::AbstractDistribution{S}=create_transition_distribution(pomdp))

"""
    observation{S,A,O}(pomdp::POMDP{S,A,O}, state::S, action::A, statep::S, distribution::AbstractDistribution{O}=create_observation_distribution(pomdp))

Returns the observation distribution for the s-a-s' tuple (state, action, and next state)
"""
@pomdp_func observation{S,A,O}(pomdp::POMDP{S,A,O}, state::S, action::A, statep::S, distribution::AbstractDistribution{O}=create_observation_distribution(pomdp))

"""
    observation{S,A,O}(pomdp::POMDP{S,A,O}, state::S, action::A, distribution::AbstractDistribution{O}=create_observation_distribution(pomdp))

Modifies distribution to the observation distribution for the s-a-s' tuple (state, action, and next state) and returns it
"""
@pomdp_func observation{S,A,O}(pomdp::POMDP{S,A,O}, state::S, action::A, distribution::AbstractDistribution{O}=create_observation_distribution(pomdp))

"""
    reward{S,A,O}(pomdp::POMDP{S,A,O}, state::S, action::A, statep::S)

Returns the immediate reward for the s-a-s' triple
"""
@pomdp_func reward{S,A,O}(pomdp::POMDP{S,A,O}, state::S, action::A, statep::S)

"""
    reward{S,A,O}(pomdp::POMDP{S,A,O}, state::S, action::A)

Returns the immediate reward for the s-a pair
"""
@pomdp_func reward{S,A,O}(pomdp::POMDP{S,A,O}, state::S, action::A)

#@pomdp_func create_state{S,A,O}(pomdp::POMDP{S,A,O})
#@pomdp_func create_observation{S,A,O}(pomdp::POMDP{S,A,O})

"""
    isterminal{S,A,O}(pomdp::POMDP{S,A,O}, state::S)

Checks if state s is terminal
"""
@pomdp_func isterminal_obs{S,A,O}(pomdp::POMDP{S,A,O}, observation::O) = false

"""
    isterminal_obs{S,A,O}(pomdp::POMDP{S,A,O}, observation::O)
Checks if an observation is terminal.
"""
@pomdp_func isterminal{S,A,O}(pomdp::POMDP{S,A,O}, state::S) = false

# @pomdp_func isterminal(pomdp::POMDP, observation::Any) = false
# @pomdp_func isterminal_obs(pomdp::POMDP, state::Any) = false

"""
    state_index{S,A,O}(pomdp::POMDP{S,A,O}, s::S)

Returns the integer index of state `s`. Used for discrete models only.
"""
@pomdp_func state_index{S,A,O}(pomdp::POMDP{S,A,O}, s::S)

"""
    action_index{S,A,O}(pomdp::POMDP{S,A,O}, a::A)

Returns the integer index of action `a`. Used for discrete models only.
"""
@pomdp_func action_index{S,A,O}(pomdp::POMDP{S,A,O}, a::A)

"""
    obs_index{S,A,O}(pomdp::POMDP{S,A,O}, o::O)

Returns the integer index of observation `o`. Used for discrete models only.
"""
@pomdp_func obs_index{S,A,O}(pomdp::POMDP{S,A,O}, o::O)
