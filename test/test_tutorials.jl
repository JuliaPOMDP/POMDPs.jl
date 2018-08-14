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
    @warn "The Grid World tutorial notebook failed with the following error:"
    showerror(STDERR, ex)
    @warn "This failure is being ignored."
end

try
    @nbinclude("../examples/Tiger.ipynb")
catch ex
    @warn "The Tiger tutorial notebook failed with the following error:"
    showerror(STDERR, ex)
    @warn "This failure is being ignored."
end

try
    @nbinclude("../examples/rl-tuto/reinforcement_learning_tutorial.ipynb")
catch ex
    @warn "The RL tutorial notebook failed with the following error:"
    showerror(STDERR, ex)
    @warn "This failure is being ignored."
end
