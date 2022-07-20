let

using POMDPModels

problem = LegacyGridWorld()

policy = UniformRandomPolicy(problem)
sim = RolloutSimulator(max_steps=10)
simulate(sim, problem, policy)

policy = CategoricalTabularPolicy(problem)
sim = RolloutSimulator(max_steps=10)
simulate(sim, problem, policy)

end
