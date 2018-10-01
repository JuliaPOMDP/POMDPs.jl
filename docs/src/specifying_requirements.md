# [Specifying Requirements](@id specifying_requirements)

## Purpose

When a researcher or student wants to use a solver in the POMDPs ecosystem, the first question they will ask is "What do I have to implement to use this solver?". The requirements interface provides a standard way for solver writers to answer this question.

## Internal interface

The most important functions in the requirements interface are [`get_requirements`](@ref), [`check_requirements`](@ref), and [`show_requirements`](@ref).

`get_requirements(f::Function, args::Tuple{...})` should be implemented by a solver or simulator writer for all important functions that use the POMDPs.jl interface. In practice, this function will rarely by implemented directly because the [@POMDP_require](@ref pomdp_require_section) macro automatically creates it. The function should return a `RequirementSet` object containing all of the methods POMDPs.jl functions that need to be implemented for the function to work with the specified arguments.

[`check_requirements`](@ref) returns true if [all of the requirements in a `RequirementSet` are met](@ref implemented_section), and [`show_requirements`](@ref) prints out a list of the requirements in a `RequirementSet` and indicates which ones have been met.

## [@POMDP_require](@id pomdp_require_section)

The [`@POMDP_require`](@ref) macro is the main point of interaction with the requirements system for solver writers. It uses a special syntax to automatically implement [`get_requirements`](@ref). This is best shown by example. Consider this `@POMDP_require` block from the [DiscreteValueIteration package](https://github.com/JuliaPOMDP/DiscreteValueIteration.jl):

```julia
@POMDP_require solve(solver::ValueIterationSolver, mdp::Union{MDP,POMDP}) begin
    P = typeof(mdp)
    S = statetype(P)
    A = actiontype(P)
    @req discount(::P)
    @req n_states(::P)
    @req n_actions(::P)
    @subreq ordered_states(mdp)
    @subreq ordered_actions(mdp)
    @req transition(::P,::S,::A)
    @req reward(::P,::S,::A,::S)
    @req stateindex(::P,::S)
    as = actions(mdp)
    ss = states(mdp)
    @req iterator(::typeof(as))
    @req iterator(::typeof(ss))
    s = first(iterator(ss))
    a = first(iterator(as))
    dist = transition(mdp, s, a)
    D = typeof(dist)
    @req iterator(::D)
    @req pdf(::D,::S)
end
```

The first expression argument to the macro is a function signature specifying what the requirements apply to. The above example implements `get_requirements{P<:Union{POMDP,MDP}}(solve::typeof(solve), args::Tuple{ValueIterationSolver,P})` which will construct a `RequirementSet` containing the requirements for executing the `solve` function with `ValueIterationSolver` and `MDP` or `POMDP` arguments at runtime.

The second expression is a [`begin`-`end` block](http://docs.julialang.org/en/release-0.5/manual/control-flow/#compound-expressions) that specifies the requirements. The arguments in the function signature (`solver` and `mdp` in this example) may be used within the block.

The [`@req`](@ref) macro is used to specify a required function. Each [`@req`](@ref) should be followed by a function with the argument types specified. The [`@subreq`](@ref) macro is used to denote that the requirements of another function are also required. Each [`@subreq`](@ref) should be followed by a function call.

## `requirements_info`

While the `@POMDP_require` macro is used to specify requirements for a specific method, the [`requirements_info`](@ref) function is a more flexible communication tool for a solver writer. [`requirements_info`](@ref) should print out a message describing the requirements for a solver. The exact form of the message is up to the solver writer, but it should be carefully thought-out because problem-writers will be directed to call the function (via the `@requirements_info` macro) as the first step in using a new solver (see [tutorial](def_pomdp.md)).

By default, `requirements_info` calls [`show_requirements`](@ref) on the `solve` function. This is adequate in many cases, but in some cases, notably for online solvers such as [MCTS](https://github.com/JuliaPOMDP/MCTS.jl), the requirements for [`solve`](@ref) do not give a good indication of the requirements for using the solver. Instead, the requirements for [`action`](@ref) should be displayed. The following example shows a more informative version of `requirements_info` from the MCTS package. Since [`action`](@ref) requires a state argument, `requirements_info` prompts the user to provide one.

```julia
function POMDPs.requirements_info(solver::AbstractMCTSSolver, problem::Union{POMDP,MDP})
    if statetype(typeof(problem)) <: Number
        s = one(statetype(typeof(problem)))
        requirements_info(solver, problem, s)
    else
        println("""
            Since MCTS is an online solver, most of the computation occurs in `action(policy, state)`. In order to view the requirements for this function, please, supply a state as the third argument to `requirements_info`, e.g.

                @requirements_info $(typeof(solver))() $(typeof(problem))() $(statetype(typeof(problem)))()

                """)
    end
end

function POMDPs.requirements_info(solver::AbstractMCTSSolver, problem::Union{POMDP,MDP}, s)
    policy = solve(solver, problem)
    requirements_info(policy, s)
end

function POMDPs.requirements_info(policy::AbstractMCTSPolicy, s)
    @show_requirements action(policy, s)
end
```

## `@warn_requirements`

The `@warn_requirements` macro is a useful tool to improve usability of a solver. It will show a requirements list only if some requirements are not met. It might be used, for example, in the solve function to give a problem writer a useful error if some required methods are missing (assuming the solver writer has already used `@POMDP_require` to specify the requirements for `solve`):

```julia
function solve(solver::ValueIterationSolver, mdp::Union{POMDP, MDP})
    @warn_requirements solve(solver, mdp)

    # do the work of solving
end
```

`@warn_requirements` does perform a runtime check of requirements every time it is called, so it should not be used in code that may be used in fast, high-performance loops.

## [Determining whether a function is implemented](@id implemented_section)

When checking requirements in `check_requirements`, or printing in `show_requirements`, the [`implemented`](@ref) function is used to determine whether an implementation for a function is available. For example `implemented(discount, Tuple{NewPOMDP})` should return true if the writer of the `NewPOMDP` problem has implemented discount for their problem. In most cases, the default implementation,
```julia
implemented(f::Function, TT::TupleType) = method_exists(f, TT)
```
will automatically handle this, but there may be cases in which you want to override the behavior of `implemented`, for example, if the function can be synthesized from other functions. Examples of this can be found in the [default implementations of the generative interface funcitons](https://github.com/JuliaPOMDP/POMDPs.jl/blob/master/src/generative_impl.jl.jl).
