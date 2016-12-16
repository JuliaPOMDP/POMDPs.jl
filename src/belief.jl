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
function initial_state_distribution end

"""
    update{B,A,O}(updater::Updater, belief_old::B, action::A, obs::O)

Returns a new instance of an updated belief given `belief_old` and the latest action and observation.
"""
function update end

"""
    initialize_belief{B}(updater::Updater{B}, 
                         state_distribution::Any)
    initialize_belief{B}(updater::Updater{B}, belief::Any)

Returns a belief that can be updated using `updater` that has similar
distribution to `state_distribution` or `belief`.

The conversion may be lossy. This function is also idempotent, i.e. there is a
default implementation that passes the belief through when it is already the
correct type: `initialize_belief{B}(updater::Updater{B}, belief::B) = belief`
"""
function initialize_belief end

# default implementation if the input is the same type as the output
initialize_belief{B}(updater::Updater{B}, belief::B) = belief
