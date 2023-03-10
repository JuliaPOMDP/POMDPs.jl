"""
Provides a basic interface for defining and solving MDPs/POMDPs
"""
module POMDPs

using Random
import Base: rand
import Statistics
import Distributions: rand, pdf, mode, mean, support
import NamedTupleTools
import Pkg
using Graphs: SimpleDiGraph, topological_sort_by_dfs, add_edge!

import POMDPLinter

export
    # Abstract type
    POMDP,
    MDP,

    # Model functions
    discount,
    states,
    actions,
    observations,
    transition,
    observation,
    reward,
    isterminal,
    initialstate,
    initialobs,

    # Generative model functions
    gen,
    @gen,
    DDNOut,

    # Discrete Functions
    length,
    stateindex,
    actionindex,
    obsindex,

    # Common Functions
    rand,
    pdf,
    mode,
    mean,
    support,

    # Solver types
    Solver,
    solve,

    # Beliefs
    Updater,
    update,
    initialize_belief,
    history,
    currentobs,

    # Policy
    Policy,
    action,
    updater,
    value,

    # Simulation
    Simulator,
    simulate,

    # Utilities
    convert_s,
    convert_a,
    convert_o,
    statetype,
    actiontype,
    obstype


include("pomdp.jl")
include("solver.jl")
include("simulator.jl")
include("distribution.jl")
include("belief.jl")
include("space.jl")
include("policy.jl")
include("type_inferrence.jl")
include("generative.jl")
include("gen_impl.jl")

end
