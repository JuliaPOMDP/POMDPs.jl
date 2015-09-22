#################################################################
######################## BELIEF #################################
#################################################################
# The abstract Belief type implements initialization (initial_belief and create_belief)
# and update (belief) methods for POMDP beliefs.
# For discrete problems, it can be usually be represented as a vector.
# For tools supportng belief updates see POMDPToolbox.jl

abstract Belief <: AbstractDistribution

# returns an initial belief
initial_belief(pomdp::POMDP, belief = create_belief(pomdp)) = error("$(typeof(pomdp)) does not implement initial_belief")

# returns any belief 
create_belief(pomdp::POMDP) = error("$(typeof(pomdp)) does not implement create_belief")

# updates the belief given the old belief (belief_old), the action and the observation
belief(pomdp::POMDP, belief_old::Belief, action::Any, obs::Any, belief_new::Belief=create_belief(pomdp)) = error("$(typeof(pomdp)) does not implement belief")
