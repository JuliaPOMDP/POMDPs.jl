# [POMDPs.jl](https://github.com/JuliaPOMDP/POMDPs.jl)
*A Julia interface for defining, solving and simulating partially observable Markov decision processes and their fully observable counterparts.*

## Package and Ecosystem Features

- General interface that can handle problems with discrete and continuous state/action/observation spaces
- A number of popular state-of-the-art solvers implemented for use out-of-the-box
- Tools that make it easy to define problems and simulate solutions
- Simple integration of custom solvers into the existing interface

## Available Packages

The POMDPs.jl package contains only the interface used for expressing and solving Markov decision processes (MDPs) and partially observable Markov decision processes (POMDPs).
The [POMDPTools](@ref pomdptools_section) package acts as a "standard library" for the POMDPs.jl interface, providing implementations of commonly-used components such as policies, belief updaters, distributions, and simulators.
The list of solver and support packages maintained by the [JuliaPOMDP](https://github.com/JuliaPOMDP) community is available at the [POMDPs.jl Readme](https://github.com/JuliaPOMDP/POMDPs.jl#supported-packages).

## Documentation Outline

The documentation is organized into three sections:

1.	Examples and Tutorials--Practical, step-by-step demonstrations are provided in the [Examples](@ref examples_section) and the [Gallery of POMDPs.jl Problems](@ref), illustrating common workflows and use cases.

2.	API Reference--Complete technical documentation of all interface functions, types, and methods in POMDPs.jl can be found in the [API Documentation](@ref).


3.	Explanatory Guide--Conceptual explanations of POMDPs.jl, including how to define problems, solve them using provided solvers, and simulate results. See the detailed sections listed below.


```@contents
Pages = reduce(vcat, map(last, Main.page_order))
Depth = 3
```