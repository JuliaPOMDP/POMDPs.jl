"""
    gen(...)

Sample from generative model of a POMDP or MDP.

There are 3 versions:
- For problem-writers, the most convenient version to implement is gen(m::Union{MDP,POMDP}, s, a, rng::AbstractRNG), which returns a `NamedTuple`.
- Solvers and simulators should use the version with a `DDNOut` argument.
- Defining behavior for and sampling from individual nodes of the dynamic decision network can be accomplished using the version with a `DDNNode` argument.

See below for detailed documentation for each type.

---

    gen(t::DDNOut{X}, m::Union{MDP,POMDP}, s, a, rng::AbstractRNG) where X

Sample values from several nodes in the dynamic decision network. 

An implementation of this method is automatically provided by POMDPs.jl. Solvers and simulators should use this version. Problem writers may implement it directly in special cases (see the POMDPs.jl documentation for more information).

# Arguments
- `t::DDNOut`: which DDN nodes the function should sample from.
- `m`: an `MDP` or `POMDP` model
- `s`: the current state
- `a`: the action
- `rng`: a random number generator (Typically a `MersenneTwister`)

# Return
If the `DDNOut` parameter, `X`, is a symbol, return a value sample from the corresponding node. If `X` is a tuple of symbols, return a `Tuple` of values sampled from the specified nodes.

# Examples
Let `m` be an `MDP` or `POMDP`, `s` be a state of `m`, `a` be an action of `m`, and `rng` be an `AbstractRNG`.
- `gen(DDNOut(:sp, :r), m, s, a, rng)` returns a `Tuple` containing the next state and reward.
- `gen(DDNOut(:sp, :o, :r), m, s, a, rng)` returns a `Tuple` containing the next state, observation, and reward.
- `gen(DDNOut(:sp), m, s, a, rng)` returns the next state.

---

    gen(m::Union{MDP,POMDP}, s, a, rng::AbstractRNG)

Convenience function for implementing the entire MDP/POMDP generative model in one function by returning a `NamedTuple`.

The `NamedTuple` version of `gen` is the most convenient for problem writers to implement. However, it should *never* be used directly by solvers or simulators. Instead solvers and simulators should use the version with a `DDNOut` first argument. 

# Arguments
- `m`: an `MDP` or `POMDP` model
- `s`: the current state
- `a`: the action
- `rng`: a random number generator (Typically a `MersenneTwister`)

# Return
The function should return a [`NamedTuple`](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple). Typically, this `NamedTuple` will be `(sp=<next state>, r=<reward>)` for an `MDP` or `(sp=<next state>, o=<observation>, r=<reward>) for a `POMDP`.

---

    gen(v::DDNNode{name}, m::Union{MDP,POMDP}, depargs..., rng::AbstractRNG)

Sample a value from a node in the dynamic decision network. 

These functions will be used within gen(::DDNOut, ...) to sample values for all outputs and their dependencies. They may be implemented directly by a problem-writer if they wish to implement a generative model for a particular node in the dynamic decision network, and may be called in solvers to sample a value for a particular node.

# Arguments
- `v::DDNNode{name}`: which DDN node the function should sample from.
- `depargs`: values for all the dependent nodes. Dependencies are determined by `deps(DDNStructure(m), name)`.
- `rng`: a random number generator (Typically a `MersenneTwister`)

# Return
A sampled value from the specified node.

# Examples
Let `m` be a `POMDP`, `s` and `sp` be states of `m`, `a` be an action of `m`, and `rng` be an `AbstractRNG`.
- `gen(DDNNode(:sp), m, s, a, rng)` returns the next state.
- `gen(DDNNode(:o), m, s, a, sp, rng)` returns the observation given the previous state, action, and new state.
"""
function gen end

"""
    initialstate(m::Union{POMDP,MDP}, rng::AbstractRNG)

Return a sampled initial state for the problem `m`.

Usually the initial state is sampled from an initial state distribution. The random number generator `rng` should be used to draw this sample (e.g. use `rand(rng)` instead of `rand()`).
"""
function initialstate end

function implemented(f::typeof(initialstate), TT::Type)
    if !hasmethod(f, TT)
        return false
    end
    m = which(f, TT)
    if m.module == POMDPs && !implemented(initialstate_distribution, Tuple{TT.parameters[1]})
        return false
    else
        return true
    end
end

@generated function initialstate(p::Union{POMDP,MDP}, rng::AbstractRNG)
    impl = quote
        d = initialstate_distribution(p)
        return rand(rng, d)
    end

    # it is technically illegal to call this within the generated function
    if implemented(initialstate_distribution, Tuple{p})
        return impl
    else
        return quote
            try
                $impl # trick to get the compiler to insert the right backedges
            catch
                throw(MethodError(initialstate, (p, rng)))
            end
        end
    end
end

"""
    initialobs(m::POMDP, s, rng::AbstractRNG)

Return a sampled initial observation for the problem `m` and state `s`.

This function is only used in cases where the policy expects an initial observation rather than an initial belief, e.g. in a reinforcement learning setting. It is not used in a standard POMDP simulation.

By default, it will fall back to `observation(m, s)`. The random number generator `rng` should be used to draw this sample (e.g. use `rand(rng)` instead of `rand()`).
"""
function initialobs end

function implemented(f::typeof(initialobs), TT::Type)
    if !hasmethod(f, TT)
        return false
    end
    m = which(f, TT)
    if m.module == POMDPs && !implemented(observation, Tuple{TT.parameters[1:2]...})
        return false
    else
        return true
    end
end

@generated function initialobs(m::POMDP, s, rng::AbstractRNG)
    impl = quote
        d = observation(m, s)
        return rand(rng, d)
    end

    # it is technically illegal to call this within the generated function
    if implemented(observation, Tuple{m, s})
        return impl
    else
        return quote
            try
                $impl # trick to get the compiler to insert the right backedges
            catch
                throw(MethodError(initialobs, (m, s, rng)))
            end
        end
    end
end
