
abstract Policy

get_action(p::Policy, belief::Any) = error("$(typeof(p)) does not implement get_action")
get_value(p::Policy, belief::Any) = error("$(typeof(p)) does not implement get_value")

