"""
url to remote JuliaPOMDP organization repo
"""
const REMOTE_URL = "https://github.com/JuliaPOMDP/"

"""
Set containing string names of officially supported solvers 
(e.g. `MCTS`, `SARSOP`, etc). 
If you have a validated solver that supports the POMDPs.jl API,
contact the developers to add your solver to this list. 
"""
# TODO (max): would it be better to have a dict of form: string => url for solvers?
const SUPPORTED_SOLVERS = Set{AbstractString}(
                          ["DiscreteValueIteration",
                           "MCTS",
                           "QMDP",
                           "SARSOP",
                           "POMCP",
                           "POMDPSolve"])
