# test simulate function using a random policy on the crying baby problem
import POMDPs
import POMDPs.action
import POMDPModels
using Distributions

problem = POMDPModels.BabyPOMDP(-0.1, -1)

# define a random policy
type RandomBabyPolicy <: POMDPs.Policy
    rng::AbstractRNG
end
action(p::RandomBabyPolicy, b::POMDPs.Belief) = POMDPModels.BabyAction(rand(p.rng)>0.5)

rng = MersenneTwister(1)

POMDPs.simulate(problem,
                RandomBabyPolicy(rng),
                POMDPModels.BabyStateDistribution(0.5),
                rng=rng,
                eps=1e-2)
