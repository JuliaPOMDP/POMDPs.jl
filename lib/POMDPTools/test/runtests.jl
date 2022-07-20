using POMDPTools
using Test

using POMDPs
using POMDPModels: BabyPOMDP, SimpleGridWorld

import Random
using Random: MersenneTwister
using DiscreteValueIteration: ValueIterationSolver

@testset "POMDPTools.jl" begin
    include("distributions/test_bool.jl")
    include("distributions/test_deterministic.jl")
    include("distributions/test_implicit.jl")
    include("distributions/test_pretty_printing.jl")
    include("distributions/test_sparse_cat.jl")
    include("distributions/test_uniform.jl")

    # include("model_tools/test_fully_observable_pomdp.jl")

    # include("belief_updaters/test_belief.jl")
    # include("belief_updaters/test_k_previous_observations.jl")
end
