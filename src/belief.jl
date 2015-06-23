
abstract Belief

update_belief(b::Belief, action::Any, obs::Any) = error("$(typeof(b)) does not implement update_belief")
update_belief!(b::Belief, action::Any, obs::Any) = error("$(typeof(b)) does not implement update_belief!")
