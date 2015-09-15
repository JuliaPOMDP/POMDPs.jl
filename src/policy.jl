
abstract Policy

action(pomdp::POMDP, p::Policy, belief::Belief, action=create_action(pomdp)) = error("$(typeof(p)) does not implement action")
create_action(pomdp::POMDP) = error("$(typeof(pomdp)) does not implement create_action")
value(p::Policy, belief::Belief) = error("$(typeof(p)) does not implement value")

