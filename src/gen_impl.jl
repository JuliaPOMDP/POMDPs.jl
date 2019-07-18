@generated function gen(v::Val{X}, m, s, a, rng) where X

    @debug("Creating an implementation for gen(::Val{$X}, ::M, ::S, ::A, ::RNG)",
           M=m, S=s, A=a, RNG=rng)
    vp = first(v.parameters)

    # use old generate_ function if available
    if haskey(old_generate, vp) && implemented(old_generate[v], Tuple{m, s, a, rng})
        @warn("Using ")
        return :($(old_generate[vp])(m, s, a, rng))
    end

    # use anything available from gen(m, s, a, rng)
    if implemented(gen, Tuple{m,s,a,rng})
        @debug("Found gen(::M, ::S, ::A, ::RNG)", M=m, S=s, A=a, RNG=rng)
        novalgen_implemented = true
        expr = quote
            x = gen(m, s, a, rng)
            @assert x isa NamedTuple "gen(m::Union{MDP,POMDP}, ...) must return a NamedTuple; got a $(typeof(x))"
        end
    else
        novalgen_implemented = false
        expr = :(x = NamedTuple())
    end

    if X isa Tuple
        symbols = X
    elseif X isa Symbol
        symbols = (X,)
    else
        error("X must be a Symbol or Tuple")
    end

    # add fallbacks for other variables
    for var in sorted_genvars(symbols)
        sym = Meta.quot(var)
        genvarargs = genvars[var].deps
        genvarargtypes = [genvars[a].type(m) for a in genvarargs]

        if implemented(gen, Tuple{Var{var}, m, genvarargtypes..., rng})
            fallback = quote
                $var = gen(Var($sym), m, $(genvarargs...), rng)
            end
        else
            fallback = quote
                @warn("warning about return of no-val-gen") # TODO: better warning
                $var = gen(Var($sym), m, $(genvarargs...), rng)
            end
        end

        varblock = quote
            if haskey(x, $sym) # should be constant at compile time
                $var = x[$sym]
            else
                $fallback 
            end
        end
        append!(expr.args, varblock.args)
    end

    if X isa Tuple
        return_expr = quote
            return ($((:($var=$var) for var in symbols)...))
        end
    else # X isa Symbol
        return_expr = :(return $X)
    end
    append!(expr.args, return_expr.args)

    @debug("Implementing gen(::Val{$X}, ::M, ::S, ::A, ::RNG) with:\n$expr")
    return expr
end

@generated function gen(v::Val, args...)
    vp = first(v.parameters)
    if haskey(old_generate, vp) && implemented(old_generate[vp], args)
        @warn("Using ")
        return :($(old_generate[vp])(args...))
    elseif implemented(genfallback, Tuple{v, args...})
        return :(genfallback(v, args...))
    else
        return :(throw(MethodError(gen, (v, args...))))
    end
end

function implemented(g::typeof(gen), TT::TupleType)
    if first(tt.parameters) <: Val
        m = which(g, TT)
        argtypes_without_val = TT.parameters[2:end]
        if implemented(g, argtypes_without_val) # gen(m,s,a,rng) is implemented
            return true
        elseif haskey(old_generate, v) && implemented(old_generate[v], TT)
            return true
        elseif m.module != POMDPs # implemented by a user elsewhere
            return true
        elseif implemented(genfallback, TT)
            return true
        else
            return false
        end
    else # gen(m,s,a,rng)
        return hasmethod(g, TT)
    end
end

@generated function genfallback(v::Val{s}, m, genvarargs..., rng)
    for impl in genvars[s].implementations(m, genvarargs..., rng)
        if satisfied(genvars[s], impl)
            return expression(genvars[s], impl)
        end
    end
    # TODO: better error
    return :(error("genfallback failed for ", s))
end

function implemented(::typeof(genfallback), tt::TupleType)
    ValT = first(tt.parameters)
    @assert ValT <: Val
    impls = genvars[first(ValT.parameters)].implementations(tt.parameters[2:end]...)
    return any(satisfied, impls)
end

struct GenVarData
    mod::Module #?
    longname::String
    descripton::String
    deps::Array{Symbol}
    type::Function # function of the model type - only used if things depend on it; can be abstract
    implementations::Function
end

const genvars = Dict{Symbol, GenVarData}()

# implementations
# - Pair{Req, Function}
# - Pair{Req, Expr}
# - DeprecatedFallback
#
# - satisfied
# - expression
# - backedge_expression
# - suggestion

rand_transition(m, s, a, rng) = rand(rng, transition(m, s, a))
rand_observation(m, s, a, sp, rng) = rand(rng, observation(m, s, a, sp))

genvars[:s] = GenVarData(@__Module__, "state", "state at the beginning of the step", Symbol[], statetype)
genvars[:a] = GenVarData(@__Module__, "action", "action taken by the agent", Symbol[], actiontype)

genvars[:sp] = GenVarData(@__Module__,
                      "new state",
                      "state at the end of the step",
                      [:s, :a],
                      statetype
                     ) do M, S, A, RNG
    [@req(transition(::M, ::S, ::A)) => rand_transition]
end

genvars[:o] = GenVarData(@__Module__,
                     "observation",
                     "observation (usually depends on sp)",
                     [:s, :a, :sp],
                     obstype
                    ) do M, S, A, SP, RNG
    [@req(observation(::M, ::S, ::A, ::SP)) => rand_observation]
end

genvars[:r] = GenVarData(@__Module__,
                     "reward",
                     "reward generated by the step",
                     [:s, :a, :sp, :o],
                     m->Number,
                    ) do M, S, A, SP, O, RNG
    [@req(reward(::M, ::S, ::A, ::SP, ::O)) => :(reward(m, s, a, sp, o))]
end

function sorted_genvars(symbols)
    dag = SimpleDiGraph(length(genvars))
    labels = Symbol[]
    nodes = Dict{Symbol, Int}()
    for sym in symbols
        if !haskey(nodes, sym)
            push!(labels, sym)
            nodes[sym] = length(labels)
        end
        for dep in genvars[sym].deps
            if !haskey(nodes, dep)
                push!(labels, dep)
                nodes[dep] = length(labels)
            end
            add_edge!(dag, nodes[sym], nodes[dep])
        end
    end
    sortednodes = topological_sort_by_dfs(dag)
    return labels[sortednodes]
end

satisfied(gv::GenVarData, impl::Pair{Req}) = implemented(first(impl))
satisfied(gv::GenVarData, impl::DeprecatedFallback) = implemented(Req(impl.f, impl.argtypes))

expression(gv::GenVarData, impl::Pair{<:Any,<:Function}) = :($(last(impl))(m, $(gv.deps...), rng))
expression(gv::GenVarData, impl::Pair{<:Any,Expr}) = last(impl)
expression(gv::GenVarData, impl::DeprecatedFallback) = :($(impl.f)(m, $(gv.deps...), rng))

function backedge_expression(gv::GenVarData, types::TupleType)
    block = quote end
    for impl in gv.implementations(types.parameters...)
        push!(block.args, expression(gv, impl))
    end
    return block
end
