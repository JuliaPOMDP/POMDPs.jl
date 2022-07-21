using POMDPTools
using Test

using POMDPs
using POMDPModels: BabyPOMDP, TigerPOMDP, SimpleGridWorld, LegacyGridWorld, RandomMDP, TMaze, Starve
using DiscreteValueIteration: ValueIterationSolver

import Random
using Random: MersenneTwister, AbstractRNG

using SparseArrays: sparse

@testset "POMDPTools.jl" begin
    # Distributions
    include("distributions/test_bool.jl")
    include("distributions/test_deterministic.jl")
    include("distributions/test_implicit.jl")
    include("distributions/test_pretty_printing.jl")
    include("distributions/test_sparse_cat.jl")
    include("distributions/test_uniform.jl")

    # Model Tools
    include("model_tools/test_fully_observable_pomdp.jl")
    include("model_tools/test_generative_belief_mdp.jl")
    include("model_tools/test_info.jl")
    include("model_tools/test_matrices.jl")
    include("model_tools/test_obs_weight.jl")
    include("model_tools/test_ordered_spaces.jl")
    include("model_tools/test_reward_model.jl")
    include("model_tools/test_tabular.jl")
    include("model_tools/test_terminal_state.jl")
    include("model_tools/test_underlying_mdp.jl")
    include("model_tools/test_visualization.jl")

    # Belief Updaters
    # include("belief_updaters/test_belief.jl")
    # include("belief_updaters/test_k_previous_observations.jl")
end
