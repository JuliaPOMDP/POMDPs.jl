#################################################################
# The policy is a mapping from a belief to an action in a POMDP,
# and it maps states to actions in an MDP. 
# The policy is extracted through calls to the action() function.
#################################################################

abstract Policy

# initializes the MDP/POMDP action
create_action(pomdp::POMDP) = error("$(typeof(pomdp)) does not implement create_action")

# returns the action according to policy p given the belief
action(pomdp::POMDP, p::Policy, belief::Belief, action=create_action(pomdp)) = error("$(typeof(p)) does not implement action")
# returns the utility value from policy p given the belief
value(p::Policy, belief::Belief) = error("$(typeof(p)) does not implement value")

# returns the action according to policy p given the state
action(pomdp::POMDP, p::Policy, state::State, action=create_action(pomdp)) = error("$(typeof(p)) does not implement action")
# returns the utility value from policy p given the state
value(p::Policy, state::State) = error("$(typeof(p)) does not implement value")
