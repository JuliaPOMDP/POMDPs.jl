
abstract Policy

action(p::Policy, belief::Belief) = error("$(typeof(p)) does not implement action")
value(p::Policy, belief::Belief) = error("$(typeof(p)) does not implement value")

