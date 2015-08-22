
abstract Belief <: AbstractDistribution

create_belief(pomdp::POMDP) = error("$(typeof(b)) does not implement create_belief")
update_belief!(b::Belief, pomdp::POMDP, bold::Belief, action::Any, obs::Any) = error("$(typeof(b)) does not implement update_belief!")
