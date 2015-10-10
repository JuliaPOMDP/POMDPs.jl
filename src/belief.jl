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
@pomdp_func initial_belief(pomdp::POMDP)

# returns any belief 
@pomdp_func create_belief(updater::BeliefUpdater)

# updates the belief given the old belief (belief_old), the action and the observation
@pomdp_func update(updater::BeliefUpdater, belief_old::Belief, action::Action, obs::Observation, belief_new::Belief=create_belief(updater))

# creates a Belief that can be updated by BeliefUpdater from the belief argument
@pomdp_func convert_belief(updater::BeliefUpdater, belief::Belief)
