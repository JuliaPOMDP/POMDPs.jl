# [POMDPs.jl](https://github.com/JuliaPOMDP/POMDPs.jl)
*A Julia interface for defining, solving and simulating partially observable Markov decision processes and their fully
observable counterparts.*

## Package Features

- General interface that can handle problems with discrete and continuous state/action/observation spaces
- A number of popular state-of-the-art solvers available to use out of the box
- Tools that make it easy to define problems and simulate solutions
- Simple integration of custom solvers into the existing interface

## Available Packages

The POMDPs.jl package contains the interface used for expressing and solving Markov decision processes (MDPs) and partially
observable Markov decision processes (POMDPs) in the Julia programming language. The
[JuliaPOMDP](https://github.com/JuliaPOMDP) community maintains these packages.
The list of solver and support packages is maintained at the [POMDPs.jl Readme](https://github.com/JuliaPOMDP/POMDPs.jl#supported-packages).

## Manual Outline

When updating these documents, make sure this is synced with [docs/make.jl](https://github.com/JuliaPOMDP/POMDPs.jl/blob/master/docs/make.jl)!!

### Basics

```@contents
Pages = ["index.md", "install.md", "get_started.md", "concepts.md"]
```

### Defining POMDP Models

```@contents
Pages = [ "def_pomdp.md", "explicit.md", "generative.md", "requirements.md", "interfaces.md" ]
```

### Writing Solvers and Updaters

```@contents
Pages = [ "def_solver.md", "specifying_requirements.md", "def_updater.md" ]
```

### Analyzing Results

```@contents
Pages = [ "simulation.md", "run_simulation.md", "policy_interaction.md" ]
```

### Reference

```@contents
Pages = ["faq.md", "api.md"]
```
