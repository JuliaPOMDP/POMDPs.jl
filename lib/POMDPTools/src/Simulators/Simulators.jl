module Simulators

using POMDPs
using ..Policies
using ..ModelTools
using ..BeliefUpdaters
using Random
using ProgressMeter
using DataFrames
using Distributed
using NamedTupleTools

import POMDPLinter: @POMDP_require, @req, @subreq, implemented
import POMDPs: simulate, discount

export RolloutSimulator
include("rollout.jl")

export
    SimHistory,
    AbstractSimHistory,
    HistoryIterator,
    eachstep,
    state_hist,
    action_hist,
    observation_hist,
    belief_hist,
    reward_hist,
    info_hist,
    ainfo_hist,
    uinfo_hist,
    exception,
    backtrace,
    undiscounted_reward,
    discounted_reward,
    n_steps,
    step_tuple
include("history.jl")

export sim
include("sim.jl")

export HistoryRecorder
include("history_recorder.jl")

export
    StepSimulator,
    stepthrough
include("stepthrough.jl")

export
    Sim,
    run,
    run_parallel,
    problem
include("parallel.jl")

export
    DisplaySimulator
include("display.jl")

end # module
