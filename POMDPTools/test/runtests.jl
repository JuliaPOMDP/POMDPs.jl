using POMDPTools
using POMDPModels: BabyPOMDP
using Test

@testset "POMDPTools.jl" begin
    include("model_tools/test_fully_observable_pomdp.jl")

    # include("belief_updaters/test_belief.jl")
    # include("belief_updaters/test_k_previous_observations.jl")
end
