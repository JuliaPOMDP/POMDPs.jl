# POMDP model functions

abstract POMDP

typealias State Any
typealias Action Any
typealias Observation Any

# return the space sizes
n_states(pomdp::POMDP)       = error("$(typeof(pomdp)) does not implement num_states")
n_actions(pomdp::POMDP)      = error("$(typeof(pomdp)) does not implement num_actions")
n_observations(pomdp::POMDP) = error("$(typeof(pomdp)) does not implement num_observations")

discount(pomdp::POMDP)  = error("$(typeof(pomdp)) does not implement discount") # returns the discount factor

transition!(distribution, pomdp::POMDP, state::State, action::Action)  = error("$(typeof(pomdp)) does not implement transition!") # returns a distributions over neighbors
observation!(distribution, pomdp::POMDP, state::State, action::Action) = error("$(typeof(pomdp)) does not implement observation!") # returns a distributions over observations
reward(pomdp::POMDP, state::State, action::Action) = error("$(typeof(pomdp)) does not implement reward") # immediate reward
reward(pomdp::POMDP, state::State, action::Action, statep::State) = reward(pomdp,state,action) # immediate reward

create_state(pomdp::POMDP) = error("$(typeof(pomdp)) does not implement create_state") # returns a state
create_observation(pomdp::POMDP) = error("$(typeof(pomdp)) does not implement create_observation") # returns an observation

isterminal(pomdp::POMDP, state::State) = false # checks if a state is terminal
