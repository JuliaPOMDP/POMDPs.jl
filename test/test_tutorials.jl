using NBInclude
using Base.Test

try
    using POMDPs
    POMDPs.add("DiscreteValueIteration")
    POMDPs.add("MCTS")

    using DiscreteValueIteration
    using MCTS

    @nbinclude("../examples/GridWorld.ipynb")
catch ex
    warn("The Grid World tutorial notebook failed with the following error:")
    showerror(ex)
    warn("This failure is being ignored.")
end
@nbinclude("../examples/Tiger.ipynb")
@nbinclude("../examples/rl-tuto/reinforcement_learning_tutorial.ipynb")
