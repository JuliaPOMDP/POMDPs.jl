# POMDP model functions

abstract POMDP

# return a space type
states(pomdp::POMDP)       = error("$(typeof(pomdp)) does not implement states") 
actions!(acts::Vector{Any}, pomdp::POMDP, state::Any) = error("$(typeof(pomdp)) does not implement actions") 
observations(pomdp::POMDP) = error("$(typeof(pomdp)) does not implement observations") 

# return the space sizes
# for huge spaces, collect might not be the best choice - let user implement?
n_states(pomdp::POMDP)       = error("$(typeof(pomdp)) does not implement num_states")
n_actions(pomdp::POMDP)      = error("$(typeof(pomdp)) does not implement num_actions")
n_observations(pomdp::POMDP) = error("$(typeof(pomdp)) does not implement num_observations")

transition!(pomdp::POMDP, state::Any, action::Any)  = error("$(typeof(pomdp)) does not implement transition!") # returns a distributions over neighbors
observation!(pomdp::POMDP, state::Any, action::Any) = error("$(typeof(pomdp)) does not implement observation!") # returns a distributions over observations
reward(pomdp::POMDP, state::Any, action::Any)      = error("$(typeof(pomdp)) does not implement reward") # immediate reward

create_state(pomdp::POMDP) = error("$(typeof(pomdp)) does not implement create_state") # returns a state
create_action(pomdp::POMDP) = error("$(typeof(pomdp)) does not implement create_action") # returns an action
