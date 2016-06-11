#################################################################
######################## BELIEF #################################
#################################################################
# For tools supporting belief updates see POMDPToolbox.jl


"""
Abstract type for an object that defines how the belief should be updated

    B: belief type that parametrizes the updater

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

"""
    initialize_belief{B}(updater::Updater{B}, 
                         state_distribution::AbstractDistribution,
                         new_belief::B=create_belief(updater))
    initialize_belief{B}(updater::Updater{B},
                         belief::Any,
                         new_belief::B=create_belief(updater))

Returns a belief that can be updated using `updater` that has similar
distribution to `state_distribution` or `belief`.

The conversion may be lossy. This function is also idempotent, i.e. there is a
default implementation that passes the belief through when it is already the
correct type: `initialize_belief{B}(updater::Updater{B}, belief::B) = belief`
"""
@pomdp_func initialize_belief(updater::Updater, initial_state_dist::Any, new_belief=create_belief(updater))

# default implementation if the input is the same type as the output
initialize_belief{B}(updater::Updater{B}, belief::B, new_belief::B=create_belief(updater)) = belief
