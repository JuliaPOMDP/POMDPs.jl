# POMDP model functions

abstract POMDP
# for discrete solvers
abstract DiscretePOMDP <: POMDP

convert!(x::Vector{Float64}, state::Any) = error("$(typeof(state)) does not implement convert")

# return the space sizes
# for huge spaces, collect might not be the best choice - let user implement?
n_states(pomdp::DiscretePOMDP)       = error("$(typeof(pomdp)) does not implement num_states")
n_actions(pomdp::DiscretePOMDP)      = error("$(typeof(pomdp)) does not implement num_actions")
n_observations(pomdp::DiscretePOMDP) = error("$(typeof(pomdp)) does not implement num_observations")

transition!(distribution, pomdp::POMDP, state::Any, action::Any)  = error("$(typeof(pomdp)) does not implement transition!") # returns a distributions over neighbors
observation!(distribution, pomdp::POMDP, state::Any, action::Any) = error("$(typeof(pomdp)) does not implement observation!") # returns a distributions over observations
reward(pomdp::POMDP, state::Any, action::Any)      = error("$(typeof(pomdp)) does not implement reward") # immediate reward

create_state(pomdp::POMDP) = error("$(typeof(pomdp)) does not implement create_state") # returns a state
create_action(pomdp::POMDP) = error("$(typeof(pomdp)) does not implement create_action") # returns an action
