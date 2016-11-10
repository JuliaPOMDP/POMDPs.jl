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
abstract MDP{S,A}

"""
Abstract type for a probability distribution.

    T: type over which distribution is over (state, action, or observation)
"""
abstract AbstractDistribution{T}

"""
    n_states(problem::POMDP)
    n_states(problem::MDP)

Returns the number of states in `problem`. Used for discrete models only.
"""
@pomdp_func n_states(problem::Union{POMDP,MDP})

"""
    n_actions(problem::POMDP)
    n_actions(problem::MDP)

Returns the number of actions in `problem`. Used for discrete models only.
"""
@pomdp_func n_actions(problem::Union{POMDP,MDP})

"""
    n_observations(problem::POMDP)

Returns the number of actions in `problem`. Used for discrete models only.
"""
@pomdp_func n_observations(problem::POMDP)

"""
    discount(problem::POMDP)
    discount(problem::MDP)

Return the discount factor for the problem.
"""
@pomdp_func discount(problem::Union{POMDP,MDP}) = 1.0

"""
    transition{S,A,O}(problem::POMDP{S,A,O}, state::S, action::A,
distribution::AbstractDistribution{S}=create_transition_distribution(problem))
    transition{S,A}(problem::MDP{S,A}, state::S, action::A,
distribution::AbstractDistribution{S}=create_transition_distribution(problem))

Returns the transition distribution from the current state-action pair
"""
@pomdp_func transition{S,A}(problem::Union{POMDP{S,A},MDP{S,A}}, state::S, action::A, distribution::AbstractDistribution{S}=create_transition_distribution(problem))

"""
    observation{S,A,O}(problem::POMDP{S,A,O}, action::A, statep::S, distribution::AbstractDistribution{O}=create_observation_distribution(problem))

Modifies distribution to the observation distribution for the a-s' tuple (action and next state) and returns it
"""
@pomdp_func observation{S,A,O}(problem::POMDP{S,A,O}, action::A, statep::S, distribution::AbstractDistribution{O}=create_observation_distribution(problem))

"""
    observation{S,A,O}(problem::POMDP{S,A,O}, state::S, action::A, statep::S, distribution::AbstractDistribution{O}=create_observation_distribution(problem))

Returns the observation distribution for the s-a-s' tuple (state, action, and next state)
"""
observation{S,A,O}(problem::POMDP{S,A,O}, s::S, a::A, sp::S, dist::AbstractDistribution{O}) = observation(problem, a,
sp, dist) 

"""
    reward{S,A,O}(problem::POMDP{S,A,O}, state::S, action::A)
    reward{S,A}(problem::MDP{S,A}, state::S, action::A)

Returns the immediate reward for the s-a pair
"""
@pomdp_func reward{S,A}(problem::Union{POMDP{S,A},MDP{S,A}}, state::S, action::A)

"""
    reward{S,A,O}(problem::POMDP{S,A,O}, state::S, action::A, statep::S)
    reward{S,A}(problem::MDP{S,A}, state::S, action::A, statep::S)

Returns the immediate reward for the s-a-s' triple
"""
reward{S,A}(problem::Union{POMDP{S,A},MDP{S,A}}, s::S, a::A, sp::S) = reward(problem, s, a)

"""
    create_state(problem::POMDP)
    create_state(problem::MDP)

Create a state object (for preallocation purposes).
"""
@pomdp_func create_state(problem::Union{POMDP,MDP})

# default implementation for numeric types
create_state{S<:Number,A}(problem::Union{POMDP{S,A},MDP{S,A}}) = zero(S)

"""
    create_observation(problem::POMDP)

Create an observation object (for preallocation purposes).
"""
@pomdp_func create_observation(problem::POMDP)

# default implementation for numeric types
create_observation{S,A,O<:Number}(problem::POMDP{S,A,O}) = zero(O)

"""
    isterminal_obs{S,A,O}(problem::POMDP{S,A,O}, observation::O)

Checks if an observation is terminal.
"""
@pomdp_func isterminal_obs{S,A,O}(problem::POMDP{S,A,O}, observation::O) = false

"""
    isterminal{S,A,O}(problem::POMDP{S,A,O}, state::S)
    isterminal{S,A}(problem::MDP{S,A}, state::S)

Checks if state s is terminal
"""
@pomdp_func isterminal{S,A}(problem::Union{POMDP{S,A},MDP{S,A}}, state::S) = false

"""
    state_index{S,A,O}(problem::POMDP{S,A,O}, s::S)
    state_index{S,A}(problem::MDP{S,A}, s::S)

Returns the integer index of state `s`. Used for discrete models only.
"""
@pomdp_func state_index{S,A}(problem::Union{POMDP{S,A},MDP{S,A}}, s::S)

"""
    action_index{S,A,O}(problem::POMDP{S,A,O}, a::A)
    action_index{S,A}(problem::MDP{S,A}, a::A)

Returns the integer index of action `a`. Used for discrete models only.
"""
@pomdp_func action_index{S,A}(problem::Union{POMDP{S,A},MDP{S,A}}, a::A)

"""
    obs_index{S,A,O}(problem::POMDP{S,A,O}, o::O)

Returns the integer index of observation `o`. Used for discrete models only.
"""
@pomdp_func obs_index{S,A,O}(problem::POMDP{S,A,O}, o::O)

"""
    vec{SO}(problem::Union{MDP{SO},POMDP{SO}}, so::S)
Convert a state or observaton to vectorized form of floats.
"""
@pomdp_func Base.vec{SO}(problem::Union{MDP{SO},POMDP{SO}}, so::SO)
