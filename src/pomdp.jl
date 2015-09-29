# POMDP model functions

abstract POMDP

abstract State
abstract Action
abstract Observation
typealias Reward Float64

# return the space sizes
n_states(pomdp::POMDP)       = error("$(typeof(pomdp)) does not implement num_states")
n_actions(pomdp::POMDP)      = error("$(typeof(pomdp)) does not implement num_actions")
n_observations(pomdp::POMDP) = error("$(typeof(pomdp)) does not implement num_observations")

discount(pomdp::POMDP)  = error("$(typeof(pomdp)) does not implement discount")

transition(pomdp::POMDP, state::State, action::Action, distribution=create_transition_distribution(pomdp))  = error("$(typeof(pomdp)) does not implement transition")
observation(pomdp::POMDP, state::State, action::Action, distribution=create_observation_distribution(pomdp)) = error("$(typeof(pomdp)) does not implement observation")
reward(pomdp::POMDP, state::State, action::Action) = error("$(typeof(pomdp)) does not implement reward")
reward(pomdp::POMDP, state::State, action::Action, statep::State) = reward(pomdp,state,action)

create_state(pomdp::POMDP) = error("$(typeof(pomdp)) does not implement create_state")
create_observation(pomdp::POMDP) = error("$(typeof(pomdp)) does not implement create_observation")

isterminal(pomdp::POMDP, state::State) = false

index(pomdp::POMDP, state::State) = error("$(typeof(pomdp)) does not implement index")
