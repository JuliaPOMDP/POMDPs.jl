# POMDP model functions

abstract POMDP

abstract State
abstract Action
abstract Observation
typealias Reward Float64

abstract AbstractDistribution

# return the space sizes
@pomdp_func n_states(pomdp::POMDP)
@pomdp_func n_actions(pomdp::POMDP)
@pomdp_func n_observations(pomdp::POMDP)

# return the discount factor
@pomdp_func discount(pomdp::POMDP)

@pomdp_func transition(pomdp::POMDP, state::State, action::Action, distribution::AbstractDistribution=create_transition_distribution(pomdp))
@pomdp_func observation(pomdp::POMDP, state::State, action::Action, statep::State, distribution::AbstractDistribution=create_observation_distribution(pomdp))
@pomdp_func observation(pomdp::POMDP, state::State, action::Action, distribution::AbstractDistribution=create_observation_distribution(pomdp))
@pomdp_func reward(pomdp::POMDP, state::State, action::Action, statep::State)

@pomdp_func create_state(pomdp::POMDP)
@pomdp_func create_observation(pomdp::POMDP)

@pomdp_func isterminal(pomdp::POMDP, state::State) = false
@pomdp_func isterminal(pomdp::POMDP, observation::Observation) = false

@pomdp_func index(pomdp::POMDP, state::State)
