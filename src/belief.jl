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
@pomdp_func initial_belief(pomdp::POMDP, belief::Belief = create_belief(pomdp))

# allocates and returns an empty problem-native belief structure
@pomdp_func create_belief(pomdp::POMDP)

# allocates and returns an empty belief structure of type used by BeliefUpdater
@pomdp_func create_belief(updater::BeliefUpdater)

# updates the belief given the old belief (belief_old), the action and the observation
@pomdp_func update(updater::BeliefUpdater, belief_old::Belief, action::Action, obs::Observation, belief_new::Belief=create_belief(updater))

# creates a Belief that can be updated by BeliefUpdater from the belief argument
@pomdp_func convert_belief(updater::BeliefUpdater, belief::Belief, new_belief::Belief=create_belief(updater)) = belief
