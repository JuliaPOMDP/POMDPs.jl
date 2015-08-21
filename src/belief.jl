
abstract Belief <: AbstractDistribution

update_belief!(b::Belief, pomdp::POMDP, bold::Belief, action::Any, obs::Any) = error("$(typeof(b)) does not implement update_belief!")
