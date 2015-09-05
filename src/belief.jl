
abstract Belief <: AbstractDistribution

create_belief(pomdp::POMDP) = error("$(typeof(b)) does not implement create_belief")
belief(pomdp::POMDP, bold::Belief, action::Any, obs::Any, belief::Belief=create_belief(pomdp)) = error("$(typeof(b)) does not implement belief")
