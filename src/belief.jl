#################################################################
######################## BELIEF #################################
#################################################################
# The abstract Belief type implements initialization (initial_belief and create_belief)
# and update (belief) methods for POMDP beliefs.
# For discrete problems, it can be usually be represented as a vector.
# For tools supportng belief updates see POMDPToolbox.jl

abstract Belief <: AbstractDistribution
abstract BeliefUpdater

# returns an initial belief
# XXX [Zach] I got rid of the second argument for this
initial_belief(pomdp::POMDP) = error("$(typeof(pomdp)) does not implement initial_belief")

# returns any belief 
create_belief(updater::BeliefUpdater) = error("$(typeof(updater)) does not implement create_belief")

# updates the belief given the old belief (belief_old), the action and the observation
update(updater::BeliefUpdater, belief_old::Belief, action::Action, obs::Observation, belief_new::Belief=create_belief(updater)) = error("$(typeof(updater)) does not implement update for belief_old::$(typeof(belief_old)), action::$(typeof(action)), obs::$(typeof(obs)), and belief_new::$(typeof(belief_new))")

convert_belief(updater::BeliefUpdater, belief::Belief) = error("$(typeof(updater)) does not implement convert_belief for belief::$(typeof(belief))")
