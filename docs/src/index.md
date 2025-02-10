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

Documentation comes in three forms:
1. An explanatory guide is available in the sections outlined below.
2. How-to examples are available throughout this documentation with specicic examples in [Examples](@ref examples_section) and [Gallery of POMDPs.jl Problems](@ref).
3. Reference docstrings for the entire POMDPs.jl interface are available in the [API Documentation](@ref) section.
