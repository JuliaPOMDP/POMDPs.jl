#################################################################
######################## BELIEF #################################
#################################################################
# For tools supporting belief updates see POMDPToolbox.jl


"""
Abstract type for an object that defines how the belief should be updated

A belief is a general construct that represents the knowledge an agent has
about the state of the system. This can be a probability distribution, an
action observation history or a more general representation.
"""
abstract type Updater end


"""
    update(updater::Updater, belief_old, action, observation)

Return a new instance of an updated belief given `belief_old` and the latest action and observation.
"""
function update end

"""
    initialize_belief(updater::Updater,
                         state_distribution::Any)
    initialize_belief(updater::Updater, belief::Any)

Returns a belief that can be updated using `updater` that has similar
distribution to `state_distribution` or `belief`.

The conversion may be lossy. This function is also idempotent, i.e. there is a
default implementation that passes the belief through when it is already the
correct type: `initialize_belief(updater::Updater, belief) = belief`
"""
function initialize_belief end

# default implementation if the input is the same type as the output
initialize_belief(updater::Updater, belief) = belief

"""
    history(b)

Return the action-observation history associated with belief `b`.

The history should be an `AbstractVector`, `Tuple`, (or similar object that supports indexing with `end`) full of `NamedTuples` with keys `:a` and `:o`, i.e. `history(b)[end][:a]` should be the last action taken leading up to `b`, and `history(b)[end][:o]` should be the last observation received.

It is acceptable to return only part of the history if that is all that is available, but it should always end with the current observation. For example, it would be acceptable to return a structure containing only the last three observations in a length 3 `Vector{NamedTuple{(:o,),Tuple{O}}`.
"""
function history end

"""
    currentobs(b)

Return the latest observation associated with belief `b`.

If a solver or updater implements `history(b)` for a belief type, `currentobs` has a default implementation.
"""
currentobs(b) = history(b)[end].o
