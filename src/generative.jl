"""
    gen(...)

Sample from a generative POMDP or MDP model.

# `NamedTuple` Version

    gen(m::MDP, s, a, rng::AbstractRNG)

Return the `NamedTuple` `(sp=<the next state>, r=<the reward>)` and possibly other values (see below).

    gen(m::POMDP, s, a, rng::AbstractRNG)

Return the `NamedTuple` `(sp=<the next state>, o=<the observation>, r=<the reward>)` and possibly other values (see below).

The `NamedTuple` version of `gen` is the most convenient for problem writers to implement. However, it should *never* be used directly by solvers or simulators. Instead solvers and simulators should use the version with a return indicator argument described below. 

## Arguments
- `m`: an `MDP` or `POMDP` model
- `s`: the current state
- `a`: the action
- `rng`: a random number generator (Typically a `MersenneTwister`)

## Return
The function should return a `NamedTuple`. Typically, this `NamedTuple` will have the keys `sp` and `r` for an `MDP` and `sp`, `o`, and `r` for a `POMDP`. Occasionally, packages may request other values. The symbols for these values that appear as keys in the `NamedTuple` are known as *genvars*. The genvars for all loaded packages can be shown with `list_genvars()`. See the documentation for more details.

# `Return` Version

    gen(rt::Return, m::Union{MDP,POMDP}, s, a, rng::AbstractRNG)

Generate the values specified with return indicator `rt`. 

An implementation of this method is automatically provided by POMDPs.jl. Solvers and simulators should use this version. Problem writers may implement it in special cases (see the POMDPs.jl documentation for more information).

## Arguments
- `rt`: return value specifier (See `Return`)
- `m`, `s`, `a`, `rng`: same as above

## Return
This `Return` version of `gen` will return a `Tuple` or a single object. The values in this tuple should correspond to the genvars that are specified as parameters of `rt`. See the docstring for `Return` for more details.

    gen(rt::Return, m::Union{MDP,POMDP}, genvarargs..., rng::AbstractRNG)

Generate the values specified with return indicator `rt`.

In some cases, `s` and `a` are not the only inputs needed to generate the returned values specified in `rt`. For example, occasionally `gen(Return(:o), m, s, a, sp, rng)` will be implemented by a problem writer or used by a solver to generate observations when the next state has already been generated. `genvarargs` represents the other possible genvar values that may be needed.
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

    if implemented(initialstate_distribution, Tuple{p})
        return impl
    else
        req = @req initialstate_distribution(::p)
        reqs = [(implemented(req...), req...)]
        this = @req(initialstate(::p, ::rng))
        return quote
            try
                $impl # trick to get the compiler to insert the right backedges
            catch
                # TODO failed_synth_warning($this, $reqs)
                throw(MethodError(initialstate, (p, rng)))
            end
        end
    end
end
