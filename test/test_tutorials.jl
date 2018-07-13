using NBInclude
using Base.Test

using POMDPs
POMDPs.add("DiscreteValueIteration")
POMDPs.add("MCTS")

using DiscreteValueIteration
using MCTS

@nbinclude("../examples/GridWorld.ipynb")
@nbinclude("../examples/Tiger.ipynb")
@nbinclude("../examples/rl-tuto/reinforcement_learning_tutorial.ipynb")
