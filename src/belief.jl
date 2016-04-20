#################################################################
######################## BELIEF #################################
#################################################################
# The abstract Belief type implements initialization (initial_belief and create_belief)
# and update (belief) methods for POMDP beliefs.
# For discrete problems, it can be usually be represented as a vector.
# For tools supportng belief updates see POMDPToolbox.jl


"""
Abstract type for an object that defines how the belief should be updated

    B: belief type that parametarizes the updater

A belief is a general construct that represents the knowledge an agent has
about the state of the system. This can be a probability distribution, an
action observation history or a more general representation. 
"""
abstract Updater{B}

# TODO(max): should this be moved to pomdp.jl?
"""
    initial_state_distribution(pomdp::POMDP)

Returns an initial belief for the pomdp.
"""
@pomdp_func initial_state_distribution(pomdp::POMDP)

"""
    create_belief(pomdp::POMDP)

Creates a belief either to be used by updater or pomdp
"""
@pomdp_func create_belief(pomdp::POMDP)

"""
    create_belief(updater::Updater)

Creates a belief object of the type used by `updater` (preallocates memory)
"""
@pomdp_func create_belief(updater::Updater)

"""
    update{B,A,O}(updater::Updater, belief_old::B, action::A, obs::O,
    belief_new::B=create_belief(updater))

Returns a new instance of an updated belief given `belief_old` and the latest action and observation.
"""
@pomdp_func update{B,A,O}(updater::Updater, belief_old::B, action::A, obs::O, belief_new::B=create_belief(updater))

# returns a belief that can be updated using `updater` that has a similar distribution to `b` (this conversion may be lossy)
"""
    convert_belief{B}(updater::Updater, belief::B,
    new_belief::B=create_belief(updater)) = belief

Returns a belief that can be updated using `updater` that has a similar distribution to `belief`.
"""
@pomdp_func convert{B}(updater::Updater, initial_state_dist::AbstractDistribution, belief::B=create_belief(updater)) = belief
