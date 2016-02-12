# url to remote organization repo
const REMOTE_URL = "https://github.com/sisl/"

# supported solvers
const SUPPORTED_SOLVERS = Set{AbstractString}(
                          ["DiscreteValueIteration",
                           "MCTS",
                           "QMDP",
                           "SARSOP",
                           "POMCP"])
