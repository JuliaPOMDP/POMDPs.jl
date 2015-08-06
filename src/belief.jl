
abstract Belief <: AbstractDistribution

update_belief!(b::Belief, pomdp::POMDP, action::Any, obs::Any) = error("$(typeof(b)) does not implement update_belief!")
