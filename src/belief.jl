
abstract Belief <: AbstractDistribution

create_belief(pomdp::POMDP) = error("$(typeof(pomdp)) does not implement create_belief")
belief(pomdp::POMDP, bold::Belief, action::Any, obs::Any, belief::Belief=create_belief(pomdp)) = error("$(typeof(pomdp)) does not implement belief")
initial_belief(pomdp::POMDP, belief = create_belief(pomdp)) = error("$(typeof(pomdp)) does not implement initial_belief")
