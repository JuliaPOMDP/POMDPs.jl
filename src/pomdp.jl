# POMDP model functions

abstract POMDP{S,A,O}
abstract MDP{S,A} <: POMDP{S,A,S}

abstract AbstractDistribution{T}

# return the space sizes
@pomdp_func n_states{S,A,O}(pomdp::POMDP{S,A,O})
@pomdp_func n_actions{S,A,O}(pomdp::POMDP{S,A,O})
@pomdp_func n_observations{S,A,O}(pomdp::POMDP{S,A,O})

# return the discount factor
@pomdp_func discount{S,A,O}(pomdp::POMDP{S,A,O})

@pomdp_func transition{S,A,O}(pomdp::POMDP{S,A,O}, state::S, action::A, distribution::AbstractDistribution{S}=create_transition_distribution(pomdp))
@pomdp_func observation{S,A,O}(pomdp::POMDP{S,A,O}, state::S, action::A, statep::S, distribution::AbstractDistribution{O}=create_observation_distribution(pomdp))
@pomdp_func observation{S,A,O}(pomdp::POMDP{S,A,O}, state::S, action::A, distribution::AbstractDistribution{O}=create_observation_distribution(pomdp))
@pomdp_func reward{S,A,O}(pomdp::POMDP{S,A,O}, state::S, action::A, statep::S)

#@pomdp_func create_state{S,A,O}(pomdp::POMDP{S,A,O})
#@pomdp_func create_observation{S,A,O}(pomdp::POMDP{S,A,O})

@pomdp_func isterminal_obs{S,A,O}(pomdp::POMDP{S,A,O}, observation::O) = false
@pomdp_func isterminal{S,A,O}(pomdp::POMDP{S,A,O}, state::S) = false

# @pomdp_func isterminal(pomdp::POMDP, observation::Any) = false
# @pomdp_func isterminal_obs(pomdp::POMDP, state::Any) = false

@pomdp_func state_index{S,A,O}(pomdp::POMDP{S,A,O}, s::S)
@pomdp_func action_index{S,A,O}(pomdp::POMDP{S,A,O}, a::A)
@pomdp_func obs_index{S,A,O}(pomdp::POMDP{S,A,O}, o::O)
