#################################################################
######################## BELIEF #################################
#################################################################
# The abstract Belief type implements initialization (initial_belief and create_belief)
# and update (belief) methods for POMDP beliefs.
# For discrete problems, it can be usually be represented as a vector.
# For tools supportng belief updates see POMDPToolbox.jl

"""
Abstract type for an object representing some knowledge about the state (often a probability distribution)
"""
abstract Belief

"""
Abstract type for an object that defines how a belief should be updated
"""
abstract BeliefUpdater

"""
    initial_belief(pomdp::POMDP, belief::Belief = create_belief(pomdp))

Returns an initial belief for the pomdp.
"""
@pomdp_func initial_belief(pomdp::POMDP, belief::Belief = create_belief(pomdp))

"""
    create_belief(pomdp::POMDP)

Creates a belief either to be used by updater or pomdp
"""
@pomdp_func create_belief(pomdp::POMDP)

"""
    create_belief(updater::BeliefUpdater)

Creates a belief object of the type used by `updater` (preallocates memory)
"""
@pomdp_func create_belief(updater::BeliefUpdater)

"""
    update(updater::BeliefUpdater, belief_old::Belief, action, obs,
    belief_new::Belief=create_belief(updater))

Returns a new instance of an updated belief given `belief_old` and the latest action and observation.
"""
@pomdp_func update(updater::BeliefUpdater, belief_old::Belief, action::Any, obs::Any, belief_new::Belief=create_belief(updater))

# returns a belief that can be updated using `updater` that has a similar distribution to `b` (this conversion may be lossy)
"""
    convert_belief(updater::BeliefUpdater, belief::Belief,
    new_belief::Belief=create_belief(updater)) = belief

Returns a belief that can be updated using `updater` that has a similar distribution to `belief`.
"""
@pomdp_func convert_belief(updater::BeliefUpdater, belief::Belief, new_belief::Belief=create_belief(updater)) = belief
