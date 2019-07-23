@generated function gen(v::Val{X}, m, s, a, rng) where X

    @debug("Creating an implementation for gen(::Val{$X}, ::M, ::S, ::A, ::RNG)",
           M=m, S=s, A=a, RNG=rng)
    vp = first(v.parameters)

    # use old generate_ function if available
    if haskey(old_generate, vp) && implemented(old_generate[vp], Tuple{m, s, a, rng})
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
        expr = quote x = NamedTuple() end
    end
    @assert expr.head == :block

    if X isa Tuple
        symbols = X
    elseif X isa Symbol
        symbols = (X,)
    else
        error("X must be a Symbol or Tuple") # TODO better error
    end

    # add fallbacks for other variables
    for var in filter(v->!(v in (:s, :a)), sorted_genvars(m, symbols))
        sym = Meta.quot(var)
        genvarargs = genvars[var].deps(m)
        genvarargtypes = [genvars[a].type(m) for a in genvarargs]

        if var == X && genvarargs == [:s, :a]
            # in this case, calling gen would lead to a stack overflow
            if genvars[var].fallback_implemented != nothing &&
                    genvars[var].fallback_implemented(m, s, a, rng)
                fallback = quote
                    $var = $(genvars[var].fallback)(m, s, a, rng)
                end
            else
                fallback = quote
                    # TODO helpful errors
                    try
                        $(genvars[var].fallback)(m, s, a, rng)
                    finally
                        throw(MethodError(gen, (v, m, s, a, rng)))
                    end
                end
            end
        elseif implemented(gen, Tuple{Val{var}, m, genvarargtypes..., rng})
            fallback = quote
                $var = gen(Val($sym), m, $(genvarargs...), rng)
            end
        else
            fallback = quote
                @warn("warning about return of no-val-gen") # TODO: better warning
                $var = gen(Val($sym), m, $(genvarargs...), rng)
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

    # add return expression
    if X isa Tuple
        return_expr = :(return $(Expr(:tuple, symbols...)))
    else # X isa Symbol
        return_expr = :(return $X)
    end
    append!(expr.args, return_expr.args)

    @debug("Implementing gen(::Val{$X}, ::M, ::S, ::A, ::RNG) with:\n$expr")
    return expr
end

@generated function gen(v::Val, args...)
    vp = first(v.parameters)
    if haskey(old_generate, vp) && implemented(old_generate[vp], Tuple{args...})
        @warn("Using ")
        return :($(old_generate[vp])(args...))
    elseif vp isa Symbol
        if genvars[vp].fallback_implemented != nothing &&
            genvars[vp].fallback_implemented(args...)
            return :($(genvars[vp].fallback)(args...))
        else
            # TODO helpful errors
            return quote
                try
                    $(genvars[vp].fallback)(args...) # for backedges
                finally
                    throw(MethodError(gen, (v, args...)))
                end
            end
        end
    else
        @error("""Automatic implementation of `gen(::Val{X}, ...)` where `X` is a `Tuple` is only supported in the case of gen(::Val{X}, m, s, a, rng). Expect an error below.
               
               You may wish to implement the missing function yourself, or if you would like this functionality, please file an issue at https://github.com/JuliaPOMDP/POMDPs.jl/issues/new.
               """)
        return :(throw(MethodError(gen, (v, args...))))
    end
end

function implemented(g::typeof(gen), TT::TupleType)
    v = first(TT.parameters)
    if v <: Val
        m = which(g, TT)
        argtypes_without_val = TT.parameters[2:end]
        vp = first(v.parameters)
        vptpl = vp isa Tuple ? vp : tuple(vp)
        if m.module != POMDPs # implemented by a user elsewhere
            return true
        elseif implemented(g, Tuple{argtypes_without_val...}) # gen(m,s,a,rng) is implemented
            return true
        elseif haskey(old_generate, vp) && implemented(old_generate[vp], TT)
            return true
        elseif vp isa Symbol &&
                genvars[vp].fallback_implemented != nothing &&
                genvars[vp].fallback_implemented(argtypes_without_val...)
            return true
        elseif vp isa Tuple
            # Note: already checked for gen(m,s,a,rng) above
            modeltype = first(argtypes_without_val)
            rngtype = last(argtypes_without_val)
            for var in filter(v->!(v in (:s, :a)), sorted_genvars(modeltype, vp))
                deptypes = collect(genvars[d].type(modeltype) for d in genvars[var].deps(modeltype))
                if !implemented(gen, Tuple{Val{var}, modeltype, deptypes..., rngtype})
                    return false
                end
            end
            return true
        else
            return false
        end
    else # gen(m,s,a,rng)
        return hasmethod(g, TT)
    end
end

struct GenVarData
    mod::Module #?
    longname::String
    descripton::String
    deps::Function
    type::Function # function of the model type - only used if things depend on it; can be abstract
    fallback_implemented::Union{Function,Nothing}
    fallback::Union{Function,Nothing}
end

GenVarData(m, l, d, deps, t) = GenVarData(m, l, d, deps, t, nothing, nothing)

const genvars = Dict{Symbol, GenVarData}()

rand_transition(m, s, a, rng) = rand(rng, transition(m, s, a))
rand_observation(m, s, a, sp, rng) = rand(rng, observation(m, s, a, sp))

genvars[:s] = GenVarData(@__MODULE__, "state", "state at the beginning of the step", M->Symbol[], statetype)
genvars[:a] = GenVarData(@__MODULE__, "action", "action taken by the agent", M->Symbol[], actiontype)

genvars[:sp] = GenVarData(@__MODULE__,
                      "new state",
                      "state at the end of the step",
                      M->[:s, :a],
                      statetype,
                      (M, S, A, RNG) -> implemented(transition, Tuple{M,S,A}),
                      rand_transition)

genvars[:o] = GenVarData(@__MODULE__,
                     "observation",
                     "observation (usually depends on sp)",
                     M->[:s, :a, :sp],
                     obstype,
                     (M, S, A, SP, RNG) -> implemented(observation, Tuple{M,S,A,SP}),
                     rand_observation)

genvars[:r] = GenVarData(@__MODULE__,
                     "reward",
                     "reward generated by the step",
                     M-> M <: POMDP ? [:s, :a, :sp, :o] : [:s, :a, :sp],
                     M->Number,
                     # for fallback, just get rid of the rng arg
                     (argtypes...) -> implemented(reward, Tuple{argtypes[1:end-1]...}),
                     (args...) -> reward(args[1:end-1]...))

function sorted_genvars(M::Type, symbols)
    dag = SimpleDiGraph(length(genvars))
    labels = Symbol[]
    nodemap = Dict{Symbol, Int}()
    for sym in symbols
        if !haskey(nodemap, sym)
            push!(labels, sym)
            nodemap[sym] = length(labels)
        end
        add_dep_edges!(dag, nodemap, labels, M, sym)
    end
    sortednodes = topological_sort_by_dfs(dag)
    return labels[filter(n -> n<=length(labels), sortednodes)]
end

function add_dep_edges!(dag, nodemap, labels, M::Type, sym)
    for dep in genvars[sym].deps(M)
        if !haskey(nodemap, dep)
            push!(labels, dep)
            nodemap[dep] = length(labels)
        end
        add_edge!(dag, nodemap[dep], nodemap[sym])
        add_dep_edges!(dag, nodemap, labels, M, dep)
    end
end
