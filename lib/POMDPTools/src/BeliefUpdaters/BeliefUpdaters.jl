module BeliefUpdaters

using POMDPs
import POMDPs: Updater, update, initialize_belief, pdf, mode, updater, support
using ..POMDPDistributions
using ..ModelTools

import Base: ==
import Statistics
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
