
abstract Policy

action(p::Policy, belief::Any) = error("$(typeof(p)) does not implement get_action")
value(p::Policy, belief::Any) = error("$(typeof(p)) does not implement get_value")

