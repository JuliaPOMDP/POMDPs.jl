module BeliefUpdaters


using POMDPs
import POMDPs: Updater, update, initialize_belief, pdf, mode, updater, support
import Base: ==
import Statistics
using ..ModelTools
using StatsBase
using Random


export
    NothingUpdater
include("void.jl")

export
    DiscreteBelief,
    DiscreteUpdater,
    uniform_belief

include("discrete.jl")

export
    PreviousObservationUpdater,
    FastPreviousObservationUpdater,
    PrimedPreviousObservationUpdater

include("previous_observation.jl")

export
    KMarkovUpdater

include("k_previous_observations.jl")

end
