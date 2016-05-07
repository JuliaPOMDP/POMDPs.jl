# POMDPs
*A Julia interface for defining, solving and simulating partially observable Markov decision processes and their fully
observable counterparts.*

## Package Features

- General interface that can handle problems with discrete and continuous state/action/observation spaces
- A number of popular state-of-the-art solvers availiable to use out of the box
- Tools that make it easy to define problems and simulate solutions 
- Simple integration of custom solvers into the existing interface

## Availible Solvers

The POMDPs.jl package contains only an interface to use for expressing and solving POMDPs. Solvers are contained in external packages that can be downloaded using [`POMDPs.add`]({ref}).

The following MDP solvers support this interface:

- [Value Iteration](https://github.com/JuliaPOMDP/DiscreteValueIteration.jl)
- [Monte Carlo Tree Search](https://github.com/JuliaPOMDP/MCTS.jl)

The following POMDP solvers support this interface:

- [QMDP](https://github.com/JuliaPOMDP/QMDP.jl)
- [SARSOP](https://github.com/JuliaPOMDP/SARSOP.jl)
- [POMCP](https://github.com/JuliaPOMDP/POMCP.jl)
- [POMDPSolve](https://github.com/JuliaPOMDP/POMDPSolve.jl)

## Manual Outline

    {contents}

