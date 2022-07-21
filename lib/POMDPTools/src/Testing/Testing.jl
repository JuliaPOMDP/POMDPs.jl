module Testing

using POMDPs
using Random

export test_solver,
    probability_check,
    obs_prob_consistency_check,
    trans_prob_consistency_check,
    has_consistent_distributions,
    has_consistent_initial_distribution,
    has_consistent_transition_distributions,
    has_consistent_observation_distributions

include("model.jl")
include("solver.jl")

end # module
