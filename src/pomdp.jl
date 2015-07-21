# POMDP model functions

abstract POMDP

abstract DiscretePOMDP <: POMDP

# return the space sizes
n_states(pomdp::POMDP)       = error("$(typeof(pomdp)) does not implement num_states")
n_actions(pomdp::POMDP)      = error("$(typeof(pomdp)) does not implement num_actions")
n_observations(pomdp::POMDP) = error("$(typeof(pomdp)) does not implement num_observations")

discount(pomdp::POMDP)  = error("$(typeof(pomdp)) does not implement discount") # returns the discount factor

transition!(distribution, pomdp::POMDP, state::Any, action::Any)  = error("$(typeof(pomdp)) does not implement transition!") # returns a distributions over neighbors
observation!(distribution, pomdp::POMDP, state::Any, action::Any) = error("$(typeof(pomdp)) does not implement observation!") # returns a distributions over observations
reward(pomdp::POMDP, state::Any, action::Any)      = error("$(typeof(pomdp)) does not implement reward") # immediate reward

create_state(pomdp::POMDP) = error("$(typeof(pomdp)) does not implement create_state") # returns a state
create_action(pomdp::POMDP) = error("$(typeof(pomdp)) does not implement create_action") # returns an action

isterminal(pomdp::POMDP, state::Any) = false # checks if a state is terminal
