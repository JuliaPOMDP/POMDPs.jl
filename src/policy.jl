
abstract Policy

action(p::Policy, belief::Belief) = error("$(typeof(p)) does not implement get_action")
value(p::Policy, belief::Belief) = error("$(typeof(p)) does not implement get_value")

