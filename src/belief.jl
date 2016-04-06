#################################################################
######################## BELIEF #################################
#################################################################
# The abstract Belief type implements initialization (initial_belief and create_belief)
# and update (belief) methods for POMDP beliefs.
# For discrete problems, it can be usually be represented as a vector.
# For tools supportng belief updates see POMDPToolbox.jl

"""
Abstract type for an object representing some knowledge about the state (often a probability distribution)

    T: the type over which the belief is over (e.g. state)
"""
abstract Belief{T} <: AbstractDistribution{T}

"""
Abstract type for an object that defines how a belief should be updated
"""
abstract BeliefUpdater{S,A,O}

"""
    initial_belief{S,A,O}(pomdp::POMDP{S,A,O}, belief::Belief{S} = create_belief(pomdp))

Returns an initial belief for the pomdp.
"""
@pomdp_func initial_belief{S,A,O}(pomdp::POMDP{S,A,O}, belief::Belief{S} = create_belief(pomdp))

"""
    create_belief(pomdp::POMDP)

Creates a belief either to be used by updater or pomdp
"""
@pomdp_func create_belief{S,A,O}(pomdp::POMDP{S,A,O})

"""
    create_belief{S,A,O}(updater::BeliefUpdater{S,A,O})

Creates a belief object of the type used by `updater` (preallocates memory)
"""
@pomdp_func create_belief{S,A,O}(updater::BeliefUpdater{S,A,O})

"""
    @pomdp_func update{S,A,O}(updater::BeliefUpdater{S,A,O}, belief_old::Belief{S}, action::A, obs::O,
    belief_new::Belief{S}=create_belief(updater))

Returns a new instance of an updated belief given `belief_old` and the latest action and observation.
"""
@pomdp_func update{S,A,O}(updater::BeliefUpdater{S,A,O}, belief_old::Belief{S}, action::A, obs::O, belief_new::Belief{S}=create_belief(updater))

# returns a belief that can be updated using `updater` that has a similar distribution to `b` (this conversion may be lossy)
"""
    convert_belief{S,A,O}(updater::BeliefUpdater{S,A,O}, belief::Belief{S},
    new_belief::Belief{S}=create_belief(updater)) = belief

Returns a belief that can be updated using `updater` that has a similar distribution to `belief`.
"""
@pomdp_func convert_belief{S,A,O}(updater::BeliefUpdater{S,A,O}, belief::Belief{S}, new_belief::Belief{S}=create_belief(updater)) = belief
