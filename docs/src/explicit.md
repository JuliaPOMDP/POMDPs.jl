# [Explicit (PO)MDP Interface](@id explicit_doc)

When using the explicit interface, the transition and observation probabilities must be explicitly defined.

!!! note 

    There is no requirement that a problem defined using the explicit interface be discrete; it is straightforward to define continuous POMDPs with the explicit interface, provided that the distributions have some finite parameterization.

## Explicit (PO)MDP interface

The explicit interface consists of the following functions:

- [`initialstate_distribution`](@ref)`(pomdp)` specifies the initial distribution of states for a problem (this is also translated to the initial belief for pomdps).
- [`transition`](@ref)`(pomdp, s, a)` defines the state transition probability distribution for state `s` and action `a`. This defines an explicit model for the [`:sp` DDN node](@ref Dynamic-decision-networks).
- [`observation`](@ref)`(pomdp, [s,] a, sp)` defines the observation distribution given that action `a` was taken and the state is now `sp` (The observation can optionally depend on `s` - see docstring). This defines an explicit model for the [`:o` DDN node](@ref Dynamic-decision-networks).
- [`reward`](@ref)`(pomdp, s, a[, sp[, o]])` defines the reward, which is a deterministic function of the state and action (and optionally `sp` and `o` - see docstring). This defines an explicit model for the [`:r` DDN node](@ref Dynamic-decision-networks).

[`transition`](@ref), [`observation`](@ref), and [`initialstate_distribution`](@ref) should return distribution objects that implement part or all of the [distribution interface](@ref Distributions). Some predefined distributions can be found in [Distributions.jl](https://github.com/JuliaStats/Distributions.jl) or [POMDPModelTools.jl](https://github.com/JuliaPOMDP/POMDPModelTools.jl), or custom types that represent distributions appropriate for the problem may be created.

### Example 

An example of defining a problem using the explicit interface can be found at: 
[https://github.com/JuliaPOMDP/POMDPExamples.jl/blob/master/notebooks/Defining-a-POMDP-with-the-Explicit-Interface.ipynb](https://github.com/JuliaPOMDP/POMDPExamples.jl/blob/master/notebooks/Defining-a-POMDP-with-the-Explicit-Interface.ipynb)
