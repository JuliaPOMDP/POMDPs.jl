# POMDPs
*A Julia interface for defining, solving and simulating partially observable Markov decision processes and their fully
observable counterparts.*

## Package Features

- General interface that can handle problems with discrete and continuous state/action/observation spaces
- A number of popular state-of-the-art solvers availiable to use out of the box
- Tools that make it easy to define problems and simulate solutions
- Simple integration of custom solvers into the existing interface


## Available Packages

The POMDPs.jl package contains the interface used for expressing and solving Markov decision processes (MDPs) and partially
observable Markov decision processes (POMDPs) in the Julia programming language. The
[JuliaPOMDP](https://github.com/JuliaPOMDP) community maintains these packages. The packages currently maintained by
JuliaPOMDP are as follows: 

### MDP solvers:

- [Value Iteration](https://github.com/JuliaPOMDP/DiscreteValueIteration.jl)
- [Monte Carlo Tree Search](https://github.com/JuliaPOMDP/MCTS.jl)

### POMDP solvers:

- [QMDP](https://github.com/JuliaPOMDP/QMDP.jl)
- [SARSOP](https://github.com/JuliaPOMDP/SARSOP.jl)
- [POMCP](https://github.com/JuliaPOMDP/POMCP.jl)
- [DESPOT](https://github.com/JuliaPOMDP/DESPOT.jl)
- [MCVI](https://github.com/JuliaPOMDP/MCVI.jl)
- [POMDPSolve](https://github.com/JuliaPOMDP/POMDPSolve.jl)

### Support Tools:

- [POMDPToolbox](https://github.com/JuliaPOMDP/POMDPToolbox.jl)
- [POMDPModels](https://github.com/JuliaPOMDP/POMDPModels.jl)

### Interface Extensions:

- [GenerativeModels](https://github.com/JuliaPOMDP/GenerativeModels.jl)
- [POMDPBounds](https://github.com/JuliaPOMDP/POMDPBounds.jl)

## Manual Outline

```@contents
```


