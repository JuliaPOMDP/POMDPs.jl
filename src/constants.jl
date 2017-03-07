"""
url to remote JuliaPOMDP organization repo
"""
const REMOTE_URL = "https://github.com/JuliaPOMDP/"

"""
Set containing string names of officially supported solvers and utility packages
(e.g. `MCTS`, `SARSOP`, `POMDPToolbox`, etc). 
If you have a validated solver that supports the POMDPs.jl API,
contact the developers to add your solver to this list. 
"""
# TODO (max): would it be better to have a dict of form: string => url for solvers?
const NATIVE_PACKAGES = Set{String}(
                        ["DiscreteValueIteration",
                         "MCTS",
                         "QMDP",
                         "POMCP",
                         "DESPOT",
                         "MCVI",
                         "GenerativeModels",
                         "POMDPModels",
                         "POMDPToolbox",
                         "POMDPXFiles",
                         "POMDPFiles",
                         "ParticleFilters",
                         "TabularTDLearning"])

const NON_NATIVE_PACKAGES = Set{String}(
                             ["SARSOP",
                             "POMDPSolve"])

const SUPPORTED_PACKAGES = union(NATIVE_PACKAGES, NON_NATIVE_PACKAGES)

const EXPORTED_TYPES = [MDP, 
                        POMDP, 
                        Policy, 
                        Simulator, 
                        Solver, 
                        Updater,
                        Union{MDP, POMDP}]
