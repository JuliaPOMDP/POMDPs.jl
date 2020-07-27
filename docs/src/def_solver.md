# Solvers

Defining a solver involves creating or using four pieces of code:

1. A subtype of [`Solver`](@ref) that holds the parameters and configuration options for the solver.
2. A subtype of [`Policy`](@ref) that holds all of the data needed to choose actions online.
3. A method of [`solve`](@ref) that takes the solver and a (PO)MDP as arguments, performs all of the offline computations for solving the problem, and returns the policy.
4. A method of [`action`](@ref) that takes in the policy and a state or belief and returns an action.

In many cases, items 2 and 4 can be satisfied with an off-the-shelf solver from [POMDPPolicies.jl](https://github.com/JuliaPOMDP/POMDPPolicies.jl). [POMDPModelTools.jl](https://github.com/JuliaPOMDP/POMDPModelTools.jl) also contains many tools that are useful for defining solvers in a robust, concise, and readable manner.

## Online and Offline Solvers

Generally, solvers can be grouped into two categories: *Offline* solvers that do most of their computational work *before* interacting with the environment, and *online* solvers that do their work online.
Although offline and online solvers both use the exact same [`Solver`](@ref), [`solve`](@ref), [`Policy`](@ref), [`action`](@ref) structure, the work of defining online and offline solvers is focused on different portions.

For an offline solver, most of the implementation effort will be spent on the [`solve`] function, and an off-the-shelf policy from [POMDPPolicies.jl](https://github.com/JuliaPOMDP/POMDPPolicies.jl) will typically be used.

For an online solver, the [`solve`](@ref) function typically does little or no work, but merely creates a policy object that will carry out computation online. It is typical in POMDPs.jl to use the term "Planner" to name a [`Policy`](@ref) object for an online solver that carries out a large amount of computation at interaction time. In this case most of the effort will be focused on implementing the [`action`](@ref) method for the "Planner" `Policy` type.

## Examples

Solver implementation is most clearly explained through examples. The following sections contain examples of both online and offline solver definitions:
```@contents
Pages = ["offline_solver.md", "online_solver.md"]
```
