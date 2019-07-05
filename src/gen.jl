# functions for models to provide
function gen end # always returns a NamedTuple
function genstate end
function genobs end


# functions for solvers and simulators to use
generate(v::Val{r::Symbol}, args...) = generate_default(r, args...)

@generated function generate(v::Val{r::Symbol}, m, s, a, rng)
    if r == :sp && implemented(genstate, Tuple{m,s,a,rng})
        return :(genstate(m,s,a,rng))
    end
    return :(first(generate(Val{($r,)}(), m, s, a, rng)))
end

@generated function generate(v::Val{t::Tuple}, m, s, a, rng) # always returns a NamedTuple

    @debug("Creating an implementation for generate(::Val{$S}, ::M, ::S, ::A, ::RNG)",
           M=m, S=s, A=a, RNG=rng)

    # use old generate_ function if available
    if implemented(old_generate_function(v), Tuple{m, s, a, rng})
        @warn("")
        return :($(old_generate_function(v))(m, s, a, rng))
    end

    # use anything available from gen
    if implemented(gen, Tuple{m,s,a,rng})
        @debug("Found gen(::M, ::S, ::A, ::RNG)::N", M=m, S=s, A=a, RNG=rng)
        expr = quote
            x = gen(m, s, a, rng)
            @assert x isa NamedTuple "gen(...) must return a NamedTuple; got $(typeof(x))"
        end
    else
        expr = quote x = NamedTuple() end
    end

    # fill in any elements that might be missing
    return_tuple_elements = Expr[]
    @assert expr.head = :block
    for var::Symbol in v.parameters
        sym = Meta.quot(var)
        genvarargs = genvars[var].deps
        varblock = quote
            if haskey(x, $sym)
                $var = x[$sym]
            else
                $var = generate_default(sym, m, $(genvarargs...), rng)
            end
        end
        append!(expr.args, varblock.args)
        push!(return_tuple_elements, :($var=$var))
    end
    return_expr = :(return ($(return_tuple_elements...)))
    append!(expr.args, return_expr.args)

    @debug("Implementing generate(::Val{$S}, ::M, ::S, ::A, ::RNG) with:\n$expr")
    return expr
end

struct GenVar
    mod::Module #?
    longname::String
    descripton::String
    deps::Array{Symbol}
    implementations::Function
end

const genvars = Dict{Symbol, GenVarData}()


rand_transition(m, s, a, rng) = rand(rng, transition(m, s, a))
rand_observation(m, s, a, sp, rng) = rand(rng, observation(m, s, a, sp))

genvars[:s] = GenVar(@__Module__, "state", "state at the beginning of the step", Symbol[])
genvars[:a] = GenVar(@__Module__, "action", "action taken by the agent", Symbol[])

genvars[:sp] = GenVar(@__Module__,
                      "new state",
                      "state at the end of the step",
                      [:s, :a]
                     ) do M, S, A, RNG

    [genstate,
     @req(transition(::M, ::S, ::A)) => rand_transition,
     DeprecatedFallback(generate_s)
    ]
end

genvars[:o] = GenVar(@__Module__,
                     "observation",
                     "observation (usually depends on sp)",
                     [:s, :a, :sp]
                    ) do M, S, A, SP, RNG
    [genobs,
     @req(observation(::M, ::S, ::A, ::SP)) => rand_observation,
     DeprecatedFallback(generate_o)
    ]
end

genvars[:r] = GenVar(@__Module__,
                     "reward",
                     "reward generated by the step",
                     [:s, :a, :sp, :o],
                     (...)->reward,
                     rng_arg=false
                    ) 
