# [Defining POMDPs](@id defining_pomdps)

The expressive nature of POMDPs.jl gives problem writers the flexibility to write their problem in many forms.
Custom POMDP problems are defined by implementing the functions specified by the POMDPs API.

## Types of problem definitions

There are two ways of specifying the state dynamics and observation behavior of a POMDP. The problem definition may include either an *explicit* definition of the probability distributions, or an implicit definition given only by a *generative* model.

An explicit definition contains the transition probabilities for each state and action, ``T(s' | s, a)``, and the observation probabilities for each state-action-state transition, ``O(o | s, a, s')``, (in continuous domains these are probability density functions). A generative definition contains only a single step simulator, ``s', o, r = G(s, a)`` (or ``s', r = G(s,a)`` for an MDP).

Accordingly, the POMDPs.jl model API is grouped into three sections:
1. The [*explicit*](@ref explicit_api) interface containing *functions that return distributions*
2. The [*generative*](@ref generative_api) interface containing *functions that return states and observations*
3. [*Common*](@ref common_api) functions used in both.

## What do I need to implement?

Generally, a problem will be defined by implementing *either*
- An explicit definition consisting of the three functions in (1) and some functions from (3), or
- A generative definition consisting of some functions from (2) and some functions from (3)
(though in some cases (e.g. particle filtering), implementations from all three sections are useful).

Note: since an explicit definition contains all of the information required for a generative definition, POMDPs.jl will automatically generate the generative functions at runtime if an explicit model is available.

An explicit definition will allow for use with the widest variety of tools and solvers, but a generative definition will generally be much easier to implement.

In order to determine which interface to use to express a problem, 2 questions should be asked:
1. Is it impossible to specify the probability distributions explicitly (or difficult compared to writing a state simulator)?
2. What solvers will be used to solve this, and what are their requirements?

If the answer to (1) is yes, then a generative definition should be used. More information about how to analyze question (2) can be found in the [Requirements](@ref requirements) section of the documentation.

Specific documentation for the two interfaces can be found here:
- [Explicit](@ref explicit_doc)
- [Generative](@ref generative_doc)
