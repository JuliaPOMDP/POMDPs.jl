# [Examples](@id examples_section)

This section contains examples of how to use POMDPs.jl. For specific informaiton about the interface and functions used in the examples, please reference the correpsonding area in the documenation or the [API Documentation](@ref).

The examples are organized by topic. The exmaples are designed to build through each step. First, we have to define a POMDP. Then we need to solve the POMDP to get a policy. Finally, we can simulate the policy to see how it performs. The examples are designed to be exeucted in order. For example, the examples in [Simulations Examples](@ref) assume that the POMDPs defined in the [Defining a POMDP](@ref) section have been defined and we have a policy we would like to simulate that we computed in the [Using Different Solvers](@ref) section.

The [GridWorld MDP Tutorial](@ref) section is a standalone example that does not require any of the other examples.

## Outline
```@contents
Pages = ["example_defining_problems.md", "example_solvers.md", "example_simulations.md", "example_gridworld_mdp.md"]
```